ESV = ESV or {}
ESV.PlayerData = {}
ESV.IsReady = false
ESV.CharacterLoaded = false

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    TriggerServerEvent('esv:server:playerLoaded')
end)

RegisterNetEvent('esv:client:playerReady', function(playerId, adminLevel)
    ESV.PlayerData.playerId = playerId
    ESV.PlayerData.adminLevel = adminLevel
    ESV.IsReady = true
end)

RegisterNetEvent('esv:client:characterLoaded', function(charData, jobInfo)
    ESV.PlayerData.character = charData
    ESV.PlayerData.job = jobInfo
    ESV.CharacterLoaded = true

    local pos = charData.position
    if pos then
        SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z, false, false, false, false)
        SetEntityHeading(PlayerPedId(), pos.h or 0.0)
    else
        local spawn = ESV.Config.DefaultSpawn
        SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z, false, false, false, false)
        SetEntityHeading(PlayerPedId(), spawn.w)
    end

    if charData.health then
        SetEntityHealth(PlayerPedId(), charData.health)
    end
    if charData.armor then
        SetPedArmour(PlayerPedId(), charData.armor)
    end

    if charData.skin then
        ESV.Functions.ApplySkin(charData.skin)
    end

    DoScreenFadeIn(1000)
    TriggerEvent('esv:client:spawnComplete')
end)

RegisterNetEvent('esv:client:updateMoney', function(moneyType, amount)
    if not ESV.PlayerData.character then return end
    ESV.PlayerData.character[moneyType] = amount
    TriggerEvent('esv:client:moneyChanged', moneyType, amount)
end)

RegisterNetEvent('esv:client:jobUpdated', function(jobName, jobLabel, grade, gradeLabel)
    if not ESV.PlayerData.character then return end
    ESV.PlayerData.character.job = jobName
    ESV.PlayerData.character.job_grade = grade
    ESV.PlayerData.job = {
        job = jobName,
        jobLabel = jobLabel,
        grade = grade,
        gradeLabel = gradeLabel,
    }
    TriggerEvent('esv:client:jobChanged', jobName, jobLabel, grade, gradeLabel)
end)

-- Disable default GTA features for RP
CreateThread(function()
    while true do
        Wait(0)
        if ESV.CharacterLoaded then
            DisableControlAction(0, 37, true)  -- Select Weapon (Tab)
            SetPedCanSwitchWeapon(PlayerPedId(), false)

            -- Disable wanted level
            SetMaxWantedLevel(0)
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)

            -- Disable health regen
            SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)

            -- Disable ambient sounds
            if not IsPlayerSwitchInProgress() then
                SetRadarBigmapEnabled(false, false)
            end
        else
            Wait(500)
        end
    end
end)

-- Disable PvP (managed by admin settings)
CreateThread(function()
    while true do
        Wait(1000)
        if ESV.CharacterLoaded then
            NetworkSetFriendlyFireOption(true)
            SetCanAttackFriendly(PlayerPedId(), true, false)
        end
    end
end)
