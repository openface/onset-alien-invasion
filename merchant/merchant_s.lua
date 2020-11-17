local Merchants = {}

AddEvent("OnPackageStart", function()
    log.info("Loading merchants...")

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/server/data/merchants.json")
    for _, config in pairs(_table) do
        -- todo: merchant name is hardcoded for now
        RegisterMerchant("Store", config)
    end
end)

AddEvent("OnPackageStop", function()
    log.info "Destroying all merchants..."
    for _, object in pairs(Merchants) do
        DestroyObject(object)
    end
end)

function RegisterMerchant(name, config)
    log.debug("Registering merchant: " .. name)
    local object = CreateObject(config['modelID'], config['x'], config['y'], config['z'], config['rx'],
                           config['ry'], config['rz'], config['sx'], config['sy'], config['sz'])
    SetObjectPropertyValue(object, "prop", { message = "Interact", remote_event = "GetMerchantData" })
    Merchants[object] = true
end

AddRemoteEvent("prop:GetMerchantData", function(player)
    local item_data = {}
    for key, item in pairs(GetItemConfigs()) do
        if item['price'] ~= nil then
            table.insert(item_data, {
                item = key,
                name = item['name'],
                category = item['category'],
                modelid = item['modelid'],
                image = item['image'],
                price = item['price']
            })
        end
    end

    local _send = {
        ["merchant_items"] = item_data,
        ["player_cash"] = 10 -- TODO
    }
    -- log.debug(dump(json_encode(_send)))
    CallRemoteEvent(player, "LoadMerchantData", json_encode(_send))
end)

AddRemoteEvent("BuyItem", function(player, item)
    local item_cfg = GetItemConfig(item)
    if item_cfg == nil then
        return
    end

    log.debug("Player " .. GetPlayerName(player) .. " buys item " .. item_cfg['name'])

    if item_cfg['max_carry'] ~= nil and GetInventoryCount(player, item) >= item_cfg['max_carry'] then
        log.debug("Pickup exceeds max_carry")
        AddPlayerChat(player, "You cannot carry anymore of this item!")
        CallRemoteEvent(player, "PurchaseDenied")
        return
    elseif GetInventoryAvailableSlots(player) <= 0 then
        log.debug("Pickup exceeded max inventory slots")
        AddPlayerChat(player, "Your inventory is full!")
        CallRemoteEvent(player, "PurchaseDenied")
        return
    end

    -- TODO: remove money from player

    -- SetPlayerLocation(player, -105738.5859375, 193734.59375, 1396.1424560547) 
    -- SetPlayerHeading(player, -92.786437988281)   
    -- SetPlayerAnimation(player, "BARCLEAN01")
    Delay(4000, function()
        -- SetPlayerAnimation(player, "STOP")
        AddPlayerChat(player, "Purchase is complete.")

        CallRemoteEvent(player, "CompletePurchase", json_encode(
            {
                player_cash = 10
            }))

        PlaySoundSync(player, "sounds/purchase.mp3")

        AddToInventory(player, item)
    end)
end)
