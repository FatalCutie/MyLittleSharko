--Initilzed DM3
myCreatureFrame = CreateFrame("Frame", "MyCreatureFrame", UIParent)
myCreatureFrame:SetSize(150,150)
myCreatureFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -75, 5)

idleSprites = {
  "Interface\\AddOns\\MyLittleSharko\\Assets\\closedMouthResize.tga",
  "Interface\\AddOns\\MyLittleSharko\\Assets\\closedMouthSquish.tga",
}

talkingSprites = {
  "Interface\\AddOns\\MyLittleSharko\\Assets\\closedMouthResize.tga",
  "Interface\\AddOns\\MyLittleSharko\\Assets\\openMouthSquish2.tga",
}

local currentIdleIndex = 1
local currentTalkingIndex = 1
local idleTimer
local talkingTimer


function UpdateSpriteTexture(texture, spriteTable, currentIndex)
  texture:SetTexture(spriteTable[currentIndex])
end

function SwitchIdleSprites()
  currentIdleIndex = currentIdleIndex % #idleSprites + 1
  UpdateSpriteTexture(myCreatureFrame.myCreatureTexture, idleSprites, currentIdleIndex)
end

function SwitchTalkingSprites()
  currentTalkingIndex = currentTalkingIndex % #talkingSprites + 1
  UpdateSpriteTexture(myCreatureFrame.myCreatureTexture, talkingSprites, currentTalkingIndex)  
end

function StartIdleAnimation()
  idleTimer = C_Timer.NewTicker(1, SwitchIdleSprites)
end

function StartTalkingAnimation()
  talkingTimer = C_Timer.NewTicker(1, SwitchTalkingSprites)
end

function StopAnimations()
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
speechBubbleFrame = CreateFrame("Frame", "SpeechBubbleFrame", UIParent)
speechBubbleFrame:SetSize(250, 200)
speechBubbleFrame:SetPoint("BOTTOM", myCreatureFrame, "TOP", -180, -70)
speechBubbleFrame:Hide()

--Texture Speech Bubble
speechBubbleTexture = speechBubbleFrame:CreateTexture("MyAddonImageTexture", "BACKGROUND")
speechBubbleTexture:SetAllPoints(speechBubbleFrame) --texture covers all of frame
speechBubbleTexture:SetTexture("Interface\\AddOns\\MyLittleSharko\\Assets\\quoteBox512.tga")
speechBubbleTexture:SetBlendMode("BLEND")

--Create Speech Bubble Text
speechText = speechBubbleFrame:CreateFontString("SpeechText", "ARTWORK", "GameFontNormal")
speechText:SetWidth(speechBubbleFrame:GetWidth()-8)
speechText:SetPoint("CENTER", speechBubbleFrame, "CENTER", 0, 14)
speechText:SetTextColor(0, 0, 0)
speechText:SetFont("Fonts\\FRIZQT__.TTF", 14) --font size

-- Enable word wrapping
speechText:SetWordWrap(true)
speechText:SetJustifyH("CENTER") -- Center the text within the width

talkTimer = nil -- Variable to hold the timer reference

function UpdateSpeechText(newText)
  speechText:SetText(newText)
end

function ToggleSpeechBubble(show)
  if show then
      speechBubbleFrame:Show()
  else
      speechBubbleFrame:Hide()
  end
end

myCreatureFrame:RegisterEvent("ADDON_LOADED")
myCreatureFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "MyLittleSharko" then
        StartTalkingAnimation() --THIS WONT FUCKING WORK, HE REFUSES TO FUCKING TALK WHEN YOU OPEN THE GAME
        startTimer = C_Timer.NewTimer(10, Welcome)
        --addonTable.OnLoad(self)
    end
end)