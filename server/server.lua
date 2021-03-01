SafeZoneLocation = {
    x = -103250.671875,
    y = 195288.359375,
    z = 1307.6508789062
}
SafeZoneRange = 5000

AddCommand("pos", function(player)
    if not IsAdmin(GetPlayerSteamId(player)) then
        return
    end
    local x, y, z = GetPlayerLocation(player)
    local heading = GetPlayerHeading(player)
    string = "Location: " .. x .. " " .. y .. " " .. z .. " Heading: " .. heading
    AddPlayerChat(player, string)
    log.debug(string)
end)

AddCommand("players", function(player)
    for _, v in pairs(GetAllPlayers()) do
        AddPlayerChat(player, '[' .. v .. '] ' .. GetPlayerName(v))
    end
end)

AddCommand("anim", function(player, anim)
    log.debug("Animation:", anim)
    SetPlayerAnimation(player, "STOP")
    if not anim then
        return
    end
    if tonumber(anim) ~= nil then
        SetPlayerAnimation(player, tonumber(anim))
    else
        SetPlayerAnimation(player, string.upper(anim))
    end
end)

-- console input from client
AddRemoteEvent("ConsoleInput", function(player, input)
    if not IsAdmin(GetPlayerSteamId(player)) then
        return
    end

    if input == "stats" then
        print("Objects: " .. tostring(GetObjectCount()))
    end

    log.debug("console: " .. input)
end)

AddEvent("OnConsoleInput", function(input)
    if input == "" then
        return
    end
    if input == "quit" or input == "exit" then
        ServerExit("Exiting via console command")
    end
    -- run lua
    load(input)()
end)

