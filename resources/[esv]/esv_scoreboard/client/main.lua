local isOpen = false

CreateThread(function()
    while true do
        Wait(0)
        if IsControlPressed(0, 20) and not isOpen then -- Z key
            isOpen = true
            ESV.Functions.TriggerCallback('esv:scoreboard:getPlayers', function(players)
                SetNuiFocus(false, false)
                SendNUIMessage({
                    action = 'openScoreboard',
                    serverName = ESV.Config.ServerName,
                    players = players,
                    maxPlayers = 64,
                })
            end)
        end
        if not IsControlPressed(0, 20) and isOpen then
            isOpen = false
            SendNUIMessage({ action = 'closeScoreboard' })
        end
    end
end)
