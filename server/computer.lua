local PartsCollected = 0
local PartsRequired = 5
---local Satellite3DText

AddEvent("OnPackageStart", function()
    -- central computer
    CreateText3D("Press [E] to Interact", 15, -106279.4140625, 193854.59375, 1399.1424560547 + 130, 0,0,0)

    -- satellite computer
    CreateText3D("Press [E] to Interact", 15, -103004.5234375, 201067.09375, 2203.3188476563 + 130, 0, 0, 0)
end)

AddRemoteEvent("InteractSatelliteComputer", function(player)
    if not GetPlayerPropertyValue(player, 'carryingPart') then
        return
    end

    -- remove part from inventory
    SetPlayerPropertyValue(player, 'carryingPart', nil)
    CallEvent("SyncInventory", player)

    SetPlayerAnimation(player, "COMBINE")

    PartsCollected = PartsCollected + 1

    -- calculate new percentage
    local percentage_complete = GetSatelliteStatus()

    AddPlayerChatAll(GetPlayerName(player) .. " acquired a satellite part!")
    AddPlayerChatAll("Satellite communications are now "..percentage_complete.."% operational!")

    print(GetPlayerName(player).. " acquired satellite part "..PartsCollected.." / "..PartsRequired)

    SetPlayerPropertyValue(player, 'carryingPart', nil, true)
    
    BumpPlayerStat(player, 'parts_collected')

    CallRemoteEvent(player, "ShowSatelliteComputer", percentage_complete)

    if PartsCollected >= PartsRequired then
        -- part collection complete; spawn the mothership
        print(GetPlayerName(player).." completed the satellite transmission")
        AddPlayerChatAll(GetPlayerName(player).." completed the satellite transmission!")

        -- reset satellite status
        PartsCollected = 0
        CallRemoteEvent(player, "SatelliteTransmission")

        -- update satellite status for everyone
        UpdateAllPlayersSatelliteStatus()

        -- call mothership
        Delay(15000, function()
            CallEvent("SpawnBoss")
        end)
    else
        -- update satellite status for everyone
        UpdateAllPlayersSatelliteStatus(percentage_complete)
    end
end)

function UpdateAllPlayersSatelliteStatus(percentage_complete)
    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "SetSatelliteStatus", percentage_complete)
    end
end

function GetSatelliteStatus()
    return math.floor(PartsCollected / PartsRequired * 100.0)
end

-- update satellite progress on client once they land on island
AddRemoteEvent("DropParachute", function(player)
    CallRemoteEvent(player, "SetSatelliteStatus", GetSatelliteStatus())
end)