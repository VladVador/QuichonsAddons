local _, BFAMasterLooter = ...

BFAMasterLooter = LibStub("AceAddon-3.0"):NewAddon(BFAMasterLooter, "BFAMasterLooter", "AceConsole-3.0", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0");
local Comm = LibStub:GetLibrary("AceComm-3.0");

--- CONSTANTS --
local VERSION = 0.2;

local TIME_FOR_LOOTING = 120;
local TIME_FOR_RAND = 30;
local TIME_BUFFER = 5;

local RAID_LEADER = 2;
local RAID_ASSISTANT = 1;
local RAID_PLEBS = 0;

local HAVE_LOOTED = "Y";
local PENDING_LOOT = "P";
local DIDNT_LOOTED = "N";
local BIG_SHIT_LOOT = "S";

local ASK_FOR_VERSION = "ASK";

local HEAD = "HeadSlot";
local NECK = "NeckSlot";
local SHOULDER = "ShoulderSlot";
local BACK = "BackSlot";
local CHEST = "ChestSlot";
local WRIST = "WristSlot";
local HANDS = "HandsSlot";
local WAIST = "WaistSlot";
local LEGS = "LegsSlot";
local FEET = "FeetSlot";
local SLOT0 = "0Slot"; -- for getting slot 0 ilevel --
local SLOT1 = "1Slot"; -- for getting slot 1 ilevel --
local FINGER = "Finger"; -- Just for the addon, for stocking an unique ring ilevel --
local FINGER0 = "Finger0Slot";
local FINGER1 = "Finger1Slot";
local TRINKET = "Trinket"; -- Just for the addon, for stocking an unique trinket ilevel --
local TRINKET0 = "Trinket0Slot";
local TRINKET1 = "Trinket1Slot";
local WEAPON = "Weapon"; -- Just for the addon, for stocking an unique weapon ilevel --
local MAINHAND = "MainHandSlot";
local SECONDARYHAND = "SecondaryHandSlot";

local TRANSFORM_ITEMSLOT_TO_SLOTNAME = {};
	
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_HEAD"] = HEAD;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_NECK"] = NECK;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_SHOULDER"] = SHOULDER;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_CHEST"] = CHEST;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_ROBE"] = CHEST;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_WAIST"] = WAIST;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_LEGS"] = LEGS;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_FEET"] = FEET;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_WRIST"] = WRIST;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_HAND"] = HANDS;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_FINGER"] = FINGER;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_TRINKET"] = TRINKET;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_CLOAK"] = BACK;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_WEAPON"] = WEAPON;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_SHIELD"] = WEAPON;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_2HWEAPON"] = WEAPON;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_WEAPONMAINHAND"] = WEAPON;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_WEAPONOFFHAND"] = WEAPON;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_HOLDABLE"] = WEAPON;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_RANGED"] = WEAPON;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_THROWN"] = WEAPON;
TRANSFORM_ITEMSLOT_TO_SLOTNAME["INVTYPE_RANGEDRIGHT"] = WEAPON;

--- Variable ---
local numberOfItemOnRand = 0;
local lastBossKillTime = time() - TIME_FOR_LOOTING;
local lassBossKilledName = "";
local raidLastBossLooted;
local transmitString;
local greaterVersion = VERSION;

local numberOfItemToAttrib = 0;
local lootList;

-- Loot frame variable --
local mainFrame;
local scrollcontainer;
local mainFrameScroll;
-- Attrib frame variable --
local attribFrame;
local scrollAttribContainer;
local attribFrameScroll;
-- Police frame variable --
local policeFrame;
local scrollPoliceContainer;
local policeFrameScroll;
local lootedBossContainer;
local lootedBossLabelList = {};
local shitListContainer;
local shitListPlayers = {};
local goodVersionCheckerContainer;
local badVersionCheckerContainer;
local noVersionCheckerContainer;
local playerVersionList = {};
local nbPlayerVersionInList = 0;

local function IsInRaidGuild()
	local inInstance, instanceType = IsInInstance();
	
	if (inInstance == true and instanceType == "raid") then
		local i;
		local name;
		local playerGuildName;
		local nbRaidMember = 0;
		local nbGuildRaidMember = 0;
		local myGuildName = GetGuildInfo("player");
		
		for i=1,MAX_RAID_MEMBERS do
			name = GetRaidRosterInfo(i);
			if (name ~= nil) then
				nbRaidMember = nbRaidMember + 1;
				playerGuildName = GetGuildInfo("raid" .. i);
				if (playerGuildName == myGuildName) then
					nbGuildRaidMember = nbGuildRaidMember + 1;
				end
			end
		end
		if ((nbGuildRaidMember / nbRaidMember * 100) > 75) then
			return true;
		end
	end
	return false;
end

local function AskForVersion()
	local name;
	local i;
	
	nbPlayerVersionInList = 0;
	playerVersionList = {};
	for i=1,MAX_RAID_MEMBERS do
		name = GetRaidRosterInfo(i);
		
		if (name ~= nil) then
			playerVersionList[i - 1] = {};
			playerVersionList[i - 1].version = 0;
			playerVersionList[i - 1].player = name;
			nbPlayerVersionInList = nbPlayerVersionInList + 1;
		end
	end
	Comm:SendCommMessage("BFA_ML_VERS", ASK_FOR_VERSION, "RAID");
end

