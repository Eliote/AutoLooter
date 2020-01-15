local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Type", "AceEvent-3.0")
module.priority = 1100

local reason = Color.GREEN .. L["Type"]

local function LootType(iType, iSubType, iRarity)
	if PRIVATE_TABLE.DB.ignoreGreys and iRarity == 0 then return false end

	local t = PRIVATE_TABLE.DB.typeTable[iType]
	if t then return t[iSubType] or t["(Legacy Types)"] end

	return false
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType = GetItemInfo(link)

	if LootType(itemType, itemSubType, nRarity) then
		local typeSubtype = (PRIVATE_TABLE.DB.printoutType and Color.YELLOW .. "(" .. itemType .. "/" .. itemSubType .. ")|r") or ""

		return true, reason, typeSubtype .. AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end

local function SetTypeTableDb(db, type, subtype, value)
	db.typeTable = db.typeTable or {}
	db.typeTable[type] = db.typeTable[type] or {}
	db.typeTable[type][subtype] = value
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

	local itemClasses = {
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
					t[subclassInfo] = GetOrCreateTypeTableDb(defTable, classInfo, subclassInfo)
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
end

local function createOptions()
	local options = {
		printoutType = {
			type = "toggle",
			name = L["Printout items type"],
			order = 1,
			width = "double",
			set = function(info, val) PRIVATE_TABLE.DB.printoutType = Util.GetBoolean(val) end,
			get = function(info) return PRIVATE_TABLE.DB.printoutType end
		},
		ignoreGreys = {
			type = "toggle",
			name = L["Ignore greys when looting by type"],
			order = 2,
			width = "double",
			set = function(info, val) PRIVATE_TABLE.DB.ignoreGreys = Util.GetBoolean(val) end,
			get = function(info) return PRIVATE_TABLE.DB.ignoreGreys end
		}
	}

	local typeTable = CreateAHTable(PRIVATE_TABLE.DB)

	for type, subtypeTable in Util.orderedPairs(typeTable) do
		local values = {}

		for subtype, _ in Util.orderedPairs(subtypeTable) do
			values[subtype] = subtype
		end

		if (Util.CountTable(subtypeTable) > 0) then
			options[type] = {
				name = type,
				type = "group",
				args = {
					all = {
						type = "execute",
						name = L["Select all"],
						func = function() SetAll(PRIVATE_TABLE.DB.typeTable[type], true) end,
						order = 10
					},
					none = {
						type = "execute",
						name = L["Remove all"],
						func = function() SetAll(PRIVATE_TABLE.DB.typeTable[type], false) end,
						order = 20
					},
					toggle = {
						type = "multiselect",
						name = type,
						values = values,
						get = function(info, key) return GetOrCreateTypeTableDb(PRIVATE_TABLE.DB, type, key) end,
						set = function(info, key, value) SetTypeTableDb(PRIVATE_TABLE.DB, type, key, value) end,
						order = 1
					},
				}
			}
		end
	end

	return options
end

function module:GetOptions()
	return {
		type = {
			name = L["Type"],
			type = "group",
			args = createOptions()
		}
	}
end