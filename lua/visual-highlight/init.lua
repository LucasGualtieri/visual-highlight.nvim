local M = {}

function M.setup(config)
    -- Forward the config to the core module
    require('visual-highlight.core').setup(config or {})
end

return M
