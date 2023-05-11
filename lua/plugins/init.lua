local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') ..
                             '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({
            'git', 'clone', '--depth', '1',
            'https://github.com/wbthomason/packer.nvim', install_path
        })
        vim.cmd "packadd packer.nvim"
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    -- Color scheme
    use {"ellisonleao/gruvbox.nvim"}

    -- GUI enhancements 
    use 'nvim-tree/nvim-web-devicons'
    use {
        'nvim-tree/nvim-tree.lua',
        requires = 'nvim-tree/nvim-web-devicons',
        config = function() require('plugins/setup/nvim-tree') end
    }
    use {
        'nvim-lualine/lualine.nvim',
        requires = 'nvim-tree/nvim-web-devicons',
        config = function() require('plugins/setup/lualine') end
    }
    use {
        'akinsho/bufferline.nvim',
        tag = "*",
        requires = 'nvim-tree/nvim-web-devicons',
        config = function() require('plugins/setup/bufferline') end
    }
    use {
        "folke/zen-mode.nvim",
        config = function() require('plugins/setup/zen-mode') end
    }

    -- Search
    use {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        requires = 'nvim-lua/plenary.nvim',
        config = function() require('plugins/setup/telescope') end
    }

    -- Navigation
    use {
        'phaazon/hop.nvim',
        config = function() require('plugins/setup/hop') end
    }

    -- Code analysis
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline', 'dcampos/nvim-snippy', 'dcampos/cmp-snippy',
            'honza/vim-snippets'
        },
        config = function() require('plugins/setup/cmp') end
    }
    -- Lua
    use {
        "folke/trouble.nvim",
        requires = "nvim-tree/nvim-web-devicons",
        config = function() require('plugins/setup/trouble') end
    }
    use {
        'neovim/nvim-lspconfig',
        requires = 'hrsh7th/nvim-cmp',
        config = function() require('plugins/setup/nvim-lspconfig') end
    }
    use {
        'simrat39/symbols-outline.nvim',
        config = function() require('plugins/setup/symbols-outline') end
    }

    -- git
    use 'tpope/vim-fugitive'

    use {
        'lewis6991/gitsigns.nvim',
        config = function() require('plugins/setup/gitsigns') end
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then require('packer').sync() end
end)
