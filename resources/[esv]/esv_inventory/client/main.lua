local isOpen = false

-- Inventar oeffnen / schliessen
RegisterCommand('inventory', function()
    if not ESV.CharacterLoaded then return end
    ToggleInventory()
end, false)

RegisterKeyMapping('inventory', 'Inventar oeffnen', 'keyboard', 'F2')

function ToggleInventory()
    if isOpen then
        CloseInventory()
    else
        OpenInventory()
    end
end

function OpenInventory()
    if isOpen then return end
    isOpen = true

    ESV.Functions.TriggerCallback('esv:inventory:getItems', function(items, maxWeight, maxSlots)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openInventory',
            items = items,
            maxWeight = maxWeight,
            maxSlots = maxSlots,
            playerName = ESV.PlayerData.character.firstname .. ' ' .. ESV.PlayerData.character.lastname,
        })
    end, 'player')
end

function CloseInventory()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeInventory' })
end

RegisterNUICallback('closeInventory', function(data, cb)
    CloseInventory()
    cb('ok')
end)

RegisterNUICallback('useItem', function(data, cb)
    TriggerServerEvent('esv:inventory:useItem', data.name, data.slot)
    cb('ok')
end)

RegisterNUICallback('dropItem', function(data, cb)
    TriggerServerEvent('esv:inventory:dropItem', data.name, data.amount or 1)
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    local closest = ESV.Functions.GetClosestPlayer(3.0)
    if closest == -1 then
        TriggerEvent('esv:client:notify', 'error', 'Kein Spieler in der Naehe!')
    else
        TriggerServerEvent('esv:inventory:giveItem', closest, data.name, data.amount or 1)
    end
    cb('ok')
end)

RegisterNUICallback('moveItem', function(data, cb)
    TriggerServerEvent('esv:inventory:moveItem', data.fromSlot, data.toSlot)
    cb('ok')
end)

RegisterNetEvent('esv:client:inventoryRefresh', function()
    if not isOpen then return end
    ESV.Functions.TriggerCallback('esv:inventory:getItems', function(items, maxWeight, maxSlots)
        SendNUIMessage({
            action = 'refreshInventory',
            items = items,
            maxWeight = maxWeight,
            maxSlots = maxSlots,
        })
    end, 'player')
end)

RegisterNetEvent('esv:client:useItem', function(itemName)
    -- Animationen fuer bestimmte Items
    local eatItems = { brot=true, burger=true, sandwich=true, donut=true }
    local drinkItems = { wasser=true, cola=true, kaffee=true, energydrink=true }

    if eatItems[itemName] then
        ESV.Functions.PlayAnim('mp_player_inteat@burger', 'mp_player_int_eat_burger', 3000, 49)
    elseif drinkItems[itemName] then
        ESV.Functions.PlayAnim('mp_player_intdrink', 'intro_bottle', 3000, 49)
    elseif itemName == 'bandage' or itemName == 'verbandskasten' then
        ESV.Functions.PlayAnim('anim@heists@narcotics@funding@gang_idle', 'gang_chatting_01', 4000, 49)
    end
end)
