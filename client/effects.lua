local LightComponents = {}

AddEvent("OnPackageStart", function()
    for object in pairs(GetStreamedObjects()) do
        local component_cfg = GetObjectPropertyValue(object, "component")
        if component_cfg ~= nil then
            AddLightComponentToObject(object, component_cfg)
        end
        local particle = GetObjectPropertyValue(object, "particle")
        if particle_cfg ~= nil then
            AddParticleToObject(object, particle_cfg)
        end
    end
end)

AddEvent("OnPackageStop", function()
    for object, component in pairs(LightComponents) do
        component:Destroy()
        LightComponents[object] = nil
    end
end)

AddEvent("OnObjectStreamIn", function(object)
    local component_cfg = GetObjectPropertyValue(object, "component")
    if component_cfg ~= nil then
        AddLightComponentToObject(object, component_cfg)
    end

    local particle_cfg = GetObjectPropertyValue(object, "particle")
    if particle_cfg ~= nil then
        AddParticleToObject(object, particle_cfg)
    end
end)

AddEvent("OnObjectStreamOut", function(object)
    if LightComponents[object] ~= nil and GetObjectPropertyValue(object, "component") == nil then
        RemoveLightComponent(object)
    end
end)

AddEvent("OnObjectNetworkUpdatePropertyValue", function(object, PropertyName, PropertyValue)
    if PropertyName == "component" then
        if PropertyValue ~= false then
            AddLightComponentToObject(object, PropertyValue)
        else
            RemoveLightComponent(object)
        end
    elseif PropertyName == "particle" then
        AddParticleToObject(object, PropertyValue)
    end
end)

function AddLightComponentToObject(object, component_cfg)
    if component_cfg.type == nil then
        AddPlayerChat "Error invalid component config"
        return
    end

    if LightComponents[object] ~= nil then
        AddPlayerChat "Object already has a component"
        return
    end

    local actor = GetObjectActor(object)
    local light_component
    if component_cfg.type == "spotlight" then
        light_component = actor:AddComponent(USpotLightComponent.Class())
    elseif component_cfg.type == "pointlight" then
        light_component = actor:AddComponent(UPointLightComponent.Class())
    elseif component_cfg.type == "rectlight" then
        light_component = actor:AddComponent(URectLightComponent.Class())
    end

    if light_component == nil then
        log.error("Error unsupported component type", component_cfg.type)
        return
    end

    light_component:SetIntensity(component_cfg.intensity)
    light_component:SetLightColor(FLinearColor(255, 255, 255, 0), true)
    light_component:SetRelativeLocation(FVector(component_cfg.position.x, component_cfg.position.y, component_cfg.position.z))
    light_component:SetRelativeRotation(FRotator(component_cfg.position.rx, component_cfg.position.ry, component_cfg.position.rz))

    LightComponents[object] = light_component
end

function RemoveLightComponent(object)
    -- destroy the component
    if LightComponents[object] ~= nil then
        LightComponents[object]:Destroy()
        LightComponents[object] = nil
    end
end

--
-- particles
--
function AddParticleToObject(object, particle_cfg)
    local HitEffect = GetWorld():SpawnEmitterAttached(
        UParticleSystem.LoadFromAsset(particle_cfg.path), 
        GetObjectStaticMeshComponent(object), 
        "", 
        FVector(particle_cfg.position.x,particle_cfg.position.y,particle_cfg.position.z), 
        FRotator(particle_cfg.position.rx,particle_cfg.position.ry,particle_cfg.position.rz),
        EAttachLocation.KeepRelativeOffset
    )
    if particle_cfg.scale ~= nil then
        HitEffect:SetRelativeScale3D(FVector(particle_cfg.scale.x, particle_cfg.scale.y, particle_cfg.scale.z))
    end
end
