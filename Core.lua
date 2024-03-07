--print("Thank you for contracting [ CORAL FEVER ] " .. UnitName("player") .. "!")
LoadAddOn("MyLittleSharko_Assets_Scripts_dialogue")

local addonName, addonTable = ...

function addonTable.OnLoad(self)
  LoadAddOn("MyAddonMinimapButton")
end
  --Initilzed DM3
  local myCreatureFrame = CreateFrame("Frame", "MyCreatureFrame", UIParent)
  myCreatureFrame:SetSize(150,150)
  myCreatureFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -75, 5)

  local idleSprites = {
    "Interface\\AddOns\\MyLittleSharko\\Assets\\closedMouthResize.tga",
    "Interface\\AddOns\\MyLittleSharko\\Assets\\closedMouthSquish.tga",
  }

  local talkingSprites = {
    "Interface\\AddOns\\MyLittleSharko\\Assets\\closedMouthResize.tga",
    "Interface\\AddOns\\MyLittleSharko\\Assets\\openMouthSquish2.tga",
}

local MyAddonSettingsFrame = CreateFrame("Frame", "MyLittleSharkoSettingsFrame", InterfaceOptionsFramePanelContainer)
MyAddonSettingsFrame.name = "MyLittleSharko"
InterfaceOptions_AddCategory(MyAddonSettingsFrame)

--[[
local MyAddonButton = CreateFrame("Button", "MyAddonButton", Minimap)
MyAddonButton:SetSize(32, 32)
MyAddonButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0) -- Adjust the position as needed

-- Set a circular texture for the bubble appearance
MyAddonButton:SetNormalTexture("Interface\\AddOns\\MyLittleSharko\\Assets\\closedMouthResize.tga")

MyAddonButton:RegisterForClicks("AnyUp") -- Enable clicks

MyAddonButton:SetScript("OnClick", function(self, button, down)
    if button == "LeftButton" then
        -- Add your functionality here (e.g., open settings, toggle a frame, etc.)
        print("Left button clicked!")
    elseif button == "RightButton" then
        -- Add different functionality for right-click if needed
        print("Right button clicked!")
    end
end)

-- Tooltip
MyAddonButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("MyAddon", 1, 1, 1)
    GameTooltip:AddLine("Click to open settings", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

MyAddonButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)
--]]

local currentIdleIndex = 1
local currentTalkingIndex = 1
local idleTimer
local talkingTimer


local function UpdateSpriteTexture(texture, spriteTable, currentIndex)
  texture:SetTexture(spriteTable[currentIndex])
end

local function SwitchIdleSprites()
  currentIdleIndex = currentIdleIndex % #idleSprites + 1
  UpdateSpriteTexture(myCreatureFrame.myCreatureTexture, idleSprites, currentIdleIndex)
end

local function SwitchTalkingSprites()
  currentTalkingIndex = currentTalkingIndex % #talkingSprites + 1
  UpdateSpriteTexture(myCreatureFrame.myCreatureTexture, talkingSprites, currentTalkingIndex)  
end

local function StartIdleAnimation()
  idleTimer = C_Timer.NewTicker(1, SwitchIdleSprites)
end

local function StartTalkingAnimation()
  talkingTimer = C_Timer.NewTicker(1, SwitchTalkingSprites)
end

local function StopAnimations()
  if idleTimer then
      idleTimer:Cancel()
  end
  if talkingTimer then
      talkingTimer:Cancel()
  end
end

--Puts DM3 on the frame
myCreatureFrame.myCreatureTexture = myCreatureFrame:CreateTexture("MyCreatureTexture", "BACKGROUND")
myCreatureFrame.myCreatureTexture:SetAllPoints(myCreatureFrame)
myCreatureFrame.myCreatureTexture:SetTexture(idleSprites[currentIdleIndex])
myCreatureFrame.myCreatureTexture:SetBlendMode("BLEND")

  --Create DM3 on Startup
  myCreatureFrame:RegisterEvent("PLAYER_LOGIN")
myCreatureFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        myCreatureFrame:Show() -- Show the frame when the player logs in
    end
end)

