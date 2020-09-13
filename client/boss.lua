local BossUI
local MothershipSpawnSound
local MothershipSoundTimer

AddEvent("OnPackageStart", function()
    BossUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(BossUI, "http://asset/"..GetPackageName().."/client/ui/boss/boss.html")
    SetWebAlignment(BossUI, 0.0, 0.0)
    SetWebAnchors(BossUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(BossUI, WEB_HIDDEN)

    SetCloudDensity(1)
end)

AddEvent("OnObjectStreamIn", function(object)
    if GetObjectPropertyValue(object, "type") ~= "boss" then
        return
    end

    AddPlayerChat("The mothership has landed in your area!")

    EnableObjectHitEvents(object, true)
    local x,y,z = GetObjectLocation(object)

    MothershipSpawnSound = CreateSound3D("client/sounds/mothership.mp3", x, y, z, 100000.0)
    SetSoundVolume(MothershipSpawnSound, 2)

    MothershipSoundTimer = CreateTimer(function(x, y, z)
        if MothershipSpawnSound ~= nil then
            DestroySound(MothershipSpawnSound)
        end
        MothershipSpawnSound = CreateSound3D("client/sounds/mothership.mp3", x, y, z, 100000.0)
        SetSoundVolume(MothershipSpawnSound, 2)
    end, 35 * 1000, x, y, z)
end)

-- Boss is coming
AddRemoteEvent("PrespawnBoss", function()
    SetCloudDensity(4)
    SetPostEffect("ImageEffects", "VignetteIntensity", 1.5)
end)

-- Boss is leaving
AddRemoteEvent("DespawnBoss", function(boss)
    local x,y,z = GetObjectLocation(boss)

    MothershipFlybySound = CreateSound3D("client/sounds/mothership_flyby.mp3", x, y, z, 100000.0)
    SetSoundVolume(MothershipFlybySound, 1)

    Delay(5000, function()
        DestroySound(MothershipSpawnSound)
        DestroyTimer(MothershipSoundTimer)

        SetCloudDensity(1)
        SetPostEffect("ImageEffects", "VignetteIntensity", 0)

        ExecuteWebJS(BossUI, "HideBossHealth()")
        SetWebVisibility(BossUI, WEB_HIDDEN)

        AddPlayerChat("The mothership has left your area.")
    end)
end)

AddRemoteEvent("UpdateBossHealth", function(HealthPercentage)
    ExecuteWebJS(BossUI, "SetBossHealth("..HealthPercentage..")")
    SetWebVisibility(BossUI, WEB_VISIBLE)
end)

-- mothership hurts player
AddRemoteEvent("BossHurtPlayer", function()
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    ShowBlood()
    AddPlayerChat("You feel life leaving your body.")
end)
