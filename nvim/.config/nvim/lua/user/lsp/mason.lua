local servers = {
	"lua_ls",
	"cssls",
	"html",
	"ts_ls",
	"pyright",
	-- "bashls",
	"jsonls",
	-- "yamlls",
}

local settings = {
	ui = {
		border = "none",
		icons = {
			package_installed = "◍",
			package_pending = "◍",
			package_uninstalled = "◍",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
}

local on_attach = require("user.lsp.handlers").on_attach
local capabilities = require("user.lsp.handlers").capabilities

require("mason").setup(settings)
require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_enable = true,
})

vim.lsp.config("*", {
	on_attach = on_attach,
	capabilities = capabilities,
})

for _, server in pairs(servers) do
	local server_name = vim.split(server, "@")[1]
	local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server_name)
	if require_ok then
		local config = {}
		if conf_opts.settings then
			config.settings = conf_opts.settings
		end
		if conf_opts.setup and conf_opts.setup.commands then
			config.commands = conf_opts.setup.commands
		end
		vim.lsp.config(server_name, config)
	end
end
