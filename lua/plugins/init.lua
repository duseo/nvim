-- Example plugin configuration
-- You can add more plugins here or create separate files in this directory

return {
    -- Gruvbox colorscheme
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                undercurl = true,
                underline = true,
                bold = true,
                italic = {
                    strings = true,
                    emphasis = true,
                    comments = true,
                    operators = false,
                    folds = true,
                },
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                invert_intend_guides = false,
                inverse = true,
                contrast = "", -- can be "hard", "soft" or empty string
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = false,
            })
            vim.cmd([[colorscheme gruvbox]])
        end,
    },

    -- File picker
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, 
                { desc = 'Telescope find files'} )
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
            vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
        end
    },

    -- Mason for managing LSP servers, linters, formatters
    {
        "williamboman/mason.nvim",
        opts = {}
    },

    -- Mason LSP config for automatic server setup
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = { "csharp_ls" },
            automatic_installation = true,
            --- THIS IS THE FIX ---
            handlers = {
                -- The first handler is a default setup for all other servers
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = require("cmp_nvim_lsp").default_capabilities(),
                    })
                end,

                -- The second handler is a specific override ONLY for csharp_ls
                ["csharp_ls"] = function()
                    require("lspconfig").csharp_ls.setup({
                        capabilities = require("cmp_nvim_lsp").default_capabilities(),
                        root_dir = require("lspconfig.util").root_pattern("*.sln", ".git"),
                    })
                end,
            },
        },
    },

    {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        -- DO NOT call lspconfig.csharp_ls.setup{} here anymore.
        -- This section is now only for general settings, like keymaps.
        
        -- LSP keymaps
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                local opts = { buffer = ev.buf }
                -- Your vim.keymap.set calls go here...
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                -- etc.
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
    {
          "karb94/neoscroll.nvim",
          opts = {
        easing = 'linear' },
    },

    -- Database plugins
    "tpope/vim-dadbod",
    "kristijanhusak/vim-dadbod-ui",
    "kristijanhusak/vim-dadbod-completion",
}
