local CurrentTime
local TimeTimer

AddEvent("OnPackageStart", function()
    CurrentTime = 10 -- server start time

    TimeTimer = CreateTimer(function()
        CurrentTime = CurrentTime + 0.20
        if CurrentTime > 24 then
            CurrentTime = 0
        end
        SyncTime()
    end, 60 * 1000)
end)

AddEvent("OnPackageStop", function()
    DestroyTimer(TimeTimer)
end)

function SyncTime()
    -- log.debug("Time is now "..CurrentTime)
    BroadcastRemoteEvent("ClientSetTime", CurrentTime)
end
AddEvent("OnPlayerJoin", SyncTime)