local function AddonVersionChecker()
	local goodGuy = "";
	local lazyGuy = "";
	local badGuy = "";
	local i;

	if (goodVersionCheckerContainer == nil) then
		local versionChecker = AceGUI:Create("SimpleGroup");
		versionChecker:SetFullWidth(true);
		versionChecker:SetHeight(80);
		versionChecker:SetLayout("Flow");
		policeFrameScroll:AddChild(versionChecker);
		
		local checkButton = AceGUI:Create("Icon");		
		checkButton:SetImageSize(32, 32);
		checkButton:SetWidth(32);
		checkButton:SetImage("236372");
		checkButton:SetCallback("OnClick", function() AskForVersion() end);
		versionChecker:AddChild(checkButton);
		
		local descriptionLabel = AceGUI:Create("Label");
		descriptionLabel:SetText("Raid Player version of the addon :");
		descriptionLabel:SetWidth(500);
		versionChecker:AddChild(descriptionLabel);
		
		goodVersionCheckerContainer = AceGUI:Create("Label");
		goodVersionCheckerContainer:SetFullWidth(true);
		goodVersionCheckerContainer:SetColor(0, 125, 0);
		
		versionChecker:AddChild(goodVersionCheckerContainer);
		
		badVersionCheckerContainer = AceGUI:Create("Label");
		badVersionCheckerContainer:SetFullWidth(true);
		badVersionCheckerContainer:SetColor(200, 125, 0);
		
		versionChecker:AddChild(badVersionCheckerContainer);
		
		noVersionCheckerContainer = AceGUI:Create("Label");
		noVersionCheckerContainer:SetFullWidth(true);
		noVersionCheckerContainer:SetColor(100, 0, 0);
		
		versionChecker:AddChild(noVersionCheckerContainer);
	end
	for i=0,100 do
		if (playerVersionList[i] ~= nil) then
			if (playerVersionList[i].version == greaterVersion) then
				goodGuy = goodGuy .. playerVersionList[i].player .. "(" .. playerVersionList[i].version .. ")" .. "     ";
			elseif (playerVersionList[i].version > 0) then
				lazyGuy = lazyGuy .. playerVersionList[i].player .. "(" .. playerVersionList[i].version .. ")" .. "     ";
			else
				badGuy = badGuy .. playerVersionList[i].player .. "(No addon)" .. "    ";
			end
		end
	end
	
	goodVersionCheckerContainer:SetText(goodGuy);
	badVersionCheckerContainer:SetText(lazyGuy);
	noVersionCheckerContainer:SetText(badGuy);
end

local function UpdatePoliceShitList()
	local i;
	local txt = "";
	
	for i=0,100 do
		if (shitListPlayers[i] ~= nil) then
			txt = txt .. shitListPlayers[i] .. "/!\\     ";
		end
	end
	if (shitListContainer == nil) then
		local bigFuckingShit = AceGUI:Create("SimpleGroup");
		bigFuckingShit:SetFullWidth(true);
		bigFuckingShit:SetHeight(80);
		bigFuckingShit:SetLayout("Flow");
		policeFrameScroll:AddChild(bigFuckingShit);
		
		local checkButton = AceGUI:Create("Icon");		
		checkButton:SetImageSize(32, 32);
		checkButton:SetWidth(32);
		checkButton:SetImage("133035");
		checkButton:SetCallback("OnClick", function() shitListPlayers = {}; UpdatePoliceShitList(); end);
		bigFuckingShit:AddChild(checkButton);
		
		local descriptionLabel = AceGUI:Create("Label");
		descriptionLabel:SetText("This is the HoS of the shitters who loot without autoloot (or shift+click when autoloot enabled :");
		descriptionLabel:SetWidth(500);
		bigFuckingShit:AddChild(descriptionLabel);
	
		shitListContainer = AceGUI:Create("Label");
		shitListContainer:SetFullWidth(true);
		shitListContainer:SetText(txt);
		shitListContainer:SetColor(255, 0, 0);
		
		bigFuckingShit:AddChild(shitListContainer);
	else
		shitListContainer:SetText(txt);
	end
end

local function UpdatePoliceLootList()
	local i;
	
	if (raidLastBossLooted ~= nil) then
		if (lootedBossContainer == nil) then
			lootedBossContainer = AceGUI:Create("SimpleGroup");
			lootedBossContainer:SetFullWidth(true);
			lootedBossContainer:SetHeight(80);
			lootedBossContainer:SetLayout("Flow");
			policeFrameScroll:AddChild(lootedBossContainer);
			
			local descriptionLabel = AceGUI:Create("Label");
			descriptionLabel:SetText(lassBossKilledName .. " looting boss status : ");
			descriptionLabel:SetWidth(350);
			lootedBossContainer:AddChild(descriptionLabel);
			
			local legendLootedLabel = AceGUI:Create("Label");
			legendLootedLabel:SetText("Looted");
			legendLootedLabel:SetColor(0, 165, 0);
			legendLootedLabel:SetWidth(50);
			lootedBossContainer:AddChild(legendLootedLabel);
			
			local legendPendingLabel = AceGUI:Create("Label");
			legendPendingLabel:SetText("Pending");
			legendPendingLabel:SetColor(212, 145, 0);
			legendPendingLabel:SetWidth(50);
			lootedBossContainer:AddChild(legendPendingLabel);
			
			local legendNotLootedLabel = AceGUI:Create("Label");
			legendNotLootedLabel:SetText("Not looted");
			legendNotLootedLabel:SetColor(255, 0, 0);
			legendNotLootedLabel:SetWidth(60);
			lootedBossContainer:AddChild(legendNotLootedLabel);
			
		end
		
		for i=0,MAX_RAID_MEMBERS do
			if (raidLastBossLooted[i] ~= nil) then
				local playerLabel;
			
				if (lootedBossLabelList[i] == nil) then
					playerLabel = AceGUI:Create("Label");
					playerLabel:SetWidth(100);
					lootedBossContainer:AddChild(playerLabel);
					lootedBossLabelList[i] = playerLabel;
				end
				playerLabel = lootedBossLabelList[i];

				playerLabel:SetText(raidLastBossLooted[i].player)
				if (raidLastBossLooted[i].status == HAVE_LOOTED) then
					playerLabel:SetColor(0, 165, 0);
				elseif (raidLastBossLooted[i].status == PENDING_LOOT) then
					playerLabel:SetColor(212, 145, 0);
				elseif (raidLastBossLooted[i].status == DIDNT_LOOTED) then
					playerLabel:SetColor(255, 0, 0);
				end
			end
		end
	end
