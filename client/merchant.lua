local MerchantUI
local merchant_timer

AddEvent("OnPackageStart", function()
    MerchantUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    SetWebURL(MerchantUI, "http://asset/"..GetPackageName().."/ui/dist/index.html#/merchant/")
    SetWebAlignment(MerchantUI, 0.0, 0.0)
    SetWebAnchors(MerchantUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(MerchantUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(MerchantUI)
end)

-- merchant data from server
AddRemoteEvent("LoadMerchantData", function(data)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetWebVisibility(MerchantUI, WEB_VISIBLE)

    ExecuteWebJS(MerchantUI, "EmitEvent('LoadMerchantData',"..data..")")

    local x,y,z = GetPlayerLocation(GetPlayerId())
    merchant_timer = CreateTimer(ShowMerchantTimer, 1000, { x = x, y = y, z = z })
end)

-- timer used to hide workbench screen once player walks away
function ShowMerchantTimer(loc)
  local x,y,z = GetPlayerLocation(GetPlayerId())
  if GetDistance3D(x, y, z, loc.x, loc.y, loc.z) > 100 then
      ShowMouseCursor(false)
      SetInputMode(INPUT_GAME)
      SetWebVisibility(MerchantUI, WEB_HIDDEN)
      DestroyTimer(merchant_timer)
  end
end

-- selected item to build from UI
AddEvent("BuyItem", function(item)
    CallRemoteEvent("BuyItem", item)    
end)

AddRemoteEvent("CompletePurchase", function(data)
    ExecuteWebJS(MerchantUI, "EmitEvent('CompletePurchase',"..data..")")
end)

AddRemoteEvent("PurchaseDenied", function()
  ExecuteWebJS(MerchantUI, "EmitEvent('PurchaseDenied')")
  SetSoundVolume(CreateSound("client/sounds/error.wav"), 0.5)
end)

-- clicks while navigating merchant items
AddEvent('PlayClick', function()
    SetSoundVolume(CreateSound("client/sounds/click.wav"), 0.2)
end)
