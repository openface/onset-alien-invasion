local WaterTimer
local PlayerInWater = false

AddEvent("OnPlayerSpawn", function()
    PlayerInWater = false

    SetOceanColor("0x8a0303", "0x9b0000", "0x7c0000", "0x850101", "0x6a0101")
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