end

local function UpdatePoliceFrame()
	local margin;
	
	AddonVersionChecker();
	
	margin = AceGUI:Create("SimpleGroup");
	margin:SetFullWidth(true);
	margin:SetHeight(20);
	margin:SetLayout("Fill");
	policeFrameScroll:AddChild(margin);
	
	UpdatePoliceLootList();
	
	margin = AceGUI:Create("SimpleGroup");
	margin:SetFullWidth(true);
	margin:SetHeight(20);
	margin:SetLayout("Fill");
	policeFrameScroll:AddChild(margin);
	
	UpdatePoliceShitList();
end

Comm:RegisterComm("BFA_ML_VERS", function(prefix, message, distribution, sender)
	local i;
	
	if (message == ASK_FOR_VERSION) then
		versionInformation = {};
		
		transmitString = tostring(VERSION);
		Comm:SendCommMessage("BFA_ML_VERS", transmitString, "RAID");
	else
		local versionReceived = tonumber(message);
		
		if (versionReceived > greaterVersion) then
			greaterVersion = versionReceived;
		end
		
		local found = false;
		for i=0,nbPlayerVersionInList do
			if (playerVersionList[i] ~= nil and playerVersionList[i].player == sender) then
				playerVersionList[i].version = versionReceived;
				found = true;
				break;
			end
		end
		if (found == false) then
			for i=0,100 do
				if (playerVersionList[i] == nil) then
					playerVersionList[i] = {};
					playerVersionList[i].player = sender;
					playerVersionList[i].version = versionReceived;
					break;
				end
			end
		end
	end
	if (policeFrame.isOpen == true) then
		UpdatePoliceFrame();
	end
end);

-- Slash command --
SLASH_BFAMasterLooterPolice1 = "/police"
SlashCmdList["BFAMasterLooterPolice"] = function()
   policeFrame:Show();
   policeFrame.isOpen = true;
   UpdatePoliceFrame();
end 
SLASH_BFAMasterLooterAttrib1 = "/attrib"
SlashCmdList["BFAMasterLooterAttrib"] = function()
   attribFrame:Show();
   attribFrame.isOpen = true;
end
SLASH_BFAMasterLooterLoot1 = "/loot"
SlashCmdList["BFAMasterLooterLoot"] = function()
   mainFrame:Show();
   mainFrame.isOpen = true;
end 


-- Function to Manage ilevel thingy

local function MajIlevelWithBag()
	local ilvl;
	local itemSlot;
	
	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag,slot);
			
			if (itemLink ~= nil) then
				_, _, _, ilvl, _, _, _, _, itemSlot = GetItemInfo(itemLink);
				itemSlot = TRANSFORM_ITEMSLOT_TO_SLOTNAME[itemSlot];
				
				if (itemSlot ~= nil and BFA_MASTERLOOT_SLOT_ILVL[itemSlot] < ilvl) then
					BFA_MASTERLOOT_SLOT_ILVL[itemSlot] = ilvl
				end
			end
		end
	end
end

local function GetIlevelOfSlot(slotName)
	local ilvl = 0;
	local slotID = GetInventorySlotInfo(slotName)
	local itemLink = GetInventoryItemLink("player", slotID)
	
	if (itemLink ~= nil) then
		_, _, _, ilvl = GetItemInfo(itemLink);
	end
	
	return ilvl, itemLink;
end

local function GetIlevelOfMultiSlot(slotName)
	local ilvl0, ilvl1, itemLink, itemLink2;
	
	if (slotName == FINGER or slotName == TRINKET) then
		ilvl0, itemLink = GetIlevelOfSlot(slotName .. SLOT0);
		ilvl1, itemLink2 = GetIlevelOfSlot(slotName .. SLOT1);
	else -- else it's a weapon --
		ilvl0, itemLink = GetIlevelOfSlot(MAINHAND);
		ilvl1, itemLink2 = GetIlevelOfSlot(SECONDARYHAND);
	end
	
	if (ilvl0 > ilvl1) then
		return ilvl0, itemLink, itemLink2;
	else
		return ilvl1, itemLink, itemLink2;
	end
end

