local HttpService = game:GetService("HttpService")

local Commands = {
	teleport = {
		Aliases = {"goto", "to", "tp"},
		
		Args = {"player"},
		
		Definition = "Teleports the bots to the provided player",
		
		Run = function(Runner: Player, ...)
			print(Runner, HttpService:JSONEncode(...))
		end,
	},
	
	define = {
		Aliases = {"def"},
		
		Args = {"command"},
		
		Definition = "Defines a provided command",
		
		Run = function(Runner: Player, ...)
			print(Runner, HttpService:JSONEncode(...))
		end,
	}
}

return Commands
