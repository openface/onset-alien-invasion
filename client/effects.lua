
local Pointlights = {}

AddEvent("OnObjectStreamIn", function(object)
    local pointlight = GetObjectPropertyValue(object, "pointlight")
    if pointlight == true then
        AttachPointlight(object)
    end
end)

AddEvent("OnObjectStreamOut", function(object)
    if GetObjectPropertyValue(object, "pointlight") ~= nil then
        DetachPointlight(object)
    end
end)

AddEvent("OnObjectNetworkUpdatePropertyValue", function(object, PropertyName, PropertyValue)
    if PropertyName == "pointlight" then
        if PropertyValue == true then
            AttachPointlight(object)
        else
            DetachPointlight(object)
        end
    end
end)

function AttachPointlight(object)
    AddPlayerChat("attaching pointlight")

    local actor = GetObjectActor(object)
    light = actor:AddComponent(USpotLightComponent.Class())
    light:SetIntensity(5000)
    light:SetLightColor(FLinearColor(255, 255, 255, 0), true)
    light:SetRelativeLocation(FVector(0, 0, 0))
    light:SetRelativeRotation(FRotator(0.0, -180, 0.0))

    Pointlights[object] = light
end

function DetachPointlight(object)
    AddPlayerChat("detaching pointlight")
    -- destroy the component
    Pointlights[object]:Destroy()
end
