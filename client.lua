
function OnPlayerSpawn()
    StartCameraFade(1.0, 0.0, 10.0, "#000")
    local player = GetPlayerId()
    SetPlayerClothingPreset(player, 25)
end
AddEvent('OnPlayerSpawn', OnPlayerSpawn)


AddEvent("OnNPCStreamIn", function(npc)
    local clothing = GetNPCPropertyValue(npc, 'clothing')
    SetNPCClothingPreset(npc, clothing)
end)

AddRemoteEvent('AlienAttacking', function(npc)
    AddPlayerChat('You are being attacked by an alien... RUN!')

    local x, y, z = GetNPCLocation(npc)
    AttackSound = CreateSound3D("sounds/alien.wav", x, y, z, 3000.0)
    SetSoundVolume(AttackSound, 1)
end)

AddRemoteEvent('AlienNoLongerAttacking', function(npc)
    AddPlayerChat('You are safe for now.')
end)

AddRemoteEvent('HealthPickup', function()
    HealthPickupSound = CreateSound("sounds/health_pickup.wav")
    SetSoundVolume(HealthPickupSound, 1)
end)
