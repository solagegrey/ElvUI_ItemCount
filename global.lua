--[[

						ElvUI ItemCount
						Solage of Greymane


]]--

-- Addon Objects

E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
IC = E:NewModule('ElvUI Item Count', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')
DT = E:GetModule('DataTexts')
EP = LibStub("LibElvUIPlugin-1.0")
ADB = LibStub("AceDB-3.0")

-- Color Constants

hexColor = "|cff00ff96"
C_YELLOW = "|cffffff00"
C_GREEN  = "|cff00ff00"
C_WHITE  = "|cffffffff"
C_RED    = "|cffff4f8b"
C_TURQ   = "|cff22ee55"
C_AQUA   = "|cff44eeaa" --22ee77"
C_MGNTA  = "|cffff0088"
C_PURPLE = "|cffEE22aa"
C_BROWN  = "|cfff4a460"
C_BLUE   = "|cff4fa8e3"


-- Functions

function shallowcopy(orig)
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

function YesNo(boolarg)
	if boolarg then
		return L["Yes"]
	else
		return L["No"]
	end
end

function debugSay(pTxt)
	if AllowDebug and pf.Debug then
		print(C_MGNTA.."ItemCount: " ..C_YELLOW..pTxt)
	end
end

