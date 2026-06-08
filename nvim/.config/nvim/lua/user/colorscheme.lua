local colorscheme = "PaperColor"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  return
end

vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff0000', bg = 'none' })
