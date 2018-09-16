local _, BFAMasterLooter = ...

-- indexes of array returned by GetFullItemInfo()
BFAMasterLooter.FII_ITEM = "ITEM";									-- contains the actual item
BFAMasterLooter.FII_NAME = "NAME";									-- return value 1 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_LINK = "LINK";									-- return value 2 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_QUALITY = "QUALITY";							-- return value 3 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_BASE_ILVL = "BASE_ILVL";						-- return value 4 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_REQUIRED_LEVEL = "REQUIRED_LEVEL";				-- return value 5 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_TYPE = "TYPE";									-- return value 6 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_SUB_TYPE = "SUB_TYPE";							-- return value 7 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_MAX_STACK = "MAX_STACK";						-- return value 8 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_ITEM_EQUIP_LOC = "ITEM_EQUIP_LOC";				-- return value 9 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_TEXTURE = "TEXTURE";							-- return value 10 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_VENDOR_PRICE = "VENDOR_PRICE";					-- return value 11 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_CLASS = "CLASS";								-- return value 12 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_SUB_CLASS = "SUB_CLASS";						-- return value 13 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_BIND_TYPE = "BIND_TYPE";						-- return value 14 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_EXPAC_ID = "EXPAC_ID";							-- return value 15 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_ITEM_SET_ID = "ITEM_SET_ID";					-- return value 16 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_IS_CRAFTING_REAGENT = "IS_CRAFTING_REAGENT";	-- return value 17 of Blizzard API call GetItemInfo()
BFAMasterLooter.FII_IS_EQUIPPABLE = "IS_EQUIPPABLE";				-- true if the item is equippable, false otherwise
BFAMasterLooter.FII_IS_RELIC = "IS_RELIC";							-- true if item is a relic, false otherwise
BFAMasterLooter.FII_REAL_ILVL = "REAL_ILVL";						-- real ilvl, derived from tooltip
BFAMasterLooter.FII_RELIC_TYPE = "RELIC_TYPE";						-- relic type, derived from tooltip
BFAMasterLooter.FII_CLASSES = "CLASSES";							-- uppercase string of classes that can use the item (ex: tier); nil if item is not class-restricted
BFAMasterLooter.FII_LOOTER = "LOOTER";
BFAMasterLooter.FII_RAND = "RAND";
BFAMasterLooter.FII_CHOICE = "CHOICE";
BFAMasterLooter.FII_PLAYER_NEEDING = "PLAYER_NEEDING";
BFAMasterLooter.FII_COMMENT = "COMMENT";
BFAMasterLooter.FII_TRADABLE = "TRADABLE";
BFAMasterLooter.FII_MAX_ILVL = "MAX_ILVL";
BFAMasterLooter.FII_EQUIPED_ILVL = "ACTUAL_ILVL";
BFAMasterLooter.FII_EQUIPED_ITEM_LINK = "EQ_ITEM_LINK";
BFAMasterLooter.FII_EQUIPED_ITEM_LINK2 = "EQ_ITEM_LINK2";

local TRADABLE = _G.BIND_TRADE_TIME_REMAINING;
	  TRADABLE = TRADABLE:gsub('%%s', '(.+)');

local PLH_CLASSES_ALLOWED_PATTERN = _G.ITEM_CLASSES_ALLOWED;
	  PLH_CLASSES_ALLOWED_PATTERN = PLH_CLASSES_ALLOWED_PATTERN:gsub('%%s', '(.+)');  -- 'Classes: (.+)'
local tooltip

--[[
creates an empty tooltip that is ready to be populated with the information from an item
-- note: a complicated tooltip could have the following lines (ex):
	1 - Oathclaw Helm, nil
	2 - Mythic, nil
	3 - Item Level 735
	4 - Upgrade Level: 2/2, nil
	5 - Binds when picked up, nil
	6 - Head, Leather
	
	rows - how many rows of the tooltip to populate; prior to version 1.24 we only cared about the first 6 rows, but to find the "classes:" row we have to go much deeper
]]--
function BFAMasterLooter.CreateEmptyTooltip(rows)
    local tip = CreateFrame('GameTooltip')
	local leftside = {}
	local rightside = {}
	local L, R
    for i = 1, rows do
        L, R = tip:CreateFontString(), tip:CreateFontString()
        L:SetFontObject(GameFontNormal)
        R:SetFontObject(GameFontNormal)
        tip:AddFontStrings(L, R)
        leftside[i] = L
		rightside[i] = R
    end
    tip.leftside = leftside
	tip.rightside = rightside
    return tip
end

local function CheckIfItemIsTradable(itemLinkOfLootedItem)
	local itemSlot;
	local tradable = false;
	
	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag,slot);
			
			if (itemLink ~= nil and itemLink == itemLinkOfLootedItem) then
				itemTooltip = itemTooltip or BFAMasterLooter.CreateEmptyTooltip(30)
				itemTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
				itemTooltip:SetBagItem(bag, slot)
				
				for i = 10, 25 do
					local tooltipText = itemTooltip.leftside[i]:GetText();
					if (tooltipText ~= nill and tooltipText:match(TRADABLE)) then
						tradable = true;
					end
				end
			end
		end
	end
	return tradable;
end

