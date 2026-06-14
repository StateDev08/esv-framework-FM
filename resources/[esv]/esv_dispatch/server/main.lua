local radioFrequencies = {} -- [src] = frequency

AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Dispatch-System geladen")
end)

RegisterNetEvent('esv:dispatch:call911', function(type, message)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local street = "Unbekannt"

    local callData = {
        type = type,
        message = message,
        caller = data.character.firstname .. ' ' .. data.character.lastname,
        location = { x = coords.x, y = coords.y, z = coords.z },
    }

    MySQL.insert('INSERT INTO dispatch_calls (caller_id, type, message, location) VALUES (?, ?, ?, ?)',
        { data.characterId, type, message, json.encode(callData.location) })

    local targetJob = type == 'ems' and 'ems' or 'police'
    local jobPlayers = exports.esv_core:GetPlayersByJob(targetJob)

    for _, player in ipairs(jobPlayers) do
        TriggerClientEvent('esv:dispatch:newCall', player.source, callData)
    end

    TriggerClientEvent('esv:client:notify', src, 'success', 'Notruf wurde an ' .. (type == 'ems' and 'EMS' or 'Polizei') .. ' weitergeleitet')
end)

RegisterNetEvent('esv:dispatch:setFrequency', function(freq)
    radioFrequencies[source] = freq
end)

RegisterNetEvent('esv:dispatch:radioMessage', function(freq, message)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    local senderName = data.character.firstname .. ' ' .. data.character.lastname

    for playerSrc, playerFreq in pairs(radioFrequencies) do
        if playerFreq == freq and playerSrc ~= src then
            TriggerClientEvent('esv:dispatch:radioReceive', playerSrc, senderName, message, freq)
        end
    end
end)

AddEventHandler('playerDropped', function()
    radioFrequencies[source] = nil
end)
