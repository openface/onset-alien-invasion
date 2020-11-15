Player = {}
Player.__index = Player

function Player.IsAdmin(player)
    steam_id = GetPlayerSteamId(player)
    for _, id in ipairs(Config.admin_steam_ids) do
        if id == steam_id then
            return true
        end
    end
    return false
end
