local PartsLocations = {} -- parts.json
local PartObjectID = 1437

-- TODO remove
AddCommand("ppos", function(playerid)
    local x, y, z = GetPlayerLocation(playerid)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(playerid, string)
    print(string)
    table.insert(PartsLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/server/data/parts.json", PartsLocations)
end)

function SetupParts()
    PartsLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/parts.json")

    -- spawn all parts
    for _,pos in pairs(PartsLocations) do
        local pickup = CreatePickup(PartObjectID, pos[1], pos[2], pos[3])
        SetPickupPropertyValue(pickup, 'type', 'part')
    end
end

-- pickup loot
function OnPlayerPickupHit(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') ~= 'part') then
        return
    end

    if (GetPlayerPropertyValue(player, 'carryingPart') == true) then
        return
    end
        
    CallRemoteEvent(player, "PartPickedup", pickup)
    AddPlayerChatAll(GetPlayerName(player)..' has found up a computer part!')
    
    -- hide part pickup for 5 mins from player
    SetPickupVisibility(pickup, player, false)
    Delay(5 * 60 * 1000, function()
        SetPickupVisibility(pickup, player, true)
    end)

    EquipPart(player)
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)

function EquipPart(player)
    -- carry with left hand
    local x,y,z = GetPlayerLocation(player)
    local object = CreateObject(PartObjectID, x, y, z)
    SetObjectAttached(object, ATTACH_PLAYER, player, 10, -5, 0, 0, 0, 90, "hand_l")

    SetPlayerPropertyValue(player, 'carryingPart', true, true)        
end

-- TODO remove me
AddCommand("part", function(player)
    EquipPart(player)
end)

--[[
AddCommand("p", function(player, x,y,z,rx,ry,rz)
    if object ~= nil then
        DestroyObject(object)
    end        
    
    local px,py,pz = GetPlayerLocation(player)
    object = CreateObject(PartObjectID, px, py, pz)
    SetObjectAttached(object, ATTACH_PLAYER, player, x, y, z, rx, ry, rz, "hand_l")

    SetPlayerPropertyValue(player, 'carryingPart', true, true) 
end)
--]]