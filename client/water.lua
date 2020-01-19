local WaterTimer
local PlayerInWater = false

function HandlePlayerInWater()
    if PlayerInWater then
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