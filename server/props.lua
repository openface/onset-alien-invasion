local Props = {}

function CreatePropsFromJSON(json_file, message, remote_event)

    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/server/" .. json_file)
    for _, v in pairs(_table) do
        log.debug("Creating interactive prop:", v['modelID'])
        local object = CreateObject(v['modelID'], v['x'], v['y'], v['z'], v['rx'], v['ry'], v['rz'], v['sx'], v['sy'], v['sz'])
        SetObjectPropertyValue(object, "interactive", {
            message = message,
            remote_event = remote_event
        })
        table.insert(Props, object)
    end
end

AddEvent("OnPackageStop", function()
    log.info "Destroying all interactive props..."
    for _, object in pairs(Props) do
        DestroyObject(object)
    end
end)