function BFAMasterLooter.GetFullItemInfo(item)
	fullItemInfo = {};
	fullItemInfo[BFAMasterLooter.FII_LOOTER] = UnitName("player");
	
	if item ~= nil then
		fullItemInfo[BFAMasterLooter.FII_ITEM] = item;
		
		-- determine the basic values from the Blizzard GetItemInfo() API call
		fullItemInfo[BFAMasterLooter.FII_NAME],
			fullItemInfo[BFAMasterLooter.FII_LINK],
			fullItemInfo[BFAMasterLooter.FII_QUALITY],
			fullItemInfo[BFAMasterLooter.FII_BASE_ILVL],
			fullItemInfo[BFAMasterLooter.FII_REQUIRED_LEVEL],
			fullItemInfo[BFAMasterLooter.FII_TYPE],
			fullItemInfo[BFAMasterLooter.FII_SUB_TYPE],
			fullItemInfo[BFAMasterLooter.FII_MAX_STACK],
			fullItemInfo[BFAMasterLooter.FII_ITEM_EQUIP_LOC],
			fullItemInfo[BFAMasterLooter.FII_TEXTURE],
			fullItemInfo[BFAMasterLooter.FII_VENDOR_PRICE],
			fullItemInfo[BFAMasterLooter.FII_CLASS],
			fullItemInfo[BFAMasterLooter.FII_SUB_CLASS],
			fullItemInfo[BFAMasterLooter.FII_BIND_TYPE],
			fullItemInfo[BFAMasterLooter.FII_EXPAC_ID],
			fullItemInfo[BFAMasterLooter.FII_ITEM_SET_ID],
			fullItemInfo[BFAMasterLooter.FII_IS_CRAFTING_REAGENT]
			= GetItemInfo(item);

		-- determine whether the item is equippable & whether it is a relic
		fullItemInfo[BFAMasterLooter.FII_IS_EQUIPPABLE] = IsEquippableItem(item);
		fullItemInfo[BFAMasterLooter.FII_IS_RELIC] = fullItemInfo[BFAMasterLooter.FII_CLASS] == LE_ITEM_CLASS_GEM and fullItemInfo[BFAMasterLooter.FII_SUB_CLASS] == LE_ITEM_ARMOR_RELIC;
		
		-- we only need to determine other values if it's an equippable item or a relic
		if fullItemInfo[BFAMasterLooter.FII_IS_EQUIPPABLE] or fullItemInfo[BFAMasterLooter.FII_IS_RELIC] then

			-- set up the tooltip to determine values that aren't returned via GetItemInfo()
			local rows = 30;
			if fullItemInfo[BFAMasterLooter.FII_IS_RELIC] then
				rows = 6;  -- if it's a relic, we only need to inspect the first 6 rows
			end
			tooltip = tooltip or BFAMasterLooter.CreateEmptyTooltip(30);
			tooltip:SetOwner(UIParent, 'ANCHOR_NONE');
			tooltip:ClearLines();
			tooltip:SetHyperlink(item);
			local t;
			local index;

			-- determine the real iLVL
			PLH_ITEM_LEVEL_PATTERN = _G.ITEM_LEVEL;
			PLH_ITEM_LEVEL_PATTERN = PLH_ITEM_LEVEL_PATTERN:gsub('%%d', '(%%d+)');  -- 'Item Level (%d+)'
			PLH_RELIC_TOOLTIP_TYPE_PATTERN = _G.RELIC_TOOLTIP_TYPE;
			PLH_RELIC_TOOLTIP_TYPE_PATTERN = PLH_RELIC_TOOLTIP_TYPE_PATTERN:gsub('%%s', '(.+)');  -- '(.+) Artifact Relic'
			
			local realILVL = nil
			t = tooltip.leftside[2]:GetText();
			if t ~= nil then
				realILVL = t:match(PLH_ITEM_LEVEL_PATTERN);
			end
			if realILVL == nil then  -- ilvl can be in the 2nd or 3rd line dependng on the tooltip; if we didn't find it in 2nd, try 3rd
				t = tooltip.leftside[3]:GetText()
				if t ~= nil then
					realILVL = t:match(PLH_ITEM_LEVEL_PATTERN);
				end
			end
			if realILVL == nil then  -- if we still couldn't find it (shouldn't happen), just use the ilvl we got from GetItemInfo()
				realILVL = fullItemInfo[BFAMasterLooter.FII_BASE_ILVL];
			end
			fullItemInfo[BFAMasterLooter.FII_REAL_ILVL] = tonumber(realILVL);

			-- if the item is a relic, determine the relic type
			local relicType = nil;
			if fullItemInfo[BFAMasterLooter.FII_IS_RELIC] then
				index = 1;
				while not relicType and tooltip.leftside[index] do
					t = tooltip.leftside[index]:GetText();
					if t ~= nil then
						relicType = t:match(PLH_RELIC_TOOLTIP_TYPE_PATTERN);
					end
					index = index + 1;
				end
			end
			fullItemInfo[BFAMasterLooter.FII_RELIC_TYPE] = relicType;

			-- if the item is restricted to certain classes, determine which ones
			local classes = nil;
			index = 1;
			while not classes and tooltip.leftside[index] do
				t = tooltip.leftside[index]:GetText();
				if t ~= nil then
					classes = t:match(PLH_CLASSES_ALLOWED_PATTERN);
				end
				index = index + 1;
			end
			if classes ~= nil then
				classes = string.upper(classes);
				classes = string.gsub(classes, " ", "");  -- remove space for DEMON HUNTER, DEATH KNIGHT
			end
			fullItemInfo[BFAMasterLooter.FII_CLASSES] = classes;

			-- hide the tooltip now that we're done with it (is this really necessary?)
			tooltip:Hide()
			
			fullItemInfo[BFAMasterLooter.FII_TRADABLE] = CheckIfItemIsTradable(fullItemInfo[BFAMasterLooter.FII_LINK]);
			fullItemInfo[BFAMasterLooter.FII_EQUIPED_ITEM_LINK2] = nil;
		end
	end

	return fullItemInfo;
end
