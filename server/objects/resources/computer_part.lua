RegisterObject("computer_part", {
    name = "Computer Part",
    type = 'resource',
    modelid = 1437,
    scale = { x = 3, y = 3, z = 3 },
    max_carry = 5,
    recipe = nil,
    attachment = nil
})

AddEvent("items:computer_part:pickup", function(player, pickup)
    print "picked up a part!"
    AddPlayerChatAll(GetPlayerName(player)..' has found a computer part!')
    CallRemoteEvent(player, "ComputerPartPickedup", pickup)
end)

-- clear satellite waypoint on death
AddEvent("OnPlayerDeath", function(player, killer)
    CallRemoteEvent(player, "HideSatelliteWaypoint")
end)