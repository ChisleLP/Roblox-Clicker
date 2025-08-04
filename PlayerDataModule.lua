export type inventoryMap = {
	[string]: number
}

export type enchantmentMap = {
	[string]: number
}

export type toolState = {
	Owned: boolean,
	Enchantments: enchantmentMap
}

export type toolsMap = {
	[string]: toolState
}

export type statsMap = {
	Click: number,
	Blocks: number,
	Level: number,
	EXP: number,
	Rebirth: number,
	CurrentBiome: string,
}

export type playerData = {
	player: Player,
	
	stats: statsMap,
	inventory: inventoryMap,
	tools: toolsMap,
	equipedTool: string,
	
	-- Methods --
	AddStat: (self: playerData, statName: string, amount: number) -> (),
	RemoveStat: (self: playerData, statName: string, amount: number) -> boolean,
	SetStat: (self: playerData, statName: string, amount: number) -> (),
	GetStat: (self: playerData, statName: string) -> number | string,

	AddItem: (self: playerData, itemName: string, amount: number) -> (),
	RemoveItem: (self: playerData, itemName: string, amount: number) -> boolean,
	GetInventory: (self: playerData) -> inventoryMap,
	
	GetEquippedTool: (self: playerData) -> string,
	UnlockTool: (self: playerData, toolName: string) -> (),
	EquipTool: (self: playerData, toolName: string) -> boolean,
	
	GetEnchantLevel: (self: playerData, toolName: string, enchantName: string) -> number,
	SetEnchantLevel: (self: playerData, toolName: string, enchantName: string, amount: number) -> (), 
	
	
}

local PlayerDataModule = {}
PlayerDataModule.__index = PlayerDataModule

local ModuleScript = script.Parent.Parent

local ToolData = require(ModuleScript.ToolData)
local EnchantmentData = require(ModuleScript.ToolData.EnchantmentData)

function PlayerDataModule.new(player: Player) : playerData
	local self = setmetatable({}, PlayerDataModule)
	self.player = player
	self.inventory = {}
	self.stats = {
		Click = 0,
		Blocks = 0,
		Level = 1,
		EXP = 0,
		Rebirth = 0,
		CurrentBiome = "Surface"
	}
	self.equipedTool = "None"
	self.tools = {}
	
	for toolName in pairs(ToolData.GetAll()) do
		self.tools[toolName] = {}
		self.tools[toolName].Owned = false
		self.tools[toolName].Enchantments = {}
	end
	
	return self
end

function PlayerDataModule:AddStat(statName: string, amount: number)
	if not self.stats[statName] then
		error("Stat not found: " .. statName)
		return
	end
	amount = amount or 1
	self.stats[statName] += amount
	if statName == "Click" or statName == "Rebirth" or statName == "Blocks" then
		self:updateLeaderStats()
	end
end

function PlayerDataModule:RemoveStat(statName: string, amount: number): boolean
	if not self.stats[statName] then
		error("Stat not found: " .. statName)
		return
	end
	amount = amount or 1
	if self.stats[statName] >= amount then
		self.stats[statName] -= amount
		if statName == "Click" or statName == "Rebirth" or statName == "Blocks" then
			self:updateLeaderStats()
		end
		return true
	else
		return false
	end
end

function PlayerDataModule:SetStat(statName: string, amount: number | string)
	if not self.stats[statName] then
		error("Stat not found: " .. statName)
		return
	end
	amount = amount or 1
	self.stats[statName] = amount
	if statName == "Click" or statName == "Rebirth" or statName == "Blocks" then
		self:updateLeaderStats()
	end
end

function PlayerDataModule:GetStat(statName: string): number | string
	if not self.stats[statName] then
		error("Stat no found: ".. statName)
		return 0
	end
	return self.stats[statName]
end

function PlayerDataModule:AddItem(itemName: string, amount: number)
	amount = amount or 1
	self.inventory[itemName] = (self.inventory[itemName] or 0) + amount
end

function PlayerDataModule:RemoveItem(itemName: string, amount: number): boolean
	amount = amount or 1
	if self.inventory[itemName] and self.inventory[itemName] >= amount then
		self.inventory[itemName] -= amount
		if self.inventory[itemName] <= 0 then
			self.inventory[itemName] = nil
		end
		return true
	end
	return false
end

function PlayerDataModule:GetInventory(): inventoryMap
	return self.inventory
end

-- Update leaderStats --
function PlayerDataModule:updateLeaderStats()
	local ls = self.player:FindFirstChild("leaderstats")
	if ls then
		ls.Click.Value = self.stats.Click
		ls.Rebirth.Value = self.stats.Rebirth
		ls.Blocks.Value = self.stats.Blocks
	end
end

-- Tools --
function PlayerDataModule:GetEquippedTool(): string
	return self.equipedTool
end

function PlayerDataModule:UnlockTool(toolName: string)
	self.tools[toolName].Owned = true
end

function PlayerDataModule:EquipTool(toolName: string): boolean
	if self.tools[toolName].Owned then
		self.equipedTool = toolName
		return true
	end
	return false
end

function PlayerDataModule:GetEnchantLevel(toolName: string, enchant: string): number
	local tool = self.tools[toolName]
	if tool and tool.Enchantments and tool.Enchantments[enchant] then
		return tool.Enchantments[enchant]
	end
	return 0
end

function PlayerDataModule:SetEnchantLevel(toolName: string, enchant: string, level: number)
	local tool = self.tools[toolName]
	local enchantDef = EnchantmentData.Get(enchant)
	
	if not tool or not tool.Enchantments then return end
	if not enchantDef then
		warn("Invalid Enchantment name: "..enchant)
		return
	end
	local clampLevel = math.clamp(level, 0, enchantDef.MaxLevel)
	tool.Enchantments[enchant] = clampLevel
end

return PlayerDataModule