local function MajIlvlPerSlot(force)
	local headIlvl = GetIlevelOfSlot(HEAD);
	local neckIlvl = GetIlevelOfSlot(NECK);
	local shoulderIlvl = GetIlevelOfSlot(SHOULDER);
	local backIlvl = GetIlevelOfSlot(BACK);
	local chestIlvl = GetIlevelOfSlot(CHEST);
	local wristIlvl = GetIlevelOfSlot(WRIST);
	local handsIlvl = GetIlevelOfSlot(HANDS);
	local waistIlvl = GetIlevelOfSlot(WAIST);
	local legsIlvl = GetIlevelOfSlot(LEGS);
	local feetIlvl = GetIlevelOfSlot(FEET);
	local fingerIlvl = GetIlevelOfMultiSlot(FINGER);
	local trinketIlvl = GetIlevelOfMultiSlot(TRINKET);
	local weaponIlvl = GetIlevelOfMultiSlot(WEAPON);
	
	if (BFA_MASTERLOOT_SLOT_ILVL == nil) then
		BFA_MASTERLOOT_SLOT_ILVL = {};
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[HEAD] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[HEAD] < headIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[HEAD] = headIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[NECK] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[NECK] < neckIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[NECK] = neckIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[SHOULDER] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[SHOULDER] < shoulderIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[SHOULDER] = shoulderIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[BACK] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[BACK] < backIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[BACK] = backIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[CHEST] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[CHEST] < chestIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[CHEST] = chestIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[WRIST] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[WRIST] < wristIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[WRIST] = wristIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[HANDS] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[HANDS] < handsIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[HANDS] = handsIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[WAIST] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[WAIST] < waistIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[WAIST] = waistIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[LEGS] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[LEGS] < legsIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[LEGS] = legsIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[FEET] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[FEET] < feetIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[FEET] = feetIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[FINGER] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[FINGER] < fingerIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[FINGER] = fingerIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[TRINKET] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[TRINKET] < trinketIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[TRINKET] = trinketIlvl;
	end
	if (BFA_MASTERLOOT_SLOT_ILVL[WEAPON] == nil or force == true or BFA_MASTERLOOT_SLOT_ILVL[WEAPON] < weaponIlvl) then
		BFA_MASTERLOOT_SLOT_ILVL[WEAPON] = weaponIlvl;
	end
end

-- blabla --

local function IsRaidLeaderOrAssist()
	local playerName = UnitName("player");
	local i;
	
	for i=0,MAX_RAID_MEMBERS do
		local name, rank = GetRaidRosterInfo(i);
		if (name == playerName) then
			return rank;
		end
	end
end

local function InitLootFrame()
	mainFrame = AceGUI:Create("Frame");
	mainFrame:SetLayout("Flow");
	mainFrame:SetWidth(600);
	mainFrame:SetHeight(400);
	mainFrame:SetPoint("TOP", nil, "TOP", 0, -50);
	mainFrame:SetTitle("LOOT");
	mainFrame:Hide();

	scrollcontainer = AceGUI:Create("SimpleGroup");
	scrollcontainer:SetFullWidth(true);
	scrollcontainer:SetFullHeight(true);
	scrollcontainer:SetLayout("Fill");
	mainFrame:AddChild(scrollcontainer);

	mainFrameScroll = AceGUI:Create("ScrollFrame");
	mainFrameScroll:SetLayout("Flow");
	scrollcontainer:AddChild(mainFrameScroll);
end

local function InitAttribFrame()
	attribFrame = AceGUI:Create("Frame");
	attribFrame:SetLayout("Flow");
	attribFrame:SetWidth(600);
	attribFrame:SetHeight(400);
	attribFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 0, -50);
	attribFrame:SetTitle("ATTRIB");
	attribFrame:Hide();

	scrollAttribContainer = AceGUI:Create("SimpleGroup");
	scrollAttribContainer:SetFullWidth(true);
	scrollAttribContainer:SetFullHeight(true);
	scrollAttribContainer:SetLayout("Fill");
	attribFrame:AddChild(scrollAttribContainer);

	attribFrameScroll = AceGUI:Create("ScrollFrame");
	attribFrameScroll:SetLayout("Flow");
	scrollAttribContainer:AddChild(attribFrameScroll);
end

local function InitPoliceFrame()
	policeFrame = AceGUI:Create("Frame");
	policeFrame:SetLayout("Flow");
	policeFrame:SetWidth(600);
	policeFrame:SetHeight(400);
	policeFrame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, 50);
	policeFrame:SetTitle("QUICHONS POULISHE");
	policeFrame:SetCallback("OnClose", function() policeFrame.isOpen = false; end)
	policeFrame.isOpen = false;
	policeFrame:Hide();

	scrollPoliceContainer = AceGUI:Create("SimpleGroup");
	scrollPoliceContainer:SetFullWidth(true);
	scrollPoliceContainer:SetFullHeight(true);
	scrollPoliceContainer:SetLayout("Fill");
	policeFrame:AddChild(scrollPoliceContainer);

	policeFrameScroll = AceGUI:Create("ScrollFrame");
	policeFrameScroll:SetLayout("Flow");
	scrollPoliceContainer:AddChild(policeFrameScroll);
end

local function RemoveItemAttrib(container)
	if (container.released == false) then
		container:Release();
		numberOfItemToAttrib = numberOfItemToAttrib - 1;
		if (numberOfItemToAttrib <= 0) then
			attribFrame:Hide();
			numberOfItemToAttrib = 0;
		end
		container.released = true;
	end
end

local function RemoveItemLine(container)
	if (container.released == false) then
		container:Release();
		numberOfItemOnRand = numberOfItemOnRand - 1;
		if (numberOfItemOnRand <= 0) then
			mainFrame:Hide();
			numberOfItemOnRand = 0;
		end
		container.released = true;
	end
