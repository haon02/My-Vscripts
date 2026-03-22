IncludeScript("fatcat_library")

// POTATO VERSION
// IncludeScript("chaosmvm/translations")
IncludeScript("translations")

const item_help_color = "\x08FFFF00DD"
const text_color = "\x08FFFFFFBB"
const item_help_color_header = "\x0826c2ffDD"
const text_color_header = "\x0826beffBB"
const error_color = "\x07D43F3F"

SetScriptVersion("item_helper", "3.3.1")
::helper <- {}

::ItemTranslateTable <- {
	///// Scout
	/// Primary
	"SCATTERGUN" 		: [13, 200, 669, 299, 808, 888, 897, 906, 915, 964, 973, 15002, 15015, 15021, 15029, 15036, 15053, 15065, 15069, 15106, 15107, 15108, 15131, 15151, 15157]
	"FORCENATURE" 		: [45, 1078]
	"SHORTSTOP" 		: [220]
	"SODAPOPPER" 		: [448]
	"BABYFACEBLASTER" 	: [772]
	"BACKSCATTER" 		: [1103]
	/// Secondary
	"PISTOL"			: [22, 23, 209, 160, 294, 15013, 15018, 15035, 15041, 15046, 15056, 15060, 15061, 15100, 15101, 15102, 15126, 15148, 30666]
	"BONK"				: [46, 1145]
	"CRITACOLA"			: [163]
	"MADMILK"			: [222]
	"WINGER"			: [449]
	"PRETTYBOYS"		: [773]
	"CLEAVER"			: [812, 833]
	"MATATEDMILK"		: [1121]
	/// Melee
	"BAT"				: [0, 190, 660, 3066]
	"SANDMAN"			: [44]
	"HOLYMACKEREL"		: [221, 999]
	"CANDYCANE"			: [317]
	"BOSTONBASHSER"		: [325]
	"SUNONASTICK"		: [349]
	"FANOWAR"			: [355]
	"ATOMIZER"			: [450]
	"THREERUNEBLADE"	: [452]
	"UNARMEDCOMBAT"		: [572]
	"WRAPAASSASSIN"		: [648]

	///// Soldier
	/// Primary
	"ROCKETLAUNCHER"	: [18, 205, 658, 800, 809, 889, 898, 907, 916, 965, 974, 10556, 15014, 15028, 1543, 15052, 15057, 15081, 15104, 15105, 15129, 15130, 15150]
	"DIRECTHIT"			: [127]
	"BLACKBOX"			: [228, 1085]
	"ROCKETJUMPER"		: [237]
	"LIBERTYLAUNCHER"	: [414]
	"COWMANGLER"		: [441]
	"ORIGINAL"			: [513]
	"BEGGARSBAZOOKA"	: [730]
	"AIRSTRIKE"			: [1104]
	/// Secondary
	"SHOTGUN_SOLD"		: [10]
	"SHOTGUN"			: [199, 1141, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152]
	"BUFFBANNER"		: [129, 1001]
	"GUNBOATS"			: [133]
	"BATTALIONS"		: [226]
	"CONCHEROR"			: [354]
	"RESERVESHOOTER"	: [415]
	"BISON"				: [442]
	"MANTREADS"			: [444]
	"BASEJUMPER"		: [1101]
	"PANICATTACK"		: [1153]
	/// Melee	
	"SHOVEL"			: [6, 196]
	"EQUALIZER"			: [128]
	"PAINTRAIN"			: [154]
	"HALFZATOICHI"		: [357]
	"MARKETGARDENER"	: [416]
	"DISCIPLINARYACTION": [447]
	"ESCAPEPLAN"		: [775]

	///// Pyro
	/// Primary
	"FLAMETHROWER"		: [21, 208, 659, 798, 807, 887, 896, 905, 914, 963, 972, 15005, 15017, 15030, 15034, 15049, 15054, 15066, 15067, 15068, 15089, 15090, 15115, 15141]
	"BACKBURNER"		: [40, 1146]
	"DEGREASER"			: [215]
	"PHLOGISTINATOR"	: [594]
	"RAINBLOWER"		: [741]
	"DRAGONSFURY"		: [1178]
	"NOSTROMONAPALMER"	: [30474]
	/// Secondary
	"SHOTGUN_PYRO"		: [12]
	"FLAREGUN"			: [39, 1081]
	"DETONATOR"			: [351]
	"MANMELTER"			: [595]
	"SCORCHSHOT"		: [740]
	"THERMALTHRUSTER"	: [1179]
	"GASPASSER"			: [1180]
	/// Melee
	"FIREAXE"			: [2, 192]
	"AXTINGUISHER"		: [38, 1000]
	"HOMEWRECKER"		: [153]
	"POWERJACK"			: [214]
	"BACKSCRATCHER"		: [326]
	"VOLCANOFRAGMENT"	: [348]
	"POSTALPUMMELER"	: [457]
	"MAUL"				: [466]
	"THIRDDEGREE"		: [593]
	"LOLLICHOP"			: [739]
	"NEONANNIHILATOR"	: [813, 834]
	"HOTHAND"			: [1181]

	///// Demo
	/// Primary
	"GRENADELAUNCHER"	: [19, 206, 1007, 15077, 15079, 15091, 15092, 15116, 15117, 15142, 15158]
	"LOCHNLOAD"			: [308]
	"ALIBABA"			: [405]
	"BOOTLEGGER"		: [608]
	"LOOSECANNON"		: [996]
	"IRONBOMBER"		: [1151]
	/// Secondary
	"STICKYBOMB"		: [20, 207, 661, 797, 806, 886, 895, 904, 913, 962, 971, 15009, 15012, 15024, 15038, 15045, 15048, 15082, 15083, 15084, 15113, 15137, 15138, 15155]
	"SCOTTISHRES"		: [130]
	"STICKYJUMPER"		: [265]
	"CHARGINTARGE"		: [131, 1144]
	"SPLENDIDSCREEN"	: [406]
	"TIDETURNER"		: [1099]
	"QUICKIEBOMB"		: [1150]
	/// Melee
	"BOTTLE"			: [1, 191]
	"EYELANDER"			: [132, 266, 1082]
	"SKULLCUTTER"		: [172]
	"CABER"				: [307]
	"CLAIDHEAMHMOR"		: [327]
	"PERSIANPERSUADER"	: [404]
	"NINEIRON"			: [482]
	"SCOTTISHHANDSHAKE"	: [609]

	///// Heavy
	/// Primary
	"MINIGUN"			: [15, 202, 298, 654, 793, 802, 882, 891, 900, 909, 958, 967, 15004, 15020, 15026, 15031, 15040, 15055, 15086, 15087, 15088, 15098, 15099, 15123, 15124, 15125, 15147]
	"NATASCHA"			: [41]
	"BRASSBEAST"		: [312]
	"TOMISLAV"			: [424]
	"HUOHEATER"			: [811]
	"GENUINEHUOHEATER"	: [832]
	/// Secondary
	"SHOTGUN_HVY"		: [11]
	"SANDVICH"			: [42, 863, 1002]
	"DALOKOHSBAR"		: [159]
	"BUFFALOSTEAK"		: [311]
	"FAMILYBUSINESS"	: [425]
	"FISHCAKE"			: [433]
	"SECONDBANANA"		: [1190]
	/// Melee
	"FISTS"				: [5, 195]
	"KILLINGGLOVES"		: [43]
	"GLOVESRUNNING"		: [239, 1084]
    "BREADBITE"			: [1100]
	"WARRIRORSSPIRIT"	: [310]
	"FISTSOFSTEEL"		: [331]
	"EVICTIONNOTICE"	: [426]
	"APOCOFISTS"		: [587]
	"HOLIDAYPUNCH"		: [656]

	///// Engineer
	/// Primary
	"SHOTGUN_ENGI"		: [9]
	"FRONTIERJUSTICE"	: [141, 1004]
	"WIDOWMAKER"		: [527]
	"POMSON"			: [588]
	"RESCUERANGER"		: [997]
	/// Secondary
	"WRANGLER"			: [140, 1086, 30668]
	"SHORTCIRCUIT"		: [528]
	/// Melee
	"WRENCH"			: [7, 169, 197, 662, 795, 804, 884, 893, 902, 911, 960, 969, 15073, 15074, 15075, 15139, 15140, 15114, 15156]
	"GUNSLINGER"		: [142]
	"SOUTHERNHOS"		: [155]
	"JAG"				: [329]
	"EUREKAEFFECT"		: [589]

	///// Medic
	/// Primary
	"SYRINGEGUN"		: [17, 204]
	"BLUTSAUGER"		: [36]
	"CRUSADERSCROSSBOW"	: [305, 1079]
	"OVERDOSE"			: [412]
	/// Secondary
	"MEDIGUN"			: [29, 211, 663, 796, 805, 885, 894, 903, 912, 961, 970, 15008, 15010, 15025, 15039, 15050, 15078, 15097, 15121, 15122, 15123, 15145, 15146]
	"KRITZKRIEG"		: [35]
	"QUICKFIX"			: [411]
	"VACCINATOR"		: [998]
	/// Melee
	"BONESAW"			: [8, 198, 1143]
	"UBERSAW"			: [37, 1003]
	"VITASAW"			: [173]
	"AMPUTATOR"			: [304]
	"SOLEMNVOW"			: [413]

	///// Sniper
	/// Primary
	"SNIPERRIFLE"		: [14, 201, 664, 792, 801, 881, 890, 899, 908, 957, 966, 15000, 15007, 15019, 15023, 15033, 15059, 15070, 15071, 15072, 15111, 15112, 15135, 15136, 15154]
	"MACHINA"			: [526, 30665]
	"HITMANSHEATMAKER"	: [752]
	"AWPERHAND"			: [851]
	"HUNTSMAN"			: [56, 1005]
	"SYDNEYSLEEPER"		: [230]
	"BAZAARBARGAIN"		: [402]
	"FORTIFIEDCOMPOUND"	: [1092]
	"CLASSIC"			: [1098]
	/// Secondary
	"SMG"				: [16, 203, 1149, 15001, 15022, 15032, 15037, 15058, 15076, 15110, 15134, 15153]
	"RAZORBACK"			: [57]
	"JARATE"			: [58, 1083]
	"DARWIN"			: [231]
	"COZYCAMPER"		: [642]
	"CLEANERSCARBINE"	: [751]
	"BEAUTYMARK"		: [1105]
	/// Melee
	"KUKRI"				: [3, 193]
	"TRIBALMANSSHIV"	: [171]
	"BUSHWACKA"			: [232]
	"SHAHANSHAH"		: [401]
	
	///// Spy
	/// Primary
	"REVOLVER" 			: [24, 210, 161, 1142, 15011, 15027, 15042, 15051, 15062, 15063, 15064, 15103, 15127, 15128, 15149]
	"AMBASSADOR" 		: [61, 1006]
	"LETRANGER" 		: [224]
	"ENFORCER" 			: [460]
	"DIAMONDBACK" 		: [525]
	/// Secondary
	"SAPPER"			: [735, 736, 933, 1080, 1102]
	"REDTAPE"			: [810, 831]
	/// Melee
	"KNIFE"				: [4, 194, 665, 727, 794, 803, 883, 892, 901, 959, 968, 15062, 15094, 15095, 15096, 15118, 15119, 15143, 15144]
	"YOURETERNALREWARD"	: [225]
	"KUNAI"				: [356]
	"BIGEARNER"			: [461]
	"WANGAPRICK"		: [574]
	"SHARPDRESSER"		: [638]
	"SPYCICLE"			: [649]
	/// Watch
	"INVISWATCH"		: [30, 297, 947]
	"DEADRINGER"		: [59]
	"CLOAKANDDAGGER"	: [60]

	///// Multiclass Melee
	"FRYINGPAN"			: [264, 1071]
	"SAXXY"				: [423]
	"MEMORYMAKER"		: [954]
	"CONOBJECTOR"		: [474]
	"FREEDOMSTAFF"		: [880]
	"BATOUTTAHELL"		: [939]
	"HAMSHANK"			: [1013]
	"NECROSMASHER"		: [1123]
	"CROSSINGGAURD"		: [1127]
	"PRINNYMACHETE"		: [30758]
}

