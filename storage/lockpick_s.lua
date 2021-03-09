AddEvent("StartLockpick", function(player, ActiveProp, CurrentInHand)
    log.trace("StartLockpick", player, dump(ActiveProp), dump(CurrentInHand))

    local prop = GetObjectPropertyValue(ActiveProp.hit_object, "prop")
    if prop.options['locked'] then
        CallRemoteEvent(player, "ShowLockpick", ActiveProp.hit_object)
    else
        CallRemoteEvent(player, "ShowError", "This item is not locked!")
    end
end)