-- global
InventoryUI = nil
CurrentInHand = nil

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

AddRemoteEvent("Play3DSound", function(sound, x, y, z)
    SetSoundVolume(CreateSound3D("client/"..sound, x, y, z, 1000), 1.0)
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
            CallRemoteEvent("UseWeaponSlot", key)
        elseif key == '4' or key == '5' or key == '6' or key == '7' or key == '8' or key == '9' then
            -- item hotkeys
            CallRemoteEvent("UseItemHotkey", key)
        elseif key == 'Left Mouse Button' and CurrentInHand and not CurrentlyInteracting then
            -- use item currently in hands
            CallRemoteEvent("UseItemFromInventory", CurrentInHand['item'])
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

-- prevent aiming while holding item
AddEvent("OnPlayerToggleAim", function(toggle)
    if toggle == true and CurrentInHand then
        return false -- do not allow the player to aim
    end
end)

-- sync inventory
AddRemoteEvent("SetInventory", function(data)
    ExecuteWebJS(InventoryUI, "EmitEvent('SetInventory'," .. data .. ")")
end)

-- controls whether or not player can aim
AddRemoteEvent("SetInHand", function(data)
    CurrentInHand = data
end)

-- drop item
AddEvent("DropItem", function(uuid)
    CallRemoteEvent("DropItemFromInventory", uuid)
end)

-- equip item
AddEvent("EquipItem", function(uuid)
    CallRemoteEvent("EquipItemFromInventory", uuid)
end)

-- unequip item
AddEvent("UnequipItem", function(uuid)
    CallRemoteEvent("UnequipItemFromInventory", uuid)
end)

--[[ -- use item
AddEvent("UseItem", function(uuid)
    CallRemoteEvent("UseItemFromInventory", uuid)
end) ]]

-- sort inventory
AddEvent("UpdateInventory", function(data)
    CallRemoteEvent("UpdateInventory", data)
end)

