local weapon_slot = 2

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
    Weapon.SetWeapon(player, 2, 100, true, weapon_slot, true)
end)

AddEvent("items:deagle:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
