-- Core.lua for TBC Classic

local addonName, addonTable = ...
local addonVersion = GetAddOnMetadata(addonName, "Version") or "Unknown"
local speechTimer = nil
local sharkoVolume = 1.0
local sharkoScale = 1.0
local sharkoOffsetX = -75
local sharkoOffsetY = 5

local function CancelSpeechTimer()
    if speechTimer then
        speechTimer:Cancel()
        speechTimer = nil
    end
end

local function CancelJokeTicker()
    if SharkoTicker then
        SharkoTicker:Cancel()
        SharkoTicker = nil
    end
end

local muteVolume
local sharkoVisible
local slowerIdle

local state --false is idle true is taling
local isShiny = false
local isFunny = false
local mageDownCooldown = false

local lastSharkoQuote = nil
local lastChatType = "SAY"
local lastChannelNumber = nil

--volume wrapper
local function PlaySharkoSound(filename)
    if muteVolume then return end

    local oldVolume = GetCVar("Sound_SFXVolume")

    SetCVar("Sound_SFXVolume", sharkoVolume)
    PlaySoundFile("Interface\\AddOns\\MyLittleSharko\\Assets\\" .. filename, "SFX")

    -- Restore after a short delay
    C_Timer.After(1, function()
        SetCVar("Sound_SFXVolume", oldVolume)
    end)
end

-- Sprite tables
local idleSprites = {
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_sharko_1.tga",
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_sharko_2.tga",
}
local talkingSprites = {
    "Interface\\AddOns\\MyLittleSharko\\Assets\\talking_sharko_1.tga",
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_sharko_2.tga",
}

local shinyIdleSprites = {
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_shiny_1.tga",
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_shiny_2.tga",
}

local shinyTalkingSprites = {
    "Interface\\AddOns\\MyLittleSharko\\Assets\\talking_shiny_1.tga",
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_shiny_2.tga",
}

local chungusIdleSprites = {
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_chungus_1.tga",
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_chungus_2.tga",
}

local chungusTalkingSprites = {
    "Interface\\AddOns\\MyLittleSharko\\Assets\\talking_chungus_1.tga",
    "Interface\\AddOns\\MyLittleSharko\\Assets\\idle_chungus_2.tga",
}

local currentIdleIndex = 1
local currentTalkingIndex = 1
local idleTimer, talkingTimer

-- Shiny Handlers
local function GetIdleSpriteTable()
    if isFunny then
        return chungusIdleSprites
    elseif isShiny then
        return shinyIdleSprites
    else
        return idleSprites
    end
end

local function GetTalkingSpriteTable()
    if isFunny then
        return chungusTalkingSprites
    elseif isShiny then
        return shinyTalkingSprites
    else
        return talkingSprites
    end
end


-- Create main frame
-- Anchor container (never scales)
local sharkoAnchor = CreateFrame("Frame", "MyCreatureAnchor", UIParent)
sharkoAnchor:SetSize(1, 1)
sharkoAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", sharkoOffsetX, sharkoOffsetY)
local BASE_SHARKO_OFFSET_X = -75
local BASE_SHARKO_OFFSET_Y = 5

-- Actual Sharko frame (this one scales)
local myCreatureFrame = CreateFrame("Frame", "MyCreatureFrame", sharkoAnchor)
local BASE_SHARKO_SIZE = 150

myCreatureFrame:SetSize(BASE_SHARKO_SIZE, BASE_SHARKO_SIZE)
myCreatureFrame:SetPoint("BOTTOMRIGHT", sharkoAnchor, "BOTTOMRIGHT", 0, 0)



myCreatureFrame.myCreatureTexture = myCreatureFrame:CreateTexture(nil, "ARTWORK")
myCreatureFrame.myCreatureTexture:SetAllPoints(myCreatureFrame)
myCreatureFrame.myCreatureTexture:SetTexture(idleSprites[1])


-- Speech Bubble
local speechBubbleFrame = CreateFrame("Frame", "SpeechBubbleFrame", UIParent)
speechBubbleFrame:SetSize(250, 200)
speechBubbleFrame:SetPoint("BOTTOM", myCreatureFrame, "TOP", -180, -70)
speechBubbleFrame:Hide()

local speechBubbleTexture = speechBubbleFrame:CreateTexture(nil, "BACKGROUND")
speechBubbleTexture:SetAllPoints(speechBubbleFrame)
speechBubbleTexture:SetBlendMode("BLEND")

--bubble texture paths
local BUBBLE_TEXTURE_OPAQUE = "Interface\\AddOns\\MyLittleSharko\\Assets\\quoteBox512.tga"
local BUBBLE_TEXTURE_TRANSLUCENT = "Interface\\AddOns\\MyLittleSharko\\Assets\\quoteBoxTranslucent.tga"

