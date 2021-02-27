local Doors = {}

AddEvent("OnPackageStart", function()
    log.info("Loading interactive doors...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/doors/doors.json")
    for _, config in pairs(_table) do
        CreateInteractiveDoor(config)
    end
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all interactive doors..."
    for door in pairs(Doors) do
        Doors[door] = nil
        DestroyDoor(door)
    end
end)

function CreateInteractiveDoor(config)
    log.debug("Creating interactive door")
    local door = CreateDoor(config['doorID'], config['x'], config['y'], config['z'], config['yaw'], true)
    SetDoorOpen(door, true) -- close door by default (should be false according to wiki)

    SetDoorPropertyValue(door, "owner", "12345") -- GetPlayerSteamId(player)
    
    Doors[door] = true
end

AddEvent("OnPlayerInteractDoor", function(player, door, bWantsOpen)
    local bWantsOpen = not bWantsOpen -- the door open state here is backwards (bug in onset)
    local bIsDoorOpen = not IsDoorOpen(door) -- again, is backwards (bugged)

    AddPlayerChat(player, "Door: " .. door .. ", open: ".. tostring(bIsDoorOpen) ..", wants: ".. tostring(bWantsOpen))

    local owner = GetDoorPropertyValue(door, "owner")
    if not bIsDoorOpen and GetPlayerSteamId(player) ~= GetDoorPropertyValue(door, "owner") then
        -- door is locked
        CallRemoteEvent(player, "ShowError", "Locked")
        return
    end

    SetDoorOpen(door, bWantsOpen)
end)

AddCommand("closedoors", function(player)
    for k, v in pairs(GetAllDoors()) do
        AddPlayerChat(player, dump(IsDoorOpen(v)))
        SetDoorOpen(v, false)
    end
end)
