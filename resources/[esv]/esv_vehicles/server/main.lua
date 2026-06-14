AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Fahrzeugsystem geladen")
end)

exports.esv_core:RegisterServerCallback('esv:vehicles:getGarage', function(src, cb, garageId)
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then cb({}) return end

    local vehicles = MySQL.query.await(
        'SELECT * FROM vehicles WHERE character_id = ? AND garage = ? AND state = ?',
        { data.characterId, garageId, 'parked' }
    )

    local result = {}
    for _, v in ipairs(vehicles or {}) do
        local vehDef = ESV.Functions.GetVehicleByModel(v.model)
        table.insert(result, {
            id = v.id,
            plate = v.plate,
            model = v.model,
            label = vehDef and vehDef.label or v.model,
            fuel = v.fuel,
            bodyHealth = v.body_health,
            engineHealth = v.engine_health,
        })
    end
    cb(result)
end)

RegisterNetEvent('esv:vehicles:spawn', function(vehicleId, garageId)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data then return end

    local vehicle = MySQL.single.await('SELECT * FROM vehicles WHERE id = ? AND character_id = ?',
        { vehicleId, data.characterId })
    if not vehicle then return end

    MySQL.update('UPDATE vehicles SET state = ? WHERE id = ?', { 'out', vehicleId })

    local garage = ESV.Config.Garages[garageId]
    local spawnPos = garage and garage.spawn or ESV.Config.DefaultSpawn

    TriggerClientEvent('esv:client:spawnVehicle', src, vehicle.model, vehicle.plate, spawnPos, vehicle.mods, vehicle.fuel)
end)

RegisterNetEvent('esv:vehicles:store', function(plate, garageId, fuel, bodyHealth, engineHealth)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data then return end

    MySQL.update('UPDATE vehicles SET state = ?, garage = ?, fuel = ?, body_health = ?, engine_health = ? WHERE plate = ? AND character_id = ?',
        { 'parked', garageId, fuel, bodyHealth, engineHealth, plate, data.characterId })

    TriggerClientEvent('esv:client:notify', src, 'success', 'Fahrzeug eingestellt')
end)

RegisterNetEvent('esv:vehicles:buy', function(model, shop)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return end

    local vehDef = ESV.Functions.GetVehicleByModel(model)
    if not vehDef then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Ungueltiges Fahrzeug!')
        return
    end

    if data.character.bank < vehDef.price then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Geld! Benoetigst: $' .. vehDef.price)
        return
    end

    exports.esv_core:RemoveMoney(src, 'bank', vehDef.price)

    local plate = ESV.Functions.GeneratePlate()
    while MySQL.single.await('SELECT id FROM vehicles WHERE plate = ?', { plate }) do
        plate = ESV.Functions.GeneratePlate()
    end

    MySQL.insert('INSERT INTO vehicles (character_id, plate, model, garage, state) VALUES (?, ?, ?, ?, ?)',
        { data.characterId, plate, model, 'hauptgarage', 'parked' })

    MySQL.insert('INSERT INTO vehicle_keys (plate, character_id, is_owner) VALUES (?, ?, ?)',
        { plate, data.characterId, 1 })

    TriggerClientEvent('esv:client:notify', src, 'success', vehDef.label .. ' gekauft! Kennzeichen: ' .. plate)
end)

RegisterNetEvent('esv:vehicles:refuel', function(cost, amount)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data then return end

    if data.character.cash >= cost then
        exports.esv_core:RemoveMoney(src, 'cash', cost)
        TriggerClientEvent('esv:client:refueled', src, amount)
        TriggerClientEvent('esv:client:notify', src, 'info', 'Getankt fuer $' .. cost)
    else
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Bargeld!')
    end
end)
