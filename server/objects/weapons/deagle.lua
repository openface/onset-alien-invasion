local Weapon = ImportPackage("Onset_Weapon_Patch")

RegisterObject("deagle", {
    name = "Deagle",
    type = 'weapon',
    modelid = 4, 
    max_carry = 2,
    recipe = {
        metal = 20,
        plastic = 10
    }
})

AddEvent("items:deagle:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 2, 100, true, 2, true)
end)