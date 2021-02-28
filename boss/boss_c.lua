local MothershipSpawnSound
local BossLocation

LoadPak("Mothership", "/Mothership/", "../../../OnsetModding/Plugins/Mothership/Content/")
ReplaceObjectModelMesh(91212, "/Mothership/Meshes/SM_AlienMothershipZ")

AddEvent("OnPackageStart", function()
    SetCloudDensity(1)
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

    EnableObjectHitEvents(object, true)

    local x, y, z = GetObjectLocation(object)
    BossLocation = { x = x, y = y, z = z }

    SetCloudDensity(4)
    SetPostEffect("ImageEffects", "VignetteIntensity", 1)

    if MothershipSpawnSound ~= nil then
        DestroySound(MothershipSpawnSound)
    end

    if BossLocation ~= nil then
        MothershipSpawnSound = CreateSound3D("client/sounds/mothership.mp3", BossLocation.x, BossLocation.y, BossLocation.z, 50000.0, true)
        SetSoundVolume(MothershipSpawnSound, 1)
    end

    Delay(1000, function()
        SetSoundVolume(CreateSound3D("client/sounds/mothership_enter.mp3", x, y, z, 50000.0), 1.0)
    end)
end)

-- Boss is leaving
AddRemoteEvent("DespawnBoss", function(boss)
    MothershipFlybySound = CreateSound3D("client/sounds/mothership_flyby.mp3", BossLocation.x, BossLocation.y, BossLocation.z, 100000.0)
    SetSoundVolume(MothershipFlybySound, 1)

    if MothershipSpawnSound ~= nil then
      DestroySound(MothershipSpawnSound)
    end

    BossLocation = nil

    Delay(5000, function()
        AddPlayerChat("The mothership has left for now...")

        SetCloudDensity(1)
        SetPostEffect("ImageEffects", "VignetteIntensity", 0)

        -- Removes the Boss Health from the HUD
        CallEvent("SetBossHealth", 0)
    end)
end)