end

local function ButtonHandler(container, label, itemReceived, commentBox)
	if (label ~= "PASS") then
		local ilvl, itemLink;
	
		itemReceived[BFAMasterLooter.FII_RAND] = random(100);
		itemReceived[BFAMasterLooter.FII_CHOICE] = label;
		itemReceived[BFAMasterLooter.FII_PLAYER_NEEDING] = UnitName("player");
		itemReceived[BFAMasterLooter.FII_COMMENT] = commentBox:GetText();
		
		
		local itemSlot = itemReceived[BFAMasterLooter.FII_ITEM_EQUIP_LOC];
		itemSlot = TRANSFORM_ITEMSLOT_TO_SLOTNAME[itemSlot];
		
		itemReceived[BFAMasterLooter.FII_MAX_ILVL] = BFA_MASTERLOOT_SLOT_ILVL[itemSlot]
		if (itemSlot == FINGER or itemSlot == TRINKET or itemSlot == WEAPON) then
			ilvl, itemLink, itemLink2 = GetIlevelOfMultiSlot(itemSlot);

			itemReceived[BFAMasterLooter.FII_EQUIPED_ILVL] = ilvl;
			itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK] = itemLink;
			itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK2] = itemLink2;
		else
			ilvl, itemLink = GetIlevelOfSlot(itemSlot);

			itemReceived[BFAMasterLooter.FII_EQUIPED_ILVL] = ilvl;
			itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK] = itemLink;
		end
		
		transmitString = BFAMasterLooter.TableToString(itemReceived);	
		Comm:SendCommMessage("BFA_ML_ATTRIB", transmitString, "RAID");
	end
	RemoveItemLine(container);
end

local function AddNeedButtonToContainer(container, itemReceived)
	container.released = false;
	
	local commentBox = AceGUI:Create("EditBox");
	commentBox:SetWidth(150);
	commentBox:DisableButton(true);
	container:AddChild(commentBox);
	
	local bisButton = AceGUI:Create("Button");
	bisButton:SetText("BiS");
	bisButton:SetWidth(50);
	bisButton:SetCallback("OnClick", function() ButtonHandler(container, "BIS", itemReceived, commentBox) end);
	container:AddChild(bisButton);
	
	local urButton = AceGUI:Create("Button");
	urButton:SetText("UR");
	urButton:SetWidth(50);
	urButton:SetCallback("OnClick", function() ButtonHandler(container, "UR", itemReceived, commentBox) end);
	container:AddChild(urButton);
	
	local iLevelForTradeButton = AceGUI:Create("Button");
	iLevelForTradeButton:SetText("ILVL");
	iLevelForTradeButton:SetWidth(60);
	iLevelForTradeButton:SetCallback("OnClick", function() ButtonHandler(container, "ILEVEL4TRADE", itemReceived, commentBox) end);
	container:AddChild(iLevelForTradeButton);
	
	local urBisButton = AceGUI:Create("Button");
	urBisButton:SetText("Spé2");
	urBisButton:SetWidth(75);
	urBisButton:SetCallback("OnClick", function() ButtonHandler(container, "Spé2", itemReceived, commentBox) end);
	container:AddChild(urBisButton);
	
	local passButton = AceGUI:Create("Button");
	passButton:SetText("PASS");
	passButton:SetWidth(70);
	passButton:SetCallback("OnClick", function() ButtonHandler(container, "PASS", itemReceived) end);
	container:AddChild(passButton);
	
	local timer = AceGUI:Create("EditBox");
	timer:SetText(tostring(TIME_FOR_RAND));
	timer:SetDisabled(true);
	timer:SetWidth(50);
	container:AddChild(timer);
	
	C_Timer.NewTicker(1, function() 
		local actualTimer = timer:GetText();
		
		actualTimer = tonumber(actualTimer) - 1;
		timer:SetText(tostring(actualTimer));
		if (actualTimer <= 0) then
			RemoveItemLine(container);
		end
	end, TIME_FOR_RAND);
	
	return container;
end

local function ShowItemOnFrame(item, container)
	local itemIcon = AceGUI:Create("Icon");
	
	if (item[BFAMasterLooter.FII_TEXTURE]) then
		itemIcon:SetImage(item[BFAMasterLooter.FII_TEXTURE]);
	end
	
	itemIcon:SetImageSize(32,32);
	itemIcon:SetWidth(32);
	itemIcon:SetCallback("OnEnter", function(widget)
		GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT");
		GameTooltip:SetHyperlink(item[BFAMasterLooter.FII_LINK]);
		GameTooltip:Show();
		end)			
	itemIcon:SetCallback("OnLeave", function(widget)
		GameTooltip:Hide();
		end)
	container:AddChild(itemIcon);
end




local addonLoadedFrame;
local coreFrame;

