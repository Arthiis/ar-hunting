Config = {}

-- Toggle debugging (prints messages to F8 console)
Config.Debug = false

-- Deer spawn settings
Config.DeerModels = { `a_c_deer` }

-- Zones where deer can spawn
Config.DeerSpawnZones = {
    { coords = vector3(-640.93, 5476.18, 48.19), radius = 50.0 },
    { coords = vector3(-725.42, 5351.02, 63.43), radius = 60.0 },
    { coords = vector3(-668.08, 5241.97, 76.91), radius = 70.0 },
}

-- Maximum deer per zone
Config.MaxDeerPerZone = 20

-- Time (in seconds) between population checks
Config.PopulationCheckInterval = 60 -- every 60 seconds

-- Respawn cooldown (in seconds)
Config.SpawnCooldown = 10800 -- 3 hours

Config.MinMeat = 2
Config.MaxMeat = 5


-- Flee behavior
Config.FleeDistance       = 30.0    -- flee if player is this close
Config.ShotFleeDistance   = 100.0   -- flee if gunshot within this range
Config.CalmDistance       = 60.0    -- calm only if player is farther than this

-- Durations (milliseconds)
Config.GrazeTime          = { 6000, 15000 }  -- min/max graze time
Config.WanderTime         = { 8000, 20000 }  -- min/max time to try to walk to a point
Config.FleeDuration       = { 12000, 20000 } -- min/max time to keep fleeing before re-check

-- Wander movement speeds (walk-like)
Config.WanderSpeed        = { 0.6, 1.2 }     -- min/max speed