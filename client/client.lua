local QBCore = exports['qb-core']:GetCoreObject()

-- Debug helper
local function DebugPrint(msg)
    if Config.Debug then
        print("^3[qb-hunting DEBUG]^0 " .. msg)
    end
end

local deerPopulation = {}

-- Spawn a deer
local function spawnDeer(zoneIndex)
    local zone = Config.DeerSpawnZones[zoneIndex]
    local model = Config.DeerModels[math.random(#Config.DeerModels)]

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    -- Pick a random point inside the zone
    local x = zone.coords.x + (math.random() * 2 - 1) * zone.radius
    local y = zone.coords.y + (math.random() * 2 - 1) * zone.radius
    local z = zone.coords.z + 50.0 -- check from above

    -- ✅ Proper FiveM ground check
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z, Citizen.ResultAsFloat())
    if not found then
        groundZ = zone.coords.z -- fallback
    end

    local spawnPos = vector3(x, y, groundZ)
    local heading = math.random(0, 360)

    DebugPrint(("Spawning deer at %.2f, %.2f, %.2f in zone %d"):format(
        spawnPos.x, spawnPos.y, spawnPos.z, zoneIndex))

    local deer = CreatePed(28, model, spawnPos.x, spawnPos.y, spawnPos.z, heading, true, true)
    if not DoesEntityExist(deer) then
        DebugPrint("❌ Failed to spawn deer!")
        return
    else
        DebugPrint("✅ Deer spawned successfully.")
    end

    SetEntityAsMissionEntity(deer, true, true)

    -- Randomize wandering
    local wanderType = math.random(0, 2)
    if wanderType == 0 then
        TaskWanderStandard(deer, 10.0, 10)
    elseif wanderType == 1 then
        TaskWanderStandard(deer, 10.0, 5)
    else
        TaskWanderStandard(deer, 10.0, 15)
    end

    SetEntityHeading(deer, heading)

    local healthiness = math.random(50, 100) / 100
    deerPopulation[deer] = { healthiness = healthiness, zone = zoneIndex }
end


-- 🦌 Maintain deer population (per-zone counting)
CreateThread(function()
    while true do
        for zoneIndex, zone in ipairs(Config.DeerSpawnZones) do
            local count = 0

            -- count deer only in this zone and clean up invalids
            for deer, data in pairs(deerPopulation) do
                if DoesEntityExist(deer) then
                    if data.zone == zoneIndex then
                        count = count + 1
                    end
                else
                    deerPopulation[deer] = nil
                end
            end

            -- top up ONLY this zone
            if count < Config.MaxDeerPerZone then
                local needed = Config.MaxDeerPerZone - count
                for i = 1, needed do
                    spawnDeer(zoneIndex)
                    Wait(500)
                end
            end

            if Config.Debug then
                print(("[HUNTING] Zone %d has %d/%d deer")
                    :format(zoneIndex, count, Config.MaxDeerPerZone))
            end
        end

        DebugPrint("Population check complete.")
        Wait(Config.PopulationCheckInterval * 1000)
    end
end)

-- Add qb-target option for deer
exports['qb-target']:AddTargetModel(Config.DeerModels, {
    options = {
        {
            type = "client",
            event = "qb-hunting:client:tryButcher",
            icon = "fa-solid fa-knife",
            label = "Butcher Deer",
            canInteract = function(entity, distance, data)
                -- Only show if deer is dead and within 2.5 units
                if not DoesEntityExist(entity) then return false end
                if GetEntityHealth(entity) > 0 then return false end
                if distance > 2.5 then return false end
                return true
            end
        }
    },
    distance = 2.5
})

RegisterNetEvent("qb-hunting:client:tryButcher", function(data)
    local ped = data.entity
    if not DoesEntityExist(ped) then return end

    local playerPed = PlayerPedId()
    TaskTurnPedToFaceEntity(playerPed, ped, 1000)
    Wait(1000)

    -- Play animation
    RequestAnimDict("amb@medic@standing@kneel@base")
    while not HasAnimDictLoaded("amb@medic@standing@kneel@base") do Wait(10) end
    TaskPlayAnim(playerPed, "amb@medic@standing@kneel@base", "base", 3.0, -1, 5000, 49, 0, 0, 0, 0)

    QBCore.Functions.Progressbar("butcher_deer", "Butchering deer...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(playerPed)

        -- Send to server with healthiness
        local healthiness = 0.8 -- fallback if we can't retrieve stored value
        TriggerServerEvent("qb-hunting:server:butcherDeer", NetworkGetNetworkIdFromEntity(ped), healthiness)
    end, function() -- Cancel
        ClearPedTasks(playerPed)
        QBCore.Functions.Notify("Butchering cancelled", "error")
    end)
end)
