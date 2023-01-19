local Version = "2.0.33"
local AllowDebug = false

--[[

						ElvUI ItemCount
						Solage of Greymane

						v2.0.33

					To Do:

					- Alt-Right-Click feature re-enable, when we can figure out
					  how to hook Blizzard's ContainerFrameItemButtonMixin:OnClick 



]]--


-- Addon Objects

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local IC = E:NewModule('ElvUI Item Count', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')
local DT = E:GetModule('DataTexts')
local EP = LibStub("LibElvUIPlugin-1.0")
local ADB = LibStub("AceDB-3.0")

-- Color Constants

local hexColor = "|cff00ff96"
local C_YELLOW = "|cffffff00"
local C_GREEN  = "|cff00ff00"
local C_WHITE  = "|cffffffff"
local C_RED    = "|cffff4f8b"
local C_TURQ   = "|cff22ee55"
local C_AQUA   = "|cff44eeaa" --22ee77"
local C_MGNTA  = "|cffff0088"
local C_PURPLE = "|cffEE22aa"
local C_BROWN  = "|cfff4a460"
local C_BLUE   = "|cff4fa8e3"


-- Functions

local function shallowcopy(orig)
   local orig_type = type(orig)
   local copy
   if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in pairs(orig) do
         copy[orig_key] = orig_value
      end
    else -- number, string, boolean, etc
      copy = orig
    end
    return copy
end

local function YesNo(boolarg)
	if boolarg then
		return L["Yes"]
	else
		return L["No"]
	end
end

local function debugSay(pTxt)
	if pTxt == nil then pTxt = "?" end
	if AllowDebug and pf.Debug then
		print(C_MGNTA.."ItemCount: " ..C_YELLOW..pTxt)
	end
end


local format = string.format
local join = string.join
local floor = math.floor
local wipe = table.wipe

local GetCVarBool = GetCVarBool

--------------- LIBRARIES ------------------

local IsAddonLoaded = IsAddonLoaded

IC.version = GetAddOnMetadata("ElvUI_ItemCount", "Version")

--------------- VARIABLES ------------------
local newButtonText = function() end

local menuFrame = CreateFrame("Frame", "ItemCountMenu", E.UIParent, "UIDropDownMenuTemplate")

local edBox = {}
local ix = 0
local tt = {}
local menu = {}
local tmpprofiles = {}

local pfList
local enteredFrame = false
local lastPanel
local dtframe
local displayString = ""
local db, pf
local initialized = false
local Count1 = {}
local Count2 = {}
local Count3 = {}
local Count4 = {}
local Count5 = {}

local self = IC
local okToAlert = false
local NewGoal

--------------- OBJECTS ------------------

local defaults = {

	global = {
		db_version = "1001",
	},
	profile = {
		id = "",
		text = "",
		watched = 1,
		Debug = AllowDebug,
		count1 = {
			index = 1,
			item = "Linen Cloth",
			Goal = 0,
			BellSound = "AllianceBell",
			frozen = false,
			Silent = false,
			Chime = true,
			Alerted = false
		},
		count2 = {
			index = 2,
			item = "Undefined 2",
			Goal = 0,
			BellSound = "AllianceBell",
			frozen = false,
			Silent = false,
			Chime = true,
			Alerted = false
		},
		count3 = {
			index = 3,
			item = "Undefined 3",
			Goal = 0,
			BellSound = "AllianceBell",
			frozen = false,
			Silent = false,
			Chime = true,
			Alerted = false
		},
		count4 = {
			index = 4,
			item = "Undefined 4",
			Goal = 0,
			BellSound = "AllianceBell",
			frozen = false,
			Silent = false,
			Chime = true,
			Alerted = false
		},
		count5 = {
			index = 5,
			item = "Undefined 5",
			Goal = 0,
			BellSound = "AllianceBell",
			frozen = false,
			Silent = false,
			Chime = true,
			Alerted = false
		},
	},
}

local BellsList = {}
local BellsLabel = {}
local BellsIndex = {}

-- Bell Sound List
local ChimeSound = 5274 --AuctionOpen
local Bells = {
	-- it would be nice to be able to control the order of appearance in the dropdown

	AuctionClose  = 5275,
	AllianceBell  = 6594, --"Sound/Doodad/Belltollalliance.Ogg",
	HordeBell     = 6595, --"Sound/Doodad/Belltollhorde.Ogg",
	NelfBell      = 6674, --"Sound/Doodad/Belltollnightelf.Ogg",
	TribalBell    = 6675, --"Sound/Doodad/Belltolltribal.Ogg",
	Ahoy          = 21174, --"Sound/Creature/Budd/Vo_Qe_Vj_Budd_Allianceship01.Ogg",
	Sailing       = 21175, --"Sound/Creature/Budd/Vo_Qe_Vj_Budd_Allianceship02.Ogg",
	CannonDeath   = 3641, --"Sound/Creature/Cannon/Cannondeath.Ogg",
	Hua           = 1263, --"Sound/Character/Human/Male/Humanmaleaggroa.Ogg",
	Erudax        = 18631, --"Sound/Creature/Erudax/Vo_Gb_Erudax_Attack01.Ogg",
	FelReaver     = 9417, --"Sound/Creature/Felreaver/Felreaverpreaggro.Ogg",
	LaochinHua    = 29859, --"Sound/Creature/Laochen/Vo_Laochin_Attackcrit_01.Ogg",
	DivineBell    = 34387, --"Sound/Doodad/Go_Pa_Divinebell_Ring_Pure.Ogg",
	KaraBell      = 9154, --"Sound/Doodad/Kharazahnbelltoll.Ogg",
	MopGong       = 29066, --"Sound/Doodad/Wow_Mop_Intro_Sfx_Bell_Nogong_Mono.Ogg",
	QuestAdded    = 618,
	OrgeAggro     = 396,
	WorldQuest    = 73277,
	SiegeClunk    = 13893,
	QuestComplete = 619,
	ReadyCheck    = 8960,
	Chime2        = 170877,
	ScenarioStage = 31757,
	Jewelcraft    = 10590,
	JoinQueue     = 79740,
	LegendaryLoot = 63971,
	WoodStackBreak = 173222,
}

--------------- FUNCTIONS ------------------


local function getText(cObj)
	-- DataText display

	local DataText

	local countcolor = C_WHITE  -- default white
	local alertcolor = C_MGNTA  -- alert redviolet?

	if not cObj.item then return "Item Count" end

	if cObj.Goal and tonumber(cObj.Goal) > 0 then
		countcolor = alertcolor
	end
	DataText = countcolor ..string.format(" %.0f ", cObj.QoH) .."|r" .." " ..cObj.item

	return DataText

end


local function Refresh(cObj, pAlert)
-- find current QoH; chime or sound bell if appropriate

	if not pAlert then pAlert = false; end

	local NewQuantity
	local newText

	if cObj.QoH == nil then
		cObj.QoH = 0
		pAlert = false
	end

	NewQuantity = GetItemCount(cObj.item)
	DeltaQ = NewQuantity - cObj.QoH
	if DeltaQ == 0 then return end
	debugSay("DeltaQ: " .. DeltaQ .. "; NewQuantity: " .. NewQuantity)

	if cObj.Goal > NewQuantity then
		debugSay("NewQuantity: " .. NewQuantity .."; Goal: " .. cObj.Goal)
		cObj.Alerted = false
	end

	if pAlert and DeltaQ > 0 then -- INCREASED

		debugSay("Alerting/Chiming - NewQuantity = " .. tonumber(NewQuantity) ..", Goal = "
			.. tonumber(cObj.Goal) ..", already Alerted = " .. YesNo(cObj.Alerted))

		if cObj.QoH < cObj.Goal and NewQuantity >= cObj.Goal then
			if cObj.Alerted == false then
				-- if previous QoH was below goal and new qty is over goal then Sound Alert
				-- UNLESS it's already been sounded, e.g. cascade of BAG_UPDATE events
				-- play BellSound, Show Goal Met Text
				if not cObj.Silent then PlaySound(Bells[cObj.BellSound]); end
				cTxt = L["Item Count Goal Attained"] .. ": " .. cObj.item .. " = " .. NewQuantity
				if GetCVarBool("enableFloatingCombatText") == true then
					CombatText_AddMessage(cTxt, CombatText_StandardScroll, 0.9, 0.2, 0.5, "crit", true)
				end
				cObj.Alerted = true
			end
		else
			-- play Chime, Show Got Qty Text
			cTxt = "+" ..tostring(DeltaQ) .." ".. cObj.item
			if cObj.Chime then PlaySound(ChimeSound,"SFX"); end
			if GetCVarBool("enableFloatingCombatText") == true then
				CombatText_AddMessage(cTxt, CombatText_StandardScroll, 2, 2, 1, "sticky", true)
			end
			--0.9, 0.2, 0.5, "sticky", true)
		end
		print(C_GREEN .. "ItemCount: " .. C_YELLOW .. cTxt ..C_WHITE)

	end

	cObj.QoH = NewQuantity

