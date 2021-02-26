
StandingPlayerLocation = nil

AddEvent("OnKeyPress", function(key)
    if StandingPlayerLocation and key == 'Space Bar' then
        -- unsitting
        local actor = GetPlayerActor(GetPlayerId())
        actor:SetActorEnableCollision(true)

        CallRemoteEvent("StopSitting", StandingPlayerLocation)
        StandingPlayerLocation = nil
    end
end)

AddEvent("SitInChair", function(object, options)
    -- save previous location
    local x, y, z = GetPlayerLocation()
    StandingPlayerLocation = {
        x = x,
        y = y,
        z = z
    }

    local actorYAdjustment = 90

    local modelid = GetObjectModel(object)
    local chairYAdjustment = 0
    if (modelid == 952) then -- Not all chairs are rotated properly by default, so you'll have to test for each chair model that you want to use and adjust y accordingly
        chairYAdjustment = 180
    end

    local x, y, z = GetObjectLocation(object)
    local rX, rY, rZ = GetObjectRotation(object)
    local locationVector = FVector(x, y, z)
    local forwardVector = FVector(0, 1, 0)
    local rotator = FRotator(rX, rY + chairYAdjustment, rZ)
    forwardVector = rotator:RotateVector(forwardVector)
    local magnitude = 30 -- Magnitude of vector for placing player (bigger = further away, smaller = closer)
    forwardVector = forwardVector * FVector(magnitude, magnitude, magnitude)
    locationVector = locationVector + forwardVector
    locationVector.Z = locationVector.Z + 100

    local actor = GetPlayerActor(GetPlayerId())
    actor:SetActorEnableCollision(false) -- Disable player collision so that the player will not be pushed off the chair

    actor:SetActorLocation(locationVector)
    actor:SetActorRotation(FRotator(rX, rY + actorYAdjustment + chairYAdjustment, rZ))
end)