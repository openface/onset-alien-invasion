local HudUI
local LastHitObject
local InteractionConfig
local InteractionEvent

AddEvent("OnPackageStart", function()
    HudUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(HudUI, "http://asset/" .. GetPackageName() .. "/ui/dist/index.html#/hud/")
    SetWebAlignment(HudUI, 0.0, 0.0)
    SetWebAnchors(HudUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(HudUI, WEB_HITINVISIBLE)

    -- when package restarts, reload data on client
    CallRemoteEvent("GetInteractionConfig")
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(HudUI)
end)

AddRemoteEvent("LoadInteractionConfig", function(data)
  InteractionConfig = data
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
        InteractionEvent = nil
        return
    end

    -- not looking at an object
    if hittype ~= 5 then
        return
    end

    -- looking at new object
    if hitid ~= LastHitObject then
        -- AddPlayerChat("now looking at " .. hitid)

        LastHitObject = hitid
        if InteractionConfig == nil then return end

        local cfg = GetInteractionConfigByModel(GetObjectModel(hitid))
        if cfg ~= nil then
            ExecuteWebJS(HudUI, "EmitEvent('ShowInteractionMessage','" .. cfg['message'] .. "')")
            SetObjectOutline(LastHitObject)
            InteractionEvent = cfg['remote_event']
        end

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

function GetInteractionConfigByModel(modelid)
  for type, config in pairs(InteractionConfig) do
    for i, m in ipairs(config.models) do
        if m == modelid then
            return config
        end
    end
  end
end

AddEvent("OnKeyPress", function(key)
    if key == "E" then
        if InteractionEvent ~= nil then
            CallRemoteEvent(InteractionEvent)
            ExecuteWebJS(HudUI, "EmitEvent('HideInteractionMessage')")
        end
    end
end)
