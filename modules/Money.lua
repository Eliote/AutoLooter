local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Money", "AceEvent-3.0")
module.priority = 200

local reason = Color.GREEN .. L["Coin"]

local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return unpack(t)
end

local wordsValue = {}
wordsValue[GetCoinText(10000):gsub("[0-9]", "")] = 10000 -- gold
wordsValue[GetCoinText(20000):gsub("[0-9]", "")] = 10000 -- gold
wordsValue[GetCoinText(100):gsub("[0-9]", "")] = 100 -- silver
wordsValue[GetCoinText(200):gsub("[0-9]", "")] = 100 -- silver
wordsValue[GetCoinText(1):gsub("[0-9]", "")] = 1 -- copper
wordsValue[GetCoinText(2):gsub("[0-9]", "")] = 1 -- copper

-- totally not a bodge
local function getMoneyValue(moneyText)
	if (not moneyText) then return 0 end

	local textOnly = moneyText:gsub("[0-9]", "")
	local moneyValue = moneyText:gsub("[^0-9]", "")

	return (wordsValue[textOnly] or 0) * moneyValue
end

local function extractMoneyValue(moneyString)
	-- here be dragons!!!
	local a, b, c = split(moneyString, "\n")
	local total = getMoneyValue(a) + getMoneyValue(b) + getMoneyValue(c)

	return total
end

local function formatMoney(moneyString)
	if (AutoLooter.db.profile.printoutIconOnly) then
		return GetMoneyString(extractMoneyValue(moneyString))
	end

	return string.gsub(moneyString, "\n", " ")
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (nQuantity == 0) then
		return true, reason, formatMoney(sTitle), nil
	end
end
