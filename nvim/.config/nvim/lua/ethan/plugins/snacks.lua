return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = false },
			indent = { enabled = true },
			input = { enabled = true },
			quickfile = { enabled = true, exclude = { "latex" } },
			scope = { enabled = true },
			scroll = { enabled = false },
			zen = { enabled = true },
			dashboard = {
				preset = {
					keys = {
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = ":lua Snacks.dashboard.pick('files')",
						},
						{ icon = " ", key = "n", desc = "New File", action = "<leader>ff" },
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = "<leader>fg",
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = "<leader>fn",
						},
						{
							icon = "󰒲 ",
							key = "L",
							desc = "Lazy",
							action = ":Lazy",
							enabled = package.loaded.lazy ~= nil,
						},
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
					header = [[
                    . .:.:.:.:. .:\     /:. .:.:.:.:. ,                    
               .-._  `..:.:. . .:.:`- -':.:. . .:.:.,'  _.-.               
              .:.:.`-._`-._..-''_...---..._``-.._.-'_.-'.:.:.              
           .:.:. . .:_.`' _..-''._________,``-.._ `.._:. . .:.:.           
        .:.:. . . ,-'_.-''      ||_-(O)-_||      ``-._`-. . . .:.:.        
       .:. . . .,'_.'           '---------'           `._`.. . . .:.       
     :.:. . . ,','               _________               `.`. . . .:.:     
    `.:.:. .,','            _.-''_________``-._            `._.     _.'    
  -._  `._./ /            ,'_.-'' ,       ``-._`.          ,' '`:..'  _.-  
 .:.:`-.._' /           ,','                   `.`.       /'  '  \\.-':.:. 
 :.:. . ./ /          ,','               ,       `.`.    / '  '  '\\. .:.: 
:.:. . ./ /          / /    ,                      \ \  :  '  '  ' \\. .:.:
.:. . ./ /          / /            ,          ,     \ \ :  '  '  ' '::. .:.
:. . .: :    o     / /                               \ ;'  '  '  ' ':: . .:
.:. . | |   /_\   : :     ,                      ,    : '  '  '  ' ' :: .:.
:. . .| |  ((<))  | |,          ,       ,             |\'__',-._.' ' ||. .:
.:.:. | |   `-'   | |---....____                      | ,---\/--/  ' ||:.:.
------| |         : :    ,.     ```--..._   ,         |''  '  '  ' ' ||----
_...--. |  ,       \ \             ,.    `-._     ,  /: '  '  '  ' ' ;;..._
:.:. .| | -O-       \ \    ,.                `._    / /:'  '  '  ' ':: .:.:
.:. . | |_(`__       \ \                        `. / / :'  '  '  ' ';;. .:.
:. . .<' (_)  `>      `.`.          ,.    ,.     ,','   \  '  '  ' ;;. . .:
.:. . |):-.--'(         `.`-._  ,.           _,-','      \ '  '  '//| . .:.
:. . .;)()(__)(___________`-._`-.._______..-'_.-'_________\'  '  //_:. . .:
.:.:,' \/\/--\/--------------------------------------------`._',;'`. `.:.:.
:.,' ,' ,'  ,'  /   /   /   ,-------------------.   \   \   \  `. `.`. `..:
,' ,'  '   /   /   /   /   //                   \\   \   \   \   \  ` `.SSt
                ]],
				},
			},
			formats = {
				icon = function(item)
					if item.file and item.icon == "file" or item.icon == "directory" then
						return M.icon(item.file, item.icon)
					end
					return { item.icon, width = 2, hl = "icon" }
				end,
				footer = { "%s", align = "center" },
				header = { "%s", align = "center" },
				file = function(item, ctx)
					local fname = vim.fn.fnamemodify(item.file, ":~")
					fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
					if #fname > ctx.width then
						local dir = vim.fn.fnamemodify(fname, ":h")
						local file = vim.fn.fnamemodify(fname, ":t")
						if dir and file then
							file = file:sub(-(ctx.width - #dir - 2))
							fname = dir .. "/…" .. file
						end
					end
					local dir, file = fname:match("^(.*)/(.+)$")
					return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
				end,
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
			},
		},
		keys = {
			{
				"<leader>uz",
				function()
					Snacks.zen()
				end,
				desc = "Enable zen mode",
			},
		},
	},
}
