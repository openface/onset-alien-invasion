local CurrentTime = 10 -- server start time
local TimeTimer

function SyncTime()
    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "ClientSetTime", time)
    end
end
AddEvent("OnPlayerJoin", SyncTime)

AddEvent("OnPackageStart", function()
  TimeTimer = CreateTimer(function()
    CurrentTime = CurrentTime + 0.20
      if CurrentTime > 24 then
        CurrentTime = 0
      end
      --log.debug("Time is now "..CurrentTime)
      SyncTime()
  end, 60 * 1000)
end)

AddEvent("OnPackageStop", function()
  DestroyTimer(TimeTimer)
end)