local Computers = {}

local PartsCollected = 0
local PartsRequired = 5

local GarageComputerConfig = {
  rz = -0.0069580078125,
  sz = 1,
  y = 193889.953125,
  x = -106377.1640625,
  sx = 1,
  z = 1386.6390380859,
  modelID = 1027,
  sy = 1,
  ry = -91.021797180176,
  rx = -0.0069599621929228
}
local SatelliteTerminalConfig = {
  rz = -0.002716064453125,
  sz = 1,
  y = 201182.859375,
  x = -102958.1484375,
  sx = 1,
  z = 2202.7407226563,
  modelID = 1027,
  sy = 1,
  ry = 177.91160583496,
  rx = -0.0027184151113033
}

AddEvent("OnPackageStart", function()
    log.info "Creating computer props..."
    -- garage computer
    RegisterComputer("Garage Computer", GarageComputerConfig, { message = "Interact", client_event = "InteractGarageComputer" })

    -- satellite terminal
    RegisterComputer("Satellite Terminal", SatelliteTerminalConfig, { message = "Interact", client_event = "InteractSatelliteTerminal" })
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all computers..."
    for _, object in pairs(Computers) do
        Computers[object] = nil
        DestroyObject(object)
    end

    PartsCollected = 0
    PartsRequired = 0
    UpdateAllPlayersSatelliteStatus(0)
end)

function RegisterComputer(name, config, prop_options)
    log.debug("Registering computer: " .. name)
    local object = CreateObject(config['modelID'], config['x'], config['y'], config['z'], config['rx'],
                           config['ry'], config['rz'], config['sx'], config['sy'], config['sz'])
    SetObjectPropertyValue(object, "prop", prop_options)
    Computers[object] = true
end

-- called when interacting with satellite with a computer_part in your inventory
AddRemoteEvent("InteractSatelliteComputer", function(player, object)
    -- remove part from inventory
    RemoveFromInventory(player, "computer_part")

    SetPlayerLocation(player, -102988.40625, 201117.9375, 2200.3193359375)
    SetPlayerHeading(player, 77.734954833984)   
    SetPlayerAnimation(player, "COMBINE")

    PartsCollected = PartsCollected + 1

    -- calculate new percentage
    local percentage_complete = GetSatelliteStatus()

    AddPlayerChatAll(GetPlayerName(player) .. " acquired a satellite part!")
    AddPlayerChatAll("Satellite communications are now "..percentage_complete.."% operational!")

    log.info(GetPlayerName(player).. " acquired satellite part "..PartsCollected.." / "..PartsRequired)
    
    BumpPlayerStat(player, 'parts_collected')

    CallRemoteEvent(player, "ShowSatelliteComputer", percentage_complete)

    if PartsCollected >= PartsRequired then
        -- part collection complete; spawn the mothership
        log.info(GetPlayerName(player).." completed the satellite transmission")
        AddPlayerChatAll(GetPlayerName(player).." completed the satellite transmission!")

        -- reset satellite status
        PartsCollected = 0
        CallRemoteEvent(player, "BeginSatelliteTransmission", object)

        -- update satellite status for everyone
        UpdateAllPlayersSatelliteStatus()

        Delay(7000, function()
          PlaySoundSync(player, "sounds/alert.mp3", 10000)
        end)

        -- call mothership
        Delay(15000, function()
            CallEvent("SpawnBoss")
        end)
    else
        -- update satellite status for everyone
        UpdateAllPlayersSatelliteStatus(percentage_complete)
    end
end)

function UpdateAllPlayersSatelliteStatus(percentage_complete)
    for _,ply in pairs(GetAllPlayers()) do
        CallRemoteEvent(ply, "SetSatelliteStatus", percentage_complete)
    end
end

function GetSatelliteStatus()
    return math.floor(PartsCollected / PartsRequired * 100.0)
end

-- update satellite progress on client once they land on island
AddRemoteEvent("DropParachute", function(player)
    CallRemoteEvent(player, "SetSatelliteStatus", GetSatelliteStatus())
end)

AddEvent("ComputerPartPickedUp", function(player)
  AddPlayerChatAll(GetPlayerName(player)..' has found a computer part!')
  CallRemoteEvent(player, "ComputerPartPickedup", { x = SatelliteTerminalConfig.x, y = SatelliteTerminalConfig.y, z = SatelliteTerminalConfig.z })
end)