end


local function OnEvent(self, event, ...)
	if self == nil then
		print(L["OnEventSelfError"])
		return
	end

	if not IC.initialized then
		IC:OnInitialize()
	end

	debugSay(event)

	if event == "BAG_UPDATE_DELAYED" then
		debugSay(C_YELLOW.."Refresh - OnEvent("..YesNo(okToAlert)..")")

		-- true = Alert or Chime if appropriate
		Refresh(Count1, okToAlert)
		Refresh(Count2, okToAlert)
		Refresh(Count3, okToAlert)
		Refresh(Count4, okToAlert)
		Refresh(Count5, okToAlert)

		if not okToAlert then okToAlert = true; end

	end

	if pf.watched == 1 then ButtonText = getText(Count1)
	elseif pf.watched == 2 then ButtonText = getText(Count2)
	elseif pf.watched == 3 then ButtonText = getText(Count3)
	elseif pf.watched == 4 then ButtonText = getText(Count4)
	elseif pf.watched == 5 then ButtonText = getText(Count5)
	end

	self.text:SetFormattedText(displayString, ButtonText, -1)

	lastPanel = self

end


local function newButtonText()

	debugSay("Refresh - newButtonText()")

	Refresh(Count1, false)
	Refresh(Count2, false)
	Refresh(Count3, false)
	Refresh(Count4, false)
	Refresh(Count5, false)

	OnEvent(lastPanel)

end


