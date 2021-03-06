ActiveProp = nil

local LastHitObject
local LastHitStruct
local TraceRange = 600.0 -- todo: this needs to adjust depending on 1st/3rd camera view
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

        if hitStruct.type == 'object' then
            -- object interaction
            local prop = GetObjectPropertyValue(hitObject, "prop")
            if prop then
                local interacts_with = CurrentInHandInteractsWithObject(prop)
                if interacts_with then
                    ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. interacts_with.use_label .. "')")
                else
                    ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. prop.use_label .. "')")
                end

                ActiveProp = {
                    hit_type = hitStruct.type,
                    hit_object = hitObject,
                    event = prop['event'],
                    options = prop['options'],
                    interacts_with = interacts_with,
                }
                --AddPlayerChat("OBJECT ActiveProp: " .. dump(ActiveProp))
            end
        elseif CurrentInHand then
            -- item in hand interacts with environment
            local interaction = CurrentInHandInteractsWithHitType(hitStruct.type)
            if interaction then
                ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. interaction.use_label .. "')")
                ActiveProp = {
                    hit_type = hitStruct.type,
                    hit_object = hitObject,
                    interacts_with = { item = interaction.hittype, use_label = interaction.use_label, event = interaction.event }
                }
                --AddPlayerChat("ENV ActiveProp: " .. dump(ActiveProp))
            end
        end

        LastHitObject = hitObject
        LastHitStruct = hitStruct
    end
end)

-- @return  { hittype = "tree", use_label = "Chop Tree", event = "HarvestTree"}
function CurrentInHandInteractsWithHitType(hittype)
    if CurrentInHand and CurrentInHand.interacts_on then
        for _, p in pairs(CurrentInHand.interacts_on) do
            if p.hittype == hittype then
                AddPlayerChat("item interacts with world: "..dump(p))
                return p
            end
        end
    end
end

-- @return { item = "axe", use_label = "Break Open", event = "UnlockStorage" }
function CurrentInHandInteractsWithObject(prop)
    if CurrentInHand and prop.interacts_with then
        for _, p in pairs(prop.interacts_with) do
            if CurrentInHand.item == p.item then
                AddPlayerChat("item interacts with prop: "..dump(p))
                return p
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

