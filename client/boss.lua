local BossUI

AddEvent("OnPackageStart", function()
    BossUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(BossUI, "http://asset/"..GetPackageName().."/client/ui/boss/boss.html")
    SetWebAlignment(BossUI, 0.0, 0.0)
    SetWebAnchors(BossUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(BossUI, WEB_HIDDEN)
end)

AddEvent("OnObjectStreamIn", function(object)
    if GetObjectPropertyValue(object, "type") == "boss" then
        AddPlayerChat("The mothership is in your area! Run or fight!")
        

        local x,y,z = GetObjectLocation(object)
        
        local MothershipSpawnSound = CreateSound3D("client/sounds/mothership.mp3", x, y, z, 100000.0)
        SetSoundVolume(MothershipSpawnSound, 1)

        CreateCountTimer(function(x, y, z)
            local laserSound = CreateSound3D("client/sounds/laser.mp3", x, y, z, 100000.0)
            SetSoundVolume(laserSound, 0.7)
        end, 2500, 14, x, y, z)

        SetSkyLightIntensity(1)
        SetSunShine(1)
        SetSunLightIntensity(1)
        SetFogDensity(4)
        SetPostEffect("ImageEffects", "VignetteIntensity", 1)

        EnableObjectHitEvents(object, true)
        --SetObjectEmissiveColor(object, "0x39ff14", 1)
    end
end)

AddRemoteEvent("DespawnBoss", function()
    SetSkyLightIntensity(4.0)
    SetSunShine(15)
    SetSunLightIntensity(4.0)
    SetFogDensity(0)
    SetPostEffect("ImageEffects", "VignetteIntensity", 0)

    ExecuteWebJS(BossUI, "HideBossHealth()")
    SetWebVisibility(BossUI, WEB_HIDDEN)
end)

AddRemoteEvent("UpdateBossHealth", function(BossHealth, BossInitialHealth)
    ExecuteWebJS(BossUI, "SetBossHealth("..BossHealth..", "..BossInitialHealth..")")
    SetWebVisibility(BossUI, WEB_VISIBLE)
end)

AddRemoteEvent("HurtPlayer", function()
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    AddPlayerChat("You feel life leaving your body.")
end)