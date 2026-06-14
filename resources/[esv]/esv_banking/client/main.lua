local isOpen = false
local nearATM = false

-- ATM-Erkennung
CreateThread(function()
    while true do
        Wait(500)
        if not ESV.CharacterLoaded then goto continue end

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        nearATM = false

        for _, model in ipairs(ESV.Config.ATMModels) do
            local atm = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.5, model, false, false, false)
            if atm ~= 0 then
                nearATM = true
                break
            end
        end

        if nearATM and not isOpen then
            ESV.Functions.ShowHelpText("Druecke ~INPUT_CONTEXT~ um den Geldautomaten zu benutzen")
        end

        ::continue::
    end
end)

-- ATM benutzen
CreateThread(function()
    while true do
        Wait(0)
        if nearATM and not isOpen and IsControlJustReleased(0, 38) then -- E
            OpenBank('atm')
        end
    end
end)

-- Bank-Blips
CreateThread(function()
    local bankLocations = {
        { pos = vector3(149.7, -1040.4, 29.4), label = "Fleeca Bank" },
        { pos = vector3(314.2, -278.8, 54.2), label = "Fleeca Bank" },
        { pos = vector3(-350.9, -49.6, 49.0), label = "Fleeca Bank" },
        { pos = vector3(-1212.9, -330.5, 37.8), label = "Fleeca Bank" },
        { pos = vector3(-2961.6, 482.6, 15.7), label = "Fleeca Bank" },
        { pos = vector3(1175.1, 2706.9, 38.1), label = "Fleeca Bank" },
        { pos = vector3(247.0, 223.8, 106.3), label = "Pacific Standard Bank" },
    }

    for _, bank in ipairs(bankLocations) do
        local blip = AddBlipForCoord(bank.pos.x, bank.pos.y, bank.pos.z)
        SetBlipSprite(blip, 108)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(bank.label)
        EndTextCommandSetBlipName(blip)
    end
end)

function OpenBank(type)
    if isOpen then return end
    isOpen = true

    ESV.Functions.TriggerCallback('esv:banking:getData', function(data)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openBank',
            bankType = type,
            cash = data.cash,
            bank = data.bank,
            accountNumber = data.accountNumber,
            transactions = data.transactions,
        })
    end)
end

function CloseBank()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeBank' })
end

RegisterNUICallback('closeBank', function(data, cb)
    CloseBank()
    cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('esv:banking:deposit', data.amount)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('esv:banking:withdraw', data.amount)
    cb('ok')
end)

RegisterNUICallback('transfer', function(data, cb)
    TriggerServerEvent('esv:banking:transfer', data.targetAccount, data.amount)
    cb('ok')
end)

RegisterNetEvent('esv:client:bankRefresh', function()
    if not isOpen then return end
    ESV.Functions.TriggerCallback('esv:banking:getData', function(data)
        SendNUIMessage({
            action = 'refreshBank',
            cash = data.cash,
            bank = data.bank,
            transactions = data.transactions,
        })
    end)
end)
