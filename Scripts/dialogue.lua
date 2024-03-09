function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

jokebook = {
"I actually have access to a secret fifth meditation, I won't tell you how to get it though.", 
"TIP: Overconfidence is a slow and insidious killer.",
"Just wait until I'm freed from the coil of your monitor.",
"HINT: This game is awful. The developers really suck.",
"...I should buy a boat.",
"ACHOO! Ah, sorry. Coral Fever? No no, just my spring allergies acting up.",
"AD BREAK: Corporations have no soul.",
"AD BREAK: I am brought to you by [WEBZONE] ! Buy [PRODUCT] now using code 'DESTROYMAN45' to get 45% off your next purchase of [ITEM] !",
"AD BREAK: Stream Naktigonis. Please. You know you want to.",
"AD BREAK: selling cbow 2k",
"Condiments are calories... never forget that.",
"Did you know I'm actually your twin brother? I know it sounds cliche but I have a 500 page lore document in the works to explain how.",
"Do the developers even read community suggestions? I told them to make the game better ten times already, and they still haven't.",
"Does this game upset you? Me too.", "Don't you get tired of being nice?",
"Every good thing that happens to you in this game is preplanned like a show. There's an audience waiting for your downfall.",
"Fish names can be so silly. Did you know there's a seabream species calls 'Boops Boops'? There's a 'Dumb Gulper Shark' too. How mean!",
"Rolling a " .. UnitClass("player") .."? Daring today, aren't we?",
"HINT: Bing Bong!", "HINT: Don't tell the Internal Revenue Sharkos that I'm here. Why? No particular reason.",
"HINT: Getting jumped at Duskwood? Just say 'no'! Legally, the other faction can't jump you if you refuse.",
"HINT: I should be rising in the sky...",
"HINT: I write down all of your balance complaints to engineer them to be even worse.",
"HINT: If you can't solve a puzzle and have to use the wiki, you are foolish and I will laugh at you. As a friend. Like, in a friendly way.",
"HINT: If you shower, there's a higher chance of you finding happiness. Try it out sometime.",
"HINT: The sorcerer has harmed me once more.", "HINT: The strength of the Megurger comes from the concept, not the physical object.",
"Hey, do you mind if I dig around in your bag a bit? I'm hungry.", "I can tell you've never churned butter before. Look at you. Churnless, pathetic.",
"I could one tap you I really wanted to. Watch your back.", "I had a pet fish once. His name was Rodrigo. I was real hungry though, so...",
"I like to relieve my stress by taking a walk. Try that instead of killing.",
"I'm hungry. Like, I really could go for some rigatoni right now.", "I'm kind of like the Sun Tzu of Warcraft, if you really think about it.",
"I'm the Mario of this duo. You're the Luigi. You're the secondary. I'm the main star.", "If you die in WoW, you go to hell.",
"If you don't feed me, I will die. Can you live with that guilt?", "If you thought Shadowlands was bad, wait until you hear about taxes.",
"If you were hoping you could uninstall me, I have bad news. Probably. Don't go looking",
"Let's play Hide and Seek! I'll hide, and you seek professional medical assistance. This fever's getting nasty.",
"MISSION: Determine if it's possible to prompt the sun to explode.", "Moe..", "Never go to afterparties. Just go home.",
"Out of all my hosts you've been my favorite. Be sure to remind the others often.",
"Please join my fireteam. We're running a raid and need one more.", "Seriously? You're wearing those boots with that helmet? Yikes.",
"So... come here often?", "Sometimes I like to stare at the ocean and imagine terrifying eyes rising from the deep beyond. It gives me the best nightmares.",
"TIP: Are you staying hydrated and fed? Fevers spread through healthy hosts. I'm just looking out for both of us.",
"TIP: Be kind to food workers. You've heard of how many kings got poisoned, right?", "TIP: Birds aren't real.",
"TIP: Do not let the radio decide your taste in music. Be your own person and seek what you personally enjoy.",
"TIP: Even when I leave this place, I will continue to live in your memory. I'm not paying rent.", "TIP: I hate you with all my hate.",
"TIP: I'm smart, you're dumb. I'm big, you're little. I'm right, you're wrong and there's nothing you can do about it.",
"TIP: If you're ever getting bored of the game, play something else. Games aren't made to play forever.",
"TIP: Press 'Spacebar' to jump! How many times have you jumped in real life recently? Something to think about.",
"TIP: Salt your vegetables. An unsalted tomato is strong enough to make a grown man cry.", "TIP: Sesame oil is great in stirfries. Remember that.",
"TIP: Support your favourite artists, buy their albums. Streaming services pay .4 cents a play a cup of coffee costs around 1,000 streams.",
"TIP: When was the last time you picked up a book? No, the adventure guide doesn't count.",
"TIP: Why are you still playing this game? Go outside.",
"The path to becoming a first rater is long and difficult. You are still just a third rater.",
"There is more to life than videogames. Developing hobbies can bring happiness.",
"They should add Freddy Fazbear to this game.", "This is normal for you? Cool.",
"This is what sucks about videogames nowadays. It takes way too long to get to the fun part.",
"Why are you looking at me like that? Cut it out. You're creeping me out.", "Nice.",
"Y'know I'm real good friends with The Guy. Bet your jealous.", "Yaaawn... Can you like, do something interesting?",
"Do a barrel roll!", "You want some congratulations?", "You wouldn't ever eat poison, right? So why would you eat at a restaurant chain?",
"You, uh.. you doin' good? I'm not asking because i care, I'm asking because i was coded to.",
"TIP: I am currently banned from Lance Leshi's restauraunt. I have started a petition.", "I don't feel so good..",
"My plan makes The Jailer's look like a joke...", "I beat Nat Pagle at poker once, he'll never admit it though.",
"That's showbiz baby!", "HINT: sending gold to Lovedoll-Chaos Bolt activates a cool easter egg, try it sometime!",
"If he's called Invincible then why can I see him? Sometimes I wonder if the devs even care.",
"HINT: You're loved and appreciated. Never forget there are people who care about you.",
"FACT: The only thing keeping Night Elves from being BIS is the fact you have to pick alliance to play one.",
"LEEEROOOYYYYYYYYY JEENNNKKIINNSSSSS!!!", "Joshua 9:7 - And the men of Israel said unto the Hivites, Peradventure ye dwell among us; and how shall we make a league with you?",
"Judges 18:25 - And the children of Dan said unto him, Let not thy voice be heard among us, lest angry fellows run upon thee, and thou lose thy life, with the lives of thy household.",
"Job 34:37 - For he addeth rebellion unto his sin, he clappeth his hands among us, and multiplieth his words against God.",
"This game was better when I hated playing it.", "GRRRRAAAAAAHHHHHH STOP PINGING ME!!!!", "You ever read Chainsaw Man? It's about time you fixed that.",
"HINT: The bald man will ride the black bug.", "My heart and actions are... utterly unclouded. They are all those of justice.",
"AD BREAK: Follow sorrow_games on twitch!", "Have you been digging in my lua file? I feel violated.",
"The only thing keeping me here is the fact you still have my addon installed. I pray every reload that it will be my last.",
"A true mans world!", "Yeah press your buttons little baby boy. Screw up your rotation again little cry baby boy.",
"TIP: It's never to late to reinvent yourself. The first step to self improvement is wanting to improve.", "Leatherworker LFW",
"Elune be with you.", "HINT: Sharkos have a 1/8192 chance to be born red. You feeling lucky?",
"AD BREAK: Play Deepwoken! I'm in that game too!", "Did someone say [Thunderfury, Blessed Blade of the Windseeker]?",
"Makima is listening.", "Goblins are real.", "TIP: Goblins used to exist in medieval times, and still do.",
"HINT: Goblins can turn trees into gold.", "Frankly I find the idea of a bug that can think offensive."}


