local ScoreboardUI

AddEvent("OnPackageStart", function()
  ScoreboardUI = CreateWebUI(0.0, 0.0, 0.0, 0.0, 1, 60)
  SetWebAnchors(ScoreboardUI, 0.0, 0.0, 1.0, 1.0)
  LoadWebFile(ScoreboardUI, 'http://asset/' .. GetPackageName() .. '/client/ui/scoreboard/scoreboard.html')
  SetWebVisibility(ScoreboardUI, WEB_HIDDEN)
end)

AddEvent('OnKeyPress', function(key)
  if key == 'Tab' then
    CallRemoteEvent('UpdateScoreboardData')
    SetWebVisibility(ScoreboardUI, WEB_HITINVISIBLE)
  end
end)

AddEvent('OnKeyRelease', function(key)
  if key == 'Tab' then
    SetWebVisibility(ScoreboardUI, WEB_HIDDEN)
  end
end)

AddRemoteEvent('OnGetScoreboardData', function(players)
  if players == nil then 
    return 
  end

  ExecuteWebJS(ScoreboardUI, "EmitEvent('LoadOnlinePlayers',"..players..")")
end)
