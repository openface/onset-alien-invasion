local weapon_slot = 2

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
    Weapon.SetWeapon(player, 5, 100, true, weapon_slot, true)
end)

AddEvent("items:beretta:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
