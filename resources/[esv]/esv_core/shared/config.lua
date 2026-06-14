ESV = ESV or {}
ESV.Config = {}

-- Server-Einstellungen
ESV.Config.ServerName = "ESV Hardcore RP"
ESV.Config.Locale = "de"
ESV.Config.MaxCharacters = 3

-- Startgeld
ESV.Config.StartCash = 5000
ESV.Config.StartBank = 10000

-- Spawn-Position (Standard)
ESV.Config.DefaultSpawn = vector4(-269.4, -955.3, 31.2, 208.0)

-- Gehalts-Intervall (Millisekunden)
ESV.Config.PaycheckInterval = 15 * 60 * 1000 -- 15 Minuten

-- Status-Einstellungen
ESV.Config.HungerDecay = 0.3    -- pro Minute
ESV.Config.ThirstDecay = 0.4    -- pro Minute
ESV.Config.StressDecay = 0.1    -- pro Minute (natuerlicher Abbau)

-- Tod-Einstellungen
ESV.Config.DeathTimer = 300     -- Sekunden bis Respawn moeglich
ESV.Config.RespawnCost = 2500   -- Kosten fuer Krankenhaus-Respawn
ESV.Config.RespawnLocation = vector4(340.5, -1397.0, 32.5, 60.0) -- Pillbox Hospital

-- Admin-Level
ESV.Config.AdminLevels = {
    [1] = "Moderator",
    [2] = "Admin",
    [3] = "Superadmin",
    [4] = "Owner",
}

-- Polizei-Einstellungen
ESV.Config.PoliceJobName = "police"
ESV.Config.MinPoliceForRobbery = 2

-- Garagen
ESV.Config.Garages = {
    hauptgarage = {
        label = "Hauptgarage",
        spawn = vector4(-338.0, -780.0, 33.96, 137.0),
        blip = { sprite = 357, color = 3, scale = 0.8 },
    },
    legion = {
        label = "Legion Square Garage",
        spawn = vector4(215.0, -810.0, 30.7, 160.0),
        blip = { sprite = 357, color = 3, scale = 0.8 },
    },
    airport = {
        label = "Flughafen Garage",
        spawn = vector4(-796.0, -2024.0, 9.17, 57.0),
        blip = { sprite = 357, color = 3, scale = 0.8 },
    },
}

-- Geldautomaten (ATM-Modelle)
ESV.Config.ATMModels = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`,
}

-- Tankstellen
ESV.Config.FuelPrice = 2.5  -- pro Liter
ESV.Config.MaxFuel = 100.0

-- Telefon
ESV.Config.PhoneItem = "handy"
ESV.Config.EmergencyNumber = "110"  -- Polizei
ESV.Config.EMSNumber = "112"        -- Rettungsdienst

-- Gefaengnis
ESV.Config.JailPosition = vector4(1680.0, 2513.0, 45.56, 0.0) -- Bolingbroke
ESV.Config.JailReducePerMinute = 1

return ESV.Config
