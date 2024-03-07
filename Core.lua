--print("Thank you for contracting [ CORAL FEVER ] " .. UnitName("player") .. "!")

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
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

local function dialogue()
    local choice = ""   
    local jokebook = {}

    --Thus Begins the Reckoning--

    jokebook[0] = "I actually have access to a secret fifth meditation, I won't tell you how to get it though."
    jokebook[1] = "TIP: Overconfidence is a slow and insidious killer."
    jokebook[2] = "Just wait until I'm freed from the coil of your monitor."
    jokebook[3] = "HINT: This game is awful. The developers really suck."
    jokebook[4] = "...I should buy a boat."
    jokebook[5] = "ACHOO! Ah, sorry. Coral Fever? No no, just my spring allergies acting up."
    jokebook[6] = "AD BREAK: Corporations have no soul."
    jokebook[7] = "AD BREAK: I am brought to you by [WEBZONE] ! Buy [PRODUCT] now using code 'DESTROYMAN45' to get 45% off your next purchase of [ITEM] !"
    jokebook[8] = "AD BREAK: Stream Naktigonis. Please. You know you want to."
    jokebook[9] = "AD BREAK: selling cbow 2k"
    jokebook[10] = "Condiments are calories... never forget that."
    jokebook[11] = "Did you know I'm actually your twin brother? I know it sounds cliche but I have a 500 page lore document in the works to explain how."
    jokebook[12] = "Do the developers even read community suggestions? I told them to make the game better ten times already, and they still haven't."
    jokebook[13] = "Does this game upset you? Me too."
    jokebook[14] = "Don't you get tired of being nice?"
    jokebook[15] = "Every good thing that happens to you in this game is preplanned like a show. There's an audience waiting for your downfall."
    jokebook[16] = "Fish names can be so silly. Did you know there's a seabream species calls 'Boops Boops'? There's a 'Dumb Gulper Shark' too. How mean!"
    jokebook[17] = "Rolling a " .. UnitClass("player") .."? Daring today, aren't we?"
    jokebook[18] = "HINT: DIE!!"
    jokebook[19] = "HINT: Don't tell the Internal Revenue Sharkos that I'm here. Why? No particular reason."
    jokebook[20] = "HINT: Getting jumped at Duskwood? Just say 'no'! Legally, the other faction can't jump you if you refuse."
    jokebook[21] = "HINT: I should be rising in the sky..."
    jokebook[22] = "HINT: I write down all of your balance complaints to engineer them to be even worse."
    jokebook[23] = "HINT: If you can't solve a puzzle and have to use the wiki, you are foolish and I will laugh at you. As a friend. Like, in a friendly way."
    jokebook[24] = "HINT: If you shower, there's a higher chance of you finding happiness. Try it out sometime."
    jokebook[25] = "HINT: The sorcerer has harmed me once more."
    jokebook[26] = "HINT: The strength of the Megurger comes from the concept, not the physical object."
    jokebook[28] = "Hey, do you mind if I dig around in your bag a bit? I'm hungry."
    jokebook[29] = "I can tell you've never churned butter before. Look at you. Churnless, pathetic."
    jokebook[30] = "I could one tap you I really wanted to. Watch your back."
    jokebook[31] = "I had a pet fish once. His name was Rodrigo. I was real hungry though, so..."
    jokebook[32] = "I like to relieve my stress by taking a walk. Try that instead of killing."
    jokebook[33] = "I'm hungry. Like, I really could go for some rigatoni right now."
    jokebook[34] = "I'm kind of like the Sun Tzu of Warcraft, if you really think about it."
    jokebook[35] = "I'm the Mario of this duo. You're the Luigi. You're the secondary. I'm the main star."
    jokebook[36] = "If you die in WoW, you go to hell."
    jokebook[37] = "If you don't feed me, I will die. Can you live with that guilt?"
    jokebook[38] = "If you thought Shadowlands was bad, wait until you hear about taxes."
    jokebook[39] = "If you were hoping you could uninstall me, I have bad news. Probably. Don't go looking"
    jokebook[40] = "Let's play Hide and Seek! I'll hide, and you seek professional medical assistance. This fever's getting nasty."
    jokebook[41] = "MISSION: Determine if it's possible to prompt the sun to explode."
    jokebook[42] = "Moe.."
    jokebook[43] = "Never go to afterparties. Just go home."
    jokebook[44] = "Ok, back to the dog race."
    jokebook[45] = "Please join my fireteam. We're running a raid and need one more."
    jokebook[46] = "Seriously? You're wearing those boots with that helmet? Yikes."
    jokebook[47] = "So... come here often?"
    jokebook[48] = "Sometimes I like to stare at the ocean and imagine terrifying eyes rising from the deep beyond. It gives me the best nightmares."
    jokebook[49] = "TIP: Are you staying hydrated and fed? Fevers spread through healthy hosts. I'm just looking out for both of us."
    jokebook[50] = "TIP: Be kind to food workers. You've heard of how many kings got poisoned, right?"
    jokebook[51] = "TIP: Birds aren't real."
    jokebook[52] = "TIP: Do not let the radio decide your taste in music. Be your own person and seek what you personally enjoy."
    jokebook[53] = "TIP: Even when I leave this place, I will continue to live in your memory. I'm not paying rent."
    jokebook[54] = "TIP: I hate you with all my hate."
    jokebook[55] = "TIP: I'm smart, you're dumb. I'm big, you're little. I'm right, you're wrong and there's nothing you can do about it."
    jokebook[56] = "TIP: If you're ever getting bored of the game, play something else. Games aren't made to play forever."
    jokebook[57] = "TIP: Press 'Spacebar' to jump! How many times have you jumped in real life recently? Something to think about."
    jokebook[58] = "TIP: Salt your vegetables. An unsalted tomato is strong enough to make a grown man cry."
    jokebook[59] = "TIP: Sesame oil is great in stirfries. Remember that."
    jokebook[60] = "TIP: Support your favourite artists, buy their albums. Streaming services pay .4 cents a play a cup of coffee costs around 1,000 streams."
    jokebook[61] = "TIP: When was the last time you picked up a book? No, the adventure guide doesn't count."
    jokebook[62] = "TIP: Why are you still playing this game? Go outside."
    jokebook[63] = "The path to becoming a first rater is long and difficult. You are still just a third rater."
    jokebook[64] = "There is more to life than videogames. Developing hobbies can bring happiness."
    jokebook[65] = "They should add Freddy Fazbear to this game."
    jokebook[66] = "This is normal for you? Cool."
    jokebook[67] = "This is what sucks about videogames nowadays. It takes way too long to get to the fun part."
    jokebook[68] = "Why are you looking at me like that? Cut it out. You're creeping me out."
    jokebook[69] = "Nice."
    jokebook[70] = "Y'know I'm real good friends with The Guy. Bet your jealous."
    jokebook[71] = "Yaaawn... Can you like, do something interesting?"
    jokebook[72] = "Yikes?"
    jokebook[73] = "You know I'm really good friends with The Guy right? I bet you're jealous."
    jokebook[74] = "You want some congratulations?"
    jokebook[75] = "You wouldn't ever eat poison, right? So why would you eat at a restaurant chain?"
    jokebook[76] = "You, uh.. you doin' good? I'm not asking because i care, I'm asking because i was coded to."
    jokebook[77] = "TIP: I am currently banned from Lance Leshi's restauraunt. I have started a petition."
    jokebook[78] = "I don't feel so good.."

    --End of Original DestroymanIII lines, beginning of personal lines

    jokebook[79] = "LF JC for recraft [Elemental Lariet]"
    jokebook[80] = "My plan makes The Jailer's look like a joke..."
    jokebook[81] = "I beat Nat Pagle at poker once, he'll never admit it though."
    jokebook[82] = "That's showbiz baby!"
    jokebook[83] = "FACT: sending gold to Lovedoll-Chaos Bolt activates a cool easter egg, try it sometime!"
    jokebook[84] = "FACT: anyone who unironically says 'rizz' has never touched a woman. Yes I'm angry."
    jokebook[85] = "Ok is it ACTUALLY invisible or is everyone just stupid."
    jokebook[86] = "FACT: Listening to Operation Ground and Pound by Dragonforce during a pull increases your DPS by 8%."
    jokebook[87] = "FACT: What?"
    jokebook[88] = "FACT: The only thing keeping Night Elves from being BIS is the fact you have to pick alliance to play one."
    jokebook[89] = "LEEEROOOYYYYYYYYY JEENNNKKIINNSSSSS!!!"
    jokebook[90] = "Joshua 9:7 - And the men of Israel said unto the Hivites, Peradventure ye dwell among us; and how shall we make a league with you?"
    jokebook[91] = "Judges 18:25 - And the children of Dan said unto him, Let not thy voice be heard among us, lest angry fellows run upon thee, and thou lose thy life, with the lives of thy household."
    jokebook[92] = "Job 34:37 - For he addeth rebellion unto his sin, he clappeth his hands among us, and multiplieth his words against God."
    jokebook[93] = "This game was better when I hated playing it."
    jokebook[94] = "Buff frost dk you apes."
    jokebook[95] = "GRRRRAAAAAAHHHHHH STOP PINGING ME!!!!"
    jokebook[96] = "You ever read Chainsaw Man? It's about time you fixed that."
    jokebook[97] = "Wanna see my Asmongold impression?"
    jokebook[98] = "FACT: The bald man will ride the black bug."
    jokebook[99] = "My heart and actions are... utterly unclouded. They are all those of justice."
    jokebook[100] = "Follow sorrow_games on twitch!"
    jokebook[101] = "Have you been digging in my lua file? I feel violated."
    jokebook[102] = "The only thing keeping me here is the fact that you still have my addon installed. I pray every ui reload that it will be my last."
    jokebook[103] = "A true mans world!"
    jokebook[104] = "Yeah press your buttons little baby boy. Screw up your rotation again little cry baby boy."
    jokebook[105] = "FACT: I get irrationally angry when low level mages don't lust."
    jokebook[106] = "Leatherworker LFW"
    jokebook[107] = "Elune be with you."
    jokebook[108] = "It'll be blue one day..."
    jokebook[109] = "Play Deepwoken! I'm in that game too!"
    jokebook[110] = "Line?"
    jokebook[111] = "Did someone say [Thunderfury, Blessed Blade of the Windseeker]?"
    jokebook[112] = "Makima is listening."
    jokebook[113] = "Goblins are real."
    jokebook[114] = "FACT: Goblins used to exist in medieval times, and still do."
    jokebook[115] = "FACT: Goblins can turn trees into gold."
    jokebook[116] = "Frankly I find the idea of a bug that can think offensive."
    

    --Picks a funny joke to say (they are jokes for legal reasons)
    choice = jokebook[math.random(tablelength(jokebook)) - 1]
    --print(choice)
    --print(tablelength(jokebook))
    return choice

end 

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
  newText = dialogue()
  UpdateSpeechText(newText)
  StopAnimations()
  StartTalkingAnimation()

  -- Show the speech bubble
  ToggleSpeechBubble(true)

  -- Schedule a timer to hide the speech bubble after 10 seconds
  C_Timer.After(10, function()
      ToggleSpeechBubble(false)
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

-- Schedule the initial talk

myCreatureFrame:RegisterEvent("ADDON_LOADED")
myCreatureFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "MyLittleSharko" then
        StartTalkingAnimation() --THIS WONT FUCKING WORK, HE REFUSES TO FUCKING TALK WHEN YOU OPEN THE GAME
        startTimer = C_Timer.NewTimer(10, Welcome)
    end
end)