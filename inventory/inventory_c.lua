-- global
InventoryUI = nil

AddEvent("OnPackageStart", function()
    InventoryUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(InventoryUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/inventory/")
    SetWebAlignment(InventoryUI, 0.0, 0.0)
    SetWebAnchors(InventoryUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(InventoryUI, WEB_HITINVISIBLE)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(InventoryUI)
end)

AddEvent('OnKeyPress', function(key)
    if IsShiftPressed() or IsAltPressed() or EditingObject or GetWebVisibility(InventoryUI) == WEB_HIDDEN then
        return
    end
    if not IsPlayerInVehicle() then
        if key == 'Tab' then
            -- inventory
            ShowMouseCursor(true)
            SetInputMode(INPUT_GAMEANDUI)
            SetWebVisibility(InventoryUI, WEB_VISIBLE)
            ExecuteWebJS(InventoryUI, "EmitEvent('ShowInventory')")
        elseif key == '1' or key == '2' or key == '3' then
            -- weapon switching
            CallRemoteEvent("UnequipForWeapon")
        elseif key == '4' or key == '5' or key == '6' or key == '7' or key == '8' or key == '9' then
            -- item hotkeys
            CallRemoteEvent("UseItemHotkey", key)
        end
    end
end)

AddEvent('OnKeyRelease', function(key)
    if GetWebVisibility(InventoryUI) == WEB_HIDDEN then
        return
    end

    if key == 'Tab' and not IsPlayerInVehicle() then
        -- item inventory
        SetWebVisibility(InventoryUI, WEB_HITINVISIBLE)
        ExecuteWebJS(InventoryUI, "EmitEvent('HideInventory')")
        ShowMouseCursor(false)
        SetInputMode(INPUT_GAME)
    end
end)

-- sync inventory
AddRemoteEvent("SetInventory", function(data)
    ExecuteWebJS(InventoryUI, "EmitEvent('SetInventory'," .. data .. ")")
end)

-- drop item
AddEvent("DropItem", function(item)
    CallRemoteEvent("DropItemFromInventory", item)
end)

-- equip item
AddEvent("EquipItem", function(item)
    CallRemoteEvent("EquipItemFromInventory", item)
end)

-- unequip item
AddEvent("UnequipItem", function(item)
    CallRemoteEvent("UnequipItemFromInventory", item)
end)

-- use item
AddEvent("UseItem", function(item)
    CallRemoteEvent("UseItemFromInventory", item)
end)

-- sort inventory
AddEvent("UpdateInventory", function(data)
    CallRemoteEvent("UpdateInventory", data)
end)

