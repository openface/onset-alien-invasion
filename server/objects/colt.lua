local Weapon = ImportPackage("Onset_Weapon_Patch")

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
    Weapon.SetWeapon(player, 3, 100, true, 2, true)
end)