return {
	{
		"aklt/plantuml-syntax", -- Syntax highlighting for PlantUML
		ft = { "plantuml", "puml" },
	},
	{
		"weirongxu/plantuml-previewer.vim", -- Preview PlantUML diagrams
		dependencies = {
			"tyru/open-browser.vim", -- Allows opening the preview in a browser
		},
		ft = { "plantuml", "puml" },
		config = function()
			-- Set the path to your plantuml.jar
			vim.g.plantuml_executable_script = "java -jar /usr/share/java/plantuml/plantuml.jar"
			vim.g.plantuml_previewer = {
				plantuml_jar_path = "/path/to/plantuml.jar",
				save_format = "png",
			}
		end,
	},
	{
		"tyru/open-browser.vim", -- Enables opening links in the browser
		ft = { "plantuml", "puml" },
	},
}
