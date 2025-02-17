local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

local hide_in_width = function()
	return vim.fn.winwidth(0) > 80
end

local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn" },
	symbols = { error = " ", warn = " " },
	colored = true,
	update_in_insert = false,
	always_visible = true,
}

local diff = {
	"diff",
	colored = false,
	symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
  cond = hide_in_width
}

local mode = {
	"mode",
    color = function()
        -- Depending on the current mode, return the appropriate highlight group
        local mode_color = {
            n = '#AFAF87',
            i = '#33FFFF',
            v = '#00FF00',
            [''] = '#00FF00', -- Visual block mode
            V = '#00FF00',
            c = '#FF00FF',
            R = '#FF00FF'
        }

        return { gui = "italic,bold", bg = mode_color[vim.fn.mode()] }
    end,
}


local filetype = {
	"filetype",
	icons_enabled = false,
	icon = nil,
}

local branch = {
	"branch",
	icons_enabled = true,
	icon = "",
}

local location = {
	"location",
	padding = 0,
}

-- cool function for progress
local progress = function()
	local current_line = vim.fn.line(".")
	local total_lines = vim.fn.line("$")
	local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
	local line_ratio = current_line / total_lines
	local index = math.ceil(line_ratio * #chars)
	return chars[index]
end

local spaces = function()
	return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
end

local sections =  {
		lualine_a = { mode },
		lualine_b = {},
		lualine_c = {
            {
                "diagnostics",
                symbols = {
                    error = ' ',
                    warn = ' ',
                    info = ' ',
                    hint = ' ',
                },
                colored = true,           -- Displays diagnostics status in color if set to true.
                update_in_insert = false, -- Update diagnostics in insert mode.
                always_visible = false,   -- Show diagnostics even if there are none.
            },
            {
                'filename',
                file_status = true,      -- Displays file status (readonly status, modified status)
                newfile_status = false,  -- Display new file status (new file means no write after created)
                path = 3,                -- 0: Just the filename
                                       -- 1: Relative path
                                       -- 2: Absolute path
                                       -- 3: Absolute path, with tilde as the home directory
                                       -- 4: Filename and parent dir, with tilde as the home directory

                shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                                       -- for other components. (terrible name, any suggestions?)
                symbols = {
                    modified = '[+]',      -- Text to show when the file is modified.
                    readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
                    unnamed = '[No Name]', -- Text to show for unnamed buffers.
                    newfile = '[New]',     -- Text to show for newly created file before first write
                }
            }
        },
		-- lualine_x = { "encoding", "fileformat", "filetype" },
		-- lualine_x = { diff, spaces, "encoding", filetype },
		lualine_x = {},
		lualine_y = {
            { "filetype", separator = "|" },
            {
              "encoding",
              separator = { left = "" },
              padding = { left = 1, right = 0 },
              color = { fg = 15, bg = 240 },
            },
            {
              "fileformat",
              separator = { left = "" },
              { left = 0, right = 0 },
              symbols = {
                unix = "[unix]",
                dos = "[dos]",
                mac = "[mac]",
              },
              color = { fg = 15, bg = 240 },
            },
        },
		lualine_z = {
            { "location", padding = { left = 0, right = 0 }, color = { fg = 0, bg = 179, gui = "italic,bold" }  },
            { "progress", separator = " ", padding = { left = 1, right = 0 }, color = { fg = 0, bg = 179, gui = "italic,bold" } },
            { "%L", padding = { left = 1, right = 0 }, color = { fg = 0, bg = 179, gui = "italic,bold" } },
        },
	}

lualine.setup({
	options = {
		icons_enabled = true,
		theme = "papercolor_light",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
		always_divide_middle = true,
	},
	sections = sections,
    inactive_sections = sections,
	tabline = {},
	extensions = {},
})
