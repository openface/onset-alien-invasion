local weapon_slot = 3

RegisterObject("ak47", {
    name = "AK47",
    type = 'weapon',
    modelid = 14, 
    max_carry = 1,
    recipe = {
        metal = 25,
        plastic = 10
    }
})

AddEvent("items:ak47:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 12, 100, true, weapon_slot, true)
end)

AddEvent("items:ak47:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
