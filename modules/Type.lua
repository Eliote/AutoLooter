local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Type", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")
module.priority = 1100

local reason = Color.GREEN .. L["Type"]

local GetItemInfoInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
local GetItemClassInfo = (C_Item and C_Item.GetItemClassInfo) or GetItemClassInfo
local GetItemSubClassInfo = (C_Item and C_Item.GetItemSubClassInfo) or GetItemSubClassInfo

local C_AuctionHouse = C_AuctionHouse
if not C_AuctionHouse then
	C_AuctionHouse = {}
	C_AuctionHouse.GetAuctionItemSubClasses = function(...)
		return { GetAuctionItemSubClasses(...) }
	end
end


local function hasAnySubtypeEnabled(subtypeTable)
	if subtypeTable then
		for subtype, enabled in pairs(subtypeTable) do
			if enabled then return true end
		end
	end
end

function module:CanEnable()
	if self.db.profile.printoutType then return true end

	for _, subtypeTable in pairs(AutoLooter.db.profile.typeTable) do
		if hasAnySubtypeEnabled(subtypeTable) then return true end
	end
end

function module:InitializeDb()
	self.db = AutoLooter.db
end

local function LootType(iType, iSubType, iRarity)
	if AutoLooter.db.profile.ignoreGreys and iRarity == 0 then return false end

	local t = AutoLooter.db.profile.typeTable[iType]
	if t then return t[iSubType] or t["(Legacy Types)"] end

	return false
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, itemType, itemSubType = GetItemInfoInstant(link)

	if LootType(itemType, itemSubType, nRarity) then
		local typeSubtype = (AutoLooter.db.profile.printoutType and Color.YELLOW .. "(" .. itemType .. "/" .. itemSubType .. ")|r") or ""

		return true, reason, typeSubtype .. AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end

local function SetTypeTableDb(db, type, subtype, value)
	db.typeTable = db.typeTable or {}
	db.typeTable[type] = db.typeTable[type] or {}
	db.typeTable[type][subtype] = value
	module:UpdateState()
end

local function GetOrCreateTypeTableDb(db, type, subtype)
	if (not db.typeTable) then
		db.typeTable = { [type] = { [subtype] = false } }
		return false
	end
	if (not db.typeTable[type]) then
		db.typeTable[type] = { [subtype] = false }
		return false
	end
	if (db.typeTable[type][subtype] == nil) then
		db.typeTable[type][subtype] = false
		return false
	end

	return db.typeTable[type][subtype]
end

local function CreateAHTable(defTable)
	local out = {}

	local itemClasses = (Enum and Enum.ItemClass) or {
		LE_ITEM_CLASS_CONSUMABLE,
		LE_ITEM_CLASS_CONTAINER,
		LE_ITEM_CLASS_WEAPON,
		LE_ITEM_CLASS_GEM,
		LE_ITEM_CLASS_ARMOR,
		LE_ITEM_CLASS_REAGENT,
		LE_ITEM_CLASS_PROJECTILE,
		LE_ITEM_CLASS_TRADEGOODS,
		LE_ITEM_CLASS_ITEM_ENHANCEMENT,
		LE_ITEM_CLASS_RECIPE,
		LE_ITEM_CLASS_QUIVER,
		LE_ITEM_CLASS_QUESTITEM,
		LE_ITEM_CLASS_KEY,
		LE_ITEM_CLASS_MISCELLANEOUS,
		LE_ITEM_CLASS_GLYPH,
		LE_ITEM_CLASS_BATTLEPET,
		LE_ITEM_CLASS_WOW_TOKEN,
	};

	for _, itemClass in pairs(itemClasses) do
		local t = {}
		local classInfo = GetItemClassInfo(itemClass)

		if classInfo then
			local itemSubClasses = C_AuctionHouse.GetAuctionItemSubClasses(itemClass)
			if #itemSubClasses > 0 then
				for _, itemSubClass in pairs(itemSubClasses) do
					local subclassInfo, _ = GetItemSubClassInfo(itemClass, itemSubClass)
					-- GetAuctionItemSubClasses for the itemClass '0', is returning a subclass '-1' for some reason.
					-- So we have to check if it's a real subclass here
					if (subclassInfo) then
					    t[subclassInfo] = GetOrCreateTypeTableDb(defTable, classInfo, subclassInfo)
					end
				end
			else
				t[classInfo] = GetOrCreateTypeTableDb(defTable, classInfo, classInfo)
			end

			out[classInfo] = t
		end
	end

	return out
