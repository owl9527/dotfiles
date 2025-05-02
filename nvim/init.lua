vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.completeopt:append({ "menuone", "noselect" })
vim.cmd("colorscheme nightfox")

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank() end })

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--header-insertion=never",
    "--header-insertion-decorators=0",
    "--completion-style=bundled",
    "--function-arg-placeholders=0"
  },
  root_markers = { ".git", "CMakeLists.txt", "Makefile", "compile_commands.json" },
  filetypes = { "c", "cpp" }
})

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx"
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  single_file_support = true
})

vim.lsp.enable({ "clangd", "ts_ls" })

vim.api.nvim_create_autocmd("ModeChanged", { command = "redrawstatus" })

vim.api.nvim_set_hl(0, "StatusLineMode",            { fg = "#2e3440", bg = "#81a1c1" })
vim.api.nvim_set_hl(0, "StatusLineDiagnosticError", { fg = "#c94f6d", bg = "#2e3440" })
vim.api.nvim_set_hl(0, "StatusLineDiagnosticWarn",  { fg = "#dbc074", bg = "#2e3440" })
vim.api.nvim_set_hl(0, "StatusLineDiagnosticInfo",  { fg = "#719cd6", bg = "#2e3440" })
vim.api.nvim_set_hl(0, "StatusLineDiagnosticHint",  { fg = "#81b29a", bg = "#2e3440" })
vim.api.nvim_set_hl(0, "StatusLineBranchName",      { fg = "#d8dee9", bg = "#5e81ac" })
vim.api.nvim_set_hl(0, "StatusLineDiffAdd",         { fg = "#f6c177", bg = "#5e81ac" })
vim.api.nvim_set_hl(0, "StatusLineDiffSub",         { fg = "#eb6f92", bg = "#5e81ac" })

local statusline_mode_map = {
  ['n']     = 'NORMAL',
  ['no']    = 'O-PEND',
  ['nov']   = 'O-PEND',
  ['noV']   = 'O-PEND',
  ['no\22'] = 'O-PEND',
  ['niI']   = 'NORMAL',
  ['niR']   = 'NORMAL',
  ['niV']   = 'NORMAL',
  ['nt']    = 'NORMAL',
  ['ntT']   = 'NORMAL',
  ['v']     = 'VISUAL',
  ['vs']    = 'VISUAL',
  ['V']     = 'V-LINE',
  ['Vs']    = 'V-LINE',
  ['\22']   = 'V-BLOCK',
  ['\22s']  = 'V-BLOCK',
  ['s']     = 'SELECT',
  ['S']     = 'S-LINE',
  ['\19']   = 'S-BLOCK',
  ['i']     = 'INSERT',
  ['ic']    = 'INSERT',
  ['ix']    = 'INSERT',
  ['R']     = 'REPLACE',
  ['Rc']    = 'REPLACE',
  ['Rx']    = 'REPLACE',
  ['Rv']    = 'V-REPLACE',
  ['Rvc']   = 'V-REPLACE',
  ['Rvx']   = 'V-REPLACE',
  ['c']     = 'COMMAND',
  ['cr']    = 'COMMAND',
  ['cv']    = 'EX',
  ['cvr']   = 'EX',
  ['r']     = 'REPLACE',
  ['rm']    = 'MORE',
  ['r?']    = 'CONFIRM',
  ['!']     = 'SHELL',
  ['t']     = 'TERMINAL'
}

statusline_mode = function()
  return statusline_mode_map[vim.api.nvim_get_mode().mode]
end

local statusline_diagnostics_severity_map = { " E:", " W:", " I:", " H:" }
local statusline_diagnostics_count = {}

statusline_diagnostics_have = function()
  statusline_diagnostics_count = vim.diagnostic.count(0)
  for _ in pairs(statusline_diagnostics_count) do
    return " "
  end
  return ""
end
statusline_diagnostics = function(severity)
  return statusline_diagnostics_count[severity] and statusline_diagnostics_severity_map[severity] .. statusline_diagnostics_count[severity] .. " " or ""
end

local statusline_git_branch_text = ""

statusline_git_branch_update = function()
  local dotgit = vim.fs.find(".git", { path = vim.api.nvim_buf_get_name(0), upward = true })[1]
  if not dotgit then return "" end

  local fd = io.open(dotgit .. "/HEAD" , "r")
  local first_line = fd:read()
  local branch_name = string.match(first_line, "ref: refs/heads/(.*)")
  fd:close()

  statusline_git_branch_text = " branch:" .. (branch_name or string.sub(first_line, 1, 7)) .. " "
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, { callback = statusline_git_branch_update })

statusline_git_branch = function()
  return statusline_git_branch_text
end

local statusline_git_diff_num = { "0", "0" }

statusline_git_diff_update = function()
  local file_path = vim.api.nvim_buf_get_name(0)
  if not file_path or file_path == "" then return end

  local dotgit = vim.fs.find(".git", { path = file_path, upward = true })[1]
  if not dotgit then return end

  local repository_path = vim.fs.dirname(dotgit)
  local relative_path = string.sub(file_path, #repository_path + 2)
  local cmd = io.popen("git -C " .. repository_path .. " --no-pager diff --numstat " .. relative_path)
  local cmd_output = cmd:read("*a")
  cmd:close()

  statusline_git_diff_num = { string.match(cmd_output, "(%d+)%s(%d+)%s.*") }
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufReadPost" }, { callback = statusline_git_diff_update })

statusline_git_diff = function(_)
  return (statusline_git_diff_num[_] and statusline_git_diff_num[_] ~= "0") and " " .. string.char(41 + _ * 2) .. statusline_git_diff_num[_] .. " " or ""
end

vim.opt.statusline = "%#StatusLineMode# %{v:lua.statusline_mode()} %#StatusLine#%#StatusLineBranchName#%{v:lua.statusline_git_branch()}%#StatusLine#%#StatusLineDiffAdd#%{v:lua.statusline_git_diff(1)}%#StatusLineDiffSub#%{v:lua.statusline_git_diff(2)}%#StatusLineDiagnosticError#%{v:lua.statusline_diagnostics_have()}%{v:lua.statusline_diagnostics(1)}%#StatusLineDiagnosticWarn#%{v:lua.statusline_diagnostics(2)}%#StatusLineDiagnosticInfo#%{v:lua.statusline_diagnostics(3)}%#StatusLineDiagnosticHint#%{v:lua.statusline_diagnostics(4)}%#StatusLine# %f %h%w%m%r%=%l,%c%V %P"
