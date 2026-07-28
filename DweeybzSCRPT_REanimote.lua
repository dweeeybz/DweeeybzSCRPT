--[[
    DweeybzSCRPT | Animations & Emotes (WindUI Edition) — REWORK
    - ANIMATIONS + EMOTES tabs (click a name = instantly equips it)
    - DEFAULT button per tab (clears everything back to normal)
    - Live search bar per tab
    - ★ Favorite button on every entry -> dedicated FAVORITES tab
    - Save / Load Configuration (persists across sessions via writefile)
    - Clean categorized layout
]]

-- ============================================================
-- // SERVICES & PLAYER SETUP
-- ============================================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
	and LocalPlayer.Character
	and LocalPlayer.Character:FindFirstChild("Animate")
	and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	and LocalPlayer.Character.Humanoid:FindFirstChild("Animator")

local URL = "http://www.roblox.com/asset/?id="
local CONFIG_FOLDER = "DweeybzSCRPT"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

game.StarterPlayer.AllowCustomAnimations = true
workspace:SetAttribute("RbxLegacyAnimationBlending", true)

if makefolder and not isfolder(CONFIG_FOLDER) then
	makefolder(CONFIG_FOLDER)
end

-- // Save the player's original animations once, so we can restore them later
if not getgenv().OriginalAnimations then
	getgenv().OriginalAnimations = {}
	local Animate = LocalPlayer.Character.Animate
	if Animate:FindFirstChild("pose") then
		local poseAnimation = Animate.pose:FindFirstChildOfClass("Animation")
		if poseAnimation then
			OriginalAnimations[3] = poseAnimation.AnimationId
		end
	end
	OriginalAnimations[1] = Animate.idle.Animation1.AnimationId
	OriginalAnimations[2] = Animate.idle.Animation2.AnimationId
	OriginalAnimations[4] = Animate.walk:FindFirstChildOfClass("Animation").AnimationId
	OriginalAnimations[5] = Animate.run:FindFirstChildOfClass("Animation").AnimationId
	OriginalAnimations[6] = Animate.jump:FindFirstChildOfClass("Animation").AnimationId
	OriginalAnimations[7] = Animate.climb:FindFirstChildOfClass("Animation").AnimationId
	OriginalAnimations[8] = Animate.fall:FindFirstChildOfClass("Animation").AnimationId
	if Animate:FindFirstChild("swim") then
		OriginalAnimations[9] = Animate.swim:FindFirstChildOfClass("Animation").AnimationId
		OriginalAnimations[10] = Animate.swimidle:FindFirstChildOfClass("Animation").AnimationId
	end
end

-- // Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ============================================================
-- // DATA: Emotes & Animation Packs
-- ============================================================

