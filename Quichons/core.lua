local _, BFAMasterLooter = ...

BFAMasterLooter = LibStub("AceAddon-3.0"):NewAddon(BFAMasterLooter, "BFAMasterLooter", "AceConsole-3.0", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0");
local Comm = LibStub:GetLibrary("AceComm-3.0");

--- CONSTANTS --
local VERSION = 1.1;

local TIME_FOR_LOOTING = 180;
local TIME_FOR_RAND = 90;
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

local totalItemLooted = 0;
local lastItemLooterTimerEnded = 0;

local numberOfItemToAttrib = 0;
local lootList = {};

-- Loot frame variable --
local mainFrame;
local scrollcontainer;
local mainFrameScroll;
-- Police frame variable --
local bossLooterLabel;
local policeFrame;
local scrollPoliceContainer;
local policeFrameScroll;
local lootedBossContainer;
local policeMargin1;
local policeMargin2;
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
	for i=0,MAX_RAID_MEMBERS do
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
			
			bossLooterLabel = AceGUI:Create("Label");
			bossLooterLabel:SetWidth(350);
			lootedBossContainer:AddChild(bossLooterLabel);
			
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
		
		bossLooterLabel:SetText(lassBossKilledName .. " looting boss status : ");
		
		
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
	AddonVersionChecker();
	
	if (policeMargin1 == nil) then
		policeMargin1 = AceGUI:Create("SimpleGroup");
		policeMargin1:SetFullWidth(true);
		policeMargin1:SetHeight(20);
		policeMargin1:SetLayout("Fill");
		policeFrameScroll:AddChild(policeMargin1);
	end
	
	UpdatePoliceLootList();
	
	if (policeMargin2 == nil) then
		policeMargin2 = AceGUI:Create("SimpleGroup");
		policeMargin2:SetFullWidth(true);
		policeMargin2:SetHeight(20);
		policeMargin2:SetLayout("Fill");
		policeFrameScroll:AddChild(policeMargin2);
	end
	
	UpdatePoliceShitList();
end

Comm:RegisterComm("BFA_ML_VERS", function(prefix, message, distribution, sender)
	local i;
	
	if (message == ASK_FOR_VERSION) then
		transmitString = tostring(VERSION);
		Comm:SendCommMessage("BFA_ML_VERS", transmitString, "RAID");
	else
		local versionReceived = tonumber(message);
		
		if (versionReceived ~= nil and (greaterVersion == nil or versionReceived > greaterVersion)) then
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
			for i=0,MAX_RAID_MEMBERS do
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
		AddonVersionChecker();
	end
end);

-- Slash command --
SLASH_BFAMasterLooterPolice1 = "/police"
SlashCmdList["BFAMasterLooterPolice"] = function()
   policeFrame:Show();
   policeFrame.isOpen = true;
   UpdatePoliceFrame();
end 
--[[
SLASH_BFAMasterLooterAttrib1 = "/attrib"
SlashCmdList["BFAMasterLooterAttrib"] = function()
   attribFrame:Show();
   attribFrame.isOpen = true;
end
--]]
SLASH_BFAMasterLooterLoot1 = "/loot"
SlashCmdList["BFAMasterLooterLoot"] = function()
   mainFrame:Show();
   mainFrame.isOpen = true;
end 


-- Function to Manage ilevel thingy

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
	mainFrame:SetWidth(200);
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

local addonLoadedFrame;
local coreFrame;

local function coreFunctionality(self, event, ...)
	if (IsInRaidGuild() == true) then
		local arg1, arg2, _, _, arg5 = ...
		
		if (event == 'LOOT_OPENED') then
			local lootInformation = {};
			
			lootInformation.player = UnitName("player");
			if (arg1 ~= true) then
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
		elseif event == 'BOSS_KILL' then
			local raidPlayerName;
			local i;
			
			lassBossKilledName = arg2;
			lastBossKillTime = time();
			totalItemLooted = 0;
			lastItemLooterTimerEnded = 0;
			print("\124cFFFF0000Quichons ML -\124r Boss " .. lassBossKilledName .. " have been killed, you have " .. TIME_FOR_LOOTING .. "sec to loot the boss, else...");
			numberOfItemToAttrib = 0; -- On Purge les items en attrib ou cas ou cas ou --
			numberOfItemOnRand = 0;
			lootList = {};
			mainFrame:Release();
			InitLootFrame();
			AskForVersion();
			AddonVersionChecker();
			
			raidLastBossLooted = {}; -- On créer la liste de toute les personnes présente lors du kill --
			for i=0,MAX_RAID_MEMBERS do
				raidPlayerName = GetRaidRosterInfo(i);
				if (raidPlayerName ~= nil) then
					raidLastBossLooted[i] = {};
					raidLastBossLooted[i].status = PENDING_LOOT;
					raidLastBossLooted[i].player = raidPlayerName;
				end
				
				if (lootedBossLabelList[i] ~= nil) then
					lootedBossLabelList[i]:SetText("");
				end
			end
			
			UpdatePoliceLootList();
			if (IsRaidLeaderOrAssist() == RAID_LEADER) then
				policeFrame:Show();
				policeFrame.isOpen = true;
			end
			
			if (IsRaidLeaderOrAssist() ~= RAID_PLEBS) then
				C_Timer.After(TIME_FOR_LOOTING + TIME_BUFFER, function()
					local i;
					
					for i=0,MAX_RAID_MEMBERS do
						if (raidLastBossLooted[i] ~= nil and raidLastBossLooted[i].status == PENDING_LOOT) then
							raidLastBossLooted[i].status = DIDNT_LOOTED;
						end
					end
					UpdatePoliceLootList();
				end);
			end
		end
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
					UpdatePoliceShitList();
					if (IsRaidLeaderOrAssist() ~= RAID_PLEBS) then
						print("QUICHONS POULISH : " .. lootInformation.player .. " find funny to not use autoloot, Police Frame Updated");
					end
					break;
				end
			end
		else
			local raidPlayerName;
			
			for i=0,MAX_RAID_MEMBERS do
				if (raidLastBossLooted ~= nil and raidLastBossLooted[i] ~= nil) then
					raidPlayerName = raidLastBossLooted[i].player;
					if (raidPlayerName ~= nil and raidPlayerName == lootInformation.player) then
						raidLastBossLooted[i].status = lootInformation.status;
						UpdatePoliceLootList();
						break;
					end
				end
			end
		end
	end
end);

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
	itemIcon:SetCallback("OnClick", function()
		SendChatMessage(item[BFAMasterLooter.FII_LINK] ,"RAID");
		end)
	container:AddChild(itemIcon);
