local TeleportService = game:GetService("TeleportService")
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
	},
	
	chat = {
		Aliases = {"say", "msg"},
		
		Args = {"message", "botindex"},
		
		Definition = "Makes all bots chat a provided message",
		
		Run = function(Runner: Player, Data)
			local BotIndex = Data.botindex
			local Message = Data.message
			
			FunctionsModule.Chat(nil, BotIndex, Message)
		end,
	},
	
	rejoin = {
		Aliases = {"rj", "rej", "botrj"},
		
		Args = {"none"},
		
		Definition = "Makes all bots rejoin the current server",
		
		Run = function(Runner: Player, Data)
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end,
	},
	
	args = {
		Aliases = {},
		
		Args = {"command", "botindex"},
		
		Definition = "Gives required arguments for provided command",
		
		Run = function(Runner: Player, Data)
			local BotIndex = Data.botindex
			local Command = Data.command
			
			local Args = get_command_data(Command).Args
			
			print(HttpService:JSONEncode(Args))
			
			FunctionsModule.Chat(1, BotIndex, Command..": "..table.concat(Args, " "))
		end,
	},
	
	leave = {
		Aliases = {"lv", "getout"},
		
		Args = {"none"},
		
		Definition = "Kicks the bots from the game",
		
		Run = function(Runner: Player, Data)
			LocalPlayer:Kick("Master kicked bots")
		end,
	}
}

function get_command_data(Command)
	if Commands[Command] then
		return Commands[Command]
	else
		for cmd, cmd_data in Commands do
			local Aliases = cmd_data.Aliases

			if table.find(Aliases, Command) then
				return cmd_data
			end
		end
	end

	return "Couldn't find command", true
end

return Commands