--centralized texture resolver
local function UpdateSpeechBubbleTexture()
    if MyAddonSavedVars.useTranslucentBubble then
        speechBubbleTexture:SetTexture(BUBBLE_TEXTURE_TRANSLUCENT)
    else
        speechBubbleTexture:SetTexture(BUBBLE_TEXTURE_OPAQUE)
    end
end

--apply on creation
MyAddon_UpdateSpeechBubbleTexture = UpdateSpeechBubbleTexture
UpdateSpeechBubbleTexture()

local speechText = speechBubbleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
speechText:SetWidth(speechBubbleFrame:GetWidth() - 8)
speechText:SetPoint("CENTER", speechBubbleFrame, "CENTER", 0, 14)
speechText:SetTextColor(0, 0, 0)
speechText:SetFont("Fonts\\FRIZQT__.TTF", 14)
speechText:SetWordWrap(true)
speechText:SetJustifyH("CENTER")

-- Sprite functions
local function UpdateSpriteTexture(texture, spriteTable, index)
    if not texture then
        return
    end

    texture:SetTexture(spriteTable[index])
end


local function SwitchIdleSprites()
    local sprites = GetIdleSpriteTable()
    currentIdleIndex = currentIdleIndex % #sprites + 1
    UpdateSpriteTexture(myCreatureFrame.myCreatureTexture, sprites, currentIdleIndex)
end

local function SwitchTalkingSprites()
    local sprites = GetTalkingSpriteTable()
    currentTalkingIndex = currentTalkingIndex % #sprites + 1
    UpdateSpriteTexture(myCreatureFrame.myCreatureTexture, sprites, currentTalkingIndex)
end


local function StartIdleAnimation()
    state = false
    if idleTimer then idleTimer:Cancel() end
    if slowerIdle then
        idleTimer = C_Timer.NewTicker(1, SwitchIdleSprites)
    else
        idleTimer = C_Timer.NewTicker(.5, SwitchIdleSprites)
    end
end

local function StartTalkingAnimation()
    state = true
    if talkingTimer then talkingTimer:Cancel() end
    if slowerIdle then
        talkingTimer = C_Timer.NewTicker(1, SwitchTalkingSprites)
    else
        talkingTimer = C_Timer.NewTicker(.5, SwitchTalkingSprites)
    end
end

local function StopAnimations()
    if idleTimer then idleTimer:Cancel() end
    if talkingTimer then talkingTimer:Cancel() end
end

-- Speech functions
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

local function ApplySharkoScale(scale)
    sharkoScale = scale

    myCreatureFrame:SetScale(scale)

    local delta = (scale - 1) * BASE_SHARKO_SIZE * 0.5

    sharkoAnchor:ClearAllPoints()
    sharkoAnchor:SetPoint(
        "BOTTOMRIGHT",
        UIParent,
        "BOTTOMRIGHT",
        sharkoOffsetX + delta,
        sharkoOffsetY
    )
end


-- Global ticker for recurring jokes
local SharkoTicker = nil

-- Make creature talk
local function MakeCreatureTalk()
    -- Increment talk counter
    if MyAddonSavedVars and MyAddonSavedVars.talkCount then
        MyAddonSavedVars.talkCount = MyAddonSavedVars.talkCount + 1
    end

    local newText = dialogue()
    lastSharkoQuote = newText
    UpdateSpeechText(newText)
    StopAnimations()
    StartTalkingAnimation()

    if not muteVolume then
        PlaySharkoSound("talkLouder.ogg")
    end

    ToggleSpeechBubble(true)

    -- Hide speech after 10 seconds
    C_Timer.After(10, function()
        ToggleSpeechBubble(false)
        StopAnimations()
        StartIdleAnimation()
        if not muteVolume then
            PlaySharkoSound("finishLouder.ogg")
        end
    end)
end

-- Start recurring joke timer
local function StartJokeTicker()
    if SharkoTicker then
        SharkoTicker:Cancel()
    end
    SharkoTicker = C_Timer.NewTicker(55, MakeCreatureTalk)
end

-- Welcome message
local function Welcome()
    local newText = "Thank you for contracting [CORAL FEVER]! I'm your new personal assistant, Destroyman III. I'll be giving you helpful tips and tricks!"
    lastSharkoQuote = newText
    UpdateSpeechText(newText)
    StopAnimations()
    StartTalkingAnimation()
    ToggleSpeechBubble(true)

    if not muteVolume then
        PlaySharkoSound("startupLouder.ogg")
    end

    C_Timer.After(10, function()
        ToggleSpeechBubble(false)
        StopAnimations()
        StartIdleAnimation()
        if not muteVolume then
            PlaySharkoSound("finishLouder.ogg")
        end
        StartJokeTicker()
    end)
