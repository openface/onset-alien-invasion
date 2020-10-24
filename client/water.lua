local WaterTimer
local PlayerInWater = false

AddEvent("OnPlayerSpawn", function()
    PlayerInWater = false

    SetOceanColor("0x0e7500", "0x0e7500", "0x0e7500", "0x0e7500", "0x0e7500")
end)


function HandlePlayerInWater()
    if PlayerInWater and IsPlayerDead(GetPlayerId()) ~= true then
        CallRemoteEvent("HandlePlayerInWater")        
        InvokeDamageFX(1000)
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