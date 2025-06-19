-- File: ~/.config/nvim/lua/custom/plugins/lspconfig.lua
-- or wherever you keep your custom LSP config.

-- 1. Load the default NvChad LSP config
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require("lspconfig")
local nvlsp = require("nvchad.configs.lspconfig")

-- Custom on_attach to set up autoformat on save
local on_attach = function(client, bufnr)
  -- Call default NvChad on_attach
  nvlsp.on_attach(client, bufnr)

  -- If this server supports formatting, run it on save
  if client.server_capabilities.documentFormattingProvider then
    local augroup = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          -- timeout_ms = 3000, -- optional
        })
      end,
    })
  end
end

local on_init = nvlsp.on_init
local capabilities = nvlsp.capabilities

--------------------------------------------------------------------------------
-- 1. HTML & CSS LSP
--------------------------------------------------------------------------------
local servers = { "cssls" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

lspconfig.html.setup({
  filetypes = { "html", "eruby.html", "eruby" },  -- or whichever you need
  init_options = {
    -- You can specify HTML LSP features here, e.g. embeddedLanguages, etc.
    provideFormatter = true,
  },
  settings = {},
})

--------------------------------------------------------------------------------
-- 2. TypeScript LSP (named "ts_ls" in your setup)
--------------------------------------------------------------------------------
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json"),
})

--------------------------------------------------------------------------------
-- 3. Svelte LSP
--------------------------------------------------------------------------------
lspconfig.svelte.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  cmd = { "svelteserver", "--stdio" },
  settings = {
    svelte = {
      plugin = {
        svelte = {
          -- Was previously "compliterWarnings" (typo). Correct is "compilerWarnings"
          compilerWarnings = {
            ["missing-declaration"] = "ignore",
          },
          format = {
            enable = true,
          },
        },
      },
    },
  },
})

--------------------------------------------------------------------------------
-- 4. Tailwind CSS LSP
--------------------------------------------------------------------------------
lspconfig.tailwindcss.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  cmd = { "tailwindcss-language-server", "--stdio" },
  root_dir = lspconfig.util.root_pattern('tailwind.config.js', 'tailwind.config.ts', 'postcss.config.js', 'package.json', '.git'),
  filetypes = {
    "html",
    "svelte",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "php",
    "css"
  },
  init_options = {
    userLanguages = {
      svelte = "html"
    }
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        svelte = "html",
      },
      experimental = {
        classRegex = {
          { "class:([%w_%-]+)", "'([^']*)'" },
          { 'class:([%w_%-]+)="([^"]*)"', "class=\"([^\"]*)\"" },
        },
      },
    },
  },
})


--------------------------------------------------------------------------------
-- 5. Ruby LSP
--------------------------------------------------------------------------------
lspconfig.ruby_lsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,

  -- The main filetype is "ruby", but you may also add erb, etc. if you want partial coverage
  filetypes = { "ruby" },

  -- Some rails projects may have Ruby code in subfolders. This helps find the project root.
  root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),

  -- Ruby LSP has a set of features; you can enable or disable them here:
  init_options = {
    enabledFeatures = {
      "codeActions",
      "diagnostics",
      "documentHighlights",
      "documentSymbols",
      "formatting",
      "inlayHint",
      "semanticHighlighting",
      "foldingRange",
      "selectionRange",
      "rename",
      "codeLens",
      "workspaceSymbol",
    },
  },
}

lspconfig.emmet_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  -- You can specify filetypes or let it default
  filetypes = {
    "html",
    "css",
    "sass",
    "scss",
    "less",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",    -- if you want Emmet in Svelte
    "php",       -- if you like Emmet for Blade templates
    "eruby",     -- if you like Emmet for ERB
    -- etc.
  },
  init_options = {
    -- Typical Emmet configuration options
    html = {
      options = {
        -- For example, override default Emmet settings here
        ["bem.enabled"] = true,
      },
    },
  },
})
