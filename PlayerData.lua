local PlayerDataModule = require(script.Parent.PlayerData.PlayerDataModule)

local playerDataTable = {}

local handler = {}

function handler.Create(player: PLayer)
	playerDataTable[player.UserId] = PlayerDataModule.new(player)
	return playerDataTable[player.UserId]
end

function handler.Get(player)
	return playerDataTable[player.UserId]
end

function handler.Clear(player)
	playerDataTable[player.UserId] = nil
end

return handler