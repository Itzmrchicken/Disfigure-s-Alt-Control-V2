local Commands = {
	teleport = {
		Aliases = {"goto", "to", "tp"},
		
		Args = {"player"},
		
		Run = function(Runner: Player, ...)
			print(Runner, ...)
		end,
	}
}

return Commands
