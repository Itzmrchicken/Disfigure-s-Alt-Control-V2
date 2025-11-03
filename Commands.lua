local HttpService = game:GetService("HttpService")

local FunctionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/functions.lua"))()

local Commands = {
	teleport = {
		Aliases = {"goto", "to", "tp"},
		
		Args = {"player"},
		
		Definition = "Teleports the bots to the provided player",
		
		Run = function(Runner: Player, Data)
			print(Runner, HttpService:JSONEncode(Data))
		end,
	},
	
	define = {
		Aliases = {"def"},
		
		Args = {"command", "botindex"},
		
		Definition = "Defines a provided command",
		
		Run = function(Runner: Player, Data)
			local BotIndex: number = Data.botindex
			
			FunctionsModule.Chat(1, BotIndex, Data.command)
		end,
	}
}

return Commands
