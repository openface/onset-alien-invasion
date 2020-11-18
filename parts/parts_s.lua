local PartsLocations = {} -- parts.json
local PartObjectID = 1437
local NumSpawnedParts = 25 -- maximum number of parts to spawn

AddCommand("ppos", function(player)
    if not Player.IsAdmin(player) then
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

function SpawnParts()
    log.debug "Spawning parts..."

    -- Remove all computer_parts from world
    DestroyObjectPickupsByName('computer_part')

    -- randomize part locations
    local shuffled = {}
    for i,pos in ipairs(PartsLocations) do
        local p = math.random(1, #shuffled+1)
        table.insert(shuffled, p, pos)
    end

    -- randomly spawn a subset of parts
    for _,pos in pairs({table.unpack(shuffled, 1, NumSpawnedParts)}) do
        CreateObjectPickup('computer_part', pos[1], pos[2], pos[3])
    end
end