end

-- Slash Commands
SLASH_TELLJOKE1 = "/mlstelljoke"
SlashCmdList["TELLJOKE"] = function(msg)
    CancelSpeechTimer()
    MakeCreatureTalk()
end

-- SLASH_MYLITTLESHARKO1 = "/mls"
-- SlashCmdList["MYLITTLESHARKO"] = function()
--     options:Show()
-- end

-- InterfaceOptions_AddCategory(options) -- removed, TBC does not support this


-- Event handling
myCreatureFrame:RegisterEvent("PLAYER_LOGIN")
myCreatureFrame:RegisterEvent("PLAYER_DEAD")
myCreatureFrame:RegisterEvent("ADDON_LOADED")
myCreatureFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
myCreatureFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local chatTracker = CreateFrame("Frame")

chatTracker:RegisterEvent("CHAT_MSG_SAY")
chatTracker:RegisterEvent("CHAT_MSG_PARTY")
chatTracker:RegisterEvent("CHAT_MSG_GUILD")
chatTracker:RegisterEvent("CHAT_MSG_RAID")
chatTracker:RegisterEvent("CHAT_MSG_CHANNEL")

chatTracker:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_SAY" then
        lastChatType = "SAY"

    elseif event == "CHAT_MSG_PARTY" then
        lastChatType = "PARTY"

    elseif event == "CHAT_MSG_GUILD" then
        lastChatType = "GUILD"

    elseif event == "CHAT_MSG_RAID" then
        lastChatType = "RAID"

    elseif event == "CHAT_MSG_CHANNEL" then
        lastChatType = "CHANNEL"
        local _, _, _, _, _, _, _, channelNumber = ...
        lastChannelNumber = channelNumber
    end
end)

-- Options Frame for TBC Classic
local options = CreateFrame("Frame", "MyLittleSharkoOptions", UIParent)
options:SetSize(300, 425)
options:SetPoint("CENTER")
options:Hide()
tinsert(UISpecialFrames, "MyLittleSharkoOptions")
options:SetMovable(true)
options:EnableMouse(true)
options:RegisterForDrag("LeftButton")
options:SetScript("OnDragStart", options.StartMoving)
options:SetScript("OnDragStop", options.StopMovingOrSizing)

-- Background
local bg = options:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(options)
bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")

-- Close button
local closeButton = CreateFrame("Button", nil, options, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", options, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function() options:Hide() end)

-- Title
local title = options:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("My Little Sharko")

-- Spacing constants
local OPTION_SPACING = -10  -- consistent vertical spacing
local LEFT_OFFSET = 20

-- Show Sharko Checkbox
local showCheck = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
showCheck:SetPoint("TOPLEFT", LEFT_OFFSET, -40)
showCheck.Text:SetText("  Show Sharko")
showCheck:SetChecked(sharkoVisible)
showCheck:SetScript("OnClick", function(self)
    sharkoVisible = self:GetChecked()
    MyAddonSavedVars.sharkoVisible = sharkoVisible
    myCreatureFrame:SetShown(sharkoVisible)
    speechBubbleFrame:SetShown(sharkoVisible)
    if sharkoVisible then
        StartIdleAnimation()
        Welcome()
    else
        if SharkoTicker then SharkoTicker:Cancel() end
    end
end)

showCheck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        "Show or hide Sharko (but you can't truly get rid of him)",
        1, 1, 1,
        true
    )
end)

showCheck:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Translucent Chat Bubble Checkbox
local translucentBubbleCheck = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
translucentBubbleCheck:SetPoint("TOPLEFT", showCheck, "BOTTOMLEFT", 0, OPTION_SPACING)
translucentBubbleCheck.Text:SetText("  Translucent Chat Bubble")
translucentBubbleCheck:SetChecked(MyAddonSavedVars.useTranslucentBubble)
translucentBubbleCheck:SetScript("OnClick", function(self)
    MyAddonSavedVars.useTranslucentBubble = self:GetChecked()
    UpdateSpeechBubbleTexture()
end)

translucentBubbleCheck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        "Make DestroymanIII's chat bubble less intrusive",
        1, 1, 1,
        true
    )
end)

translucentBubbleCheck:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Slower Idle Checkbox
local slowerIdleCheck = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
slowerIdleCheck:SetPoint("TOPLEFT", translucentBubbleCheck, "BOTTOMLEFT", 0, OPTION_SPACING)
slowerIdleCheck.Text:SetText("  Slower Idle Animation")
slowerIdleCheck:SetChecked(slowerIdle)
slowerIdleCheck:SetScript("OnClick", function(self)
    slowerIdle = self:GetChecked()
    MyAddonSavedVars.slowerIdle = slowerIdle

    -- Restart animation
    if sharkoVisible then
        StopAnimations()
        if state then
            StartTalkingAnimation()
        else
             StartIdleAnimation()
        end
    end
end)

