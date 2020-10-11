local Weapon = ImportPackage("Onset_Weapon_Patch")

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
    Weapon.SetWeapon(player, 6, 100, true, 3, true)
end)