end

local function SetAll(table, value)
	for k, v in pairs(table) do
		table[k] = value
	end
	module:UpdateState()
end

local function createOptions()
	local options = {
		ignoreGreys = {
			type = "toggle",
			name = L["Ignore greys when looting by type"],
			order = 2,
			width = "full",
			set = function(info, value) module:SetProfileVar("ignoreGreys", Util.GetBoolean(value)) end,
			get = function(info) return AutoLooter.db.profile.ignoreGreys end
		},
		removeAll = {
			type = "execute",
			desc = L["This will cleanup and recreate the type database"],
			confirm = true,
			width = "double",
			name = L["Remove all"],
			order = 3,
			func = function() module:SetProfileVar("typeTable", CreateAHTable({})) end
		},
		removeOld = {
			type = "execute",
			desc = L["This will remove old types/subtypes entries from the database"],
			confirm = true,
			width = "double",
			name = L["Remove old entries"],
			order = 4,
			func = function() module:SetProfileVar("typeTable", CreateAHTable(AutoLooter.db.profile.typeTable)) end
		}
	}

	local typeTable = CreateAHTable(AutoLooter.db.profile)

	local order = 10
	for type, subtypeTable in Util.orderedPairs(typeTable) do
		local values = {}

		for subtype, _ in Util.orderedPairs(subtypeTable) do
			values[subtype] = subtype
		end

		if (next(values)) then
			order = order + 1
			options[type] = {
				name = function()
					local color = (hasAnySubtypeEnabled(AutoLooter.db.profile.typeTable[type]) and Color.GREEN) or ""
					return color .. type
				end,
				order = order,
				type = "group",
				args = {
					all = {
						type = "execute",
						name = L["Select all"],
						func = function() SetAll(AutoLooter.db.profile.typeTable[type], true) end,
						order = 10
					},
					none = {
						type = "execute",
						name = L["Remove all"],
						func = function() SetAll(AutoLooter.db.profile.typeTable[type], false) end,
						order = 20
					},
					toggle = {
						type = "multiselect",
						name = type,
						values = values,
						get = function(info, key) return GetOrCreateTypeTableDb(AutoLooter.db.profile, type, key) end,
						set = function(info, key, value) SetTypeTableDb(AutoLooter.db.profile, type, key, value) end,
						order = 1
					},
				}
			}
		end
	end

	local keyTable = {}
	options.oldEntries = {
		type = "multiselect",
		name = L["Old Entries"],
		values = function()
			local values = {}
			for type, subtypeTable in pairs(AutoLooter.db.profile.typeTable) do
				for subtype, enabled in pairs(subtypeTable) do
					if (typeTable[type] == nil) or (typeTable[type][subtype] == nil) then
						local key = type .. "//" .. subtype
						keyTable[key] = { type = type, subtype = subtype }
						values[key] = type .. "/" .. subtype
					end
				end
			end
			return values
		end,
		get = function(info, key)
			local t = keyTable[key]
			return GetOrCreateTypeTableDb(AutoLooter.db.profile, t.type, t.subtype)
		end,
		set = function(info, key, value)
			local t = keyTable[key]
			SetTypeTableDb(AutoLooter.db.profile, t.type, t.subtype, value)
		end
	}

	return options
end

function module:GetOptions()
	return {
		type = {
			name = L["Type"],
			type = "group",
			args = createOptions()
		},
		chat = {
			args = {
				printoutType = {
					type = "toggle",
					name = L["Printout items type"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, value) module:SetProfileVar("printoutType", Util.GetBoolean(value)) end,
					get = function(info) return AutoLooter.db.profile.printoutType end
				}
			}
		}
	}
end