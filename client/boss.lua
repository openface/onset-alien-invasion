local MothershipSpawnSound

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

    SetCloudDensity(4)
    SetPostEffect("ImageEffects", "VignetteIntensity", 1.5)

    if MothershipSpawnSound ~= nil then
      DestroySound(MothershipSpawnSound)
    end

    local x, y, z = GetObjectLocation(object)
    MothershipSpawnSound = CreateSound3D("client/sounds/mothership.mp3", x, y, z, 100000.0, true)
    SetSoundVolume(MothershipSpawnSound, 1)
end)

-- Boss is leaving
AddRemoteEvent("DespawnBoss", function(boss)
    local x, y, z = GetObjectLocation(boss)
    if x == nil or y == nil or z == nil then
        -- boss is no longer streamed
    else
        MothershipFlybySound = CreateSound3D("client/sounds/mothership_flyby.mp3", x, y, z, 100000.0)
        SetSoundVolume(MothershipFlybySound, 1)
    end

    Delay(5000, function()
        DestroySound(MothershipSpawnSound)

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