end

Comm:RegisterComm("BFA_ML_LOOT", function(prefix, message, distribution, sender)
    local itemReceived = BFAMasterLooter.StringToTable(message);
	
	local container = AceGUI:Create("SimpleGroup");
	container:SetFullWidth(true);
	container:SetHeight(80);
	container:SetLayout("Flow");
	mainFrameScroll:AddChild(container);
   
	ShowItemOnFrame(itemReceived, container);
	
	local playerLabel = AceGUI:Create("Label");
	playerLabel:SetText(itemReceived[BFAMasterLooter.FII_LOOTER]);
	_, playerClass = UnitClass(itemReceived[BFAMasterLooter.FII_LOOTER]);
	color = RAID_CLASS_COLORS[playerClass];
	
	if (color ~= nil) then
		playerLabel:SetColor(color.r, color.g, color.b);
	end
	playerLabel:SetWidth(110);
	playerLabel:SetFont("Fonts\\ARIALN.ttf", 15, "OUTLINE, MONOCHROME")
	container:AddChild(playerLabel);
	
	mainFrame:Show();
end);



local function Debug(secondCall)
	local search = "Azerothian";
	
	if (secondCall) then
		search = "Ascension";
	end
	
	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			local item = GetContainerItemLink(bag,slot)
			if item and item:find(search) then
				
				local fullItemInfo = BFAMasterLooter.GetFullItemInfo(item);
				
				if (secondCall) then
					fullItemInfo[BFAMasterLooter.FII_LOOTER] = "AnotherPlayerNameNotNamo";
				end

				transmitString = BFAMasterLooter.TableToString(fullItemInfo);		
				Comm:SendCommMessage("BFA_ML_LOOT", transmitString, "RAID");

			end
		end
	end
	
	if (secondCall ~= true) then
		C_Timer.After(10, function()
				Debug(true);
			end);
	else
		C_Timer.After(10, function()
				mainFrame:Release();
				InitLootFrame();
				Debug();
			end);
	end
end

-- Function for initializing purpose
local function Initialize(self, event, addonName, ...)
	if (addonName == 'Quichons') then
	
		InitLootFrame();
		InitPoliceFrame();
		coreFrame = CreateFrame("Frame");
		
		coreFrame:SetScript('OnEvent', coreFunctionality);
		
		coreFrame:RegisterEvent("LOOT_OPENED"); -- To know if the person has loot --
		coreFrame:RegisterEvent("CHAT_MSG_LOOT"); -- for catching new loot --
		coreFrame:RegisterEvent("BOSS_KILL"); -- for lastBossKillTime timestamp --

		
		--C_Timer.After(5, function()Debug();end);
	end
end

addonLoadedFrame = CreateFrame('Frame');
addonLoadedFrame:SetScript('OnEvent', Initialize);
addonLoadedFrame:RegisterEvent('ADDON_LOADED');