local function coreFunctionality(self, event, ...)
	if (IsInRaidGuild() == true) then
		local arg1, arg2, _, _, arg5 = ...
		
		if (event == 'LOOT_OPENED') then
			local lootInformation = {};
			
			lootInformation.player = UnitName("player");
			if (arg1 ~= 1) then
				lootInformation.status = BIG_SHIT_LOOT;
			else
				if (time() > lastBossKillTime + TIME_FOR_LOOTING) then
					return;
				end
				lootInformation.status = HAVE_LOOTED;
			end
			transmitString = BFAMasterLooter.TableToString(lootInformation);
			Comm:SendCommMessage("BFA_ML_POLICE", transmitString, "RAID");
		elseif (event == 'CHAT_MSG_LOOT' and (time() <= lastBossKillTime + TIME_FOR_LOOTING)) then
		C_Timer.After(1, function()
			local LOOT_ITEM_SELF_PATTERN = _G.LOOT_ITEM_SELF;
			LOOT_ITEM_SELF_PATTERN = LOOT_ITEM_SELF_PATTERN:gsub('%%s', '(.+)');
			local lootedItem = arg1:match(LOOT_ITEM_SELF_PATTERN);
		
			if (lootedItem) then
				local fullItemInfo = BFAMasterLooter.GetFullItemInfo(lootedItem);
				
				if (fullItemInfo[BFAMasterLooter.FII_QUALITY] >= 4 and
						(fullItemInfo[BFAMasterLooter.FII_IS_EQUIPPABLE] == true
							or fullItemInfo[BFAMasterLooter.FII_IS_RELIC] == true)
						and fullItemInfo[BFAMasterLooter.FII_TRADABLE] == true) then
		
					transmitString = BFAMasterLooter.TableToString(fullItemInfo);		
					Comm:SendCommMessage("BFA_ML_LOOT", transmitString, "RAID");
				end
			end
		end)
		elseif event == 'UNIT_INVENTORY_CHANGED' then
			local maxIlvl = GetAverageItemLevel();
		
			if (maxIlvl > BFA_MASTERLOOT_MAX_ILVL) then
				BFA_MASTERLOOT_MAX_ILVL = maxIlvl;
			end
			MajIlvlPerSlot(false);
			MajIlevelWithBag();
		elseif event == 'BOSS_KILL' then
			local raidPlayerName;
			local i;
			
			lassBossKilledName = arg2;
			lastBossKillTime = time();
			print("\124cFFFF0000Quichons ML -\124r Boss " .. lassBossKilledName .. " have been killed, you have " .. TIME_FOR_LOOTING .. "sec to loot the boss, else...");
			numberOfItemToAttrib = 0; -- On Purge les items en attrib ou cas ou cas ou --
			numberOfItemOnRand = 0;
			lootList = {};
			InitAttribFrame();
			InitLootFrame();
			
			raidLastBossLooted = {}; -- On créer la liste de toute les personnes présente lors du kill --
			for i=0,MAX_RAID_MEMBERS do
				raidPlayerName = GetRaidRosterInfo(i);
				if (raidPlayerName ~= nil) then
					raidLastBossLooted[i] = {};
					raidLastBossLooted[i].status = PENDING_LOOT;
					raidLastBossLooted[i].player = raidPlayerName;
				end
			end
			
			UpdatePoliceFrame();
			if (IsRaidLeaderOrAssist() == RAID_LEADER or UnitName("player") == "Nâmo") then
				policeFrame:Show();
				policeFrame.isOpen = true;
			end
			
			C_Timer.After(TIME_FOR_LOOTING + TIME_BUFFER, function()
				local i;
				
				for i=0,MAX_RAID_MEMBERS do
					if (raidLastBossLooted[i] ~= nil and raidLastBossLooted[i].status == PENDING_LOOT) then
						raidLastBossLooted[i].status = DIDNT_LOOTED;
					end
				end
				UpdatePoliceFrame();
			end);
		end
	end
end

local function AttribLoot(looter, playerWhoWon, itemLink, container)
	SendChatMessage("Envoie le loot " .. itemLink .. " à " .. playerWhoWon .. "!", "WHISPER", "ORCISH", looter);
	RemoveItemAttrib(container);
end

local function AddPlayerLine(container, needList, looter, itemLink)
	local playerClass;
	local color;
	local i;
	
	for i=0, MAX_RAID_MEMBERS do
		if (needList[i] ~= nil) then
			local needInformation = needList[i];
			
			local playerLabel = AceGUI:Create("Label");
			playerLabel:SetText(needInformation.player);
			_, playerClass = UnitClass(needInformation.player);
			color = RAID_CLASS_COLORS[playerClass];
			
			if (color ~= nil) then
				playerLabel:SetColor(color.r, color.g, color.b);
			end
			playerLabel:SetWidth(90);
			playerLabel:SetFont("Fonts\\ARIALN.ttf", 15, "OUTLINE, MONOCHROME")
			container:AddChild(playerLabel);
			
			if (IsRaidLeaderOrAssist() == RAID_LEADER) then
				local attribButton = AceGUI:Create("Icon");
				
				attribButton:SetImageSize(32, 32);
				attribButton:SetWidth(32);
				attribButton:SetImage("1418621");
				attribButton:SetCallback("OnClick", function() AttribLoot(looter, needInformation.player, itemLink, container) end);
				container:AddChild(attribButton);
			end
			
			local fullItemInfo = BFAMasterLooter.GetFullItemInfo(needInformation.itemLink);
			ShowItemOnFrame(fullItemInfo, container);

			if (needInformation.itemLink2 ~= nil) then
			   local fullItemInfo2 = BFAMasterLooter.GetFullItemInfo(needInformation.itemLink2);
			   ShowItemOnFrame(fullItemInfo, container);
			end
			
			local label = AceGUI:Create("Label");
			local text = needInformation.equippedIlvl .. "(actual) - " .. needInformation.maxIlvl .. "(max) - " .. needInformation.rand .. "(rand) - " .. needInformation.note;
			
			label:SetText(text);
			label:SetWidth(350);
			label:SetFont("Fonts\\ARIALN.ttf", 15);
			container:AddChild(label);
		end
	end
	local heading = AceGUI:Create("Heading");
	heading:SetText("lul");
	container:AddChild(heading);