slowerIdleCheck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        "Reduces how often DestroymanIII moves",
        1, 1, 1,
        true
    )
end)

slowerIdleCheck:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Public Mage Down Checkbox
local publicMageDownCheck = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
publicMageDownCheck:SetPoint("TOPLEFT", slowerIdleCheck, "BOTTOMLEFT", 0, OPTION_SPACING)
publicMageDownCheck.Text:SetText("  Public Mage Down")

publicMageDownCheck:SetScript("OnClick", function(self)
    MyAddonSavedVars.publicMageDown = self:GetChecked()
end)

publicMageDownCheck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        "Inform your fellow groupmates about a mage's deserved downfall",
        1, 1, 1,
        true
    )
end)

publicMageDownCheck:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Forward declarations
local funnyModeCheck
local shinyModeCheck
local volumeSlider
local volumeLabel
local muteCheck

local scaleSlider
local scaleLabel

local posXSlider
local posXLabel
local posYSlider
local posYLabel

-- Mute Sharko Checkbox
muteCheck = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
muteCheck:SetPoint("TOPLEFT", publicMageDownCheck, "BOTTOMLEFT", 0, OPTION_SPACING)
muteCheck.Text:SetText("  Mute Sharko")
muteCheck:SetChecked(muteVolume)
muteCheck:SetScript("OnClick", function(self)
    muteVolume = self:GetChecked()
    MyAddonSavedVars.muteVolume = muteVolume

    if volumeSlider then
        volumeSlider:SetShown(not muteVolume)
    end
    if volumeLabel then
        volumeLabel:SetShown(not muteVolume)
    end
end)

muteCheck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
        "Silence DestroymanIII's notification sounds",
        1, 1, 1,
        true
    )
end)

muteCheck:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Funny Mode Checkbox (Chungus)
funnyModeCheck = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
funnyModeCheck:SetPoint("TOPRIGHT", options, "TOPRIGHT", 35, -35)
funnyModeCheck.Text:SetText("  Chungus Mode")

funnyModeCheck:SetScript("OnClick", function(self)
    if self:GetChecked() then
        isFunny = true
        isShiny = false

        MyAddonSavedVars.forceFunny = true
        MyAddonSavedVars.forceShiny = false
    else
        isFunny = false
        MyAddonSavedVars.forceFunny = false
    end

    currentIdleIndex = 1
    currentTalkingIndex = 1

    StopAnimations()
    if state then
        StartTalkingAnimation()
    else
        StartIdleAnimation()
    end

    shinyModeCheck:SetChecked(false)
end)

-- Shiny Mode Checkbox
shinyModeCheck = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
shinyModeCheck:SetPoint("TOPRIGHT", funnyModeCheck, "BOTTOMRIGHT", 0, -6)
shinyModeCheck.Text:SetText("  Shiny Mode")

shinyModeCheck:SetScript("OnClick", function(self)
    if self:GetChecked() then
        isShiny = true
        isFunny = false

        MyAddonSavedVars.forceShiny = true
        MyAddonSavedVars.forceFunny = false
    else
        isShiny = false
        MyAddonSavedVars.forceShiny = false
    end

    currentIdleIndex = 1
    currentTalkingIndex = 1

    StopAnimations()
    if state then
        StartTalkingAnimation()
    else
        StartIdleAnimation()
    end

    funnyModeCheck:SetChecked(false)
end)

-- Volume Slider (after the checkbox)
volumeSlider = CreateFrame("Slider", nil, options, "OptionsSliderTemplate")
volumeSlider:SetPoint("TOPLEFT", muteCheck, "BOTTOMLEFT", 0, OPTION_SPACING)
volumeSlider:SetMinMaxValues(0, 1)
volumeSlider:SetValueStep(0.05)
volumeSlider:SetObeyStepOnDrag(true)
volumeSlider:SetWidth(200)
volumeSlider.Low:SetText("0%")
volumeSlider.High:SetText("100%")
volumeSlider.Text:Hide()  -- hide built-in slider label

-- Label under the slider
volumeLabel = volumeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
volumeLabel:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -4)
volumeLabel:SetText("Volume: "..string.format("%.0f%%", sharkoVolume * 100))

-- Slider value update
volumeSlider:SetScript("OnValueChanged", function(self, value)
    sharkoVolume = tonumber(value) or 1.0
    if not MyAddonSavedVars then MyAddonSavedVars = {} end
    MyAddonSavedVars.volume = sharkoVolume
    volumeLabel:SetText("Volume: "..string.format("%.0f%%", sharkoVolume * 100))
end)

