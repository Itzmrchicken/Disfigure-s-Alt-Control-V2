local HttpService = game:GetService("HttpService")

local Commands = {
	teleport = {
		Aliases = {"goto", "to", "tp"},
		
		Args = {"player"},
		
		Run = function(Runner: Player, ...)
			print(Runner, HttpService:JSONEncode(...))
		end,
	}
}

return Commands
