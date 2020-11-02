AddEvent("OnPackageStart", function()
  log.info("Loading scrap heaps...")
  CreatePropsFromJSON("data/storages.json", { message = "Hit [E] to Open", remote_event = "OpenStorage" })
end)

AddRemoteEvent("OpenStorage", function(player)

  log.info "opening storage..."
  PlaySoundSync(player, "sounds/storage_open.wav")
end)


