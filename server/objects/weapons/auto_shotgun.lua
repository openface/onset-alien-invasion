local Weapon = ImportPackage("Onset_Weapon_Patch")

local weapon_slot = 3

RegisterObject("auto_shotgun", {
    name = "Auto Shotgun",
    type = 'weapon',
    modelid = 8, 
    max_carry = 1,
    recipe = {
        metal = 25,
        plastic = 10
    }
})

AddEvent("items:auto_shotgun:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 6, 100, true, weapon_slot, true)
end)

AddEvent("items:auto_shotgun:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
