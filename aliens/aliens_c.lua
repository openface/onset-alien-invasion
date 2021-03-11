local AmbientSound
local AmbientSoundTimer
local SpottedBy = {}

AddEvent("OnPackageStop", function()
    DestroySound(AmbientSound)
    DestroyTimer(AmbientSoundTimer)
end)

AddEvent("OnPackageStart", function()
    AmbientSound = CreateSound("client/sounds/chased.mp3", true)
    SetSoundVolume(AmbientSound, 0.0)

    AmbientSoundTimer = CreateTimer(function()
        local targetted = false
        for k, v in pairs(GetStreamedNPC()) do
            if GetNPCPropertyValue(v, 'target') == GetPlayerId() then
                targetted = true
            end
        end
        if targetted == false then
            SetSafeAmbience()
        end
    end, 10000)
end)

AddEvent("OnNPCStreamIn", function(npc)
    local type = GetNPCPropertyValue(npc, "type")

    if (type == "alien") then
        ApplyAlienSkin(npc)
    end
end)

function ApplyAlienSkin(npc)
    SetNPCClothingPreset(npc, Random(23, 24))
    --SetNPCOutline(npc, true)
end

AddRemoteEvent("AlienAttacking", function(npc)
    if next(SpottedBy) == nil then
        ShowMessage("You have been spotted!")
        SetSoundVolume(AmbientSound, 0.5)
    end

    SpottedBy[npc] = true

    --debug("SpottedBy:"..dump(SpottedBy))

    -- alien attack sound
    Delay(Random(1,2000), function()
        local x, y, z = GetNPCLocation(npc)
        if x and y and z then
            SetSoundVolume(CreateSound3D("client/sounds/alien.wav", x, y, z, 6000.0), 0.6)
        end
    end)
end)

function SetSafeAmbience()
    --SetSoundFadeOut(AmbientSound, 5000, 0.0)
    SetSoundVolume(AmbientSound, 0.0)
end

AddRemoteEvent('AlienNoLongerAttacking', function(npc)
    SpottedBy[npc] = nil

    --debug("SpottedBy:"..dump(SpottedBy))

    if next(SpottedBy) == nil then
        ShowMessage("You are safe for now")
        SetSafeAmbience()
    end
end)

AddEvent("OnPlayerSpawn", function()
    SetSoundVolume(AmbientSound, 0.0)
end)
