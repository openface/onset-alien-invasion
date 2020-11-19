local UndermapTimer

AddEvent("OnPackageStart", function()
    UndermapTimer = CreateTimer(CheckUndermap, 1000)
end)

AddEvent("OnPackageStop", function()
    DestroyTimer(UndermapTimer)
end)

function CheckUndermap()
    local x, y, z = GetPlayerLocation()

    local terrain = GetTerrainHeight(x, y, 99999.9)
    if z < 0 and terrain - 400 > z and not IsPlayerInVehicle() then
        GetPlayerActor(GetPlayerId()):SetActorLocation(FVector(x, y, terrain + 200))
    end
end
