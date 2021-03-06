ItemConfig["screwdriver"] = {
    name = "Screwdriver",
    type = 'usable',
    category = "Supplies",
    modelid = 20100,
    image = "lockpick/screwdriver.jpg",
    max_carry = 2,
    use_label = "Screw",
    price = 20,
    interaction = {
        animation = { name = "LOCKDOOR" },
        use_label = "Screw",
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

AddEvent("items:screwdriver:use", function(player, object, ActiveProp)
    local prop = GetObjectPropertyValue(ActiveProp.hit_object, "prop")
    if prop.event ~= "OpenStorage" then
        CallRemoteEvent(player, "ShowError", "This cannot be lockpicked!")
        return
    end
    if not prop.options['locked'] then
        CallRemoteEvent(player, "ShowError", "Not locked!")
        CallEvent("OpenStorage", player, ActiveProp)
        return
    end
    CallRemoteEvent(player, "ShowLockpick", ActiveProp.hit_object)
end)