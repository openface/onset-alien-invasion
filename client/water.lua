local WaterTimer
local PlayerInWater = false

AddEvent("OnPlayerSpawn", function()
    PlayerInWater = false

    SetOceanColor("0x3a0e0e", "0x4a1111", "0x630c0c", "0x630c0c", "0x3a0e0e")
end)


function HandlePlayerInWater()
    if PlayerInWater and IsPlayerDead(GetPlayerId()) ~= true then
        CallRemoteEvent("HandlePlayerInWater")        
        SetSoundVolume(CreateSound("client/sounds/pain.mp3"), 1)
    end
end

AddEvent("OnPlayerEnterWater", function()
    PlayerInWater = true
    WaterTimer = CreateTimer(HandlePlayerInWater, 3000)
end)

AddEvent("OnPlayerLeaveWater", function()
    PlayerInWater = false
    DestroyTimer(WaterTimer)
end)