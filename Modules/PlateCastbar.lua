local AddOn = "PlateCastBar"
local Gladdy = LibStub("Gladdy")

function log(...)
	local text = ""
	for i = 1, select("#", ...) do
		text = text .. " " .. tostring(select(i, ...))
	end
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

local Table = {
	["Nameplates"] = {},
	["CheckButtons"] = {
		["Test"] = {
			["PointX"] = 170,
			["PointY"] = -10,
		},
		["Player Pet"] = {
			["PointX"] = 300,
			["PointY"] = -90,
		},
		["Icon"] = {
			["PointX"] = 300,
			["PointY"] = -120,
		},
		["Timer"] = {
			["PointX"] = 300,
			["PointY"] = -150,
		},
		["Spell"] = {
			["PointX"] = 300,
			["PointY"] = -180,
		},
	},
}
local Textures = {
	Font = "Interface\\AddOns\\Gladdy\\Images\\DorisPP.ttf",
	CastBar = "Interface\\AddOns\\Gladdy\\Images\\LiteStep.tga",
}
_G[AddOn .. "_SavedVariables"] = {
	["CastBar"] = {
		["Width"] = 105,
		["PointX"] = 15,
		["PointY"] = -5,
	},
	["Icon"] = {
		["PointX"] = -62,
		["PointY"] = 0,
	},
	["Timer"] = {
		["Anchor"] = "RIGHT",
		["PointX"] = 52,
		["PointY"] = 0,
		["Format"] = "LEFT"
	},
	["Spell"] = {
		["Anchor"] = "LEFT",
		["PointX"] = -53,
		["PointY"] = 0,
	},
	["Enable"] = {
		["Test"] = false,
		["Player Pet"] = true,
		["Icon"] = true,
		["Timer"] = true,
		["Spell"] = true,
	},
}

local unitsToCheck = {
	["mouseover"] = true,
	["mouseovertarget"] = true,
	["mouseovertargettarget"] = true,
	["target"] = true,
	["targettarget"] = true,
	["targettargettarget"] = true,
	["focus"] = true,
	["focustargettarget"] = true,
	["focustarget"] = true,
	["pet"] = true,
	["pettarget"] = true,
	["pettargettarget"] = true,
	["party1"] = true,
	["party2"] = true,
	["party3"] = true,
	["party4"] = true,
	["party1target"] = true,
	["party2target"] = true,
	["party3target"] = true,
	["party4target"] = true,
	["partypet1target"] = true,
	["partypet2target"] = true,
	["partypet3target"] = true,
	["partypet4target"] = true,
	["party1targettarget"] = true,
	["party2targettarget"] = true,
	["party3targettarget"] = true,
	["party4targettarget"] = true,
	["raid1"] = true,
	["raid2"] = true,
	["raid3"] = true,
	["raid4"] = true,
	["raid1target"] = true,
	["raid2target"] = true,
	["raid3target"] = true,
	["raid4target"] = true,
	["raidpet1target"] = true,
	["raidpet2target"] = true,
	["raidpet3target"] = true,
	["raidpet4target"] = true,
	["raid1targettarget"] = true,
	["raid2targettarget"] = true,
	["raid3targettarget"] = true,
	["raid4targettarget"] = true,
}