AddChatTrigger("itemhelp", function(player, ...) { 
	if(!player)
		return

	if(vargv.len() != 1)
	{
		player.TranslateToChat("IH_HELP_MSG")
		return
	}
	local setting = -1
	try {
		setting = vargv[0].tointeger()
	}
	catch(e) {}


	if (setting > 2 || setting < 0)
	{
		player.TranslateToChat("IH_OOB_ARG", setting.tostring())
		return
	}

	GetScope(player).SpawnHelper <- setting
	if(setting == 0) 
		player.TranslateToChat("IH_DISABLE")
	if(setting == 1) 
		player.TranslateToChat("IH_WAVE_SETUP")
	if(setting == 2) 
		player.TranslateToChat("IH_ENABLE")
} )


::helper <-{
	/////////////////
	function OnScriptEvent_HumanTeam(params)
	{
		local player = params.player

		local scope = GetScope(player)

		if(IsNotInScope("spawncount", scope))
			scope.spawncount <- 0

		if(IsNotInScope("SpawnHelper", scope))
			scope.SpawnHelper <- 2

		if(player.IsAdmin())
		{
			scope.SpawnHelper <- 0
		}
	}
	function OnScriptEvent_HumanSpawn(params)
	{
		local player = params.player

		if(!player)
			return

		local scope = GetScope(player)
		if(params.team == TEAM_UNASSIGNED)
		{
			scope.spawncount <- 0
			scope.SpawnHelper <- player.IsAdmin() ? 0 : 2
			return
		}

		if(IsNotInScope("spawncount", scope))
			scope.spawncount <- 0

		if(IsNotInScope("SpawnHelper", scope))
			scope.SpawnHelper <- 2

		scope.spawncount++
	}
	//////////////////
	function OnScriptEvent_HumanResupply(params)
	{
		local player = params.player

		local scope = GetScope(player)

		if(IsNotInScope("spawncount", scope)) 	return
		if(IsNotInScope("SpawnHelper", scope)) 	return
		if(scope.SpawnHelper == 0) return
		if(scope.spawncount <= 0) return

		if(scope.SpawnHelper == 2 || (scope.SpawnHelper == 1 && GetRoundState() != GR_STATE_RND_RUNNING))
		{
			player.TranslateToChat("IH_INCLUDES")

			local weapons = player.GetAllWeapons()
			foreach (weapon in weapons)
			{
				foreach (item, indexs in ItemTranslateTable)
				{
					Assert(typeof indexs == "array", format("%s has a idx not in an array", item))
					if(IsInArray(weapon.GetIDX(), indexs))
						player.IHTranslateToChat2(item)
				}
			}
			if(scope.SpawnHelper == 2)
				player.TranslateToChat("IH_DIS_MSG_2")
			else
				player.TranslateToChat("IH_DIS_MSG")
		}
	}
	/////////////////////
	/* function OnScriptEvent_HumanSay(params)
	{
		local player = params.player
		local text = split(params.message, " ")

		if(text[0] != "/itemhelp")
			{ if(text[0] != "!itemhelp") return }
		
		if(text.len() != 2)
		{
			player.TranslateToChat("IH_HELP_MSG")
			return
		}

		local message_value = text[1].tointeger()

		if (message_value > 2 || message_value < 0)
		{
			player.TranslateToChat("IH_OOB_ARG", message_value)
			return
		}

		GetScope(player).SpawnHelper <- message_value
		if(message_value == 0) 
			player.TranslateToChat("IH_DISABLE")
		if(message_value == 1) 
			player.TranslateToChat("IH_WAVE_SETUP")
		if(message_value == 2) 
			player.TranslateToChat("IH_ENABLE")
	} */
}
__CollectGameEventCallbacks(helper)