--Create Speech Bubble
local speechBubbleFrame = CreateFrame("Frame", "SpeechBubbleFrame", UIParent)
speechBubbleFrame:SetSize(250, 200)
speechBubbleFrame:SetPoint("BOTTOM", myCreatureFrame, "TOP", -180, -70)
speechBubbleFrame:Hide()

--Texture Speech Bubble
local speechBubbleTexture = speechBubbleFrame:CreateTexture("MyAddonImageTexture", "BACKGROUND")
speechBubbleTexture:SetAllPoints(speechBubbleFrame) --texture covers all of frame
speechBubbleTexture:SetTexture("Interface\\AddOns\\MyLittleSharko\\Assets\\quoteBox512.tga")
speechBubbleTexture:SetBlendMode("BLEND")

--Create Speech Bubble Text
local speechText = speechBubbleFrame:CreateFontString("SpeechText", "ARTWORK", "GameFontNormal")
speechText:SetWidth(speechBubbleFrame:GetWidth()-8)
speechText:SetPoint("CENTER", speechBubbleFrame, "CENTER", 0, 14)
speechText:SetTextColor(0, 0, 0)
speechText:SetFont("Fonts\\FRIZQT__.TTF", 14) --font size

-- Enable word wrapping
speechText:SetWordWrap(true)
speechText:SetJustifyH("CENTER") -- Center the text within the width

local talkTimer = nil -- Variable to hold the timer reference

local function UpdateSpeechText(newText)
  speechText:SetText(newText)
end

local function ToggleSpeechBubble(show)
  if show then
      speechBubbleFrame:Show()
  else
      speechBubbleFrame:Hide()
  end
end

local function MakeCreatureTalk()
  newText = ""
  randomDialogue = dialogue()
  newText = randomDialogue
  UpdateSpeechText(newText)
  StopAnimations()
  StartTalkingAnimation()
  local startSound = "Interface\\AddOns\\MyLittleSharko\\Assets\\talkLouder.ogg"
  PlaySoundFile(startSound, "Master")
  -- Show the speech bubble
  ToggleSpeechBubble(true)
  

  -- Schedule a timer to hide the speech bubble after 10 seconds
  C_Timer.After(10, function()
      ToggleSpeechBubble(false)
      local finishSound = "Interface\\AddOns\\MyLittleSharko\\Assets\\finishLouder.ogg"
      PlaySoundFile(finishSound, "Master")
      StopAnimations()
      StartIdleAnimation()
  end)
  talkTimer = C_Timer.NewTimer(45, MakeCreatureTalk)
end

local function Welcome()
  newText = "Thank you for contracting [CORAL FEVER]! I'm your new personal assistant, Destroyman III. I'll be giving you helpful tips and tricks!"
  UpdateSpeechText(newText)
  --StartTalkingAnimation()
  -- Show the speech bubble
  ToggleSpeechBubble(true)

  -- Schedule a timer to hide the speech bubble after 10 seconds
  C_Timer.After(10, function()
      ToggleSpeechBubble(false)
  end)
  talkTimer = C_Timer.NewTimer(45, MakeCreatureTalk)
  StopAnimations()
  StartIdleAnimation()
end

-- Function to make the DM3 talk on command
local function TalkCommandHandler()
  -- If there's an existing timer, cancel it
  if talkTimer then
      talkTimer:Cancel()
  end

  -- Make DM3 talk immediately
  MakeCreatureTalk()
end

-- Register the slash command
SLASH_MYADDON_TALK1 = "/telljoke"
SlashCmdList["MYADDON_TALK"] = TalkCommandHandler

SLASH_MYLITTLESHARKO1 = "/mls"
SlashCmdList["MYLITTLESHARKO"] = function()
  InterfaceOptionsFrame_OpenToCategory("MyLittleSharko")
end

-- Schedule the initial talk

myCreatureFrame:RegisterEvent("ADDON_LOADED")
myCreatureFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "MyLittleSharko" then
        StartTalkingAnimation() --THIS WONT FUCKING WORK, HE REFUSES TO FUCKING TALK WHEN YOU OPEN THE GAME
        startTimer = C_Timer.NewTimer(10, Welcome)
        addonTable.OnLoad(self)
    end
end)