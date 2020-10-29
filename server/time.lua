local time = 10 -- server start time

function SyncTime()
    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "ClientSetTime", time)
    end
end
AddEvent("OnPlayerJoin", SyncTime)

CreateTimer(function()
    time = time + 0.20
    if time > 24 then
        time = 0
    end
    --log.debug("Time is now "..time)
    SyncTime()
end, 60 * 1000)
