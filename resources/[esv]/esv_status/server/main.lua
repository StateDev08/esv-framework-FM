AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("^2[ESV]^0 Status-System geladen")
end)

-- Item-Nutzung registrieren
RegisterNetEvent('esv:server:useItem', function(itemName)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    local foodItems = {
        brot = { type = 'eat', amount = 25 },
        burger = { type = 'eat', amount = 35 },
        sandwich = { type = 'eat', amount = 30 },
        donut = { type = 'eat', amount = 15 },
    }

    local drinkItems = {
        wasser = { type = 'drink', amount = 30 },
        cola = { type = 'drink', amount = 25 },
        kaffee = { type = 'drink', amount = 20 },
        energydrink = { type = 'drink', amount = 35 },
    }

    if foodItems[itemName] then
        TriggerClientEvent('esv:client:eat', src, foodItems[itemName].amount)
    elseif drinkItems[itemName] then
        TriggerClientEvent('esv:client:drink', src, drinkItems[itemName].amount)
    end
end)
