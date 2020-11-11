local LastHitObject
local LastHitStruct
local ActiveProp
local TraceRange = 500.0
local Debug = true

AddEvent("OnGameTick", function()

    local hitObject, hitStruct = PlayerLookRaycast()

    -- previously hit an object but are now looking at something else
    if LastHitObject ~= nil and hitObject ~= LastHitObject then
        if Debug then
            AddPlayerChat("no longer looking at " .. LastHitObject .. " -> " .. dump(LastHitStruct))
        end

        ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")

        if LastHitStruct.type == 'object' then
            SetObjectOutline(LastHitObject, false)
        end

        LastHitObject = nil
        LastHitStruct = nil
        ActiveProp = nil
        return
    end

    -- do not process further if player is in vehicle
    if IsPlayerInVehicle() then
        return
    end

    -- looking at new object
    if hitObject ~= LastHitObject then
        if Debug then
            AddPlayerChat("-> now looking at " .. hitObject .. " -> " .. dump(hitStruct))
        end

        if hitStruct.type == 'object' then
            -- world object
            local prop_options = GetObjectPropertyValue(hitObject, "prop")
            if prop_options ~= nil then
                SetObjectOutline(hitObject, true)
                ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. prop_options['message'] .. "')")
                ActiveProp = {
                    object = hitObject,
                    event = prop_options['event'] or nil,
                    remote_event = prop_options['remote_event'] or nil,
                    options = prop_options['options']
                }
                -- AddPlayerChat(dump(ActiveProp))
            end
        elseif hitStruct.type == 'tree' then
            -- foliage component
            ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','Press [E] to Harvest')")
            ActiveProp = {
                object = hitObject,
                remote_event = "HarvestTree"
            }
        elseif hitStruct.type == 'vehicle' then
            -- vehicle component
            ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','Press [E] to Inspect/Repair')")
            ActiveProp = {
                object = hitObject,
                remote_event = "InspectOrRepairVehicle"
            }
        end

        LastHitObject = hitObject
        LastHitStruct = hitStruct
    end
end)

-- returns the object and a structure or nil
function PlayerLookRaycast()
    local camX, camY, camZ = GetCameraLocation()
    local camForwardX, camForwardY, camForwardZ = GetCameraForwardVector()

    local Start = FVector(camX, camY, camZ)
    local End = Start + (FVector(camForwardX, camForwardY, camForwardZ) * FVector(TraceRange, TraceRange, TraceRange))
    local bResult, HitResult = UKismetSystemLibrary.LineTraceSingle(GetPlayerActor(), Start, End,
                                   ETraceTypeQuery.TraceTypeQuery1, true, {}, EDrawDebugTrace.None, true,
                                   FLinearColor(1.0, 0.0, 0.0, 1.0), FLinearColor(0.0, 1.0, 0.0, 1.0), 10.0)
    if bResult ~= true then
        return
    end

    local Actor = HitResult:GetActor()
    local Comp = HitResult:GetComponent()
    if not Comp then
        return
    end

    -- AddPlayerChat("comp name: " .. Comp:GetName() .. " class:" .. Comp:GetClassName() .." id:"..Comp:GetUniqueID())
    return ProcessHitComponent(Comp)
end

-- given a SMC, returns interactive component or object along
-- with a structure describing it
function ProcessHitComponent(Comp)
    -- trees
    if string.find(Comp:GetName(), "FoliageInstancedStaticMeshComponent") then
        -- foliage tree
        return Comp:GetUniqueID(), {
            type = 'tree',
            component = Comp
        }
    end

    -- world objects
    for _, obj in pairs(GetStreamedObjects()) do
        if GetObjectStaticMeshComponent(obj):GetUniqueID() == Comp:GetUniqueID() then
            return obj, {
                type = 'object'
            }
        end
    end

    -- vehicle hoods
    for _, veh in pairs(GetStreamedVehicles()) do
        if GetVehicleSkeletalMeshComponent(veh):GetUniqueID() == Comp:GetUniqueID() then
            -- we only care about being close to the hood bone
            if IsNearVehicleOpenHood(veh) then
                return veh, {
                    type = 'vehicle'
                }
            end
        end
    end
end

AddEvent("OnKeyPress", function(key)
    if key == "E" then
        if ActiveProp ~= nil then
            if ActiveProp['event'] then
                -- AddPlayerChat("calling event: "..ActiveProp['event'])
                CallEvent(ActiveProp['event'], ActiveProp['object'], ActiveProp['options'])
            elseif ActiveProp['remote_event'] then
                -- AddPlayerChat("calling remote event: "..ActiveProp['remote_event'])
                CallRemoteEvent(ActiveProp['remote_event'], ActiveProp['object'], ActiveProp['options'])
            end
            ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")
            SetObjectOutline(ActiveProp['object'], false)
            ActiveProp = nil
        end
    end
end)
