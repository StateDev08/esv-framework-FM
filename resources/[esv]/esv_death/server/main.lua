AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Tod-System geladen")
end)

RegisterNetEvent('esv:server:respawn', function()
    local src = source
    exports.esv_core:RemoveMoney(src, 'bank', ESV.Config.RespawnCost)
    local data = exports.esv_core:GetPlayerBySrc(src)
    if data and data.character then
        data.character.is_dead = false
        data.character.health = 200
    end
end)

RegisterNetEvent('esv:server:revivePlayer', function(targetId)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    if data.character.job ~= 'ems' then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nur EMS kann wiederbelebeen!')
        return
    end

    if not exports.esv_inventory:HasItem(src, 'defibrillator', 1) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Du brauchst einen Defibrillator!')
        return
    end

    TriggerClientEvent('esv:client:revive', targetId)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Spieler wiederbelebt!')
end)
