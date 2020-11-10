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
    log.debug(string)
    table.insert(VehicleLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/server/data/vehicles.json", VehicleLocations)
end)

AddEvent("OnPackageStart", function()
    VehicleLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/vehicles.json")
    SpawnVehicles()
end)

AddEvent("OnPackageStop", function()
    DespawnVehicles()
    Vehicles = {}
    VehicleLocations = {}
end)

function DespawnVehicles()
    for _,veh in pairs(Vehicles) do
        --log.debug("Destroying vehicle: "..veh)
        DestroyVehicle(veh)
        Vehicles[veh] = nil
    end
end

function SpawnVehicles()
    log.debug "Spawning vehicles..."
    DespawnVehicles()

    for _,pos in pairs(VehicleLocations) do
        local veh = CreateVehicle(23, pos[1], pos[2], pos[3])
        SetVehicleRespawnParams(veh, false, VehicleRespawnTime, true)
        Vehicles[veh] = veh
    end
end

AddEvent("OnPlayerEnterVehicle", function(player, vehicle, seat)
    if seat == 1 then
        StartVehicleEngine(vehicle)
        SetVehicleLightEnabled(vehicle, true)
    end
end)

AddEvent("OnPlayerLeaveVehicle", function(player, vehicle, seat)
  if seat == 1 then
      StopVehicleEngine(vehicle)
      SetVehicleLightEnabled(vehicle, false)
  end
end)


function cmd_trunk(player, ratio)
	local vehicle = GetPlayerVehicle(player)

	if (vehicle == 0) then
		return AddPlayerChat(player, "You must be in a vehicle")
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end

	if (ratio == nil) then
		if (GetVehicleTrunkRatio(vehicle) > 0.0) then
			SetVehicleTrunkRatio(vehicle, 0.0)
		else
			SetVehicleTrunkRatio(vehicle, 60.0)
		end
	else
		ratio = tonumber(ratio)

		if (ratio > 90.0) then
			ratio = 90.0
		elseif (ratio < 0.0) then
			ratio = 0.0
		end

		SetVehicleTrunkRatio(vehicle, ratio)
	end
end
AddCommand("trunk", cmd_trunk)


function cmd_hood(player, ratio)
	local vehicle = GetPlayerVehicle(player)

	if (vehicle == 0) then
		return AddPlayerChat(player, "You must be in a vehicle")
	end

	if (GetPlayerVehicleSeat(player) ~= 1) then
		return AddPlayerChat(player, "You must be the driver of the vehicle")
	end

	if (ratio == nil) then
		if (GetVehicleHoodRatio(vehicle) > 0.0) then
			SetVehicleHoodRatio(vehicle, 0.0)
		else
			SetVehicleHoodRatio(vehicle, 60.0)
		end
	else
		ratio = tonumber(ratio)

		if (ratio > 90.0) then
			ratio = 90.0
		elseif (ratio < 0.0) then
			ratio = 0.0
		end

		SetVehicleHoodRatio(vehicle, ratio)
	end
end
AddCommand("hood", cmd_hood)