local function doToolTip(cObj)

	local chimestr = "Chime "..C_RED.."OFF"
	local silentstr = "Silent "..C_RED.."OFF"
	local sKey = C_AQUA.." "

	if not cObj or not cObj.item then return; end
	if not cObj.QoH then cObj.QoH = 0 end
	if not cObj.Goal then cObj.Goal = 0 end

	if cObj.Chime == true then chimestr = "Chime "..C_GREEN.."ON"; end
	if cObj.Silent == true then silentstr = "Silent "..C_GREEN.."ON"; end

	if cObj.frozen == true then sKey = sKey.."F"; end
	if pf.watched == cObj.index then sKey = sKey.."W"; end
	if cObj.QoH >= cObj.Goal and cObj.Goal > 0 then sKey = sKey.."#" end

	DT.tooltip:AddDoubleLine(tostring(cObj.index)..". " ..cObj.item..sKey, 
		C_YELLOW.."QoH "..string.format("%.0f", cObj.QoH), 1, 1, 1, 0.8, 0.8, 0.8)
	DT.tooltip:AddDoubleLine(" "..C_WHITE..cObj.BellSound, 
		C_YELLOW.."Goal "..C_WHITE..tostring(cObj.Goal), 1, 1, 1, 0.8, 0.8, 0.8)

	DT.tooltip:AddDoubleLine("  "..C_WHITE..chimestr, C_WHITE..silentstr, 1, 1, 1, 0.8, 0.8, 0.8)
	DT.tooltip:AddLine(" ")

end


local function OnEnter(IC)
-- Show DataText Dropdown

	DT:SetupTooltip(IC)
	enteredFrame = true

	-- Header
	DT.tooltip:AddLine((L["%sElvUI|r ItemCount"].." ".. L["version"].." "..Version):format(hexColor), 1, 1, 1)
	DT.tooltip:AddLine(" ")

	doToolTip(Count1)
	doToolTip(Count2)
	doToolTip(Count3)
	doToolTip(Count4)
	doToolTip(Count5)

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddLine(L["Left-Click datatext: configuration"])
	DT.tooltip:AddLine(L["RightClick datatext: menu"])
	DT.tooltip:AddLine(L["Alt-RightClick inventory: change item"])

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddLine("KEY: ".. C_AQUA.."F=frozen  W=watched  #=goal met")

	DT.tooltip:Show()

end


local function OnUpdate(IC)
-- DO NOT PUT ANYTHING HERE that you don't want to run every millisecond
	if not dtframe then dtframe = IC end
end


local function Open_IC_Options()
	E:ToggleOptions() --E:ToggleOptionsUI()
	local ACD = E.Libs.AceConfigDialog
	if ACD then ACD:SelectGroup('ElvUI', "itemcount"); end
end


local function getProfileList(db, nocurrent)
	-- clear old profile table
	local profiles = {}

	-- copy existing profiles into the table
	local curr = db.keys.profile
	for i,v in pairs(db:GetProfiles(tmpprofiles)) do 
		if not (nocurrent and v == curr) then profiles[v] = v end 
	end

	return profiles
end


local function InitDB()

	db = ADB:New("ItemCountDB", defaults, true)
	db.RegisterCallback(IC, "OnProfileChanged", "RefreshConfig")
	db.RegisterCallback(IC, "OnProfileCopied", "RefreshConfig")
	db.RegisterCallback(IC, "OnProfileReset", "RefreshConfig")

	pf = db.profile

	Count1 = pf.count1
	Count2 = pf.count2
	Count3 = pf.count3
	Count4 = pf.count4
	Count5 = pf.count5

end


function IC:RefreshConfig(event, database, newProfileKey)
	-- would do some stuff here
	debugSay("Pattern Set changed to "..newProfileKey.." - Event = "..event)

	pf = database.profile

	if not pf.count1 then
		SetDefaults(pf)
	end

end


local function setItem(cObj, pItem)

	cObj.item = pItem
	Refresh(cObj)
	debugSay(C_WHITE.." Item for Counter #"..tostring(cObj.index)
		.. " set to " .. pItem)
	newButtonText()

end


local function ConfigIsActive()

	return false

end

--[[

-- disable alt-right-click until further notice - blizz func changed to a Mixin

--function IC:ContainerFrameItemButton_OnModifiedClick(...)
function BagOnClick(...)
	-- Alt-Right-Click
	local newItem

	debugSay("OnModifiedClick(): AltKey="..YesNo(IsAltKeyDown()))

	if ConfigIsActive() then return 0 end

	if select(2,...) and IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown()and not CursorHasItem() then

		bagID, slot = (...):GetParent():GetID(), (...):GetID()
		texture, itemCount, locked, quality, readable, lootable, itemLink = 
			GetContainerItemInfo(bagID, slot);

		newItem = tostring(itemLink)

		debugSay("newItem: "..newItem)

		if Count1.item == newItem or Count2.item == newItem or Count3.item == newItem
		or Count4.item == newItem or Count5.item == newItem then
--			print("Item Count ERROR: You are already counting "..newItem)
			E:StaticPopup_Show('AlreadyCounting', '', '')
			return
		end

		if Count1.frozen == false then setItem(Count1, newItem)
		elseif Count2.frozen == false then setItem(Count2, newItem)
		elseif Count3.frozen == false then setItem(Count3, newItem)
		elseif Count4.frozen == false then setItem(Count4, newItem)
		elseif Count5.frozen == false then setItem(Count5, newItem)
		else
			E:StaticPopup_Show('AllFrozen', '', '')
		end

	end

	if select(2,...) and IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown()and not CursorHasItem() then
		newButtonText()
	end

end



function IC:OnEnable()
	-- Usage: Hook([object], method, [handler], [hookSecure])

	-- disable alt-click feature for now, until we can debug
	IC:Hook(ContainerFrameItemButtonMixin, "OnClick", BagOnClick, true)

end
]]--


