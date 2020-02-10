local PartsCollected = 0
local PartsRequired = 10
local Satellite3DText

function OnPackageStart()
    -- central computer
    CreateText3D("Press [E] to Interact", 15, -106279.4140625, 193854.59375, 1399.1424560547 + 130, 0,0,0)

    -- satellite computer
    CreateText3D("Press [E] to Interact", 15, -103004.5234375, 201067.09375, 2203.3188476563 + 130, 0, 0, 0)

    Satellite3DText = CreateText3D("STATUS: 0% OPERATIONAL", 50, -103577.703125, 200838.734375, 2203.2883300781 + 200, 0, 0, 0)
end
AddEvent("OnPackageStart", OnPackageStart)

AddRemoteEvent("InteractSatelliteComputer", function(player)
    local object = GetPlayerPropertyValue(player, 'carryingPart')
    if not IsValidObject(object) then
        return
    end

    SetPlayerAnimation(player, "COMBINE")

    PartsCollected = PartsCollected + 1

    local percentage_complete = math.floor(PartsCollected / PartsRequired * 100.0)

    AddPlayerChatAll(GetPlayerName(player) .. " acquired a satellite part!")
    AddPlayerChatAll("Satellite communications are now "..percentage_complete.."% operational!")

    print(GetPlayerName(player).. " acquired satellite part "..PartsCollected.." / "..PartsRequired)

    SetPlayerPropertyValue(player, 'carryingPart', nil, true)
    SetObjectDetached(object)
    DestroyObject(object)
    
    BumpPlayerStat(player, 'parts_collected')

    CallRemoteEvent(player, "ShowSatelliteComputer", percentage_complete)

    if PartsCollected >= PartsRequired then
        print(GetPlayerName(player).." completed the satellite transmission")
        AddPlayerChatAll(GetPlayerName(player).." completed the satellite transmission!")

        -- reset satellite status
        PartsCollected = 0
        SetText3DText(Satellite3DText, "STATUS: 0% OPERATIONAL")
        CallRemoteEvent(player, "SatelliteTransmission")

        -- call mothership
        Delay(15000, function()
            CallEvent("SpawnBoss")
        end)
    else
        SetText3DText(Satellite3DText, "STATUS: "..percentage_complete.."% OPERATIONAL")
    end
end)
