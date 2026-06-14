AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Scoreboard geladen")
end)

exports.esv_core:RegisterServerCallback('esv:scoreboard:getPlayers', function(src, cb)
    local players = {}
    local isAdmin = exports.esv_core:IsAdmin(src, 1)

    for _, playerId in ipairs(GetPlayers()) do
        local data = exports.esv_core:GetPlayerBySrc(tonumber(playerId))
        if data and data.character then
            table.insert(players, {
                id = tonumber(playerId),
                name = data.character.firstname .. ' ' .. data.character.lastname,
                job = ESV.Jobs[data.character.job] and ESV.Jobs[data.character.job].label or data.character.job,
                ping = GetPlayerPing(playerId),
            })
        end
    end

    cb(players)
end)
