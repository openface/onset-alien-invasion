local ScoreboardUI

AddEvent("OnPackageStart", function()
  ScoreboardUI = CreateWebUI(0.0, 0.0, 0.0, 0.0, 1, 60)
  SetWebAnchors(ScoreboardUI, 0.0, 0.0, 1.0, 1.0)
  SetWebUrl(ScoreboardUI, 'http://asset/' .. GetPackageName() .. '/ui/dist/index.html#/scoreboard/')
  SetWebVisibility(ScoreboardUI, WEB_HIDDEN)
end)

AddEvent("OnPackageStop", function()
    DestroyWebUI(ScoreboardUI)
end)

AddEvent('OnKeyPress', function(key)
  if key == 'P' then
    CallRemoteEvent('UpdateScoreboardData')
    SetWebVisibility(ScoreboardUI, WEB_HITINVISIBLE)
  end
end)

AddEvent('OnKeyRelease', function(key)
  if key == 'P' then
    SetWebVisibility(ScoreboardUI, WEB_HIDDEN)
  end
end)

AddRemoteEvent('OnGetScoreboardData', function(players)
  if players == nil then 
    return 
  end

  ExecuteWebJS(ScoreboardUI, "EmitEvent('LoadOnlinePlayers',"..players..")")
end)
