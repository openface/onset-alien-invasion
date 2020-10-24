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

-- equips weapons (if slot is available)
function EquipWeapon(player, item)
  item_cfg = GetItemConfig(item)
  local weapon_slot = GetNextAvailableWeaponSlot(player)
  if weapon_slot ~= nil then
    Weapon.SetWeapon(player, item_cfg['weapon_id'], 100, true, weapon_slot, true)
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

-- returns the weapon slot that the given item is in (or nil)
function IsItemInWeaponSlot(player, item)
  item_cfg = GetItemConfig(item)
  for i = 1, 3 do
    local weapon_id,ammo = GetPlayerWeapon(player, i)
    if item_cfg['weapon_id'] == weapon_id then
      return i
    end
  end
end
