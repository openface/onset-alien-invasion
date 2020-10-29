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
  local slot = GetNextAvailableWeaponSlot(player)
  if slot ~= nil then
    Weapon.SetWeapon(player, item_cfg['weapon_id'], 100, true, slot, true)
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

-- check if weapon is equipped
function IsWeaponEquipped(player, item)
  local item_cfg = GetItemConfig(item)
  for slot = 1, 3 do
    local weapon_id,ammo = GetPlayerWeapon(player, slot)
    if item_cfg['weapon_id'] == weapon_id then
      return true
    end
  end
  return false
end

-- switch to fists if weapon is equipped
function UnequipWeapon(player, item)
  local item_cfg = GetItemConfig(item)
  for slot = 1, 3 do
    local weapon_id,ammo = GetPlayerWeapon(player, slot)
    if item_cfg['weapon_id'] == weapon_id then
      Weapon.SetWeapon(player, 1, 0, true, slot, true)
    end
  end
end
