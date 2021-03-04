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
                if CurrentInHand and CurrentInHandInteractsOnType(ActiveProp.hit_type) then
                    -- use item in hand on object
                    CallRemoteEvent("UseItemFromInventory", CurrentInHand.uuid, ActiveProp)
                else
                    -- interact with object directly
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

-- given an environment type (tree, water, etc), returns the prop
-- definition compatible with what is currently equipped in hands
function CurrentInHandInteractsOnType(hittype)
    if CurrentInHand and CurrentInHand.interacts_on then
        for _,p in pairs(CurrentInHand.interacts_on) do
            if p.hittype == hittype then
                return p -- { hittype = "tree", use_label = "Chop Tree" }
            end
        end
    end
    return false
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
    local vx, vy, vz = GetPlayerForwardVector(GetPlayerId())
    local forward_vector = { vx = vx, vy = vy, vz = vz }
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

