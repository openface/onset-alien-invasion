AddEvent("OnPackageStart", function()
  log.info("Loading scrap heaps...")
  CreatePropsFromJSON("data/storages.json", "Hit [E] to Open", "OpenStorage")
end)

AddRemoteEvent("OpenStorage", function(player)

  log.info "opening storage..."
end)


