function OnPackageStart()
    -- central computer
    CreateText3D("Press E to Interact", 15, -106279.4140625, 193854.59375, 1399.1424560547 + 130, 0,0,0)

    -- satellite computer
    CreateText3D("Press E to Interact", 15, -103004.5234375, 201067.09375, 2203.3188476563 + 130, 0, 0, 0)
end
AddEvent("OnPackageStart", OnPackageStart)

AddRemoteEvent("InteractSatelliteComputer", function(player, parts)
    SetPlayerAnimation(player, "COMBINE")
    AddPlayerChatAll(GetPlayerName(player) .. " acquired satellite part "..parts.." / 10")
    local object = GetPlayerPropertyValue(player, 'carryingPart')
    if object ~= nil then
        SetObjectDetached(object)
        DestroyObject(object)
    end
    print(GetPlayerName(player).. " acquired satellite part "..parts.." / 10")
end)
