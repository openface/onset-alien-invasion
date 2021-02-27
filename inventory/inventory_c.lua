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
    SetSoundVolume(CreateSound3D("client/" .. sound, x, y, z, 1000), 1.0)
end)

AddEvent("OnWebLoadComplete", function(ui)
    if ui == InventoryUI then
        CallRemoteEvent("GetInventory")
    end
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
        elseif key == 'Left Mouse Button' and not CurrentlyInteracting then
            if ActiveProp then
                -- object/prop interaction
                if CurrentInHand and ItemInHandInteractsWithActiveProp() then
                    -- use item in hand on object
                    CallRemoteEvent("UseItemFromInventory", CurrentInHand.uuid, ActiveProp)
                else
                    -- interact with object directly
                    -- todo remove client_event if possible to keep it simple
                    if ActiveProp['client_event'] then
                        -- AddPlayerChat("calling client event: "..ActiveProp['event'])
                        CallEvent(ActiveProp['client_event'], ActiveProp['hit_object'], ActiveProp['options'])
                    end
                    if ActiveProp['remote_event'] then
                        --AddPlayerChat("calling remote event: " .. ActiveProp['remote_event'])
                        CallRemoteEvent(ActiveProp['remote_event'], ActiveProp)
                    end
                end
                ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")
            elseif CurrentInHand then
                -- use item currently in hands freely
                if CurrentInHand.type == 'placeable' then
                    CallEvent("PlaceItemFromInventory", CurrentInHand.uuid)
                else
                    CallRemoteEvent("UseItemFromInventory", CurrentInHand.uuid)
                end
            end
        end
    end
end)

function ItemInHandInteractsWithActiveProp()
    --AddPlayerChat("CurrentInHand: " .. dump(CurrentInHand))
    --AddPlayerChat("ActiveProp: " .. dump(prop))
    if CurrentInHand and ActiveProp and CurrentInHand.hittype == ActiveProp.hit_type then
        return true
    else
        return false
    end
end

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
AddRemoteEvent("SetInventory", function(inventory_data, inhand_data)
    ExecuteWebJS(InventoryUI, "EmitEvent('SetInventory'," .. inventory_data .. ")")
    CurrentInHand = inhand_data
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

-- sort inventory
AddEvent("UpdateInventory", function(data)
    CallRemoteEvent("UpdateInventory", data)
end)

