if(!("SetLibraryVersion" in getroottable()) || ("FatCatLibForce" in ROOT && FatCatLibForce == true))
	IncludeScript("fatcat_library")
SetScriptVersion("Abilities", "2.7.0")

::Debug_Abilities <- false

// Base
// - - - - - - - - - Base - - - - - - - - - |
local BASE_spawn_cooldown = 5            // |
local BASE_attack_cooldown = 5           // |
// - - - - - - - - - - - - - - - - - - - - -|
// Scout
// Soldier
// Pyro
// Demoman
// Heavy
// - - - - - - - - - Rage - - - - - - - - - |
::RageSettings <- {
	SpawnCooldown 	= 180.0
	AttackCooldown 	= 120.0
	BombRange 		= 75.0
	ExplodeDmg 		= 750000.0
	ExplodeRad 		= 500.0
	ExplodeDmgSmall = 40000.0
	ExplodeRadSmall = 500.0
	CondDuration 	= 20.0
}
// - - - - - - - - - - - - - - - - - - - - -|
// Engineer
// Medic
// Sniper
// Spy
// Multi-Class
// - - - - - - - -  CHEERS  - - - - - - - - |
::CheersSettings <- {
	SpawnCooldown  = 20.0
	AttackCooldown = 75.0
	HealthMult     = 10.0
	Duration       = 20.0
	UseTimes       = array(TF_CLASS_MAXNORMAL+1, 4.0)
}
CheersSettings.UseTimes[TF_CLASS_PYRO] 			= 3.85
CheersSettings.UseTimes[TF_CLASS_DEMOMAN] 		= 4.4
CheersSettings.UseTimes[TF_CLASS_MEDIC] 		= 3.9
CheersSettings.UseTimes[TF_CLASS_HEAVYWEAPONS] 	= 4.1
CheersSettings.UseTimes[TF_CLASS_SNIPER] 		= 3.15
// - - - - - - - - - - - - - - - - - - - - -|
// - - - - - - - -   KART   - - - - - - - - |
::KartSettings <- {
	SpawnCooldown  = 30.0
	AttackCooldown = 75.0
	Duration       = 25.0
	UseTimes       = array(TF_CLASS_MAXNORMAL+1, 2.75)
}
KartSettings.UseTimes[TF_CLASS_DEMOMAN] 		= 3.75
KartSettings.UseTimes[TF_CLASS_MEDIC] 			= 2.6
KartSettings.UseTimes[TF_CLASS_HEAVYWEAPONS] 	= 2.6
KartSettings.UseTimes[TF_CLASS_SNIPER] 			= 2.2
// - - - - - - - - - - - - - - - - - - - - -|
function AbilityValid(player, player_class, idx)
{
	if(!player.IsAlive())
		return false
	if(!player.HasWeapon(idx))
		return false
	if(player_class > TF_CLASS_UNDEFINED && player_class < TF_CLASS_MAXNORMAL)
	{
		return player.GetPlayerClass() == player_class
	}
	return true
}


/**
 * Sets up the ability think for the weapon
 * 
 * @param {entity}		weapon 			The weapon to apply the ability to.
 * @param {float}		spawncooldown 	The Abilitys cooldown when created.
 * @param {string}		name 			The NonTranslated name of the weapon.
 * @param {short}		player_class 	Which Class the player needs to be to use the ability (TF_CLASS_UNDEFINED or > TF_CLASS_MAXNORMAL to ignore).
 * @param {short}		idx				The ItemDefIndex of the Weapon.
 * @param {table}		text_parms		Table of Text parameters for the GlobalGameText.
 * @param {function}	ability_func	Function to use when the Ability is used
 */
