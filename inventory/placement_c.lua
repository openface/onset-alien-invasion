-- global
EditingObject = nil

local PlacementPendingItem
local EditMode = EDIT_LOCATION
local cancel_edit_timer
local PlacementCooldown
local PlacementTimer

AddEvent("OnPackageStop", function()
    EditingObject = nil
end)

AddEvent('OnRenderHUD', function()
    if PlacementPendingItem then
        local x, y, z = GetMouseHitLocation()
        SetDrawColor(RGB(255, 255, 0))
        DrawCircle3D(x, y, z + 10.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 20.0)
        DrawPoint3D(x, y, z, 20.0)
    end
end)

-- Edit placeable objects with Ctrl key
AddEvent("OnKeyPress", function(key)
    if key == "Left Ctrl" then
        local found_editable_object = false
        -- outline all placeable items nearby
        for _, object in pairs(GetStreamedObjects()) do
            if GetObjectPropertyValue(object, "placeable") == true then
                SetObjectOutline(object, true)
                found_editable_object = true
            end
        end

        if found_editable_object then
            -- pointing mode for selecting object to edit
            SetInputMode(INPUT_GAMEANDUI)
            ShowMouseCursor(true)
        end
    end
end)

AddEvent("OnKeyRelease", function(key)
    if PlacementPendingItem and key == 'Left Mouse Button' then
        local secs = GetTimeSeconds() - (PlacementCooldown or 0)
        if secs < 3 then
            CallEvent("HideSpinner")
            DestroyTimer(PlacementTimer)
        end
    elseif key == "Left Ctrl" then
        -- stop editing
        SetInputMode(INPUT_GAME)
        ShowMouseCursor(false)

        for _, object in pairs(GetStreamedObjects()) do
            if GetObjectPropertyValue(object, "placeable") == true then
                SetObjectOutline(object, false)
            end
        end

        if EditingObject then
            StopEditingObject()
        end
    end
end)

AddEvent("OnKeyPress", function(key)
    if PlacementPendingItem and key == 'Left Mouse Button' then

        PlacementCooldown = GetTimeSeconds()
        PlacementTimer = CreateTimer(function(starttime)
            local secs = GetTimeSeconds() - starttime
            AddPlayerChat("placement timer: "..starttime.." "..secs)

            if secs > 3 then
                CallEvent("HideSpinner")

                local x, y, z, distance = GetMouseHitLocation()
                if distance > 1000 then
                    ShowMessage("Cannot place that far away!")
                else
                    CallRemoteEvent("PlaceItem", PlacementPendingItem, {
                        x = x,
                        y = y,
                        z = z
                    })
                end
                DestroyTimer(PlacementTimer)
            elseif secs > 0 then
                CallEvent("ShowSpinner")
            end
        end, 200, PlacementCooldown)

    elseif IsCtrlPressed() and key == 'Left Mouse Button' then
        -- select object to edit
        local hittype, hitid = GetMouseHitEntity()

        if (hittype == HIT_OBJECT and hitid ~= 0) then
            SelectEditableObject(hitid)
        end
    elseif EditingObject and key == 'Right Mouse Button' then
        -- object is being edited
        if EditMode == EDIT_LOCATION then
            EditMode = EDIT_ROTATION
        elseif EditMode == EDIT_ROTATION then
            EditMode = EDIT_LOCATION
        end
        SetObjectEditable(EditingObject, EditMode)
    elseif EditingObject and key == 'Backspace' then
        -- put back into player inventory
        CallRemoteEvent("UnplaceItem", EditingObject)
    end
end)

-- do not allow the player to aim while editing object
AddEvent("OnPlayerToggleAim", function(toggle)
    if EditingObject and toggle == true then
        return false
    end
end)

-- place item from inventory
AddEvent("PlaceItemFromInventory", function(uuid)
    PlacementPendingItem = uuid
    AddPlayerChat("Choose a location and hold Left Mouse Button for a few seconds to place this item.")
end)

AddRemoteEvent("ObjectPlaced", function(object)
    PlacementPendingItem = nil
    ShowMessage("Item has been placed.")
end)

function SelectEditableObject(object)
    if GetObjectPropertyValue(object, "placeable") ~= true then
        return
    end

    AddPlayerChat(
        "Editing object. While holding CTRL, you can reposition the item and use right-click to alternate between location and rotation. Hit [BACKSPACE] to unplace item.")

    EditingObject = object

    SetObjectEditable(EditingObject, EditMode)
    SetObjectOutline(EditingObject, true)

    SetInputMode(INPUT_GAMEANDUI)
    ShowMouseCursor(true)

    local x, y, z = GetObjectLocation(EditingObject)
    cancel_edit_timer = CreateTimer(CancelEditTimer, 1000, x, y, z)
end

function StopEditingObject()
    SetObjectEditable(EditingObject, EDIT_NONE)
    SetObjectOutline(EditingObject, false)

    SetInputMode(INPUT_GAME)
    ShowMouseCursor(false)

    CallRemoteEvent("FinalizeObjectPlacement", EditingObject)

    EditingObject = nil
end

-- timer used to cancel object placement if player walks away
function CancelEditTimer(x, y, z)
    if not EditingObject then
        return
    end

    local px, py, pz = GetPlayerLocation()
    if GetDistance3D(px, py, pz, x, y, z) > 1500 then
        AddPlayerChat("You are too far away to edit the object!")

        SetObjectEditable(EditingObject, EDIT_NONE)
        SetObjectOutline(EditingObject, false)

        EditingObject = nil
        PendingPlacement = false

        SetInputMode(INPUT_GAME)
        ShowMouseCursor(false)

        DestroyTimer(cancel_edit_timer)
    end
end
