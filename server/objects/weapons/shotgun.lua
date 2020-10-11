local Weapon = ImportPackage("Onset_Weapon_Patch")

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
    Weapon.SetWeapon(player, 7, 100, true, 3, true)
end)