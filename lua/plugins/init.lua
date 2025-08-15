-- Example plugin configuration
-- You can add more plugins here or create separate files in this directory

return {
	-- Example: colorscheme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- vim.cmd([[colorscheme tokyonight]])
		end,
	},

	-- File picker
	{
		"dmtrKovalenko/fff.nvim",
		build = "cargo build --release",
		-- or if you are using nixos
		-- build = "nix run .#release",
		opts = {
			-- pass here all the options
		},
		keys = {
			{
				"ff", -- try it if you didn't it is a banger keybinding for a picker
				function()
					require("fff").find_files() -- or find_in_git_root() if you only want git files
				end,
				desc = "Open file picker",
			},
		},
	},

	-- Mason for managing LSP servers, linters, formatters
	{
		"williamboman/mason.nvim",
		opts = {}
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- LSP keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<leader>f", function()
						vim.lsp.buf.format { async = true }
					end, opts)
				end,
			})
		end,
	},

	-- Completion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"kristijanhusak/vim-dadbod-completion",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "vim-dadbod-completion" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
			})

			-- Setup for SQL files
			cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
				sources = cmp.config.sources({
					{ name = "vim-dadbod-completion" },
					{ name = "buffer" },
				}),
			})
		end,
	},

	-- Database plugins
	"tpope/vim-dadbod",
	"kristijanhusak/vim-dadbod-ui",
	"kristijanhusak/vim-dadbod-completion",
}
