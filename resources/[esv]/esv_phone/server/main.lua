AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Telefonsystem geladen")
end)

exports.esv_core:RegisterServerCallback('esv:phone:getData', function(src, cb)
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then cb({}) return end

    local contacts = MySQL.query.await('SELECT * FROM phone_contacts WHERE character_id = ? ORDER BY name', { data.characterId }) or {}
    local messages = MySQL.query.await(
        'SELECT * FROM phone_messages WHERE sender_number = ? OR receiver_number = ? ORDER BY created_at DESC LIMIT 50',
        { data.character.phone_number, data.character.phone_number }
    ) or {}
    local calls = MySQL.query.await(
        'SELECT * FROM phone_calls WHERE caller_number = ? OR receiver_number = ? ORDER BY created_at DESC LIMIT 20',
        { data.character.phone_number, data.character.phone_number }
    ) or {}

    cb({
        phoneNumber = data.character.phone_number,
        contacts = contacts,
        messages = messages,
        calls = calls,
    })
end)

RegisterNetEvent('esv:phone:sendMessage', function(targetNumber, message)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    MySQL.insert('INSERT INTO phone_messages (sender_number, receiver_number, message) VALUES (?, ?, ?)',
        { data.character.phone_number, targetNumber, message })

    local targetChar = MySQL.single.await('SELECT id FROM characters WHERE phone_number = ?', { targetNumber })
    if targetChar then
        local targetSrc = exports.esv_core:GetSourceByCharId(targetChar.id)
        if targetSrc then
            TriggerClientEvent('esv:client:newMessage', targetSrc, data.character.phone_number, message)
        end
    end

    TriggerClientEvent('esv:client:notify', src, 'success', 'SMS gesendet')
    TriggerClientEvent('esv:client:phoneRefresh', src)
end)

RegisterNetEvent('esv:phone:call', function(targetNumber)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    MySQL.insert('INSERT INTO phone_calls (caller_number, receiver_number) VALUES (?, ?)',
        { data.character.phone_number, targetNumber })

    local targetChar = MySQL.single.await('SELECT id FROM characters WHERE phone_number = ?', { targetNumber })
    if targetChar then
        local targetSrc = exports.esv_core:GetSourceByCharId(targetChar.id)
        if targetSrc then
            TriggerClientEvent('esv:client:incomingCall', targetSrc, data.character.phone_number)
        end
    end

    TriggerClientEvent('esv:client:notify', src, 'info', 'Anruf gestartet...')
end)

RegisterNetEvent('esv:phone:addContact', function(name, number)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return end

    MySQL.insert('INSERT INTO phone_contacts (character_id, name, number) VALUES (?, ?, ?)',
        { data.characterId, name, number })
    TriggerClientEvent('esv:client:notify', src, 'success', 'Kontakt gespeichert')
    TriggerClientEvent('esv:client:phoneRefresh', src)
end)

RegisterNetEvent('esv:phone:deleteContact', function(contactId)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data then return end
    MySQL.update('DELETE FROM phone_contacts WHERE id = ? AND character_id = ?', { contactId, data.characterId })
    TriggerClientEvent('esv:client:phoneRefresh', src)
end)
