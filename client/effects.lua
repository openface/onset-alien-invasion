
local Components = {}

AddEvent("OnPackageStop", function()
  for object,component in pairs(Components) do  
    component:Destroy()
    Components[object] = nil
  end
end)

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
        if PropertyValue ~= false then
            AddComponentToObject(object, PropertyValue)
        else
            RemoveComponent(object)
        end
    end
end)

function AddComponentToObject(object, component)
    if component.type == nil then
      log.error "Error invalid component config"
      return
    end

    local actor = GetObjectActor(object)
    if component.type == "spotlight" then
      light = actor:AddComponent(USpotLightComponent.Class())
    elseif component.type == "pointlight" then
      light = actor:AddComponent(UPointLightComponent.Class())
    elseif component.type == "rectlight" then
      light = actor:AddComponent(URectLightComponent.Class())
    end

    if light == nil then
      log.error("Error unsupported component type",component.type)
      return
    end

    light:SetIntensity(component.intensity)
    light:SetLightColor(FLinearColor(255, 255, 255, 0), true)
    light:SetRelativeLocation(FVector(component.position.x, component.position.y, component.position.z))
    light:SetRelativeRotation(FRotator(component.position.rx, component.position.ry, component.position.rz))

    Components[object] = light
end

function RemoveComponent(object)
    -- destroy the component
    if Components[object] ~= nil then
      Components[object]:Destroy()
      Components[object] = nil
    end
end
