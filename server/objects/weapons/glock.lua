local Weapon = ImportPackage("Onset_Weapon_Patch")

RegisterObject("glock", {
    name = "Glock",
    type = 'weapon',
    modelid = 6, 
    max_carry = 2,
    recipe = {
        metal = 20,
        plastic = 10
    }
})

AddEvent("items:glock:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 4, 100, true, 2, true)
end)