local Emotes = {
	['Fashion'] = 3333331310; 
	["Baby Dance"] = 4265725525; 
	["Cha-Cha"] = 6862001787; 
	['Monkey'] = 3333499508; 
	['Shuffle'] = 4349242221; 
	["Top Rock"] = 3361276673; 
	["Around Town"] = 3303391864; 
	["Fancy Feet"] = 3333432454; 
	["Hype Dance"] = 3695333486; 
	['Bodybuilder'] = 3333387824; 
	['Idol'] = 4101966434;
	['Curtsy'] = 4555816777;
	['Happy'] = 4841405708;
	["Quiet Waves"] = 7465981288;
	['Sleep'] = 4686925579;
	["Floss Dance"] = 5917459365;
	['Shy'] = 3337978742;
	['Godlike'] = 3337994105;
	["Hero Landing"] = 5104344710;
	["High Wave"] = 5915690960;
	['Cower'] = 4940563117;
	['Bored'] = 5230599789;
	["Show Dem Wrists -KSI"] = 7198989668;
	['Celebrate'] = 3338097973;
	['Dash'] = 582855105;
	['Beckon'] = 5230598276;
	['Haha'] = 3337966527;
	["Lasso Turn - Tai Verdes"] = 7942896991;
	["Line Dance"] = 4049037604;
	['Shrug'] = 3334392772;
	['Point2'] = 3344585679;
	['Stadium'] = 3338055167;
	['Confused'] = 4940561610;
	['Side to Side'] = 3333136415;
	['Old Town Road Dance - Lil Nas X"'] = 5937560570;
	['Hello'] = 3344650532;
	['Dolphin Dance'] = 5918726674;
	['Samba'] = 6869766175;
	['Break Dance'] = 5915648917;
	["Hips Poppin' - Zara Larsson"] = 6797888062;
	['Wake Up Call - KSI'] = 7199000883;
	['Greatest'] = 3338042785;
	['On The Outside - Twenty One'] = 7422779536;
	['Boxing Punch - KSI'] = 7202863182;
	['Sad'] = 4841407203;
	['Flowing Breeze'] = 7465946930;
	['Twirl'] = 3334968680;
	['Jumping Wave'] = 4940564896;
	['HOLIDAY Dance - Lil Nas X (LNX)'] = 5937558680;
	['Take Me Under - Zara Larsson'] = 6797890377;
	['Shuffle'] = 4349242221;
	['Dizzy'] = 3361426436;
	["Dancing' Shoes - Twenty One"] = 7404878500;
	['Fashionable'] = 3333331310;
	['Fast Hands'] = 4265701731;
	['Tree'] = 4049551434;
	['Agree'] = 4841397952;
	['Power Blast'] = 4841403964;
	['Swoosh'] = 3361481910;
	['Jumping Cheer'] = 5895324424;
	['Disagree'] = 4841401869;
	['Rodeo Dance - Lil Nas X (LNX)'] = 5918728267;
	["It Ain't My Fault - Zara Larsson"] = 6797891807;
	['Rock On'] = 5915714366;
	['Block Partier'] = 6862022283;
	['Dorky Dance'] = 4212455378;
	['Zombie'] = 4210116953;
	['AOK - Tai Verdes'] = 7942885103;
	['T'] = 3338010159;
	['Cobra Arms - Tai   Verdes'] = 7942890105;
	['Panini Dance - Lil Nas X (LNX)'] = 5915713518;
	['Fishing'] = 3334832150;
	['Robot'] = 3338025566;
	['Around Town'] = 3303391864;
	['Saturday Dance - Twenty One'] = 7422807549;
	['Top Rock'] = 3361276673;
	['Keeping Time'] = 4555808220;
	['Air Dance'] = 4555782893;
	['Fancy Feet'] = 3333432454;
	['Rock Guitar - Royal Blood'] = 6532134724;
	["Borock's Rage"] = 3236842542;
	["Ud'zal's Summoning"] = 3303161675;
	['Y'] = 4349285876;
	['Swan Dance'] = 7465997989;
	['Louder'] = 3338083565;
	['Up and Down - Twenty One'] = 7422797678;
	['Swish'] = 3361481910;
	['Drummer Moves - Twenty One'] = 7422527690;
	['Sneaky'] = 3334424322;
	['Heisman Pose'] = 3695263073;
	['Jacks'] = 3338066331;
	['Cha-Cha 2'] = 3695322025;
	['BURBERRY LOLA ATTITUDE - NIMBUS'] = 10147821284;
	['BURBERRY LOLA  ATTITUDE - GEM'] = 10147815602;
	['BURBERRY LOLA ATTITUDE - HYDRO'] = 10147823318;
	['BURBERRY LOLA ATTITUDE - BLOOM'] = 10147817997;
	['Superhero Reveal'] = 3695373233;
	['Air Guitar'] = 3695300085;
	['Dismissive Wave'] = 3333272779;
	['Country Line  Dance - Lil Nas X'] = 5915712534;
	['Salute'] = 3333474484;
	['Applaud'] = 5915693819;
	['Get Out'] = 3333272779;
	['Hwaiting (화이팅)'] = 9527885267;
	['Annyeong (안녕)'] = 9527883498;
	['Bunny Hop'] = 4641985101;
	['Sandwich Dance'] = 4406555273;
	['Hyperfast  5G Dance Move'] = 9408617181;
	['Victory - 24kGoldn'] = 9178377686;
	['Tantrum'] = 5104341999;
	['Rock Star - Royal Blood'] = 10714400171;
	['Drum Solo - Royal Blood'] = 6532839007;
	['Drum Master - Royal Blood'] = 6531483720;
	['High Hands'] = 9710985298;
	['Tilt'] = 3334538554;
	['Gashina - SUNMI'] = 9527886709;
	['Chicken Dance'] = 4841399916;
	["You can't sit with us - Sunmi"] = 9983520970;
	["Frosty Flair - Tommy Hilfiger"] = 10214311282;
	["Floor Rock Freeze - Tommy Hilfiger"] = 10214314957;
	['Boom Boom Clap - George Ezra'] = 10370346995;
	['Cartwheel - George Ezra'] = 10370351535;
	['Chill Vibes - George Ezra'] = 10370353969; 
	['Sidekicks - George Ezra'] = 10370362157;
	['The Conductor - George Ezra'] = 10370359115;
	['Super Charge'] = 10478338114;
	['Swag Walk'] = 10478341260;
	['Mean Mug - Tommy Hilfiger'] = 10214317325;
	['V Pose - Tommy Hilfiger'] = 10214319518;
	['Uprise - Tommy Hilfiger'] = 10275008655;
	['2 Baddies Dance Move - NCT 127'] = 12259828678; 
	['Kick It Dance Move - NCT 127'] = 12259826609;
	['Sticker Dance Move - NCT 127'] = 12259825026;
	['Elton John - Rock Out'] = 11753474067;
	['Elton John - Heart Skip'] = 11309255148;
	['Elton John - Still Standing'] = 11444443576;
	['Elton John - Elevate'] = 11394033602;
	['Elton John - Cat Man'] = 11444441914;
	['Elton John - Piano Jump'] = 11453082181;
	['Alo Yoga Pose - Triangle'] = 12507084541;
	['Alo Yoga Pose - Warrior II'] = 12507083048;
	['Alo Yoga Pose - Lotus Position'] = 12507085924;
	['Alo Yoga Pose - Warrior II'] = 12507083048;
	['Alo Yoga Pose - Triangle'] = 12507084541;
	['TWICE-Moonlight-Sunrise'] = 12714233242;
	['TWICE-Set-Me-Free-Dance-1'] = 12714228341;
	['TWICE-Set-Me-Free-Dance-2'] = 12714231087;
	['Ay-Yo-Dance-Move-NCT-127'] = 12804157977;
	['TWICE-The-Feels'] = 12874447851;
	['Zombie'] = 10714089137;
	['Rise-Above-The-Chainsmokers'] = 12992262118;
	['TWICE-What-Is-Love'] = 13327655243;
	['Man-City-Bicycle-Kick'] = 13421057998;
	['TWICE-Fancy'] = 13520524517;
	['TWICE Pop by Nayeon'] = 13768941455;
	['Tommy - Archer'] = 13823324057;
	['TWICE-Pop-by-Nayeon'] = 13768941455;
	['Man City Backflip'] = 13694100677;
	['Man-City-Scorpion-Kick'] = 13694096724;
	['Arm Twist'] = 10713968716;
	['Tommy - Archer'] = 13823324057;
	['YUNGBLUD – HIGH KICK'] = 14022936101;
	['TWICE Like Ooh-Ahh'] = 14123781004;
	['Baby Queen - Air Guitar & Knee Slide'] = 14352335202;
	['Baby Queen - Dramatic Bow'] = 14352337694;
	['Baby Queen - Face Frame'] = 14352340648;
	['Baby Queen - Bouncy Twirl'] = 14352343065;
	['Baby Queen - Strut'] = 14352362059;
	['BLACKPINK Pink Venom - Get em Get em Get em'] = 14548619594;
	['BLACKPINK Pink Venom - I Bring the Pain Like…'] = 14548620495;
	['BLACKPINK Pink Venom - Straight to Ya Dome'] = 14548621256;
	['TWICE LIKEY'] = 14899979575;
	['TWICE Feel Special'] = 14899980745;
	['BLACKPINK Shut Down - Part 1'] = 14901306096;
	['BLACKPINK Shut Down - Part 2'] = 14901308987;
	["Bone Chillin' Bop"] = 15122972413;
	['Paris Hilton - Sliving For The Groove'] = 15392759696;
	['Paris Hilton - Iconic IT-Grrrl'] = 15392756794;
	['Paris Hilton - Checking My Angles'] = 15392752812;
	['BLACKPINK JISOO Flower'] = 15439354020;
	['BLACKPINK JENNIE You and Me'] = 15439356296;
	['Rock n Roll'] = 15505458452;
	['Air Guitar'] = 15505454268;
	['Victory Dance'] = 15505456446;
	['Flex Walk'] = 15505459811;
	['Olivia Rodrigo Head Bop'] = 15517864808;
	['Olivia Rodrigo good 4 u'] = 15517862739;
	['Olivia Rodrigo Fall Back to Float'] = 15549124879;
	["Nicki Minaj That's That Super Bass"] = 15571446961;
	['Nicki Minaj Boom Boom Boom'] = 15571448688;
	['Nicki Minaj Anaconda'] = 15571450952;
	['Nicki Minaj Starships'] = 15571453761;
	['Yungblud Happier Jump'] = 15609995579;
	['Festive Dance'] = 15679621440;
	['BLACKPINK LISA Money'] = 15679623052;
	['BLACKPINK ROSÉ On The Ground'] = 15679624464;
	['Imagine Dragons - “Bones” Dance'] = 15689279687;
	['GloRilla - "Tomorrow" Dance'] = 15689278184;
	['d4vd - Backflip'] = 15693621070;
	['ericdoa - dance'] = 15698402762;
	['Cuco - Levitate'] = 15698404340;
	['Mean Girls Dance Break'] = 15963314052;
	['Paris Hilton Sanasa'] = 16126469463;
	['BLACKPINK Ice Cream'] = 16181797368;
	['BLACKPINK Kill This Love'] = 16181798319;
	['TWICE I GOT YOU part 1'] = 16215030041;
	['TWICE I GOT YOU part 2'] = 16256203246;
	["Dave's Spin Move - Glass Animals"] = 16272432203;
	['Sol de Janeiro - Samba'] = 16270690701;
	['Beauty Touchdown'] = 16302968986;
	['Skadoosh Emote - Kung Fu Panda 4'] = 16371217304;
	['Jawny - Stomp'] = 16392075853;
	['Mae Stephens - Piano Hands'] = 16553163212;
	['BLACKPINK Boombayah Emote'] = 16553164850;
	['BLACKPINK DDU-DU DDU-DU'] = 16553170471;
	['HIPMOTION - Amaarae'] = 16572740012;
	['Mae Stephens – Arm Wave'] = 16584481352;
	['Wanna play?'] = 16646423316;
	['BLACKPINK-How-You-Like-That'] = 16874470507;
	['BLACKPINK - Lovesick Girls'] = 16874472321;
	['Mini Kong'] = 17000021306;
	["HUGO Let's Drive!"] = 17360699557;
	['Wisp - air guitar'] = 17370775305;
	['Vans Ollie'] = 18305395285;
	['Sturdy Dance - Ice Spice'] = 17746180844;
	['Shuffle'] = 17748314784;
	['Rolling Stones Guitar Strum'] = 18148804340;
	['Rock Out - Bebe Rexha'] = 18225053113;
	['SpongeBob Imaginaaation 🌈'] = 18443237526;
	['SpongeBob Dance'] = 18443245017;
	['Shrek Roar'] = 18524313628;
	['Team USA Breaking Emote'] = 18526288497;
	['NBA WNBA Fadeaway'] = 18526362841;
	['Vroom Vroom'] = 18526397037;
	['TMNT Dance'] = 18665811005;
	['Olympic Dismount'] = 18665825805;
    ["BLACKPINK As If It's Your Last"] = 18855536648;
    ["BLACKPINK Don't know what to do"] = 18855531354;
    ['TWICE ABCD by Nayeon'] = 18933706381;
    ['Charli xcx - Apple Dance'] = 18946844622;
	['The Zabb'] = 129470135909814;
	['Fashion Klossette - Runway my way'] = 80995190624232;
	['ALTÉGO - Couldn’t Care Less'] = 107875941017127;
	['Fashion Roadkill'] = 136831243854748;
	['Skibidi Toilet - Titan Speakerman Laser Spin'] = 134283166482394;
	['Chappell Roan HOT TO GO!'] = 85267023718407;
	['Secret Handshake Dance'] = 71243990877913;
	['KATSEYE - Touch'] = 135876612109535;
	['Fashion Spin'] = 131669256082047;
	['TWICE Strategy'] = 97311229290836;
	['NBA Monster Dunk'] = 132748833449150;
	['DearALICE - Ariana'] = 134318425949290;
	['The Weeknd Starboy Strut'] = 71105746210464;
	['The Weeknd Opening Night'] = 133110725387025;
	['Robot M3GAN'] = 125803725853577;  
	["M3GAN's Dance"] = 99649534578309;
	['Rasputin – Boney M.'] = 114872820353992;
	['Thanos Happy Jump - Squid Game'] = 97611664803614;
	['Young-hee Head Spin - Squid Game'] = 112011282168475;
	['TWICE Takedown'] = 140182843839424;
	['Stray Kids Walkin On Water'] = 125064469983655;
	['TWICE TAKEDOWN DANCE 2'] = 127104635954695;
}
local Animations = {
 Emotes = {Weight=9, Weight2=1},
 Stylish = {Idle = 616136790, Idle2=616138447, Idle3=886888594, Walk=616146177,Run=616140816,Jump=616139451,Climb=616133594,Fall=616134815, Swim=616143378, SwimIdle=616144772, Weight=9, Weight2=1},
 Zombie = {Idle = 616158929, Idle2=616160636, Idle3=885545458, Walk=616168032,Run=616163682,Jump=616161997,Climb=616156119,Fall=616157476, Swim=616165109, SwimIdle=616166655, Weight=9, Weight2=1},
 Robot = {Idle = 616088211, Idle2=616089559, Idle3=885531463, Walk=616095330,Run=616091570,Jump=616090535,Climb=616086039,Fall=616087089, Swim=616092998, SwimIdle=616094091, Weight=9, Weight2=1},
 Toy = {Idle = 782841498, Idle2=782845736, Idle3=980952228, Walk=782843345,Run=782842708,Jump=782847020,Climb=782843869,Fall=782846423, Swim=782844582, SwimIdle=782845186, Weight=9, Weight2=1},
 Cartoony = {Idle = 742637544, Idle2=742638445, Idle3=885477856, Walk=742640026,Run=742638842,Jump=742637942,Climb=742636889,Fall=742637151, Swim=742639220, SwimIdle=742639812, Weight=9, Weight2=1},
 Superhero = {Idle = 616111295, Idle2=616113536, Idle3=885535855, Walk=616122287,Run=616117076,Jump=616115533,Climb=616104706,Fall=616108001, Swim=616119360, SwimIdle=616120861, Weight=9, Weight2=1},
 Mage = {Idle = 707742142, Idle2=707855907, Idle3=885508740, Walk=707897309,Run=707861613,Jump=707853694,Climb=707826056,Fall=707829716, Swim=707876443, SwimIdle=707894699, Weight=9, Weight2=1},
 Levitation = {Idle = 616006778, Idle2=616008087, Idle3=886862142, Walk=616013216,Run=616010382,Jump=616008936,Climb=616003713,Fall=616005863, Swim=616011509, SwimIdle=616012453, Weight=9, Weight2=1},
 Vampire = {Idle = 1083445855, Idle2=1083450166, Idle3=1088037547, Walk=1083473930,Run=1083462077,Jump=1083455352,Climb=1083439238,Fall=1083443587, Swim=1083464683, SwimIdle=1083467779, Weight=9, Weight2=1},
 Elder = {Idle = 845397899, Idle2=845400520, Idle3=901160519, Walk=845403856,Run=845386501,Jump=845398858,Climb=845392038,Fall=845396048, Swim=845401742, SwimIdle=845403127, Weight=9, Weight2=1},
 Werewolf = {Idle = 1083195517, Idle2=1083214717, Idle3=1099492820, Walk=1083178339,Run=1083216690,Jump=1083218792,Climb=1083182000,Fall=1083189019, Swim=1083222527, SwimIdle=1083225406, Weight=9, Weight2=1},
 Knight = {Idle = 657595757, Idle2=657568135, Idle3=885499184, Walk=657552124,Run=657564596,Jump=658409194,Climb=658360781,Fall=657600338, Swim=657560551, SwimIdle=657557095, Weight=9, Weight2=1},
 Bold = {Idle = 16738333868, Idle2=16738334710, Idle3=16738335517, Walk=16738340646,Run=16738337225,Jump=16738336650,Climb=16738332169,Fall=16738333171, Swim=16738339158, SwimIdle=16738339817, Weight=9, Weight2=1},
 Astronaut = {Idle = 891621366, Idle2=891633237, Idle3=1047759695, Walk=891667138,Run=891636393,Jump=891627522,Climb=891609353,Fall=891617961, Swim=891639666, SwimIdle=891663592, Weight=9, Weight2=1},
 Bubbly = {Idle = 910004836, Idle2=910009958, Idle3=1018536639, Walk=910034870,Run=910025107,Jump=910016857,Climb=909997997,Fall=910001910, Swim=910028158, SwimIdle=910030921, Weight=9, Weight2=1},
 Pirate = {Idle = 750781874, Idle2=750782770, Idle3=885515365, Walk=750785693,Run=750783738,Jump=750782230,Climb=750779899,Fall=750780242, Swim=750784579, SwimIdle=750785176, Weight=9, Weight2=1},
 Rthro = {Idle = 2510196951, Idle2=2510197257, Idle3=3711062489, Walk=2510202577,Run=2510198475,Jump=2510197830,Climb=2510192778,Fall=2510195892, Swim=2510199791, SwimIdle=2510201162, Weight=9, Weight2=1},
 Ninja = {Idle=656117400, Idle2=656118341, Idle3=886742569, Walk=656121766, Run=656118852, Jump=656117878, Climb=656114359,Fall=656115606, Swim=656119721, SwimIdle=656121397, Weight=9, Weight2=1},
 Oldschool = {Idle=5319828216, Idle2=5319831086, Idle3=5392107832, Walk=5319847204, Run=5319844329, Jump=5319841935, Climb=5319816685, Fall=5319839762, Swim=5319850266, SwimIdle=5319852613, Weight=9, Weight2=1},
 Realistic = {Idle=17172918855, Idle2=17173014241, Idle3=17173014241, Walk=11600249883, Run=11600211410, Jump=11600210487, Climb=11600205519, Fall=11600206437, Swim=11600212676, SwimIdle=11600213505, Weight=9, Weight2=1},
 ['No Boundaries'] = {Idle=18747067405, Idle2=18747063918, Idle3=18747063918, Walk=18747074203, Run=18747070484, Jump=18747069148, Climb=18747060903,Fall=18747062535, Swim=18747073181, SwimIdle=18747071682, Weight=9, Weight2=1},
 ['NFL Animation'] = {Idle=92080889861410, Idle2=74451233229259, Idle3=80884010501210, Walk=110358958299415, Run=117333533048078, Jump=119846112151352, Climb=134630013742019,Fall=129773241321032, Swim=132697394189921, SwimIdle=79090109939093, Weight=9, Weight2=1},
 ['Adidas Aura'] = {Idle=110211186840347,Idle2=114191137265065,Idle3=99129837931148,Walk=83842218823011,Run=118320322718866,Jump=109996626521204,Climb=97824616490448,Fall=95603166884636,Swim=134530128383903,SwimIdle=94922130551805,Weight=9,Weight2=1},
 ['Adidas Sports'] = {Idle=18537376492, Idle2=18537371272, Idle3=18537374150, Walk=18537392113, Run=18537384940, Jump=18537380791, Climb=18537363391,Fall=18537367238, Swim=18537389531, SwimIdle=18537387180, Weight=9, Weight2=1},
 ['Adidas Community '] = {Idle=122257458498464, Idle2=102357151005774, Idle3=89262795687364, Walk=122150855457006, Run=82598234841035, Jump=75290611992385, Climb=88763136693023,Fall=98600215928904, Swim=133308483266208, SwimIdle=109346520324160, Weight=9, Weight2=1},
 ['Wickled Popular'] = {Idle=118832222982049, Idle2=76049494037641, Idle3=138255200176080, Walk=92072849924640, Run=72301599441680, Jump=104325245285198, Climb=131326830509784, Fall=121152442762481, Swim=99384245425157, SwimIdle=113199415118199, Weight=9, Weight2=1},
 ['Catwalk Glam'] = {Idle=133806214992291, Idle2=94970088341563, Idle3=87105332133518, Walk=109168724482748, Run=81024476153754, Jump=116936326516985, Climb=119377220967554,Fall=92294537340807, Swim=134591743181628, SwimIdle=98854111361360, Weight=9, Weight2=1},
 Princess = {Idle=941003647, Idle2=941013098, Idle3=1159195712, Walk=941028902, Run=941015281, Jump=0941008832, Climb=940996062, Fall=941000007, Swim=941018893, SwimIdle=941025398, Weight=9, Weight2=1},
 Confident = {Idle=1069977950, Idle2=1069987858, Idle3=1116160740, Walk=1070017263, Run=1070001516, Jump=1069984524, Climb=1069946257, Fall=1069973677, Swim=1070009914, SwimIdle=1070012133, Weight=9, Weight2=1},
 Popstar = {Idle=1212900985, Idle2=1150842221, Idle3=1239733474, Walk=1212980338, Run=1212980348, Jump=1212954642, Climb=1213044953, Fall=1212900995, Swim=1212852603, SwimIdle=1070012133, Weight=9, Weight2=1},
 Patrol = {Idle=1149612882, Idle2=1150842221, Idle3=1159573567, Walk=1151231493, Run=1150967949, Jump=1150944216, Climb=1148811837, Fall=1148863382, Swim=1151204998, SwimIdle=1151221899, Weight=9, Weight2=1},
 Sneaky = {Idle=1132473842, Idle2=1132477671, Idle3="None", Walk=1132510133, Run=1132494274, Jump=1132489853, Climb=1132461372, Fall=1132469004, Swim=1132500520, SwimIdle=1132506407, Weight=9, Weight2=1},
 Cowboy = {Idle=1014390418, Idle2=1014398616, Idle3=1159487651, Walk=1014421541, Run=1014401683, Jump=1014394726, Climb=1014380606, Fall=1014384571, Swim=1014406523, SwimIdle=1014411816, Weight=9, Weight2=1},
 Ghost = {Idle=616006778, Idle2=616008087, Idle3=616008087, Walk=616013216, Run=616013216, Jump=616008936, Climb=0, Fall=616005863, Swim=616011509, SwimIdle=616012453, Weight=9, Weight2=1},
 ['Ghost 2'] = {Idle=1151221899, Idle2=1151221899, Idle3="None", Walk=1151221899, Run=1151221899, Jump=1151221899, Climb=0, Fall=1151221899, Swim=16738339158, SwimIdle=1151221899, Weight=9, Weight2=1},
 ['Mr. Toilet'] = {Idle=4417977954, Idle2=4417978624, Idle3=4441285342, Walk=2510202577, Run=4417979645, Jump=2510197830, Climb=2510192778, Fall=2510195892, Swim=2510199791, SwimIdle=2510201162, Weight=9, Weight2=1},
 Udzal = {Idle=3303162274, Idle2=3303162549, Idle3=3710161342, Walk=3303162967, Run=3236836670, Jump=2510197830, Climb=2510192778, Fall=2510195892, Swim=2510199791, SwimIdle=2510201162, Weight=9, Weight2=1},
 ['Oinan Thickhoof'] = {Idle = 657595757, Idle2=657568135, Idle3=885499184, Walk=2510202577, Run=3236836670, Jump=2510197830, Climb=2510192778, Fall=2510195892, Swim=2510199791, SwimIdle=2510201162, Weight=9, Weight2=1},
 Borock = {Idle = 3293641938, Idle2=3293642554, Idle3=3710131919, Walk=2510202577, Run=3236836670, Jump=2510197830, Climb=2510192778, Fall=2510195892, Swim=2510199791, SwimIdle=2510201162, Weight=9, Weight2=1},
 ['Blocky Mech'] = {Idle=4417977954, Idle2=4417978624, Idle3=4441285342, Walk=2510202577, Run=4417979645, Jump=2510197830, Climb=2510192778, Fall=2510195892, Swim=2510199791, SwimIdle=2510201162, Weight=9, Weight2=1},
 ['Stylized Female'] = {Idle=4708191566, Idle2=4708192150, Idle3=121221, Walk=4708193840, Run=4708192705, Jump=4708188025, Climb=4708184253, Fall=4708186162, Swim=4708189360, SwimIdle=4708190607, Weight=9, Weight2=1},
 R15 = {Idle=4211217646, Idle2=4211218409, Idle3="None", Walk=4211223236, Run=4211220381, Jump=4211219390, Climb=4211214992, Fall=4211216152, Swim=4211221314, SwimIdle=4374694239, Weight=9, Weight2=1},
 Mocap = {Idle=913367814, Idle2=913373430, Idle3="None", Walk=913402848, Run=913376220, Jump=913370268, Climb=913362637, Fall=913365531, Swim=913384386, SwimIdle=913389285, Weight=9, Weight2=1},
 ['Wicked "Dancing Through Life"'] = {Idle=92849173543269,Idle2=132238900951109,Idle3=87867222929430,Walk=73718308412641,Run=135515454877967,Jump=78508480717326,Climb=129447497744818,Fall=78147885297412,Swim=110657013921774,SwimIdle=129183123083281,Weight=9,Weight2=1},
 Unboxed = {Idle=98281136301627,Idle2=138183121662404,Idle3=133117300343405,Walk=90478085024465,Run=134824450619865,Jump=121454505477205,Climb=121145883950231,Fall=94788218468396,Swim=105962919001086,SwimIdle=129126268464847,Weight=9,Weight2=1}
}

