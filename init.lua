vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 350
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }
vim.opt.clipboard = 'unnamedplus'

vim.cmd.colorscheme('habamax')

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/windwp/nvim-autopairs',
}, { confirm = false, load = true })

local map = vim.keymap.set
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save file' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit window' })
map('n', '<leader>h', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('n', '<leader>e', '<cmd>Explore<cr>', { desc = 'Open file explorer' })

pcall(function()
  require('gitsigns').setup({
    current_line_blame = false,
  })
end)

pcall(function()
  require('nvim-autopairs').setup({
    check_ts = true,
    disable_filetype = { 'TelescopePrompt', 'vim' },
  })
end)

local ts_parsers = {
  'bash',
  'css',
  'dockerfile',
  'html',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'prisma',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

vim.treesitter.language.register('json', 'jsonc')

pcall(function()
  local treesitter = require('nvim-treesitter')
  treesitter.setup({ install_dir = vim.fn.stdpath('data') .. '/site' })
  treesitter.install(ts_parsers)

  vim.api.nvim_create_autocmd('FileType', {
    pattern = {
      'bash',
      'css',
      'dockerfile',
      'html',
      'javascript',
      'javascriptreact',
      'json',
      'jsonc',
      'lua',
      'markdown',
      'prisma',
      'scss',
      'tsx',
      'typescript',
      'typescriptreact',
      'vim',
      'vimdoc',
      'yaml',
      'yaml.docker-compose',
    },
    callback = function()
      pcall(vim.treesitter.start)
      pcall(function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end)
    end,
  })
end)

vim.filetype.add({
  filename = {
    ['compose.yaml'] = 'yaml.docker-compose',
    ['compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
    ['docker-compose.yml'] = 'yaml.docker-compose',
  },
  pattern = {
    ['.*[/\\]compose%.override%.yaml'] = 'yaml.docker-compose',
    ['.*[/\\]compose%.override%.yml'] = 'yaml.docker-compose',
    ['.*[/\\]docker%-compose%..*%.yaml'] = 'yaml.docker-compose',
    ['.*[/\\]docker%-compose%..*%.yml'] = 'yaml.docker-compose',
  },
})

local function has_exec(name)
  return vim.fn.executable(name) == 1
end

pcall(function()
  require('conform').setup({
    formatters_by_ft = {
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      html = { 'prettier' },
      markdown = { 'prettier' },
      yaml = { 'prettier' },
      ['yaml.docker-compose'] = { 'prettier' },
      lua = { 'stylua' },
    },
    format_on_save = function()
      return { timeout_ms = 2000, lsp_format = 'fallback' }
    end,
  })
end)

vim.api.nvim_create_user_command('Format', function(args)
  local ok, conform = pcall(require, 'conform')
  if ok then
    conform.format({ async = args.bang, lsp_format = 'fallback' })
  else
    vim.lsp.buf.format({ async = args.bang })
  end
end, { bang = true, desc = 'Format current buffer' })

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config('dockerls', {
  root_markers = { '.git', 'Dockerfile' },
})

vim.lsp.config('docker_compose_language_service', {
  root_markers = { '.git', 'docker-compose.yaml', 'docker-compose.yml', 'compose.yaml', 'compose.yml' },
})

local lsp_servers = {
  ts_ls = 'typescript-language-server',
  eslint = 'vscode-eslint-language-server',
  html = 'vscode-html-language-server',
  cssls = 'vscode-css-language-server',
  jsonls = 'vscode-json-language-server',
  tailwindcss = 'tailwindcss-language-server',
  emmet_language_server = 'emmet-language-server',
  lua_ls = 'lua-language-server',
  dockerls = 'docker-langserver',
  docker_compose_language_service = 'docker-compose-langserver',
  prismals = 'prisma-language-server',
}

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local opts = { buffer = event.buf }

    map('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
    map('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Find references' }))
    map('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
    map('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
    map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
    map('n', '<leader>d', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = 'Line diagnostics' }))
    map('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
    map('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))

    if client and client:supports_method('textDocument/completion') then
      local chars = {}
      for i = 32, 126 do
        chars[#chars + 1] = string.char(i)
      end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

map('i', '<c-space>', function()
  vim.lsp.completion.get()
end, { desc = 'Trigger LSP completion' })

for name, executable in pairs(lsp_servers) do
  if has_exec(executable) then
    pcall(vim.lsp.enable, name)
  end
end
