AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Wohnungssystem geladen")
end)

local propertyData = {
    apt_01 = { label = 'Apartment Alta St.', price = 150000, interior = { x = 346.5, y = -1013.0, z = -99.2 }, exterior = { x = -271.0, y = -957.0, z = 31.2 } },
    apt_02 = { label = 'Apartment Vinewood', price = 250000, interior = { x = 346.5, y = -1013.0, z = -99.2 }, exterior = { x = -906.3, y = -370.2, z = 113.1 } },
    apt_03 = { label = 'Haus Grove Street', price = 350000, interior = { x = 346.5, y = -1013.0, z = -99.2 }, exterior = { x = -14.9, y = -1438.7, z = 31.1 } },
    apt_04 = { label = 'Haus Paleto Bay', price = 120000, interior = { x = 346.5, y = -1013.0, z = -99.2 }, exterior = { x = -381.0, y = 6262.0, z = 31.5 } },
    apt_05 = { label = 'Villa Vinewood Hills', price = 800000, interior = { x = 346.5, y = -1013.0, z = -99.2 }, exterior = { x = -855.7, y = 682.5, z = 152.6 } },
    apt_06 = { label = 'Villa Richman', price = 1200000, interior = { x = 346.5, y = -1013.0, z = -99.2 }, exterior = { x = -1543.0, y = 119.0, z = 59.2 } },
}

RegisterNetEvent('esv:housing:interact', function(propId)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return end

    local prop = propertyData[propId]
    if not prop then return end

    local dbProp = MySQL.single.await('SELECT * FROM properties WHERE name = ?', { propId })

    if not dbProp then
        MySQL.insert('INSERT INTO properties (name, label, price, position) VALUES (?, ?, ?, ?)',
            { propId, prop.label, prop.price, json.encode(prop.exterior) })
        dbProp = MySQL.single.await('SELECT * FROM properties WHERE name = ?', { propId })
    end

    if dbProp.owner_id == data.characterId then
        TriggerClientEvent('esv:client:enterProperty', src, propId, prop.interior, 0.0)
    elseif not dbProp.owner_id then
        if data.character.bank >= prop.price then
            exports.esv_core:RemoveMoney(src, 'bank', prop.price)
            MySQL.update('UPDATE properties SET owner_id = ? WHERE name = ?', { data.characterId, propId })
            TriggerClientEvent('esv:client:propertyBought', src, prop.label, prop.price)
            TriggerClientEvent('esv:client:enterProperty', src, propId, prop.interior, 0.0)
        else
            TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Geld! Preis: $' .. prop.price)
        end
    else
        TriggerClientEvent('esv:client:notify', src, 'error', 'Diese Wohnung gehoert jemand anderem!')
    end
end)

RegisterNetEvent('esv:housing:exit', function(propId)
    local src = source
    local prop = propertyData[propId]
    if prop then
        TriggerClientEvent('esv:client:exitProperty', src, prop.exterior)
    end
end)