-- ============================================================
-- // STATE
-- ============================================================

local CurrentAnimationPack = nil   -- name of the currently equipped animation pack (nil = default)
local CurrentEmoteName = nil       -- name of the currently playing emote (nil = none)
local CurrentEmoteTrack = nil

getgenv().Favorites = getgenv().Favorites or { Animation = {}, Emote = {} }
local Favorites = getgenv().Favorites

-- ============================================================
-- // CATEGORIZATION (keyword based, so new table entries auto-sort)
-- ============================================================

local function Categorize(name, keywordMap, fallback)
	local lowerName = string.lower(name)
	for category, keywords in pairs(keywordMap) do
		for _, keyword in ipairs(keywords) do
			if string.find(lowerName, string.lower(keyword), 1, true) then
				return category
			end
		end
	end
	return fallback
end

local AnimationCategoryKeywords = {
	["Fantasy & Creature"] = { "zombie", "vampire", "werewolf", "elder", "knight", "mage", "ninja", "pirate", "ghost", "udzal", "thickhoof", "borock", "toilet", "blocky mech" },
	["Sci-Fi & Futuristic"] = { "robot", "astronaut", "rthro", "levitation", "stylized female" },
	["Style & Character"] = { "stylish", "toy", "cartoony", "superhero", "bubbly", "bold", "princess", "confident", "popstar", "patrol", "sneaky", "cowboy" },
	["Brand & Realistic"] = { "adidas", "nfl", "no boundaries", "wickled", "catwalk", "realistic", "oldschool", "r15", "mocap", "wicked", "unboxed" },
}

