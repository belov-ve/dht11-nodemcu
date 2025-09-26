do
    local response = "<html><head><meta charset=\"utf-8\"></head><body><h4>BVE HTTP Server ver 1.2</h4>"
    if Model then response = response .. string.format("<b>Model:</b> %s\n", Model) end
    if ModelVersion then response = response .. string.format("<br/><b>Model version:</b> %s\n", ModelVersion) end
    if Config and Config.name then response = response .. string.format("<br/><b>Node name:</b> %s\n", Config.name) end
    if Config and Config.friendly_name then response = response .. string.format("<br/><b>Friendly name:</b> %s\n", Config.friendly_name) end
    if ModelManufacturer then response = response .. string.format("<br/><b>Manufacturer:</b> %s\n", ModelManufacturer) end
    return response .. "<hr/></body></html>"
end
