vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.signcolumn = "yes"
vim.opt.completeopt:append("menuone")
vim.opt.completeopt:append("noinsert")
vim.cmd.colorscheme("habamax")

vim.api.nvim_create_autocmd("TextYankPost", {
   callback = function() vim.hl.on_yank() end
})

vim.lsp.config["clangd"] = {
   cmd = {
      "clangd",
      "--header-insertion=never",
      "--header-insertion-decorators=0",
      "--completion-style=bundled",
      "--function-arg-placeholders=0"
   },
   root_markers = { ".clangd", "compile_commands.json", ".git", "CMakeLists.txt" },
   filetypes = { "cpp" },
   capabilities = {
      textDocument = {
         semanticTokens = {
            multilineTokenSupport = true
         }
      }
   }
}

vim.api.nvim_create_autocmd("LspAttach", {
   callback = function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if client:supports_method("textDocument/completion") then
         vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
      end
   end
})

vim.lsp.enable("clangd")