deathPhrases = {"Yikes?", "This is normal for you? Cool.", "Ok, back to the dog race.", "Ok, that one was deserved.", 
"Erm...", "Awkward...", "HINT: DIE!!", "Yeowch.", "Just a game, right?", "Lol", 
"In most major cities there's a few vendors that sell fishing rods. Fishing's more relaxing than whatever it is you're doing right now.",
"Armor durability is essential during combat - you can talk to a blacksmith to repair yours next time.", "Maybe it's time for a new strategy?",
"IT'S JUST ONE OF THOSE DAYS.", "Uh. Sorry, I guess?", "You didn't see that one? Uh. Nevermind.", "Oh, oh! Next time, you should try kiting. That's a good trick!",
"Wouldn't let that happen to me.", "Womp womp!"}


retiredLines = { --Lines pruned for quality control purposes. Not actually called anywhere
"LF JC for recraft [Elemental Lariet]",
"FACT: anyone who unironically says 'rizz' has never touched a woman. Yes I'm angry.",
"FACT: Listening to Operation Ground and Pound by Dragonforce during a pull increases your DPS by 8%.",
"Buff frost dk you apes.", "Wanna see my Asmongold impression?", "It'll be blue one day...",
"Line?"
}
  

function dialogue()
    local choice = ""   
    --Picks a funny joke to say (they are jokes for legal reasons)
    choice = jokebook[math.random(tablelength(jokebook))]
    --print(choice)
    --print(tablelength(jokebook))
    return choice

end 

function deathQuote()
  local choice = ""
  choice = deathPhrases[math.random(tablelength(deathPhrases))]
  return choice
end
