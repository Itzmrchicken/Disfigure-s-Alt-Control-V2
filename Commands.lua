local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")

local LocalPlayer = PlayersService.LocalPlayer

local FunctionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/functions.lua"))()

local Data = getgenv().Data

local Master = Data["Master"]
local Bots = Data["Bots"]

local Commands = {
	teleport = {
		Aliases = {"goto", "to", "tp"},
		
		Args = {"player", "botindex"},
		
		Definition = "Teleports the bots to the provided player",
		
		Run = function(Runner: Player, Data)
			local BotIndex: number = Data.botindex
			local Target: Player = Data.player
			
			local LPCharacter = LocalPlayer.Character
			
			local Character = Target.Character
			
			if LPCharacter and Character then
				local LPHumanoidRootPart: BasePart = LPCharacter:FindFirstChild("HumanoidRootPart")
				
				local HumanoidRootPart: BasePart = Character:FindFirstChild("HumanoidRootPart")
				
				if LPHumanoidRootPart and HumanoidRootPart then
					LPHumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, (1 * BotIndex))
				end
			end
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
