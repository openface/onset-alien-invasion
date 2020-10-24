local Weapon = ImportPackage("Onset_Weapon_Patch")

local weapon_slot = 3

RegisterObject("uzi", {
    name = "UZI",
    type = 'weapon',
    modelid = 11, 
    max_carry = 1,
    recipe = {
        metal = 25,
        plastic = 10
    }
})

AddEvent("items:uzi:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 9, 100, true, weapon_slot, true)
end)

AddEvent("items:uzi:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
