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

function AddWeapon(player, item)
    item_cfg = GetItemConfig(item)
    if not item_cfg then
        log.error("Invalid weapon " .. item)
        return
    end
    if item_cfg['type'] ~= 'weapon' then
        log.error('Invalid weapon type')
        return
    end

    local weapons = GetPlayerPropertyValue(player, "weapons")
    -- add new item to store
    table.insert(weapons, {
        item = item,
        type = item_cfg['type'],
        name = item_cfg['name'],
        modelid = item_cfg['modelid']
    })
    SetPlayerPropertyValue(player, "weapons", weapons)
    EquipWeapon(player, item)
    CallEvent("SyncInventory", player)
end

function RemoveWeapon(player, item)
    UnequipWeapon(player, item)
    local weapons = GetPlayerPropertyValue(player, "weapons")
    for i, _weapon in ipairs(weapons) do
        if _weapon['item'] == item then
            table.remove(weapons, i)
            break
        end
    end
    SetPlayerPropertyValue(player, "weapons", weapons)
    CallEvent("SyncInventory", player)
end

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
    return false
    --
    -- This does not currently work because it is possible for player
    -- to switch weapons and the inventory never gets sync'd.
    -- Need a OnPlayerWeaponSwitch event or similar
    --[[   local item_cfg = GetItemConfig(item)
  for slot = 1, 3 do
    local weapon_id,ammo = GetPlayerWeapon(player, slot)
    if item_cfg['weapon_id'] == weapon_id then
      return true
    end
  end
  return false
 ]]
end

-- switch to fists if weapon is equipped
function UnequipWeapon(player, item)
    local item_cfg = GetItemConfig(item)
    for slot = 1, 3 do
        local weapon_id, ammo = GetPlayerWeapon(player, slot)
        if item_cfg['weapon_id'] == weapon_id then
            Weapon.SetWeapon(player, 1, 0, true, slot, true)
        end
    end
end
