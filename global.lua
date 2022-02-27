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

