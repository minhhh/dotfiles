local status_ok, comment = pcall(require, "Comment")
if not status_ok then
  return
end

comment.setup {
  pre_hook = function()
    local ft = vim.bo.filetype
    if ft == "python" then
      return "# %s"
    end
  end,
}
