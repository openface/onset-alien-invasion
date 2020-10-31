local HudUI
local LastHitObject
local CurrentInteraction

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

-- interactive objects
AddEvent("OnGameTick", function()
    local hittype, hitid, impactX, impactY, impactZ = PlayerLookRaycast(200)

    -- previously hit an object but are now looking at something else
    if LastHitObject ~= nil and hitid ~= LastHitObject then
        -- AddPlayerChat("no longer looking at " .. LastHitObject)
        ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")

        SetObjectOutline(LastHitObject, false)
        LastHitObject = nil
        CurrentInteraction = nil
        return
    end

    -- not looking at an object
    if hittype ~= 5 then
        return
    end

    -- looking at new object
    if hitid ~= LastHitObject then
        -- AddPlayerChat("now looking at " .. hitid)
        local action = GetObjectPropertyValue(hitid, "interactive")
        if action ~= nil then
            ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. action['message'] .. "')")
            SetObjectOutline(hitid)
            CurrentInteraction = {
              remote_event = action['remote_event'],
              object = hitid
            }
        end

        LastHitObject = hitid
        -- AddPlayerChat("hittype: "..hittype.." hitid: "..hitid..")
    end
end)

-- this function was borrowed from Mog Interactive Objects by AlexMog
function PlayerLookRaycast(maxDistance)
    local x, y, z = GetPlayerLocation(GetPlayerId())
    z = z + 60
    local forwardX, forwardY, forwardZ = GetCameraForwardVector()
    local finalPointX = forwardX * maxDistance + x
    local finalPointY = forwardY * maxDistance + y
    local finalPointZ = forwardZ * maxDistance + z
    return LineTrace(x + forwardX * 20, y + forwardY * 20, z, finalPointX, finalPointY, finalPointZ, false)
end


AddEvent("OnKeyPress", function(key)
    if key == "E" then
        if CurrentInteraction ~= nil then
            CallRemoteEvent(CurrentInteraction['remote_event'])
            ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")
            SetObjectOutline(CurrentInteraction['object'], false)
            CurrentInteraction = nil
        end
    end
end)
