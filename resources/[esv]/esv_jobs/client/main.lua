local onDuty = false
local isCuffed = false
local isEscorted = false
local escortedBy = 0
local escortTarget = 0

-- Dienst-System
RegisterCommand('duty', function()
    if not ESV.CharacterLoaded then return end
    local job = ESV.PlayerData.character.job
    if job == 'arbeitslos' then
        TriggerEvent('esv:client:notify', 'error', 'Du bist arbeitslos!')
        return
    end
    onDuty = not onDuty
    TriggerServerEvent('esv:jobs:toggleDuty', onDuty)
    if onDuty then
        TriggerEvent('esv:client:notify', 'success', 'Du bist jetzt im Dienst')
    else
        TriggerEvent('esv:client:notify', 'info', 'Du bist jetzt ausser Dienst')
    end
end, false)

-- Job-Blips erstellen
CreateThread(function()
    while not ESV.CharacterLoaded do Wait(500) end

    for jobName, jobData in pairs(ESV.Jobs) do
        if jobData.stations then
            for _, station in pairs(jobData.stations) do
                if station.blip then
                    local blip = AddBlipForCoord(station.position.x, station.position.y, station.position.z)
                    SetBlipSprite(blip, station.blip.sprite)
                    SetBlipScale(blip, station.blip.scale)
                    SetBlipColour(blip, station.blip.color)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(station.label)
                    EndTextCommandSetBlipName(blip)
                end
            end
        end
    end
end)

-- ==================== POLIZEI ====================

-- Fesseln / Entfesseln
RegisterCommand('cuff', function()
    if not ESV.CharacterLoaded then return end
    if ESV.PlayerData.character.job ~= 'police' or not onDuty then
        TriggerEvent('esv:client:notify', 'error', 'Du bist kein aktiver Polizist!')
        return
    end

    local closest = ESV.Functions.GetClosestPlayer(2.0)
    if closest == -1 then
        TriggerEvent('esv:client:notify', 'error', 'Kein Spieler in der Naehe!')
        return
    end

    TriggerServerEvent('esv:jobs:cuffPlayer', closest)
    ESV.Functions.PlayAnim('mp_arrest_paired', 'cop_p2_back_right', 3000, 0)
end, false)

-- Durchsuchen
RegisterCommand('search', function()
    if ESV.PlayerData.character.job ~= 'police' or not onDuty then return end
    local closest = ESV.Functions.GetClosestPlayer(2.0)
    if closest == -1 then
        TriggerEvent('esv:client:notify', 'error', 'Kein Spieler in der Naehe!')
        return
    end
    TriggerServerEvent('esv:jobs:searchPlayer', closest)
end, false)

-- Bussgeld
RegisterCommand('fine', function(src, args)
    if ESV.PlayerData.character.job ~= 'police' or not onDuty then return end
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    local reason = table.concat(args, " ", 3) or ""
    if not targetId or not amount then
        TriggerEvent('esv:client:notify', 'error', '/fine [id] [betrag] [grund]')
        return
    end
    TriggerServerEvent('esv:jobs:finePlayer', targetId, amount, reason)
end, false)

-- Einsperren
RegisterCommand('jail', function(src, args)
    if ESV.PlayerData.character.job ~= 'police' or not onDuty then return end
    local targetId = tonumber(args[1])
    local time = tonumber(args[2]) or 10
    local reason = table.concat(args, " ", 3) or ""
    if not targetId then
        TriggerEvent('esv:client:notify', 'error', '/jail [id] [minuten] [grund]')
        return
    end
    TriggerServerEvent('esv:jobs:jailPlayer', targetId, time, reason)
end, false)

-- Mitnehmen
RegisterCommand('escort', function()
    local job = ESV.PlayerData.character.job
    if (job ~= 'police' and job ~= 'ems') or not onDuty then return end

    if escortTarget ~= 0 then
        TriggerServerEvent('esv:jobs:releaseEscort', escortTarget)
        escortTarget = 0
        return
    end

    local closest = ESV.Functions.GetClosestPlayer(2.0)
    if closest == -1 then return end
    TriggerServerEvent('esv:jobs:escortPlayer', closest)
    escortTarget = closest
end, false)

-- Fahrzeug beschlagnahmen
RegisterCommand('impound', function()
    if ESV.PlayerData.character.job ~= 'police' or not onDuty then return end
    local vehicle = ESV.Functions.GetClosestVehicle(5.0)
    if vehicle == 0 then
        TriggerEvent('esv:client:notify', 'error', 'Kein Fahrzeug in der Naehe!')
        return
    end
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerServerEvent('esv:jobs:impoundVehicle', plate)
    DeleteEntity(vehicle)
    TriggerEvent('esv:client:notify', 'success', 'Fahrzeug beschlagnahmt')
end, false)

