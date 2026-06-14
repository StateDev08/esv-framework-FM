RegisterNetEvent('esv:client:notify', function(type, message, duration)
    SendNUIMessage({
        action = 'notify',
        type = type or 'info',
        message = message or '',
        duration = duration or 5000,
    })
end)

exports('Notify', function(type, message, duration)
    SendNUIMessage({
        action = 'notify',
        type = type or 'info',
        message = message or '',
        duration = duration or 5000,
    })
end)
