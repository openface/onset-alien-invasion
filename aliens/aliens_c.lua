local AmbientSound
local AttackSound
local AmbientSoundTimer

AddEvent("OnPackageStop", function()
    DestroySound(AmbientSound)

    if AttackSound ~= nil then
        DestroySound(AttackSound)
    end

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
    SetNPCOutline(npc, true)
end

AddRemoteEvent("AlienAttacking", function(npc)
    SetSoundVolume(AmbientSound, 0.5)
    ShowMessage("You have been spotted!")

    -- alien attack sound
    if AttackSound == nil then
        local x, y, z = GetNPCLocation(npc)
        if x and y and z then
            AttackSound = CreateSound3D("client/sounds/alien.wav", x, y, z, 6000.0)
            SetSoundVolume(AttackSound, 0.6)
        end
    end
end)

function SetSafeAmbience()
    --SetSoundFadeOut(AmbientSound, 1000, 0.0)
    SetSoundVolume(AmbientSound, 0.0)

    if AttackSound ~= nil then
        DestroySound(AttackSound)
    end
end

AddRemoteEvent('AlienNoLongerAttacking', function()
    ShowMessage("You are safe for now.")
    SetSafeAmbience()
end)

AddRemoteEvent("OnAlienHit", function()
    SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    InvokeDamageFX(1000)
end)

AddEvent("OnPlayerSpawn", function()
    SetSoundVolume(AmbientSound, 0.0)
end)
