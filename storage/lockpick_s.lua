AddEvent("LockPickStorage", function(player, object)
    log.debug("call lockpick event")
    CallRemoteEvent("ShowLockpick", player, object)
end)