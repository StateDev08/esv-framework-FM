local playerDuty = {}

AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Job-System geladen (Polizei, EMS, Mechaniker)")
end)

RegisterNetEvent('esv:jobs:toggleDuty', function(state)
    local src = source
    playerDuty[src] = state
end)

RegisterNetEvent('esv:jobs:cuffPlayer', function(targetId)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or data.character.job ~= 'police' then return end

    TriggerClientEvent('esv:client:setCuffed', targetId, true)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler gefesselt')
end)

RegisterNetEvent('esv:jobs:searchPlayer', function(targetId)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or data.character.job ~= 'police' then return end

    ESV.Functions.TriggerCallback('esv:inventory:getItems', function(items)
        local itemList = "Inventar von ID " .. targetId .. ":\n"
        for _, item in ipairs(items) do
            itemList = itemList .. "- " .. item.label .. " x" .. item.amount .. "\n"
        end
        TriggerClientEvent('esv:client:notify', src, 'info', 'Durchsuchung durchgefuehrt')
    end)

    -- Einfacher Ansatz: Items des Ziels als Callback abrufen
    local targetData = exports.esv_core:GetPlayerBySrc(targetId)
    if targetData and targetData.characterId then
        local items = MySQL.query.await(
            'SELECT item_name, amount FROM inventories WHERE owner = ? AND owner_type = ?',
            { tostring(targetData.characterId), 'player' }
        )
        local msg = "Gefundene Items: "
        for _, item in ipairs(items or {}) do
            local def = ESV.Items[item.item_name]
            msg = msg .. (def and def.label or item.item_name) .. " x" .. item.amount .. ", "
        end
        TriggerClientEvent('esv:client:notify', src, 'info', msg)
    end

    TriggerClientEvent('esv:client:notify', targetId, 'info', 'Du wirst durchsucht')
end)

RegisterNetEvent('esv:jobs:finePlayer', function(targetId, amount, reason)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or data.character.job ~= 'police' then return end

    exports.esv_core:RemoveMoney(targetId, 'bank', amount)

    local targetData = exports.esv_core:GetPlayerBySrc(targetId)
    if targetData and targetData.characterId then
        MySQL.insert('INSERT INTO billing (character_id, sender, amount, reason, paid) VALUES (?, ?, ?, ?, ?)',
            { targetData.characterId, 'LSPD', amount, reason, 1 })
        MySQL.insert('INSERT INTO criminal_records (character_id, officer_id, charge, fine) VALUES (?, ?, ?, ?)',
            { targetData.characterId, data.characterId, reason, amount })
    end

    TriggerClientEvent('esv:client:notify', src, 'success', 'Bussgeld: $' .. amount .. ' ausgestellt')
    TriggerClientEvent('esv:client:notify', targetId, 'error', 'Bussgeld erhalten: $' .. amount .. ' - ' .. reason)
end)

RegisterNetEvent('esv:jobs:jailPlayer', function(targetId, time, reason)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or data.character.job ~= 'police' then return end

    local targetData = exports.esv_core:GetPlayerBySrc(targetId)
    if targetData and targetData.character then
        targetData.character.jail_time = time
        MySQL.update('UPDATE characters SET jail_time = ? WHERE id = ?', { time, targetData.characterId })
        MySQL.insert('INSERT INTO criminal_records (character_id, officer_id, charge, jail_time) VALUES (?, ?, ?, ?)',
            { targetData.characterId, data.characterId, reason, time })
    end

    TriggerClientEvent('esv:client:setCuffed', targetId, false)
    TriggerClientEvent('esv:client:jailed', targetId, time, reason)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler eingesperrt: ' .. time .. ' Minuten')
    TriggerClientEvent('esv:client:notify', targetId, 'error', 'Du wurdest eingesperrt: ' .. time .. ' Minuten - ' .. reason)
end)

RegisterNetEvent('esv:jobs:escortPlayer', function(targetId)
    local src = source
    TriggerClientEvent('esv:client:setEscorted', targetId, true, src)
end)

RegisterNetEvent('esv:jobs:releaseEscort', function(targetId)
    TriggerClientEvent('esv:client:setEscorted', targetId, false, 0)
end)

RegisterNetEvent('esv:jobs:healPlayer', function(targetId)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or data.character.job ~= 'ems' then return end

    TriggerClientEvent('esv:admin:heal', targetId)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler behandelt')
end)

RegisterNetEvent('esv:jobs:impoundVehicle', function(plate)
    MySQL.update('UPDATE vehicles SET state = ? WHERE plate = ?', { 'impound', plate })
end)

RegisterNetEvent('esv:jobs:repairComplete', function()
    local src = source
    exports.esv_core:AddMoney(src, 'cash', 250)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Reparatur-Bonus: $250')
end)

RegisterNetEvent('esv:jobs:spawnJobVehicle', function()
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    local jobData = ESV.Jobs[data.character.job]
    if not jobData or not jobData.vehicles then return end

    local availableVehicles = {}
    for _, veh in ipairs(jobData.vehicles) do
        if data.character.job_grade >= veh.grade then
            table.insert(availableVehicles, veh)
        end
    end

    if #availableVehicles == 0 then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Fahrzeuge verfuegbar')
        return
    end

    local vehicle = availableVehicles[#availableVehicles]
    local station = nil
    if jobData.stations then
        for _, s in pairs(jobData.stations) do
            if s.garage then
                station = s
                break
            end
        end
    end

    local spawnPos = station and station.garage or { x = 0, y = 0, z = 0, w = 0 }
    TriggerClientEvent('esv:client:spawnJobVehicle', src, vehicle.model, spawnPos)
end)

AddEventHandler('playerDropped', function()
    playerDuty[source] = nil
end)

exports('IsPlayerOnDuty', function(src) return playerDuty[src] or false end)
