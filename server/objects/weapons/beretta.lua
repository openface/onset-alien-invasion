local Weapon = ImportPackage("Onset_Weapon_Patch")

RegisterObject("beretta", {
    name = "Beretta",
    type = 'weapon',
    modelid = 7, 
    max_carry = 2,
    recipe = {
        metal = 20,
        plastic = 10
    }
})

AddEvent("items:beretta:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 5, 100, true, 2, true)
end)