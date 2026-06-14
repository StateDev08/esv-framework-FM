AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
    print("^2[ESV]^0 Shop-System geladen")
end)

RegisterNetEvent('esv:shops:purchase', function(itemName, price)
    local src = source
    local data = exports.esv_core:GetPlayerBySrc(src)
    if not data or not data.character then return end

    if data.character.cash < price then
        TriggerClientEvent('esv:client:notify', src, 'error', 'Nicht genuegend Bargeld!')
        return
    end

    local success = exports.esv_inventory:AddItem(src, itemName, 1)
    if success then
        exports.esv_core:RemoveMoney(src, 'cash', price)
        local def = ESV.Items[itemName]
        TriggerClientEvent('esv:client:notify', src, 'success', (def and def.label or itemName) .. ' gekauft fuer $' .. price)
    end
end)
