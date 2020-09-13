local WorkbenchLoc = { x = -105858.1328125, y = 193734.21875, z = 1396.1424560547 }

AddEvent("OnPackageStart", function()
    -- workbench
    CreateText3D("Press [E] to Interact", 10, WorkbenchLoc.x, WorkbenchLoc.y, WorkbenchLoc.z + 130, 0,0,0)
end)