function CreateAbility(weapon, spawncooldown, name, player_class, idx, text_parms, ability_func) {
	local scope = GetScope(weapon)
	weapon.SetAbilityTime(Time() + spawncooldown)
	scope.WeaponIDX <- idx
	scope.PlayerClass <- player_class
	scope.TranslationName <- name
	scope.AbilityFunc <- ability_func

	scope.AbilityThink <- function() 
	{
		if(!self.IsValid())
			return 500

		local player = self.GetOwner()

		if ( player.IsAdmin() && Debug_Abilities)
		{
			local message = "Variable list:\n"
			foreach(k, v in this)
			{
				if(type(v) == "function")
					continue
				if (!startswith(k, "__"))
					message += (k + " : " + v + "\n")
			}
			player.PrintToHud(message)
		}

		if(!AbilityValid(player, PlayerClass, WeaponIDX))
			return 1.0

		// Setup Text
		local text_msg = ""
		if(!player.IsTaunting())
		{
			if (Timestamp-Time() < 0) 
				text_msg = player.GetTranslatedAndFormattedString("ABILITY_READY", "%T"+TranslationName)
			else 
				text_msg = player.GetTranslatedAndFormattedString("ABILITY_CHARGING", "%T"+TranslationName, player.GetTranslatedAndFormattedString("ABILITY_CHARGING_MSG", (Timestamp-Time()).tointeger().tostring()))
		}

		player.DisplayHudText(text_msg,  text_parms.color, [text_parms.x, text_parms.y])

		//////////
		// MAIN //
		//////////
		if (player.IsUsingActionSlot() && player.IsOnGround() && player.GetActiveWeaponIDX() == WeaponIDX && Timestamp <= Time())
		{
			self.AddAbilityTime(10) // only if the ability fails / was not set, or if we want to run a function with a delay, I.E. the below
			this.AbilityFunc()
		}
		return 0.1
	}
	AddThinkToEnt(weapon, "AbilityThink")
}

::AbilityEvents <- {
	function OnScriptEvent_HumanResupply(params)
	{
		local player = params.player

		ClearThinks(player.GetWeaponInSlotNew(SLOT_MELEE))

		if( player.GetAbilityWeaponIDX() == null )
			return
		
		local melee = player.GetWeaponInSlotNew(SLOT_MELEE)
		switch (player.GetAbilityWeaponIDX())
		{
			case TF_ABILITY_HEAVY_RAGE:
			{
				CreateAbility(melee, RageSettings.SpawnCooldown, "MEGACRUSH", TF_CLASS_HEAVYWEAPONS, TF_ABILITY_HEAVY_RAGE, {x = 0.75, y = 0.75, color = "255 25 5"}, function() {
					local player = self.GetOwner()
					player.ForceTaunt(TF_TAUNT_UNLEASHED_RAGE)

					if (GetFlagStatus(FindByClassnameWithin(null, "item_teamflag", player.GetOrigin(), RageSettings.BombRange)) == FLAG_DROPPED) 
						player.SetCond(TF_COND_MARKEDFORDEATH, 2.55)

					player.SetCond(TF_COND_IMMUNE_TO_PUSHBACK, 2.75)
					player.SetCond(TF_COND_STUNNED, 2.55)

					RunWithDelay(@() HeavyGoKaboom(player), 2.55)
				})
				break
			}
			case TF_ABILITY_CHEERS:
			{
				CreateAbility(melee, CheersSettings.SpawnCooldown, "VITALRESURGENCE", TF_CLASS_UNDEFINED, TF_ABILITY_CHEERS, {x = 0.75, y = 0.75, color = "21 124 235"}, function() {
					local player = self.GetOwner()
					player.ForceTaunt(TF_TAUNT_CHEERS)

					RunWithDelay(@() GiveMeThyHealth(player), CheersSettings.UseTimes[player.GetPlayerClass()])
				})
				break
			}
			case TF_ABILITY_KART:
			{
				CreateAbility(melee, KartSettings.SpawnCooldown, "VEHICULARMANNSLAUGHTER", TF_CLASS_UNDEFINED, TF_ABILITY_KART, {x = 0.7, y = 0.75, color = "95 25 255"}, function() {
					local player = self.GetOwner()
					player.ForceTaunt(TF_TAUNT_SECOND_RATE_SORCERY)

					RunWithDelay(@() SummonLasKart(player), KartSettings.UseTimes[player.GetPlayerClass()])
				})
				break
			}
		}
	}
}
__CollectGameEventCallbacks(AbilityEvents)

