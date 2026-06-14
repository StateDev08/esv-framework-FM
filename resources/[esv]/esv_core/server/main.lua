ESV = ESV or {}
ESV.Players = {}
ESV.PlayersBySource = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("^2[ESV Framework]^0 Core gestartet - Version 1.0.0")
end)

-- Spieler verbindet sich
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)
    deferrals.update("ESV Framework: Verbindung wird hergestellt...")

    local license = ESV.Functions.GetIdentifier(src, "license")
    if not license then
        deferrals.done("Keine gueltige Lizenz gefunden. Bitte starte FiveM neu.")
        return
    end

    deferrals.update("ESV Framework: Daten werden geladen...")

    local steam = ESV.Functions.GetIdentifier(src, "steam")
    local discord = ESV.Functions.GetIdentifier(src, "discord")
    local ip = GetPlayerEndpoint(src)

    local result = MySQL.single.await('SELECT * FROM players WHERE license = ?', { license })

    if result then
        if result.banned == 1 then
            if result.ban_expire and os.time() < result.ban_expire then
                deferrals.done("Du bist gebannt!\nGrund: " .. (result.ban_reason or "Kein Grund angegeben") ..
                    "\nBis: " .. os.date("%d.%m.%Y %H:%M", result.ban_expire))
                return
            else
                MySQL.update.await('UPDATE players SET banned = 0, ban_reason = NULL, ban_expire = NULL WHERE id = ?', { result.id })
            end
        end

        MySQL.update.await('UPDATE players SET steam = ?, discord = ?, ip = ?, last_login = NOW() WHERE id = ?',
            { steam, discord, ip, result.id })
    else
        MySQL.insert.await('INSERT INTO players (license, steam, discord, ip) VALUES (?, ?, ?, ?)',
            { license, steam, discord, ip })
    end

    deferrals.done()
end)

-- Spieler hat das Spiel vollstaendig geladen
RegisterNetEvent('esv:server:playerLoaded', function()
    local src = source
    local license = ESV.Functions.GetIdentifier(src, "license")
    if not license then return end

    local player = MySQL.single.await('SELECT * FROM players WHERE license = ?', { license })
    if not player then return end

    ESV.PlayersBySource[src] = {
        id = player.id,
        license = license,
        admin_level = player.admin_level,
        characterId = nil,
        character = nil,
    }

    TriggerClientEvent('esv:client:playerReady', src, player.id, player.admin_level)
    print("^2[ESV]^0 Spieler geladen: " .. GetPlayerName(src) .. " (ID: " .. player.id .. ")")
end)

-- Charakter ausgewaehlt
RegisterNetEvent('esv:server:selectCharacter', function(slot)
    local src = source
    local playerData = ESV.PlayersBySource[src]
    if not playerData then return end

    local character = MySQL.single.await(
        'SELECT * FROM characters WHERE player_id = ? AND slot = ?',
        { playerData.id, slot }
    )

    if not character then return end

    playerData.characterId = character.id
    playerData.character = {
        id = character.id,
        firstname = character.firstname,
        lastname = character.lastname,
        dateofbirth = character.dateofbirth,
        gender = character.gender,
        nationality = character.nationality,
        phone_number = character.phone_number,
        cash = character.cash,
        bank = character.bank,
        job = character.job,
        job_grade = character.job_grade,
        health = character.health,
        armor = character.armor,
        hunger = character.hunger,
        thirst = character.thirst,
        stress = character.stress,
        is_dead = character.is_dead == 1,
        jail_time = character.jail_time,
        position = character.position and json.decode(character.position) or nil,
        skin = character.skin and json.decode(character.skin) or nil,
    }

    ESV.Players[character.id] = playerData

    local jobData = ESV.Jobs[character.job]
    local jobLabel = jobData and jobData.label or "Arbeitslos"
    local gradeLabel = jobData and jobData.grades[character.job_grade] and jobData.grades[character.job_grade].label or "Keine"

    TriggerClientEvent('esv:client:characterLoaded', src, playerData.character, {
        job = character.job,
        jobLabel = jobLabel,
        grade = character.job_grade,
        gradeLabel = gradeLabel,
    })

    MySQL.update('UPDATE characters SET last_played = NOW() WHERE id = ?', { character.id })

    print("^2[ESV]^0 Charakter geladen: " .. character.firstname .. " " .. character.lastname .. " (CID: " .. character.id .. ")")
end)

