local ADDON_NAME, PRIVATE_TABLE = ...

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")

local prot = PRIVATE_TABLE.SingleVarModulePrototype

function prot:New()
	local function LoadState(self)
		if (AutoLooter.db.profile.enable and self:CanEnable()) then
			self:Enable()
		else
			self:Disable()
		end
	end

	local function OnInitialize(self)
		if self.InitializeDb then self:InitializeDb() end

		self.db.RegisterCallback(self, "OnProfileChanged", LoadState, self)
		self.db.RegisterCallback(self, "OnProfileCopied", LoadState, self)
		self.db.RegisterCallback(self, "OnProfileReset", LoadState, self)

		-- OnInitialize (and only it) should call SetEnabledState
		self:SetEnabledState(AutoLooter.db.profile.enable and self:CanEnable())
		AutoLooter.RegisterCallback(self, "OnEnable", LoadState, self)
		AutoLooter.RegisterCallback(self, "OnDisable", LoadState, self)
	end

	local newPrototype = {
		LoadState = LoadState,
		OnInitialize = OnInitialize
	}

	newPrototype.super = newPrototype

	return newPrototype
end