local function SetDefaults(obj)

	shallowcopy(obj, defaults)
	shallowcopy(obj.count1, defaults.count1)
	shallowcopy(obj.count2, defaults.count2)
	shallowcopy(obj.count3, defaults.count3)
	shallowcopy(obj.count4, defaults.count4)
	shallowcopy(obj.count5, defaults.count5)

end


local function MakeMenu()
	local tt = {}
	menu = wipe(menu)

	Refresh(Count1, false)
	Refresh(Count2, false)
	Refresh(Count3, false)
	Refresh(Count4, false)
	Refresh(Count5, false)

	local debugmenu = ""
	if AllowDebug then
		debugmenu = { text = C_GREEN..L["Debug"], checked = pf.Debug, isNotRadio = true, 
			keepShownOnClick = false,
			func = function() 
				checked = not checked
				pf.Debug = checked
			end, }
	end
	menu = {
		{ text = L["Item Count Options"], colorCode = C_YELLOW, isTitle = true, 
			isNotRadio = true, notCheckable = true, justifyH = "CENTER", },

		debugmenu,

		{ text = L["--- Item List ---"], isTitle = 0, 
			isNotRadio = true, notCheckable = true, justifyH = "CENTER", },
		{ text = L["Checked = Frozen"], isTitle = 0,
			isNotRadio = true, notCheckable = true, justifyH = "CENTER", },
		{ text = L["Left-click to freeze/unfreeze"], isTitle = 0,
			isNotRadio = true, notCheckable = true, justifyH = "CENTER", },

		{ text = Count1.item.." - "..tostring(Count1.Goal), colorCode = C_YELLOW,
			isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
			checked = Count1.frozen, keepShownOnClick = true,
			func = function() checked = not checked; Count1.frozen = checked; end,
			menuList = {
				{ text = " Change Goal", isNotRadio = true, notCheckable = true,
					func = function()
						E:StaticPopup_Show('GetGoalQty', Count1.item, tostring(Count1.Goal), Count1)
					end,
				},
			},
		},
		{ text = "  Watch This Item ^", isTitle = false, isNotRadio = false, notCheckable = false,
			checked = (pf.watched == 1), hasArrow = false, keepShownOnClick = false,
			leftPadding = 12,
			func = function() 
				pf.watched = 1; checked = true; --debugSay("Counting 1");
				newButtonText(); CloseDropDownMenus(1); --debugSay("OK 1");
			end, },
		{ text = "", isTitle = 1, isNotRadio = true, notCheckable = true },

		{ text = Count2.item.." - "..tostring(Count2.Goal), colorCode = C_YELLOW,
			isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
			checked = Count2.frozen, keepShownOnClick = true,
			func = function() checked = not checked; Count2.frozen = checked; end,
			menuList = {
				{ text = " Change Goal", isNotRadio = true, notCheckable = true,
					func = function()
						E:StaticPopup_Show('GetGoalQty', Count2.item, tostring(Count2.Goal), Count2)
					end,
				},
			},
		},
		{ text = "  Watch This Item ^", isTitle = false, isNotRadio = false, notCheckable = false,
			checked = (pf.watched == 2), hasArrow = false, keepShownOnClick = true,
			leftPadding = 12, 
			func = function()
				pf.watched = 2; checked = true; --debugSay("Counting 2"); 
				newButtonText(); CloseDropDownMenus(1); --debugSay("OK 2");
			end },
		{ text = "", isTitle = 1, isNotRadio = true, notCheckable = true },

		{ text = Count3.item.." - "..tostring(Count3.Goal), colorCode = C_YELLOW,
			isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
			checked = Count3.frozen, keepShownOnClick = true,
			func = function() checked = not checked; Count3.frozen = checked; end,
			menuList = {
				{ text = " Change Goal", isNotRadio = true, notCheckable = true,
					func = function()
						E:StaticPopup_Show('GetGoalQty', Count3.item, tostring(Count3.Goal), Count3)
					end,
				},
			},
		},
		{ text = "  Watch This Item ^", isTitle = false, isNotRadio = false, notCheckable = false,
			checked = (pf.watched == 3), hasArrow = false, keepShownOnClick = false,
			leftPadding = 12,
			func = function() 
				pf.watched = 3; checked = true; --debugSay("Counting 3"); 
				newButtonText(); CloseDropDownMenus(1); --debugSay("OK 3");
			end },
		{ text = "", isTitle = 1, isNotRadio = true, notCheckable = true },

		{ text = Count4.item.." - "..tostring(Count4.Goal), colorCode = C_YELLOW,
			isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
			checked = Count4.frozen, keepShownOnClick = true,
			func = function() checked = not checked; Count4.frozen = checked; end,
			menuList = {
				{ text = " Change Goal", isNotRadio = true, notCheckable = true,
					func = function()
						E:StaticPopup_Show('GetGoalQty', Count4.item, tostring(Count4.Goal), Count4)
					end,
				},
			},
		},
		{ text = "  Watch This Item ^", isTitle = false, isNotRadio = false, notCheckable = false,
			checked = (pf.watched == 4), hasArrow = false, keepShownOnClick = false,
			leftPadding = 12,
			func = function() 
				pf.watched = 4; checked = true; --debugSay("Counting 4"); 
				newButtonText(); CloseDropDownMenus(1); --debugSay("OK 4");
			end },
		{ text = "", isTitle = 1, isNotRadio = true, notCheckable = true },

		{ text = Count5.item.." - "..tostring(Count5.Goal), colorCode = C_YELLOW,
			isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
			checked = Count5.frozen, keepShownOnClick = true,
			func = function() checked = not checked; Count5.frozen = checked; end,
			menuList = {
				{ text = " Change Goal", isNotRadio = true, notCheckable = true,
					func = function()
						E:StaticPopup_Show('GetGoalQty', Count5.item, tostring(Count5.Goal), Count5)
					end,
				},
			},
		},
		{ text = "  Watch This Item ^", isTitle = false, isNotRadio = false, notCheckable = false,
			checked = (pf.watched == 5), hasArrow = false, keepShownOnClick = false,
			leftPadding = 12,
			func = function() 
				pf.watched = 5; checked = true; --debugSay("Counting 5");
				newButtonText(); CloseDropDownMenus(1); --debugSay("OK 5");
			end },


		{ text = "", isTitle = 1, isNotRadio = true, notCheckable = true },
		{ text = L["Close"], isNotRadio = true, notCheckable = true, colorCode = C_YELLOW,
			tooltipTitle = " ",
			tooltipText = L["Click here to close menu"], keepShownOnClick = false, 
			justifyH = "CENTER", },

	}

