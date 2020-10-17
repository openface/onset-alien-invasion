local lr = ImportPackage("lightstreamer")

RegisterObject("flashlight", {
    name = "Flashlight",
    type = 'equipable',
    modelid = 1271, 
    max_carry = 1,
    recipe = {
        metal = 10,
        plastic = 5,
        computer_part = 1
    },
    attachment = { 
        x = 33, 
        y = -8, 
        z = 0, 
        rx = 360, 
        ry = 260, 
        rz = -110, 
        bone = "hand_l" 
    }
})

AddEvent("items:flashlight:attach", function(player, object)
  local x, y, z = GetPlayerLocation(player)
  local light = lr.CreateLight("POINTLIGHT", x, y, z)
  lr.SetLightAttached(light, ATTACH_OBJECT, object)
end)

AddEvent("items:flashlight:detach", function(player, object)
  DestroyLightsOnObject(object)
end)

AddEvent("OnObjectDestroyed", function(object)
  if GetObjectPropertyValue(object, "_name") ~= "flashlight" then
    return
  end
  DestroyLightsOnObject(object)
end)

function DestroyLightsOnObject(object)
  local attached_lights = lr.GetAttachedLights(ATTACH_OBJECT, object)
  for _, light in pairs(attached_lights) do
    lr.SetLightDetached(light)
    lr.DestroyLight(light)
  end
end