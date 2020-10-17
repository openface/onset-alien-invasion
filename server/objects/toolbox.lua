--[[ local x, y, z = GetPlayerLocation(player)
objxD = CreateObject(551, x, y, z)
Delay(100, function(player)
    SetObjectAttached(objxD, ATTACH_PLAYER, player, -41.114220, 2.789312, -8.013786, -69.331429, 14.331373, -13.422723,
        "hand_r")
end, player)
 ]]