function HeavyGoKaboom(player)
{
	if (!player.IsAlive()) return
	if (!player.IsTaunting()) return

	if (player.GetAbilityWeapon() == null) return

	player.AddAbilityTime(RageSettings.AttackCooldown + 0.2) // cancel taunt delay

	player.RunScriptCode("CancelTaunt()", 0.1)
	player.RunScriptCode("SetCond(TF_COND_CRITBOOSTED, RageSettings.CondDuration)", 0.1)
	player.RunScriptCode("SetCond(TF_COND_DEFENSEBUFF, RageSettings.CondDuration)", 0.1)
	player.RunScriptCode("SetCond(TF_COND_REGENONDAMAGEBUFF, RageSettings.CondDuration)", 0.1)

	PrecacheSound("weapons/airstrike_small_explosion_02.wav")
	PrecacheSound("items/cart_explode.wav")

	local bomb = FindByClassnameWithin(null, "item_teamflag", player.GetOrigin(), RageSettings.BombRange)
	if (GetFlagStatus(bomb) == FLAG_DROPPED)
	{
		DispatchParticleEffect("hightower_explosion", bomb.GetOrigin(), QAngle(-90, 0, 0).Forward())
		bomb.EmitSound("items/cart_explode.wav")

		player.TakeDamage(RageSettings.ExplodeDmg, 0, player)
		player.DamageEveryBotWithin(RageSettings.ExplodeRad, RageSettings.ExplodeDmg)
		player.DamageEveryTankWithin(RageSettings.ExplodeRad, RageSettings.ExplodeDmg)
		bomb.AcceptInput("ForceReset", "", player, player)
	}
	else
	{
		DispatchParticleEffect("chaos_rage_burst", (player.GetOrigin() + Vector(0,0,10)), QAngle(-90, 0, 0).Forward())
		player.EmitSound("weapons/airstrike_small_explosion_02.wav")

		player.DamageEveryBotWithin(RageSettings.ExplodeRadSmall, RageSettings.ExplodeDmgSmall)
		player.DamageEveryTankWithin(RageSettings.ExplodeRadSmall, RageSettings.ExplodeDmgSmall)
	}
}
function GiveMeThyHealth(player)
{
	if (!player.IsAlive()) return
	if (!player.IsTaunting()) return

	local weapon = player.GetAbilityWeapon()
	if (weapon == null) return

	if(player.GetHealth() >= player.GetMaxHealth() * CheersSettings.HealthMult)
		return;
	player.SetHealth(player.GetMaxHealth() * CheersSettings.HealthMult)
	player.SetCond(TF_COND_IMMUNE_TO_PUSHBACK, CheersSettings.Duration)
	player.SetCond(TF_COND_GRAPPLINGHOOK_BLEEDING, CheersSettings.Duration)

	player.AddAbilityTime(CheersSettings.AttackCooldown + 3) // + 3 for taunt duration
}
function SummonLasKart(player)
{
	if (!player.IsAlive()) return
	if (!player.IsTaunting()) return

	if (player.GetAbilityWeapon() == null) return

	local trace = {
		start = player.GetOrigin() + Vector(0, 0, 35)
		end = player.GetOrigin() + Vector(0, 0, 35)
		mask = MASK_SOLID
		hullmax = GetPropVector(player, "m_Collision.m_vecMaxs") * 0.975
		hullmin = GetPropVector(player, "m_Collision.m_vecMins") * 0.975
		allsolid = false
		ignore = player
	}
	TraceHull(trace)
	if(trace.allsolid == true)
	{
		player.ForceRespawn()
		player.TranslateToHud("STUCK_RESPAWNED")
		return
	}

	player.SetAbsOrigin(player.GetOrigin() + Vector(0, 0, 35))
	player.SetCond(TF_COND_HALLOWEEN_KART, KartSettings.Duration)
	player.SetCond(TF_COND_HALLOWEEN_QUICK_HEAL, KartSettings.Duration)
	player.SetCond(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, KartSettings.Duration)
	player.SetCond(TF_COND_HALLOWEEN_TINY, 0)
	player.SetScale(1.0)
	player.CancelTaunt()

	player.AddAbilityTime(KartSettings.AttackCooldown)
}