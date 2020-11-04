local Props = {}

function CreatePropsFromJSON(json_file, options)
    local _table = File_LoadJSONTable("packages/" .. GetPackageName() .. "/server/" .. json_file)
    for _, v in pairs(_table) do
        CreateProp(v, options)
    end
end

function CreateProp(config, options)
    -- log.debug("Creating interactive prop:", config['modelID'], dump(options))
    local object = CreateObject(config['modelID'], config['x'], config['y'], config['z'], config['rx'], config['ry'],
                       config['rz'], config['sx'], config['sy'], config['sz'])
    SetObjectPropertyValue(object, "prop", options)
    table.insert(Props, object)
end

AddEvent("OnPackageStop", function()
    log.info "Destroying all interactive props..."
    for _, object in pairs(Props) do
        DestroyObject(object)
    end
end)
