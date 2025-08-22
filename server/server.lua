local QBCore = exports['qb-core']:GetCoreObject()
local function DebugPrint(msg)
    if Config.Debug then
        print("^3[qb-hunting DEBUG]^0 " .. msg)
    end
end

RegisterNetEvent("qb-hunting:server:butcherDeer", function(deerNetId, healthiness)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local knife = Player.Functions.GetItemByName("weapon_knife")
    if not knife then
        TriggerClientEvent('QBCore:Notify', src, "You need a knife to butcher this!", "error")
        return
    end

    local baseMeat = math.random(Config.MinMeat, Config.MaxMeat)
    local meatAmount = math.floor(baseMeat * (healthiness or 1.0))

    exports['ps-inventory']:AddItem(src, "meat", meatAmount)
    TriggerClientEvent('QBCore:Notify', src, ("You butchered the deer and got %d meat."):format(meatAmount), "success")

    -- Delete deer entity
    local deer = NetworkGetEntityFromNetworkId(deerNetId)
    if DoesEntityExist(deer) then DeleteEntity(deer) end
end)
