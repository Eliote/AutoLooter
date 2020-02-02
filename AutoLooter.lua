--[[
	Description: Loot only what you want and keep your precious bag slots free of trash.
	Author: Eliote
--]]

local ADDON_NAME, PRIVATE_TABLE = ...
local MOD_VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

---@class AutoLooter
local AUTO_LOOTER = LibStub("AceAddon-3.0"):NewAddon("AutoLooter", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local DataBase = PRIVATE_TABLE.DB

---@type Util
local Util = PRIVATE_TABLE.Util
local Color = PRIVATE_TABLE.Color

-- global calls runs 30% slower -- http://www.lua.org/gems/sample.pdf
local GetNumLootItems = GetNumLootItems
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local LootSlot = LootSlot
local ConfirmLootSlot = ConfirmLootSlot
--

local chatCache = {}
local function findChatFrame(name)
	if (name == -1) then return DEFAULT_CHAT_FRAME end

	local chat = chatCache[name]
	if chat then return chat end

	local found
	for i = 1, NUM_CHAT_WINDOWS do
		local chatName = GetChatWindowInfo(i)
		if chatName then
			local chatFrame = getglobal("ChatFrame" .. i)
			chatCache[chatName] = chatFrame

			if chatName == name then
				found = chatFrame
			end
		end
	end

	return found
end

local function filterChatFrame(namesMap)
	local frames = {}
	for k, selected in pairs(namesMap) do
		if selected then
			local frame = findChatFrame(k)
			if frame then
				table.insert(frames, frame)
			end
		end
	end
	return frames
end

function AUTO_LOOTER.print(...)
	local chatFrames = filterChatFrame(AUTO_LOOTER.db.char.chatFrameNames)
	if #chatFrames == 0 then return end

	local out = ""

	for i = 1, select("#", ...) do
		local s = tostring(select(i, ...))

		out = out .. s
	end

	for i, chatFrame in ipairs(chatFrames) do
		chatFrame:AddMessage(Color.WHITE .. "<" .. Color.BLUE .. "AutoLooter" .. Color.WHITE .. ">|r " .. out)
	end
end

function AUTO_LOOTER.Toggle(bool)
	DataBase.enable = Util.GetBoolean(bool, not DataBase.enable)

	if DataBase.enable then
		AUTO_LOOTER:Enable()
		AUTO_LOOTER:RegisterEvent("LOOT_READY")
		DataBase.enable = true
		AUTO_LOOTER.print(L["Enabled"])
	else
		AUTO_LOOTER:Disable()
		AUTO_LOOTER:UnregisterEvent("LOOT_READY")
		DataBase.enable = false
		AUTO_LOOTER.print(L["Disabled"])
	end
end

function AUTO_LOOTER:ReloadOptions()
	PRIVATE_TABLE.DB = self.db.profile
	PRIVATE_TABLE.CHAR_DB = self.db.char
	DataBase = PRIVATE_TABLE.DB

	AUTO_LOOTER.Toggle(DataBase.enable)
end

function AUTO_LOOTER:CreateProfile()
	self.options = {
		type = "group",
		name = "AutoLooter",
		args = {
			config = {
				type = "execute",
				name = L["Show/Hide UI"],
				func = function() LibStub("AceConfigDialog-3.0"):Open(ADDON_NAME) end,
				hidden = true
			},
			general = {
				order = 0,
				name = L["General"],
				type = "group",
				args = {}
			}
		}
	}

	self.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profile.order = -1

	for _, module in AUTO_LOOTER:IterateModules() do
		if (module.GetOptions) then
			Util.mergeTable(self.options.args, module:GetOptions())
		end
	end

	local AceConfig = LibStub("AceConfig-3.0")
	AceConfig:RegisterOptionsTable("AutoLooter", self.options, { "al", "autolooter", "atl" })

	local AceDialog = LibStub("AceConfigDialog-3.0")
	self.optionsFrame = AceDialog:AddToBlizOptions("AutoLooter")
end

function AUTO_LOOTER:OnInitialize()
	local defaults = {
		profile = {
			items = {},
			ignore = {},
			alert = {},
			enable = true,
			printout = true,
			printoutIgnored = false,
			printType = false,
			lootAll = false,
			lootQuest = true,
			close = false,
			rarity = 2,
			price = 40000,
			alertSound = "Sound/creature/Murloc/mMurlocAggroOld.ogg",
			typeTable = {}, --CreateAHTable(),
			ignoreGreys = false,
			autoConfirmRoll = false,
			minimap = { hide = false },
			ignoreBop = false,
			printoutReason = true
		},
		char = {
			chatFrameNames = { [-1] = true }
		}
	}
	self.db = LibStub("AceDB-3.0"):New("AutoLooterDB", defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileChanged", "ReloadOptions")
	self.db.RegisterCallback(self, "OnProfileCopied", "ReloadOptions")
	self.db.RegisterCallback(self, "OnProfileReset", "ReloadOptions")

	AUTO_LOOTER:ReloadOptions()
	AUTO_LOOTER:CreateProfile()

	DEFAULT_CHAT_FRAME:AddMessage(Color.BLUE .. "AutoLooter" .. Color.WHITE .. " || v" .. MOD_VERSION .. " || " .. Color.YELLOW .. "/autolooter /al /atl|r")
end

local function Loot(index, itemName, itemLink)
	LootSlot(index)
	ConfirmLootSlot(index) -- In case it's a Bind on Pickup
end

local trim = Util.trim
local function PrintReason(reason, contents)
	local items = ""
	for _, content in pairs(contents) do
		items = items .. content .. " "
	end

	if (not reason or reason == "") then
		AUTO_LOOTER.print(trim(items))
	else
		AUTO_LOOTER.print(reason, "|r: ", trim(items))
	end
end

---@return fun(tbl: table<string, AutoLooterModule>):string, AutoLooterModule
function AUTO_LOOTER:SortedModulesIterator(lootOnly)
	local function sort(o1, o2)
		return (self:GetModule(o1).priority or 99999999) < (self:GetModule(o2).priority or 99999999)
	end
	local exclusion
	if (lootOnly) then
		exclusion = function(key, module)
			return module.CanLoot
		end
	end
	local function iterator() return self:IterateModules() end

	return Util.orderedPairs(iterator, sort, exclusion)
end

function AUTO_LOOTER:LOOT_READY(_, autoloot)
	if (autoloot) then return end

	local reasonMap = {}
	local printReason = PRIVATE_TABLE.DB.printout

	for nIndex = 1, GetNumLootItems() do
		local icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(nIndex)
		local sItemLink = GetLootSlotLink(nIndex)

		for _, module in self:SortedModulesIterator(true) do
			local loot, reason, reasonContent, forceBreak = module.CanLoot(sItemLink, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)

			if (printReason and reason and reasonContent and reasonContent ~= "") then
				-- ignored items will still print the reason
				if (loot and not PRIVATE_TABLE.DB.printoutReason) then
					reason = ""
				end

				if (loot or PRIVATE_TABLE.DB.printoutIgnored) then
					reasonMap[reason] = reasonMap[reason] or {}
					table.insert(reasonMap[reason], reasonContent)
				end
			end

			if loot then
				Loot(nIndex, sTitle, sItemLink)
				break
			end

			if forceBreak then break end -- ignore other modules and go to the next item
		end
	end

	for _, module in self:SortedModulesIterator() do
		if (module.Finish) then module.Finish() end
	end

	for reason, contents in pairs(reasonMap) do
		PrintReason(reason, contents)
	end
end