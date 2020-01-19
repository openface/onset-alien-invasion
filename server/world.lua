local WorldLoaded

function World_LoadWorld()
  if WorldLoaded then return end
  WorldLoaded = true

  print('Server: Attempting to load world.')

  local _table = File_LoadJSONTable("packages/"..GetPackageName().."/server/data/world.json")
  for _,v in pairs(_table) do
    if v['modelID'] ~= nil then
      CreateObject(v['modelID'], v['x'], v['y'], v['z'], v['rx'], v['ry'], v['rz'], v['sx'], v['sy'], v['sz'])
    else
      local _AddYaw = DoorConfig[tonumber(doorID)]
      if _AddYaw == nil then
        _AddYaw = 90
      end

      CreateDoor(v['doorID'], v['x'], v['y'], v['z'], v['yaw'] + _AddYaw, true)
    end
  end

  print('Server: Alien Invasion World loaded!')
end
AddEvent('OnPackageStart', World_LoadWorld)