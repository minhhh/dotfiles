local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

local function my_on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- use all default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- remove a default
    vim.keymap.del('n', 'e', { buffer = bufnr })
    vim.keymap.del('n', 'o', { buffer = bufnr })
    vim.keymap.del('n', 's', { buffer = bufnr })

    -- override a default
    --vim.keymap.set('n', '<C-e>', api.tree.reload,                       opts('Refresh'))

    -- add your mappings
    vim.keymap.set('n', '?',     api.tree.toggle_help,                  opts('Help'))
    ---
end


nvim_tree.setup {
    update_focused_file = {
        enable = true,
        update_cwd = true,
    },
    git = {
        enable = false,
    },
    renderer = {
        root_folder_modifier = ":t",
        icons = {
            show = {
                file = false,
            },
            glyphs = {
                default = "",
                symlink = "",
                folder = {
                    arrow_open = "",
                    arrow_closed = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                    symlink_open = "",
                },
                git = {
                    unstaged = "",
                    staged = "S",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "U",
                    deleted = "",
                    ignored = "◌",
                },
            },
        },
    },
    diagnostics = {
        enable = false,
        show_on_dirs = true,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        },
    },
    view = {
        width = 30,
        side = "left",
    },
    on_attach = my_on_attach,
}
