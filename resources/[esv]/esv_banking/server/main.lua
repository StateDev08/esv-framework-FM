AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("^2[ESV]^0 Banksystem geladen")
end)

exports.esv_core:RegisterServerCallback('esv:banking:getData', function(src, cb)
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then cb({}) return end

    local account = MySQL.single.await(
        'SELECT * FROM bank_accounts WHERE character_id = ? AND account_type = ?',
        { data.characterId, 'personal' }
    )

    local transactions = MySQL.query.await(
        'SELECT * FROM bank_transactions WHERE account_id = ? ORDER BY created_at DESC LIMIT 20',
        { account and account.id or 0 }
    )

    cb({
        cash = data.character.cash,
        bank = data.character.bank,
        accountNumber = account and account.account_number or 'N/A',
        transactions = transactions or {},
    })
end)

RegisterNetEvent('esv:banking:deposit', function(amount)
    local src = source
    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    if data.character.cash < amount then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Bargeld!')
        return
    end

    exports.esv_core:RemoveMoney(src, 'cash', amount)
    exports.esv_core:AddMoney(src, 'bank', amount)

    local account = MySQL.single.await(
        'SELECT id, balance FROM bank_accounts WHERE character_id = ? AND account_type = ?',
        { data.characterId, 'personal' }
    )

    if account then
        local newBalance = account.balance + amount
        MySQL.update('UPDATE bank_accounts SET balance = ? WHERE id = ?', { newBalance, account.id })
        MySQL.insert('INSERT INTO bank_transactions (account_id, type, amount, description, balance_after) VALUES (?, ?, ?, ?, ?)',
            { account.id, 'deposit', amount, 'Einzahlung', newBalance })
    end

    TriggerClientEvent('esv:client:notify', src, 'success', '$' .. amount .. ' eingezahlt')
    TriggerClientEvent('esv:client:bankRefresh', src)
end)

RegisterNetEvent('esv:banking:withdraw', function(amount)
    local src = source
    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    if data.character.bank < amount then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Guthaben!')
        return
    end

    exports.esv_core:RemoveMoney(src, 'bank', amount)
    exports.esv_core:AddMoney(src, 'cash', amount)

    local account = MySQL.single.await(
        'SELECT id, balance FROM bank_accounts WHERE character_id = ? AND account_type = ?',
        { data.characterId, 'personal' }
    )

    if account then
        local newBalance = account.balance - amount
        MySQL.update('UPDATE bank_accounts SET balance = ? WHERE id = ?', { newBalance, account.id })
        MySQL.insert('INSERT INTO bank_transactions (account_id, type, amount, description, balance_after) VALUES (?, ?, ?, ?, ?)',
            { account.id, 'withdraw', amount, 'Abhebung', newBalance })
    end

    TriggerClientEvent('esv:client:notify', src, 'success', '$' .. amount .. ' abgehoben')
    TriggerClientEvent('esv:client:bankRefresh', src)
end)

RegisterNetEvent('esv:banking:transfer', function(targetAccount, amount)
    local src = source
    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    if data.character.bank < amount then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Guthaben!')
        return
    end

    local target = MySQL.single.await(
        'SELECT ba.id, ba.balance, ba.character_id, c.firstname, c.lastname FROM bank_accounts ba JOIN characters c ON c.id = ba.character_id WHERE ba.account_number = ?',
        { targetAccount }
    )

    if not target then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Kontonummer nicht gefunden!')
        return
    end

    -- Sender
    exports.esv_core:RemoveMoney(src, 'bank', amount)
    local senderAccount = MySQL.single.await(
        'SELECT id, balance FROM bank_accounts WHERE character_id = ? AND account_type = ?',
        { data.characterId, 'personal' }
    )
    if senderAccount then
        local newBalance = senderAccount.balance - amount
        MySQL.update('UPDATE bank_accounts SET balance = ? WHERE id = ?', { newBalance, senderAccount.id })
        MySQL.insert('INSERT INTO bank_transactions (account_id, type, amount, description, balance_after) VALUES (?, ?, ?, ?, ?)',
            { senderAccount.id, 'transfer_out', amount, 'Ueberweisung an ' .. target.firstname .. ' ' .. target.lastname, newBalance })
    end

    -- Empfaenger
    local targetSrc = exports.esv_core:GetSourceByCharId(target.character_id)
    if targetSrc then
        exports.esv_core:AddMoney(targetSrc, 'bank', amount)
    end

    local newTargetBalance = target.balance + amount
    MySQL.update('UPDATE bank_accounts SET balance = ? WHERE id = ?', { newTargetBalance, target.id })
    MySQL.insert('INSERT INTO bank_transactions (account_id, type, amount, description, balance_after) VALUES (?, ?, ?, ?, ?)',
        { target.id, 'transfer_in', amount, 'Ueberweisung von ' .. data.character.firstname .. ' ' .. data.character.lastname, newTargetBalance })

    -- Empfaenger benachrichtigen
    MySQL.update('UPDATE characters SET bank = bank + ? WHERE id = ?', { amount, target.character_id })

    if targetSrc then
        TriggerClientEvent('esv:client:notify', targetSrc, 'success', 'Ueberweisung erhalten: $' .. amount)
        TriggerClientEvent('esv:client:bankRefresh', targetSrc)
    end

    TriggerClientEvent('esv:client:notify', src, 'success', '$' .. amount .. ' an ' .. target.firstname .. ' ' .. target.lastname .. ' ueberwiesen')
    TriggerClientEvent('esv:client:bankRefresh', src)
end)
