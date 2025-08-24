-- Daily Notes System
-- Lightweight note-taking system with tag support

local M = {}

-- Configuration
M.config = {
    notes_dir = vim.fn.expand('~/Documents/daily-notes')
}

-- Create notes directory if it doesn't exist
local function ensure_notes_dir()
    vim.fn.mkdir(M.config.notes_dir, 'p')
end

-- Function to open today's daily note
function M.open_daily_note()
    ensure_notes_dir()
    
    local date = os.date('%Y-%m-%d')
    local filename = M.config.notes_dir .. '/' .. date .. '.md'
    vim.cmd('edit ' .. filename)
    
    -- Add template if file is empty
    if vim.fn.getfsize(filename) <= 0 then
        local lines = {
            '# ' .. date,
            '',
            '## Morning Standup #standup',
            '- ',
            '',
            '## Client Meetings #meetings',
            '- ',
            '',
            '## Project Alpha Work #project-alpha',
            '- ',
            '',
            '## Urgent Issues #urgent',
            '- ',
            '',
            '## General Tasks',
            '- [ ] ',
            '- [ ] ',
            '',
            '## Notes',
            ''
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.cmd('write')
    end
end

-- Function to search for tags across all daily notes
function M.search_tags()
    ensure_notes_dir()
    
    local builtin = require('telescope.builtin')
    builtin.live_grep({
        prompt_title = 'Search Tags in Daily Notes',
        cwd = M.config.notes_dir,
        default_text = '#',
        additional_args = function()
            return {'--type', 'md'}
        end
    })
end

-- Function to generate tag report
function M.generate_tag_report(tag)
    ensure_notes_dir()
    
    if not tag or tag == '' then
        tag = vim.fn.input('Enter tag (without #): ')
    end
    
    if tag == '' then return end
    
    -- Get all markdown files in the notes directory
    local files = vim.fn.glob(M.config.notes_dir .. '/*.md', false, true)
    
    if #files == 0 then
        print('No markdown files found in: ' .. M.config.notes_dir)
        return
    end
    
    local search_pattern = '#' .. tag
    local report_entries = {}
    
    -- Search through each file for tagged sections
    for _, file_path in ipairs(files) do
        local file_handle = io.open(file_path, 'r')
        if file_handle then
            local all_lines = {}
            for line in file_handle:lines() do
                table.insert(all_lines, line)
            end
            file_handle:close()
            
            local date = vim.fn.fnamemodify(file_path, ':t:r')  -- Get filename without extension
            
            -- Find tagged headings and capture their sections
            for i, line in ipairs(all_lines) do
                -- Check if this is a heading with our tag
                if line:match('^#+%s+.*' .. search_pattern) then
                    local heading_level = #line:match('^#+')
                    local section_content = {}
                    
                    -- Extract the heading without the tag
                    local heading_text = line:gsub(search_pattern, ''):gsub('%s+$', '')
                    table.insert(section_content, heading_text)
                    
                    -- Collect all content under this heading until we hit another heading of same or higher level
                    for j = i + 1, #all_lines do
                        local next_line = all_lines[j]
                        local next_heading_level = next_line:match('^#+')
                        
                        -- Stop if we hit another heading of same or higher level
                        if next_heading_level and #next_heading_level <= heading_level then
                            break
                        end
                        
                        -- Add all lines (including empty ones for proper formatting)
                        table.insert(section_content, next_line)
                    end
                    
                    -- Only add if there's content beyond just the heading
                    if #section_content > 1 then
                        table.insert(report_entries, {
                            date = date,
                            content = section_content
                        })
                    end
                end
            end
        end
    end
    
    if #report_entries == 0 then
        print('No tagged headings found for: #' .. tag)
        return
    end
    
    -- Sort entries by date
    table.sort(report_entries, function(a, b) return a.date < b.date end)
    
    -- Create new buffer for report
    vim.cmd('new')
    local buf = vim.api.nvim_get_current_buf()
    
    local report_lines = {'# ' .. tag:upper() .. ' Report', '', ''}
    
    for _, entry in ipairs(report_entries) do
        table.insert(report_lines, '## ' .. entry.date)
        table.insert(report_lines, '')
        
        -- Add the section content
        for _, content_line in ipairs(entry.content) do
            table.insert(report_lines, content_line)
        end
        
        table.insert(report_lines, '')
    end
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, report_lines)
    vim.bo.filetype = 'markdown'
    vim.bo.buftype = 'nofile'
    vim.bo.bufhidden = 'wipe'
end

-- Setup function to initialize keymaps
function M.setup()
    vim.keymap.set('n', '<leader>j', M.open_daily_note, { desc = 'Open daily note' })
    vim.keymap.set('n', '<leader>ft', M.search_tags, { desc = 'Search tags in daily notes' })
    vim.keymap.set('n', '<leader>fr', function() M.generate_tag_report() end, { desc = 'Generate tag report' })
end

return M