local numChildren = -1
local function HookFrames(...)
	for ID = 1,select('#', ...) do
		local frame = select(ID, ...)
		local region = frame:GetRegions()
		if ( not Table["Nameplates"][frame] and not frame:GetName() and region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" ) then
			Table["Nameplates"][frame] = true
		end
	end
end

local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
local function Frame_RegisterEvents()
	Frame:RegisterEvent("UNIT_SPELLCAST_START")
	Frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	Frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	Frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	Frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	Frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
	Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	Frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	Frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
end

local function UnitCastBar_Create(unit)
	_G[AddOn .. "_Frame_" .. unit .. "CastBar"] = CreateFrame("Frame",nil);
	local CastBar = _G[AddOn .. "_Frame_" .. unit .. "CastBar"]
	CastBar:SetFrameStrata("BACKGROUND");
	CastBar:SetWidth(_G[AddOn .. "_SavedVariables"]["CastBar"]["Width"]);
	CastBar:SetHeight(11);
	CastBar:SetPoint("CENTER");

	_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"] = CastBar:CreateTexture(nil,"ARTWORK");
	local Texture = _G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]
	Texture:SetHeight(11);
	Texture:SetTexture(Textures.CastBar);
	Texture:SetPoint("CENTER",AddOn .. "_Frame_" .. unit .. "CastBar","CENTER");

	_G[AddOn .. "_Texture_" .. unit .. "CastBar_Icon"] = CastBar:CreateTexture(nil,"ARTWORK");
	local Icon = _G[AddOn .. "_Texture_" .. unit .. "CastBar_Icon"]
	Icon:SetHeight(13);
	Icon:SetWidth(13);
	Icon:SetPoint("CENTER",AddOn .. "_Frame_" .. unit .. "CastBar","CENTER",
		_G[AddOn .. "_SavedVariables"]["Icon"]["PointX"],
		_G[AddOn .. "_SavedVariables"]["Icon"]["PointY"]);
	if ( _G[AddOn .. "_SavedVariables"]["Enable"]["Icon"] ) then
		Icon:Show()
	else
		Icon:Hide()
	end

	_G[AddOn .. "_Texture_" .. unit .. "CastBar_IconBorder"] = CastBar:CreateTexture(nil,"BACKGROUND");
	local IconBorder = _G[AddOn .. "_Texture_" .. unit .. "CastBar_IconBorder"]
	IconBorder:SetHeight(16);
	IconBorder:SetWidth(16);
	IconBorder:SetPoint("CENTER",Icon,"CENTER");
	if ( _G[AddOn .. "_SavedVariables"]["Enable"]["Icon"] ) then
		IconBorder:Show()
	else
		IconBorder:Hide()
	end

	_G[AddOn .. "_FontString_" .. unit .. "CastBar_SpellName"] = CastBar:CreateFontString(nil)
	local SpellName = _G[AddOn .. "_FontString_" .. unit .. "CastBar_SpellName"]
	SpellName:SetFont(Textures.Font,9,"OUTLINE")
	SpellName:SetPoint(_G[AddOn .. "_SavedVariables"]["Spell"]["Anchor"],
		AddOn .. "_Frame_" .. unit .. "CastBar","CENTER",
		_G[AddOn .. "_SavedVariables"]["Spell"]["PointX"],
		_G[AddOn .. "_SavedVariables"]["Spell"]["PointY"]);
	if ( _G[AddOn .. "_SavedVariables"]["Enable"]["Spell"] ) then
		SpellName:Show()
	else
		SpellName:Hide()
	end

	_G[AddOn .. "_FontString_" .. unit .. "CastBar_CastTime"] = CastBar:CreateFontString(nil)
	local CastTime = _G[AddOn .. "_FontString_" .. unit .. "CastBar_CastTime"]
	CastTime:SetFont(Textures.Font,9,"OUTLINE")
	CastTime:SetPoint(_G[AddOn .. "_SavedVariables"]["Timer"]["Anchor"],
		AddOn .. "_Frame_" .. unit .. "CastBar","CENTER",
		_G[AddOn .. "_SavedVariables"]["Timer"]["PointX"],
		_G[AddOn .. "_SavedVariables"]["Timer"]["PointY"]);
	if ( _G[AddOn .. "_SavedVariables"]["Enable"]["Timer"] ) then
		CastTime:Show()
	else
		CastTime:Hide()
	end

	_G[AddOn .. "_Texture_" .. unit .. "CastBar_Border"] = CastBar:CreateTexture(nil,"BACKGROUND");
	local Border =_G[AddOn .. "_Texture_" .. unit .. "CastBar_Border"]
	Border:SetPoint("CENTER",AddOn .. "_Frame_" .. unit .. "CastBar","CENTER");
	Border:SetWidth(_G[AddOn .. "_SavedVariables"]["CastBar"]["Width"]+5);
	Border:SetHeight(16);

	local Background = CastBar:CreateTexture(nil,"BORDER");
	Background:SetTexture(1/10, 1/10, 1/10, 1);
	Background:SetAllPoints(AddOn .. "_Frame_" .. unit .. "CastBar");
end

local function CastBars_Create()
	for k,v in pairs(unitsToCheck) do
		UnitCastBar_Create(k)
	end
end

