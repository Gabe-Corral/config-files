vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = false
vim.o.termguicolors = true
vim.o.background = "dark"

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.wrap = false
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.signcolumn = "yes"

vim.opt.clipboard = "unnamedplus"

vim.keymap.set("v", "<C-c>", '"+y')

vim.keymap.set("n", "<C-v>", '"+p')

vim.keymap.set("i", "<C-v>", '<C-r>+')

vim.keymap.set("v", "<C-v>", '"+p')

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Colorscheme
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    priority = 1000,
    config = function()
      require("dracula").setup({
        transparent_bg = false,
      })
      vim.cmd.colorscheme("dracula")
    end,
  },

{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
      }, {
        { name = "buffer" },
      }),
    })
  end,
},

{
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "lua",
        "python",
        "javascript",
        "html",
        "css",
        "json",
        "markdown",
        "markdown_inline",
        "vim",
        "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
},

  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
      pcall(telescope.load_extension, "fzf")
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = {},
  },

  -- Bridge Mason -> lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "pyright", "clangd" },
    },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },

{
  "neovim/nvim-lspconfig",
  config = function()
    -- Setup LSP servers (new API)
    vim.lsp.config("lua_ls", {})
    vim.lsp.config("pyright", {})
    vim.lsp.config("clangd", {})

    vim.lsp.enable("lua_ls")
    vim.lsp.enable("pyright")
    vim.lsp.enable("clangd")

    -- Keymaps when LSP attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      end,
    })
  end,
},

{
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("neo-tree").setup({
      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        hijack_netrw_behavior = "open_default",
      },
      window = {
        position = "left",
        width = 30,
      },
    })

    vim.keymap.set("n", "<C-b>", "<cmd>Neotree filesystem toggle left<CR>", { silent = true, noremap = true })
  end,
},

{
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
      },
    })

    -- keymaps
    vim.keymap.set("n", "<S-l>", ":bnext<CR>", { silent = true })
    vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { silent = true })
  end,
}
})
