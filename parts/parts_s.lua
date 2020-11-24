local PartsLocations = {} -- parts.json
local PartObjectID = 1437
local NumSpawnedParts = 25 -- maximum number of parts to spawn

AddCommand("ppos", function(player)
    if not Account.IsAdmin(GetPlayerSteamId(player)) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(player, string)
    log.debug(string)
    table.insert(PartsLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/parts/parts.json", PartsLocations)
end)

AddEvent("OnPackageStart", function()
    PartsLocations = File_LoadJSONTable("packages/"..GetPackageName().."/parts/parts.json")
    SpawnParts()
end)

-- randomly spawn a subset of parts
function SpawnParts()
    log.debug "Spawning parts..."

    -- Remove all computer_parts from world
    DestroyObjectPickupsByName('computer_part')

    local random_part_locations = getRandomSample(PartsLocations, NumSpawnedParts)

    for _,pos in pairs(random_part_locations) do
        log.debug("Creating part pickup")
        CreateObjectPickup('computer_part', pos[1], pos[2], pos[3])
    end
end