Frame:SetScript("OnEvent",function(self,event,unitID,spell,...)
	local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( not _G[AddOn .. "_PlayerEnteredWorld"] ) then
			Frame_RegisterEvents()
			CastBars_Create()
			_G[AddOn .. "_PlayerEnteredWorld"] = true
		end
		Table["Nameplates"] = {}
	end


	local function Spell_Interrupt()
		if ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
			if ( eventType == "SPELL_INTERRUPT" ) then
				local function Units_Check(unit)
					if ( destGUID ==  UnitGUID(unit) ) then
						_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]:SetVertexColor(1, 0, 0)
						_G[AddOn .. "_" .. unit .. "_Casting"] = false
						_G[AddOn .. "_" .. unit .. "_Channeling"] = false
						_G[AddOn .. "_" .. unit .. "_Fading"] = true
					end
				end
				for k,v in pairs (unitsToCheck) do
					Units_Check(k)
				end
			end
		end
	end
	Spell_Interrupt()
end)

-- function needs massive cleanup and shouldn't be used in the first place
-- instead of using events, just query unitcastinginfo OnUpdate
local function setCastbarInfo(event, unit)
	if ( event == "UNIT_SPELLCAST_START" ) then
		_G[AddOn .. "_" .. unit .. "_Fading"] = false
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
		if not name then return end
		_G[AddOn .. "_" .. unit .. "_Casting"] = true
		if ( string.len(name) > 12 ) then name = (string.sub(name,1,12) .. ".. ") end
		_G[AddOn .. "_FontString_" .. unit .. "CastBar_SpellName"]:SetText(name)
		_G[AddOn .. "_Frame_" .. unit .. "CastBar"]:SetAlpha(1)
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_Icon"]:SetTexture(texture)
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].value = (GetTime() - (startTime / 1000));
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].maxValue = (endTime - startTime) / 1000;
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]:SetVertexColor(1, 0.5, 0)
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		_G[AddOn .. "_" .. unit .. "_Fading"] = false
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
		if not name then return end
		_G[AddOn .. "_" .. unit .. "_Channeling"] = true
		if ( string.len(name) > 12 ) then name = (string.sub(name,1,12) .. ".. ") end
		_G[AddOn .. "_FontString_" .. unit .. "CastBar_SpellName"]:SetText(name)
		_G[AddOn .. "_Frame_" .. unit .. "CastBar"]:SetAlpha(1)
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_Icon"]:SetTexture(texture)
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].value = (GetTime() - (startTime / 1000));
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].maxValue = (endTime - startTime) / 1000;
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]:SetVertexColor(1, 0.5, 0)
	elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
		if not name then return end
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].value = (GetTime() - (startTime / 1000));
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].maxValue = (endTime - startTime) / 1000;
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
		if not name then return end
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].value = (GetTime() - (startTime / 1000));
		_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].maxValue = (endTime - startTime) / 1000;
	elseif ( event == "UNIT_SPELLCAST_FAILED" ) then
		if ( _G[AddOn .. "_" .. unit .. "_Casting"] == true and unitID == unit ) then
			_G[AddOn .. "_" .. unit .. "_Casting"] = false
			_G[AddOn .. "_" .. unit .. "_Channeling"] = false
		end
	elseif ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
		if ( _G[AddOn .. "_" .. unit .. "_Casting"] and unitID == unit ) then
			_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]:SetVertexColor(0, 1, 0)
			_G[AddOn .. "_" .. unit .. "_Fading"] = true
			_G[AddOn .. "_" .. unit .. "_Casting"] = false
		end
	end
end

