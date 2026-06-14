local currentFrequency = 0
local blips = {}

RegisterNetEvent('esv:dispatch:newCall', function(callData)
    TriggerEvent('esv:client:notify', callData.type == 'police' and 'police' or 'ems',
        '[' .. string.upper(callData.type) .. '] ' .. callData.message)

    -- Blip fuer den Einsatzort
    if callData.location then
        local blip = AddBlipForCoord(callData.location.x, callData.location.y, callData.location.z)
        SetBlipSprite(blip, callData.type == 'police' and 161 or 153)
        SetBlipColour(blip, callData.type == 'police' and 38 or 1)
        SetBlipScale(blip, 1.2)
        SetBlipFlashes(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(callData.type == 'police' and "Polizei-Einsatz" or "EMS-Einsatz")
        EndTextCommandSetBlipName(blip)

        table.insert(blips, { blip = blip, time = GetGameTimer() })

        -- Blip nach 2 Minuten entfernen
        SetTimeout(120000, function()
            RemoveBlip(blip)
        end)
    end
end)

-- /funk [frequenz]
RegisterCommand('funk', function(src, args)
    if not ESV.CharacterLoaded then return end
    local freq = tonumber(args[1]) or 0
    if freq == 0 then
        currentFrequency = 0
        TriggerEvent('esv:client:notify', 'info', 'Funk verlassen')
    else
        currentFrequency = freq
        TriggerServerEvent('esv:dispatch:setFrequency', freq)
        TriggerEvent('esv:client:notify', 'success', 'Funk Frequenz: ' .. freq)
    end
end, false)

-- /funkmsg [nachricht]
RegisterCommand('funkmsg', function(src, args)
    if currentFrequency == 0 then
        TriggerEvent('esv:client:notify', 'error', 'Du bist in keiner Funk-Frequenz!')
        return
    end
    local msg = table.concat(args, " ")
    TriggerServerEvent('esv:dispatch:radioMessage', currentFrequency, msg)
end, false)

RegisterNetEvent('esv:dispatch:radioReceive', function(senderName, message, freq)
    TriggerEvent('esv:client:notify', 'info', '[Funk ' .. freq .. '] ' .. senderName .. ': ' .. message)
end)

-- 911 Befehl
RegisterCommand('911', function(src, args)
    if not ESV.CharacterLoaded then return end
    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerEvent('esv:client:notify', 'error', '/911 [nachricht]')
        return
    end
    TriggerServerEvent('esv:dispatch:call911', 'police', msg)
    TriggerEvent('esv:client:notify', 'success', 'Notruf abgesetzt!')
end, false)

RegisterCommand('112', function(src, args)
    if not ESV.CharacterLoaded then return end
    local msg = table.concat(args, " ")
    if msg == "" then return end
    TriggerServerEvent('esv:dispatch:call911', 'ems', msg)
    TriggerEvent('esv:client:notify', 'success', 'Rettungsdienst-Notruf abgesetzt!')
end, false)