-- Options frame OnShow handler
options:SetScript("OnShow", function()
    -- Sync Show Sharko
    if MyAddonSavedVars.sharkoVisible ~= nil then
        showCheck:SetChecked(MyAddonSavedVars.sharkoVisible)
    else
        showCheck:SetChecked(sharkoVisible)
    end

    -- Sync Translucent Chat Bubble
    if MyAddonSavedVars.useTranslucentBubble ~= nil then
        translucentBubbleCheck:SetChecked(MyAddonSavedVars.useTranslucentBubble)
    else
        translucentBubbleCheck:SetChecked(false)
    end

    -- Sync Idle Speed
    if MyAddonSavedVars.slowerIdle ~= nil then
        slowerIdleCheck:SetChecked(MyAddonSavedVars.slowerIdle)
        slowerIdle = MyAddonSavedVars.slowerIdle
    else
        slowerIdleCheck:SetChecked(slowerIdle)
    end

    -- Sync Mute Sharko
    if MyAddonSavedVars.muteVolume ~= nil then
        muteCheck:SetChecked(MyAddonSavedVars.muteVolume)
        muteVolume = MyAddonSavedVars.muteVolume
    else
        muteCheck:SetChecked(muteVolume)
    end

    -- Show/hide volume slider and label based on mute
    volumeSlider:SetShown(not muteVolume)
    volumeLabel:SetShown(not muteVolume)

    -- Sync slider value
    if MyAddonSavedVars.volume ~= nil then
        sharkoVolume = MyAddonSavedVars.volume
    end
    volumeSlider:SetValue(sharkoVolume)

    -- Sync Chungus and Shiny UI
    if MyAddonSavedVars.unlockedFunny then
        funnyModeCheck:Show()
        funnyModeCheck:SetChecked(isFunny)
    else
        funnyModeCheck:Hide()
    end

    if MyAddonSavedVars.unlockedShiny then
        shinyModeCheck:Show()
        shinyModeCheck:SetChecked(isShiny)
    else
        shinyModeCheck:Hide()
    end

    -- Sync Sharko Scale
    if MyAddonSavedVars.sharkoScale ~= nil then
        sharkoScale = MyAddonSavedVars.sharkoScale
    end

    -- Sync Horizontal Offset
    if MyAddonSavedVars.sharkoOffsetX ~= nil then
        sharkoOffsetX = MyAddonSavedVars.sharkoOffsetX
    end

    -- Sync Vertical Offset
    if MyAddonSavedVars.sharkoOffsetY ~= nil then
        sharkoOffsetY = MyAddonSavedVars.sharkoOffsetY
    end

    -- Sync Public Mage Down
    if MyAddonSavedVars.publicMageDown ~= nil then
        publicMageDownCheck:SetChecked(MyAddonSavedVars.publicMageDown)
    else
        publicMageDownCheck:SetChecked(true)
    end

    posYSlider:SetValue(sharkoOffsetY)
    posXSlider:SetValue(sharkoOffsetX)


        ApplySharkoScale(sharkoScale)

        scaleSlider:SetValue(sharkoScale)
        scaleLabel:SetText("Sharko Size: "..string.format("%.0f%%", sharkoScale * 100))
    end)

-- Sharko Size Slider
scaleSlider = CreateFrame("Slider", nil, options, "OptionsSliderTemplate")
scaleSlider:SetPoint("TOPLEFT", volumeSlider, "BOTTOMLEFT", 0, -35)
scaleSlider:SetMinMaxValues(0.25, 2.0)
scaleSlider:SetValueStep(0.05)
scaleSlider:SetObeyStepOnDrag(true)
scaleSlider:SetWidth(200)
scaleSlider.Low:SetText("25%")
scaleSlider.High:SetText("200%")
scaleSlider.Text:Hide()

scaleLabel = scaleSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
scaleLabel:SetPoint("TOP", scaleSlider, "BOTTOM", 0, -4)
scaleLabel:SetText("Sharko Size: 50%")

scaleSlider:SetScript("OnValueChanged", function(self, value)
    sharkoScale = tonumber(value) or 0.5
    MyAddonSavedVars.sharkoScale = sharkoScale

    ApplySharkoScale(sharkoScale)

    scaleLabel:SetText("Sharko Size: "..string.format("%.0f%%", sharkoScale * 100))
end)

-- Sharko Horizontal Position Slider
posXSlider = CreateFrame("Slider", nil, options, "OptionsSliderTemplate")
posXSlider:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -35)
posXSlider:SetMinMaxValues(-800, 400)
posXSlider:SetValueStep(5)
posXSlider:SetObeyStepOnDrag(true)
posXSlider:SetWidth(200)
posXSlider.Low:SetText("Left")
posXSlider.High:SetText("Right")
posXSlider.Text:Hide()

