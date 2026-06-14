local nearGarage = nil
local nearDealership = false
local vehicleKeys = {}

-- Garagen-Blips und Erkennung
CreateThread(function()
    while not ESV.CharacterLoaded do Wait(500) end

    for id, garage in pairs(ESV.Config.Garages) do
        local blip = AddBlipForCoord(garage.spawn.x, garage.spawn.y, garage.spawn.z)
        SetBlipSprite(blip, garage.blip.sprite)
        SetBlipScale(blip, garage.blip.scale)
        SetBlipColour(blip, garage.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(garage.label)
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        if not ESV.CharacterLoaded then goto continue end

        local coords = GetEntityCoords(PlayerPedId())
        nearGarage = nil

        for id, garage in pairs(ESV.Config.Garages) do
            local dist = #(coords - vector3(garage.spawn.x, garage.spawn.y, garage.spawn.z))
            if dist < 5.0 then
                nearGarage = id
                break
            end
        end

        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if nearGarage then
            ESV.Functions.ShowHelpText("Druecke ~INPUT_CONTEXT~ fuer Garage")
            if IsControlJustReleased(0, 38) then
                OpenGarage(nearGarage)
            end
        end
    end
end)

function OpenGarage(garageId)
    ESV.Functions.TriggerCallback('esv:vehicles:getGarage', function(vehicles)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openGarage',
            garage = garageId,
            garageLabel = ESV.Config.Garages[garageId].label,
            vehicles = vehicles,
        })
    end, garageId)
end

RegisterNUICallback('closeGarage', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    TriggerServerEvent('esv:vehicles:spawn', data.vehicleId, data.garage)
    cb('ok')
end)

RegisterNUICallback('storeVehicle', function(data, cb)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local plate = GetVehicleNumberPlateText(veh)
        local fuel = GetVehicleFuelLevel(veh)
        local bodyHealth = GetVehicleBodyHealth(veh)
        local engineHealth = GetVehicleEngineHealth(veh)
        TriggerServerEvent('esv:vehicles:store', plate, data.garage, fuel, bodyHealth, engineHealth)
        DeleteEntity(veh)
    end
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    cb('ok')
end)

RegisterNetEvent('esv:client:spawnVehicle', function(model, plate, spawnPos, mods, fuel)
    local hash = joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local vehicle = CreateVehicle(hash, spawnPos.x, spawnPos.y, spawnPos.z, spawnPos.w, true, false)
    SetVehicleNumberPlateText(vehicle, plate)
    SetVehicleFuelLevel(vehicle, fuel or 100.0)
    SetEntityAsMissionEntity(vehicle, true, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetModelAsNoLongerNeeded(hash)

    vehicleKeys[plate] = true
    TriggerEvent('esv:client:notify', 'success', 'Fahrzeug ausgefahren')
end)

-- ==================== AUTOHÄNDLER ====================
local dealershipPositions = {
    standard = { pos = vector3(-56.0, -1096.0, 26.4), blip = { sprite = 326, color = 2, scale = 0.9 }, label = "Standard Autohaus" },
    premium  = { pos = vector3(-802.0, -223.0, 37.1), blip = { sprite = 326, color = 5, scale = 0.9 }, label = "Premium Autohaus" },
    luxury   = { pos = vector3(-1260.0, -357.0, 36.9), blip = { sprite = 326, color = 46, scale = 0.9 }, label = "Luxus Autohaus" },
}

CreateThread(function()
    while not ESV.CharacterLoaded do Wait(500) end
    for id, dealer in pairs(dealershipPositions) do
        local blip = AddBlipForCoord(dealer.pos.x, dealer.pos.y, dealer.pos.z)
        SetBlipSprite(blip, dealer.blip.sprite)
        SetBlipScale(blip, dealer.blip.scale)
        SetBlipColour(blip, dealer.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(dealer.label)
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        if not ESV.CharacterLoaded then goto continue end
        local coords = GetEntityCoords(PlayerPedId())
        nearDealership = nil
        for id, dealer in pairs(dealershipPositions) do
            if #(coords - dealer.pos) < 5.0 then
                nearDealership = id
                break
            end
        end
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if nearDealership then
            ESV.Functions.ShowHelpText("Druecke ~INPUT_CONTEXT~ fuer Autohaus")
            if IsControlJustReleased(0, 38) then
                local vehicles = {}
                for _, v in ipairs(ESV.Vehicles) do
                    if v.shop == nearDealership then
                        table.insert(vehicles, v)
                    end
                end
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'openDealership',
                    shop = nearDealership,
                    shopLabel = dealershipPositions[nearDealership].label,
                    vehicles = vehicles,
                    categories = ESV.VehicleCategories,
                })
            end
        end
    end
end)

RegisterNUICallback('closeDealership', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    cb('ok')
end)

