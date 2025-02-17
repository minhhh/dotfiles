local status_ok, webdevicons = pcall(require, "nvim-web-devicons")
if not status_ok then
    return
end

webdevicons.setup({})