end


local function LoadDialogs()

	E.PopupDialogs['BadGoal'] = {
		text = L["You must enter an integer zero or higher"],
		button1 = OKAY,
		hasEditBox = false,
		sound = 137776,
		timeout = 1,
		whileDead = true,
		preferredIndex = 3,
		hideOnEscape = true,
		enterClicksFirstButton = true,
		exclusive = true,
	}

	E.PopupDialogs['AllFrozen'] = {
		text = "Item Count ERROR: there are no unfrozen Count slots",
		button1 = OKAY,
		hasEditBox = false,
		sound = 137776,
		timeout = 4,
		whileDead = true,
		preferredIndex = 3,
		hideOnEscape = true,
		enterClicksFirstButton = true,
		exclusive = true,
	}

	E.PopupDialogs['AlreadyCounting'] = {
		text = "Item Count ERROR: you are already counting that item",
		button1 = OKAY,
		sound = 137776,
		hasEditBox = false,
		timeout = 4,
		whileDead = true,
		preferredIndex = 3,
		hideOnEscape = true,
		enterClicksFirstButton = true,
		exclusive = true,
	}

	E.PopupDialogs['NowCounting'] = {
		text = C_YELLOW.."Item Count: now counting %s in slot #%s",
		button1 = OKAY,
		button2 = CANCEL,
		hasEditBox = false,
		sound = 137776,
		timeout = 4,
		whileDead = true,
		preferredIndex = 3,
		hideOnEscape = true,
		enterClicksFirstButton = true,
		exclusive = true
	}

	E.PopupDialogs['BadItem'] = {
		text = L["You must enter an item that exists in your bags"],
		button1 = OKAY,
		hasEditBox = false,
		timeout = 0,
		whileDead = true,
		preferredIndex = 3,
		hideOnEscape = true,
		exclusive = true,
	}

	E.PopupDialogs['GetGoalQty'] = {
		text = "Enter the desired goal quantity for %s",
		name = "dlgGetGoal",
		sound = 137776,
		button1 = OKAY,
		button2 = CANCEL,
		hasEditBox = true,
		EditBoxOnEscapePressed = function(self)
		   self:GetParent():Hide()
		end,
		OnShow = function(self)
		   edBox = getglobal(self:GetName().."EditBox")
		   edBox:SetNumeric(true)
		   edBox:SetText(tostring(self.data.Goal))
		   edBox:HighlightText()
		end,
		enterClicksFirstButton = true,
		OnAccept = function(self)
		   self.data.Goal = edBox:GetNumber()
		   newButtonText()
		end,
		timeout = 0,
		whileDead = true,
		preferredIndex = 3,
		hideOnEscape = true,
		enterClicksFirstButton = true,
		exclusive = true,
	}
end


local function OnClick(IC, btn)
-- OPEN Configuration Dialog

	DT.tooltip:Hide()
	if btn == "RightButton" then
		MakeMenu()
		EasyMenu(menu, menuFrame, "cursor", -10, -10, "MENU")

	elseif IsControlKeyDown() then
		newButtonText()

	else
		Open_IC_Options()

	end

end


function IC:OnInitialize()

	self.initialized = true

	if E.db.general.loginmessage then
		E:Delay(1, function () 
			print(C_WHITE.."Loading "..C_BLUE..IC:GetName()..C_WHITE.." version "..Version)
		end)
	end

	if not pf then
		pf = defaults.profile
		InitDB()
	end

	--set up Alert Bell arrays for convenience
	for k,v in pairs(Bells) do
		BellsLabel[ix] = k
		BellsIndex[k] = ix
		ix = ix + 1
	end

	LoadDialogs(IC)

	Refresh(Count1, false)
	Refresh(Count2, false)
	Refresh(Count3, false)
	Refresh(Count4, false)
	Refresh(Count5, false)

	ctLoaded, ctFinished = IsAddOnLoaded("Blizzard_CombatText")
	if not ctLoaded then
		UIParentLoadAddOn("Blizzard_CombatText")
	end