-- ==================== EMS ====================

RegisterCommand('revive', function()
    if ESV.PlayerData.character.job ~= 'ems' or not onDuty then return end
    local closest = ESV.Functions.GetClosestPlayer(2.0)
    if closest == -1 then return end
    ESV.Functions.PlayAnim('mini@cpr@char_a@cpr_str', 'cpr_pumpchest', 5000, 0)
    Wait(5000)
    TriggerServerEvent('esv:server:revivePlayer', closest)
end, false)

RegisterCommand('behandeln', function()
    if ESV.PlayerData.character.job ~= 'ems' or not onDuty then return end
    local closest = ESV.Functions.GetClosestPlayer(2.0)
    if closest == -1 then return end
    ESV.Functions.PlayAnim('mini@cpr@char_a@cpr_str', 'cpr_pumpchest', 5000, 0)
    Wait(5000)
    TriggerServerEvent('esv:jobs:healPlayer', closest)
end, false)

-- ==================== MECHANIKER ====================

RegisterCommand('repair', function()
    if ESV.PlayerData.character.job ~= 'mechanic' or not onDuty then return end
    local vehicle = ESV.Functions.GetClosestVehicle(5.0)
    if vehicle == 0 then return end

    ESV.Functions.PlayAnim('mini@repair', 'fixing_a_player', 5000, 0)
    Wait(5000)

    SetVehicleFixed(vehicle)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    TriggerEvent('esv:client:notify', 'success', 'Fahrzeug repariert!')
    TriggerServerEvent('esv:jobs:repairComplete')
end, false)

-- ==================== GEFESSELT / ESKORTIERT ====================

RegisterNetEvent('esv:client:setCuffed', function(state)
    isCuffed = state
    local ped = PlayerPedId()
    if state then
        RequestAnimDict('mp_arresting')
        while not HasAnimDictLoaded('mp_arresting') do Wait(10) end
        TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
        DisablePlayerFiring(PlayerId(), true)
        TriggerEvent('esv:client:notify', 'info', 'Du wurdest gefesselt')
    else
        ClearPedTasks(ped)
        DisablePlayerFiring(PlayerId(), false)
        TriggerEvent('esv:client:notify', 'info', 'Du wurdest entfesselt')
    end
end)

RegisterNetEvent('esv:client:setEscorted', function(state, byPlayer)
    isEscorted = state
    escortedBy = byPlayer or 0

    if state then
        TriggerEvent('esv:client:notify', 'info', 'Du wirst mitgenommen')
    else
        TriggerEvent('esv:client:notify', 'info', 'Du wurdest losgelassen')
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if isEscorted and escortedBy > 0 then
            local escortPed = GetPlayerPed(GetPlayerFromServerId(escortedBy))
            if DoesEntityExist(escortPed) then
                local coords = GetEntityCoords(escortPed)
                local heading = GetEntityHeading(escortPed)
                local offset = GetOffsetFromEntityInWorldCoords(escortPed, 0.0, -0.5, 0.0)
                SetEntityCoords(PlayerPedId(), offset.x, offset.y, offset.z, false, false, false, false)
            end
        end

        if isCuffed then
            DisableControlAction(0, 24, true)   -- Attack
            DisableControlAction(0, 25, true)   -- Aim
            DisableControlAction(0, 47, true)   -- Weapon
            DisableControlAction(0, 58, true)   -- Weapon
            DisableControlAction(0, 263, true)  -- Melee
            DisableControlAction(0, 264, true)  -- Melee
            DisableControlAction(0, 140, true)  -- Melee
            DisableControlAction(0, 141, true)  -- Melee
            DisableControlAction(0, 142, true)  -- Melee
            DisableControlAction(0, 143, true)  -- Melee
        end
    end
end)

-- Dienstfahrzeug spawnen
RegisterCommand('dienstfahrzeug', function()
    if not onDuty then
        TriggerEvent('esv:client:notify', 'error', 'Du musst im Dienst sein!')
        return
    end
    TriggerServerEvent('esv:jobs:spawnJobVehicle')
end, false)

RegisterNetEvent('esv:client:spawnJobVehicle', function(model, spawnPos)
    local hash = joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    local vehicle = CreateVehicle(hash, spawnPos.x, spawnPos.y, spawnPos.z, spawnPos.w, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetVehicleColours(vehicle, 0, 0)
    SetModelAsNoLongerNeeded(hash)
    TriggerEvent('esv:client:notify', 'success', 'Dienstfahrzeug bereit')
end)

exports('IsOnDuty', function() return onDuty end)
exports('IsCuffed', function() return isCuffed end)
