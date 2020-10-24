local weapon_slot = 3

RegisterObject("m16a4", {
    name = "M16A4",
    type = 'weapon',
    modelid = 13, 
    max_carry = 1,
    recipe = {
        metal = 25,
        plastic = 10
    }
})

AddEvent("items:m16a4:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 11, 100, true, weapon_slot, true)
end)

AddEvent("items:m16a4:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
