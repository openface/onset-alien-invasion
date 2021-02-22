WeaponPatch = ImportPackage("Onset_Weapon_Patch")
if WeaponPatch == nil then
    print("Missing Onset_Weapon_Patch package!")
    ServerExit()
end

-- weapon map
--[[ WeaponsConfig = {
    ["ak47"] = {
        name = "AK47",
        weapon_id = 12,
        modelid = 14,
        mag_item = "rifle_mag",
        mag_size = 30
    },
    ["ak47g"] = {
        name = "AK47 (Gold)",
        weapon_id = 13,
        modelid = 15,
        mag_size = 30
    },
    ["auto_shotgun"] = {
        name = "Auto Shotgun",
        weapon_id = 6,
        modelid = 8
    },
    ["beretta"] = {
        name = "Beretta",
        weapon_id = 5,
        modelid = 7
    },
    ["colt"] = {
        name = "Colt",
        weapon_id = 3,
        modelid = 5
    },
    ["deagle"] = {
        name = "Deagle",
        weapon_id = 2,
        modelid = 4
    },
    ["glock"] = {
        name = "Glock",
        weapon_id = 4,
        modelid = 6
    },
    ["m16a4"] = {
        name = "M16A4",
        weapon_id = 11,
        modelid = 13
    },
    ["mp5"] = {
        name = "MP5",
        weapon_id = 8,
        modelid = 10
    },
    ["shotgun"] = {
        name = "Shotgun",
        weapon_id = 7,
        modelid = 9
    },
    ["ump"] = {
        name = "UMP",
        weapon_id = 10,
        modelid = 12
    },
    ["uzi"] = {
        name = "UZI",
        weapon_id = 9,
        modelid = 11
    }
}
 ]]
-- replace all weapon slots for all players to fists
AddEvent("OnPackageStop", function()
    for _, player in pairs(GetAllPlayers()) do
        ClearAllWeaponSlots(player)
    end
end)

-- sets weapons slots from inventory data
-- if we find a weapon in inventory that is supposed to be equipped, equip it
function SyncWeaponSlotsFromInventory(player)
    local inventory = PlayerData[player].inventory
    for i, inventory_item in ipairs(inventory) do
        if inventory_item.type == 'weapon' and GetEquippedObject(player, inventory_item.uuid) then
            EquipWeaponFromInventory(player, inventory_item.uuid, false)
            return
        end
    end
end

function ClearAllWeaponSlots(player)
    for i = 1, 3 do
        WeaponPatch.SetWeapon(player, 1, 0, true, i, true)
    end
end

-- equips weapon by item and adds to weapon slot
function EquipWeaponFromInventory(player, uuid, equip)
    log.trace("EquipWeaponFromInventory",uuid,equip)
    local inventory = PlayerData[player].inventory
    local slot
    for i, inventory_item in ipairs(inventory) do
        log.debug(dump(inventory_item))
        if inventory_item.uuid == uuid and ItemConfig[inventory_item.item].type == 'weapon' then
            if inventory_item.slot then
                -- if we already know which weapon slot is used, use it
                slot = inventory_item.slot
            else
                -- pick a new weapon slot
                slot = GetNextAvailableWeaponSlot(player)
                PlayerData[player].inventory[i].slot = slot
                CallEvent("SyncInventory", player)
            end

            log.debug("Equipping weapon from inventory to slot", player, uuid, slot)
            EquipWeaponToSlot(player, uuid, slot, equip)
            return
        end
    end
end

function EquipWeaponToSlot(player, uuid, slot, equip)
    local item = GetItemInstance(uuid)
    WeaponPatch.SetWeapon(player, ItemConfig[item].weapon_id, ItemConfig[item].mag_size, equip, slot, true)
end

-- returns the next available weapon slot (checks for fists)
function GetNextAvailableWeaponSlot(player)
    for i = 1, 3 do
        if (GetPlayerWeapon(player, i) == 1) then
            return i
        end
    end
end

function IsWeaponEquipped(player, uuid)
    return PlayerData[player].equipped[uuid] or nil
end

-- switch to fists if weapon is equipped for given weapon/item
function UnequipWeapon(player, uuid)
    local item = GetItemInstance(uuid)
    for slot = 1, 3 do
        local weapon_id, ammo = GetPlayerWeapon(player, slot)
        if ItemConfig[item].weapon_id == weapon_id then
            WeaponPatch.SetWeapon(player, 1, 0, true, slot, true)
        end
    end
end

-- if weapon is not 1, set weapon 1 to slot 1 (fists)
function SwitchToFists(player)
    log.debug("SwitchToFist")
    local wep = GetPlayerEquippedWeapon(player)
    if wep ~= 1 then
        WeaponPatch.SetWeapon(player, 1, 0, true, 1, true)
    end
end

function GetItemConfigByWeaponID(weapon_id)
    for item, cfg in pairs(GetItemConfigsByType('weapon')) do
        if cfg['weapon_id'] == weapon_id then
            return item, cfg
        end
    end
end

-- return currently equipped weapon ID or nil
function GetCurrentWeaponID(player)
    local weapon_id = GetPlayerEquippedWeapon(player)
    if weapon_id == 1 then
        return nil
    else
        return weapon_id
    end
end

AddRemoteEvent("ReloadWeapon", function(player)
    local weapon_id = GetCurrentWeaponID(player)
    if weapon_id then
        local item, item_cfg = GetItemConfigByWeaponID(weapon_id)
        if GetItemFromInventoryByName(player, item_cfg['mag_item']) then
            log.debug("Reloading player weapon " .. item .. " from magazine")

            RemoveFromInventory(player, item_cfg['mag_item'], 1)
            local slot = GetPlayerEquippedWeaponSlot(player)
            WeaponPatch.SetWeapon(player, weapon_id, item_cfg.mag_size, true, slot, true)
        end
    end
end)
