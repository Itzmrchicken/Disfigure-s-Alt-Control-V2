local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = PlayersService.LocalPlayer

local FunctionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/functions.lua"))()

local Data = getgenv().Data

local Whitelist = Data["Whitelist"]
local Master = Data["Master"]
local Bots = Data["Bots"]

local Connections = {
	RunService = {}
}

local BaseValues = {
	GameGravity = workspace.Gravity
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
					LPHumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, (2 * BotIndex))
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
				
				Connections.RunService.Swarm = nil
				
				workspace.Gravity = BaseValues.GameGravity
				
				return
			end
			
			workspace.Gravity = 0
			
			for _, connection in Connections.RunService do
				connection:Disconnect()
				
				connection = nil
			end
			
			Connections.RunService["Swarm"] = RunService.Heartbeat:Connect(function()
				local LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				
				local Character = Target.Character or Target.CharacterAdded:Wait()
				
				local LPHumanoidRootPart: BasePart = LPCharacter and LPCharacter:FindFirstChild("HumanoidRootPart")
				
				local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")
				
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				
				local LPHumanoid = LPCharacter and LPCharacter:FindFirstChildOfClass("Humanoid")
				
				if LPHumanoid:GetState() == Enum.HumanoidStateType.Seated then
					LPHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end
				
				if LPHumanoidRootPart and HumanoidRootPart and Humanoid then
					LPHumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15)) + Humanoid.MoveDirection
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
						
			local Command_Data = Command and get_command_data(Command)
						
			if not next(Command_Data) then
				return
			end
			
			if table.find(Command_Data.Args, "botindex") then
				table.remove(Command_Data.Args, table.find(Command_Data.Args, "botindex"))
			end
			
			FunctionsModule.Chat(1, BotIndex, Command..": "..table.concat(Command_Data.Args, ", "))
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
		Aliases = {"res", "rb", "re"},
		
		Args = {"none"},
		
		Definition = "Resets the bots",
		
		Run = function(Runner: Player, Data)
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
		end,
	},
	
	whitelist = {
		Aliases = {"wl", "white"},
		
		Args = {"player", "botindex"},
		
		Definition = "Allows a list of users to control the bots",
		
		Run = function(Runner: Player, Data)
			local PlayerToWhitelist: Player = Data.player
			local BotIndex = Data.botindex
			
			if table.find(Whitelist, PlayerToWhitelist.Name) then
				table.remove(Whitelist, table.find(Whitelist, PlayerToWhitelist.Name))
				
				FunctionsModule.Chat(1, BotIndex, PlayerToWhitelist.Name.." you have been REMOVED from the whitelist to control us")
			else
				table.insert(Whitelist, PlayerToWhitelist.Name)
				
				FunctionsModule.Chat(1, BotIndex, PlayerToWhitelist.Name.." you have been ADDED to the whitelist to control us! Use .cmds to see current commands")
			end
			
			getgenv().Data.Whitelist = Whitelist
		end,
	},
	
	orbit = {
		Aliases = {},
		
		Args = {"player", "botindex"},
		
		Definition = "Makes the bots orbit a provided player",
		
		Run = function(Runner: Player, Data)
			local Target: Player = Data.player
			local BotIndex = Data.botindex
			
			if Connections.RunService.Orbit then
				Connections.RunService.Orbit:Disconnect()
				
				Connections.RunService.Orbit = nil
				
				workspace.Gravity = BaseValues.GameGravity
				
				return
			end
			
			workspace.Gravity = 0
			
			for _, connection in Connections.RunService do
				connection:Disconnect()

				connection = nil
			end
			
			local Speed = 1
			local Radius = 10
			local Spacing = Radius / #Bots
			
			local Rotation = 0
			local RotationSpeed = math.pi * 2 / Speed
			
			Connections.RunService.Orbit = RunService.Heartbeat:Connect(function(DeltaTime)
				local Character = Target.Character or Target.CharacterAdded:Wait()
				
				local LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				
				local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")
				
				local LPHumanoidRootPart: BasePart = LPCharacter and LPCharacter:FindFirstChild("HumanoidRootPart")
				
				local LPHumanoid = LPCharacter and LPCharacter:FindFirstChildOfClass("Humanoid")

				if LPHumanoid:GetState() == Enum.HumanoidStateType.Seated then
					LPHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end
				
				if HumanoidRootPart and LPHumanoidRootPart then
					Rotation = Rotation + DeltaTime * RotationSpeed
					
					local Angle = Rotation - (BotIndex * Spacing)
					
					local X, Z = math.sin(Angle) * Radius, math.cos(Angle) * Radius
					
					local NewPosition = HumanoidRootPart.Position + Vector3.new(X, 0, Z)
					
					LPHumanoidRootPart.CFrame = CFrame.new(NewPosition, HumanoidRootPart.Position)
				end
			end)
		end,
	},
	
	commands = {
		Aliases = {"cmds"},
		
		Args = {"number", "botindex"},
		
		Definition = "Shows the list of commands",
		
		Run = function(Runner: Player, Data)
			local BotIndex = Data.botindex
			local Page = Data.number or 1
			
			local Pages = get_commands_pages()
			
			if Pages[Page] then
				FunctionsModule.Chat(1, BotIndex, "Viewing commands for page "..Page.."/"..#Pages.." : "..table.concat(Pages[Page], ", "))
			else
				FunctionsModule.Chat(1, BotIndex, "Can't go to that page. Current amount of pages are "..#Pages)
			end
		end,
	},
	
	line = {
		Aliases = {"ln"},
		
		Args = {"player", "botindex"},
		
		Definition = "Makes the bots form a line side-by-side next to provided player",
		
		Run = function(Runner: Player, Data)
			local Target: Player = Data.player
			local BotIndex = Data.botindex
			
			if Connections.RunService.Line then
				Connections.RunService.Line:Disconnect()
				
				Connections.RunService.Line = nil
				
				workspace.Gravity = BaseValues.GameGravity
				
				return
			end
			
			workspace.Gravity = 0
			
			for _, connection in Connections.RunService do
				connection:Disconnect()

				connection = nil
			end
			
			Connections.RunService.Line = RunService.Heartbeat:Connect(function()
				local Character = Target.Character or Target.CharacterAdded:Wait()
				
				local LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				
				local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")
				
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				
				local LPHumanoidRootPart: BasePart = LPCharacter and LPCharacter:FindFirstChild("HumanoidRootPart")
				
				local LPHumanoid = LPCharacter and LPCharacter:FindFirstChildOfClass("Humanoid")
				
				if LPHumanoid:GetState() == Enum.HumanoidStateType.Seated then
					LPHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end
				
				if HumanoidRootPart and LPHumanoidRootPart then
					LPHumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(2 * BotIndex, 0, 0) + Humanoid.MoveDirection
				end
			end)
		end,
	},
	
	count = {
		Aliases = {"coff", "cnt"},
		
		Args = {"none", "botindex"},
		
		Definition = "Makes each bot count off their number",
		
		Run = function(Runner: Player, Data)
			local BotIndex = Data.botindex
			
			for i, _ in Bots do
				if i == BotIndex then
					task.wait(BotIndex / 2)
					
					FunctionsModule.Chat(i, BotIndex, "I'm number "..BotIndex.."!")
					
					break
				end
			end
			
			task.wait(1)
			
			FunctionsModule.Chat(1, BotIndex, "Looks like everyone counted off right!")
		end,
	},
	
	fling = {
		Aliases = {"skyrocket", "moon"},
		
		Args = {"player"},
		
		Definition = "Flings a provided player",
		
		Run = function(Runner: Player, Data)
			local Target: Player = Data.player
			
			if Connections.RunService.Fling then
				if LocalPlayer.Character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyAngularVelocity") then
					LocalPlayer.Character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyAngularVelocity"):Destroy()
				end
				
				Connections.RunService.Fling:Disconnect()
				
				Connections.RunService.Fling = nil
				
				workspace.Gravity = BaseValues.GameGravity
				
				return
			end
			
			--local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
			--BodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
			--BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
			--BodyAngularVelocity.P = math.huge
			
			workspace.Gravity = 0
			
			for _, connection in Connections.RunService do
				connection:Disconnect()

				connection = nil
			end
			
			local LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			
			local LPHumanoidRootPart: BasePart = LPCharacter and LPCharacter:FindFirstChild("HumanoidRootPart")
			
			--BodyAngularVelocity.Parent = LPHumanoidRootPart
			
			Connections.RunService.Fling = RunService.Heartbeat:Connect(function()
				local Character = Target.Character or Target.CharacterAdded:Wait()
				
				LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				
				local HumanoidRootPart: BasePart = Character and Character:FindFirstChild("HumanoidRootPart")
				
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				
				local LPHumanoid = LPCharacter and LPCharacter:FindFirstChildOfClass("Humanoid")
				
				LPHumanoidRootPart = LPCharacter and LPCharacter:FindFirstChild("HumanoidRootPart")
				
				LPHumanoidRootPart.AssemblyLinearVelocity = Vector3.new(math.huge, math.huge, math.huge)
				LPHumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
				
				LPHumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, math.random(-10, 10)) + Humanoid.MoveDirection
				
				task.wait(0.001)
				
				if (Humanoid.Health <= 0 or LPHumanoid.Health <= 0) or not(Character or LPCharacter) or LocalPlayer:DistanceFromCharacter(HumanoidRootPart.Position) > 25 then
					Connections.RunService.Fling:Disconnect()
					
					Connections.RunService.Fling = nil
					
					workspace.Gravity = BaseValues.GameGravity
					
					LPHumanoid.Health = 0
					
					return
				end
			end)
		end,
	}
	
	--aliases = {
	--	Aliases = {"ali", "als"},
		
	--	Args = {"word", "botindex"},
		
	--	Definition = "Gives the aliases or alternate commands to the parent command",
		
	--	Run = function(Runner: Player, Data)
	--		local BotIndex = Data.botindex
	--		local Command = Data.word
			
	--		print(Command)
			
	--		local Command_Data = Command and get_command_data(Command)
			
	--		if not next(Command_Data) then
	--			return
	--		end
			
	--		FunctionsModule.Chat(1, BotIndex, "Aliases for "..Command..": "..table.concat(Command_Data.Aliases, ", "))
	--	end,
	--},
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

function get_commands_pages()
	local Pages = {}
	local Keys = {}
	
	for name, _ in Commands do
		table.insert(Keys, name)
	end
	
	local Chunk = 5
	
	for i = 1, #Keys, Chunk do
		local Page = {}
		
		for j = i, math.min(i + Chunk - 1, #Keys) do
			table.insert(Page, Keys[j])
		end
		
		table.insert(Pages, Page)
	end
	
	return Pages
end

return Commands
