-- global
EditingObject = nil
local editing_timer

AddEvent("OnPackageStop", function()
    EditingObject = nil    
end)

AddEvent("OnKeyPress", function(key)
    if EditingObject and key == "Enter" then
        AddPlayerChat("Object placed.")

        SetObjectEditable(EditingObject, EDIT_NONE)
        SetObjectOutline(EditingObject, false)
        EditingObject = nil

        SetInputMode(INPUT_GAME)
        ShowMouseCursor(false)

        -- TODO: Call Remote to finalize
    end
end)

AddRemoteEvent("EnableEditMode", function()
    AddPlayerChat("Enabling Edit Mode")

    -- find the first editable object
    for _, object in pairs(GetStreamedObjects()) do
        if GetObjectPropertyValue(object, "temporary") == true then
            SetObjectEditable(object, EDIT_LOCATION)
            SetObjectOutline(object, true)
            EditingObject = object
            break
        end
    end

    AddPlayerChat(EditingObject)

    SetInputMode(INPUT_GAMEANDUI)
    ShowMouseCursor(true)

    local x, y, z = GetObjectLocation(EditingObject)
    editing_timer = CreateTimer(EditingTimer, 1000, {
        x = x,
        y = y,
        z = z
    })
end)

-- timer used to hide storage screen once player walks away
function EditingTimer(loc)
    local x, y, z = GetPlayerLocation(GetPlayerId())
    if GetDistance3D(x, y, z, loc.x, loc.y, loc.z) > 2000 then
        AddPlayerChat("Object editing cancelled.")

        SetObjectEditable(EditingObject, EDIT_NONE)
        SetObjectOutline(EditingObject, false)

        EditingObject = nil
        -- TODO: call remote to destroy object
        --DestroyObject(EditingObject)

        SetInputMode(INPUT_GAME)
        ShowMouseCursor(false)

        DestroyTimer(editing_timer)
    end
end
