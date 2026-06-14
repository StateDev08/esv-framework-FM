local playingEmote = false

-- /e [emote_name] oder /emote [emote_name]
RegisterCommand('e', function(src, args)
    if not ESV.CharacterLoaded then return end
    local emoteName = args[1]

    if not emoteName then
        -- Alle Emotes auflisten
        local emoteList = ""
        for _, emote in ipairs(EmoteList) do
            emoteList = emoteList .. emote.name .. ", "
        end
        TriggerEvent('esv:client:notify', 'info', 'Emotes: ' .. emoteList)
        return
    end

    -- Cancel
    if emoteName == "cancel" or emoteName == "c" then
        CancelEmote()
        return
    end

    -- Emote suchen
    for _, emote in ipairs(EmoteList) do
        if emote.name == emoteName then
            PlayEmote(emote)
            return
        end
    end

    TriggerEvent('esv:client:notify', 'error', 'Emote nicht gefunden: ' .. emoteName)
end, false)

RegisterCommand('emote', function(src, args)
    ExecuteCommand('e ' .. table.concat(args, " "))
end, false)

RegisterCommand('emotes', function()
    local emoteList = "Verfuegbare Emotes:\n"
    for _, emote in ipairs(EmoteList) do
        emoteList = emoteList .. "/e " .. emote.name .. " - " .. emote.label .. "\n"
    end
    TriggerEvent('esv:client:notify', 'info', emoteList)
end, false)

function PlayEmote(emote)
    if playingEmote then CancelEmote() Wait(300) end

    local ped = PlayerPedId()
    playingEmote = true

    RequestAnimDict(emote.dict)
    local timeout = 0
    while not HasAnimDictLoaded(emote.dict) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if HasAnimDictLoaded(emote.dict) then
        TaskPlayAnim(ped, emote.dict, emote.anim, 2.0, 2.0, -1, emote.flag, 0, false, false, false)
    else
        TriggerEvent('esv:client:notify', 'error', 'Animation konnte nicht geladen werden')
        playingEmote = false
    end
end

function CancelEmote()
    if not playingEmote then return end
    playingEmote = false
    ClearPedTasks(PlayerPedId())
    TriggerEvent('esv:client:notify', 'info', 'Animation abgebrochen')
end

-- Cancel bei Bewegung
CreateThread(function()
    while true do
        Wait(0)
        if playingEmote then
            if IsControlPressed(0, 32) or IsControlPressed(0, 33) or
               IsControlPressed(0, 34) or IsControlPressed(0, 35) then
                CancelEmote()
            end
        end
    end
end)

-- /handsup shortcut
RegisterCommand('handsup', function()
    for _, emote in ipairs(EmoteList) do
        if emote.name == "handsup" then
            PlayEmote(emote)
            return
        end
    end
end, false)
RegisterKeyMapping('handsup', 'Haende hoch', 'keyboard', 'X')
