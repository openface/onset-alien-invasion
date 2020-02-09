local PartsCollected = 0
local PartsRequired = 10
local SatelliteComputerText

function OnPackageStart()
    -- central computer
    CreateText3D("Press [E] to Interact", 15, -106279.4140625, 193854.59375, 1399.1424560547 + 130, 0,0,0)

    -- satellite computer
    SatelliteComputerText = CreateText3D("Press [E] to Interact", 20, -103004.5234375, 201067.09375, 2203.3188476563 + 130, 0, 0, 0)
end
AddEvent("OnPackageStart", OnPackageStart)

AddRemoteEvent("InteractSatelliteComputer", function(player)
    local object = GetPlayerPropertyValue(player, 'carryingPart')
    if IsValidObject(object) then
        SetPlayerAnimation(player, "COMBINE")

        PartsCollected = PartsCollected + 1

        AddPlayerChatAll(GetPlayerName(player) .. " acquired satellite part "..PartsCollected.." of "..PartsRequired.."!")
        print(GetPlayerName(player).. " acquired satellite part "..PartsCollected.." / "..PartsRequired)

        SetPlayerPropertyValue(player, 'carryingPart', nil, true)
        SetObjectDetached(object)
        DestroyObject(object)
        
        BumpPlayerStat(player, 'parts_collected')

        CallRemoteEvent(player, "ShowSatelliteComputer", PartsCollected, PartsRequired)

        if PartsCollected >= PartsRequired then
            print(GetPlayerName(player).." completed the satellite transmission")
            AddPlayerChatAll(GetPlayerName(player).." completed the satellite transmission!")

            PartsCollected = 0
            CallRemoteEvent(player, "SatelliteTransmission")
            Delay(15000, function()
                CallEvent("SpawnBoss")
            end)
            SetText3DText(SatelliteComputerText, "Press [E] to Interact")
        else
            SetText3DText(SatelliteComputerText, "Parts Collected ("..PartsCollected.."/"..PartsRequired..") ~ Press [E] to Interact")
        end
    end
end)
