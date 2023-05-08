local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd "packadd packer.nvim"
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()


require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Color scheme
  use { "ellisonleao/gruvbox.nvim" }

  -- GUI enhancements 
  use 'nvim-tree/nvim-web-devicons'
  use {'nvim-tree/nvim-tree.lua', requires = 'nvim-tree/nvim-web-devicons',
  	config = function() require('plugins/setup/nvim-tree') end }
  use {'nvim-lualine/lualine.nvim', requires = 'nvim-tree/nvim-web-devicons',
  	config = function() require('plugins/setup/lualine') end }
  use {'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons', 
  	config = function() require('plugins/setup/bufferline') end }

  use {"folke/zen-mode.nvim", 
    config = function() require('plugins/setup/zen-mode') end }
  -- Search
  use {'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = 'nvim-lua/plenary.nvim',
  	config = function() require('plugins/setup/telescope') end }

  -- Navigation
  use {'phaazon/hop.nvim', config = function() require('plugins/setup/hop') end }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
