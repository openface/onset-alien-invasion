local HudUI

AddEvent("OnPackageStart", function()
    HudUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(HudUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/hud/")
    SetWebAlignment(HudUI, 0.0, 0.0)
    SetWebAnchors(HudUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(HudUI, WEB_HITINVISIBLE)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(HudUI)
end)

-- banner
function ShowBanner(msg)
    ExecuteWebJS(HudUI, "EmitEvent('ShowBanner','" .. msg .. "')")
end
AddFunctionExport("ShowBanner", ShowBanner)

AddRemoteEvent("ShowBanner", function(msg)
    ShowBanner(msg)
end)

-- message
function ShowMessage(msg)
    ExecuteWebJS(HudUI, "EmitEvent('ShowMessage','" .. msg .. "')")
end
AddFunctionExport("ShowMessage", ShowMessage)

AddRemoteEvent("ShowMessage", function(msg)
    ShowMessage(msg)
end)

-- boss health bar
function SetBossHealth(percentage)
    ExecuteWebJS(HudUI, "EmitEvent('SetBossHealth'," .. percentage .. ")")
end
AddRemoteEvent("SetBossHealth", SetBossHealth)
AddEvent("SetBossHealth", SetBossHealth)

-- inventory
AddRemoteEvent("SetInventory", function(data)
    ExecuteWebJS(HudUI, "EmitEvent('SetInventory'," .. data .. ")")
end)

--
-- interactive props 
--

local LastHitObject
local LastHitStruct
local ActiveProp

AddEvent("OnGameTick", function()
    local hitObject, hitStruct = PlayerLookRaycast()

    -- previously hit an object but are now looking at something else
    if LastHitObject ~= nil and hitObject ~= LastHitObject then
        AddPlayerChat("no longer looking at " .. LastHitObject .. " -> ".. dump(LastHitStruct))
        ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")

        if LastHitStruct.type == 'object' then
          SetObjectOutline(LastHitObject, false)
        end

        LastHitObject = nil
        LastHitStruct = nil
        ActiveProp = nil
        return
    end

    -- looking at new object
    if hitObject ~= LastHitObject then
        AddPlayerChat("-> now looking at " .. hitObject .. " -> ".. dump(hitStruct))

        if hitStruct.type == 'object' then
            -- world object
            local prop_options = GetObjectPropertyValue(hitObject, "prop")
            if prop_options ~= nil then
                SetObjectOutline(hitObject, true)
                ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. prop_options['message'] .. "')")
                ActiveProp = {
                    object = hitObject,
                    event = prop_options['event'] or nil,
                    remote_event = prop_options['remote_event'] or nil
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
        end

        LastHitObject = hitObject
        LastHitStruct = hitStruct
    end
end)

local TraceRange = 600.0

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
    if Comp and Comp:IsA(UStaticMeshComponent.Class()) then

        --AddPlayerChat("comp name: " .. Comp:GetName() .. " class:" .. Comp:GetClassName())

        if string.find(Comp:GetName(), "FoliageInstancedStaticMeshComponent") then
            -- foliage tree
            return Comp:GetUniqueID(), { type = 'tree', component = Comp }
        end

        for _, obj in pairs(GetStreamedObjects()) do
            if GetObjectStaticMeshComponent(obj):GetUniqueID() == Comp:GetUniqueID() then
                return obj, { type = 'object' }
            end
        end
    end
end

AddEvent("OnKeyPress", function(key)
    if key == "E" then
        if ActiveProp ~= nil then
            if ActiveProp['event'] then
                -- AddPlayerChat("calling event: "..ActiveProp['event'])
                CallEvent(ActiveProp['event'], ActiveProp['object'])
            elseif ActiveProp['remote_event'] then
                -- AddPlayerChat("calling remote event: "..ActiveProp['remote_event'])
                CallRemoteEvent(ActiveProp['remote_event'], ActiveProp['object'])
            end
            ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")
            SetObjectOutline(ActiveProp['object'], false)
            ActiveProp = nil
        end
    end
end)
