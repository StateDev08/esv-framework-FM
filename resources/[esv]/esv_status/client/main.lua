local hunger = 100.0
local thirst = 100.0
local stress = 0.0

AddEventHandler('esv:client:spawnComplete', function()
    if ESV.PlayerData.character then
        hunger = ESV.PlayerData.character.hunger or 100
        thirst = ESV.PlayerData.character.thirst or 100
        stress = ESV.PlayerData.character.stress or 0
    end
end)

-- Status-Abbau
CreateThread(function()
    while true do
        Wait(60 * 1000) -- jede Minute
        if not ESV.CharacterLoaded then goto continue end
        if ESV.PlayerData.character and ESV.PlayerData.character.is_dead then goto continue end

        hunger = math.max(0, hunger - ESV.Config.HungerDecay)
        thirst = math.max(0, thirst - ESV.Config.ThirstDecay)
        stress = math.max(0, stress - ESV.Config.StressDecay)

        -- Effekte bei niedrigem Status
        local ped = PlayerPedId()

        if hunger <= 0 or thirst <= 0 then
            local health = GetEntityHealth(ped)
            SetEntityHealth(ped, math.max(100, health - 5))
        end

        if hunger < 20 then
            TriggerEvent('esv:client:notify', 'warning', 'Du hast starken Hunger!')
        end
        if thirst < 20 then
            TriggerEvent('esv:client:notify', 'warning', 'Du hast starken Durst!')
        end

        -- Stress-Effekte
        if stress > 80 then
            SetPedMotionBlur(ped, true)
        else
            SetPedMotionBlur(ped, false)
        end

        -- Daten synchronisieren
        ESV.PlayerData.character.hunger = hunger
        ESV.PlayerData.character.thirst = thirst
        ESV.PlayerData.character.stress = stress
        TriggerServerEvent('esv:server:updateStatus', hunger, thirst, stress)

        ::continue::
    end
end)

-- Stress durch Schüsse/Geschwindigkeit
CreateThread(function()
    while true do
        Wait(5000)
        if not ESV.CharacterLoaded then goto continue end

        local ped = PlayerPedId()

        if IsPedShooting(ped) then
            stress = math.min(100, stress + 2)
        end

        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local speed = GetEntitySpeed(veh) * 3.6
            if speed > 150 then
                stress = math.min(100, stress + 1)
            end
        end

        ::continue::
    end
end)

-- Item-Nutzung: Essen & Trinken
RegisterNetEvent('esv:client:eat', function(amount)
    hunger = math.min(100, hunger + (amount or 20))
    ESV.PlayerData.character.hunger = hunger
    TriggerEvent('esv:client:notify', 'success', 'Du hast etwas gegessen')
end)

RegisterNetEvent('esv:client:drink', function(amount)
    thirst = math.min(100, thirst + (amount or 25))
    ESV.PlayerData.character.thirst = thirst
    TriggerEvent('esv:client:notify', 'success', 'Du hast etwas getrunken')
end)

RegisterNetEvent('esv:client:relieveStress', function(amount)
    stress = math.max(0, stress - (amount or 15))
    ESV.PlayerData.character.stress = stress
end)

exports('GetHunger', function() return hunger end)
exports('GetThirst', function() return thirst end)
exports('GetStress', function() return stress end)
exports('SetHunger', function(v) hunger = v end)
exports('SetThirst', function(v) thirst = v end)
exports('SetStress', function(v) stress = v end)
