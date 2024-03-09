--print("Thank you for contracting [ CORAL FEVER ] " .. UnitName("player") .. "!")
LoadAddOn("MyLittleSharko_Assets_Scripts_dialogue")

muteVolume = false
sharkoVisible = true
local myFrame = CreateFrame("Frame")

-- Register for the PLAYER_DEAD event
myFrame:RegisterEvent("PLAYER_DEAD")

-- Load the settings


local addonName, addonTable = ...

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

local MuteAddonCheckbox = CreateFrame("CheckButton", "MuteAddonCheckbox", MyAddonSettingsFrame, "UICheckButtonTemplate")
MuteAddonCheckbox:SetPoint("TOPLEFT", 16, -16)
--MuteAddonCheckbox:GetFontString():SetText("Mute Sound")
--MuteAddonCheckbox.text:SetText("Mute Addon Volume")

MuteAddonCheckbox:SetScript("OnClick", function(self)
  local checked = self:GetChecked()
  -- Add your logic to mute or unmute the addon's volume
  if checked then
      -- Mute the volume
      muteVolume = true
      print("Addon volume muted")
  else
      -- Unmute the volume
      muteVolume = false
      print("Addon volume unmuted")
  end
end)

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
  if muteVolume == false then
    local startSound = "Interface\\AddOns\\MyLittleSharko\\Assets\\talkLouder.ogg"
    PlaySoundFile(startSound, "Master")
  end
  -- Show the speech bubble
  ToggleSpeechBubble(true)
  

  -- Schedule a timer to hide the speech bubble after 10 seconds
  C_Timer.After(10, function()
      ToggleSpeechBubble(false)
      if muteVolume == false then
        local finishSound = "Interface\\AddOns\\MyLittleSharko\\Assets\\finishLouder.ogg"
        PlaySoundFile(finishSound, "Master")
      end
      StopAnimations()
      StartIdleAnimation()
  end)
  talkTimer = C_Timer.NewTimer(55, MakeCreatureTalk)
  
end

local function Welcome()
  newText = "Thank you for contracting [CORAL FEVER]! I'm your new personal assistant, Destroyman III. I'll be giving you helpful tips and tricks!"
  UpdateSpeechText(newText)
  StopAnimations()
  StartTalkingAnimation()
  -- Show the speech bubble
  ToggleSpeechBubble(true)
  if muteVolume == false then
    local finishSound = "Interface\\AddOns\\MyLittleSharko\\Assets\\startupLouder.ogg"
    PlaySoundFile(finishSound, "Master")
  end

  -- Schedule a timer to hide the speech bubble after 10 seconds
  C_Timer.After(10, function()
      ToggleSpeechBubble(false)
      StopAnimations()
      StartIdleAnimation()
      if muteVolume == false then
        local finishSound = "Interface\\AddOns\\MyLittleSharko\\Assets\\finishLouder.ogg"
        PlaySoundFile(finishSound, "Master")
      end
  end)
  talkTimer = C_Timer.NewTimer(55, MakeCreatureTalk)
  
  
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

--[[
SLASH_MYLITTLESHARKO1 = "/mls"
SlashCmdList["MYLITTLESHARKO"] = function()
  InterfaceOptionsFrame_OpenToCategory("MyLittleSharko")
end
--]]

myFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_DEAD" then
    newText = ""
    randomDialogue = deathQuote()
    newText = randomDialogue
    talkTimer:Cancel()
    UpdateSpeechText(newText)
    StopAnimations()
    StartTalkingAnimation()
    if muteVolume == false then
      local startSound = "Interface\\AddOns\\MyLittleSharko\\Assets\\talkLouder.ogg"
      PlaySoundFile(startSound, "Master")
    end
    -- Show the speech bubble
    ToggleSpeechBubble(true)
    
  
    -- Schedule a timer to hide the speech bubble after 10 seconds
    C_Timer.After(10, function()
        ToggleSpeechBubble(false)
        if muteVolume == false then
          local finishSound = "Interface\\AddOns\\MyLittleSharko\\Assets\\finishLouder.ogg"
          PlaySoundFile(finishSound, "Master")
        end
        StopAnimations()
        StartIdleAnimation()
    end)
    talkTimer = C_Timer.NewTimer(55, MakeCreatureTalk)
    
  end
end)

SLASH_MYLITTLESHARKO_QUIET1 = "/mls"
SlashCmdList["MYLITTLESHARKO_QUIET"] = function(msg)
    if msg == "" or msg == "help" then
        print("My Little Sharko Commands:")
        print("/mls mute - Toggle Volume Mute")
        print("/mls toggle - Toggle Sharko")
        print("/mls joke - Force Sharko to tell youu a silly joke")
    elseif msg == "mute" then
        muteVolume = not muteVolume
        if muteVolume then
            print("Volume Muted")
        else
            print("Volume Unmuted")
        end
    elseif msg == "toggle" then
        myCreatureFrame:SetShown(not myCreatureFrame:IsShown())
        speechBubbleFrame:SetShown(myCreatureFrame:IsShown()) 
        sharkoVisible = not sharkoVisible
        --Disable timer when disabled
        if sharkoVisible == false then
          print("His free trial has Expired.")
          if talkTimer then
            talkTimer:Cancel()
          elseif startTimer then
            startTimer:Cancel()
          end

        else
          Welcome()
        end
        if sharkoVisible == true then
          print("RETURN OF THE KING")
        end
        --[[
      elseif msg == "telljoke" or msg == "joke" then
        TalkCommandHandler()
      end
      --]]
    else
        print("Invalid command. Type /mls or /mls help for a list of commands.")
    end
end

-- Schedule the initial talk

myCreatureFrame:RegisterEvent("ADDON_LOADED")
myCreatureFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "MyLittleSharko" then
        StartIdleAnimation()
        startTimer = C_Timer.NewTimer(10, Welcome)
    end
end)