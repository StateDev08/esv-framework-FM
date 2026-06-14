local MAX_WEIGHT = 50000 -- 50kg max
local MAX_SLOTS = 40

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("^2[ESV]^0 Inventarsystem geladen")
end)

-- Inventar laden
exports.esv_core:RegisterServerCallback('esv:inventory:getItems', function(src, cb, ownerType, ownerId)
    local owner = ownerId or tostring(src)
    local oType = ownerType or 'player'

    if oType == 'player' then
        local data = exports.esv_core:GetPlayerBySrc(src)
        if data and data.characterId then
            owner = tostring(data.characterId)
        end
    end

    local items = MySQL.query.await(
        'SELECT * FROM inventories WHERE owner = ? AND owner_type = ? ORDER BY slot',
        { owner, oType }
    )

    local result = {}
    for _, item in ipairs(items or {}) do
        local itemDef = ESV.Items[item.item_name]
        table.insert(result, {
            id = item.id,
            name = item.item_name,
            label = itemDef and itemDef.label or item.item_name,
            amount = item.amount,
            weight = itemDef and itemDef.weight or 0,
            slot = item.slot,
            usable = itemDef and itemDef.usable or false,
            description = itemDef and itemDef.description or '',
            metadata = item.metadata and json.decode(item.metadata) or nil,
        })
    end

    cb(result, MAX_WEIGHT, MAX_SLOTS)
end)

-- Item hinzufuegen
function AddItem(src, itemName, amount, metadata, targetType, targetId)
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return false end

    local itemDef = ESV.Items[itemName]
    if not itemDef then return false end

    local owner = targetId or tostring(data.characterId)
    local ownerType = targetType or 'player'

    local currentWeight = GetInventoryWeight(owner, ownerType)
    local addWeight = itemDef.weight * amount
    if currentWeight + addWeight > MAX_WEIGHT then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Inventar zu schwer!')
        return false
    end

    if itemDef.stackable then
        local existing = MySQL.single.await(
            'SELECT id, amount FROM inventories WHERE owner = ? AND owner_type = ? AND item_name = ? LIMIT 1',
            { owner, ownerType, itemName }
        )

        if existing then
            MySQL.update('UPDATE inventories SET amount = amount + ? WHERE id = ?', { amount, existing.id })
        else
            local slot = GetNextFreeSlot(owner, ownerType)
            if not slot then
                TriggerClientEvent('esv:client:notify', src, 'error', 'Inventar voll!')
                return false
            end
            MySQL.insert('INSERT INTO inventories (owner, owner_type, item_name, amount, slot, weight, metadata) VALUES (?, ?, ?, ?, ?, ?, ?)',
                { owner, ownerType, itemName, amount, slot, itemDef.weight, metadata and json.encode(metadata) or nil })
        end
    else
        for i = 1, amount do
            local slot = GetNextFreeSlot(owner, ownerType)
            if not slot then
                TriggerClientEvent('esv:client:notify', src, 'error', 'Inventar voll!')
                return false
            end
            MySQL.insert('INSERT INTO inventories (owner, owner_type, item_name, amount, slot, weight, metadata) VALUES (?, ?, ?, ?, ?, ?, ?)',
                { owner, ownerType, itemName, 1, slot, itemDef.weight, metadata and json.encode(metadata) or nil })
        end
    end

    TriggerClientEvent('esv:client:notify', src, 'success',
        itemDef.label .. ' x' .. amount .. ' erhalten')
    TriggerClientEvent('esv:client:inventoryRefresh', src)
    return true
end

-- Item entfernen
function RemoveItem(src, itemName, amount)
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return false end

    local owner = tostring(data.characterId)
    local items = MySQL.query.await(
        'SELECT id, amount FROM inventories WHERE owner = ? AND owner_type = ? AND item_name = ? ORDER BY slot',
        { owner, 'player', itemName }
    )

    local remaining = amount
    for _, item in ipairs(items or {}) do
        if remaining <= 0 then break end
        if item.amount <= remaining then
            remaining = remaining - item.amount
            MySQL.update('DELETE FROM inventories WHERE id = ?', { item.id })
        else
            MySQL.update('UPDATE inventories SET amount = amount - ? WHERE id = ?', { remaining, item.id })
            remaining = 0
        end
    end

    if remaining > 0 then return false end

    TriggerClientEvent('esv:client:inventoryRefresh', src)
    return true
end

