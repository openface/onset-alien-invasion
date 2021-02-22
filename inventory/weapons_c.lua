AddEvent('OnKeyPress', function(key)
    if IsShiftPressed() or IsAltPressed() or EditingObject or GetWebVisibility(InventoryUI) == WEB_HIDDEN then
        return
    end
    if key == 'R' then
        if not IsPlayerReloading(GetPlayerId()) then
            CallRemoteEvent("ReloadWeapon")
        end
    end
end)