local isOpen = false
local clothingShops = {
    { pos = vector3(72.3, -1399.1, 29.4), label = "Binco", blip = { sprite = 73, color = 47 } },
    { pos = vector3(-703.8, -152.3, 37.4), label = "Ponsonbys", blip = { sprite = 73, color = 47 } },
    { pos = vector3(-167.9, -299.0, 39.7), label = "Suburban", blip = { sprite = 73, color = 47 } },
    { pos = vector3(428.7, -800.1, 29.5), label = "Kleidungsladen", blip = { sprite = 73, color = 47 } },
    { pos = vector3(-829.4, -1073.7, 11.3), label = "Kleidungsladen", blip = { sprite = 73, color = 47 } },
    { pos = vector3(-1447.8, -242.5, 49.8), label = "Kleidungsladen", blip = { sprite = 73, color = 47 } },
    { pos = vector3(11.6, 6514.2, 31.9), label = "Kleidungsladen", blip = { sprite = 73, color = 47 } },
    { pos = vector3(1696.3, 4829.3, 42.1), label = "Kleidungsladen", blip = { sprite = 73, color = 47 } },
    { pos = vector3(618.1, 2759.6, 42.1), label = "Kleidungsladen", blip = { sprite = 73, color = 47 } },
    { pos = vector3(1190.6, 2713.4, 38.2), label = "Kleidungsladen", blip = { sprite = 73, color = 47 } },
}

local barberShops = {
    { pos = vector3(-814.3, -183.8, 37.6), label = "Friseur" },
    { pos = vector3(136.8, -1708.4, 29.3), label = "Friseur" },
    { pos = vector3(-1282.6, -1116.8, 7.0), label = "Friseur" },
    { pos = vector3(1931.5, 3729.7, 32.8), label = "Friseur" },
    { pos = vector3(1212.8, -472.9, 66.2), label = "Friseur" },
    { pos = vector3(-32.9, -152.3, 57.1), label = "Friseur" },
    { pos = vector3(-278.1, 6228.5, 31.7), label = "Friseur" },
}

-- Blips
CreateThread(function()
    while not ESV.CharacterLoaded do Wait(500) end
    for _, shop in ipairs(clothingShops) do
        local blip = AddBlipForCoord(shop.pos.x, shop.pos.y, shop.pos.z)
        SetBlipSprite(blip, shop.blip.sprite)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, shop.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.label)
        EndTextCommandSetBlipName(blip)
    end

    for _, shop in ipairs(barberShops) do
        local blip = AddBlipForCoord(shop.pos.x, shop.pos.y, shop.pos.z)
        SetBlipSprite(blip, 71)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 4)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Shop-Erkennung
CreateThread(function()
    while true do
        Wait(500)
        if not ESV.CharacterLoaded then goto continue end
        local coords = GetEntityCoords(PlayerPedId())

        for _, shop in ipairs(clothingShops) do
            if #(coords - shop.pos) < 2.0 and not isOpen then
                ESV.Functions.ShowHelpText("Druecke ~INPUT_CONTEXT~ fuer Kleidungsladen")
                break
            end
        end
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if not ESV.CharacterLoaded or isOpen then goto continue end
        local coords = GetEntityCoords(PlayerPedId())

        for _, shop in ipairs(clothingShops) do
            if #(coords - shop.pos) < 2.0 and IsControlJustReleased(0, 38) then
                OpenClothingShop()
                break
            end
        end
        ::continue::
    end
end)

function OpenClothingShop()
    if isOpen then return end
    isOpen = true
    local ped = PlayerPedId()
    local currentSkin = GetCurrentSkin(ped)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openClothing',
        gender = ESV.PlayerData.character.gender,
        currentSkin = currentSkin,
    })
end

function CloseClothingShop()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeClothing' })
end

function GetCurrentSkin(ped)
    local skin = { components = {}, props = {} }
    for i = 0, 11 do
        skin.components[tostring(i)] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i),
        }
    end
    for i = 0, 7 do
        skin.props[tostring(i)] = {
            drawable = GetPedPropIndex(ped, i),
            texture = GetPedPropTextureIndex(ped, i),
        }
    end
    return skin
end

RegisterNUICallback('closeClothing', function(data, cb)
    CloseClothingShop()
    cb('ok')
end)

RegisterNUICallback('previewComponent', function(data, cb)
    local ped = PlayerPedId()
    SetPedComponentVariation(ped, data.component, data.drawable, data.texture, 0)
    cb('ok')
end)

RegisterNUICallback('previewProp', function(data, cb)
    local ped = PlayerPedId()
    if data.drawable == -1 then
        ClearPedProp(ped, data.prop)
    else
        SetPedPropIndex(ped, data.prop, data.drawable, data.texture, true)
    end
    cb('ok')
end)

RegisterNUICallback('saveOutfit', function(data, cb)
    local ped = PlayerPedId()
    local skin = GetCurrentSkin(ped)
    TriggerServerEvent('esv:server:saveSkin', skin)
    TriggerEvent('esv:client:notify', 'success', 'Outfit gespeichert!')
    CloseClothingShop()
    cb('ok')
end)

RegisterNUICallback('resetOutfit', function(data, cb)
    if ESV.PlayerData.character.skin then
        ESV.Functions.ApplySkin(ESV.PlayerData.character.skin)
    end
    cb('ok')
end)

local componentNames = {
    [0] = "Kopf", [1] = "Maske", [2] = "Haare", [3] = "Oberteil",
    [4] = "Hose", [5] = "Tasche", [6] = "Schuhe", [7] = "Accessoire",
    [8] = "Unterhemd", [9] = "Koerperschutz", [10] = "Aufkleber", [11] = "Jacke",
}

local propNames = {
    [0] = "Hut", [1] = "Brille", [2] = "Ohren", [6] = "Uhr", [7] = "Armband",
}
