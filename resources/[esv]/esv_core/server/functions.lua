ESV = ESV or {}
ESV.Functions = ESV.Functions or {}

function ESV.Functions.GetIdentifier(src, idType)
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if string.find(id, idType .. ":") then
            return id
        end
    end
    return nil
end

function ESV.Functions.GetPlayerData(src)
    return ESV.PlayersBySource[src]
end

function ESV.Functions.GetPlayerByCharId(charId)
    return ESV.Players[charId]
end

function ESV.Functions.GetPlayerBySrc(src)
    return ESV.PlayersBySource[src]
end

function ESV.Functions.GetPlayersByJob(jobName)
    local players = {}
    for src, data in pairs(ESV.PlayersBySource) do
        if data.character and data.character.job == jobName then
            table.insert(players, { source = src, data = data })
        end
    end
    return players
end

function ESV.Functions.GetOnlinePlayerCount()
    local count = 0
    for _ in pairs(ESV.PlayersBySource) do
        count = count + 1
    end
    return count
end

function ESV.Functions.SaveCharacter(src)
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local position = json.encode({ x = coords.x, y = coords.y, z = coords.z, h = heading })

    MySQL.update(
        'UPDATE characters SET cash = ?, bank = ?, job = ?, job_grade = ?, position = ?, health = ?, armor = ?, hunger = ?, thirst = ?, stress = ?, is_dead = ?, jail_time = ?, last_played = NOW() WHERE id = ?',
        {
            data.character.cash,
            data.character.bank,
            data.character.job,
            data.character.job_grade,
            position,
            data.character.health or 200,
            data.character.armor or 0,
            data.character.hunger or 100,
            data.character.thirst or 100,
            data.character.stress or 0,
            data.character.is_dead and 1 or 0,
            data.character.jail_time or 0,
            data.characterId,
        }
    )
end

function ESV.Functions.AddMoney(src, moneyType, amount, reason)
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then return false end
    if amount <= 0 then return false end

    if moneyType == 'cash' then
        data.character.cash = data.character.cash + amount
        MySQL.update('UPDATE characters SET cash = ? WHERE id = ?', { data.character.cash, data.characterId })
        TriggerClientEvent('esv:client:updateMoney', src, 'cash', data.character.cash)
    elseif moneyType == 'bank' then
        data.character.bank = data.character.bank + amount
        MySQL.update('UPDATE characters SET bank = ? WHERE id = ?', { data.character.bank, data.characterId })
        TriggerClientEvent('esv:client:updateMoney', src, 'bank', data.character.bank)
    end

    return true
end

function ESV.Functions.RemoveMoney(src, moneyType, amount, reason)
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then return false end
    if amount <= 0 then return false end

    if moneyType == 'cash' then
        if data.character.cash < amount then return false end
        data.character.cash = data.character.cash - amount
        MySQL.update('UPDATE characters SET cash = ? WHERE id = ?', { data.character.cash, data.characterId })
        TriggerClientEvent('esv:client:updateMoney', src, 'cash', data.character.cash)
    elseif moneyType == 'bank' then
        if data.character.bank < amount then return false end
        data.character.bank = data.character.bank - amount
        MySQL.update('UPDATE characters SET bank = ? WHERE id = ?', { data.character.bank, data.characterId })
        TriggerClientEvent('esv:client:updateMoney', src, 'bank', data.character.bank)
    end

    return true
end

function ESV.Functions.GetMoney(src, moneyType)
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then return 0 end
    if moneyType == 'cash' then return data.character.cash end
    if moneyType == 'bank' then return data.character.bank end
    return 0
end

function ESV.Functions.SetJob(src, jobName, grade)
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then return false end

    local job = ESV.Jobs[jobName]
    if not job then return false end
    if not job.grades[grade] then return false end

    data.character.job = jobName
    data.character.job_grade = grade

    MySQL.update('UPDATE characters SET job = ?, job_grade = ? WHERE id = ?',
        { jobName, grade, data.characterId })

    TriggerClientEvent('esv:client:jobUpdated', src, jobName, job.label, grade, job.grades[grade].label)
    return true
end

function ESV.Functions.IsAdmin(src, minLevel)
    local data = ESV.PlayersBySource[src]
    if not data then return false end
    return data.admin_level >= (minLevel or 1)
end

function ESV.Functions.GetSourceByCharId(charId)
    for src, data in pairs(ESV.PlayersBySource) do
        if data.characterId == charId then
            return src
        end
    end
    return nil
end

function ESV.Functions.LogAdmin(adminSrc, action, target, details)
    local adminData = ESV.PlayersBySource[adminSrc]
    local adminId = adminData and adminData.id or 0
    MySQL.insert('INSERT INTO admin_logs (admin_id, action, target, details) VALUES (?, ?, ?, ?)',
        { adminId, action, target or '', details or '' })
end

-- Callback-System
ESV.ServerCallbacks = {}

function ESV.Functions.RegisterServerCallback(name, cb)
    ESV.ServerCallbacks[name] = cb
end

RegisterNetEvent('esv:server:triggerCallback', function(name, requestId, ...)
    local src = source
    if ESV.ServerCallbacks[name] then
        ESV.ServerCallbacks[name](src, function(...)
            TriggerClientEvent('esv:client:callbackResponse', src, requestId, ...)
        end, ...)
    end
end)

-- Server-Callbacks registrieren

ESV.Functions.RegisterServerCallback('esv:getCharacters', function(src, cb)
    local data = ESV.PlayersBySource[src]
    if not data then cb({}) return end

    local characters = MySQL.query.await(
        'SELECT slot, firstname, lastname, dateofbirth, gender, job, job_grade, cash, bank, last_played FROM characters WHERE player_id = ? ORDER BY slot',
        { data.id }
    )

    local result = {}
    for _, char in ipairs(characters or {}) do
        local jobData = ESV.Jobs[char.job]
        char.jobLabel = jobData and jobData.label or "Arbeitslos"
        char.gradeLabel = jobData and jobData.grades[char.job_grade] and jobData.grades[char.job_grade].label or ""
        result[char.slot] = char
    end

    cb(result)
end)

ESV.Functions.RegisterServerCallback('esv:getPlayerMoney', function(src, cb)
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then cb(0, 0) return end
    cb(data.character.cash, data.character.bank)
end)

-- Exports
exports('GetPlayerData', ESV.Functions.GetPlayerData)
exports('GetPlayerBySrc', ESV.Functions.GetPlayerBySrc)
exports('GetPlayerByCharId', ESV.Functions.GetPlayerByCharId)
exports('GetPlayersByJob', ESV.Functions.GetPlayersByJob)
exports('AddMoney', ESV.Functions.AddMoney)
exports('RemoveMoney', ESV.Functions.RemoveMoney)
exports('GetMoney', ESV.Functions.GetMoney)
exports('SetJob', ESV.Functions.SetJob)
exports('IsAdmin', ESV.Functions.IsAdmin)
exports('RegisterServerCallback', ESV.Functions.RegisterServerCallback)
exports('GetSourceByCharId', ESV.Functions.GetSourceByCharId)
exports('LogAdmin', ESV.Functions.LogAdmin)
exports('GetIdentifier', ESV.Functions.GetIdentifier)
exports('SaveCharacter', ESV.Functions.SaveCharacter)
