function OnPackageStart()
    -- central computer
    CreateText3D("Press E to Interact", 15, -106279.4140625, 193854.59375, 1399.1424560547 + 130, 0,0,0)

    -- satellite computer
    CreateText3D("Press E to Interact", 15, -101970.984375, 194300.09375, 2211.4655761719 + 130, 0, 0, 0)
end
AddEvent("OnPackageStart", OnPackageStart)

AddRemoteEvent("InteractSatelliteComputer", function(player)
    SetPlayerAnimation(player, "COMBINE")
    AddPlayerChatAll(GetPlayerName(player) .. " is operating the satellite computer!")
end)