end

local function AddNeedLabel(container, text, red, green, blue)
	local bisLabel = AceGUI:Create("Label");
	bisLabel:SetWidth(500);
	bisLabel:SetText(text);
	bisLabel:SetColor(red, green, blue);
	bisLabel:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE, MONOCHROME")
	container:AddChild(bisLabel);
end

local function AddItemToAttribFrame(itemId)
	local loot = lootList[itemId];
	local looter = loot.looter;
	
	if (loot.bis ~= nil or loot.ur ~= nil or loot.ilevel ~= nil or loot.spec2 ~= nil) then
		local container = AceGUI:Create("SimpleGroup");
		container.released = false;
		container:SetFullWidth(true);
		container:SetHeight(80);
		container:SetLayout("Flow");
		attribFrameScroll:AddChild(container);

		ShowItemOnFrame(loot.item, container);
		
		if (loot.bis ~= nil) then
			AddNeedLabel(container, "BIS :", 0, 255, 0);
			AddPlayerLine(container, loot.bis, looter, loot.item[BFAMasterLooter.FII_LINK]);
		end
		if (loot.ur ~= nil) then
			AddNeedLabel(container, "UR :", 200, 150, 0);
			AddPlayerLine(container, loot.ur, looter, loot.item[BFAMasterLooter.FII_LINK]);
		end
		if (loot.ilevel ~= nil) then
			AddNeedLabel(container, "ILEVEL 4 TRADE :", 80, 0, 0);
			AddPlayerLine(container, loot.ilevel, looter, loot.item[BFAMasterLooter.FII_LINK]);
		end
		if (loot.spec2 ~= nil) then
			AddNeedLabel(container, "SPEC2 :", 80, 0, 0);
			AddPlayerLine(container, loot.spec2, looter, loot.item[BFAMasterLooter.FII_LINK])
		end
		
		local heading = AceGUI:Create("Heading");
		container:AddChild(heading);
		
		attribFrame:Show();
	end
end

Comm:RegisterComm("BFA_ML_POLICE", function(prefix, message, distribution, sender)
	local lootInformation = BFAMasterLooter.StringToTable(message);
	local i;
	
	if (lootInformation ~= nil) then
		if (lootInformation.status == BIG_SHIT_LOOT) then
			for i=0,100 do
				if (shitListPlayers[i] == nil) then
					shitListPlayers[i] = lootInformation.player;
					UpdatePoliceFrame();
					if (IsRaidLeaderOrAssist() ~= RAID_PLEBS or UnitName("player") == "Nâmo") then
						print("QUICHONS POULISH : " .. lootInformation.player .. " find funny to not use autoloot, Police Frame Updated");
					end
					break;
				end
			end
		else
			local raidPlayerName;
			
			for i=0,MAX_RAID_MEMBERS do
				if (raidLastBossLooted ~= nil and raidLastBossLooted[i - 0] ~= nil) then
					raidPlayerName = raidLastBossLooted[i].player;
					if (raidPlayerName ~= nil and raidPlayerName == lootInformation.player) then
						raidLastBossLooted[i].status = lootInformation.status;
						UpdatePoliceFrame();
						break;
					end
				end
			end
		end
	end
end);

Comm:RegisterComm("BFA_ML_LOOT", function(prefix, message, distribution, sender)
    local itemReceived = BFAMasterLooter.StringToTable(message);
	
	if (BFAMasterLooter.IsEquippableItemForCharacter(itemReceived)) then
		local container = AceGUI:Create("SimpleGroup");
		container:SetFullWidth(true);
		container:SetHeight(80);
		container:SetLayout("Flow");
		mainFrameScroll:AddChild(container);
	   
		ShowItemOnFrame(itemReceived, container);
		AddNeedButtonToContainer(container, itemReceived);
		numberOfItemOnRand = numberOfItemOnRand + 1;
		mainFrame:Show();
	end
	if (IsRaidLeaderOrAssist() ~= RAID_PLEBS or UnitName("player") == "Nâmo") then
		local id = numberOfItemToAttrib;
		
		numberOfItemToAttrib = numberOfItemToAttrib + 1;

		lootList[id] = {};
		lootList[id].looter = itemReceived[BFAMasterLooter.FII_LOOTER];
		lootList[id].item = itemReceived;
		
		C_Timer.After(TIME_FOR_RAND + TIME_BUFFER, function()
			AddItemToAttribFrame(id);
		end);
	end
end);

