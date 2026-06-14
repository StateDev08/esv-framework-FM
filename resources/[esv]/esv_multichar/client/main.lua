local isOpen = false
local charCam = nil

RegisterNetEvent('esv:client:playerReady', function()
    Wait(500)
    OpenMultichar()
end)

function OpenMultichar()
    if isOpen then return end
    isOpen = true

    DoScreenFadeOut(500)
    Wait(600)

    -- Ladebildschirm beenden
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    SetNuiFocus(true, true)

    -- Kamera einrichten
    local camPos = vector3(-75.0, -819.0, 326.0)
    charCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(charCam, camPos.x, camPos.y, camPos.z)
    SetCamRot(charCam, -5.0, 0.0, 0.0, 2)
    SetCamFov(charCam, 45.0)
    SetCamActive(charCam, true)
    RenderScriptCams(true, false, 0, true, true)

    -- Charaktere laden
    ESV.Functions.TriggerCallback('esv:getCharacters', function(characters)
        SendNUIMessage({
            action = 'openMultichar',
            characters = characters,
            maxSlots = ESV.Config.MaxCharacters,
        })
        DoScreenFadeIn(500)
    end)
end

function CloseMultichar()
    isOpen = false
    SetNuiFocus(false, false)

    if charCam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(charCam, false)
        charCam = nil
    end

    SendNUIMessage({ action = 'closeMultichar' })
end

-- NUI Callbacks
RegisterNUICallback('selectCharacter', function(data, cb)
    CloseMultichar()
    DoScreenFadeOut(500)
    Wait(600)
    TriggerServerEvent('esv:server:selectCharacter', data.slot)
    cb('ok')
end)

RegisterNUICallback('createCharacter', function(data, cb)
    TriggerServerEvent('esv:server:createCharacter', {
        slot = data.slot,
        firstname = data.firstname,
        lastname = data.lastname,
        dateofbirth = data.dateofbirth,
        gender = data.gender,
        nationality = data.nationality,
    })
    cb('ok')
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    TriggerServerEvent('esv:server:deleteCharacter', data.slot)
    cb('ok')
end)

RegisterNUICallback('closeMultichar', function(data, cb)
    cb('ok')
end)

RegisterNetEvent('esv:client:characterCreated', function(charId, slot)
    ESV.Functions.TriggerCallback('esv:getCharacters', function(characters)
        SendNUIMessage({
            action = 'openMultichar',
            characters = characters,
            maxSlots = ESV.Config.MaxCharacters,
        })
    end)
end)

RegisterNetEvent('esv:client:characterDeleted', function(slot)
    ESV.Functions.TriggerCallback('esv:getCharacters', function(characters)
        SendNUIMessage({
            action = 'openMultichar',
            characters = characters,
            maxSlots = ESV.Config.MaxCharacters,
        })
    end)
end)
