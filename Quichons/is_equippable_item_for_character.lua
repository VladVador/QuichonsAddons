local _, BFAMasterLooter = ...

local DEATH_KNIGHT = select(2, GetClassInfo(6))
local DEMON_HUNTER = select(2, GetClassInfo(12))
local DRUID = select(2, GetClassInfo(11))
local HUNTER = select(2, GetClassInfo(3))
local MAGE = select(2, GetClassInfo(8))
local MONK = select(2, GetClassInfo(10))
local PALADIN = select(2, GetClassInfo(2))
local PRIEST = select(2, GetClassInfo(5))
local ROGUE = select(2, GetClassInfo(4))
local SHAMAN = select(2, GetClassInfo(7))
local WARLOCK = select(2, GetClassInfo(9))
local WARRIOR = select(2, GetClassInfo(1))

local ValidGear = {
--	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
--	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },
	{ DEATH_KNIGHT, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H },

--	{ DEMON_HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ DEMON_HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ DEMON_HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ DEMON_HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WARGLAIVE },

--	{ DRUID, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ DRUID, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ DRUID, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ DRUID, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },

--	{ HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ HUNTER, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_BOWS },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_CROSSBOW },
	{ HUNTER, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GUNS },

	{ MAGE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ MAGE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ MAGE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ MAGE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ MAGE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ MAGE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WAND },

--	{ MONK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ MONK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ MONK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ MONK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },

--	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
--	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE },
	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ PALADIN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },
	{ PALADIN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H },

	{ PRIEST, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ PRIEST, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ PRIEST, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ PRIEST, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ PRIEST, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ PRIEST, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WAND },

--	{ ROGUE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ ROGUE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ ROGUE, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_BOWS },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_CROSSBOW },
	{ ROGUE, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GUNS },

--	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ SHAMAN, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ SHAMAN, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },

	{ WARLOCK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
	{ WARLOCK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ WARLOCK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ WARLOCK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ WARLOCK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ WARLOCK, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_WAND },

--	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH },
--	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER },
--	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL },
	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE },
	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC },
	{ WARRIOR, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE1H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_DAGGER },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_UNARMED },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE1H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_POLEARM },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_STAFF },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD1H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_AXE2H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_MACE2H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_SWORD2H },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_BOWS },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_CROSSBOW },
	{ WARRIOR, LE_ITEM_CLASS_WEAPON, LE_ITEM_WEAPON_GUNS }
}

local ValidRelics = {
	[250] = {RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_IRON}, -- Blood DK
	[251] = {RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_FROST}, -- Frost DK
	[252] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_BLOOD}, -- Unholy DK

	[577] = {RELIC_SLOT_TYPE_FEL, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_FEL}, -- Havoc DH
	[581] = {RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_FEL}, -- Vengeance DH

	[102] = {RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_ARCANE}, -- Balance Druid
	[103] = {RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_LIFE}, -- Feral Druid
	[104] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_LIFE}, -- Guardian Druid
	[105] = {RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_LIFE}, -- Restoration Druid

	[253] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_IRON}, -- Beast Mastery Hunter
	[254] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_LIFE}, -- Marksmanship Hunter
	[255] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_BLOOD}, -- Survival Hunter

	[62] = {RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_ARCANE}, -- Arcane Mage
	[63] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_FIRE}, -- Fire Mage
	[64] = {RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_ARCANE, RELIC_SLOT_TYPE_FROST}, -- Frost Mage

	[268] = {RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_IRON}, -- Brewmaster Monk
	[270] = {RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_WIND}, -- Mistweaver Monk
	[269] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_WIND}, -- Windwalker Monk

	[65] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_HOLY}, -- Holy Paladin
	[66] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_ARCANE}, -- Protection Paladin
	[70] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_HOLY}, -- Retribution Paladin

	[256] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_HOLY}, -- Discipline Priest
	[257] = {RELIC_SLOT_TYPE_HOLY, RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_HOLY}, -- Holy Priest
	[258] = {RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_SHADOW}, -- Shadow Priest

	[259] = {RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_BLOOD}, -- Assassination Rogue
	[260] = {RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_WIND}, -- Outlaw Rogue
	[261] = {RELIC_SLOT_TYPE_FEL, RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_FEL}, -- Subtlety Rogue

	[262] = {RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_WIND}, -- Elemental Shaman
	[263] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_WIND}, -- Enhancement Shaman
	[264] = {RELIC_SLOT_TYPE_LIFE, RELIC_SLOT_TYPE_FROST, RELIC_SLOT_TYPE_LIFE}, -- Restoration Shaman

	[265] = {RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_SHADOW}, -- Affliction Warlock
	[266] = {RELIC_SLOT_TYPE_SHADOW, RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_FEL}, -- Demonology Warlock
	[267] = {RELIC_SLOT_TYPE_FEL, RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_FEL}, -- Destruction Warlock

	[71] = {RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_SHADOW}, -- Arms Warrior
	[72] = {RELIC_SLOT_TYPE_FIRE, RELIC_SLOT_TYPE_WIND, RELIC_SLOT_TYPE_IRON}, -- Fury Warrior
	[73] = {RELIC_SLOT_TYPE_IRON, RELIC_SLOT_TYPE_BLOOD, RELIC_SLOT_TYPE_FIRE}, -- Protection Warrior
}

