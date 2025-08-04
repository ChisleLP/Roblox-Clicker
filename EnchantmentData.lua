local EnchantmentData = {}

export type EnchantmentDefinition = {
	Name: string,
	MaxLevel: number,
	Description: string?
}

local enchantments: {[string]: EnchantmentDefinition} = {
	
	Efficiency = {
		Name = "Efficiency",
		MaxLevel = 5,
		Description = "Increases Power"
	},
	
	Fortune = {
		Name = "Fortune",
		MaxLevel = 3,
		Description = "Increases drop chance"
	},
	
	Silktouch = {
		Name = "Silktouch",
		MaxLevel = 1,
		Description = "SILLKKK"
	}
}

function EnchantmentData.Get(name: string): EnchantmentDefinition?
	return enchantments[name]
end

function EnchantmentData.GetAll(): {[string]: EnchantmentDefinition}
	return enchantments
end

return EnchantmentData