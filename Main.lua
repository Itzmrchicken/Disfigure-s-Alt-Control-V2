local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")

local LocalPlayer = PlayersService.LocalPlayer

local Data = getgenv().Data

local FunctionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/functions.lua"))()
local CommandsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/Commands.lua"))()

local Master = Data["Master"]
local Prefix = Data["Prefix"]
local Bots = Data["Bots"]

local AccountIsMaster = LocalPlayer.Name == Master or LocalPlayer.DisplayName == Master
local IsDisplayName = LocalPlayer.DisplayName == Master

local BotIndex = not AccountIsMaster and table.find(Bots, LocalPlayer.Name)

local CustomArgs = {
	me = function(Runner: Player)
		return Runner
	end,
}

local ArgumentTypes = {
	player = function(Runner: Player, ArgString: string, Index: number, ArgText: string)
		for _, player in PlayersService:GetPlayers() do
			if ArgText and (player.Name:lower():sub(1, #ArgText) == ArgText or player.DisplayName:lower():sub(1, #ArgText) == ArgText) then
				return player
			end
		end
		
		if CustomArgs[ArgText] then
			return CustomArgs[ArgText](Runner)
		end
		
		return "Player not found or nil", true
	end,
	
	command = function(Runner: Player, ArgString: string, Index: number, ArgText: string)
		if CommandsModule[ArgText] then
			return CommandsModule[ArgText].Definition
		else
			for cmd, cmd_data in CommandsModule do
				local Aliases = cmd_data.Aliases
				
				if table.find(Aliases, ArgText) then
					return cmd_data.Definition
				end
			end
		end
		
		return "Command not found or nil", true
	end,
	
	botindex = function(Runner: Player)
		return BotIndex
	end,
}

function debug_style(Type: string, FunctionName: string, ...)
	return "["..Type.."]["..FunctionName.."] ".. ...
end

function verify_all_bots()
	for _, bot in Bots do
		if not PlayersService:FindFirstChild(bot) then
			table.remove(Bots, table.find(Bots, bot))
			
			print(bot, "doesn't exist in-game")
		end
	end
	
	BotIndex = not AccountIsMaster and table.find(Bots, LocalPlayer.Name)
end

function account_master()
	print(debug_style("INFO", "account_master()", "Account is master"))
end

function grab_args(Runner: Player, Command: string, Arguments)
	local CommandData = {}
	local CmdArgs = {}
	
	Command = Command:split(".")[2]
	
	if CommandsModule[Command] then
		CommandData = CommandsModule[Command]
		
		for Index, Arg in CommandsModule[Command].Args do
			local ArgumentData, IsError = ArgumentTypes[Arg](Runner, Arg, Index, Arguments[Index], CommandsModule[Command])
			
			if ArgumentData and not IsError then
				CmdArgs[Arg] = ArgumentData
			else
				warn(debug_style("WARN", "grab_args()", IsError and ArgumentData))
				
				return
			end
		end
	else
		for cmd, cmd_data in CommandsModule do
			local Aliases = cmd_data.Aliases
						
			if table.find(Aliases, Command) then
				print("Found command")
				
				for Index, Arg in cmd_data.Args do
					local ArgumentData, IsError = ArgumentTypes[Arg](Runner, Arg, Index, Arguments[Index], cmd_data)

					if ArgumentData and not IsError then
						CmdArgs[Arg] = ArgumentData
					else
						warn(debug_style("WARN", "grab_args()", IsError and ArgumentData))

						return
					end
				end
				
				CommandData = cmd_data
				
				break
			end
		end
	end
	
	return CommandData, CmdArgs
end

function run_command(Runner: Player, CommandData, Arguments)
	if CommandData and CommandData.Run then
		CommandData.Run(Runner, Arguments)
		
		return true
	end
	
	return
end

function register_command(Runner: Player, Text: string)
	local Split = Text:split(" ")
	
	local Command = Split[1]:find(Prefix, 1) and Split[1]
	
	local Arguments = table.remove(Split, 1) and Split
	
	if Command and next(Arguments) then
		local CommandData, CommandArgs = grab_args(Runner, Command, Arguments)
		
		if CommandArgs and next(CommandArgs) then
			local Status = run_command(Runner, CommandData, CommandArgs)
			
			print(Status)
		end
	elseif Command and not next(Arguments) then
		warn(debug_style("WARN", "register_command() ~> grab_args", "Can't run command in general. No args"))
	end
end

return function()
	if AccountIsMaster then return account_master() end
	
	verify_all_bots()
		
	TextChatService.MessageReceived:Once(function(message)
		local PlayerMessage: Player = PlayersService:FindFirstChild(message.TextSource.Name)
		
		if IsDisplayName and PlayerMessage.DisplayName == Master or PlayerMessage.Name == Master then
			print(debug_style("INFO", "main() => MessageReceived", message.Text))
			
			register_command(PlayerMessage, message.Text)
		end
	end)
end
