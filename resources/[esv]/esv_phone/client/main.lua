local isOpen = false

RegisterCommand('phone', function()
    if not ESV.CharacterLoaded then return end
    if isOpen then ClosePhone() else OpenPhone() end
end, false)
RegisterKeyMapping('phone', 'Telefon oeffnen', 'keyboard', 'F1')

function OpenPhone()
    if isOpen then return end
    isOpen = true
    ESV.Functions.TriggerCallback('esv:phone:getData', function(data)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openPhone',
            phoneNumber = data.phoneNumber,
            contacts = data.contacts,
            messages = data.messages,
            calls = data.calls,
        })
    end)
end

function ClosePhone()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closePhone' })
end

RegisterNUICallback('closePhone', function(d, cb) ClosePhone() cb('ok') end)

RegisterNUICallback('sendMessage', function(data, cb)
    TriggerServerEvent('esv:phone:sendMessage', data.number, data.message)
    cb('ok')
end)

RegisterNUICallback('makeCall', function(data, cb)
    TriggerServerEvent('esv:phone:call', data.number)
    cb('ok')
end)

RegisterNUICallback('addContact', function(data, cb)
    TriggerServerEvent('esv:phone:addContact', data.name, data.number)
    cb('ok')
end)

RegisterNUICallback('deleteContact', function(data, cb)
    TriggerServerEvent('esv:phone:deleteContact', data.id)
    cb('ok')
end)

RegisterNUICallback('call911', function(data, cb)
    TriggerServerEvent('esv:dispatch:call911', data.type, data.message)
    TriggerEvent('esv:client:notify', 'success', 'Notruf abgesetzt!')
    cb('ok')
end)

RegisterNetEvent('esv:client:phoneRefresh', function()
    if not isOpen then return end
    ESV.Functions.TriggerCallback('esv:phone:getData', function(data)
        SendNUIMessage({
            action = 'refreshPhone',
            contacts = data.contacts,
            messages = data.messages,
            calls = data.calls,
        })
    end)
end)

RegisterNetEvent('esv:client:incomingCall', function(callerNumber)
    TriggerEvent('esv:client:notify', 'info', 'Eingehender Anruf von: ' .. callerNumber)
end)

RegisterNetEvent('esv:client:newMessage', function(senderNumber, message)
    TriggerEvent('esv:client:notify', 'info', 'Neue SMS von: ' .. senderNumber)
    if isOpen then
        ESV.Functions.TriggerCallback('esv:phone:getData', function(data)
            SendNUIMessage({
                action = 'refreshPhone',
                contacts = data.contacts,
                messages = data.messages,
                calls = data.calls,
            })
        end)
    end
end)
