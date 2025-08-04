local players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local PlayerDataHandler = require(SSS.ModuleScript.PlayerData)

local BlockModule = require(SSS.ModuleScript.BlockData)
local ToolData = require(script.Parent.ModuleScript.ToolData)
local BiomeData = require(script.Parent.ModuleScript.BiomeData)

local plotFolder = workspace.Plots
local UITemplate = RS.BlockHealthbar

local BiomeUpdate = RS.remoteEvent:WaitForChild("UpdateBiomeInfo")

players.PlayerAdded:Connect(function(player)
	
	local ls = Instance.new("Folder", player)
	ls.Name = "leaderstats"
	
	local Click = Instance.new("IntValue", ls)
	Click.Name = "Click"
	
	local rebirth = Instance.new("IntValue", ls)
	rebirth.Name = "Rebirth"
	
	local blocks = Instance.new("IntValue", ls)
	blocks.Name = "Blocks"
	
	-- i dont feel good now
	-- I give up with this sickness.
	
	local ply = PlayerDataHandler.Create(player)
	
	ply:UnlockTool("Wooden Pickaxe")
	ply:EquipTool("Wooden Pickaxe")

	for _, plot in pairs(plotFolder:GetChildren()) do
		if plot:GetAttribute("InUse") == true then continue end
		plot:SetAttribute("InUse", true)
		plot:SetAttribute("Owner", player.UserId)
		
		local clone = UITemplate:Clone()
		
		clone.Parent = player.PlayerGui
		clone.Adornee = plot.MainBlock
		
		local blockPart = plot.MainBlock
		local block = BlockModule.new(blockPart, "Grass")
		
		plot.MainBlock.ClickDetector.MouseClick:Connect(function(player)
			if plot:GetAttribute("Owner") ~= player.UserId then return end
			ply:AddStat("Click", 1)
			
			local tool = ply:GetEquippedTool()
			
			local toolInfo = ToolData.Get(tool)
			local effifency = ply:GetEnchantLevel(tool, "Efficiency")
			local damage = 1 + (toolInfo and toolInfo.Damage or 0) + effifency
			
			ply:SetEnchantLevel(tool, "Fortune", 3)
			ply:SetEnchantLevel(tool, "Efficiency", 5)
			--ply:SetEnchantLevel(tool, "Silktouch", 1)

			
			if block:Damage(damage) then
				
				
				ply:AddStat("Blocks", 1)
				
				
				local requriedTool = block:GetRequriedTool()
				if requriedTool and ToolData.GetType(tool) ~= requriedTool then
					print("No loot, wrong tool")
					block:SetBlockType("Coal Ore")
					return
				end
				

				
				local drop = block:GetDrop(ply:GetEnchantLevel(tool, "Silktouch") > 0)

				
				local dropAmount = block:GetDropCount(ply:GetEnchantLevel(tool, "Fortune"))
				
				
				
		
				
				
				ply:AddItem(drop, dropAmount)
				
				
				local newBlock = BiomeData.GetRandomBlock("Surface")
				block:SetBlockType(newBlock)
				
				
			end
		end)
		
		break
	end	
end)


BiomeUpdate.OnServerEvent:Connect(function(player, biome)
	local ply = PlayerDataHandler.Get(player)
	ply:SetStat("CurrentBiome", biome)
end)

