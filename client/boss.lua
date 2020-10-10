local BossUI
local MothershipSpawnSound
local MothershipSoundTimer

AddEvent("OnPackageStart", function()
    SetCloudDensity(1)

    -- Load UFO from MothershipBoss.pak
    -- Thanks Voltaism!
    LoadPak("MothershipBoss", "/MothershipBoss/", "../../../OnsetModding/Plugins/MothershipBoss/Content/")    
  	ReplaceObjectModelMesh(91212, "/MothershipBoss/UFO")
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

        AddPlayerChat("The mothership has left your area.")
    end)
end)

-- mothership hurts player
AddRemoteEvent("BossHurtPlayer", function()
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    ShowBlood()
    AddPlayerChat("You feel life leaving your body.")
end)
