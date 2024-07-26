local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

language = "en_US"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins", opts = { colorscheme = "tokyonight-storm" } },
    -- import any extras modules here
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.lang.json" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.lsp.none-ls" },
    -- import/override with your plugins

    { import = "plugins" },

    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "simrat39/rust-tools.nvim" },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
      },
      config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

        require("mason").setup()
        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup({
          ensure_installed = { "pyright", "rust_analyzer" },
        })
        require("lspconfig").pyright.setup({
          capabilities = capabilities,
        })
        require("lspconfig").rust_analyzer.setup({})
      end,
    },

    {
      "L3MON4D3/LuaSnip",
      event = "VeryLazy",
      config = function()
        require("luasnip.loaders.from_lua").load({ paths = "./snippets" })
      end,
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = {
            autocomplete = false,
          },
          mapping = cmp.mapping.preset.insert({
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<s-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<c-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
          sources = {
            { name = "nvim_lsp" },
            { name = "luasnip" },
          },
        })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      version = false,
      build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
      end,
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "bash",
            "c",
            "dockerfile",
            "gitignore",
            "javascript",
            "json",
            "kdl",
            "lua",
            "mermaid",
            "python",
            "query",
            "rust",
            "scala",
            "sql",
            "terraform",
            "typescript",
            "vim",
            "vimdoc",
            "vue",
            "yaml",
          },
          auto_install = false,
          highlight = { enable = true, additional_vim_regex_highlighting = false },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "<C-n>",
              node_incremental = "<C-n>",
              scope_incremental = "<C-s>",
              node_decremental = "<C-m>",
            },
          },
        })
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      version = false,
      dependencies = {
        "nvim-lua/plenary.nvim",
        --  "nvim-telescope/telescope-live-grep-args.nvim"
      },
      --config = function()
      --  local telescope = require("telescope")
      --  telescope.setup({
      --      -- your config
      --  })
      --  telescope.load_extension("live_grep_args")
      --end
      keys = {
        { "<leader>sf", "<cmd>Telescope git_files<cr>", desc = "Find Files (root dir)" },
        { "<leader><space>", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
        { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Search Project" },
        -- { "<leader>sg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", desc = "Live Grep" },
        { "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Search Document Symbols" },
        { "<leader>sw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Search Workspace Symbols" },
      },
      opts = {
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      },
    },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },

    {
      "akinsho/toggleterm.nvim",
      event = "VeryLazy",
      version = "*",
      -- config = true,
      opts = {
        size = 10,
        open_mapping = "<c-s>",
      },
    },

    "Pocco81/auto-save.nvim",

    "dinhhuy258/vim-local-history",

    {
      "lewis6991/gitsigns.nvim",
      opts = {
        current_line_blame = true,
      },
    },

    -- {
    --   "NeogitOrg/neogit",
    --   dependencies = {
    --     "nvim-lua/plenary.nvim", -- required
    --     "sindrets/diffview.nvim", -- optional - Diff integration
    --     "nvim-telescope/telescope.nvim", -- optional
    --   },
    --   config = true,
    -- },
    { "tpope/vim-fugitive" },

    { "mrk21/yaml-vim" },

    -- themes
    { "EdenEast/nightfox.nvim" },
    { "catppuccin/nvim" },

    {
      "m4xshen/hardtime.nvim",
      dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
      opts = {},
    },

    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
      end,
      opts = {},
    },

    { "folke/flash.nvim" },

    { "folke/todo-comments.nvim" },

    {
      "numToStr/Comment.nvim",
      opts = {},
    },

    {
      "folke/zen-mode.nvim",
      opts = {},
    },

    { "laytan/cloak.nvim" },

    { "farmergreg/vim-lastplace" },
    { "rmagatti/auto-session" },

    { "sQVe/sort.nvim" },

    { "johmsalas/text-case.nvim" },

    -- { "gu-fan/lastbuf.nvim" }, -- TODO install this (github.com issue) and set the g:lastbug_level var to 2 to reopen bufs closed by :bd

    -- { "stevearc/oil.nvim" },

    -- { "folke/neoconf.nvim" },
    -- { "folke/flash.nvim" },

    -- { "ThePrimeagen/herpoon" }.

    --
    --
    -- DISABLED
    --
    --
    { "kdheepak/lazygit.nvim", enabled = false },
  },

  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = false, notify = false }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