local EmoteCategoryKeywords = {
	["Artists & Music"] = {
		"blackpink", "twice", "elton john", "nicki minaj", "adidas", "tommy hilfiger", "paris hilton",
		"george ezra", "nct", "olivia rodrigo", "chappell roan", "charli xcx", "ice spice", "bebe rexha",
		"rolling stones", "glass animals", "glorilla", "imagine dragons", "cuco", "ericdoa", "d4vd",
		"yungblud", "katseye", "weeknd", "sunmi", "baby queen", "alo yoga", "rasputin", "royal blood",
		"zara larsson", "lil nas x", "24kgoldn", "twenty one", "sol de janeiro", "mae stephens", "jawny",
		"hipmotion", "amaarae", "dearalice", "tai verdes", "ksi", "man city", "stray kids", "jisoo", "jennie",
	},
	["Movies, Games & Pop Culture"] = {
		"squid game", "m3gan", "kung fu panda", "spongebob", "shrek", "tmnt", "mean girls",
		"skibidi toilet", "nba", "wnba", "vans", "hugo", "wisp", "olympic",
	},
	["Dance Moves"] = { "dance", "shuffle", "twirl", "samba" },
}

local function BuildCategories(dataTable, keywordMap, fallback)
	local categories = {}
	local sortedNames = {}
	for name in pairs(dataTable) do
		table.insert(sortedNames, name)
	end
	table.sort(sortedNames)

	for _, name in ipairs(sortedNames) do
		local category = Categorize(name, keywordMap, fallback)
		categories[category] = categories[category] or {}
		table.insert(categories[category], name)
	end
	return categories
