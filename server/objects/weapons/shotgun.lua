local Weapon = ImportPackage("Onset_Weapon_Patch")

local weapon_slot = 3

RegisterObject("shotgun", {
    name = "Shotgun",
    type = 'weapon',
    modelid = 9, 
    max_carry = 1,
    recipe = {
        metal = 25,
        plastic = 10
    }
})

AddEvent("items:shotgun:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 7, 100, true, weapon_slot, true)
end)

AddEvent("items:shotgun:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