RegisterNUICallback('buyVehicle', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    TriggerServerEvent('esv:vehicles:buy', data.model, data.shop)
    cb('ok')
end)

-- ==================== TANKEN ====================
local fuelStations = {
    vector3(49.4, 2778.8, 58.0), vector3(263.9, 2606.5, 45.0),
    vector3(1039.9, 2671.1, 39.6), vector3(1207.3, 2660.5, 37.9),
    vector3(2539.7, 2594.7, 38.0), vector3(2679.9, 3263.9, 55.2),
    vector3(2005.5, 3774.3, 32.4), vector3(1687.2, 4929.4, 42.1),
    vector3(1701.8, 6416.1, 32.8), vector3(179.8, 6602.8, 31.9),
    vector3(-94.2, 6419.0, 31.5), vector3(-2554.8, 2334.0, 33.1),
    vector3(-1800.4, 803.7, 138.7), vector3(-1437.6, -276.7, 46.2),
    vector3(-2096.2, -320.3, 13.2), vector3(-724.6, -935.2, 19.2),
    vector3(-526.0, -1211.0, 18.2), vector3(-70.2, -1761.8, 29.5),
    vector3(265.6, -1261.3, 29.3), vector3(819.7, -1028.6, 26.4),
    vector3(1208.9, -1402.6, 35.2), vector3(1181.4, -330.8, 69.3),
    vector3(620.8, 269.0, 103.1), vector3(-1108.4, 2708.8, 19.3),
    vector3(2581.2, 362.0, 108.5),
}

CreateThread(function()
    while not ESV.CharacterLoaded do Wait(500) end
    for _, pos in ipairs(fuelStations) do
        local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
        SetBlipSprite(blip, 361)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 47)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Tankstelle")
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        if not ESV.CharacterLoaded then goto continue end
        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) then goto continue end

        local veh = GetVehiclePedIsIn(ped, false)
        local coords = GetEntityCoords(ped)
        local nearFuel = false

        for _, pos in ipairs(fuelStations) do
            if #(coords - pos) < 10.0 then
                nearFuel = true
                break
            end
        end

        if nearFuel and GetEntitySpeed(veh) < 1.0 then
            ESV.Functions.ShowHelpText("Druecke ~INPUT_CONTEXT~ zum Tanken")
            if IsControlJustReleased(0, 38) then
                local fuel = GetVehicleFuelLevel(veh)
                local needed = ESV.Config.MaxFuel - fuel
                local cost = math.floor(needed * ESV.Config.FuelPrice)

                TriggerServerEvent('esv:vehicles:refuel', cost, needed)
            end
        end
        ::continue::
    end
end)

RegisterNetEvent('esv:client:refueled', function(amount)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local currentFuel = GetVehicleFuelLevel(veh)
        SetVehicleFuelLevel(veh, math.min(100.0, currentFuel + amount))
        TriggerEvent('esv:client:notify', 'success', 'Fahrzeug aufgetankt!')
    end
end)

-- ==================== SCHLÜSSEL ====================
RegisterCommand('lock', function()
    if not ESV.CharacterLoaded then return end
    local vehicle = ESV.Functions.GetClosestVehicle(10.0)
    if vehicle == 0 then return end
    local plate = GetVehicleNumberPlateText(vehicle)
    if vehicleKeys[plate] then
        local locked = GetVehicleDoorLockStatus(vehicle) == 2
        if locked then
            SetVehicleDoorsLocked(vehicle, 1)
            TriggerEvent('esv:client:notify', 'info', 'Fahrzeug entsperrt')
        else
            SetVehicleDoorsLocked(vehicle, 2)
            TriggerEvent('esv:client:notify', 'info', 'Fahrzeug gesperrt')
        end
    else
        TriggerEvent('esv:client:notify', 'error', 'Du hast keinen Schluessel!')
    end
end, false)
RegisterKeyMapping('lock', 'Fahrzeug (ent)sperren', 'keyboard', 'U')

-- Kraftstoffverbrauch
CreateThread(function()
    while true do
        Wait(10000)
        if not ESV.CharacterLoaded then goto continue end
        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) then goto continue end
        local veh = GetVehiclePedIsIn(ped, false)
        if GetIsVehicleEngineRunning(veh) then
            local speed = GetEntitySpeed(veh)
            local consumption = 0.05 + (speed * 0.005)
            local fuel = GetVehicleFuelLevel(veh)
            SetVehicleFuelLevel(veh, math.max(0, fuel - consumption))
            if fuel < 5 then
                TriggerEvent('esv:client:notify', 'warning', 'Tank fast leer!')
            end
            if fuel <= 0 then
                SetVehicleEngineOn(veh, false, true, true)
            end
        end
        ::continue::
    end
end)

exports('HasKey', function(plate) return vehicleKeys[plate] or false end)
exports('GiveKey', function(plate) vehicleKeys[plate] = true end)
