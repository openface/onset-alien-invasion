local BossUI
local DefaultWeather = 0
local DefaultFogDensity = 1.5
local MothershipSpawnSound
local MothershipSoundTimer

AddEvent("OnPackageStart", function()
    BossUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(BossUI, "http://asset/"..GetPackageName().."/client/ui/boss/boss.html")
    SetWebAlignment(BossUI, 0.0, 0.0)
    SetWebAnchors(BossUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(BossUI, WEB_HIDDEN)

    SetWeather(DefaultWeather)
    SetFogDensity(DefaultFogDensity)
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

    SetWeather(10)
    SetFogDensity(4.0)
    SetPostEffect("ImageEffects", "VignetteIntensity", 1)
end)

AddRemoteEvent("DespawnBoss", function()
    if MothershipSpawnSound ~= nil then
        DestroySound(MothershipSpawnSound)
    end
    if MothershipSoundTimer ~= nil then
        DestroyTimer(MothershipSoundTimer)
    end

    SetWeather(DefaultWeather)
    SetFogDensity(DefaultFogDensity)
    SetPostEffect("ImageEffects", "VignetteIntensity", 0)

    ExecuteWebJS(BossUI, "HideBossHealth()")
    SetWebVisibility(BossUI, WEB_HIDDEN)
end)

AddRemoteEvent("UpdateBossHealth", function(HealthPercentage)
    ExecuteWebJS(BossUI, "SetBossHealth("..HealthPercentage..")")
    SetWebVisibility(BossUI, WEB_VISIBLE)
end)

-- mothership hurts player
AddRemoteEvent("BossHurtPlayer", function()
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    AddPlayerChat("You feel life leaving your body.")
end)
