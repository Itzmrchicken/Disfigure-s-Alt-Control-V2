local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Functions = {}

local CommandsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzmrchicken/Disfigure-s-Alt-Control-V2/refs/heads/main/Commands.lua"))()

function Functions.Chat(Bot: number, BotIndex: number, Message: string)
	local TCS_Version = TextChatService.ChatVersion

	if Bot then
		if Bot == BotIndex then
			if TCS_Version == Enum.ChatVersion.TextChatService then
				local General_Channel: TextChannel = TextChatService.TextChannels.RBXGeneral

				General_Channel:SendAsync(Message)
			else
				ReplicatedStorageService:WaitForChild("DefaultChatSystemChatEvents").SayMessageRequest:FireServer(Message, "All")
			end

			return
		end
	else
		if TCS_Version == Enum.ChatVersion.TextChatService then
			local General_Channel: TextChannel = TextChatService.TextChannels.RBXGeneral

			General_Channel:SendAsync(Message)
		else
			ReplicatedStorageService:WaitForChild("DefaultChatSystemChatEvents").SayMessageRequest:FireServer(Message, "All")
		end
	end
end

function Functions.CommandData(Command: string)
	if CommandsModule[Command] then
		return CommandsModule[Command]
	else
		for cmd, cmd_data in CommandsModule do
			local Aliases = cmd_data.Aliases
			
			if table.find(Aliases, Command) then
				return cmd_data
			end
		end
	end
	
	return "Couldn't find command "..Command, true
end

return Functions
