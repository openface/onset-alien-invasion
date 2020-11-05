AddEvent("OnPackageStart", function()
  log.info("Loading merchants...")

  local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/server/data/merchants.json")
  for _, v in pairs(_table) do
      CreateProp(v, { message = "Hit [E] to Interact", remote_event = "GetMerchantData" })
  end
end)

AddRemoteEvent("GetMerchantData", function(player)
    local item_data = {}
    for key,item in pairs(GetItemConfigs()) do
        if item['price'] ~= nil then
            table.insert(item_data, {
                item = key,
                name = item['name'],
                modelid = item['modelid'],
                price = item['price']
            })
        end
    end

    local _send = {
        ["merchant_items"] = item_data,
        ["player_cash"] = 10 -- TODO
    }
    --log.debug(dump(json_encode(_send)))
    CallRemoteEvent(player, "LoadMerchantData", json_encode(_send))
end)

AddRemoteEvent("BuyItem", function(player, item)
    local item_cfg = GetItemConfig(item)
    if item_cfg == nil then
        return
    end

    log.debug("Player "..GetPlayerName(player).." buys item "..item_cfg['name'])

    -- TODO: remove money from player

    -- TODO: PlaySoundSync


    --SetPlayerLocation(player, -105738.5859375, 193734.59375, 1396.1424560547) 
    --SetPlayerHeading(player, -92.786437988281)   
    --SetPlayerAnimation(player, "BARCLEAN01")
    Delay(3000, function()
        --SetPlayerAnimation(player, "STOP")
        AddPlayerChat(player, "Purchase is complete.")

        CallRemoteEvent(player, "CompletePurchase", item, json_encode({
          player_cash = 10
        }))
        -- TODO: adjust player inventory
        --AddToInventory(player, item)
    end)
end)
