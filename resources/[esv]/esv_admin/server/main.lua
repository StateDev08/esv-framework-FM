AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Admin-System geladen")
end)

-- /setjob [id] [job] [grade]
RegisterCommand('setjob', function(src, args)
    if src ~= 0 and not exports.esv_core:IsAdmin(src, 2) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Berechtigung!')
        return
    end
    local targetId = tonumber(args[1])
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0
    if not targetId or not jobName then
        if src == 0 then print("Verwendung: /setjob [id] [job] [grade]")
        else TriggerClientEvent('esv:client:notify', src, 'error', 'Verwendung: /setjob [id] [job] [grade]') end
        return
    end
    local success = exports.esv_core:SetJob(targetId, jobName, grade)
    if success then
        if src ~= 0 then TriggerClientEvent('esv:client:notify', src, 'success', 'Job gesetzt!') end
        TriggerClientEvent('esv:client:notify', targetId, 'info', 'Dein Job wurde geaendert.')
        exports.esv_core:LogAdmin(src, 'setjob', tostring(targetId), jobName .. ' Grade: ' .. grade)
    else
        if src ~= 0 then TriggerClientEvent('esv:client:notify', src, 'error', 'Ungueltiger Job oder Rang!') end
    end
end, false)

-- /givemoney [id] [cash/bank] [amount]
RegisterCommand('givemoney', function(src, args)
    if src ~= 0 and not exports.esv_core:IsAdmin(src, 2) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Berechtigung!')
        return
    end
    local targetId = tonumber(args[1])
    local moneyType = args[2]
    local amount = tonumber(args[3])
    if not targetId or not moneyType or not amount then
        if src ~= 0 then TriggerClientEvent('esv:client:notify', src, 'error', '/givemoney [id] [cash/bank] [betrag]') end
        return
    end
    exports.esv_core:AddMoney(targetId, moneyType, amount)
    if src ~= 0 then TriggerClientEvent('esv:client:notify', src, 'success', '$' .. amount .. ' gegeben') end
    TriggerClientEvent('esv:client:notify', targetId, 'success', '$' .. amount .. ' erhalten (Admin)')
    exports.esv_core:LogAdmin(src, 'givemoney', tostring(targetId), moneyType .. ': ' .. amount)
end, false)

-- /giveitem [id] [item] [amount]
RegisterCommand('giveitem', function(src, args)
    if src ~= 0 and not exports.esv_core:IsAdmin(src, 2) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Berechtigung!')
        return
    end
    local targetId = tonumber(args[1])
    local itemName = args[2]
    local amount = tonumber(args[3]) or 1
    if not targetId or not itemName then
        if src ~= 0 then TriggerClientEvent('esv:client:notify', src, 'error', '/giveitem [id] [item] [anzahl]') end
        return
    end
    exports.esv_inventory:AddItem(targetId, itemName, amount)
    if src ~= 0 then TriggerClientEvent('esv:client:notify', src, 'success', 'Item gegeben') end
    exports.esv_core:LogAdmin(src, 'giveitem', tostring(targetId), itemName .. ' x' .. amount)
end, false)

-- /tp [id] - teleport zu spieler
RegisterCommand('tp', function(src, args)
    if not exports.esv_core:IsAdmin(src, 1) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Berechtigung!')
        return
    end
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('esv:client:notify', src, 'error', '/tp [id]')
        return
    end
    local targetPed = GetPlayerPed(targetId)
    if targetPed and DoesEntityExist(targetPed) then
        local coords = GetEntityCoords(targetPed)
        TriggerClientEvent('esv:admin:teleport', src, coords.x, coords.y, coords.z)
        TriggerClientEvent('esv:client:notify', src, 'success', 'Teleportiert zu ID: ' .. targetId)
        exports.esv_core:LogAdmin(src, 'teleport', tostring(targetId))
    end
end, false)

-- /bring [id]
RegisterCommand('bring', function(src, args)
    if not exports.esv_core:IsAdmin(src, 1) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Berechtigung!')
        return
    end
    local targetId = tonumber(args[1])
    if not targetId then return end
    local adminPed = GetPlayerPed(src)
    local coords = GetEntityCoords(adminPed)
    TriggerClientEvent('esv:admin:teleport', targetId, coords.x, coords.y, coords.z)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler herbeigeholt')
    TriggerClientEvent('esv:client:notify', targetId, 'info', 'Du wurdest zu einem Admin teleportiert')
    exports.esv_core:LogAdmin(src, 'bring', tostring(targetId))
end, false)

