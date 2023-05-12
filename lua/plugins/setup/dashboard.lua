require('dashboard').setup{
    theme = 'hyper',
    change_to_vcs_root = true,
    config = {
        shortcut = {
            {
                icon = ' ',
                icon_hl = '@variable',
                desc = 'Files',
                group = 'Label',
                action = 'Telescope find_files',
                key = 'f',
            }
        },
        week_header = {
            enable = true
        }
    }
}
