local ADDON_NAME, PRIVATE_TABLE = ...;
PRIVATE_TABLE.AUTO_LOOTER = LibStub("AceAddon-3.0"):NewAddon("AutoLooter", "AceEvent-3.0")

PRIVATE_TABLE.GetTable = function(tableName)
	if not PRIVATE_TABLE[tableName] then
		PRIVATE_TABLE[tableName] = {}
	end

	return PRIVATE_TABLE[tableName]
end


local L = PRIVATE_TABLE.GetTable("L")
local function defaultFunc(L, key)
	-- If this function was called, we have no localization for this key.
	-- We could complain loudly to allow localizers to see the error of their ways,
	-- but, for now, just return the key as its own localization. This allows you to
	-- avoid writing the default localization out explicitly.
	return key;
end

setmetatable(L, { __index = defaultFunc });