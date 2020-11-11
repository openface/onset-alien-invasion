-- vehicle key bindings

AddEvent("OnKeyPress", function(key)
  if key == "K" then
    CallRemoteEvent("ToggleVehicleTrunk")
  elseif key == "J" then
    CallRemoteEvent("ToggleVehicleHood")
  end
end)
