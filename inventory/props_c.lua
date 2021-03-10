ActiveProp = nil

local LastHitObject
local LastHitStruct
local TraceRange = 600.0 -- todo: this needs to adjust depending on 1st/3rd camera view

AddEvent("OnGameTick", function()

    local hitObject, hitStruct = PlayerLookRaycast()

    -- previously hit an object but are now looking at something else
    if LastHitObject ~= nil and hitObject ~= LastHitObject then
        --debug("no longer looking at " .. LastHitObject .. " -> " .. dump(LastHitStruct))

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
        --debug("-> now looking at " .. hitObject .. " -> " .. dump(hitStruct))

        if hitStruct.type == 'object' then
            -- object interaction
            local prop = GetObjectPropertyValue(hitObject, "prop")
            if prop then
                local item_interaction = GetItemInteraction(prop)
                if item_interaction then
                    debug(dump(item_interaction))
                    ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. item_interaction.interaction.use_label .. "')")
                    ActiveProp = {
                        hit_type = 'object',
                        hit_object = hitObject,
                        item_interaction = item_interaction,
                        options = prop.options,
                    }
                    debug("OBJECT ActiveProp: " .. dump(ActiveProp))
                end
            end
        elseif CurrentInHand then
            -- item in hand interacts with environment
            local interaction = CurrentInHandInteractsWithHitType(hitStruct.type)
            if interaction then
                ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. interaction.use_label .. "')")
                ActiveProp = {
                    hit_type = hitStruct.type,
                    hit_object = hitObject,
                }
                debug("ENV ActiveProp: " .. dump(ActiveProp))
            end
        end

        LastHitObject = hitObject
        LastHitStruct = hitStruct
    end
end)

-- @return { item = "Crowbar", interaction = { use_label = "", event = "", animation = "", sound = "" } }
function GetItemInteraction(prop)
    if prop.interacts_with and CurrentInHand then
        for item, interaction_name in pairs(prop.interacts_with) do
            if CurrentInHand.item == item and CurrentInHand.interactions and CurrentInHand.interactions[interaction_name] then
                return {
                    item = item,
                    interaction = CurrentInHand.interactions[interaction_name],
                }
            end
        end
    end
    -- no item interaction, default to using prop events
    return {
        item = nil,
        interaction = { use_label = prop.use_label, event = prop.event }
    }
end

-- @return  { use_label = "Chop Tree", event = "HarvestTree", sound = "sounds/chopping_wood.mp3", animation = { id = 920, duration = 5000 } }
function CurrentInHandInteractsWithHitType(hittype)
    debug("CurrentInHandInteractsWithHitType:"..hittype)
    if CurrentInHand and CurrentInHand.interactions then
        for type, int in pairs(CurrentInHand.interactions) do
            if type == hittype then
                debug("item interacts with world: " .. dump(int))
                return int
            end
        end
    end
end

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

    -- debug("comp name: " .. Comp:GetName() .. " class:" .. Comp:GetClassName() .." id:"..Comp:GetUniqueID())

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

