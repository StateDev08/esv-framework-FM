local storeCooldowns = {}

AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Kriminelles System geladen (Drogen, Ueberfaelle, Gefaengnis)")
end)

RegisterNetEvent('esv:criminal:harvest', function(drugType, harvestItem, needItem)
    local src = source
    if needItem and not exports.esv_inventory:HasItem(src, needItem, 1) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Du brauchst: ' .. (ESV.Items[needItem] and ESV.Items[needItem].label or needItem))
        return
    end

    if needItem then
        exports.esv_inventory:RemoveItem(src, needItem, 1)
    end

    local amount = math.random(1, 3)
    exports.esv_inventory:AddItem(src, harvestItem, amount)
end)

RegisterNetEvent('esv:criminal:process', function(input, output, requiredAmount)
    local src = source
    if not exports.esv_inventory:HasItem(src, input, requiredAmount) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Material!')
        return
    end

    exports.esv_inventory:RemoveItem(src, input, requiredAmount)
    exports.esv_inventory:AddItem(src, output, 1)
end)

RegisterNetEvent('esv:criminal:sellDrugs', function()
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return end

    local drugPrices = {
        joint = { min = 50, max = 100 },
        kokain = { min = 200, max = 500 },
        meth = { min = 300, max = 600 },
        cannabis_trocken = { min = 30, max = 80 },
    }

    local totalEarnings = 0

    for drugName, priceRange in pairs(drugPrices) do
        local count = exports.esv_inventory:GetItemCount(src, drugName)
        if count > 0 then
            exports.esv_inventory:RemoveItem(src, drugName, count)
            local pricePerUnit = math.random(priceRange.min, priceRange.max)
            totalEarnings = totalEarnings + (pricePerUnit * count)
        end
    end

    if totalEarnings > 0 then
        exports.esv_core:AddMoney(src, 'cash', totalEarnings)
        TriggerClientEvent('esv:client:notify', src, 'success', 'Drogen verkauft fuer $' .. totalEarnings)
    else
        TriggerClientEvent('esv:client:notify', src, 'error', 'Du hast keine Drogen zum Verkaufen!')
    end
end)

RegisterNetEvent('esv:criminal:robStore', function(storeLabel, reward)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data then return end

    -- Cooldown pruefen
    if storeCooldowns[storeLabel] and os.time() < storeCooldowns[storeLabel] then
        local remaining = storeCooldowns[storeLabel] - os.time()
        TriggerClientEvent('esv:client:notify', src, 'error', 'Laden ist noch gesichert! Warte ' .. math.ceil(remaining / 60) .. ' Minuten.')
        return
    end

    -- Mindest-Polizisten pruefen
    local policeOnline = exports.esv_core:GetPlayersByJob('police')
    if #policeOnline < ESV.Config.MinPoliceForRobbery then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Polizisten online! (Min: ' .. ESV.Config.MinPoliceForRobbery .. ')')
        return
    end

    -- Ueberfall starten
    storeCooldowns[storeLabel] = os.time() + 600

    -- Polizei benachrichtigen
    for _, police in ipairs(policeOnline) do
        TriggerClientEvent('esv:client:notify', police.source, 'police', 'Ladenueberfall gemeldet: ' .. storeLabel)
    end

    -- Beute berechnen
    Wait(15000)
    local loot = math.random(reward.min, reward.max)
    exports.esv_core:AddMoney(src, 'cash', loot)
    TriggerClientEvent('esv:client:notify', src, 'success', 'Ueberfall erfolgreich! Beute: $' .. loot)
end)

RegisterNetEvent('esv:criminal:released', function()
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if data and data.character then
        data.character.jail_time = 0
        MySQL.update('UPDATE characters SET jail_time = 0 WHERE id = ?', { data.characterId })
    end
end)
