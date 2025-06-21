local M = {}

-- Default configuration
local default_config = {
    highlight_group = "VisualMatches",
    highlight_color = "#3a3a3a",
    enable_in_visual = true,
    enable_in_line = true,
    enable_in_block = true,
}

-- State variables
local hl_group = default_config.highlight_group
local namespace = vim.api.nvim_create_namespace("visual_matches")
local last_pattern = nil
local current_matches = {}

-- 1. BRUTE FORCE SEARCH IMPLEMENTATION
-- This is the core matching algorithm (will be replaced with Boyer-Moore later)
local function brute_force_search(bufnr, pattern)

    -- Skip empty patterns
    if #pattern == 0 then return {} end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local matches = {}
    local pattern_len = #pattern

    for line_num, line in ipairs(lines) do
        local line_idx = line_num - 1  -- Convert to 0-based

        -- Search the whole line for our pattern
        for i = 1, #line - pattern_len + 1 do
            local substring = line:sub(i, i + pattern_len - 1)
            if substring == pattern then
                table.insert(matches, {
                    line = line_idx,
                    start_col = i - 1,  -- 0-based
                    end_col = (i - 1) + pattern_len
                })
            end
        end
    end

    return matches
end

-- 2. VISUAL SELECTION EXTRACTION
local function get_visual_selection()
    local mode = vim.fn.mode()
    if not (mode == "v" or mode == "V" or mode == "") then
        return nil
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local start_pos = vim.fn.getpos("v")  -- Visual start position
    local end_pos = vim.fn.getpos(".")    -- Current cursor position

    -- Normalize positions (start before end)
    local start_line, start_col = start_pos[2] - 1, start_pos[3] - 1
    local end_line, end_col = end_pos[2] - 1, end_pos[3] - 1

    if start_line > end_line or (start_line == end_line and start_col > end_col) then
        start_line, end_line = end_line, start_line
        start_col, end_col = end_col, start_col
    end

    -- Handle different visual modes
    if mode == "V" then  -- Line-wise
        start_col = 0
        end_col = #vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1]
    elseif mode == "" then  -- Block-wise
        if start_col > end_col then
            start_col, end_col = end_col, start_col
        end
        end_col = end_col + 1  -- Make inclusive
    else  -- Character-wise
        end_col = end_col + 1
    end

    -- Extract and return the selected text
    local lines = vim.api.nvim_buf_get_text(bufnr, start_line, start_col, end_line, end_col, {})
    return table.concat(lines, "\n")
end

-- 3. HIGHLIGHT UPDATE LOGIC
local function update_highlights()
    local bufnr = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()

    -- Clear previous highlights
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    current_matches = {}

    -- Only proceed in visual modes
    if not (mode == "v" or mode == "V" or mode == "") then
        last_pattern = nil
        return
    end

    -- Get current selection pattern
    local pattern = get_visual_selection()
    if not pattern or #pattern == 0 or pattern == last_pattern then
        return
    end
    last_pattern = pattern

    -- Find all matches using brute force
    current_matches = brute_force_search(bufnr, pattern)

    -- Apply highlights to all matches
    for _, match in ipairs(current_matches) do
        vim.api.nvim_buf_add_highlight(
            bufnr,
            namespace,
            hl_group,
            match.line,
            match.start_col,
            match.end_col
        )
    end
end

-- Plugin setup function
function M.setup(config)
    -- Merge user config with defaults
    config = vim.tbl_deep_extend("force", default_config, config or {})

    -- Initialize highlight group
    hl_group = config.highlight_group
    vim.api.nvim_command('highlight ' .. hl_group .. ' guibg=' .. config.highlight_color)

    -- Set up autocommands
    local group = vim.api.nvim_create_augroup("VisualHighlight", { clear = true })

    vim.api.nvim_create_autocmd({"ModeChanged", "CursorMoved", "CursorMovedI"}, {
        group = group,
        callback = function()
            local mode = vim.fn.mode()
            if mode:match("[vV]") then
                update_highlights()
            else
                -- Clear highlights when leaving visual mode
                local bufnr = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
            end
        end
    })
end

return M
