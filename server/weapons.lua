-- weapon handler
WeaponPatch = ImportPackage("Onset_Weapon_Patch")

-- replace all weapon slots for all players to fists
AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
        for i = 1, 3 do
            WeaponPatch.SetWeapon(player, 1, 0, true, i, true)
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

    local slot = EquipWeapon(player, item)
    if slot == nil then
        log.error("No available slot")
        return
    end

    local weapons = GetPlayerPropertyValue(player, "weapons")
    -- add new item to store
    table.insert(weapons, {
        item = item,
        type = item_cfg['type'],
        name = item_cfg['name'],
        modelid = item_cfg['modelid'],
        slot = slot
    })
    SetPlayerPropertyValue(player, "weapons", weapons)
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

-- equips weapon
-- returns slot or nil
function EquipWeapon(player, item)
    item_cfg = GetItemConfig(item)
    local slot = GetNextAvailableWeaponSlot(player)
    if slot == nil then
        return false
    else
        WeaponPatch.SetWeapon(player, item_cfg['weapon_id'], 100, true, slot, true)
        return slot
    end
end

-- returns the next available weapon slot
-- only checks slots 2-3 to leave 1 always for fists
function GetNextAvailableWeaponSlot(player)
    for i = 2, 3 do
        if (GetPlayerWeapon(player, i) == 1) then
            return i
        end
    end
end

-- switch to fists if weapon is equipped for given weapon/item
function UnequipWeapon(player, item)
    local item_cfg = GetItemConfig(item)
    for slot = 2, 3 do
        local weapon_id, ammo = GetPlayerWeapon(player, slot)
        if item_cfg['weapon_id'] == weapon_id then
            WeaponPatch.SetWeapon(player, 1, 0, true, slot, true)
        end
    end
end

-- if weapon is not 1, set weapon 1 to slot 1
function SwitchToFists(player)
  local wep = GetPlayerEquippedWeapon(player)
  if wep ~= 1 then
    WeaponPatch.SetWeapon(player, 1, 0, true, 1, true)
  end
end