function HasItem(src, itemName, amount)
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return false end

    local result = MySQL.single.await(
        'SELECT SUM(amount) as total FROM inventories WHERE owner = ? AND owner_type = ? AND item_name = ?',
        { tostring(data.characterId), 'player', itemName }
    )

    return result and result.total and result.total >= (amount or 1)
end

function GetItemCount(src, itemName)
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return 0 end

    local result = MySQL.single.await(
        'SELECT SUM(amount) as total FROM inventories WHERE owner = ? AND owner_type = ? AND item_name = ?',
        { tostring(data.characterId), 'player', itemName }
    )

    return result and result.total or 0
end

function GetInventoryWeight(owner, ownerType)
    local result = MySQL.single.await(
        'SELECT SUM(weight * amount) as total FROM inventories WHERE owner = ? AND owner_type = ?',
        { owner, ownerType }
    )
    return result and result.total or 0
end

function GetNextFreeSlot(owner, ownerType)
    local items = MySQL.query.await(
        'SELECT slot FROM inventories WHERE owner = ? AND owner_type = ? ORDER BY slot',
        { owner, ownerType }
    )

    local usedSlots = {}
    for _, item in ipairs(items or {}) do
        usedSlots[item.slot] = true
    end

    for i = 1, MAX_SLOTS do
        if not usedSlots[i] then return i end
    end
    return nil
end

-- Item benutzen
RegisterNetEvent('esv:inventory:useItem', function(itemName, slot)
    local src = source
    if not HasItem(src, itemName, 1) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Item nicht gefunden!')
        return
    end

    local itemDef = ESV.Items[itemName]
    if not itemDef or not itemDef.usable then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Dieses Item kann nicht benutzt werden!')
        return
    end

    TriggerEvent('esv:server:useItem', itemName)
    TriggerClientEvent('esv:client:useItem', src, itemName)

    local consumables = { brot=true, wasser=true, burger=true, cola=true, kaffee=true,
        donut=true, sandwich=true, energydrink=true, bandage=true, schmerzmittel=true,
        joint=true, kokain=true, meth=true }

    if consumables[itemName] then
        RemoveItem(src, itemName, 1)
    end
end)

-- Item droppen
RegisterNetEvent('esv:inventory:dropItem', function(itemName, amount)
    local src = source
    if not HasItem(src, itemName, amount) then return end

    RemoveItem(src, itemName, amount)
    TriggerClientEvent('esv:client:notify', src, 'info', ESV.Items[itemName].label .. ' x' .. amount .. ' weggeworfen')
end)

-- Item geben
RegisterNetEvent('esv:inventory:giveItem', function(targetId, itemName, amount)
    local src = source
    if not HasItem(src, itemName, amount) then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Items!')
        return
    end

    RemoveItem(src, itemName, amount)
    AddItem(targetId, itemName, amount)

    TriggerClientEvent('esv:client:notify', src, 'success', ESV.Items[itemName].label .. ' x' .. amount .. ' gegeben')
    TriggerClientEvent('esv:client:notify', targetId, 'success', ESV.Items[itemName].label .. ' x' .. amount .. ' erhalten')
end)

-- Slot verschieben
RegisterNetEvent('esv:inventory:moveItem', function(fromSlot, toSlot, ownerType, ownerId)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.characterId then return end

    local owner = ownerId or tostring(data.characterId)
    local oType = ownerType or 'player'

    local fromItem = MySQL.single.await(
        'SELECT * FROM inventories WHERE owner = ? AND owner_type = ? AND slot = ?',
        { owner, oType, fromSlot }
    )

    local toItem = MySQL.single.await(
        'SELECT * FROM inventories WHERE owner = ? AND owner_type = ? AND slot = ?',
        { owner, oType, toSlot }
    )

    if not fromItem then return end

    if toItem then
        MySQL.update('UPDATE inventories SET slot = ? WHERE id = ?', { toSlot, fromItem.id })
        MySQL.update('UPDATE inventories SET slot = ? WHERE id = ?', { fromSlot, toItem.id })
    else
        MySQL.update('UPDATE inventories SET slot = ? WHERE id = ?', { toSlot, fromItem.id })
    end

    TriggerClientEvent('esv:client:inventoryRefresh', src)
end)

-- Exports
exports('AddItem', AddItem)
exports('RemoveItem', RemoveItem)
exports('HasItem', HasItem)
exports('GetItemCount', GetItemCount)
