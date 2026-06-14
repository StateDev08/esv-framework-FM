ESV = ESV or {}
ESV.Functions = ESV.Functions or {}

local callbackId = 0
local pendingCallbacks = {}

function ESV.Functions.TriggerCallback(name, cb, ...)
    callbackId = callbackId + 1
    pendingCallbacks[callbackId] = cb
    TriggerServerEvent('esv:server:triggerCallback', name, callbackId, ...)
end

RegisterNetEvent('esv:client:callbackResponse', function(requestId, ...)
    if pendingCallbacks[requestId] then
        pendingCallbacks[requestId](...)
        pendingCallbacks[requestId] = nil
    end
end)

function ESV.Functions.DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function ESV.Functions.ShowHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function ESV.Functions.ApplySkin(skin)
    if not skin then return end
    local ped = PlayerPedId()

    if skin.model then
        local hash = type(skin.model) == "string" and joaat(skin.model) or skin.model
        RequestModel(hash)
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end
        if HasModelLoaded(hash) then
            SetPlayerModel(PlayerId(), hash)
            ped = PlayerPedId()
            SetModelAsNoLongerNeeded(hash)
        end
    end

    if skin.face then
        for k, v in pairs(skin.face) do
            SetPedHeadBlendData(ped, v.shapeFirst or 0, v.shapeSecond or 0, 0,
                v.skinFirst or 0, v.skinSecond or 0, 0,
                v.shapeMix or 0.5, v.skinMix or 0.5, 0.0, false)
        end
    end

    if skin.components then
        for compId, data in pairs(skin.components) do
            SetPedComponentVariation(ped, tonumber(compId), data.drawable or 0, data.texture or 0, data.palette or 0)
        end
    end

    if skin.props then
        for propId, data in pairs(skin.props) do
            if data.drawable == -1 then
                ClearPedProp(ped, tonumber(propId))
            else
                SetPedPropIndex(ped, tonumber(propId), data.drawable or 0, data.texture or 0, true)
            end
        end
    end

    if skin.hair then
        SetPedComponentVariation(ped, 2, skin.hair.style or 0, skin.hair.color or 0, 0)
        SetPedHairColor(ped, skin.hair.color or 0, skin.hair.highlight or 0)
    end
end

function ESV.Functions.GetClosestPlayer(radius)
    local coords = GetEntityCoords(PlayerPedId())
    local closest = -1
    local closestDist = radius or 3.0
    local players = GetActivePlayers()

    for _, player in ipairs(players) do
        if player ~= PlayerId() then
            local targetPed = GetPlayerPed(player)
            local dist = #(coords - GetEntityCoords(targetPed))
            if dist < closestDist then
                closestDist = dist
                closest = GetPlayerServerId(player)
            end
        end
    end

    return closest, closestDist
end

function ESV.Functions.GetClosestVehicle(radius)
    local coords = GetEntityCoords(PlayerPedId())
    local vehicles = GetGamePool('CVehicle')
    local closest = 0
    local closestDist = radius or 5.0

    for _, vehicle in ipairs(vehicles) do
        local dist = #(coords - GetEntityCoords(vehicle))
        if dist < closestDist then
            closestDist = dist
            closest = vehicle
        end
    end

    return closest, closestDist
end

function ESV.Functions.GetClosestObject(radius)
    local coords = GetEntityCoords(PlayerPedId())
    local objects = GetGamePool('CObject')
    local closest = 0
    local closestDist = radius or 3.0

    for _, obj in ipairs(objects) do
        local dist = #(coords - GetEntityCoords(obj))
        if dist < closestDist then
            closestDist = dist
            closest = obj
        end
    end

    return closest, closestDist
end

function ESV.Functions.LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(5)
    end
end

function ESV.Functions.PlayAnim(dict, anim, duration, flag)
    ESV.Functions.LoadAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, duration or -1, flag or 0, 0, false, false, false)
end

function ESV.Functions.Notify(type, message, duration)
    TriggerEvent('esv:client:notify', type, message, duration)
end

-- Exports
exports('GetPlayerData', function() return ESV.PlayerData end)
exports('IsCharacterLoaded', function() return ESV.CharacterLoaded end)
exports('TriggerCallback', ESV.Functions.TriggerCallback)
exports('GetClosestPlayer', ESV.Functions.GetClosestPlayer)
exports('GetClosestVehicle', ESV.Functions.GetClosestVehicle)