local posXLabel = posXSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
posXLabel:SetPoint("TOP", posXSlider, "BOTTOM", 0, -4)
posXLabel:SetText("Horizontal Offset")

posXSlider:SetScript("OnValueChanged", function(self, value)
    sharkoOffsetX = tonumber(value) or -75
    MyAddonSavedVars.sharkoOffsetX = sharkoOffsetX

    ApplySharkoScale(sharkoScale)
end)

-- Sharko Vertical Position Slider
posYSlider = CreateFrame("Slider", nil, options, "OptionsSliderTemplate")
posYSlider:SetPoint("TOPLEFT", posXSlider, "BOTTOMLEFT", 0, -35)
posYSlider:SetMinMaxValues(-50, 1000)
posYSlider:SetValueStep(5)
posYSlider:SetObeyStepOnDrag(true)
posYSlider:SetWidth(200)
posYSlider.Low:SetText("Down")
posYSlider.High:SetText("Up")
posYSlider.Text:Hide()

posYLabel = posYSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
posYLabel:SetPoint("TOP", posYSlider, "BOTTOM", 0, -4)
posYLabel:SetText("Vertical Offset")

posYSlider:SetScript("OnValueChanged", function(self, value)
    sharkoOffsetY = tonumber(value) or 5
    MyAddonSavedVars.sharkoOffsetY = sharkoOffsetY

    ApplySharkoScale(sharkoScale)
end)


-- Slash Command to open options
SLASH_MYLITTLESHARKO1 = "/mls"
SlashCmdList["MYLITTLESHARKO"] = function()
    if options:IsShown() then
        options:Hide()
    else
        options:Show()
    end
end

SLASH_MLSSHARE1 = "/mlsshare"

SlashCmdList["MLSSHARE"] = function()

    if not lastSharkoQuote then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[MLS] No quote stored yet.|r")
        return
    end

    local output = '[MLS] "' .. lastSharkoQuote .. '"'

    local editBox = DEFAULT_CHAT_FRAME.editBox
    local chatType = editBox:GetAttribute("chatType")
    local channel = editBox:GetAttribute("channelTarget")

    if chatType == "CHANNEL" and channel then
        SendChatMessage(output, "CHANNEL", nil, channel)
    else
        SendChatMessage(output, chatType or "SAY")
    end
end

SLASH_MLSHELP1 = "/mlshelp"

SlashCmdList["MLSHELP"] = function()

    DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[MLS Help]|r v"..addonVersion.." Available Commands:")

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00/mls|r - Opens the options menu.")

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00/mlsshare|r - Shares DestroymanIII's last line to your currently selected chat.")

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00/mlshelp|r - Displays this help menu (but I think you figured that out).")

end

-- Force Chungus Command
SLASH_MLSFORCEFUNNY1 = "/mlsforcefunny"
SlashCmdList["MLSFORCEFUNNY"] = function()

    if isFunny then
        -- Turn OFF Chungus
        isFunny = false
        MyAddonSavedVars.forceFunny = false

        print("|cff00ffffMyLittleSharko:|r Chungus disabled.")
    else
        -- Turn ON Chungus (forces shiny off)
        isFunny = true
        isShiny = false
        MyAddonSavedVars.unlockedFunny = true

        MyAddonSavedVars.forceFunny = true
        MyAddonSavedVars.forceShiny = false

        print("|cff00ffffMyLittleSharko:|r |cffff8800CHUNGUS MODE ACTIVATED|r")
    end

    currentIdleIndex = 1
    currentTalkingIndex = 1

    StopAnimations()
    if state then
        StartTalkingAnimation()
    else
        StartIdleAnimation()
    end
end



SLASH_MLSCLEARFUNNY1 = "/mlsclearfunny"
SlashCmdList["MLSCLEARFUNNY"] = function()

    isFunny = false
    MyAddonSavedVars.forceFunny = false

    currentIdleIndex = 1
    currentTalkingIndex = 1

    StopAnimations()
    if state then
        StartTalkingAnimation()
    else
        StartIdleAnimation()
    end

    print("|cff00ffffMyLittleSharko:|r Chungus disabled.")
end


--Slash Command to force shiny
SLASH_MLSFORCESHINY1 = "/mlsforceshiny"
SlashCmdList["MLSFORCESHINY"] = function()

    if isShiny then
        -- Turn OFF shiny
        isShiny = false
        MyAddonSavedVars.forceShiny = false

        print("|cff00ffffMyLittleSharko:|r Shiny disabled.")
    else
        -- Turn ON shiny (Chungus must be off)
        isShiny = true
        isFunny = false
        MyAddonSavedVars.unlockedShiny = true

        MyAddonSavedVars.forceShiny = true
        MyAddonSavedVars.forceFunny = false

        print("|cff00ffffMyLittleSharko:|r DestroymanIII is now |cffffff00SHINY|r!")
    end

    currentIdleIndex = 1
    currentTalkingIndex = 1

    StopAnimations()
    if state then
        StartTalkingAnimation()
    else
        StartIdleAnimation()
    end
