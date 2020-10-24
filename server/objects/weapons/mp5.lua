local weapon_slot = 3

RegisterObject("mp5", {
    name = "MP5",
    type = 'weapon',
    modelid = 10, 
    max_carry = 1,
    recipe = {
        metal = 25,
        plastic = 10
    }
})

AddEvent("items:mp5:pickup", function(player, pickup)
    Weapon.SetWeapon(player, 8, 100, true, weapon_slot, true)
end)

AddEvent("items:mp5:drop", function(player, object)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