Comm:RegisterComm("BFA_ML_ATTRIB", function(prefix, message, distribution, sender)
	if (IsRaidLeaderOrAssist() ~= RAID_PLEBS or UnitName("player") == "Nâmo") then
		local itemReceived = BFAMasterLooter.StringToTable(message);
		local itemLooter = itemReceived[BFAMasterLooter.FII_LOOTER];
		local loot;
		local i;
		local j;
		
		for i=0,MAX_RAID_MEMBERS do
			loot =  lootList[i];
			if (loot ~= nil and itemLooter == lootList[i].looter) then
				if (itemReceived[BFAMasterLooter.FII_CHOICE] == "BIS") then
					if (loot.bis == nil) then
						loot.bis = {};
					end
					for j=0,MAX_RAID_MEMBERS do
						if (loot.bis[j] == nil) then
							loot.bis[j] = {};
							loot.bis[j].player = itemReceived[BFAMasterLooter.FII_PLAYER_NEEDING];
							loot.bis[j].equippedIlvl = itemReceived[BFAMasterLooter.FII_EQUIPED_ILVL];
							loot.bis[j].itemLink = itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK];
							loot.bis[j].itemLink2 = itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK2];
							loot.bis[j].maxIlvl = itemReceived[BFAMasterLooter.FII_MAX_ILVL];
							loot.bis[j].rand = itemReceived[BFAMasterLooter.FII_RAND];
							loot.bis[j].note = itemReceived[BFAMasterLooter.FII_COMMENT];
							break;
						end
					end
				elseif (itemReceived[BFAMasterLooter.FII_CHOICE] == "UR") then
					if (loot.ur == nil) then
						loot.ur = {};
					end
					for j=0,MAX_RAID_MEMBERS do
						if (loot.ur[j] == nil) then
							loot.ur[j] = {};
							loot.ur[j].player = itemReceived[BFAMasterLooter.FII_PLAYER_NEEDING];
							loot.ur[j].equippedIlvl = itemReceived[BFAMasterLooter.FII_EQUIPED_ILVL];
							loot.ur[j].itemLink = itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK];
							loot.ur[j].itemLink2 = itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK2];
							loot.ur[j].maxIlvl = itemReceived[BFAMasterLooter.FII_MAX_ILVL];
							loot.ur[j].rand = itemReceived[BFAMasterLooter.FII_RAND];
							loot.ur[j].note = itemReceived[BFAMasterLooter.FII_COMMENT];
							break;
						end
					end
				elseif (itemReceived[BFAMasterLooter.FII_CHOICE] == "ILEVEL4TRADE") then
					if (loot.ilevel == nil) then
						loot.ilevel = {};
					end
					for j=0,MAX_RAID_MEMBERS do
						if (loot.ilevel[j] == nil) then
							loot.ilevel[j] = {};
							loot.ilevel[j].player = itemReceived[BFAMasterLooter.FII_PLAYER_NEEDING];
							loot.ilevel[j].equippedIlvl = itemReceived[BFAMasterLooter.FII_EQUIPED_ILVL];
							loot.ilevel[j].itemLink = itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK];
							loot.ilevel[j].itemLink2 = itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK2];
							loot.ilevel[j].maxIlvl = itemReceived[BFAMasterLooter.FII_MAX_ILVL];
							loot.ilevel[j].rand = itemReceived[BFAMasterLooter.FII_RAND];
							loot.ilevel[j].note = itemReceived[BFAMasterLooter.FII_COMMENT];
							break;
						end
					end
				elseif (itemReceived[BFAMasterLooter.FII_CHOICE] == "Spé2") then
					if (loot.spec2 == nil) then
						loot.spec2 = {};
					end
					for j=0,MAX_RAID_MEMBERS do
						if (loot.spec2[j] == nil) then
							loot.spec2[j] = {};
							loot.spec2[j].player = itemReceived[BFAMasterLooter.FII_PLAYER_NEEDING];
							loot.spec2[j].equippedIlvl = itemReceived[BFAMasterLooter.FII_EQUIPED_ILVL];
							loot.spec2[j].itemLink = itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK];
							loot.spec2[j].itemLink2 = itemReceived[BFAMasterLooter.FII_EQUIPED_ITEM_LINK2];
							loot.spec2[j].maxIlvl = itemReceived[BFAMasterLooter.FII_MAX_ILVL];
							loot.spec2[j].rand = itemReceived[BFAMasterLooter.FII_RAND];
							loot.spec2[j].note = itemReceived[BFAMasterLooter.FII_COMMENT];
							break;
						end
					end
				end
			end
		end
	end
end);

-- Function for initializing purpose
local function Initialize(self, event, addonName, ...)
	if (addonName == 'Quichons') then
	
		InitLootFrame();
		InitAttribFrame();
		InitPoliceFrame();
		coreFrame = CreateFrame("Frame");
		
		coreFrame:SetScript('OnEvent', coreFunctionality);
		
		coreFrame:RegisterEvent("LOOT_OPENED"); -- To know if the person has loot --
		coreFrame:RegisterEvent("CHAT_MSG_LOOT"); -- for catching new loot --
		coreFrame:RegisterEvent("UNIT_INVENTORY_CHANGED"); -- for updating ilevel information --
		coreFrame:RegisterEvent("BOSS_KILL"); -- for lastBossKillTime timestamp --
		
		local maxIlvl, _ = GetAverageItemLevel();
		
		if (BFA_MASTERLOOT_MAX_ILVL == nil or (maxIlvl < 900 and BFA_MASTERLOOT_MAX_ILVL > 900)) then
			BFA_MASTERLOOT_MAX_ILVL = maxIlvl;
			MajIlvlPerSlot(true);
		elseif (maxIlvl > BFA_MASTERLOOT_MAX_ILVL) then
			BFA_MASTERLOOT_MAX_ILVL = maxIlvl;
			MajIlvlPerSlot(false);
		end
		MajIlevelWithBag();
	end
end

addonLoadedFrame = CreateFrame('Frame');
addonLoadedFrame:SetScript('OnEvent', Initialize);
addonLoadedFrame:RegisterEvent('ADDON_LOADED');

