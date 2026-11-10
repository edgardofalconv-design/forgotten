-- Visual prototype only. No gameplay constants or animation IDs belong here.
return {
	Version = "native-visual-20261110",
	-- IDs stay unset until verified in Studio. These are catalog item names,
	-- not mesh or texture IDs. The resolver requires Roblox (user ID 1).
	Resources = {
		Hair = {Name = "Pal Hair", Type = "HairAccessory", AssetTypeId = 41, Id = 0},
		Shirt = {Name = "Blue and Black Motorcycle Shirt", Type = "Shirt", AssetTypeId = 11, Id = 0},
		Pants = {Name = "Dark Green Jeans", Type = "Pants", AssetTypeId = 12, Id = 0},
	},
	-- Starting proportions for the selected native mesh body; review in Studio.
	Scale = {WidthScale = 0.80, DepthScale = 0.85, HeightScale = 1.00, HeadScale = 1.00},
	Skin = Color3.fromRGB(242, 243, 243),
	-- Accessory-only geometry from the previous work, in Roblox studs.
	SourceTorsoSize = Vector3.new(1.25, 1.10, 0.68),
	BackpackFit = Vector3.new(1, 1, 1),
	BackpackOffset = Vector3.new(0, 0, 0),
}
