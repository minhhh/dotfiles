local colorscheme = "onelight"

if colorscheme == "catppuccin" then
  local ok, _ = pcall(require, "catppuccin")
  if ok then
    require("catppuccin").setup({ flavour = "latte" })
  end
elseif colorscheme == "onedark" or colorscheme == "onelight" then
  local ok, _ = pcall(require, "onedarkpro")
  if ok then
    require("onedarkpro").setup({})
  end
elseif colorscheme == "onenord" then
  local ok, _ = pcall(require, "onenord")
  if ok then
    require("onenord").setup({ theme = "light" })
  end
end

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  return
end

vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff0000', bg = 'none' })

if colorscheme == "onelight" or colorscheme == "onedark" then
  vim.api.nvim_set_hl(0, '@markup.heading.3.markdown', { fg = '#d46a7a', bold = true })
end
