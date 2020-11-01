local Objects = {}
local Doors = {}

AddEvent("OnPackageStart", function()
  if IsPackageStarted('sandbox') then 
    log.warn("Not loading alien invasion world because sandbox package is loaded.") 
    return
  end

  log.info("Loading world...")

  local _table = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/world.json")
  for _,v in pairs(_table) do
    if v['modelID'] ~= nil then
      --log.debug("Creating object:",v['modelID'])
      table.insert(Objects, CreateObject(v['modelID'], v['x'], v['y'], v['z'], v['rx'], v['ry'], v['rz'], v['sx'], v['sy'], v['sz']))
    else
      --log.debug("Creating door:",v['doorID'])
      table.insert(Doors, CreateDoor(v['doorID'], v['x'], v['y'], v['z'], v['yaw'], true))
    end
  end
  log.info("Alien Invasion world loaded!")
end)

AddEvent("OnPackageStop", function()
  log.info("Destroying world...")

  for _,object in pairs(Objects) do
    DestroyObject(object)
  end
  for _,door in pairs(Doors) do
    DestroyDoor(object)
  end
end)