-- IDs for following are from http://wow.gamepedia.com/API_GetInspectSpecialization
local PrimaryAttributes = {
	{ DEATH_KNIGHT, 'Any', ITEM_MOD_STRENGTH_SHORT },
	
	{ DEMON_HUNTER, 'Any', ITEM_MOD_AGILITY_SHORT },
	
	{ DRUID, 102, ITEM_MOD_INTELLECT_SHORT },			-- balance
	{ DRUID, 103, ITEM_MOD_AGILITY_SHORT },			-- feral
	{ DRUID, 104, ITEM_MOD_AGILITY_SHORT },			-- guardian
	{ DRUID, 105, ITEM_MOD_INTELLECT_SHORT },			-- restoration
	
	{ HUNTER, 'Any', ITEM_MOD_AGILITY_SHORT },
	
	{ MAGE, 'Any', ITEM_MOD_INTELLECT_SHORT },

	{ MONK, 268, ITEM_MOD_AGILITY_SHORT },				-- brewmaster
	{ MONK, 270, ITEM_MOD_INTELLECT_SHORT },			-- mistweaver
	{ MONK, 269, ITEM_MOD_AGILITY_SHORT },				-- windwalker
	
	{ PALADIN, 65, ITEM_MOD_INTELLECT_SHORT },			-- holy
	{ PALADIN, 66, ITEM_MOD_STRENGTH_SHORT },			-- protection
	{ PALADIN, 70, ITEM_MOD_STRENGTH_SHORT },			-- retribution

	{ PRIEST, 'Any', ITEM_MOD_INTELLECT_SHORT },
	
	{ ROGUE, 'Any', ITEM_MOD_AGILITY_SHORT },

	{ SHAMAN, 262, ITEM_MOD_INTELLECT_SHORT },			-- elemental
	{ SHAMAN, 263, ITEM_MOD_AGILITY_SHORT },			-- enhancement
	{ SHAMAN, 264, ITEM_MOD_INTELLECT_SHORT },			-- restoration
	
	{ WARLOCK, 'Any', ITEM_MOD_INTELLECT_SHORT },
	
	{ WARRIOR, 'Any', ITEM_MOD_STRENGTH_SHORT }
}

local OffspecAttributes = {
	{ DRUID, 102, ITEM_MOD_AGILITY_SHORT },			-- balance
	{ DRUID, 103, ITEM_MOD_INTELLECT_SHORT },			-- feral
	{ DRUID, 104, ITEM_MOD_INTELLECT_SHORT },			-- guardian
	{ DRUID, 105, ITEM_MOD_AGILITY_SHORT },			-- restoration

	{ MONK, 268, ITEM_MOD_INTELLECT_SHORT },			-- brewmaster
	{ MONK, 270, ITEM_MOD_AGILITY_SHORT },				-- mistweaver
	{ MONK, 269, ITEM_MOD_INTELLECT_SHORT },			-- windwalker

	{ PALADIN, 65, ITEM_MOD_STRENGTH_SHORT },			-- holy
	{ PALADIN, 66, ITEM_MOD_INTELLECT_SHORT },			-- protection
	{ PALADIN, 70, ITEM_MOD_INTELLECT_SHORT },			-- retribution

	{ SHAMAN, 262, ITEM_MOD_AGILITY_SHORT },			-- elemental
	{ SHAMAN, 263, ITEM_MOD_INTELLECT_SHORT },			-- enhancement
	{ SHAMAN, 264, ITEM_MOD_AGILITY_SHORT }			-- restoration
	
}

-- note that this will return a value based on player's class/spec, so it will switch if the primary attribute is mutable!
-- thus only use for cloaks/rings/necks/trinkets, sine those things are not mutable
local function GetItemPrimaryAttribute(item)
	local stats = GetItemStats(item)
	if stats ~= nil then
		for stat, value in pairs(stats) do
			if _G[stat] == ITEM_MOD_STRENGTH_SHORT or _G[stat] == ITEM_MOD_INTELLECT_SHORT or _G[stat] == ITEM_MOD_AGILITY_SHORT then
				return _G[stat]
			end
		end
	end
	return nil