end

local AnimationCategories = BuildCategories(Animations, AnimationCategoryKeywords, "Classic & Misc")
local EmoteCategories = BuildCategories(Emotes, EmoteCategoryKeywords, "Classic & Misc")
local animCategoryOrder = { "Style & Character", "Fantasy & Creature", "Sci-Fi & Futuristic", "Brand & Realistic", "Classic & Misc" }
local emoteCategoryOrder = { "Artists & Music", "Movies, Games & Pop Culture", "Dance Moves", "Classic & Misc" }

local totalAnimations, totalEmotes = 0, 0
for _ in pairs(Animations) do totalAnimations = totalAnimations + 1 end
for _ in pairs(Emotes) do totalEmotes = totalEmotes + 1 end

-- ============================================================
-- // CORE PLAYBACK FUNCTIONS
-- ============================================================

local function StopAllTracks()
	local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end
	for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
		track:Stop()
	end
end

local function RefreshAnims()
	repeat task.wait() until LocalPlayer.Character
		and LocalPlayer.Character:FindFirstChild("Animate")
		and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		and LocalPlayer.Character.Humanoid:FindFirstChild("Animator")
	LocalPlayer.Character.Animate.Disabled = true
	StopAllTracks()
	LocalPlayer.Character.Animate.Disabled = false
	local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local originalSpeed = Humanoid.WalkSpeed
	Humanoid.WalkSpeed = 0
	task.wait()
	Humanoid.WalkSpeed = originalSpeed
