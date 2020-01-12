local VehicleLocations = {}
local VehicleRespawnTime = 5 * 60 * 1000

-- TODO remove
AddCommand("vpos", function(player)
    local x, y, z = GetPlayerLocation(player)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(player, string)
    print(string)
    table.insert(VehicleLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/server/data/vehicles.json", VehicleLocations)
end)

function SetupVehicles()
    VehicleLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/vehicles.json")
    print "Spawning vehicles..."

    for _,pos in pairs(VehicleLocations) do
        local veh = CreateVehicle(23, pos[1], pos[2], pos[3])
        SetVehicleRespawnParams(veh, true, VehicleRespawnTime, true)
    end
end