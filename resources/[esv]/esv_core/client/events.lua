-- Client-seitige Event-Handler

RegisterNetEvent('esv:client:notify', function(type, message, duration)
    SendNUIMessage({
        action = 'notify',
        type = type,
        message = message,
        duration = duration or 5000,
    })
end)

RegisterNetEvent('esv:client:spawnComplete', function()
    TriggerEvent('esv:client:hudVisible', true)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
end)
