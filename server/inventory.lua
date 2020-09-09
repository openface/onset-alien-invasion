local PartObjectID = 1437

function SyncInventory(player)
    _send = {}
    if GetPlayerPropertyValue(player, 'carryingPart') ~= nil then
        table.insert(_send, {
            quantity = 1,
            modelid = PartObjectID
        })
    end
    CallRemoteEvent(player, "SetInventory", json_encode(_send))
end
AddEvent("SyncInventory", SyncInventory)
AddRemoteEvent("SyncInventory", SyncInventory)
