; Neovim 0.12.x can crash in markdown fenced-code injections when paired with
; the legacy nvim-treesitter master branch. Replace the injection query locally
; so markdown buffers still highlight without hitting the broken code path.
