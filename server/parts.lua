local PartsLocations = {} -- parts.json

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
        local pickup = CreatePickup(551, pos[1], pos[2], pos[3])
        SetPickupPropertyValue(pickup, 'type', 'part')
    end
end

-- pickup loot
function OnPlayerPickupHit(player, pickup)
    if (GetPickupPropertyValue(pickup, 'type') == 'part') then
        CallRemoteEvent(player, "PartPickedup", pickup)
        AddPlayerChatAll(GetPlayerName(player)..' has picked up a part!')
        
        -- hide part pickup for 5 mins from player
        SetPickupVisibility(pickup, player, false)
        Delay(5 * 60 * 1000, function()
            SetPickupVisibility(pickup, player, true)
        end)

        -- carry with left hand
        local x,y,z = GetPlayerLocation(player)
        local object = CreateObject(551, x, y, z)
        SetObjectAttached(object, ATTACH_PLAYER, player, 42, -5, 8, 110, 0, 0, "hand_l")
    end
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)
