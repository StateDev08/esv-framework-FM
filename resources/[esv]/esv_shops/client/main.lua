local shops = {
    {
        label = "24/7 Supermarkt", type = "general",
        locations = {
            vector3(25.7, -1346.3, 29.5), vector3(-3039.5, 584.4, 7.9),
            vector3(-3242.9, 1000.0, 12.8), vector3(1728.5, 6414.0, 35.0),
            vector3(1960.5, 3740.7, 32.3), vector3(549.1, 2671.0, 42.2),
            vector3(2678.0, 3280.4, 55.2), vector3(-47.0, -1758.7, 29.4),
            vector3(373.6, 325.7, 103.6), vector3(-706.4, -913.7, 19.2),
        },
        items = {
            { name = "brot", price = 10 }, { name = "wasser", price = 8 },
            { name = "burger", price = 25 }, { name = "cola", price = 12 },
            { name = "kaffee", price = 15 }, { name = "donut", price = 8 },
            { name = "sandwich", price = 20 }, { name = "energydrink", price = 18 },
            { name = "taschenlampe", price = 50 }, { name = "handy", price = 500 },
            { name = "bandage", price = 100 }, { name = "schmerzmittel", price = 80 },
        },
        blip = { sprite = 52, color = 1, scale = 0.7 },
    },
    {
        label = "Ammunation", type = "weapons",
        locations = {
            vector3(22.2, -1107.6, 29.8), vector3(252.6, -50.0, 69.9),
            vector3(842.4, -1034.0, 28.2), vector3(-330.2, 6084.0, 31.5),
            vector3(-661.5, -935.3, 21.8), vector3(2567.7, 294.4, 108.7),
            vector3(-1117.6, 2700.0, 18.6), vector3(1693.4, 3760.2, 34.7),
        },
        items = {
            { name = "pistol_ammo", price = 250 }, { name = "smg_ammo", price = 500 },
            { name = "rifle_ammo", price = 750 }, { name = "shotgun_ammo", price = 400 },
            { name = "verbandskasten", price = 200 }, { name = "reparaturkit", price = 500 },
        },
        blip = { sprite = 110, color = 1, scale = 0.8 },
    },
    {
        label = "Tankstellen-Shop", type = "gas",
        locations = {
            vector3(49.4, 2778.8, 58.0), vector3(1039.9, 2671.1, 39.6),
            vector3(-724.6, -935.2, 19.2),
        },
        items = {
            { name = "wasser", price = 5 }, { name = "cola", price = 8 },
            { name = "donut", price = 5 }, { name = "energydrink", price = 12 },
            { name = "benzinkanister", price = 200 },
        },
        blip = { sprite = 52, color = 25, scale = 0.6 },
    },
}

-- Blips
CreateThread(function()
    while not ESV.CharacterLoaded do Wait(500) end
    for _, shop in ipairs(shops) do
        for _, loc in ipairs(shop.locations) do
            local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
            SetBlipSprite(blip, shop.blip.sprite)
            SetBlipScale(blip, shop.blip.scale)
            SetBlipColour(blip, shop.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(shop.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Shop-Interaktion
CreateThread(function()
    while true do
        Wait(500)
        if not ESV.CharacterLoaded then goto continue end
        local coords = GetEntityCoords(PlayerPedId())

        for _, shop in ipairs(shops) do
            for _, loc in ipairs(shop.locations) do
                if #(coords - loc) < 2.0 then
                    ESV.Functions.ShowHelpText("Druecke ~INPUT_CONTEXT~ fuer " .. shop.label)
                    goto done
                end
            end
        end
        ::done::
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if not ESV.CharacterLoaded then goto continue end
        if not IsControlJustReleased(0, 38) then goto continue end

        local coords = GetEntityCoords(PlayerPedId())
        for _, shop in ipairs(shops) do
            for _, loc in ipairs(shop.locations) do
                if #(coords - loc) < 2.0 then
                    OpenShopMenu(shop)
                    goto done2
                end
            end
        end
        ::done2::
        ::continue::
    end
end)

function OpenShopMenu(shop)
    local options = {}
    for _, item in ipairs(shop.items) do
        local def = ESV.Items[item.name]
        local label = def and def.label or item.name
        table.insert(options, {
            title = label .. " - $" .. item.price,
            description = def and def.description or "",
            event = 'esv:shops:buy',
            args = { name = item.name, price = item.price, shopType = shop.type },
        })
    end

    lib.registerContext({
        id = 'shop_menu',
        title = shop.label,
        options = options,
    })
    lib.showContext('shop_menu')
end

RegisterNetEvent('esv:shops:buy', function(data)
    TriggerServerEvent('esv:shops:purchase', data.name, data.price)
end)
