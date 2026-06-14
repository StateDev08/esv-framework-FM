local noclipActive = false
local noclipCam = nil

RegisterNetEvent('esv:admin:teleport', function(x, y, z)
    SetEntityCoords(PlayerPedId(), x, y, z, false, false, false, false)
end)

RegisterNetEvent('esv:admin:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 100)
    ClearPedBloodDamage(ped)
    TriggerEvent('esv:client:eat', 100)
    TriggerEvent('esv:client:drink', 100)
    TriggerEvent('esv:client:notify', 'success', 'Du wurdest vollstaendig geheilt')
end)

RegisterNetEvent('esv:admin:noclip', function()
    noclipActive = not noclipActive
    local ped = PlayerPedId()

    if noclipActive then
        SetEntityVisible(ped, false, false)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetEntityCollision(ped, false, false)
        TriggerEvent('esv:client:notify', 'info', 'NoClip aktiviert')

        CreateThread(function()
            while noclipActive do
                Wait(0)
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                local speed = 1.0

                if IsControlPressed(0, 21) then speed = 5.0 end -- Shift

                if IsControlPressed(0, 32) then -- W
                    local dx = -math.sin(math.rad(heading)) * speed
                    local dy = math.cos(math.rad(heading)) * speed
                    SetEntityCoords(ped, coords.x + dx, coords.y + dy, coords.z, false, false, false, false)
                end
                if IsControlPressed(0, 33) then -- S
                    local dx = math.sin(math.rad(heading)) * speed
                    local dy = -math.cos(math.rad(heading)) * speed
                    SetEntityCoords(ped, coords.x + dx, coords.y + dy, coords.z, false, false, false, false)
                end
                if IsControlPressed(0, 34) then -- A
                    SetEntityHeading(ped, heading + 2.0)
                end
                if IsControlPressed(0, 35) then -- D
                    SetEntityHeading(ped, heading - 2.0)
                end
                if IsControlPressed(0, 44) then -- Q - runter
                    SetEntityCoords(ped, coords.x, coords.y, coords.z - speed, false, false, false, false)
                end
                if IsControlPressed(0, 38) then -- E - hoch
                    SetEntityCoords(ped, coords.x, coords.y, coords.z + speed, false, false, false, false)
                end
            end
        end)
    else
        SetEntityVisible(ped, true, false)
        SetEntityInvincible(ped, false)
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
        TriggerEvent('esv:client:notify', 'info', 'NoClip deaktiviert')
    end
end)

RegisterNetEvent('esv:admin:spawnVehicle', function(model)
    local hash = joaat(model)
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    if not HasModelLoaded(hash) then
        TriggerEvent('esv:client:notify', 'error', 'Modell nicht gefunden: ' .. model)
        return
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    SetVehicleNumberPlateText(vehicle, "ADMIN")
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetModelAsNoLongerNeeded(hash)
    TriggerEvent('esv:client:notify', 'success', 'Fahrzeug gespawnt: ' .. model)
end)

RegisterNetEvent('esv:admin:deleteVehicle', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        DeleteEntity(veh)
        TriggerEvent('esv:client:notify', 'success', 'Fahrzeug geloescht')
    else
        local closest = ESV.Functions.GetClosestVehicle(10.0)
        if closest and closest ~= 0 then
            DeleteEntity(closest)
            TriggerEvent('esv:client:notify', 'success', 'Fahrzeug geloescht')
        end
    end
end)
