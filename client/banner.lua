local BannerUI

AddEvent("OnPackageStart", function()
    BannerUI = CreateWebUI(0.0, 0.0, 0.0, 0.0)
    LoadWebFile(BannerUI, "http://asset/"..GetPackageName().."/client/ui/banner/banner.html")
    SetWebAlignment(BannerUI, 0.0, 0.0)
    SetWebAnchors(BannerUI, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(BannerUI, WEB_HIDDEN)
end)

function ShowBanner(msg, duration)
    ExecuteWebJS(BannerUI, "ShowBanner('"..msg.."')")
    SetWebVisibility(BannerUI, WEB_VISIBLE)

    Delay(duration, function()
        ExecuteWebJS(BannerUI, "HideBanner()")
        SetWebVisibility(BannerUI, WEB_HIDDEN)
    end)
end
AddFunctionExport("ShowBanner", ShowBanner)
    
AddRemoteEvent("ShowBanner", function(msg, duration)
    ShowBanner(msg, duration)
end)
