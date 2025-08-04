local ToolData = {}

export type ToolDefinition = {
	Name: string,
	Damage: number,
	-- More infos?
}

local tools: {[string]: ToolDefinition} = {
	["Wooden Pickaxe"] = {
		Name = "Wooden Pickaxe",
		Damage = 1,
		Type = "Pickaxe"
	},
	["Stone Pickaxe"] = {
		Name = "Stone Pickaxe",
		Damage = 2,
		Type = "Pickaxe"
	}
}



function ToolData.Get(toolName: string): ToolDefinition
	return tools[toolName]
end

function ToolData.GetAll(): {[string]: ToolDefinition}
	return tools
end

function ToolData.GetType(toolName: string): string?
	local tool = tools[toolName]
	if tool then
		return tool.Type
	end
	return nil
end

return ToolData