local Commands = {
	teleport = {
		Aliases = {"goto", "to", "tp"},
		
		Args = {"player"},
		
		Run = function(Args)
			print(Args)
		end,
	}
}

return Commands