end

local function EquipAnimation(packName)
	local pack = Animations[packName]
	if not pack then return end
	repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
	local Animate = LocalPlayer.Character.Animate

	if Animate:FindFirstChild("idle") then
		Animate.idle.Animation1.AnimationId = URL .. pack.Idle
		Animate.idle.Animation1.Weight.Value = tostring(pack.Weight)
		Animate.idle.Animation2.Weight.Value = tostring(pack.Weight2)
		Animate.idle.Animation2.AnimationId = URL .. pack.Idle2
	end
	if pack.Idle3 and Animate:FindFirstChild("pose") then
		Animate.pose:FindFirstChildOfClass("Animation").AnimationId = URL .. pack.Idle3
	end
	Animate.walk:FindFirstChildOfClass("Animation").AnimationId = URL .. pack.Walk
	Animate.run:FindFirstChildOfClass("Animation").AnimationId = URL .. pack.Run
	Animate.jump:FindFirstChildOfClass("Animation").AnimationId = URL .. pack.Jump
	Animate.climb:FindFirstChildOfClass("Animation").AnimationId = URL .. pack.Climb
	Animate.fall:FindFirstChildOfClass("Animation").AnimationId = URL .. pack.Fall
	if Animate:FindFirstChild("swim") then
		Animate.swim:FindFirstChildOfClass("Animation").AnimationId = URL .. pack.Swim
		Animate.swimidle:FindFirstChildOfClass("Animation").AnimationId = URL .. pack.SwimIdle
	end

	RefreshAnims()
	CurrentAnimationPack = packName
	WindUI:Notify({ Title = "Animation Equipped", Content = packName .. " is now active.", Duration = 3, Icon = "sparkles" })
end

local function DefaultAnimations()
	if not getgenv().OriginalAnimations then return end
	repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
	local Animate = LocalPlayer.Character.Animate
	local O = getgenv().OriginalAnimations

	if O[1] then Animate.idle.Animation1.AnimationId = O[1] end
	if O[2] then Animate.idle.Animation2.AnimationId = O[2] end
	if O[3] and Animate:FindFirstChild("pose") then
		Animate.pose:FindFirstChildOfClass("Animation").AnimationId = O[3]
	end
	if O[4] then Animate.walk:FindFirstChildOfClass("Animation").AnimationId = O[4] end
	if O[5] then Animate.run:FindFirstChildOfClass("Animation").AnimationId = O[5] end
	if O[6] then Animate.jump:FindFirstChildOfClass("Animation").AnimationId = O[6] end
	if O[7] then Animate.climb:FindFirstChildOfClass("Animation").AnimationId = O[7] end
	if O[8] then Animate.fall:FindFirstChildOfClass("Animation").AnimationId = O[8] end
	if Animate:FindFirstChild("swim") then
		if O[9] then Animate.swim:FindFirstChildOfClass("Animation").AnimationId = O[9] end
		if O[10] then Animate.swimidle:FindFirstChildOfClass("Animation").AnimationId = O[10] end
	end

	RefreshAnims()
	CurrentAnimationPack = nil
	WindUI:Notify({ Title = "Default Restored", Content = "All animations reset to default.", Duration = 3, Icon = "rotate-ccw" })
end

local DefaultEmote -- forward declaration so EquipEmote's auto-revert closure can call it

local function EquipEmote(emoteName)
	local id = Emotes[emoteName]
	if not id then return end
	local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end

	if CurrentEmoteTrack then
		CurrentEmoteTrack:Stop()
	end

	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://" .. id
	CurrentEmoteTrack = Humanoid:LoadAnimation(Animation)
	CurrentEmoteTrack.Priority = Enum.AnimationPriority.Idle
	CurrentEmoteTrack.Looped = false
	CurrentEmoteTrack:Play(0)

	-- Auto-revert to default once this specific emote finishes playing on its own.
	-- The CurrentEmoteTrack == thisTrack check prevents this from firing DefaultEmote
	-- again if the emote was manually stopped or replaced by another emote first.
	local thisTrack = CurrentEmoteTrack
	thisTrack.Stopped:Connect(function()
		if CurrentEmoteTrack == thisTrack then
			DefaultEmote()
		end
	end)

	if not LocalPlayer.Character.Animate.Disabled then
		LocalPlayer.Character.Animate.Disabled = true
	end

	CurrentEmoteName = emoteName
	WindUI:Notify({ Title = "Emote Equipped", Content = emoteName, Duration = 2, Icon = "party-popper" })
end