end


-- Revert shiny command
SLASH_MLSCLEARSHINY1 = "/mlsclearshiny"
SlashCmdList["MLSCLEARSHINY"] = function()
    isShiny = false
    MyAddonSavedVars.forceShiny = false

    currentIdleIndex = 1
    currentTalkingIndex = 1

    StopAnimations()
    if state then
        StartTalkingAnimation()
    else
        StartIdleAnimation()
    end

    print("|cff00ffffMyLittleSharko:|r DestroymanIII is now boring.")
end

--returns true if GUID belongs to a mage in our party or raid
local function IsGroupMageGUID(guid)
    if not guid then return false end
    if not IsInGroup() then return false end

    local num = GetNumGroupMembers()

    for i = 1, num do
        local unit
        if IsInRaid() then
            unit = "raid"..i
        else
            unit = i == num and "player" or "party"..i
        end

        if UnitExists(unit) and UnitGUID(unit) == guid then
            local _, class = UnitClass(unit)
            return class == "MAGE"
        end
    end

    return false
end


local function IsSoloPlayerMageDeath(guid)
    if IsInGroup() then return false end

    if UnitGUID("player") == guid then
        local _, class = UnitClass("player")
        return class == "MAGE"
    end

    return false
end

--Mage down reaction
local function TriggerMageDown(deadName)
    if mageDownCooldown then return end
    mageDownCooldown = true

    CancelSpeechTimer()
    CancelJokeTicker()

    state = true

    StopAnimations()
    ToggleSpeechBubble(false)

    UpdateSpeechText("MAGE DOWN!!!")

    StartTalkingAnimation()

    --play special temporary sound
    if not muteVolume then
        PlaySharkoSound("mageDown.ogg")
    end

    ToggleSpeechBubble(true)

    -- public yell if enabled
    if MyAddonSavedVars.publicMageDown and deadName then
        SendChatMessage(
            "MAGE DOWN! MAGE DOWN! "..deadName.." IS DOWN!",
            "YELL"
        )
    end

    --bubble stays up for 8 seconds
    C_Timer.After(8, function()
        ToggleSpeechBubble(false)
        StopAnimations()
        StartIdleAnimation()

        state = false

        StartJokeTicker()
        mageDownCooldown = false

        if not muteVolume then
            PlaySharkoSound("finishLouder.ogg")
        end
    end)
end

myCreatureFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "PLAYER_LOGIN" then
        -- Do nothing here in TBC; wait for ADDON_LOADED
    elseif event == "PLAYER_DEAD" then
        local newText = deathQuote()
        UpdateSpeechText(newText)
        StopAnimations()
        StartTalkingAnimation()
        if not muteVolume then
            PlaySharkoSound("talkLouder.ogg")
        end
        ToggleSpeechBubble(true)
        C_Timer.After(10, function()
            ToggleSpeechBubble(false)
            StopAnimations()
            StartIdleAnimation()
            if not muteVolume then
                PlaySharkoSound("finishLouder.ogg")
            end
        end)
        StartJokeTicker()
elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    local timestamp,
        subevent,
        hideCaster,
        sourceGUID,
        sourceName,
        sourceFlags,
        sourceRaidFlags,
        destGUID,
        destName,
        destFlags,
        destRaidFlags = CombatLogGetCurrentEventInfo()

    if subevent == "UNIT_DIED" then

        local inGroup =
            bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 or
            bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_RAID) > 0

        if not inGroup then return end

        -- ignore solo mage death, player already has lines
        if IsSoloPlayerMageDeath(destGUID) then
            return
        end

        if IsGroupMageGUID(destGUID) then
            TriggerMageDown(destName)
        end
    end

    elseif event == "ADDON_LOADED" and addon == "MyLittleSharko" then

        -- Create saved vars if missing
        if not MyAddonSavedVars then
            MyAddonSavedVars = {}
        end

        -- Defaults
        if MyAddonSavedVars.volume == nil then
            MyAddonSavedVars.volume = 1.0
        end
        if MyAddonSavedVars.muteVolume == nil then
            MyAddonSavedVars.muteVolume = false
        end
        if MyAddonSavedVars.sharkoVisible == nil then
            MyAddonSavedVars.sharkoVisible = true
        end
        if MyAddonSavedVars.useTranslucentBubble == nil then
            MyAddonSavedVars.useTranslucentBubble = false
        end
        if MyAddonSavedVars.slowerIdle == nil then
            MyAddonSavedVars.slowerIdle = false
        end
        if MyAddonSavedVars.forceShiny == nil then
            MyAddonSavedVars.forceShiny = false
        end
        if MyAddonSavedVars.forceFunny == nil then
            MyAddonSavedVars.forceFunny = false
        end
        if MyAddonSavedVars.unlockedFunny == nil then
            MyAddonSavedVars.unlockedFunny = false
        end
        if MyAddonSavedVars.unlockedShiny == nil then
            MyAddonSavedVars.unlockedShiny = false
        end
        if MyAddonSavedVars.sharkoScale == nil then
            MyAddonSavedVars.sharkoScale = 1
        end
        if MyAddonSavedVars.sharkoOffsetX == nil then
            MyAddonSavedVars.sharkoOffsetX = -75
        end
        if MyAddonSavedVars.sharkoOffsetY == nil then
            MyAddonSavedVars.sharkoOffsetY = 5
        end
        if MyAddonSavedVars.publicMageDown == nil then
            MyAddonSavedVars.publicMageDown = true
        end
        if MyAddonSavedVars.reloadCount == nil then
            MyAddonSavedVars.reloadCount = 0
        end

        -- Increment reload counter
        MyAddonSavedVars.reloadCount = MyAddonSavedVars.reloadCount + 1

        if MyAddonSavedVars.talkCount == nil then
            MyAddonSavedVars.talkCount = 0
        end

        if MyAddonSavedVars.pendingSecret == nil then
            MyAddonSavedVars.pendingSecret = nil -- string name of mode to activate next reload
        end



        -- Load into runtime
        sharkoVolume = MyAddonSavedVars.volume
        muteVolume = MyAddonSavedVars.muteVolume
        sharkoVisible = MyAddonSavedVars.sharkoVisible
        slowerIdle = MyAddonSavedVars.slowerIdle
        UpdateSpeechBubbleTexture()
        sharkoScale = MyAddonSavedVars.sharkoScale
        sharkoOffsetX = MyAddonSavedVars.sharkoOffsetX
        sharkoOffsetY = MyAddonSavedVars.sharkoOffsetY
        ApplySharkoScale(sharkoScale)

        -- Reset runtime flags
        isFunny = false
        isShiny = false

        -- =========================================================
        -- SECRET MODE REGISTRY
        -- =========================================================
        local SecretModes = {
            Shiny = {
                unlockCheck = function()
                    return MyAddonSavedVars.reloadCount >= 20
                end,
                activate = function()
                    isShiny = true
                    MyAddonSavedVars.unlockedShiny = true
                end
            },
            Chungus = {
                unlockCheck = function()
                    return MyAddonSavedVars.talkCount >= 1000
                end,
                activate = function()
                    isFunny = true
                    MyAddonSavedVars.unlockedFunny = true
                end
            }
        }

        -- =========================================================
        -- FORCE MODES STILL TAKE PRIORITY
        -- =========================================================
        if MyAddonSavedVars.forceFunny then
            isFunny = true
            MyAddonSavedVars.unlockedFunny = true

        elseif MyAddonSavedVars.forceShiny then
            isShiny = true
            MyAddonSavedVars.unlockedShiny = true

        else

            -- =====================================================
            -- ACTIVATE PENDING SECRET (ONE RELOAD ONLY)
            -- =====================================================
            if MyAddonSavedVars.pendingSecret then
                local mode = SecretModes[MyAddonSavedVars.pendingSecret]

                if mode then
                    mode.activate()
                end

                -- Clear so it only lasts one reload
                MyAddonSavedVars.pendingSecret = nil

            else
                -- =================================================
                -- CHECK FOR NEW UNLOCKS
                -- =================================================
                for name, mode in pairs(SecretModes) do
                    if mode.unlockCheck() then

                        -- Only queue if not already unlocked
                        if name == "Shiny" and not MyAddonSavedVars.unlockedShiny then
                            MyAddonSavedVars.pendingSecret = name
                        elseif name == "Chungus" and not MyAddonSavedVars.unlockedFunny then
                            MyAddonSavedVars.pendingSecret = name
                        end
                    end
                end
            end
        end

        -- Apply visibility
        myCreatureFrame:SetShown(sharkoVisible)
        speechBubbleFrame:SetShown(sharkoVisible)
    elseif event == "PLAYER_ENTERING_WORLD" then
        DEFAULT_CHAT_FRAME:AddMessage(
    "|cff00ffff[MyLittleSharko]|r v"..addonVersion.." by Softcorre@Dreamscythe. Type |cffffff00/mlshelp|r for options."
)
                if sharkoVisible then
                StartIdleAnimation()
                Welcome()
            end
        end
end)

