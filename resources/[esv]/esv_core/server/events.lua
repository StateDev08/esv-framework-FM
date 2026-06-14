-- Server-seitige Events fuer andere Resources

RegisterNetEvent('esv:server:updateStatus', function(hunger, thirst, stress)
    local src = source
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then return end

    data.character.hunger = hunger
    data.character.thirst = thirst
    data.character.stress = stress
end)

RegisterNetEvent('esv:server:updateHealth', function(health, armor)
    local src = source
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then return end

    data.character.health = health
    data.character.armor = armor
end)

RegisterNetEvent('esv:server:setDead', function(isDead)
    local src = source
    local data = ESV.PlayersBySource[src]
    if not data or not data.character then return end

    data.character.is_dead = isDead
end)

RegisterNetEvent('esv:server:saveSkin', function(skinData)
    local src = source
    local data = ESV.PlayersBySource[src]
    if not data or not data.characterId then return end

    MySQL.update('UPDATE characters SET skin = ? WHERE id = ?', { json.encode(skinData), data.characterId })
end)

RegisterNetEvent('esv:server:savePosition', function()
    local src = source
    ESV.Functions.SaveCharacter(src)
end)
