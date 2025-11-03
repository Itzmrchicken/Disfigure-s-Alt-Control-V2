local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Functions = {}

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

return Functions
