local AllowDebug = false
local Version = "1.4.4"
--[[

                  ElvUI ItemCount
                  Solage of Greymane

                  v1.4.4

]]--

--------------- LIBRARIES ------------------

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local IC = E:NewModule('ItemCount', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')
local DT = E:GetModule('DataTexts')
local EP = LibStub("LibElvUIPlugin-1.0")
local ADB = LibStub("AceDB-3.0")
local IsAddonLoaded = IsAddonLoaded

IC.version = GetAddOnMetadata("ElvUI_ItemCount", "Version")

--------------- VARIABLES ------------------

local menuFrame = CreateFrame("Frame", "ItemCountMenu", E.UIParent, "UIDropDownMenuTemplate")

local Bells = {
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
-- it would be nice to be able to control the order of appearance in the dropdown
local ChimeSound = 5274 --AuctionOpen

local BellsIndex = {}
local BellsLabel = {}
local BellsList = {}
local isCurSound, CurColor
local edBox = {}
local ix = 0
local tt = {}
local menu = {}
local tmpprofiles = {}

local format = string.format
local join = string.join
local floor = math.floor
local wipe = table.wipe

local hexColor = "|cff00ff96"
local C_YELLOW = "|cffffff00"
local C_GREEN  = "|cff00ff00"
local C_WHITE  = "|cffffffff"
local C_RED    = "|cffff4f8b"
local C_TURQ   = "|cff22ee55"
local C_AQUA   = "|cff22ee77"
local C_MGNTA  = "|cffff0088"
local C_PURPLE = "|cffEE22aa"
local C_BROWN  = "|cfff4a460"
local C_BLUE   = "|cff4fa8e3"

local pfList
local enteredFrame = false
local lastPanel
local dtframe
local displayString = ""
local db, pf, curitem, p1, p2, p3, p4, p5

local QoHtext, countcolor, alertcolor
local QoH, prevQoH = 0, 0
local GoalIsMet = false
local AlreadyAlerted = false
local AddonIsInitialized = false
local RunBefore = false

local defaults = {
   profile = {
      id = "",
      text = "",
      ShowItem = true,
      Silent = false,
      Chime = true,
      curitem  = {
         Item = "Linen Cloth",
         Goal = 0,
         BellSound = "AllianceBell",
         frozen = false,
      },
      pattern1 = {
         Item = "Linen Cloth",
         Goal = 0,
         BellSound = "AllianceBell",
         frozen = false,
      },
      pattern2 = {
         Item = "Linen Cloth",
         Goal = 0,
         BellSound = "AllianceBell",
         frozen = false,
      },
      pattern3 = {
         Item = "Linen Cloth",
         Goal = 0,
         BellSound = "AllianceBell",
         frozen = false,
      },
      pattern4 = {
         Item = "Linen Cloth",
         Goal = 0,
         BellSound = "AllianceBell",
         frozen = false,
      },
      pattern5 = {
         Item = "Linen Cloth",
         Goal = 0,
         BellSound = "AllianceBell",
         frozen = false,
      },
   },
}


--------------- FUNCTIONS ------------------

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


local function CopyPattern(ptn1, ptn2)
   if ptn1.frozen then return end
   ptn1.Item = ptn2.Item
   ptn1.Goal = ptn2.Goal
   ptn1.BellSound = ptn2.BellSound
end


function ItemChanged(newitm)
   -- do nothing if the item isn't actually new
   if curitem.Item == newitm then return end
   if AllowDebug and pf.Debug then
      print(C_AQUA.. L["ElvUI ItemCount"].. ": " ..C_YELLOW.. "ItemChanged "
         ..C_WHITE.. "from " ..curitem.Item.. " to " ..newitm)
   end

   curitem.Item = newitm
   -- if this item is in the Pattern list, then recall its Pattern
   if p1.Item == newitm then
      if not pf.Silent then print(C_AQUA..L["ElvUI ItemCount"]..": "..
         C_YELLOW.."Recalling item Pattern for "..newitm) end
      CopyPattern(curitem, p1)
   elseif p2.Item == newitm then
      if not pf.Silent then print(C_AQUA..L["ElvUI ItemCount"]..": "..
         C_YELLOW.."Recalling item Pattern for "..newitm) end
      CopyPattern(curitem, p2)
   elseif p3.Item == newitm then
      if not pf.Silent then print(C_AQUA..L["ElvUI ItemCount"]..": "..
         C_YELLOW.."Recalling item Pattern for "..newitm) end
      CopyPattern(curitem, p3)
   elseif p4.Item == newitm then
      if not pf.Silent then print(C_AQUA..L["ElvUI ItemCount"]..": "..
         C_YELLOW.."Recalling item Pattern for "..newitm) end
      CopyPattern(curitem, p4)
   elseif p5.Item == newitm then
      if not pf.Silent then print(C_AQUA..L["ElvUI ItemCount"]..": "..
         C_YELLOW.."Recalling item Pattern for "..newitm) end
      CopyPattern(curitem, p5)
   else
      -- confirm replace; replace first unfrozen saved item with current
      if not p1.frozen then E:StaticPopup_Show('ConfirmReplace', newitm, p1.Item)
      elseif not p2.frozen then E:StaticPopup_Show('ConfirmReplace', newitm, p2.Item)
      elseif not p3.frozen then E:StaticPopup_Show('ConfirmReplace', newitm, p3.Item)
      elseif not p4.frozen then E:StaticPopup_Show('ConfirmReplace', newitm, p4.Item)
      elseif not p5.frozen then E:StaticPopup_Show('ConfirmReplace', newitm, p5.Item)
      elseif not pf.Silent then 
         print(C_AQUA..L["ElvUI ItemCount"]..": "..C_YELLOW
            ..L["NotSavingPattern"]..newitm)
      end
   end
end


function GoalChanged(newgoal)
   -- do nothing if the goal hasn't actually changed
   if tonumber(curitem.Goal) == newgoal then return end
   if AllowDebug and pf.Debug then
      print(C_AQUA..L["ElvUI ItemCount"]..": " ..C_YELLOW.. "GoalChanged "
         ..C_WHITE.."from "..tostring(curitem.Goal).." to "..tostring(newgoal))
   end

   curitem.Goal = newgoal   
   if p1.Item == curitem.Item and not p1.frozen then
      p1.Goal = newgoal
   elseif p2.Item == curitem.Item and not p2.frozen then
      p2.Goal = newgoal
   elseif p3.Item == curitem.Item and not p3.frozen then
      p3.Goal = newgoal
   elseif p4.Item == curitem.Item and not p4.frozen then
      p4.Goal = newgoal
   elseif p5.Item == curitem.Item and not p5.frozen then
      p5.Goal = newgoal
   end
end


function SoundChanged(newsound)
   -- do nothing if the sound hasn't actually changed
   if curitem.BellSound == newsound then return end
   if AllowDebug and pf.Debug then
      print(C_AQUA.. L["ElvUI ItemCount"].. ": " ..C_YELLOW.. "SoundChanged "..
         C_WHITE.. "from " ..curitem.BellSound.. " to " ..newsound)
   end
   curitem.BellSound = newsound

   if p1.Item == curitem.Item then
      if not p1.frozen then p1.BellSound = newsound end
   elseif p2.Item == curitem.Item then
      if not p2.frozen then p2.BellSound = newsound end
   elseif p3.Item == curitem.Item then
      if not p3.frozen then p3.BellSound = newsound end
   elseif p4.Item == curitem.Item then
      if not p4.frozen then p4.BellSound = newsound end
   elseif p5.Item == curitem.Item then
      if not p5.frozen then p5.BellSound = newsound end
   end
end


local function RefreshBellsList()
   local tt = {}

   if AllowDebug and pf.Debug then
      --print(C_AQUA.."RefreshBellsList")
   end

   BellsList = wipe(BellsList)
   for k,v in pairs(Bells) do
      isCurSound = (curitem.BellSound == k)
      CurColor = C_WHITE
      if isCurSound then CurColor = C_GREEN end
      tt = {
         text = k,
         value = k,
         arg1 = k,
         checked = isCurSound,
         colorCode = CurColor,
         isNotRadio = true,
         keepShowOnClick = true,
         func = function()
            if not (curitem.BellSound == k) then
               if not pf.Silent then
                  print(C_AQUA..L["ElvUI ItemCount"]..": " ..C_YELLOW.. L["alert sound is "]..C_WHITE..k)
               end
               colorCode = C_GREEN
               checked = true
               SoundChanged(k)
               curitem.BellSound = k
               RefreshBellsList()
            end
            PlaySound(Bells[curitem.BellSound], "Master")
         end,
      }
      table.insert(BellsList, tt)
   end
end


local function ShowFrozen(IsFrozen)
   if IsFrozen then
      return C_AQUA.."** "
   else
      return C_WHITE.."   "
   end
end


local function MakeMenu()
   local tt = {}
   menu = wipe(menu)

   RefreshBellsList()
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

      { text = L["Show Item Name"], colorCode = C_GREEN, checked = pf.ShowItem, notCheckable = false, 
         isNotRadio = true, keepShownOnClick = false, 
         func = function() 
            checked = not checked
            pf.ShowItem = checked 
         end, },

      { text = L["Chime on Qty Increase"], colorCode = C_GREEN, checked = pf.Chime, notCheckable = false, 
         isNotRadio = true, keepShownOnClick = false, 
         func = function() 
            checked = not checked
            pf.Chime = checked
         end, },

      { text = L["Silent"], colorCode = C_GREEN, checked = pf.Silent, notCheckable = false, 
         isNotRadio = true, keepShownOnClick = false, tooltipText = L["SilentTooltip"],
         func = function() 
            checked = not checked
            --ChimeChanged(checked)
            pf.Silent = checked
         end, },

      { text = L["Change Goal Quantity"].." ("..tostring(curitem.Goal)..")", isNotRadio = true, 
         notCheckable = true, keepShownOnClick = false, 
         func = function()
            E:StaticPopup_Show('GetGoalQty')
         end, },

      { text = L["Alert Sound"], colorCode = C_YELLOW, isTitle = false, 
         hasArrow = true, isNotRadio = true, 
         notCheckable = true, menuList = BellsList, keepShownOnClick = true, 
         justifyH = "RIGHT", },

      { text = L["--- Item List ---"], isTitle = 0, 
         isNotRadio = true, notCheckable = true, justifyH = "CENTER", },
      { text = L["Checked = Frozen"], isTitle = 0,
         isNotRadio = true, notCheckable = true, justifyH = "CENTER", },
      { text = L["Left-click to freeze/unfreeze"], isTitle = 0,
         isNotRadio = true, notCheckable = true, justifyH = "CENTER", },
      { text = "1. "..p1.Item.." - "..tostring(p1.Goal), colorCode = C_YELLOW, 
         isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
         checked = p1.frozen, keepShownOnClick = true,
         func = function() checked = not checked; p1.frozen = checked; end,
         menuList = {
            { text = L["Count This Item"], isNotRadio = true, notCheckable = true, 
               func = function() CopyPattern(curitem, p1); newButtonText(curitem.Item); end, }, },
      },
      { text = "2. "..p2.Item.." - "..tostring(p2.Goal), colorCode = C_YELLOW,
         isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
         checked = p2.frozen, keepShownOnClick = true,
         func = function() checked = not checked; p2.frozen = checked; end,
         menuList = {
            { text = L["Count This Item"], isNotRadio = true, notCheckable = true, 
               func = function() CopyPattern(curitem, p2); newButtonText(curitem.Item); end, },
         },
      },
      { text = "3. "..p3.Item.." - "..tostring(p3.Goal), colorCode = C_YELLOW, 
         isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
         checked = p3.frozen, keepShownOnClick = true,
         func = function() checked = not checked; p3.frozen = checked; end,
         menuList = {
            { text = L["Count This Item"], isNotRadio = true, notCheckable = true, 
               func = function() CopyPattern(curitem, p3); newButtonText(curitem.Item); end, },
         },
      },
      { text = "4. "..p4.Item.." - "..tostring(p4.Goal), colorCode = C_YELLOW, 
         isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
         checked = p4.frozen, keepShownOnClick = true,
         func = function() checked = not checked; p4.frozen = checked; end,
         menuList = {
            { text = L["Count This Item"], isNotRadio = true, notCheckable = true, 
               func = function() CopyPattern(curitem, p4); newButtonText(curitem.Item); end, },
         },
      },
      { text = "5. "..p5.Item.." - "..tostring(p5.Goal), colorCode = C_YELLOW, 
         isTitle = false, isNotRadio = true, notCheckable = false, hasArrow = true,
         checked = p5.frozen, keepShownOnClick = true,
         func = function() checked = not checked; p5.frozen = checked; end,
         menuList = {
            { text = L["Count This Item"], isNotRadio = true, notCheckable = true, 
               func = function() CopyPattern(curitem, p5); newButtonText(curitem.Item); end, },
         },
      },

      { text = L["Close"], isNotRadio = true, notCheckable = true, colorCode = C_YELLOW,
         tooltipTitle = " ",
         tooltipText = L["Click here to close menu"], keepShownOnClick = false, 
         justifyH = "CENTER", },
   }

end


local function OnEvent(self, event, ...)
   if self == nil then
      print(L["OnEventSelfError"])
      return
   end

   lastPanel = self
   if not pf then
      pf = defaults.profile
      InitDB()
   end

   if pf.id and pf.text then
      self.text:SetFormattedText(displayString, pf.text)
   end

   QoH = GetItemCount(curitem.Item)
   if not AddonIsInitialized then
      AddonIsInitialized = true
      prevQoH = QoH
      AlreadyAlerted = (QoH >= tonumber(curitem.Goal))
   end

   -- only update the button and alert if qty has changed
   if RunBefore and QoH == prevQoH then return end
   RunBefore = true

   if tonumber(curitem.Goal) > 0 then
     GoalIsMet = (QoH >= tonumber(curitem.Goal))
   else
     curitem.Goal = 0
     GoalIsMet = false
   end

   -- in case the quantity has gone down (sold, converted, turned in, whatever)
   if QoH < prevQoH and not GoalIsMet then AlreadyAlerted = false; end

   -- ding if quantity increased
   if event == "BAG_UPDATE" and pf.Chime and QoH > prevQoH and ((not GoalIsMet) or AlreadyAlerted) then
      NumGot = QoH - prevQoH
      cTxt = "+" ..tostring(NumGot) .." ".. curitem.Item
      --print(C_AQUA..L["ElvUI ItemCount"]..": " ..C_YELLOW.. "qty update - you now have "..curitem.Item..C_WHITE..string.format("x%.0f", QoH))
      --PlaySoundFile("Interface/AddOns/ElvUI_ItemCount/media/bell-01.ogg", "SFX")
	  PlaySound(ChimeSound,"SFX")
	  CombatText_AddMessage(cTxt, CombatText_StandardScroll, 0.9, 0.2, 0.5, "sticky", true)
   end

   prevQoH = QoH

   if GoalIsMet and event == "BAG_UPDATE" and not AlreadyAlerted then
      PlaySound(Bells[curitem.BellSound], "SFX")
      AlreadyAlerted = true
      cTxt = L["Item Count Goal Attainied"] .. "\r" .. curitem.Item .. " = " .. QoH
      CombatText_AddMessage(cTxt, CombatText_StandardScroll, 
            0.9, 0.2, 0.5, "crit", true)
      print(C_YELLOW .. cTxt .. C_WHITE)

   end

   countcolor = C_WHITE  -- default white
   alertcolor = C_MGNTA  -- alert redviolet?
   QoHtext = "-"
   if not QoH then
      QoH = 0
   end
   if tonumber(curitem.Goal) > 0 and GoalIsMet then
      countcolor = alertcolor
   end
   QoHtext = countcolor..string.format(" %.0f ", QoH).."|r"
   if pf.ShowItem == true then
      QoHtext = QoHtext..curitem.Item
   end

   pf.text = QoHtext
   self.text:SetFormattedText(displayString, QoHtext)

end


local function YesNo(boolarg)
   if boolarg then
      return L["Yes"]
   else
      return L["No"]
   end
end


local function OnEnter(self)
   DT:SetupTooltip(self)
   enteredFrame = true

   DT.tooltip:AddLine((L["%sElvUI|r ItemCount"].." "..L["version"].." "..IC.version):format(hexColor), 1, 1, 1)
   DT.tooltip:AddLine(" ")
   DT.tooltip:AddDoubleLine(C_YELLOW..L["Item"], C_WHITE..curitem.Item, 1, 1, 1, 0.8, 0.8, 0.8)
   DT.tooltip:AddDoubleLine(C_YELLOW..L["Qty in bags"], C_WHITE..string.format("%.0f", QoH), 1, 1, 1, 0.8, 0.8, 0.8)

   if tonumber(curitem.Goal) > 0 then
       DT.tooltip:AddDoubleLine(C_YELLOW..L["Goal quantity"], C_WHITE..tostring(curitem.Goal), 1, 1, 1, 0.8, 0.8, 0.8)
      if GoalIsMet then
         DT.tooltip:AddLine(C_PURPLE..L["GOAL QUANTITY ACHIEVED"])
      end
      DT.tooltip:AddDoubleLine(C_YELLOW..L["Alert Sound"], C_WHITE..curitem.BellSound, 1, 1, 1, 0.8, 0.8, 0.8)
   end

   DT.tooltip:AddDoubleLine(C_YELLOW..L["Chime"], C_WHITE..YesNo(pf.Chime), 1, 1, 1, 0.8, 0.8, 0.8)
   DT.tooltip:AddDoubleLine(C_YELLOW..L["Silent"], C_WHITE..YesNo(pf.Silent), 1, 1, 1, 0.8, 0.8, 0.8)

   if AllowDebug and pf.Debug then
      DT.tooltip:AddLine(" ")
      -- localization not necessary for debug messages
      DT.tooltip:AddDoubleLine(C_YELLOW.."GoalIsMet", C_WHITE..tostring(GoalIsMet))
      DT.tooltip:AddDoubleLine(C_YELLOW.."AlreadyAlerted", C_WHITE..tostring(AlreadyAlerted))
      DT.tooltip:AddDoubleLine(C_YELLOW.."prevQoH", C_WHITE..tostring(prevQoH))
   end

   DT.tooltip:AddLine(" ")
   DT.tooltip:AddDoubleLine(C_YELLOW..L[" - Item List - "], C_YELLOW..L["In Bags"], 1, 1, 1, 0.8, 0.8, 0.8)
   DT.tooltip:AddDoubleLine(C_WHITE.."1. "..ShowFrozen(p1.frozen)..p1.Item..
      C_WHITE.." ("..tostring(p1.Goal)..")", hexColor..tostring(GetItemCount(p1.Item)), 1, 1, 1, 0.8, 0.8, 0.8) 
   DT.tooltip:AddDoubleLine(C_WHITE.."2. "..ShowFrozen(p2.frozen)..p2.Item..
      C_WHITE.." ("..tostring(p2.Goal)..")", hexColor..tostring(GetItemCount(p2.Item)), 1, 1, 1, 0.8, 0.8, 0.8)
   DT.tooltip:AddDoubleLine(C_WHITE.."3. "..ShowFrozen(p3.frozen)..p3.Item..
      C_WHITE.." ("..tostring(p3.Goal)..")", hexColor..tostring(GetItemCount(p3.Item)), 1, 1, 1, 0.8, 0.8, 0.8)
   DT.tooltip:AddDoubleLine(C_WHITE.."4. "..ShowFrozen(p4.frozen)..p4.Item..
      C_WHITE.." ("..tostring(p4.Goal)..")", hexColor..tostring(GetItemCount(p4.Item)), 1, 1, 1, 0.8, 0.8, 0.8)
   DT.tooltip:AddDoubleLine(C_WHITE.."5. "..ShowFrozen(p5.frozen)..p5.Item..
      C_WHITE.." ("..tostring(p5.Goal)..")", hexColor..tostring(GetItemCount(p5.Item)), 1, 1, 1, 0.8, 0.8, 0.8)

   DT.tooltip:AddLine(" ")
   DT.tooltip:AddLine(L["Left-Click datatext: configuration"])
   DT.tooltip:AddLine(L["RightClick datatext: menu"])
   DT.tooltip:AddLine(L["Alt-RightClick inventory: change item"])

   DT.tooltip:AddLine(" ")
   DT.tooltip:AddLine(L["** indicates a Frozen item - won't be overwritten"])
 
   DT.tooltip:Show()
end


local function OnUpdate(self)
   if not dtframe then dtframe = self end
end


function newButtonText(item)
   -- force refresh of datatext display
   if AllowDebug and pf.Debug then
      print(C_AQUA.. L["ElvUI ItemCount"]..": " ..C_YELLOW.. "newButtonText(\"" ..C_WHITE..item..C_YELLOW.. "\")")
   end
   curitem.Item = item
   prevQoH = -1
   OnEvent(lastPanel)
   if lastPanel ~= nil then
   end
end


local function PrintNewGoal(newgoal)
   if not pf.Silent then
      print(C_AQUA.. L["ElvUI ItemCount"]..": " ..C_YELLOW.. "New Goal Quantity = " ..C_WHITE..tostring(newgoal))
   end
end


local function Open_IC_Options()
   E:ToggleOptionsUI()
   local ACD = E.Libs.AceConfigDialog
   if ACD then ACD:SelectGroup('ElvUI', "itemcount") end
end


local function Click(self, btn)
-- OPEN Configuration Dialog

   DT.tooltip:Hide()
   if btn == "RightButton" then
      MakeMenu()
      EasyMenu(menu, menuFrame, "cursor", -10, -10, "MENU");
   else
      Open_IC_Options()
   end

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


local function InjectOptions()
   if not pf then
      pf = defaults.profile
      InitDB()
   end
   if not E.Options.args.itemcount then
      E.Options.args.itemcount = {
         order = -2,
         type = 'group',
         name = 'Item Count',
         args = {
            header = {
               type     = "header",
               name     = L["ItemCount"] .. C_GREEN ..' ' .. Version,
               order    = 20,
            },
            space0 = {
               type     = 'description',
               name     = '',
               order    = 40,
            },
            header2b = {
               type     = "header",
               name     = "       General Options       ",
               order    = 50,
            },
            ShowItem = {
               type     = 'toggle',
               name     = L["Show Item Name"],
               desc     = L["Show the item name in the datatext?"],
               get      = function() return pf.ShowItem end,
               set      = function(info, value)
                  pf.ShowItem = value
                  newButtonText(curitem.Item)
               end,
               order    = 60,
            },
            Chime = {
               type      = 'toggle',
               name      = L["Chime on Qty Increase"],
               desc      = L["Sound a bell when the watched item increases in quantity?"],
               get      = function() return pf.Chime end,
               set      = function(info, value)
                  pf.Chime = value
                  newButtonText(curitem.Item)
               end,
               order      = 70,
            },
            Silent = {
               type      = 'toggle',
               name      = L["Silent"],
               desc      = L["Don't announce everything, only what's important."],
               get      = function() return pf.Silent end,
               set      = function(info, value)
                  pf.Silent = value
                  newButtonText(curitem.Item)
               end,
               order      = 80,
            },
            Debug = {
               type      = 'toggle',
               name      = L["Debug"],
               desc      = L["Print Debug messages"],
               get      = function() return pf.Debug end,
               set      = function(info, value)
                  pf.Debug = value
                  newButtonText(curitem.Item)
               end,
               hidden   = not AllowDebug,
               order      = 90,
            },
            BellSound = {
               type     = 'select',
               name     = L["Alert Sound"],
               style    = "dropdown",
               values   = BellsLabel,
               set      = function(info, value)
                  SoundChanged(BellsLabel[value])
                  curitem.BellSound = BellsLabel[value]
                  PlaySound(Bells[curitem.BellSound], "SFX")
                  newButtonText(curitem.Item)
               end,
               get      = function() return BellsIndex[curitem.BellSound] end,
               order    = 100,
            },
            
            header2c = {
               type     = 'header',
               name     = L["Current Item"],
               order    = 200,
            },
            CurrentItem = {
               type     = 'input',
               name     = L["Item"],
               desc     = L["Inventory item to track quantity"],
               get      = function() return curitem.Item end,
               set      = function(info, value)
                  ItemChanged(value)
                  curitem.Item = value
                  QoH = GetItemCount(value)
                  AlreadyAlerted = (tonumber(curitem.Goal) <= QoH)
                  newButtonText(value)
               end,
               validate = function(info, value)
                  local tcount
                  tcount = GetItemCount(value)
                  if tcount < 1 then 
                     E:StaticPopup_Show('BadItem','','')
                     return false
                  end
                  return true
               end,
               usage    = L["Enter an item from your inventory - type the name, or drag from your bags, or Alt-RightClick on an item in your bags"],
               width    = full,
               order    = 210,
            },
            Goal = {
               type     = 'input',
               name     = L["Goal Quantity"],
               desc     = L["Enter zero to disable, positive integer for alert when qty reached"],
               get      = function() return tostring(curitem.Goal) end,
               set      = function(info, value)
                  GoalChanged(tonumber(value))
                  curitem.Goal = tonumber(value)
                  AlreadyAlerted = (tonumber(curitem.Goal) < QoH)
                  newButtonText(curitem.Item)
               end,
               validate = function(info, value)
                  local tnum
                  tnum = tonumber(value)
                  if not tnum or tnum < 0 then
                      E:StaticPopup_Show('BadGoal', '', '')
                      return false
                  end
                  return true
               end,
               usage    = L["Enter an integer zero or higher"],
               width    = full,
               order    = 220,
            },

      -- PATTERN SETS (profiles)
            header2 = {
               type      = 'header',
               name      = L["Pattern Sets"],
               order      = 300,
            },
            space5 = {
               type       = 'description',
               name      = "",
               order      = 310,
            },
            selectprofile = {
               name      = L["Select Pattern Set"],
               type       = "select",
               get       = function() return db:GetCurrentProfile() end,
               set       = function(info, value) db:SetProfile(value) end,
               values    = function() return getProfileList(db, false)   end,
               order      = 320,
            },
            copyprofile = {
               type      = 'select',
               style     = 'dropdown',
               desc      = L["This only copies ItemCount Pattern Sets, never any ElvUI configuration"],
               name      = L["Copy Pattern Set"],
               get       = function() return false end,
               set       = function(info, value) db:CopyProfile(value) end,
               values    = function() return getProfileList(db, true) end,
               order     = 340,
            },
            space6 = {
               type      = 'description',
               name      = "",
               order     = 350,
            },
            newprofile = {
               type      = 'input',
               name      = L["New Pattern Set"],
               get       = function() return false end,
               set       = function(info, value) db:SetProfile(value) end,
               order     = 360,
            },
            rmprofile = {
               type      = 'select',
               style     = 'dropdown',
               name      = L["Delete Pattern Set"],
               get       = function() return false end,
               set       = function(info, value) db:DeleteProfile(value) end,
               values    = function() return getProfileList(db, true) end,
               confirm   = true,
               confirmText = L["Are you sure you want to delete the selected pattern set?"],
               order     = 370,
            },

      -- ITEM LIST
            header3 = {
               type     = 'header',
               name     = "  Item List  ",
               order    = 500,
            },
            item1group = {
               type = 'group',
               name = "Item 1",
               order = 510,
               args = {
                  Item1 = {
                     type      = 'input',
                     name      = "Item",
                     get       = function() return p1.Item end,
                     set       = function(info, value)
                        p1.Item = value
                     end,
                     order    = 10,
                  },               
                  Lock1 = {
                     type     = 'toggle',
                     name     = "Freeze",
                     desc     = "Keep Item 1 from being overwritten",
                     get      = function() return p1.frozen end,
                     set      = function(info, value)
                        p1.frozen = value
                        newButtonText(curitem.Item)
                     end,
                     order     = 20,
                  },
                  Qty1 = {
                     type     = 'input',
                     name     = "Quantity",
                     get      = function() return tostring(p1.Goal) end,
                     set      = function(info, value)
                        p1.Goal = tonumber(value)
                     end,
                     validate = function(info, value)
                        local tnum
                        tnum = tonumber(value)
                        if not tnum or tnum < 0 then
                            E:StaticPopup_Show('BadGoal', '', '')
                            return false
                        end
                        return true
                     end,
                     order    = 30,
                  },
                  newline    = {
                     type    = 'description',
                     name    = '',
                     order   = 39,
                  },
                  count1 = {
                     type     = 'execute',
                     name     = L['Count This Item'],
                     func     = function() CopyPattern(curitem, p1); newButtonText(curitem.Item); end,
                     order    = 40,
                  },
               },
            },
            item2group = {
               type = 'group',
               name = "Item 2",
               order = 520,
               args = {
                  Item2 = {
                     type      = 'input',
                     name      = "Item",
                     get       = function() return p2.Item end,
                     set       = function(info, value)
                        p2.Item = value
                     end,
                     order    = 10,
                  },               
                  Lock2 = {
                     type     = 'toggle',
                     name     = "Freeze",
                     desc     = "Keep Item 2 from being overwritten",
                     get      = function() return p2.frozen end,
                     set      = function(info, value)
                        p2.frozen = value
                        newButtonText(curitem.Item)
                     end,
                     order     = 20,
                  },
                  Qty2 = {
                     type     = 'input',
                     name     = "Quantity",
                     get      = function() return tostring(p2.Goal) end,
                     set      = function(info, value)
                        p2.Goal = tonumber(value)
                     end,
                     validate = function(info, value)
                        local tnum
                        tnum = tonumber(value)
                        if not tnum or tnum < 0 then
                            E:StaticPopup_Show('BadGoal', '', '')
                            return false
                        end
                        return true
                     end,
                     order    = 30,
                  },
                  newline    = {
                     type    = 'description',
                     name    = '',
                     order   = 39,
                  },
                  count2 = {
                     type     = 'execute',
                     name     = L['Count This Item'],
                     func     = function() CopyPattern(curitem, p2); newButtonText(curitem.Item); end,
                     order    = 40,
                  },
               },
            },
            item3group = {
               type = 'group',
               name = "Item 3",
               order = 530,
               args = {
                  Item3 = {
                     type      = 'input',
                     name      = "Item",
                     get       = function() return p3.Item end,
                     set       = function(info, value)
                        p3.Item = value
                     end,
                     order    = 10,
                  },
                  Lock3 = {
                     type     = 'toggle',
                     name     = "Freeze",
                     desc     = "Keep Item 3 from being overwritten",
                     get      = function() return p3.frozen end,
                     set      = function(info, value)
                        p3.frozen = value
                        newButtonText(curitem.Item)
                     end,
                     order     = 20,
                  },
                  Qty3 = {
                     type     = 'input',
                     name     = "Quantity",
                     get      = function() return tostring(p3.Goal) end,
                     set      = function(info, value)
                        p3.Goal = tonumber(value)
                     end,
                     validate = function(info, value)
                        local tnum
                        tnum = tonumber(value)
                        if not tnum or tnum < 0 then
                            E:StaticPopup_Show('BadGoal', '', '')
                            return false
                        end
                        return true
                     end,
                     order    = 30,
                  },
                  newline    = {
                     type    = 'description',
                     name    = '',
                     order   = 39,
                  },
                  count3 = {
                     type     = 'execute',
                     name     = L['Count This Item'],
                     func     = function() CopyPattern(curitem, p3); newButtonText(curitem.Item); end,
                     order    = 40,
                  },
               },
            },
            item4group = {
               type = 'group',
               name = "Item 4",
               order = 540,
               args = {
                  Item4 = {
                     type      = 'input',
                     name      = "Item",
                     get       = function() return p4.Item end,
                     set       = function(info, value)
                        p4.Item = value
                     end,
                     order    = 10,
                  },               
                  Lock1 = {
                     type     = 'toggle',
                     name     = "Freeze",
                     desc     = "Keep Item 4 from being overwritten",
                     get      = function() return p4.frozen end,
                     set      = function(info, value)
                        p4.frozen = value
                        newButtonText(curitem.Item)
                     end,
                     order     = 20,
                  },
                  Qty4 = {
                     type     = 'input',
                     name     = "Quantity",
                     get      = function() return tostring(p4.Goal) end,
                     set      = function(info, value)
                        p4.Goal = tonumber(value)
                     end,
                     order    = 30,
                     validate = function(info, value)
                        local tnum
                        tnum = tonumber(value)
                        if not tnum or tnum < 0 then
                            E:StaticPopup_Show('BadGoal', '', '')
                            return false
                        end
                        return true
                     end,
                  },
                  newline    = {
                     type    = 'description',
                     name    = '',
                     order   = 39,
                  },
                  count4 = {
                     type     = 'execute',
                     name     = L['Count This Item'],
                     func     = function() CopyPattern(curitem, p4); newButtonText(curitem.Item); end,
                     order    = 40,
                  },
               },
            },
            item5group = {
               type = 'group',
               name = "Item 5",
               order = 550,
               args = {
                  Item5 = {
                     type      = 'input',
                     name      = "Item",
                     get       = function() return p5.Item end,
                     set       = function(info, value)
                        p5.Item = value
                     end,
                     order    = 10,
                  },               
                  Lock5 = {
                     type     = 'toggle',
                     name     = "Freeze",
                     desc     = "Keep Item 5 from being overwritten",
                     get      = function() return p5.frozen end,
                     set      = function(info, value)
                        p5.frozen = value
                        newButtonText(curitem.Item)
                     end,
                     order     = 20,
                  },
                  Qty5 = {
                     type     = 'input',
                     name     = "Quantity",
                     get      = function() return tostring(p5.Goal) end,
                     set      = function(info, value)
                        p5.Goal = tonumber(value)
                     end,
                     validate = function(info, value)
                        local tnum
                        tnum = tonumber(value)
                        if not tnum or tnum < 0 then
                            E:StaticPopup_Show('BadGoal', '', '')
                            return false
                        end
                        return true
                     end,
                     order    = 30,
                  },
                  newline    = {
                     type    = 'description',
                     name    = '',
                     order   = 39,
                  },
                  count5 = {
                     type     = 'execute',
                     name     = L['Count This Item'],
                     func     = function() CopyPattern(curitem, p5); newButtonText(curitem.Item); end,
                     order    = 40,
                  },
               },
            },

         },
       }
   end
end


local function LoadDialogs()
   E.PopupDialogs['BadGoal'] = {
      text = L["You must enter an integer zero or higher"],
      button1 = OKAY,
      hasEditBox = false,
      timeout = 0,
      whileDead = true,
      preferredIndex = 3,
      hideOnEscape = true,
      exclusive = true,
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
      text = L["Enter the desired quantity."],
      name = "dlgGetGoal",
      button1 = OKAY,
      button2 = CANCEL,
      hasEditBox = true,
      EditBoxOnEnterPressed = function(self)
         GoalChanged(self:GetNumber())
         newButtonText(curitem.Item)
         self:GetParent():Hide();
      end,
      EditBoxOnEscapePressed = function(self)
         self:GetParent():Hide();
      end,
      OnShow = function(self)
         edBox = getglobal(self:GetName().."EditBox")
         edBox:SetNumeric(true)
         edBox:SetText(tostring(curitem.Goal));
         edBox:HighlightText()
      end,
      OnAccept = function(self)
         GoalChanged(edBox:GetNumber())
         newButtonText(curitem.Item)
      end,
      timeout = 0,
      whileDead = true,
      preferredIndex = 3,
      hideOnEscape = true,
      enterClicksFirstButton = true,
      exclusive = true,
   }
   E.PopupDialogs['ConfirmReplace'] = {
      text = L["New counted item %s will also replace the first unfrozen Item Pattern (%s). Is this what you want?"],
      name = "dlgConfirmReplace",
      button1 = YES,
      button2 = NO,
      hasEditBox = false,
      OnShow = function(self)
         PlaySound(137776, "SFX")
      end,
      OnAccept = function(self)
         if not p1.frozen then CopyPattern(p1, curitem)
         elseif not p2.frozen then CopyPattern(p2, curitem)
         elseif not p3.frozen then CopyPattern(p3, curitem) 
         elseif not p4.frozen then CopyPattern(p4, curitem) 
         elseif not p5.frozen then CopyPattern(p5, curitem) 
         end
      end,
      OnCancel = function(self)
         --PlaySound(847, "SFX")
      end,
      timeout = 0,
      whileDead = true,
      preferredIndex = 3,
      hideOnEscape = true,
      enterClicksFirstButton = true,
      exclusive = true,
   }
   E.PopupDialogs['AllFrozen'] = {
      text = L["All Item Patterns are frozen; %s will be Counted, but without being stored in an Item Pattern."],
      name = "dlgAllFrozen",
      sound = "Whisper",
      button1 = OKAY,
      hasEditBox = false,
      timeout = 0,
      whileDead = true,
      preferredIndex = 3,
      hideOnEscape = true,
      enterClicksFirstButton = true,
      exclusive = true,
   }
   E.PopupDialogs['RecallingItem'] = {
      text = L["Retrieving pattern for %s."],
      button1 = OKAY,
      hasEditBox = false,
      timeout = 0,
      whileDead = true,
      preferredIndex = 3,
      hideOnEscape = true,
      exclusive = true,
   }
end


function InitDB()
   db = ADB:New("ItemCountDB", defaults, true)
   db.RegisterCallback(IC, "OnProfileChanged", "RefreshConfig")
   db.RegisterCallback(IC, "OnProfileCopied", "RefreshConfig")
   db.RegisterCallback(IC, "OnProfileReset", "RefreshConfig")

   pf = db.profile
   curitem = pf.curitem
   p1 = pf.pattern1
   p2 = pf.pattern2
   p3 = pf.pattern3
   p4 = pf.pattern4
   p5 = pf.pattern5
   
end


function SetDefaults(obj)
   shallowcopy(obj, defaults)
   shallowcopy(obj.curitem, defaults.curitem)
   shallowcopy(obj.pattern1, defaults.pattern1)
   shallowcopy(obj.pattern2, defaults.pattern2)
   shallowcopy(obj.pattern3, defaults.pattern3)
   shallowcopy(obj.pattern4, defaults.pattern4)
   shallowcopy(obj.pattern5, defaults.pattern5)
end


function IC:RefreshConfig(event, database, newProfileKey)
   -- would do some stuff here
   if pf.Debug and AllowDebug then
      print("Pattern Set changed to "..newProfileKey.." - Event = "..event)
   end

   pf = database.profile

   if not pf.Item then
      SetDefaults(pf)
   end

   curitem = pf.curitem
   p1 = pf.pattern1
   p2 = pf.pattern2
   p3 = pf.pattern3
   p4 = pf.pattern4
   p5 = pf.pattern5
 
   newButtonText(curitem.Item)

end


function IC:ContainerFrameItemButton_OnModifiedClick(...)
   -- Alt-Right-Click
   local newItem

   if select(2,...) == "RightButton" and IsAltKeyDown() and 
   not IsControlKeyDown() and not IsShiftKeyDown() and 
   not CursorHasItem() then

      bagID, slot = (...):GetParent():GetID(), (...):GetID()
      texture, itemCount, locked, quality, readable, lootable, itemLink = 
         GetContainerItemInfo(bagID, slot);

      newItem = tostring(itemLink)
      if newItem == curitem.Item then 
         return -- no need to do anything
      end

      ItemChanged(newItem)
      --curitem.Item = newItem

      QoH = itemCount --GetItemCount(itemLink)
      AlreadyAlerted = (tonumber(curitem.Goal) <= QoH)
      newButtonText(curitem.Item)

      if not pf.Silent then
         print(C_AQUA.. L["ElvUI ItemCount"]..":" .. C_YELLOW.. L[" now counting "] .. curitem.Item)
         print(C_AQUA.. L["ElvUI ItemCount"]..":" .. C_YELLOW.. L[" current qty "] ..C_WHITE.. tostring(QoH))
      end

   end
end


function IC:OnInitialize()
   if E.db.general.loginmessage then
      print(C_WHITE.."Loading "..C_BLUE..IC:GetName()..C_WHITE.." version "..Version)
   end

   --set up Alert Bell arrays for convenience
   for k,v in pairs(Bells) do
      BellsLabel[ix] = k
      BellsIndex[k] = ix
      ix = ix + 1
   end

   LoadDialogs()
   RunBefore = false  -- need to reset QoH

   ctLoaded, ctFinished = IsAddOnLoaded("Blizzard_CombatText")
   if not ctLoaded then
     --print(C_AQUA..L["ElvUI ItemCount"]..": " ..C_YELLOW.. "Loading Blizzard_CombatText")
     UIParentLoadAddOn("Blizzard_CombatText")
   end

end


function IC:OnEnable()
   self:Hook("ContainerFrameItemButton_OnModifiedClick", true)
end


function Slash_IC(msg, editbox)
   Open_IC_Options()
end
SLASH_IC1 = "/ic"
SLASH_IC2 = "/itemcount"
SlashCmdList['IC'] = Slash_IC


-- this is here so that the datatext button display will refresh
local function ValueColorUpdate(hex, r, g, b)   
   displayString = join("", hex, "%s|r")
   hexColor = hex
   if lastPanel ~= nil then
      OnEvent(lastPanel)
   end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

-- has to use '...' to avoid elvui_config version nil error.  No idea why this is so
EP:RegisterPlugin(..., InjectOptions)

--[[
   DT:RegisterDatatext(name, something, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)

   name - name of the datatext (required)
   something - new argument required by ElvUI now
   events - must be a table with string values of event names to register 
   eventFunc - function that gets fired when an event gets triggered
   updateFunc - onUpdate script target function
   click - function to fire when clicking the datatext
   onEnterFunc - function to fire OnEnter
   onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]--
DT:RegisterDatatext('ItemCount', nil, {"PLAYER_ENTERING_WORLD","BAG_UPDATE"}, OnEvent, OnUpdate, Click, OnEnter, OnLeave)
--E:RegisterModule('ItemCount')

