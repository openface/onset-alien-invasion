ActiveProp = nil

local LastHitObject
local LastHitStruct
local TraceRange = 600.0
local Debug = false

AddEvent("OnGameTick", function()

    local hitObject, hitStruct = PlayerLookRaycast()

    -- previously hit an object but are now looking at something else
    if LastHitObject ~= nil and hitObject ~= LastHitObject then
        if Debug then
            AddPlayerChat("no longer looking at " .. LastHitObject .. " -> " .. dump(LastHitStruct))
        end

        ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")

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

        if CurrentlyInteracting then
            return
        end

        if hitStruct.type == 'object' then
            -- object interaction
            local prop = GetObjectPropertyValue(hitObject, "prop")
            if prop then
                ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. prop.use_label .. "')")
                ActiveProp = {
                    hit_type = hitStruct.type,
                    hit_object = hitObject,
                    client_event = prop['client_event'] or nil,
                    remote_event = prop['remote_event'] or nil,
                    options = prop['options']
                }
                AddPlayerChat("OBJECT ActiveProp: " .. dump(ActiveProp))
            end
        elseif CurrentInHand then
            local prop = CurrentInHandInteractsOnType(hitStruct.type)
            if prop then
                -- equipped item interacts with environment
                ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. prop.use_label .. "')")
                ActiveProp = {
                    hit_type = hitStruct.type,
                    hit_object = hitObject
                }
                AddPlayerChat("ENV ActiveProp: " .. dump(ActiveProp))
            end
        end

        LastHitObject = hitObject
        LastHitStruct = hitStruct
    end
end)

-- returns the object and a structure or nil
function PlayerLookRaycast()
    local camX, camY, camZ = GetCameraLocation()
    if not camX then
        return
    end

    local camForwardX, camForwardY, camForwardZ = GetCameraForwardVector()

    local Start = FVector(camX, camY, camZ)
    local End = Start + (FVector(camForwardX, camForwardY, camForwardZ) * FVector(TraceRange, TraceRange, TraceRange))
    local bResult, HitResult = UKismetSystemLibrary.LineTraceSingle(GetPlayerActor(), Start, End,
                                   ETraceTypeQuery.TraceTypeQuery1, true, {}, EDrawDebugTrace.None, true,
                                   FLinearColor(1.0, 0.0, 0.0, 1.0), FLinearColor(0.0, 1.0, 0.0, 1.0), 10.0)
    if bResult == true and HitResult then
        return ProcessHitResult(HitResult)
    end
end

-- returns interactive component or object along
-- with a structure describing it
function ProcessHitResult(HitResult)
    local Actor = HitResult:GetActor()
    local Comp = HitResult:GetComponent()
    if not Comp then
        return
    end

    -- AddPlayerChat("comp name: " .. Comp:GetName() .. " class:" .. Comp:GetClassName() .." id:"..Comp:GetUniqueID())

    -- environment
    if string.find(Comp:GetName(), "FoliageInstancedStaticMeshComponent") then
        -- foliage tree
        return Comp:GetUniqueID(), {
            type = 'tree',
            component = Comp,
            actor = Actor
        }
    elseif string.find(Comp:GetName(), "BrushComponent0") then
        -- water
        return Comp:GetUniqueID(), {
            type = 'water',
            component = Comp,
            actor = Actor
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
                    type = 'vehicle_hood'
                }
            end
        end
    end
end

