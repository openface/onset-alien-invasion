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
      local object = CreateObject(v['modelID'], v['x'], v['y'], v['z'], v['rx'], v['ry'], v['rz'], v['sx'], v['sy'], v['sz'])
      if v['modelID'] == 582 then
        local component = {
          type = "pointlight",
          position = { x = 0, y = 66.3, z = 147.6, rx = 0, ry = 86.6, rz = 0 },
          intensity = 10000
        }
        SetObjectPropertyValue(object, "component", component)
        log.debug("Adding light component to model",v['modelID'])
      end
      --log.debug("Creating object:",v['modelID'])
      table.insert(Objects, object)
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
    -- TODO: need to destroy components too or is this automatic?
  end
  for _,door in pairs(Doors) do
    DestroyDoor(object)
  end
end)