end

local function IsMutablePrimaryAttribute(itemEquipLoc)
	return itemEquipLoc == 'INVTYPE_HEAD'
		or itemEquipLoc == 'INVTYPE_SHOULDER'
		or itemEquipLoc == 'INVTYPE_CLOAK'
		or itemEquipLoc == 'INVTYPE_CHEST'
		or itemEquipLoc == 'INVTYPE_ROBE'
		or itemEquipLoc == 'INVTYPE_WAIST'
		or itemEquipLoc == 'INVTYPE_LEGS'
		or itemEquipLoc == 'INVTYPE_FEET'
		or itemEquipLoc == 'INVTYPE_WRIST'
		or itemEquipLoc == 'INVTYPE_HAND'
end

local function IsTrinketUsable(item, role)
	return true;
end

local function IsValidRelicTypeForSpec(relicType, spec)
	local specRelics = ValidRelics[spec]
	if specRelics ~= nil then
		return ValidRelics[spec][1] == relicType or ValidRelics[spec][2] == relicType or ValidRelics[spec][3] == relicType
	else
		return false
	end
end

-- Returns false if the character cannot use the item.
function BFAMasterLooter.IsEquippableItemForCharacter(fullItemInfo)
	local isEquippableForClass = false
	local isEquippableForSpec = false
	local isEquippableForOffspec = false
	if fullItemInfo ~= nil then
		if fullItemInfo[BFAMasterLooter.FII_IS_EQUIPPABLE] or fullItemInfo[BFAMasterLooter.FII_IS_RELIC] then
			local requiredLevel = fullItemInfo[BFAMasterLooter.FII_REQUIRED_LEVEL]
			local itemEquipLoc = fullItemInfo[BFAMasterLooter.FII_ITEM_EQUIP_LOC]
			local itemClass = fullItemInfo[BFAMasterLooter.FII_CLASS]
			local itemSubclass = fullItemInfo[BFAMasterLooter.FII_SUB_CLASS]
			local class
			local spec
			local characterLevel
			_, class = UnitClass('player')
			spec = GetSpecializationInfo(GetSpecialization())
			characterLevel = UnitLevel('player')
			
			isEquippableForClass = itemEquipLoc == 'INVTYPE_CLOAK' -- cloaks show up as type=armor, subtype=cloth, but they're equippable by all, so set to true if cloak
			local i = 1
			
			while not isEquippableForClass and ValidGear[i] do
				if class == ValidGear[i][1] and itemClass == ValidGear[i][2] and itemSubclass == ValidGear[i][3] then
					isEquippableForClass = true
				end
				i = i + 1
			end

			-- check whether to item is a class restricted item (ex: tier)
			if fullItemInfo[BFAMasterLooter.FII_CLASSES] ~= nil then
				if not string.find(class, fullItemInfo[BFAMasterLooter.FII_CLASSES]) then
					isEquippableForClass = false
				end
			end
			
			if isEquippableForClass then
				if itemEquipLoc == 'INVTYPE_TRINKET' then
					item = fullItemInfo[BFAMasterLooter.FII_ITEM]
					if spec == 105 or spec == 270 or spec == 65 or spec == 256 or spec == 257 or spec == 264 then
						isEquippableForSpec = IsTrinketUsable(item, 'Healer')					
					elseif spec == 250 or spec == 581 or spec == 104 or spec == 268 or spec == 66 or spec == 73 then
						isEquippableForSpec = IsTrinketUsable(item, 'Tank')
					elseif spec == 577 or spec == 103 or spec == 253 or spec == 254 or spec == 255 or spec == 269 or spec == 259 or spec == 260 or spec == 261 or spec == 263 then
						isEquippableForSpec = IsTrinketUsable(item, 'AgilityDPS')
					elseif spec == 251 or spec == 252 or spec == 70 or spec == 71 or spec == 72 then
						isEquippableForSpec = IsTrinketUsable(item, 'StrengthDPS')
					elseif spec == 102 or spec == 62 or spec == 63 or spec == 64 or spec == 258 or spec == 262 or spec == 265 or spec == 266 or spec == 267 then
						isEquippableForSpec = IsTrinketUsable(item, 'IntellectDPS')
					end
						
					if not isEquippableForSpec then
						if class == DEATH_KNIGHT or class == WARRIOR then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'StrengthDPS')
						elseif class == DEMON_HUNTER then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'AgilityDPS')
						elseif class == DRUID then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'AgilityDPS') or IsTrinketUsable(item, 'Healer') or IsTrinketUsable(item, 'IntellectDPS')
						elseif class == MONK then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'AgilityDPS') or IsTrinketUsable(item, 'Healer')
						elseif class == PALADIN then
							isEquippableForOffspec = IsTrinketUsable(item, 'Tank') or IsTrinketUsable(item, 'StrengthDPS') or IsTrinketUsable(item, 'Healer')
						elseif class == PRIEST then
							isEquippableForOffspec = IsTrinketUsable(item, 'Healer') or IsTrinketUsable(item, 'IntellectDPS')
						elseif class == SHAMAN then
							isEquippableForOffspec = IsTrinketUsable(item, 'Healer') or IsTrinketUsable(item, 'IntellectDPS') or IsTrinketUsable(item, 'AgilityDPS')
						end
					end
				else
					local itemPrimaryAttribute = GetItemPrimaryAttribute(fullItemInfo[BFAMasterLooter.FII_ITEM])
					if itemPrimaryAttribute == nil then
						isEquippableForSpec = true  -- if there's no primary attr (ex: ring/neck), then the item is equippable by everyone
					elseif IsMutablePrimaryAttribute(itemEquipLoc) then
						isEquippableForSpec = true	-- if the item is a piece of gear that has mutable primary stats then return true
					else
						-- otherwise we're going to check if the item's primary attribute is applicable for the character's spec
						i = 1
						while not isEquippableForSpec and PrimaryAttributes[i] do
							if class == PrimaryAttributes[i][1] and PrimaryAttributes[i][3] == itemPrimaryAttribute and (PrimaryAttributes[i][2] == 'Any' or PrimaryAttributes[i][2] == spec) then
								isEquippableForSpec = true
							end
							i = i + 1
						end

						if not isEquippableForSpec then
							-- now check to see if it's usable by an offspec
							i = 1
							while not isEquippableForSpec and OffspecAttributes[i] do
								if class == OffspecAttributes[i][1] and OffspecAttributes[i][3] == itemPrimaryAttribute and OffspecAttributes[i][2] == spec then
									isEquippableForOffspec = true
								end
								i = i + 1
							end
						end
					end
				end
			elseif fullItemInfo[BFAMasterLooter.FII_IS_RELIC] then
				local relicType = fullItemInfo[BFAMasterLooter.FII_RELIC_TYPE]
				isEquippableForSpec = IsValidRelicTypeForSpec(relicType, spec)
				isEquippableForClass = isEquippableForSpec
				if not isEquippableForSpec then
					if class == DEATH_KNIGHT then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 250) or IsValidRelicTypeForSpec(relicType, 251) or IsValidRelicTypeForSpec(relicType, 252)
					elseif class == DEMON_HUNTER then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 577) or IsValidRelicTypeForSpec(relicType, 581)
					elseif class == DRUID then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 102) or IsValidRelicTypeForSpec(relicType, 103) or IsValidRelicTypeForSpec(relicType, 104) or IsValidRelicTypeForSpec(relicType, 105)
					elseif class == HUNTER then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 253) or IsValidRelicTypeForSpec(relicType, 254) or IsValidRelicTypeForSpec(relicType, 255)
					elseif class == MAGE then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 62) or IsValidRelicTypeForSpec(relicType, 63) or IsValidRelicTypeForSpec(relicType, 64)
					elseif class == MONK then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 268) or IsValidRelicTypeForSpec(relicType, 270) or IsValidRelicTypeForSpec(relicType, 269)
					elseif class == PALADIN then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 65) or IsValidRelicTypeForSpec(relicType, 66) or IsValidRelicTypeForSpec(relicType, 70)
					elseif class == PRIEST then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 256) or IsValidRelicTypeForSpec(relicType, 257) or IsValidRelicTypeForSpec(relicType, 258)
					elseif class == ROGUE then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 259) or IsValidRelicTypeForSpec(relicType, 260) or IsValidRelicTypeForSpec(relicType, 261)
					elseif class == SHAMAN then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 262) or IsValidRelicTypeForSpec(relicType, 263) or IsValidRelicTypeForSpec(relicType, 264)
					elseif class == WARLOCK then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 265) or IsValidRelicTypeForSpec(relicType, 266) or IsValidRelicTypeForSpec(relicType, 267)
					elseif class == WARRIOR then
						isEquippableForOffspec = IsValidRelicTypeForSpec(relicType, 71) or IsValidRelicTypeForSpec(relicType, 72) or IsValidRelicTypeForSpec(relicType, 73)
					end
					isEquippableForClass = isEquippableForSpec or isEquippableForOffspec
				end
			end
		end
	end

	return isEquippableForClass and (isEquippableForSpec or isEquippableForOffspec)
end