ItemConfig["screwdriver"] = {
    name = "Screwdriver",
    type = 'usable',
    category = "Supplies",
    modelid = 20100,
    image = "lockpick/screwdriver.jpg",
    max_carry = 2,
    price = 20,
    interactions = {
        picklock = {
            animation = { name = "LOCKDOOR", duration = "3500" },
            use_label = "Pick Lock",
            event = "StartLockpick"
        }
    },
    attachment = { 
      x = -10.5, 
      y = 2, 
      z = 21.4, 
      rx = -175.1, 
      ry = 79.8, 
      rz = 0, 
      bone = "hand_r"
    },
    scale = {
        x = 0.4,
        y = 0.4,
        z = 0.4
    },
}

AddEvent("StartLockpick", function(player, ActiveProp, CurrentInHand)
    log.trace("StartLockpick", player, dump(ActiveProp), dump(CurrentInHand))

    local prop = GetObjectPropertyValue(ActiveProp.hit_object, "prop")
    if prop.options['locked'] then
        CallRemoteEvent(player, "ShowLockpick", ActiveProp.hit_object)
    else
        CallRemoteEvent(player, "ShowError", "This item is not locked!")
    end
end)