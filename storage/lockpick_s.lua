AddEvent("StartLockpick", function(player, ActiveProp, CurrentInHand)
    log.trace("StartLockpick", player, dump(ActiveProp), dump(CurrentInHand))

    local prop = GetObjectPropertyValue(ActiveProp.hit_object, "prop")
    if not prop.options['locked'] then
        CallEvent("OpenStorage", player, ActiveProp)
    else
        CallRemoteEvent(player, "ShowLockpick", ActiveProp.hit_object)
    end
end)