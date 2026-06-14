local isDead = false
local deathTimer = 0
local lastDeath = 0
local canRespawn = false

CreateThread(function()
    while true do
        Wait(1000)
        if not ESV.CharacterLoaded then goto continue end

        local ped = PlayerPedId()

        if IsEntityDead(ped) and not isDead then
            isDead = true
            deathTimer = ESV.Config.DeathTimer
            canRespawn = false
            lastDeath = GetGameTimer()

            TriggerServerEvent('esv:server:setDead', true)
            TriggerEvent('esv:client:notify', 'error', 'Du bist am Boden! Warte auf den Rettungsdienst...')
            ESV.PlayerData.character.is_dead = true

            -- Ragdoll
            SetEntityInvincible(ped, true)
            Wait(2000)

            -- Respawn-Kamera
            local coords = GetEntityCoords(ped)
            DoScreenFadeOut(1000)
            Wait(1000)

            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
            SetEntityHealth(ped, 150)
            SetEntityInvincible(ped, false)
            ClearPedBloodDamage(ped)

            ESV.Functions.PlayAnim('dead', 'dead_a', -1, 1)

            DoScreenFadeIn(1000)
        end

        if isDead then
            deathTimer = deathTimer - 1

            if deathTimer <= 0 then
                canRespawn = true
            end

            if canRespawn then
                ESV.Functions.ShowHelpText("Druecke ~INPUT_CONTEXT~ fuer Krankenhaus-Respawn ($" .. ESV.Config.RespawnCost .. ")")
            else
                ESV.Functions.DrawText3D(
                    GetEntityCoords(ped).x,
                    GetEntityCoords(ped).y,
                    GetEntityCoords(ped).z + 1.0,
                    "~r~AM BODEN~w~ - Respawn in " .. deathTimer .. "s"
                )
            end

            if canRespawn and IsControlJustReleased(0, 38) then
                Respawn()
            end
        end

        ::continue::
    end
end)

function Respawn()
    if not isDead or not canRespawn then return end

    isDead = false
    canRespawn = false
    ESV.PlayerData.character.is_dead = false

    DoScreenFadeOut(1000)
    Wait(1000)

    local ped = PlayerPedId()
    local spawn = ESV.Config.RespawnLocation

    ClearPedTasksImmediately(ped)
    SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, false)
    SetEntityHeading(ped, spawn.w)
    NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)

    DoScreenFadeIn(1000)

    TriggerServerEvent('esv:server:respawn')
    TriggerEvent('esv:client:notify', 'info', 'Du wurdest im Krankenhaus behandelt.')
end

-- EMS-Wiederbelebung
RegisterNetEvent('esv:client:revive', function()
    if not isDead then return end

    isDead = false
    canRespawn = false
    ESV.PlayerData.character.is_dead = false

    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    NetworkResurrectLocalPlayer(GetEntityCoords(ped).x, GetEntityCoords(ped).y, GetEntityCoords(ped).z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)

    TriggerServerEvent('esv:server:setDead', false)
    TriggerEvent('esv:client:notify', 'success', 'Du wurdest wiederbelebt!')
end)

exports('IsDead', function() return isDead end)
