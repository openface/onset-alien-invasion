AddEvent("LockPickStorage", function(player, object)
    CallRemoteEvent(player, "ShowLockpick", object)
end)