-- Charakter erstellen
RegisterNetEvent('esv:server:createCharacter', function(data)
    local src = source
    local playerData = ESV.PlayersBySource[src]
    if not playerData then return end

    local slot = data.slot or 1
    local existing = MySQL.single.await(
        'SELECT id FROM characters WHERE player_id = ? AND slot = ?',
        { playerData.id, slot }
    )
    if existing then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Dieser Slot ist bereits belegt!')
        return
    end

    local phoneNumber = ESV.Functions.GeneratePhoneNumber()
    local charId = MySQL.insert.await(
        'INSERT INTO characters (player_id, slot, firstname, lastname, dateofbirth, gender, nationality, phone_number, cash, bank, job, job_grade) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            playerData.id, slot,
            data.firstname, data.lastname,
            data.dateofbirth, data.gender,
            data.nationality or "Deutschland",
            phoneNumber,
            ESV.Config.StartCash, ESV.Config.StartBank,
            "arbeitslos", 0
        }
    )

    local accountNumber = ESV.Functions.GenerateAccountNumber()
    MySQL.insert.await(
        'INSERT INTO bank_accounts (character_id, account_number, balance, account_type) VALUES (?, ?, ?, ?)',
        { charId, accountNumber, ESV.Config.StartBank, 'personal' }
    )

    TriggerClientEvent('esv:client:characterCreated', src, charId, slot)
    print("^2[ESV]^0 Neuer Charakter erstellt: " .. data.firstname .. " " .. data.lastname .. " (CID: " .. charId .. ")")
end)

-- Charakter loeschen
RegisterNetEvent('esv:server:deleteCharacter', function(slot)
    local src = source
    local playerData = ESV.PlayersBySource[src]
    if not playerData then return end

    MySQL.update.await('DELETE FROM characters WHERE player_id = ? AND slot = ?', { playerData.id, slot })
    TriggerClientEvent('esv:client:characterDeleted', src, slot)
end)

-- Spieler disconnected
AddEventHandler('playerDropped', function(reason)
    local src = source
    local playerData = ESV.PlayersBySource[src]
    if not playerData then return end

    if playerData.character then
        ESV.Functions.SaveCharacter(src)
        if playerData.characterId then
            ESV.Players[playerData.characterId] = nil
        end
    end

    ESV.PlayersBySource[src] = nil
    print("^3[ESV]^0 Spieler getrennt: " .. GetPlayerName(src) .. " (" .. reason .. ")")
end)

-- Periodisches Speichern aller Spieler
CreateThread(function()
    while true do
        Wait(5 * 60 * 1000) -- alle 5 Minuten
        for src, data in pairs(ESV.PlayersBySource) do
            if data.character then
                ESV.Functions.SaveCharacter(src)
            end
        end
    end
end)

-- Gehaltsauszahlung
CreateThread(function()
    while true do
        Wait(ESV.Config.PaycheckInterval)
        for src, data in pairs(ESV.PlayersBySource) do
            if data.character then
                local job = ESV.Jobs[data.character.job]
                if job then
                    local grade = job.grades[data.character.job_grade]
                    if grade and grade.salary > 0 then
                        data.character.bank = data.character.bank + grade.salary
                        MySQL.update('UPDATE characters SET bank = ? WHERE id = ?', { data.character.bank, data.characterId })

                        local account = MySQL.single.await('SELECT id, balance FROM bank_accounts WHERE character_id = ? AND account_type = ?', { data.characterId, 'personal' })
                        if account then
                            local newBalance = account.balance + grade.salary
                            MySQL.update('UPDATE bank_accounts SET balance = ? WHERE id = ?', { newBalance, account.id })
                            MySQL.insert('INSERT INTO bank_transactions (account_id, type, amount, description, balance_after) VALUES (?, ?, ?, ?, ?)',
                                { account.id, 'salary', grade.salary, 'Gehalt: ' .. job.label .. ' - ' .. grade.label, newBalance })
                        end

                        TriggerClientEvent('esv:client:notify', src, 'success',
                            'Gehalt erhalten: ' .. ESV.Functions.FormatMoney(grade.salary))
                        TriggerClientEvent('esv:client:updateMoney', src, 'bank', data.character.bank)
                    end
                end
            end
        end
    end
end)
