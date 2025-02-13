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
local servers = { "html", "cssls" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

--------------------------------------------------------------------------------
-- 2. TypeScript LSP (named "ts_ls" in your setup)
--------------------------------------------------------------------------------
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  cmd = { "bun", "run", "--bun", "typescript-language-server", "--stdio" },
  -- Or just {"typescript-language-server", "--stdio"} if installed globally
  filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
  root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
})

--------------------------------------------------------------------------------
-- 3. Svelte LSP
--------------------------------------------------------------------------------
lspconfig.svelte.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  cmd = { "bun", "run", "--bun", "svelteserver", "--stdio" },
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
  cmd = { "bun", "run", "--bun", "tailwindcss-language-server", "--stdio" },
  -- Or just {"tailwindcss-language-server", "--stdio"}
  settings = {
    tailwindCSS = {
      includeLanguages = {
        -- Tell Tailwind to treat Svelte as HTML for class detection
        svelte = "html",
      },
      experimental = {
        -- If you use "class:..." directives in Svelte, add them here
        classRegex = {
          { "class:([%w_%-]+)", "'([^']*)'" },
          { 'class:([%w_%-]+)="([^"]*)"', "class=\"([^\"]*)\"" },
        },
      },
    },
  },
})

