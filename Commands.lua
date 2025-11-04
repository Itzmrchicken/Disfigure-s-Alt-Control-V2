local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = PlayersService.LocalPlayer

local FunctionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/functions.lua"))()

local Data = getgenv().Data

local Master = Data["Master"]
local Bots = Data["Bots"]

local Connections = {
	RunService = {}
}

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
	
	swarm = {
		Aliases = {"swm", "surround"},
		
		Args = {"player"},
		
		Definition = "Makes the bots swarm a provided player like bugs",
		
		Run = function(Runner: Player, Data)
			local Target: Player = Data.player
			
			if Connections.RunService.Swarm then
				Connections.RunService.Swarm:Disconnect()
				
				return
			end
			
			Connections.RunService["Swarm"] = RunService.Heartbeat:Connect(function()
				local LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				
				local Character = Target.Character or Target.CharacterAdded:Wait()
				
				local LPHumanoidRootPart: BasePart = LPCharacter and LPCharacter:FindFirstChild("HumanoidRootPart")
				
				local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")
				
				if LPHumanoidRootPart and HumanoidRootPart then
					LPHumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				end
			end)
		end,
	},
	
	args = {
		Aliases = {},
		
		Args = {"word", "botindex"},
		
		Definition = "Gives required arguments for provided command",
		
		Run = function(Runner: Player, Data)
			local BotIndex = Data.botindex
			local Command = Data.word
			
			--print(HttpService:JSONEncode(Data))
			
			local Command_Data = get_command_data(Command)
			
			--print(Command_Data and HttpService:JSONEncode(Command_Data))
			
			FunctionsModule.Chat(1, BotIndex, Command..": "..table.concat(Command_Data.Args, " "))
		end,
	},
	
	leave = {
		Aliases = {"lv", "getout"},
		
		Args = {"none"},
		
		Definition = "Kicks the bots from the game",
		
		Run = function(Runner: Player, Data)
			LocalPlayer:Kick("Master kicked bots")
		end,
	},
	
	reset = {
		Aliases = {"res", "rb"},
		
		Args = {"none"},
		
		Definition = "Resets the bots",
		
		Run = function(Runner: Player, Data)
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
		end,
	},
	
	commands = {
		Aliases = {"cmds"},
		
		Args = {"number"},
		
		Definition = "Shows the list of commands",
		
		Run = function(Runner: Player, Data)
			
		end,
	}
}

function get_command_data(Command)
	if Commands[Command] then
		print(HttpService:JSONEncode(Commands[Command]))
		
		return Commands[Command]
	else
		for cmd, cmd_data in Commands do
			local Aliases = cmd_data.Aliases

			if table.find(Aliases, Command) then
				print(HttpService:JSONEncode(cmd_data))
				return cmd_data
			end
		end
	end

	return "Couldn't find command", true
end

return Commands
