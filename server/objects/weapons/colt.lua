local Weapon = ImportPackage("Onset_Weapon_Patch")

local weapon_slot = 2

RegisterObject("colt", {
    name = "Colt",
    type = 'weapon',
    modelid = 5, 
    max_carry = 2,
    recipe = {
        metal = 20,
        plastic = 10
    }
})

AddEvent("items:colt:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 3, 100, true, weapon_slot, true)
end)

AddEvent("items:colt:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
