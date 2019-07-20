local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(1100)
local reason = Color.GREEN .. L["Type"]

local function LootType(iType, iSubType, iRarity)
	if PRIVATE_TABLE.DB.ignoreGreys and iRarity == 0 then return false end

	local t = PRIVATE_TABLE.DB.typeTable[iType]
	if t then return t[iSubType] or t["(Legacy Types)"] end

	return false
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)

	if LootType(itemType, itemSubType, nRarity) then
		local typeSubtype = (PRIVATE_TABLE.DB.printoutType and Color.YELLOW .. "(" .. itemType .. "/" .. itemSubType .. ")|r") or ""

		return true, reason, typeSubtype .. Util.GetItemText(icon, link, nQuantity), nil
	end
end

local function SetTypeTableDb(db, type, subtype, value)
	db.typeTable = db.typeTable or {}
	db.typeTable[type] = db.typeTable[type] or {}
	db.typeTable[type][subtype] = value
end

local function GetTypeTableDb(db, type, subtype)
	if (not db.typeTable) then return false end
	if (not db.typeTable[type]) then return false end
	return db.typeTable[type][subtype] or false
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

		local itemSubClasses = { GetAuctionItemSubClasses(itemClass) };
		if #itemSubClasses > 0 then
			for _, itemSubClass in pairs(itemSubClasses) do
				local subclassInfo, _ = GetItemSubClassInfo(itemClass, itemSubClass)
				t[subclassInfo] = GetTypeTableDb(defTable, classInfo, subclassInfo)
			end
		else
			t[classInfo] = GetTypeTableDb(defTable, classInfo, classInfo)
		end

		out[classInfo] = t
	end

	return out
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
				cmdInline = true,
				args = {
					[type] = {
						type = "multiselect",
						name = type,
						desc = "",
						values = values,
						order = 10,
						get = function(info, key) return GetTypeTableDb(PRIVATE_TABLE.DB, type, key) end,
						set = function(info, key, value) SetTypeTableDb(PRIVATE_TABLE.DB, type, key, value) end
					}
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