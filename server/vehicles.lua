local VehicleLocations = {}
local Vehicles = {}
local VehicleRespawnTime = 5 * 60 * 1000 -- 5 mins

AddCommand("vpos", function(player)
    if not IsAdmin(player) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(player, string)
    print(string)
    table.insert(VehicleLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/server/data/vehicles.json", VehicleLocations)
end)

AddEvent("OnPackageStart", function()
    VehicleLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/vehicles.json")
    SpawnVehicles()
end)

AddEvent("OnPackageStop", function()
    DespawnVehicles()
end)

function DespawnVehicles()
    for _,veh in pairs(Vehicles) do
        --print("Destroying vehicle: "..veh)
        DestroyVehicle(veh)
        Vehicles[veh] = nil
    end
end

function SpawnVehicles()
    print "Spawning vehicles..."
    DespawnVehicles()

    for _,pos in pairs(VehicleLocations) do
        local veh = CreateVehicle(23, pos[1], pos[2], pos[3])
        SetVehicleRespawnParams(veh, false, VehicleRespawnTime, true)
        Vehicles[veh] = veh
    end
end

AddEvent("OnPlayerEnterVehicle", function(player, vehicle, seat)
    if seat == 1 then
        SetVehicleLightEnabled(vehicle, true)
    end
end)
