local BlockModule = {}

export type BlockDefinition = {
	Name: string,
	MaxHP: number,
	Textures: {
		Top: string?,
		Bottom: string?,
		Side: string?
	},
	Drops: {
		default: string,
		silktouch: string?,
		supportFortune: boolean?,
	},
	RequriedTool: string?
}

export type BlockInstance = {
	Part: Part,
	HP: number,
	Definition: BlockDefinition,
	
	-- Function --
	SetBlockType: (self: BlockInstance, blockType: string) -> (),
	GetBlockType: (self: BlockInstance) -> string,
	Damage: (self: BlockInstance, amount: number) -> boolean,
	GetDrop: (self: BlockInstance, hasSilktouch: boolean) -> string,
	GetDropCount: (self: BlockInstance, fortuneLevel: number) -> number,
	GetRequriedTool: (self: BlockInstance) -> string?,
	UpdateVisuals: (self: BlockInstance) -> ()
}

local blockDefinitions: {[string]: BlockDefinition} = {
	Dirt = {
		Name = "Dirt",
		MaxHP = 10,
		Textures = {
			Top = "3027464199",
			Bottom = "3027464199",
			Side = "3027464199"
		},
		Drops = {
			default = "Dirt"
		}
	},
	Grass = {
		Name = "Grass",
		MaxHP = 10,
		Textures = {
			Top = "9267183930",
			Bottom = "3027464199",
			Side = "9267155972",
		},
		Drops = {
			default = "Dirt",
			silktouch = "Grass"
		}
	},
	["Oak Log"] = {
		Name = "Oak Log",
		MaxHP = 15,
		Textures = {
			Top = "3313419952",
			Bottom = "3313419952",
			Side = "3313420421"
		},
		Drops = {
			default = "Oak Log"
		}
	},
	["Coal Ore"] = {
		Name = "Coal Ore",
		MaxHP = 30,
		Textures = {
			Top = "87517589",
			Bottom = "87517589",
			Side = "87517589"
		},
		Drops = {
			default = "Coal",
			silktouch = "Coal Ore",
			supportFortune = true,
		},
		RequriedTool = "Pickaxe"
	}
}

function BlockModule.new(part: Part, blockType: string): BlockInstance
	local definition = blockDefinitions[blockType]
	if not definition then
		error("Unknow block: "..blockType)
	end
	
	local self = {
		Part = part,
		HP = definition.MaxHP,
		Definition = definition
	}
	
	self.Part:SetAttribute("BlockMaxHP", definition.MaxHP)
	self.Part:SetAttribute("BlockHP", definition.MaxHP)
	self.Part:SetAttribute("BlockName", blockType)
	
	function self:SetBlockType(blockType: string)
		local def = blockDefinitions[blockType]
		if not def then error("Unknow Block: "..blockType) end
		self.Definition = def
		self.HP = def.MaxHP
		self.Part:SetAttribute("BlockMaxHP", def.MaxHP)
		self.Part:SetAttribute("BlockHP", def.MaxHP)
		self.Part:SetAttribute("BlockName", blockType)
		self:UpdateVisuals()
	end
	
	function self:Damage(amount: number): boolean
		self.HP -= amount
		self.Part:SetAttribute("BlockHP", self.HP)
		if self.HP <= 0 then
			return true
		else
			return false
		end
	end
	
	function self:GetBlockType()
		return self.Definition.Name
	end
	
	function self:UpdateVisuals()
		local tex = self.Definition.Textures

		local function getOrCreateDecal(face: Enum.NormalId): Decal
			local existing = self.Part:FindFirstChild(face.Name)
			if existing and existing:IsA("Decal") then
				return existing
			end

			local decal = Instance.new("Decal")
			decal.Name = face.Name
			decal.Face = face
			decal.Parent = self.Part
			return decal
		end

		if tex.Top then
			getOrCreateDecal(Enum.NormalId.Top).Texture = "rbxassetid://"..tex.Top
		end

		if tex.Bottom then
			getOrCreateDecal(Enum.NormalId.Bottom).Texture = "rbxassetid://"..tex.Bottom
		end

		if tex.Side then
			for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right }) do
				getOrCreateDecal(face).Texture = "rbxassetid://"..tex.Side
			end
		end
	end
	
	function self:GetDrop(hasSilkTouch: boolean): string
		local drops = self.Definition.Drops
		if hasSilkTouch and drops.silktouch then
			return drops.silktouch
		end
		return drops.default
	end
	
	function self:GetDropCount(fortuneLevel: number): number
		if fortuneLevel <= 0 then
			return 1
		end
		if self.Definition.Drops.supportFortune and fortuneLevel > 0 then
			local bonus = math.random(1, fortuneLevel + 1)
			return bonus
		end
		return 1
	end
	
	function self:GetRequriedTool(): string?
		return self.Definition.RequriedTool
	end

	
	self:UpdateVisuals()
	return self
end

return BlockModule