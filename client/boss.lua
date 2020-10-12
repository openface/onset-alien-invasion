local MothershipSpawnSound
local MothershipSoundTimer

AddEvent("OnPackageStart", function()
    SetCloudDensity(1)

    -- Load UFO from MothershipBoss.pak
    -- Thanks Voltaism!
    LoadPak("MothershipBoss", "/MothershipBoss/", "../../../OnsetModding/Plugins/MothershipBoss/Content/")    
  	ReplaceObjectModelMesh(91212, "/MothershipBoss/UFO")
end)

AddEvent("OnPackageStop", function()
    DestroySound(MothershipSpawnSound)
    DestroyTimer(MothershipSoundTimer)
end)

AddEvent("OnObjectStreamIn", function(object)
    if GetObjectPropertyValue(object, "type") ~= "boss" then
        return
    end

    AddPlayerChat("The mothership is approaching your area!")

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

AddEvent("OnObjectStreamOut", function (object)
    DespawnBoss(object)
end)

-- Boss is coming
AddRemoteEvent("SpawnBoss", function()
    SetCloudDensity(4)
    SetPostEffect("ImageEffects", "VignetteIntensity", 1.5)
end)

-- Boss is leaving
function DespawnBoss(boss)
    local x,y,z = GetObjectLocation(boss)
    if x == nil then return end

    MothershipFlybySound = CreateSound3D("client/sounds/mothership_flyby.mp3", x, y, z, 100000.0)
    SetSoundVolume(MothershipFlybySound, 1)

    Delay(5000, function()
        DestroySound(MothershipSpawnSound)
        DestroyTimer(MothershipSoundTimer)

        -- Removes the Boss Health from the HUD
        CallEvent("SetBossHealth", 0)

        SetCloudDensity(1)
        SetPostEffect("ImageEffects", "VignetteIntensity", 0)

        AddPlayerChat("The mothership has left your area.")
    end)
end
AddRemoteEvent("DespawnBoss", DespawnBoss)

-- mothership hurts player
AddRemoteEvent("BossHurtPlayer", function()
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    ShowBlood()
    AddPlayerChat("You feel life leaving your body.")
end)
