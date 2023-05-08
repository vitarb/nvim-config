-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {
    on_attach = on_attach,
    cmd = {
        'clangd', '--background-index', '--clang-tidy',
        '--completion-style=bundled'
    },
    capabilities = capabilities
}
lspconfig.rust_analyzer.setup {
    -- Server-specific settings. See `:help lspconfig-setup`
    settings = {['rust-analyzer'] = {}},
    capabilities = capabilities
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', 'gp', vim.diagnostic.goto_prev)
vim.keymap.set('n', 'gn', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = {buffer = ev.buf}
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<C-b>', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<C-q>', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-M-i>', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-p>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder,
                       opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<C-r>', vim.lsp.buf.rename, opts)
        vim.keymap.set({'n', 'v'}, '<C-space>', vim.lsp.buf.code_action, opts)
        vim.keymap.set({'n', 'v'}, '<M-CR>', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gu', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<C-M-b>', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f',
                       function() vim.lsp.buf.format {async = true} end, opts)
    end
})
