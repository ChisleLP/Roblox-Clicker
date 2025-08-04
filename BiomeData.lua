local BiomeData = {}

local RS = game:GetService("ReplicatedStorage")
local UpdateBiome = RS.remoteFunction:WaitForChild("UpdateBiome")
local SSS = game:GetService("ServerScriptService")
local PlayerDataHandler = require(SSS.ModuleScript.PlayerData)

export type BlockEntry = {
	BlockName: string,
	Chance: number
}

export type BiomeDefinition = {
	Name: string,
	UnlockBlocks: number,
	Blocks: { BlockEntry }
}

local biomes: {BiomeDefinition} = {
	{
		Name = "Surface",
		UnlockBlocks = 0,
		Blocks = {
			{BlockName = "Dirt", Chance = 60},
			{BlockName = "Grass", Chance = 30},
			{BlockName = "Oak Log", Chance = 90}
		}
	},
	{
		Name = "Deep",
		UnlockBlocks = 50,
		Blocks = {
			{BlockName = "Cobblestone", Chance = 60},
			{BlockName = "Coal Ore", Chance = 30},
			{BlockName = "Iron Ore", Chance = 10}
		}
	}
}

function BiomeData.GetCurrentBiome(): BiomeDefinition
	return biomes.Surface
end

local function getBiomeByName(name: string): BiomeDefinition?
	for _, biome in pairs(biomes) do
		if biome.Name == name then
			return biome
		end
	end
end

function BiomeData.GetRandomBlock(layer: string): string
	local biome = getBiomeByName(layer)
	if not biome or not biome.Blocks or #biome.Blocks == 0 then
		warn("Biome not found, or has no blocks: "..layer)
		return nil
	end
	local total = 0
	for _, b in pairs(biome.Blocks) do
		total = total + b.Chance
	end
	
	local roll = math.random(1, total)
	local acc = 0
	for _, b in pairs(biome.Blocks) do
		acc += b.Chance
		if roll <= acc then
			return b.BlockName
		end
	end
end

UpdateBiome.OnServerInvoke = function(player)
	print(player.UserId)
	local ply = PlayerDataHandler.Get(player)
	
	print(ply)
	
	return biomes, ply:GetStat("CurrentBiome")
end

return BiomeData