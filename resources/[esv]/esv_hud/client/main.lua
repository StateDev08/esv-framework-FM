local hudVisible = false

RegisterNetEvent('esv:client:hudVisible', function(visible)
    hudVisible = visible
    SendNUIMessage({ action = 'toggleHud', visible = visible })
end)

AddEventHandler('esv:client:spawnComplete', function()
    hudVisible = true
    SendNUIMessage({ action = 'toggleHud', visible = true })
end)

RegisterNetEvent('esv:client:moneyChanged', function(type, amount)
    SendNUIMessage({
        action = 'updateMoney',
        moneyType = type,
        amount = amount,
    })
end)

CreateThread(function()
    while true do
        Wait(500)
        if hudVisible and ESV.CharacterLoaded then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped) - 100
            local maxHealth = GetEntityMaxHealth(ped) - 100
            local armor = GetPedArmour(ped)
            local hunger = ESV.PlayerData.character and ESV.PlayerData.character.hunger or 100
            local thirst = ESV.PlayerData.character and ESV.PlayerData.character.thirst or 100
            local stress = ESV.PlayerData.character and ESV.PlayerData.character.stress or 0
            local cash = ESV.PlayerData.character and ESV.PlayerData.character.cash or 0
            local bank = ESV.PlayerData.character and ESV.PlayerData.character.bank or 0

            local healthPercent = maxHealth > 0 and math.floor((health / maxHealth) * 100) or 0
            if healthPercent < 0 then healthPercent = 0 end

            local isTalking = NetworkIsPlayerTalking(PlayerId())
            local inVehicle = IsPedInAnyVehicle(ped, false)
            local speed = 0
            local fuel = 100

            if inVehicle then
                local veh = GetVehiclePedIsIn(ped, false)
                speed = math.floor(GetEntitySpeed(veh) * 3.6)
                fuel = GetVehicleFuelLevel(veh)
            end

            SendNUIMessage({
                action = 'updateHud',
                health = healthPercent,
                armor = armor,
                hunger = math.floor(hunger),
                thirst = math.floor(thirst),
                stress = math.floor(stress),
                cash = cash,
                bank = bank,
                talking = isTalking,
                inVehicle = inVehicle,
                speed = speed,
                fuel = math.floor(fuel),
            })
        end
    end
end)

-- Minimap konfigurieren
CreateThread(function()
    while true do
        Wait(1000)
        if ESV.CharacterLoaded then
            DisplayRadar(hudVisible)
        end
    end
end)