Frame:SetScript("OnUpdate", function(self, elapsed)
	-- throw nameplates in table
	if ( WorldFrame:GetNumChildren() ~= numChildren ) then
		numChildren = WorldFrame:GetNumChildren()
		if Gladdy.db.npCastbars then
			HookFrames(WorldFrame:GetChildren())
		end
	end

	-- decide whether castbar should be showing or not
	for frame in pairs(Table["Nameplates"]) do
		local hpborder, cbborder, cbicon, overlay, oldname, level, bossicon, raidicon = frame:GetRegions()
		local name = oldname:GetText()
		-- hide all castbars, then only shows those of players whose nameplates were found
		for k, v in pairs(unitsToCheck) do
			--_G[AddOn .. "_Frame_" .. k .. "CastBar"]:Hide()
			if( name == UnitName(k) and UnitCastingInfo(k) ) then
				setCastbarInfo("UNIT_SPELLCAST_START", k)
				_G[AddOn .. "_Frame_" .. k .. "CastBar"]:SetPoint("TOP",hpborder,"BOTTOM",6,-4.5)
				_G[AddOn .. "_Frame_" .. k .. "CastBar"]:SetParent(frame)
				_G[AddOn .. "_Frame_" .. k .. "CastBar"]:Show()
			end
		end
	end

	--set info to castbars
	local function CastBars_Update()
		local function Casting_Update(unit)
			local Casting = _G[AddOn .. "_" .. unit .. "_Casting"]
			local Channeling = _G[AddOn .. "_" .. unit .. "_Channeling"]
			local CastBar = _G[AddOn .. "_Frame_" .. unit .. "CastBar"]
			local Texture = _G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]
			local Border = _G[AddOn .. "_Texture_" .. unit .. "CastBar_Border"]
			local IconBorder = _G[AddOn .. "_Texture_" .. unit .. "CastBar_IconBorder"]
			local Fading =  _G[AddOn .. "_" .. unit .. "_Fading"]
			local CastTime = _G[AddOn .. "_FontString_" .. unit .. "CastBar_CastTime"]
			local Width = _G[AddOn .. "_SavedVariables"]["CastBar"]["Width"]
			local Enabled = true


			if ( not Fading or not _G[AddOn .. "_" .. unit .. "CastBarAlpha"] ) then
				_G[AddOn .. "_" .. unit .. "CastBarAlpha"] = 0
			end
			if ( Enabled ) then
				if ( Channeling and not UnitChannelInfo(unit) ) then
					Texture:SetVertexColor(0, 1, 0)
					_G[AddOn .. "_" .. unit .. "_Fading"] = true
					_G[AddOn .. "_" .. unit .. "_Channeling"] = false
				elseif ( Casting and not Fading and UnitCastingInfo(unit) ) then
					local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
					if ( endTime ) then
						local total = string.format("%.2f",(endTime-startTime)/1000)
						local left = string.format("%.1f",total - Texture.value/Texture.maxValue*total)
						if ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "LEFT" ) then
							CastTime:SetText(left)
						elseif ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "TOTAL" ) then
							CastTime:SetText(total)
						elseif ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "BOTH" ) then
							CastTime:SetText(left .. " /" .. total)
						end
					end
					Border:SetTexture(0,0,0,1)
					IconBorder:SetTexture(0,0,0,1)
					Texture.value = Texture.value + elapsed
					if ( Texture.value >= Texture.maxValue ) then return end
					Texture:SetWidth(Width*Texture.value/Texture.maxValue)
					point, relativeTo, relativePoint, xOfs, yOfs = Texture:GetPoint()
					Texture:SetPoint(point, relativeTo, relativePoint, -Width/2+Width/2*Texture.value/Texture.maxValue, yOfs)
				elseif ( Channeling and not Fading ) then
					local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
					if ( endTime ) then
						local total = string.format("%.2f",(endTime-startTime)/1000)
						local left = string.format("%.1f",total - Texture.value/Texture.maxValue*total)
						if ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "LEFT" ) then
							CastTime:SetText(left)
						elseif ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "TOTAL" ) then
							CastTime:SetText(total)
						elseif ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "BOTH" ) then
							CastTime:SetText(left .. " /" .. total)
						end
					end
					Border:SetTexture(0,0,0,1)
					IconBorder:SetTexture(0,0,0,1)
					Texture.value = Texture.value + elapsed
					if ( Texture.value >= Texture.maxValue ) then return end
					Texture:SetWidth(Width*(Texture.maxValue-Texture.value)/Texture.maxValue)
					point, relativeTo, relativePoint, xOfs, yOfs = Texture:GetPoint()
					Texture:SetPoint(point, relativeTo, relativePoint, -Width/2*Texture.value/Texture.maxValue, yOfs)
				elseif ( Fading ) then
					if ( Channeling or Casting or _G[AddOn .. "_" .. unit .. "CastBarAlpha"] >= 0.5 ) then
						_G[AddOn .. "_" .. unit .. "CastBarAlpha"] = 0
						_G[AddOn .. "_" .. unit .. "_Fading"] = false
						return
					end
					_G[AddOn .. "_" .. unit .. "CastBarAlpha"] = _G[AddOn .. "_" .. unit .. "CastBarAlpha"] + elapsed
					CastBar:SetAlpha(1-(2*_G[AddOn .. "_" .. unit .. "CastBarAlpha"]))
				elseif ( CastBar ) then
					CastBar:SetAlpha(0)
				end
			end
		end

		for k,v in pairs(unitsToCheck) do
			Casting_Update(k)
		end
	end
	CastBars_Update()
end)
