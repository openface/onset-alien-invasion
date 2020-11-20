local LastHitObject
local LastHitStruct
local ActiveProp
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
                    client_event = prop_options['client_event'] or nil,
                    remote_event = prop_options['remote_event'] or nil,
                    options = prop_options['options']
                }
                --AddPlayerChat(dump(ActiveProp))
            end
        elseif hitStruct.type == 'tree' then
            -- foliage component
            ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','Harvest')")
            ActiveProp = {
                object = hitObject,
                remote_event = "HarvestTree"
            }
        elseif hitStruct.type == 'water' then
            -- water component
            ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','Go Fishing')")
            ActiveProp = {
                object = hitObject,
                remote_event = "GoFishing"
            }
        elseif hitStruct.type == 'vehicle' then
            -- vehicle component
            ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','Repair')")
            ActiveProp = {
                object = hitObject,
                remote_event = "RepairVehicle"
            }
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
    if bResult ~= true then
        return
    end

    local Actor = HitResult:GetActor()
    local Comp = HitResult:GetComponent()
    if not Comp then
        return
    end

    --AddPlayerChat("comp name: " .. Comp:GetName() .. " class:" .. Comp:GetClassName() .." id:"..Comp:GetUniqueID())
    return ProcessHitComponent(Comp)
end

-- given a SMC, returns interactive component or object along
-- with a structure describing it
function ProcessHitComponent(Comp)
    -- environment
    if string.find(Comp:GetName(), "FoliageInstancedStaticMeshComponent") then
        -- foliage tree
        return Comp:GetUniqueID(), {
            type = 'tree',
            component = Comp
        }
    elseif string.find(Comp:GetName(), "BrushComponent0") then
        -- water
        return Comp:GetUniqueID(), {
            type = 'water',
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
    if ActiveProp ~= nil and key == "E" then
        -- call prop events
        
        if ActiveProp['client_event'] then
            --AddPlayerChat("calling client event: "..ActiveProp['event'])
            CallEvent("prop:" .. ActiveProp['client_event'], ActiveProp['object'], ActiveProp['options'])
        end
        if ActiveProp['remote_event'] then
            --AddPlayerChat("calling remote event: "..ActiveProp['remote_event'])
            CallRemoteEvent("prop:" .. ActiveProp['remote_event'], ActiveProp['object'], ActiveProp['options'])
        end
        ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")
        SetObjectOutline(ActiveProp['object'], false)
        ActiveProp = nil
    elseif StandingPlayerLocation and key == 'Space Bar' then
        -- unsitting
        local actor = GetPlayerActor(GetPlayerId())
        actor:SetActorEnableCollision(true)

        CallRemoteEvent("prop:StopSitting", StandingPlayerLocation)
        StandingPlayerLocation = nil
    end
end)

--
-- Sitting
-- Thanks Pindrought!
--

AddEvent("prop:SitInChair", function(object, options)
    -- save previous location
    local x, y, z = GetPlayerLocation()
    StandingPlayerLocation = {
        x = x,
        y = y,
        z = z
    }

    local actorYAdjustment = 90

    local modelid = GetObjectModel(object)
    local chairYAdjustment = 0
    if (modelid == 952) then -- Not all chairs are rotated properly by default, so you'll have to test for each chair model that you want to use and adjust y accordingly
        chairYAdjustment = 180
    end

    local x, y, z = GetObjectLocation(object)
    local rX, rY, rZ = GetObjectRotation(object)
    local locationVector = FVector(x, y, z)
    local forwardVector = FVector(0, 1, 0)
    local rotator = FRotator(rX, rY + chairYAdjustment, rZ)
    forwardVector = rotator:RotateVector(forwardVector)
    local magnitude = 30 -- Magnitude of vector for placing player (bigger = further away, smaller = closer)
    forwardVector = forwardVector * FVector(magnitude, magnitude, magnitude)
    locationVector = locationVector + forwardVector
    locationVector.Z = locationVector.Z + 100

    local actor = GetPlayerActor(GetPlayerId())
    actor:SetActorEnableCollision(false) -- Disable player collision so that the player will not be pushed off the chair

    actor:SetActorLocation(locationVector)
    actor:SetActorRotation(FRotator(rX, rY + actorYAdjustment + chairYAdjustment, rZ))
end)