DefaultEmote = function()
	if CurrentEmoteTrack then
		CurrentEmoteTrack:Stop()
		CurrentEmoteTrack = nil
	end
	if LocalPlayer.Character:FindFirstChild("Animate") then
		LocalPlayer.Character.Animate.Disabled = false
	end
	CurrentEmoteName = nil
	WindUI:Notify({ Title = "Default Restored", Content = "Emote stopped, back to default.", Duration = 3, Icon = "rotate-ccw" })
end

-- ============================================================
-- // SAVE / LOAD CONFIGURATION
-- ============================================================

local function SetToList(set)
	local list = {}
	for name, on in pairs(set) do
		if on then table.insert(list, name) end
	end
	return list
end

local function ListToSet(list)
	local set = {}
	if list then
		for _, name in ipairs(list) do
			set[name] = true
		end
	end
	return set
end

local function SaveConfiguration()
	if not writefile then
		WindUI:Notify({ Title = "Save Failed", Content = "Your executor doesn't support writefile.", Duration = 4, Icon = "x" })
		return
	end
	local config = {
		animation = CurrentAnimationPack,
		emote = CurrentEmoteName,
		favoriteAnimations = SetToList(Favorites.Animation),
		favoriteEmotes = SetToList(Favorites.Emote),
	}
	local ok, encoded = pcall(function() return HttpService:JSONEncode(config) end)
	if not ok then
		WindUI:Notify({ Title = "Save Failed", Content = "Could not encode configuration.", Duration = 4, Icon = "x" })
		return
	end
	writefile(CONFIG_FILE, encoded)
	WindUI:Notify({ Title = "Configuration Saved", Content = "Your setup has been saved.", Duration = 3, Icon = "save" })
end

-- Forward declarations (assigned once the tabs/buttons are built below)
local RefreshFavoritesTab

local function LoadConfiguration()
	if not (isfile and isfile(CONFIG_FILE)) then
		WindUI:Notify({ Title = "No Save Found", Content = "Save a configuration first.", Duration = 3, Icon = "info" })
		return
	end
	local ok, raw = pcall(readfile, CONFIG_FILE)
	if not ok then
		WindUI:Notify({ Title = "Load Failed", Content = "Could not read the save file.", Duration = 4, Icon = "x" })
		return
	end
	local decodeOk, config = pcall(function() return HttpService:JSONDecode(raw) end)
	if not decodeOk then
		WindUI:Notify({ Title = "Load Failed", Content = "Save file is corrupted.", Duration = 4, Icon = "x" })
		return
	end

	Favorites.Animation = ListToSet(config.favoriteAnimations)
	Favorites.Emote = ListToSet(config.favoriteEmotes)

	if config.animation and Animations[config.animation] then
		EquipAnimation(config.animation)
	end
	if config.emote and Emotes[config.emote] then
		EquipEmote(config.emote)
	end

	if RefreshFavoritesTab then RefreshFavoritesTab() end
	WindUI:Notify({ Title = "Configuration Loaded", Content = "Your saved setup has been applied.", Duration = 3, Icon = "check" })
end

-- ============================================================
-- // UI HELPERS
-- ============================================================

-- Some WindUI builds name their search-input element differently; try a few
-- so the search bar works regardless of the exact WindUI version installed.
local function TryCreateSearch(tabObj, placeholder, onChange)
	local attempts = {
		function() return tabObj:Input({ Title = "Search", Placeholder = placeholder, Callback = onChange }) end,
		function() return tabObj:Textbox({ Title = "Search", Placeholder = placeholder, Callback = onChange }) end,
		function() return tabObj:SearchBar({ Placeholder = placeholder, Callback = onChange }) end,
	}
	for _, attempt in ipairs(attempts) do
		local ok, element = pcall(attempt)
		if ok and element then
			return element
		end
	end
	return nil
end

-- Destroys previously created dynamic elements so a tab can be rebuilt
-- (used when the search text changes or a favorite is toggled).
local function ClearElements(elementList)
	for _, element in ipairs(elementList) do
		pcall(function()
			if element.Destroy then
				element:Destroy()
			elseif element.Instance then
				element.Instance:Destroy()
			end
		end)
	end
	table.clear(elementList)
end

-- ============================================================
-- // UI: WINDOW
-- ============================================================

local UserInputService = game:GetService("UserInputService")
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local WindowSize = IsMobile and UDim2.fromOffset(380, 460) or UDim2.fromOffset(660, 520)

local VALID_KEYS = { "imongmama" } -- keep this in sync with KeySystem.Key below

local Window = WindUI:CreateWindow({
	Title = "DweeybzSCRPT",
	Icon = "sparkles",
	Author = "DweeybzSCRPT",
	Folder = CONFIG_FOLDER,
	Size = WindowSize,
	MinSize = Vector2.new(380, 320),
	Theme = "Dark",
	ToggleKey = Enum.KeyCode.RightControl,
	HideSearchBar = false,
	Resizable = true,

	KeySystem = {
		Key = VALID_KEYS,
		Note = "Enter the key to unlock DweeybzSCRPT.",
		SaveKey = false, -- always prompts for the key on every session
		KeyValidator = function(enteredKey)
			for _, validKey in ipairs(VALID_KEYS) do
				if enteredKey == validKey then
					return true
				end
			end
			WindUI:Notify({
				Title = "Invalid Key",
				Content = "The key you entered is incorrect. Please try again.",
				Duration = 4,
				Icon = "x",
			})
			return false
		end,
	},

	-- // Floating toggle button on BOTH mobile and PC, draggable either way.
	-- // PC still also has ToggleKey (RightControl) as a shortcut.
	OpenButton = {
		Title = "DweeybzSCRPT",
		Enabled = true,
		OnlyMobile = false,
		Draggable = true,
		Scale = IsMobile and 0.55 or 0.45,
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 2,
		Color = ColorSequence.new(
			Color3.fromHex("#7775F2"),
			Color3.fromHex("#257AF7")
		),
	},
})

-- ============================================================
-- // GENERIC LIST-TAB BUILDER (Animations / Emotes)
-- ============================================================
-- Builds a searchable, categorized button list where every entry has:
--   • a main button that instantly equips it
--   • a small favorite toggle button (★ / ☆)
-- plus a single "DEFAULT" button that clears whatever is currently applied.

