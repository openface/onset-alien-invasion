local Props = {}

function CreateProp(config, options)
    log.debug("Creating interactive prop:", config['modelID'])
    local object = CreateObject(config['modelID'], config['x'], config['y'], config['z'], config['rx'], config['ry'],
                       config['rz'], config['sx'], config['sy'], config['sz'])
    SetObjectPropertyValue(object, "prop", options)
    table.insert(Props, object)
end

AddEvent("OnPackageStop", function()
    log.info "Destroying all interactive props..."
    for _, object in pairs(Props) do
        DestroyObject(object)
    end
end)

--
-- Foliage
--

AddRemoteEvent("HarvestTree", function(player)
  log.debug("harvesting tree")
  if GetInventoryCount(player, "axe") == 0 then
    AddPlayerChat(player, "You need an axe to harvest this!")
    CallRemoteEvent(player, "PlayErrorSound")
    return
  end

  UseItemFromInventory(player, "axe")

  Delay(5000, function()
      AddPlayerChat(player, "You collect some wood")
      AddToInventory(player, "wood")
  end)

end)