-- /kick [id] [grund]
RegisterCommand('kick', function(src, args)
    if src ~= 0 and not exports.esv_core:IsAdmin(src, 1) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Berechtigung!')
        return
    end
    local targetId = tonumber(args[1])
    if not targetId then return end
    local reason = table.concat(args, " ", 2) or "Kein Grund angegeben"
    DropPlayer(targetId, "Gekickt: " .. reason)
    if src ~= 0 then TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler gekickt') end
    exports.esv_core:LogAdmin(src, 'kick', tostring(targetId), reason)
end, false)

-- /ban [id] [dauer_minuten] [grund]
RegisterCommand('ban', function(src, args)
    if src ~= 0 and not exports.esv_core:IsAdmin(src, 2) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Berechtigung!')
        return
    end
    local targetId = tonumber(args[1])
    local duration = tonumber(args[2]) or 60
    local reason = table.concat(args, " ", 3) or "Kein Grund angegeben"
    if not targetId then return end

    local license = ESV.Functions.GetIdentifier(targetId, "license")
    if license then
        local expireTime = os.time() + (duration * 60)
        MySQL.update('UPDATE players SET banned = 1, ban_reason = ?, ban_expire = FROM_UNIXTIME(?) WHERE license = ?',
            { reason, expireTime, license })
    end

    DropPlayer(targetId, "Gebannt fuer " .. duration .. " Minuten: " .. reason)
    if src ~= 0 then TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler gebannt') end
    exports.esv_core:LogAdmin(src, 'ban', tostring(targetId), duration .. 'min - ' .. reason)
end, false)

-- /revive [id]
RegisterCommand('revive', function(src, args)
    if not exports.esv_core:IsAdmin(src, 1) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Keine Berechtigung!')
        return
    end
    local targetId = tonumber(args[1]) or src
    TriggerClientEvent('esv:client:revive', targetId)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler wiederbelebt')
    exports.esv_core:LogAdmin(src, 'revive', tostring(targetId))
end, false)

-- /heal [id]
RegisterCommand('heal', function(src, args)
    if not exports.esv_core:IsAdmin(src, 1) then return end
    local targetId = tonumber(args[1]) or src
    TriggerClientEvent('esv:admin:heal', targetId)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler geheilt')
    exports.esv_core:LogAdmin(src, 'heal', tostring(targetId))
end, false)

-- /noclip
RegisterCommand('noclip', function(src)
    if not exports.esv_core:IsAdmin(src, 1) then return end
    TriggerClientEvent('esv:admin:noclip', src)
end, false)

-- /announce [text]
RegisterCommand('announce', function(src, args)
    if src ~= 0 and not exports.esv_core:IsAdmin(src, 2) then return end
    local text = table.concat(args, " ")
    TriggerClientEvent('esv:client:notify', -1, 'warning', '[ANKUENDIGUNG] ' .. text)
    exports.esv_core:LogAdmin(src, 'announce', '', text)
end, false)

-- /setadmin [id] [level]
RegisterCommand('setadmin', function(src, args)
    if src ~= 0 and not exports.esv_core:IsAdmin(src, 4) then return end
    local targetId = tonumber(args[1])
    local level = tonumber(args[2]) or 0
    if not targetId then return end
    local license = ESV.Functions.GetIdentifier(targetId, "license")
    if license then
        MySQL.update('UPDATE players SET admin_level = ? WHERE license = ?', { level, license })
        local data = ESV.PlayersBySource[targetId]
        if data then data.admin_level = level end
        TriggerClientEvent('esv:client:notify', targetId, 'info', 'Dein Admin-Level wurde auf ' .. level .. ' gesetzt')
    end
    exports.esv_core:LogAdmin(src, 'setadmin', tostring(targetId), 'Level: ' .. level)
end, false)

-- /car [model]
RegisterCommand('car', function(src, args)
    if not exports.esv_core:IsAdmin(src, 2) then return end
    local model = args[1] or 'adder'
    TriggerClientEvent('esv:admin:spawnVehicle', src, model)
    exports.esv_core:LogAdmin(src, 'spawncar', '', model)
end, false)

-- /dv - delete vehicle
RegisterCommand('dv', function(src)
    if not exports.esv_core:IsAdmin(src, 1) then return end
    TriggerClientEvent('esv:admin:deleteVehicle', src)
end, false)
