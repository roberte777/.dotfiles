return {
    "ThePrimeagen/harpoon",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    branch = "harpoon2",
    config = function()
        -- set keymaps
        local harpoon = require("harpoon")
        harpoon:setup()
        vim.keymap.set("n", "<leader>hg",
            function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            { noremap = true, silent = true, desc = "Open Harpoon menu" })

        vim.keymap.set("n", "<leader>ha",
            function()
                harpoon:list():append()
            end,
            { noremap = true, silent = true, desc = "Add file to harpoon menu" })

        vim.keymap.set("n", "<leader>hj",
            function()
                harpoon:list():select(1)
            end,
            { noremap = true, silent = true, desc = "Go to first marked file" })

        vim.keymap.set("n", "<leader>hk",
            function()
                harpoon:list():select(2)
            end,
            { noremap = true, silent = true, desc = "Go to second marked file" })

        vim.keymap.set("n", "<leader>hl",
            function()
                harpoon:list():select(3)
            end,
            { noremap = true, silent = true, desc = "Go to third marked file" })
        vim.keymap.set("n", "<leader>h;",
            function()
                harpoon:list():select(4)
            end,
            { noremap = true, silent = true, desc = "Go to fourth marked file" })
    end,
}
