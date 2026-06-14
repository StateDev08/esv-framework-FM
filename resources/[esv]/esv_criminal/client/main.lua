local isJailed = false
local jailTime = 0

-- ==================== DROGEN ====================
local drugFields = {
    { pos = vector3(2222.0, 5577.0, 53.8), type = "cannabis", label = "Cannabis Feld", harvestItem = "cannabis_blatt", needItem = "cannabis_samen" },
    { pos = vector3(1388.0, 3606.0, 34.9), type = "koka", label = "Koka Feld", harvestItem = "koka_blatt", needItem = nil },
}

local drugProcessing = {
    { pos = vector3(1000.0, -3200.0, -38.9), type = "cannabis", label = "Cannabis Trocknung", input = "cannabis_blatt", output = "cannabis_trocken", amount = 2 },
    { pos = vector3(1093.0, -3196.0, -38.9), type = "joint", label = "Joint drehen", input = "cannabis_trocken", output = "joint", amount = 1 },
    { pos = vector3(997.0, -3200.0, -38.9), type = "kokain", label = "Kokain verarbeiten", input = "koka_blatt", output = "kokain", amount = 3 },
    { pos = vector3(1100.0, -3200.0, -38.9), type = "meth", label = "Meth kochen", input = "meth_zutaten", output = "meth", amount = 2 },
}

local drugSellPoints = {
    { pos = vector3(127.0, -1280.0, 29.3), label = "Dealer - Innenstadt" },
    { pos = vector3(-1167.0, -1571.0, 4.4), label = "Dealer - Strand" },
    { pos = vector3(321.0, -2037.0, 21.3), label = "Dealer - Hafen" },
}

-- Drogen-Felder
CreateThread(function()
    while true do
        Wait(500)
        if not ESV.CharacterLoaded then goto continue end
        local coords = GetEntityCoords(PlayerPedId())

        for _, field in ipairs(drugFields) do
            if #(coords - field.pos) < 3.0 then
                ESV.Functions.ShowHelpText("~INPUT_CONTEXT~ " .. field.label .. " (Ernten)")
                break
            end
        end

        for _, proc in ipairs(drugProcessing) do
            if #(coords - proc.pos) < 2.0 then
                ESV.Functions.ShowHelpText("~INPUT_CONTEXT~ " .. proc.label)
                break
            end
        end

        for _, sell in ipairs(drugSellPoints) do
            if #(coords - sell.pos) < 2.0 then
                ESV.Functions.ShowHelpText("~INPUT_CONTEXT~ Drogen verkaufen")
                break
            end
        end
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if not ESV.CharacterLoaded or not IsControlJustReleased(0, 38) then goto continue end
        local coords = GetEntityCoords(PlayerPedId())

        for _, field in ipairs(drugFields) do
            if #(coords - field.pos) < 3.0 then
                TriggerServerEvent('esv:criminal:harvest', field.type, field.harvestItem, field.needItem)
                ESV.Functions.PlayAnim('amb@world_human_gardener_plant@male@base', 'base', 5000, 1)
                break
            end
        end

        for _, proc in ipairs(drugProcessing) do
            if #(coords - proc.pos) < 2.0 then
                TriggerServerEvent('esv:criminal:process', proc.input, proc.output, proc.amount)
                ESV.Functions.PlayAnim('anim@gangops@facility@servers@', 'hotwire', 5000, 1)
                break
            end
        end

        for _, sell in ipairs(drugSellPoints) do
            if #(coords - sell.pos) < 2.0 then
                TriggerServerEvent('esv:criminal:sellDrugs')
                break
            end
        end
        ::continue::
    end
end)

-- ==================== UEBERFAELLE ====================
local robbableStores = {
    { pos = vector3(25.7, -1346.3, 29.5), label = "24/7 Supermarkt", reward = { min = 1000, max = 3000 }, cooldown = 600 },
    { pos = vector3(-3039.5, 584.4, 7.9), label = "24/7 Supermarkt", reward = { min = 1000, max = 3000 }, cooldown = 600 },
    { pos = vector3(373.6, 325.7, 103.6), label = "24/7 Supermarkt", reward = { min = 1000, max = 3000 }, cooldown = 600 },
    { pos = vector3(-706.4, -913.7, 19.2), label = "24/7 Supermarkt", reward = { min = 1000, max = 3000 }, cooldown = 600 },
}

RegisterCommand('rob', function()
    if not ESV.CharacterLoaded then return end
    local coords = GetEntityCoords(PlayerPedId())

    for _, store in ipairs(robbableStores) do
        if #(coords - store.pos) < 5.0 then
            TriggerServerEvent('esv:criminal:robStore', store.label, store.reward)
            ESV.Functions.PlayAnim('mp_am_hold_up', 'highpiste_base', 15000, 49)
            return
        end
    end

    TriggerEvent('esv:client:notify', 'error', 'Kein Laden zum Ueberfallen in der Naehe!')
end, false)

-- ==================== GEFAENGNIS ====================
RegisterNetEvent('esv:client:jailed', function(time, reason)
    isJailed = true
    jailTime = time * 60 -- in Sekunden

    DoScreenFadeOut(500)
    Wait(600)

    local jailPos = ESV.Config.JailPosition
    SetEntityCoords(PlayerPedId(), jailPos.x, jailPos.y, jailPos.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), jailPos.w)

    DoScreenFadeIn(500)
    TriggerEvent('esv:client:notify', 'error', 'Du bist im Gefaengnis fuer ' .. time .. ' Minuten. Grund: ' .. reason)

    -- Alle Waffen entfernen
    RemoveAllPedWeapons(PlayerPedId(), true)
end)

-- Gefaengnis-Timer
CreateThread(function()
    while true do
        Wait(1000)
        if isJailed and jailTime > 0 then
            jailTime = jailTime - 1

            local minutes = math.floor(jailTime / 60)
            local seconds = jailTime % 60

            ESV.Functions.DrawText3D(
                GetEntityCoords(PlayerPedId()).x,
                GetEntityCoords(PlayerPedId()).y,
                GetEntityCoords(PlayerPedId()).z + 1.0,
                "~r~GEFAENGNIS~w~ - " .. minutes .. ":" .. string.format("%02d", seconds)
            )

            if jailTime <= 0 then
                isJailed = false
                TriggerServerEvent('esv:criminal:released')
                DoScreenFadeOut(500)
                Wait(600)
                local spawn = ESV.Config.DefaultSpawn
                SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z, false, false, false, false)
                SetEntityHeading(PlayerPedId(), spawn.w)
                DoScreenFadeIn(500)
                TriggerEvent('esv:client:notify', 'success', 'Du wurdest aus dem Gefaengnis entlassen!')
            end
        end

        -- Gefaengnis-Grenzen
        if isJailed then
            local coords = GetEntityCoords(PlayerPedId())
            local jailCenter = vector3(ESV.Config.JailPosition.x, ESV.Config.JailPosition.y, ESV.Config.JailPosition.z)
            if #(coords - jailCenter) > 100.0 then
                SetEntityCoords(PlayerPedId(), jailCenter.x, jailCenter.y, jailCenter.z, false, false, false, false)
            end
        end
    end
end)

exports('IsJailed', function() return isJailed end)