local function BuildListTab(tabObj, kind, dataTable, categories, categoryOrder, equipFn, favSet)
	local dynamicElements = {}
	local favDropdown = nil

	local function AllNames()
		local names = {}
		for name in pairs(dataTable) do table.insert(names, name) end
		table.sort(names)
		return names
	end

	local function CurrentFavList()
		local list = {}
		for name, on in pairs(favSet) do
			if on then table.insert(list, name) end
		end
		table.sort(list)
		return list
	end

	local function Rebuild(filterText)
		ClearElements(dynamicElements)
		filterText = filterText and string.lower(filterText) or ""

		for _, categoryName in ipairs(categoryOrder) do
			local items = categories[categoryName]
			if items and #items > 0 then
				local matched = {}
				for _, itemName in ipairs(items) do
					if filterText == "" or string.find(string.lower(itemName), filterText, 1, true) then
						table.insert(matched, itemName)
					end
				end
				if #matched > 0 then
					local Section = tabObj:Section({ Title = categoryName .. " (" .. #matched .. ")" })
					table.insert(dynamicElements, Section)
					for _, itemName in ipairs(matched) do
						local mainBtn = Section:Button({
							Title = itemName,
							Icon = "play",
							Callback = function() equipFn(itemName) end,
						})
						table.insert(dynamicElements, mainBtn)
					end
				end
			end
		end
	end

	TryCreateSearch(tabObj, "Search " .. kind .. "s...", function(text)
		Rebuild(text)
	end)

	-- One compact multi-select control for favorites instead of a button
	-- on every single row -- keeps the list clean even with hundreds of items.
	local ok, dropdown = pcall(function()
		return tabObj:Dropdown({
			Title = "★ Favorites",
			Desc = "Check items to add them to your Favorites tab",
			Values = AllNames(),
			Value = CurrentFavList(),
			Multi = true,
			AllowNone = true,
			Callback = function(selected)
				for name in pairs(favSet) do favSet[name] = nil end
				for _, name in ipairs(selected) do favSet[name] = true end
				if RefreshFavoritesTab then RefreshFavoritesTab() end
			end,
		})
	end)
	if ok then favDropdown = dropdown end

	Rebuild("")
	return Rebuild
end

-- ============================================================
-- // UI: ANIMATIONS TAB
-- ============================================================

local AnimTab = Window:Tab({ Title = "Animations", Icon = "person-standing" })

AnimTab:Button({
	Title = "DEFAULT",
	Desc = "Removes the applied animation pack and restores your original animations",
	Icon = "rotate-ccw",
	Callback = DefaultAnimations,
})

BuildListTab(AnimTab, "Animation", Animations, AnimationCategories, animCategoryOrder, EquipAnimation, Favorites.Animation)

-- ============================================================
-- // UI: EMOTES TAB
-- ============================================================

local EmoteTab = Window:Tab({ Title = "Emotes", Icon = "party-popper" })

EmoteTab:Button({
	Title = "DEFAULT",
	Desc = "Stops the current emote and restores your original animations",
	Icon = "rotate-ccw",
	Callback = DefaultEmote,
})

BuildListTab(EmoteTab, "Emote", Emotes, EmoteCategories, emoteCategoryOrder, EquipEmote, Favorites.Emote)

-- ============================================================
-- // UI: FAVORITES TAB
-- ============================================================

local FavTab = Window:Tab({ Title = "Favorites", Icon = "star" })
local favDynamicElements = {}

FavTab:Button({
	Title = "DEFAULT",
	Desc = "Clears both the applied animation pack and the current emote",
	Icon = "rotate-ccw",
	Callback = function()
		DefaultAnimations()
		DefaultEmote()
	end,
})

RefreshFavoritesTab = function(filterText)
	ClearElements(favDynamicElements)
	filterText = filterText and string.lower(filterText) or ""

	local favAnims, favEmotes = {}, {}
	for name in pairs(Favorites.Animation) do
		if filterText == "" or string.find(string.lower(name), filterText, 1, true) then
			table.insert(favAnims, name)
		end
	end
	for name in pairs(Favorites.Emote) do
		if filterText == "" or string.find(string.lower(name), filterText, 1, true) then
			table.insert(favEmotes, name)
		end
	end
	table.sort(favAnims)
	table.sort(favEmotes)

	if #favAnims > 0 then
		local Section = FavTab:Section({ Title = "Animations (" .. #favAnims .. ")" })
		table.insert(favDynamicElements, Section)
		for _, name in ipairs(favAnims) do
			local btn = Section:Button({ Title = name, Icon = "play", Callback = function() EquipAnimation(name) end })
			table.insert(favDynamicElements, btn)
			local unfavBtn = Section:Button({
				Title = "★ Remove Favorite",
				Icon = "star",
				Callback = function()
					Favorites.Animation[name] = nil
					RefreshFavoritesTab(filterText)
				end,
			})
			table.insert(favDynamicElements, unfavBtn)
		end
	end

	if #favEmotes > 0 then
		local Section = FavTab:Section({ Title = "Emotes (" .. #favEmotes .. ")" })
		table.insert(favDynamicElements, Section)
		for _, name in ipairs(favEmotes) do
			local btn = Section:Button({ Title = name, Icon = "play", Callback = function() EquipEmote(name) end })
			table.insert(favDynamicElements, btn)
			local unfavBtn = Section:Button({
				Title = "★ Remove Favorite",
				Icon = "star",
				Callback = function()
					Favorites.Emote[name] = nil
					RefreshFavoritesTab(filterText)
				end,
			})
			table.insert(favDynamicElements, unfavBtn)
		end
	end

	if #favAnims == 0 and #favEmotes == 0 then
		local Section = FavTab:Section({ Title = "No favorites yet" })
		table.insert(favDynamicElements, Section)
		local info = Section:Button({
			Title = "Tap ☆ Add Favorite on any Animation or Emote to see it here",
			Icon = "info",
			Callback = function() end,
		})
		table.insert(favDynamicElements, info)
	end
end

TryCreateSearch(FavTab, "Search favorites...", function(text)
	RefreshFavoritesTab(text)
end)

RefreshFavoritesTab("")

-- ============================================================
-- // UI: CONFIGURATION TAB
-- ============================================================

local ConfigTab = Window:Tab({ Title = "Configuration", Icon = "save" })

local ConfigSection = ConfigTab:Section({ Title = "Save & Load" })

ConfigSection:Button({
	Title = "Save Configuration",
	Desc = "Saves your current animation, emote, and favorites so you can load them later",
	Icon = "save",
	Callback = SaveConfiguration,
})

ConfigSection:Button({
	Title = "Load Configuration",
	Desc = "Applies your last saved animation, emote, and favorites (use after rejoining)",
	Icon = "folder-open",
	Callback = LoadConfiguration,
})

-- ============================================================
-- // FINISHED LOADING
-- ============================================================

WindUI:Notify({
	Title = "DweeybzSCRPT Loaded",
	Content = "Loaded " .. totalAnimations .. " Animations and " .. totalEmotes .. " Emotes!",
	Duration = 4,
	Icon = "check",
})
