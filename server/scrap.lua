local ScrapLocations = {} -- scraps.json
local NumSpawnedScrap = 25 -- maximum number of scrap spots to spawn
local ScrapCooldown = 60000 * 5 -- can only search a scrap point every 10 minutes

AddCommand("spos", function(player)
    if not IsAdmin(player) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    string = "Location: "..x.." "..y.." "..z
    AddPlayerChat(player, string)
    print(string)
    table.insert(ScrapLocations, { x, y, z })

    File_SaveJSONTable("packages/"..GetPackageName().."/server/data/scrap.json", ScrapLocations)
end)

AddCommand("respawnscrap", function(player)
    if not IsAdmin(player) then
        return
    end
    SpawnScrap()
end)

AddCommand("scrap", function(player)
    if not IsAdmin(player) then
        return
    end
    PickupScrap(player)
end)

AddEvent("OnPackageStart", function()
    ScrapLocations = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/scrap.json")
    SpawnScrap()
end)

function DespawnScrap()
    for _,text3d in pairs(GetAllText3D()) do
        if GetText3DPropertyValue(text3d, 'scrap') ~= nil then
            print("Despawning scrap: "..dump(text3d))
            DestroyText3D(text3d)
        end
    end
end

function SpawnScrap()
    print "Spawning scrap..."
    DespawnScrap()

    -- randomize scrap locations
    local shuffled = {}
    for i,pos in ipairs(ScrapLocations) do
        local p = math.random(1, #shuffled+1)
        table.insert(shuffled, p, pos)
    end

    -- randomly spawn a subset of scraps
    for _,pos in pairs({table.unpack(shuffled, 1, NumSpawnedScrap)}) do
        local text3d = CreateText3D("Press [E] to Search", 6, pos[1], pos[2], pos[3]+30, 0, 0, 0)
        SetText3DPropertyValue(text3d, 'scrap', true)
        print("Spawned scrap: "..dump(text3d))
    end
end

-- search for scrap
local CurrentlySearching = {}
AddRemoteEvent("SearchForScrap", function(player)
    if CurrentlySearching[player] ~= nil then
        return
    end

    local x,y,z = GetPlayerLocation(player)
    for _,text3d in pairs(GetAllText3D()) do
        if GetText3DPropertyValue(text3d, 'scrap') ~= nil then
            if IsText3DStreamedIn(player, text3d) then
                local sx, sy, sz = GetText3DLocation(text3d)
                if GetDistance3D(x, y, z, sx, sy, sz) <= 300 then

                    CallRemoteEvent(player, "SearchingScrap")
                    CurrentlySearching[player] = true
                    SetPlayerAnimation(player, "PICKUP_LOWER")

                    Delay(4000, function()
                        CurrentlySearching[player] = nil

                        -- chance to find scrap
                        if math.random(1,5) == 1 then
                            -- found something
                            SetText3DVisibility(text3d, player, false)
                            PickupScrap(player)

                            -- hide from player for 10 minutes
                            Delay(ScrapCooldown, function(text3d, player)
                                SetText3DVisibility(text3d, player, true)
                            end, text3d, player)
                        else
                            -- not found
                            AddPlayerChat(player, "You were unable to find anything useful.")
                            print("Player "..GetPlayerName(player).." searched but found nothing.")
                        end
                    end)
                end
            end
        end
    end
end)

-- add scrap to inventory
function PickupScrap(player)
    -- add to inventory
    CallEvent("AddItemToInventory", player, "scrap")

    AddPlayerChatAll(GetPlayerName(player)..' has found scrap!')
    print("Player "..GetPlayerName(player).." has found scrap!")

    CallRemoteEvent(player, "ScrapPickedup")
end


