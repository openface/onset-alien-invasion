local Weapon = ImportPackage("Onset_Weapon_Patch")

local weapon_slot = 2

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
    Weapon.SetWeapon(player, 4, 100, true, weapon_slot, true)
end)

AddEvent("items:glock:drop", function(player, object)
    print("dropping weapon",weapon_slot)
    Weapon.SetWeapon(player, 1, 0, true, weapon_slot, true)
end)
