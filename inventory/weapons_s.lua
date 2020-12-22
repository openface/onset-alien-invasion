WeaponPatch = ImportPackage("Onset_Weapon_Patch")

-- weapon map
WeaponsConfig = {
    ["ak47"] = { name = "AK47", weapon_id = 12, modelid = 14 },
    ["ak47g"] = { name = "AK47 (Gold)", weapon_id = 13, modelid = 15 },
    ["auto_shotgun"] = { name = "Auto Shotgun", weapon_id = 6, modelid = 8 },
    ["beretta"] = { name = "Beretta", weapon_id = 5, modelid = 7 },
    ["colt"] = { name = "Colt", weapon_id = 3, modelid = 5 },
    ["deagle"] = { name = "Deagle", weapon_id = 2, modelid = 4 },
    ["glock"] = { name = "Glock", weapon_id = 4, modelid = 6 },
    ["m16a4"] = { name = "M16A4", weapon_id = 11, modelid = 13 },
    ["mp5"] = { name = "MP5", weapon_id = 8, modelid = 10 },
    ["shotgun"] = { name = "Shotgun", weapon_id = 7, modelid = 9 },
    ["ump"] = { name = "UMP", weapon_id = 10, modelid = 12 },
    ["uzi"] = { name = "UZI", weapon_id = 9, modelid = 11 }
}

-- replace all weapon slots for all players to fists
AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
        for i = 1, 3 do
            WeaponPatch.SetWeapon(player, 1, 0, true, i, true)
        end
    end
end)

function SyncWeapons(player)
    local weapons = PlayerData[player].weapons
    for _,w in pairs(weapons) do
        WeaponPatch.SetWeapon(player, WeaponsConfig[w['item']].weapon_id, 100, false, w['slot'], true)
    end
end

-- add weapon to player
function AddWeapon(player, item)
    item_cfg = WeaponsConfig[item]
    if not item_cfg then
        log.error("Invalid weapon " .. item)
        return
    end

    local slot = EquipWeapon(player, item)
    if slot == nil then
        log.error("No available slot")
        return
    end

    local weapons = PlayerData[player].weapons
    -- add new item to store
    table.insert(weapons, {
        item = item,
        type = item_cfg['type'],
        name = item_cfg['name'],
        modelid = item_cfg['modelid'],
        slot = slot
    })
    PlayerData[player].weapons = weapons
    CallEvent("SyncInventory", player)
end

function RemoveWeapon(player, item)
    UnequipWeapon(player, item)
    local weapons = PlayerData[player].weapons
    for i, _weapon in ipairs(weapons) do
        if _weapon['item'] == item then
            table.remove(weapons, i)
            break
        end
    end
    PlayerData[player].weapons = weapons
    CallEvent("SyncInventory", player)
end

-- equips weapon
-- returns slot or nil
function EquipWeapon(player, item)
    local slot = GetNextAvailableWeaponSlot(player)
    if slot ~= nil then
        WeaponPatch.SetWeapon(player, WeaponsConfig[item].weapon_id, 100, true, slot, true)
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
    for slot = 2, 3 do
        local weapon_id, ammo = GetPlayerWeapon(player, slot)
        if WeaponsConfig[item].weapon_id == weapon_id then
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

