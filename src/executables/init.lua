---@type { [string] : fun(objects: Module[], cmods: Module[], to: string, config: Config) }
local export = {
    ["self-extract"] = require("executables.self-extract")
}

return export