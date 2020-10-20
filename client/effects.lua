
local Components = {}

AddEvent("OnObjectStreamIn", function(object)
    local component = GetObjectPropertyValue(object, "component")
    if component ~= nil then
        AddComponentToObject(object, component)
    end
end)

AddEvent("OnObjectStreamOut", function(object)
    if Components[object] ~= nil and GetObjectPropertyValue(object, "component") == nil then
        RemoveComponent(object)
    end
end)

AddEvent("OnObjectNetworkUpdatePropertyValue", function(object, PropertyName, PropertyValue)
    if PropertyName == "component" then
        if PropertyValue ~= nil then
            AddComponentToObject(object, PropertyValue)
        else
            RemoveComponent(object)
        end
    end
end)

function AddComponentToObject(object, component)
    AddPlayerChat("attaching component",component.type)

    -- only spotlight supported for now
    if component.type ~= "spotlight" then
      return
    end

    local actor = GetObjectActor(object)
    local light = actor:AddComponent(USpotLightComponent.Class())
    light:SetIntensity(5000)
    light:SetLightColor(FLinearColor(255, 255, 255, 0), true)
    light:SetRelativeLocation(FVector(component.position.x, component.position.y, component.position.z))
    light:SetRelativeRotation(FRotator(component.position.rx, component.position.ry, component.position.rz))

    Components[object] = light
end

function RemoveComponent(object)
    AddPlayerChat("detaching component")
    -- destroy the component
    Components[object]:Destroy()
end
