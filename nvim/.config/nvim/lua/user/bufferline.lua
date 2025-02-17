local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup {
  options = {
    numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
    close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
    right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
    middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
    -- NOTE: this plugin is designed with this icon in mind,
    -- and so changing this is NOT recommended, this is intended
    -- as an escape hatch for people who cannot bear it for whatever reason
	indicator_icon = nil,
    indicator = { style = "none", icon = "▎"},
    buffer_close_icon = '',
    modified_icon = "[●]",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    --- name_formatter can be used to change the buffer's label in the bufferline.
    --- Please note some names can/will break the
    --- bufferline so use this at your discretion knowing that it has
    --- some limitations that will *NOT* be fixed.
    name_formatter = function(buf)
      local max_length = 19  -- Define the maximum length of the displayed path
      local full_path = vim.fn.fnamemodify(buf.path, ':p')  -- Get the full path
      local path = vim.fn.fnamemodify(full_path, ':.')
      local result = {}
      -- Split the path into segments
      for segment in string.gmatch(path, "[^/]+") do
          if #segment > 1 then
              -- Add the first character of each segment except the last one
              table.insert(result, string.sub(segment, 1, 1))
          else
              -- Add the whole segment if it's only one character long
              table.insert(result, segment)
          end
      end
      -- Replace the last segment with the full last segment (file name)
      result[#result] = path:match("[^/]+$")
      -- Join the parts together
      path = table.concat(result, "/")

      if #path > max_length then
        -- If the path is too long, truncate from the start and keep the end part
        return '..' .. string.sub(path, #path - max_length + 3)
      else
        return path  -- If it's short enough, show the full path
      end
    end,
    max_name_length = 30,
    -- max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
    truncate_names = false, -- whether or not tab names should be truncated
    tab_size = 25,
    diagnostics = false, -- | "nvim_lsp" | "coc",
    diagnostics_update_in_insert = false,
    -- diagnostics_indicator = function(count, level, diagnostics_dict, context)
    --   return "("..count..")"
    -- end,
    -- NOTE: this will be called a lot so don't do any heavy processing here
    -- custom_filter = function(buf_number)
    --   -- filter out filetypes you don't want to see
    --   if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
    --     return true
    --   end
    --   -- filter out by buffer name
    --   if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
    --     return true
    --   end
    --   -- filter out based on arbitrary rules
    --   -- e.g. filter out vim wiki buffer from tabline in your work repo
    --   if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
    --     return true
    --   end
    -- end,
    offsets = { { filetype = "NvimTree", text = "", padding = -30, separator = false } }, -- Use the NVimtree tab for displaying
    show_buffer_icons = true,
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = false,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = "thin", -- | "thick" | "thin" | { 'any', 'any' },
    enforce_regular_tabs = true,
    always_show_bufferline = true,
    -- sort_by = 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
    --   -- add custom logic
    --   return buffer_a.modified > buffer_b.modified
    -- end
  },
  highlights = {
    fill = {
      fg = "#5F87AF",
      bg = "#5F87AF",
    },
    background = {
      fg = "#DADADA",
      bg = "#5F87AF",
    },

    buffer_selected = {
      fg = "#141411",
      bg = "#AFAF87",
    },

    buffer_visible = {
      fg = "#141411",
      bg = "#FEFEFE",
    },

    close_button = {
      fg = "#800080",
      bg = "#5F87AF",
    },
    close_button_visible = {
      fg = "#141411",
      bg = "#FEFEFE",
    },
    close_button_selected = {
      fg = "#141411",
      bg = "#AFAF87"
    },

    tab_selected = {
      fg = { attribute = "fg", highlight = "Normal" },
      bg = { attribute = "bg", highlight = "Normal" },
    },
    tab = {
      fg = { attribute = "fg", highlight = "TabLine" },
      bg = { attribute = "bg", highlight = "TabLine" },
    },
    tab_close = {
      -- fg = {attribute='fg',highlight='LspDiagnosticsDefaultError'},
      fg = { attribute = "fg", highlight = "TabLineSel" },
      bg = { attribute = "bg", highlight = "Normal" },
    },

    duplicate_selected = {
      fg = { attribute = "fg", highlight = "TabLineSel" },
      bg = { attribute = "bg", highlight = "TabLineSel" },
      underline = true,
    },
    duplicate_visible = {
      fg = { attribute = "fg", highlight = "TabLine" },
      bg = { attribute = "bg", highlight = "TabLine" },
      underline = true,
    },
    duplicate = {
      fg = { attribute = "fg", highlight = "TabLine" },
      bg = { attribute = "bg", highlight = "TabLine" },
      underline = true,
    },

    modified = {
      fg = "#11eeee",
      bg = "#5F87AF",
    },
    modified_selected = {
      fg = "#11eeee",
      bg = "#AFAF87",
    },
    modified_visible = {
      fg = "#11eeee",
      bg = "#FEFEFE",
    },

    separator = {
      fg = "#DADADA",
      bg = "#5F87AF",
    },
    -- separator_selected = {
    --   fg = "#FF00FF",
    --   bg = "#AFAF87",
    -- },
    separator_visible = {
      fg = "#FF00FF",
      bg = "#FF00FF",
    },
    indicator_visible = {
      fg = "#FEFEFE",
      bg = "#FEFEFE",
    },
    indicator_selected = {
      bg = "#AFAF87",
      bg = "#AFAF87",
    },
  },
}
