local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")

local LocalPlayer = PlayersService.LocalPlayer

local Data = getgenv().Data

local FunctionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/functions.lua"))()
local CommandsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/Commands.lua"))()

local Whitelist = Data["Whitelist"]
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
	
	random = function(Runner: Player)
		local Players = PlayersService:GetPlayers()
		
		return Players[math.random(1, #Players)]
	end,
}

local ArgumentTypes = {
	player = function(Runner: Player, Data)
		local ArgText = Data.ArgText
		
		if CustomArgs[ArgText] then
			return CustomArgs[ArgText](Runner)
		end
		
		for _, player in PlayersService:GetPlayers() do
			if ArgText and (player.Name:lower():sub(1, #ArgText) == ArgText or player.DisplayName:lower():sub(1, #ArgText) == ArgText) then
				return player
			end
		end
		
		return "Player not found or nil", true
	end,
	
	command = function(Runner: Player, Data)
		local ArgText = Data.ArgText
		
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
	
	message = function(Runner: Player, Data)
		local OriginalMessage = Data.OriginalMessage
		
		return OriginalMessage
	end,
	
	none = function(Runner: Player, Data)
		return true
	end,
	
	word = function(Runner: Player, Data)
		return Data.ArgText
	end,
	
	number = function(Runner: Player, Data)
		return tonumber(Data.ArgText)
	end,
}

function debug_style(Type: string, FunctionName: string, ...)
	return "["..Type.."]["..FunctionName.."] ".. ...
end

function verify_all_bots()
	local NewBots = {}
	
	for _, bot in Bots do
		if PlayersService:FindFirstChild(bot) then
			table.insert(NewBots, bot)
		else
			warn(debug_style("WARN", "main() => verify_all_bots()", bot.." doesn't exist in-game"))
		end
	end
	
	--BotIndex = not AccountIsMaster and table.find(NewBots, LocalPlayer.Name)
		
	Bots = NewBots
	
	getgenv().Data.Bots = NewBots
end

function account_master()
	print(debug_style("INFO", "account_master()", "Account is master"))
	
	verify_all_bots()
end

function grab_args(Runner: Player, Command: string, Arguments, Data)
	local CommandData = {}
	local CmdArgs = {}
	
	Command = Command:split(".")[2]
	
	if CommandsModule[Command] then
		CommandData = CommandsModule[Command]
		
		for Index, Arg in CommandsModule[Command].Args do
			local ArgumentData, IsError = ArgumentTypes[Arg](Runner, {
				Arg = Arg,
				Index = Index,
				ArgText = Arguments[Index],
				Arguments = Arguments,
				OriginalMessage = Data.OriginalMessage
			})
			
			if ArgumentData and not IsError then
				if CmdArgs[Arg] then
					local SameName = 0
					
					for _, name in ipairs(CmdArgs) do
						if name == Arg then
							SameName += 1
						end
					end
					
					print(SameName)
					
					CmdArgs[Arg..SameName] = ArgumentData
				else
					CmdArgs[Arg] = ArgumentData
				end
			else
				warn(debug_style("WARN", "grab_args()", IsError and ArgumentData))
				
				return
			end
		end
	else
		for cmd, cmd_data in CommandsModule do
			local Aliases = cmd_data.Aliases
						
			if table.find(Aliases, Command) then
				for Index, Arg in cmd_data.Args do
					local ArgumentData, IsError = ArgumentTypes[Arg](Runner, {
						Arg = Arg,
						Index = Index,
						ArgText = Arguments[Index]
					})

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
	
	--print(HttpService:JSONEncode(CmdArgs))
		
	return CommandData, CmdArgs
end

function run_command(Runner: Player, CommandData, Arguments)
	if CommandData and CommandData.Run then
		CommandData.Run(Runner, Arguments)
		
		return true
	end
	
	return
end

function get_original_message(SubStrings: {})
	return table.concat(SubStrings, " ")
end

function register_command(Runner: Player, Text: string)
	local Split = Text:split(" ")
	
	local Command = Split[1]:find(Prefix, 1) and Split[1]
	
	local Arguments = table.remove(Split, 1) and Split
	
	if not Command then return end
	
	if Command and Arguments then
		local CommandData, CommandArgs = grab_args(Runner, Command, Arguments, {
			OriginalMessage = get_original_message(Arguments)
		})
		
		if CommandArgs and next(CommandArgs) then
			local Status = run_command(Runner, CommandData, CommandArgs)
			
			print(debug_style("INFO", "main() => register_command()", "Command status: "..(Status and "Completed") or "Failed"))
		end
	--elseif Command and not next(Arguments) then
	--	warn(debug_style("WARN", "register_command() ~> grab_args", "Can't run command in general. No args"))
	end
end

return function()
	print(debug_style("INFO", "main()", "Loading script on Master and Bot . . ."))
	
	if AccountIsMaster then return account_master() end
	
	Bots = getgenv().Data.Bots
		
	BotIndex = table.find(Bots, LocalPlayer.Name) and table.find(Bots, LocalPlayer.Name) or table.find(Bots, LocalPlayer.DisplayName)
	
	UserSettings():GetService("UserGameSettings").MasterVolume = 0
	UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
	
	setfpscap(60)
	
	--UserSettings().GameSettings.StartMaximized = false
	--UserSettings().GameSettings.MaxQuality = true
		
	TextChatService.MessageReceived:Connect(function(message)
		local PlayerMessage: Player = PlayersService:FindFirstChild(message.TextSource.Name)
		
		Whitelist = getgenv().Data.Whitelist
		
		if (IsDisplayName and PlayerMessage.DisplayName == Master or PlayerMessage.Name == Master) or (table.find(Whitelist, PlayerMessage.Name) or table.find(Whitelist, PlayerMessage.DisplayName)) then
			print(debug_style("INFO", "main() => MessageReceived", message.Text))
			
			register_command(PlayerMessage, message.Text)
		end
	end)
end
