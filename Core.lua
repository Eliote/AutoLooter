local ADDON_NAME, PRIVATE_TABLE = ...
PRIVATE_TABLE.MODULES = {}

setmetatable(PRIVATE_TABLE, {
	__index = function(table, key)
		table[key] = {}
		return table[key]
	end
})

local L = PRIVATE_TABLE.L
local function defaultFunc(L, key)
	-- If this function was called, we have no localization for this key.
	-- We could complain loudly to allow localizers to see the error of their ways,
	-- but, for now, just return the key as its own localization. This allows you to
	-- avoid writing the default localization out explicitly.
	return key;
end

setmetatable(L, { __index = defaultFunc });
