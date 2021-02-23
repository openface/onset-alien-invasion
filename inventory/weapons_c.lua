AddEvent('OnKeyPress', function(key)
    if key == 'R' then
        if not IsPlayerReloading(GetPlayerId()) then
            CallRemoteEvent("ReloadWeapon")
        end
    end
end)