end



function ADB:OnEnable()
	print("ADB Enabled")
end


local function Slash_IC(msg, editbox)
	Open_IC_Options()
end
SLASH_IC1 = "/ic"
SLASH_IC2 = "/itemcount"
SlashCmdList['IC'] = Slash_IC


-- this is here so that the datatext button display will refresh
--[[
local function ValueColorUpdate(hex, r, g, b)   
	displayString = join("", hex, "%s|r")
	hexColor = hex
	if lastPanel then OnEvent(lastPanel) end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true
]]--

local function InjectOptions()

	if not pf then
		pf = defaults.profile
		InitDB()
	end

	local db_version = "alpha"
	if db.global.db_version then
		db_version = db.global.db_version
	end

	if not E.Options.args.itemcount then
		E.Options.args.itemcount = {
			order	= -2,
			type	= 'group',
			name	= 'Item Count',
			args	= {
				header = {
					type	= "header",
					name	= L["ItemCount"] .. C_GREEN ..' ' .. Version,
					order	= 20,
				},
				space0 = {
					type	= 'description',
					name	= "   ItemCount Database Version " .. db.global.db_version,
					order	= 40,
				},
				header2b = {
					type	= "header",
					name	= " [    General Options    ] ",
					order	= 50,
				},
				Debug = {
					type	= 'toggle',
					name	= L["Debug"],
					desc	= L["Print Debug messages"],
					get		= function() return pf.Debug end,
					set		= function(info, value)
						pf.Debug = value
					end,
					hidden	= not AllowDebug,
					order	= 90,
				},

		-- PATTERN SETS (profiles)
				header2 = {
					type	= 'header',
					name	= " [   Pattern Sets   ] ",
					order	= 300,
				},
				space5 = {
					type	= 'description',
					name	= "",
					order	= 310,
				},
				selectprofile = {
					name	= L["Select Pattern Set"],
					type	= "select",
					get		= function() return db:GetCurrentProfile() end,
					set		= function(info, value) db:SetProfile(value) end,
					values	= function() return getProfileList(db, false)   end,
					order	= 320,
				},
				copyprofile = {
					type	= 'select',
					style	= 'dropdown',
					desc	= L["This only copies ItemCount Pattern Sets, never any ElvUI configuration"],
					name	= L["Copy Pattern Set"],
					get		= function() return false end,
					set		= function(info, value) db:CopyProfile(value) end,
					values	= function() return getProfileList(db, true) end,
					order	= 340,
				},
				space6 = {
					type	= 'description',
					name	= "",
					order	= 350,
				},
				newprofile = {
					type	= 'input',
					name	= L["New Pattern Set"],
					get		= function() return false end,
					set		= function(info, value) db:SetProfile(value) end,
					order	= 360,
				},
				rmprofile = {
					type	= 'select',
					style	= 'dropdown',
					name	= L["Delete Pattern Set"],
					get		= function() return false end,
					set		= function(info, value) db:DeleteProfile(value) end,
					values	= function() return getProfileList(db, true) end,
					confirm	= true,
					confirmText= L["Are you sure you want to delete the selected pattern set?"],
					order	= 370,
				},

				-- ITEM LIST
				header3 = {
					type	= 'header',
					name	= " [   Counted Items   ] ",
					order	= 500,
				},


				-- ***********************   ITEM 1   ***************************
				item1group = {
					type	= 'group',
					name	= "Item 1",
					order	= 1100,
					args	= {
						item1 = {
							type	= 'input',
							name	= "Item",
							desc	= "Item to be counted",
							get		= function() return Count1.item end,
							set		= function(info, value)
								Count1.item = value
								newButtonText()
							end,
							order	= 1110,
						},			
						froz1 = {
							type	= 'toggle',
							name	= "Frozen",
							desc	= "Keep Item 1 from being overwritten",
							get		= function() return Count1.frozen end,
							set		= function(info, value)
								Count1.frozen = value
							end,
							order	= 1120,
						},
						goal1 = {
							type	= 'input',
							name	= "Goal Qty",
							desc	= "Goal Quantity",
							get		= function() return tostring(Count1.Goal) end,
							set		= function(info, value)
								Count1.Goal = tonumber(value)
								-- reset Count1.
							end,
							validate	= function(info, value)
								local tnum
								tnum = tonumber(value)
								if not tnum or tnum < 0 then
									 E:StaticPopup_Show('BadGoal', '', '')
									 return false
								end
								return true
							end,
							order	= 1130,
						},
						newline1 = {
							type	= 'description',
							name	= '',
							order	= 1140,
						},
						silent1		= {
							type	= 'toggle',
							name	= "Silent",
							desc	= L['Announce goal met for this item'],
							get		= function() return Count1.Silent end,
							set		= function(info, value)
								Count1.Silent = value
							end,
							order	= 1160,
						},
						chime1		= {
							type	= 'toggle',
							name	= "Chime",
							desc	= L['Chime on collection for this item'],
							get		= function() return Count1.Chime end,
							set		= function(info, value)
								Count1.Chime = value
							end,
							order	= 1170,
						},
						bellsound1 = {
							type	= 'select',
							name	= L["Alert Sound for meeting this goal"],
							style	= "dropdown",
							values	= BellsLabel,
							get		= function() return BellsIndex[Count1.BellSound] end,
							set		= function(info, value)
								Count1.BellSound = BellsLabel[value]
								PlaySound(Bells[BellsLabel[value]], "SFX")
							end,
							order	= 1180,
						},
						watch1 = {
							type	= 'execute',
							name	= L['Watch This Item'],
							func	= function() 
								pf.watched = 1
								newButtonText()
							end,
							order	= 1190,
						}, 
					},
				},


				-- ***********************   ITEM 2   ***************************
				item2group = {
					type	= 'group',
					name	= "Item 2",
					order	= 1200,
					args	= {
						item2 = {
							type	= 'input',
							name	= "Item",
							desc	= "Item to be counted",
							get		= function() return Count2.item end,
							set		= function(info, value)
								Count2.item = value
								newButtonText()
							end,
							order	= 1210,
						},			
						froz2 = {
							type	= 'toggle',
							name	= "Frozen",
							desc	= "Keep Item 2 from being overwritten",
							get		= function() return Count2.frozen end,
							set		= function(info, value)
								Count2.frozen = value
							end,
							order	= 1220,
						},
						goal2 = {
							type	= 'input',
							name	= "Goal Qty",
							desc	= "Goal Quantity",
							get		= function() return tostring(Count2.Goal) end,
							set		= function(info, value)
								Count2.Goal = tonumber(value)
							end,
							validate	= function(info, value)
								local tnum
								tnum = tonumber(value)
								if not tnum or tnum < 0 then
									 E:StaticPopup_Show('BadGoal', '', '')
									 return false
								end
								return true
							end,
							order	= 1230,
						},
						newline2 = {
							type	= 'description',
							name	= '',
							order	= 1240,
						},
						silent2 = {
							type	= 'toggle',
							name	= "Silent",
							desc	= L['Announce goal met for this item'],
							get		= function() return Count2.Silent end,
							set		= function(info, value)
								Count2.Silent = value
							end,
							order	= 1260,
						},
						chime2 = {
							type	= 'toggle',
							name	= "Chime",
							desc	= L['Chime on collection for this item'],
							get		= function() return Count2.Chime end,
							set		= function(info, value)
								Count2.Chime = value
							end,
							order	= 1270,
						},
						bellsound2 = {
							type	= 'select',
							name	= L["Alert Sound for meeting this goal"],
							style	= "dropdown",
							values	= BellsLabel,
							get		= function() return BellsIndex[Count2.BellSound] end,
							set		= function(info, value)
								Count2.BellSound = BellsLabel[value]
								PlaySound(Bells[BellsLabel[value]], "SFX")
							end,
							order	= 1280,
						},
						watch2 = {
							type	= 'execute',
							name	= L['Watch This Item'],
							func	= function() 
								pf.watched = 2
								newButtonText()
							end,
							order	= 1290,
						},
					},
				},


				-- ***********************   ITEM 3   ***************************
				item3group = {
					type	= 'group',
					name	= "Item 3",
					order	= 1300,
					args	= {
						item3 = {
							type	= 'input',
							name	= "Item",
							desc	= "Item to be counted",
							get		= function() return Count3.item end,
							set		= function(info, value)
								Count3.item = value
								newButtonText()
							end,
							order	= 1310,
						},			
						froz3 = {
							type	= 'toggle',
							name	= "Frozen",
							desc	= "Keep Item 3 from being overwritten",
							get		= function() return Count3.frozen end,
							set		= function(info, value)
								Count3.frozen = value
							end,
							order	= 1320,
						},
						goal3 = {
							type	= 'input',
							name	= "Goal Qty",
							desc	= "Goal Quantity",
							get		= function() return tostring(Count3.Goal) end,
							set		= function(info, value)
								Count3.Goal = tonumber(value)
							end,
							validate	= function(info, value)
								local tnum
								tnum = tonumber(value)
								if not tnum or tnum < 0 then
									 E:StaticPopup_Show('BadGoal', '', '')
									 return false
								end
								return true
							end,
							order	= 1330,
						},
						newline3 = {
							type	= 'description',
							name	= '',
							order	= 1340,
						},
						silent3 = {
							type	= 'toggle',
							name	= "Silent",
							desc	= L['Announce goal met for this item'],
							get		= function() return Count3.Silent end,
							set		= function(info, value)
								Count3.Silent = value
							end,
							order	= 1360,
						},
						chime3 = {
							type	= 'toggle',
							name	= "Chime",
							desc	= L['Chime on collection for this item'],
							get		= function() return Count3.Chime end,
							set		= function(info, value)
								Count3.Chime = value
							end,
							order	= 1370,
						},
						bellsound3 = {
							type	= 'select',
							name	= L["Alert Sound for meeting this goal"],
							style	= "dropdown",
							values	= BellsLabel,
							get		= function() return BellsIndex[Count3.BellSound] end,
							set		= function(info, value)
								Count3.BellSound = BellsLabel[value]
								PlaySound(Bells[BellsLabel[value]], "SFX")
							end,
							order	= 1380,
						},
						watch3 = {
							type	= 'execute',
							name	= L['Watch This Item'],
							func	= function() 
								pf.watched = 3
								newButtonText()
							end,
							order	= 1390,
						},
					},
				},


				-- ***********************   ITEM 4   ***************************
				item4group = {
					type	= 'group',
					name	= "Item 4",
					order	= 1400,
					args	= {
						item4 = {
							type	= 'input',
							name	= "Item",
							desc	= "Item to be counted",
							get		= function() return Count4.item end,
							set		= function(info, value)
								Count4.item = value
								newButtonText()
							end,
							order	= 1410,
						},			
						froz4 = {
							type	= 'toggle',
							name	= "Frozen",
							desc	= "Keep Item 4 from being overwritten",
							get		= function() return Count4.frozen end,
							set		= function(info, value)
								Count4.frozen = value
							end,
							order	= 1420,
						},
						goal4 = {
							type	= 'input',
							name	= "Goal Qty",
							desc	= "Goal Quantity",
							get		= function() return tostring(Count4.Goal) end,
							set		= function(info, value)
								Count4.Goal = tonumber(value)
							end,
							validate	= function(info, value)
								local tnum
								tnum = tonumber(value)
								if not tnum or tnum < 0 then
									 E:StaticPopup_Show('BadGoal', '', '')
									 return false
								end
								return true
							end,
							order	= 1430,
						},
						newline4 = {
							type	= 'description',
							name	= '',
							order	= 1440,
						},
						silent4 = {
							type	= 'toggle',
							name	= "Silent",
							desc	= L['Announce goal met for this item'],
							get		= function() return Count4.Silent end,
							set		= function(info, value)
								Count4.Silent = value
							end,
							order	= 1460,
						},
						chime4 = {
							type	= 'toggle',
							name	= "Chime",
							desc	= L['Chime on collection for this item'],
							get		= function() return Count4.Chime end,
							set		= function(info, value)
								Count4.Chime = value
							end,
							order	= 1470,
						},
						bellsound4 = {
							type	= 'select',
							name	= L["Alert Sound for meeting this goal"],
							style	= "dropdown",
							values	= BellsLabel,
							get		= function() return BellsIndex[Count4.BellSound] end,
							set		= function(info, value)
								Count4.BellSound = BellsLabel[value]
								PlaySound(Bells[BellsLabel[value]], "SFX")
							end,
							order	= 1480,
						},
						watch4 = {
							type	= 'execute',
							name	= L['Watch This Item'],
							func	= function() 
								pf.watched = 4
								newButtonText()
							end,
							order	= 1490,
						},
					},
				},


				-- ***********************   ITEM 5   ***************************
				item5group = {
					type	= 'group',
					name	= "Item 5",
					order	= 1500,
					args	= {
						item1 = {
							type	= 'input',
							name	= "Item",
							desc	= "Item to be counted",
							get		= function() return Count5.item end,
							set		= function(info, value)
								Count5.item = value
								newButtonText()
							end,
							order	= 1510,
						},			
						froz5 = {
							type	= 'toggle',
							name	= "Frozen",
							desc	= "Keep Item 5 from being overwritten",
							get		= function() return Count5.frozen end,
							set		= function(info, value)
								Count5.frozen = value
							end,
							order	= 1520,
						},
						goal5 = {
							type	= 'input',
							name	= "Goal Qty",
							desc	= "Goal Quantity",
							get		= function() return tostring(Count5.Goal) end,
							set		= function(info, value)
								Count5.Goal = tonumber(value)
							end,
							validate	= function(info, value)
								local tnum
								tnum = tonumber(value)
								if not tnum or tnum < 0 then
									 E:StaticPopup_Show('BadGoal', '', '')
									 return false
								end
								return true
							end,
							order	= 1530,
						},
						newline5 = {
							type	= 'description',
							name	= '',
							order	= 1540,
						},
						silent5		= {
							type	= 'toggle',
							name	= "Silent",
							desc	= L['Announce goal met for this item'],
							get		= function() return Count5.Silent end,
							set		= function(info, value)
								Count5.Silent = value
							end,
							order	= 1560,
						},
						chime5		= {
							type	= 'toggle',
							name	= "Chime",
							desc	= L['Chime on collection for this item'],
							get		= function() return Count5.Chime end,
							set		= function(info, value)
								Count5.Chime = value
							end,
							order	= 1570,
						},
						bellsound5 = {
							type	= 'select',
							name	= L["Alert Sound for meeting this goal"],
							style	= "dropdown",
							values	= BellsLabel,
							get		= function() return BellsIndex[Count5.BellSound] end,
							set		= function(info, value)
								Count5.BellSound = BellsLabel[value]
								PlaySound(Bells[BellsLabel[value]], "SFX")
							end,
							order	= 1580,
						},
						watch5 = {
							type	= 'execute',
							name	= L['Watch This Item'],
							func	= function() 
								pf.watched = 5
								newButtonText()
							end,
							order	= 1590,
						},

					},
				},
			},
		 }
	end

end
EP:RegisterPlugin(..., InjectOptions)

--[[
	DT:RegisterDatatext(name, category, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc, localizedName, objectEvent, colorUpdate)	

	name - name of the datatext (required)
	category - menu category
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]--

local function ValueColorUpdate(self, hex)
	--displayString = strjoin('', '%s', hex, '%d|r')
	displayString = join("", hex, "%s|r")
	OnEvent(self)
end



DT:RegisterDatatext('ItemCount', 'Miscellaneous', {"PLAYER_ENTERING_WORLD","BAG_UPDATE_DELAYED"}, OnEvent, OnUpdate, OnClick, OnEnter, OnLeave, 'Item Count', nil, ValueColorUpdate)
