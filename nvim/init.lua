vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 3
vim.opt.scrolloff = 7
vim.opt.showmode = false
vim.opt.completeopt:append("menuone")
vim.opt.completeopt:append("noselect")

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank() end })

vim.api.nvim_create_autocmd("LspAttach", {
   callback = function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if client:supports_method("textDocument/completion") then
         vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
      end
   end
})

vim.lsp.config("*", {
   capabilities = {
      textDocument = {
         semanticTokens = {
            multilineTokenSupport = true
         }
      }
   }
})

vim.lsp.config.pyright = {
   cmd = { "pyright-langserver", "--stdio" },
   root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
   filetypes = { "python" },
   settings = {
      python = {
         analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "openFilesOnly"
         }
      }
   }
}

vim.lsp.config.clangd = {
   cmd = {
      "clangd",
      "--header-insertion=never",
      "--header-insertion-decorators=0",
      "--completion-style=bundled",
      "--function-arg-placeholders=0"
   },
   root_markers = { ".clangd", "compile_commands.json", ".git", "CMakeLists.txt" },
   filetypes = { "c", "cpp" }
}

vim.lsp.enable({ "clangd", "pyright" })
vim.diagnostic.config({ virtual_text = { current_line = true }})

-- 3rd party
vim.cmd.colorscheme("nightfox")
