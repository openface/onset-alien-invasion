local Storages = {}
local StorageLocations = {
  { x = -103740.4765625, y = 192622.484375, z = 1215 }
}


AddEvent("OnPackageStart", function()
  for _,loc in pairs(StorageLocations) do
    local storage = CreateObject(1013, loc.x, loc.y, loc.z)
    Storages[storage] = storage
  end
end)

AddEvent("OnPackageStop", function()
  for _,s in pairs(Storages) do
    DestroyObject(s)
  end
end)

