local MothershipSpawnSound
local BossLocation

AddEvent("OnPackageStart", function()
    SetCloudDensity(1)

    -- Load UFO from MothershipBoss.pak
    -- Thanks Voltaism!
    LoadPak("MothershipBoss", "/MothershipBoss/", "../../../OnsetModding/Plugins/MothershipBoss/Content/")
    ReplaceObjectModelMesh(91212, "/MothershipBoss/UFO")
end)

AddEvent("OnPackageStop", function()
    if MothershipSpawnSound ~= nil then
        DestroySound(MothershipSpawnSound)
    end
end)

AddEvent("OnObjectStreamIn", function(object)
    if GetObjectPropertyValue(object, "type") ~= "boss" then
        return
    end

    AddPlayerChat("The mothership has invaded your area!")

    EnableObjectHitEvents(object, true)

    local x, y, z = GetObjectLocation(object)
    BossLocation = { x = x, y = y, z = z }

    SetSoundVolume(CreateSound3D("client/sounds/mothership_enter.mp3", x, y, z, 100000.0), 1.0)

    Delay(6000, function()
        if MothershipSpawnSound ~= nil then
            DestroySound(MothershipSpawnSound)
        end

        SetCloudDensity(4)
        SetPostEffect("ImageEffects", "VignetteIntensity", 1)

        MothershipSpawnSound = CreateSound3D("client/sounds/mothership.mp3", BossLocation.x, BossLocation.y, BossLocation.z, 100000.0, true)
        SetSoundVolume(MothershipSpawnSound, 1)
    end)
end)

-- Boss is leaving
AddRemoteEvent("DespawnBoss", function(boss)
    MothershipFlybySound = CreateSound3D("client/sounds/mothership_flyby.mp3", BossLocation.x, BossLocation.y, BossLocation.z, 100000.0)
    SetSoundVolume(MothershipFlybySound, 1)

    DestroySound(MothershipSpawnSound)
    BossLocation = nil

    Delay(5000, function()
        AddPlayerChat("The mothership has left for now...")

        SetCloudDensity(1)
        SetPostEffect("ImageEffects", "VignetteIntensity", 0)

        -- Removes the Boss Health from the HUD
        CallEvent("SetBossHealth", 0)
    end)
end)

-- mothership hurts player
AddRemoteEvent("BossHurtPlayer", function()
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    InvokeDamageFX(1000)
end)
