local time = 8

function SyncTime()
    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "ClientSetTime", time)
    end
end
AddEvent("OnPlayerJoin", SyncTime)

CreateTimer(function()
    time = time + 0.10
    if time > 24 then
        time = 0
    end
    --print("Time is now "..time)
    SyncTime()
end, 60 * 1000)