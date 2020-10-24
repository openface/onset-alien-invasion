-- weapon handler
Weapon = ImportPackage("Onset_Weapon_Patch")

-- replace all weapon slots for all players to fists
AddEvent("OnPackageStop", function()
  for _, player in pairs(GetAllPlayers()) do
    for i = 1, 3 do
      Weapon.SetWeapon(player, 1, 0, true, i, true)
    end
  end
end)

-- equips weapons
function EquipWeapon(player, item, force)
  local weapon_slot = GetNextAvailableWeaponSlot(player)
  if weapon_slot ~= nil then
    Weapon.SetWeapon(player, item_cfg['weapon_id'], 100, true, weapon_slot, true)
  elseif force == true then
    -- if forced, pick slot 1 if no slots are available
    Weapon.SetWeapon(player, item_cfg['weapon_id'], 100, true, 1, true)
  end
end

-- returns the next available weapon slot
function GetNextAvailableWeaponSlot(player)
  for i = 1, 3 do
    if (GetPlayerWeapon(player, i) == 1) then
      return i
    end
  end
end
