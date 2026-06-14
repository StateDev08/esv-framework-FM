local insideProperty = nil

local properties = {
    { id = 'apt_01', label = 'Apartment Alta St.', price = 150000, pos = vector3(-271.0, -957.0, 31.2), interior = vector3(346.5, -1013.0, -99.2), heading = 0.0 },
    { id = 'apt_02', label = 'Apartment Vinewood', price = 250000, pos = vector3(-906.3, -370.2, 113.1), interior = vector3(346.5, -1013.0, -99.2), heading = 0.0 },
    { id = 'apt_03', label = 'Haus Grove Street', price = 350000, pos = vector3(-14.9, -1438.7, 31.1), interior = vector3(346.5, -1013.0, -99.2), heading = 0.0 },
    { id = 'apt_04', label = 'Haus Paleto Bay', price = 120000, pos = vector3(-381.0, 6262.0, 31.5), interior = vector3(346.5, -1013.0, -99.2), heading = 0.0 },
    { id = 'apt_05', label = 'Villa Vinewood Hills', price = 800000, pos = vector3(-855.7, 682.5, 152.6), interior = vector3(346.5, -1013.0, -99.2), heading = 0.0 },
    { id = 'apt_06', label = 'Villa Richman', price = 1200000, pos = vector3(-1543.0, 119.0, 59.2), interior = vector3(346.5, -1013.0, -99.2), heading = 0.0 },
}

-- Blips fuer Wohnungen
CreateThread(function()
    while not ESV.CharacterLoaded do Wait(500) end
    for _, prop in ipairs(properties) do
        local blip = AddBlipForCoord(prop.pos.x, prop.pos.y, prop.pos.z)
        SetBlipSprite(blip, 40)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 69)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(prop.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Wohnungs-Interaktion
CreateThread(function()
    while true do
        Wait(500)
        if not ESV.CharacterLoaded then goto continue end
        local coords = GetEntityCoords(PlayerPedId())

        for _, prop in ipairs(properties) do
            if #(coords - prop.pos) < 2.0 then
                ESV.Functions.ShowHelpText("~INPUT_CONTEXT~ " .. prop.label)
                break
            end
        end
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if not ESV.CharacterLoaded then goto continue end
        local coords = GetEntityCoords(PlayerPedId())

        if IsControlJustReleased(0, 38) then
            for _, prop in ipairs(properties) do
                if #(coords - prop.pos) < 2.0 then
                    TriggerServerEvent('esv:housing:interact', prop.id)
                    break
                end
            end
        end
        ::continue::
    end
end)

RegisterNetEvent('esv:client:enterProperty', function(propId, interior, heading)
    insideProperty = propId
    DoScreenFadeOut(500)
    Wait(600)
    SetEntityCoords(PlayerPedId(), interior.x, interior.y, interior.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), heading or 0.0)
    DoScreenFadeIn(500)
    TriggerEvent('esv:client:notify', 'info', 'Wohnung betreten')
end)

RegisterNetEvent('esv:client:exitProperty', function(exterior)
    insideProperty = nil
    DoScreenFadeOut(500)
    Wait(600)
    SetEntityCoords(PlayerPedId(), exterior.x, exterior.y, exterior.z, false, false, false, false)
    DoScreenFadeIn(500)
    TriggerEvent('esv:client:notify', 'info', 'Wohnung verlassen')
end)

RegisterCommand('exit', function()
    if insideProperty then
        TriggerServerEvent('esv:housing:exit', insideProperty)
    end
end, false)

RegisterNetEvent('esv:client:propertyBought', function(label, price)
    TriggerEvent('esv:client:notify', 'success', label .. ' gekauft fuer $' .. price .. '!')
end)
