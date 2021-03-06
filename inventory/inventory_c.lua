-- global
InventoryUI = nil
CurrentInHand = nil

local ActionCooldown
local ActionTimer
local CurrentlyInteracting

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

AddRemoteEvent("Play3DSound", function(sound, x, y, z, radius)
    local radius = radius or 1000
    SetSoundVolume(CreateSound3D("client/" .. sound, x, y, z, radius), 1.0)
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
    if IsPlayerInVehicle() then
        return
    end
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
    elseif key == 'Left Mouse Button' and ActiveProp then
        -- interact with prop

        local prop_object_name = GetObjectModelName(GetObjectModel(ActiveProp.hit_object))

        if not CurrentInHand then
            AddPlayerChat("interact with prop "..prop_object_name.." (no item)")
            CallRemoteEvent("InteractWithProp", ActiveProp)
            -- ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")
            return
        end

        -- interact with prop (with item in hand)
        AddPlayerChat("use item "..CurrentInHand.item.." on prop "..prop_object_name.." - start")
        ActionCooldown = GetTickCount()
        ActionTimer = CreateTimer(function(starttime)
            local hold_button_elapsed = (GetTickCount() - ActionCooldown) / 1000
            AddPlayerChat("action timer: " .. starttime .. " " .. hold_button_elapsed)

            if hold_button_elapsed > 3 then
                AddPlayerChat("use item "..CurrentInHand.item.." on prop "..prop_object_name.." - end")

                CallEvent("HideSpinner")
                CallRemoteEvent("UseItemFromInventory", CurrentInHand.uuid, ActiveProp)
                DestroyTimer(ActionTimer)
                ActionCooldown = nil
            elseif hold_button_elapsed > 0 then
                CallEvent("ShowSpinner")
                ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")
            end
        end, 200, ActionCooldown)

    elseif key == 'Left Mouse Button' then
        -- use item
        if CurrentInHand then
            AddPlayerChat("use item")

            if CurrentInHand.type == 'placeable' then
                CallEvent("PlaceItemFromInventory", CurrentInHand.uuid)
            else
                CallRemoteEvent("UseItemFromInventory", CurrentInHand.uuid)
            end
            return
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
    elseif key == 'Left Mouse Button' and ActionCooldown then
        local hold_button_elapsed = GetTickCount() - ActionCooldown
        CallEvent("HideSpinner")
        ActionCooldown = nil
        DestroyTimer(ActionTimer)
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
    local vx, vy, vz = GetPlayerForwardVector(GetPlayerId())
    local forward_vector = {
        vx = vx,
        vy = vy,
        vz = vz
    }
    CallRemoteEvent("DropItemFromInventory", uuid, forward_vector)
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

