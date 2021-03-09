ItemConfig["lighter"] = {
    name = "Lighter",
    type = 'usable',
    category = "Supplies",
    recipe = nil,
    interaction = {
        sound = "sounds/zippo.wav",
        animation = {
            id = 924,
            duration = 10000
        },
    },
    modelid = 20024,
    max_use = 20,
    image = "survival/SM_Lighter.png",
    max_carry = 1,
    price = 150,
    attachment = {
        x = -10.5,
        y = 5.5,
        z = 0,
        rx = 0,
        ry = 0,
        rz = 0,
        bone = "hand_r"
    },
}

AddEvent("items:lighter:use", function(player, object, ActiveProp)
    if ActiveProp.modelid ~= "20007" then
        return
    end
    CallEvent("IgniteCampfire", player, ActiveProp)
end)
