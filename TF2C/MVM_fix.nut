if(!IsMannVsMachineMode())
	return

PrecacheSound("mvm/giant_soldier/giant_soldier_loop.wav")
PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_explode.wav")
PrecacheSound("mvm/giant_heavy/giant_heavy_loop.wav")
PrecacheSound(")mvm/giant_heavy/giant_heavy_loop.wav")
PrecacheSound("mvm/giant_scout/giant_scout_loop.wav")
PrecacheSound("mvm/giant_demoman/giant_demoman_loop.wav")
PrecacheSound("mvm/giant_pyro/giant_pyro_loop.wav")

PrecacheModel("models/props_mvm/mvm_revive_tombstone.mdl")
PrecacheModel("models/weapons/w_models/w_rocketbeta.mdl")

for (local i = 1; i < 19; i++) {
	PrecacheSound(format("mvm/player/footsteps/robostep_%s.wav", i < 10 ? "0"+i : i.tostring()))
}
for (local i = 1; i < 9; i++) {
	PrecacheSound(format("^mvm/giant_common/giant_common_step_0%s.wav", i.tostring()))
}

// EntFire("tf_gamerules", "SetCustomUpgradesFile", "scripts/items/mvm_upgrades-test.txt")

if(!("FatCatLibVersion" in getroottable()))
{
	::ROOT <- getroottable()
	::CONST <- getconsttable()
	if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
	{
		foreach (enum_table in Constants)
		{
			foreach (name, value in enum_table)
			{
				if (value == null)
					value = 0

				CONST[name] <- value
				ROOT[name] <- value
			}
		}
	}

	if (!("FoldedNetProps" in ROOT)) // make sure folding is only done once
	{
		ROOT["FoldedNetProps"] <- "Folds all NetProps to Not require 'NetProps.'"
		foreach (name, method in ::NetProps.getclass())
		{
			// Every 'class' has this
			if (name != "IsValid")
			{
				ROOT[name] <- method.bindenv(::NetProps)
			}
		}
	}

	function ROOT::FindByClassname(previous, classname)
	{
		local ent = Entities.FindByClassname(previous, classname)
		SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
		return ent
	}
	function ROOT::FindByName(previous, targetname)
	{
		local ent = Entities.FindByName(previous, targetname)
		SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
		return ent
	}

	function ROOT::GetAllEntitiesByClassname(classname)
	{
		local list = []
		for (local entity; entity = FindByClassname(entity, classname); )
		{
			if(entity != null) list.append(entity)
		}
		return list
	}

	function CTFBot::GetWeaponInSlot(slot = 0)
	{
		local ent = GetPropEntityArray(this, "m_hMyWeapons", slot)
		if(ent) SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
		return ent
	}

	function CTFBot::InRespawnRoom()
	{
		foreach (respawnroom in GetAllEntitiesByClassname("func_respawnroom"))
		{
			respawnroom.RemoveSolidFlags(FSOLID_NOT_SOLID)
			respawnroom.SetCollisionGroup(0)
			local trace =
			{
				start =       EyePosition()
				end =         EyePosition()
				hullmin =     GetPlayerMins()
				hullmax =     GetPlayerMaxs()
				mask =        CONTENTS_SOLID
			}
			TraceHull(trace)
			respawnroom.AddSolidFlags(FSOLID_NOT_SOLID)
			respawnroom.SetCollisionGroup(TFCOLLISION_GROUP_RESPAWNROOMS)

			if(trace.hit && trace.enthit == respawnroom) return true
		}
		return false
	}

	function CTFBot::GetActiveHealers()
	{
		local healers = []
		foreach (player in GetAllEntitiesByClassname("player"))
		{
			if(player.GetTeam() != TF_TEAM_PVE_INVADERS || player.GetPlayerClass() != TF_CLASS_MEDIC)
				continue
			if(player.GetHealTarget() == null || player.GetHealTarget() != this)
				continue
			healers.append(player)
		}
		return healers
	}
}

::Currencys <- []
function CollectNewDroppedCurrency()
{
	return
	local total_moneys = Currencys.len()

	if(total_moneys != 0)
		for (local i = total_moneys-1; i != 0; i--) {
			if(!Currencys[i] || !Currencys[i].IsValid())
				Currencys.remove(i)
		}
	
	local moneys = []
	moneys.extend(GetAllEntitiesByClassname("item_currencypack_small"))
	moneys.extend(GetAllEntitiesByClassname("item_currencypack_medium"))
	moneys.extend(GetAllEntitiesByClassname("item_currencypack_large"))
	moneys.extend(GetAllEntitiesByClassname("item_currencypack_custom"))

	local new = []

	foreach (money in moneys)
	{
		if(Currencys.find(money))
			continue
		else 
		{
			new.append(money)
			Currencys.append(money)
		}
	}
	return new
}
::MvMStats <- FindByClassname(null, "tf_mann_vs_machine_stats")

function IncrementCurrency(amount = 0)
{
	if(!MvMStats)
		throw "MISSING \"tf_mann_vs_machine_stats\""
	SetPropInt(MvMStats, "m_currentWaveStats.nCreditsAcquired", GetPropInt(MvMStats, "m_currentWaveStats.nCreditsAcquired")+amount)
}

function GetWaveIndex()
	return GetPropInt(MvMStats, "m_iCurrentWaveIdx")
function SetWaveIndex(wave)
	SetPropInt(MvMStats, "m_iCurrentWaveIdx", wave)
function IncrementWaveCounter()
	SetWaveIndex(GetWaveIndex()+1)


local Thinker = FindByName(null, "Thinker")
if(!Thinker) Thinker = SpawnEntityFromTable("info_target", { targetname = "Thinker" })
AddThinkToEnt(Thinker, "MVMThink")

function MVMThink() {
	/* if(GetListenServerHost())
	{
		local R_Acquired = GetPropInt(MvMStats, "m_runningTotalWaveStats.nCreditsAcquired")
		local R_Dropped = GetPropInt(MvMStats, "m_runningTotalWaveStats.nCreditsDropped")
		local R_Bonus = GetPropInt(MvMStats, "m_runningTotalWaveStats.nCreditsBonus")

		local P_Acquired = GetPropInt(MvMStats, "m_previousWaveStats.nCreditsAcquired")
		local P_Dropped = GetPropInt(MvMStats, "m_previousWaveStats.nCreditsDropped")
		local P_Bonus = GetPropInt(MvMStats, "m_previousWaveStats.nCreditsBonus")

		local C_Acquired = GetPropInt(MvMStats, "m_currentWaveStats.nCreditsAcquired")
		local C_Dropped = GetPropInt(MvMStats, "m_currentWaveStats.nCreditsDropped")
		local C_Bonus = GetPropInt(MvMStats, "m_currentWaveStats.nCreditsBonus")

		local message = "Wave "+GetWaveIndex()+" Stats: \n"
		message += "Running: ( "+R_Acquired+" / " +(R_Dropped+R_Acquired)+" ) (+"+R_Bonus+")\n"
		message += "Previous: ( "+P_Acquired+" / " +(P_Dropped+P_Acquired)+" ) (+"+P_Bonus+")\n"
		message += "Current: ( "+C_Acquired+" / " +(C_Dropped+C_Acquired)+" ) (+"+C_Bonus+")\n"
		if("Host" in ROOT)
			Host.PrintToHud(message)
	} */


	for (local player = FindByClassname(null, "player"); player; player = FindByClassname(player, "player"))
	{
		if(player.GetTeam() != TF_TEAM_PVE_INVADERS)
			continue

		if(player.InRespawnRoom())
			continue
		
		if(GetPropInt(player, "m_Shared.m_nNumHealers") != 0)
		{
			//TODO
		}

		player.RemoveCondEx(TF_COND_INVULNERABLE, true)
		player.RemoveCondEx(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, true)

		SetPropInt(player, "m_Shared.m_iSpawnRoomTouchCount", 0)
		SetPropBool(player, "m_Shared.m_bInUpgradeZone", false)
	}
	return -1
}

::Events <- {
	function OnScriptHook_OnTakeDamage(params)
	{
		local victim = params.const_entity
		local attacker = params.attacker

		if(params.damage_custom == -1)
			return

		if(!attacker || !attacker.IsPlayer() || !victim.IsPlayer())
			return
		if(!victim.IsBotOfType(1337) || victim.InRespawnRoom())
			return

		if(GetPropInt(victim, "m_Shared.m_nNumHealers") == 0)
		{
			victim.RemoveCondEx(TF_COND_INVULNERABLE, true)
			victim.RemoveCondEx(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, true)
		}
		else
		{
			local healers = victim.GetActiveHealers()
			if(healers == null || healers.len() == 0)
				return
			foreach (healer in healers)
			{
				local weapon = GetPropEntityArray(healer, "m_hMyWeapons", 1)
				if(!HasProp(weapon, "m_bChargeRelease"))
					continue
				// if(weapon.GetAttribute("medigun charge is crit boost", 0) != 0)
					// continue
				// if(NetProps.GetPropBool(weapon, "m_bChargeRelease"))
					// continue
				
				victim.RemoveCondEx(TF_COND_INVULNERABLE, true)
				victim.RemoveCondEx(TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED, true)
			}
		}
	}
	function OnGameEvent_player_death(params)
	{
		local moneys = CollectNewDroppedCurrency()
		if(moneys == null)
			return
		foreach(money in moneys)
		{
			SetDestroyCallback(money, function() {
				DebugDrawText(self.GetOrigin(), GetPropBool(self, "m_bDistributed").tostring(), false, 10)
				if(GetPropBool(self, "m_bDistributed"))
					return
				IncrementCurrency() // GET OUR AMOUNT????>????>???>"????"?>?>?:
			})
		}
	}
	function OnGameEvent_mvm_pickup_currency(params)
	{
		local MvMStats = FindByClassname(null, "tf_mann_vs_machine_stats")
		if(!MvMStats)
			throw "MISSING \"tf_mann_vs_machine_stats\""
		IncrementCurrency(params.currency)
	}

	// function OnGameEvent_mvm_sniper_headshot_currency(params)
	// {
	// }

	function OnGameEvent_mvm_begin_wave(params)
	{
		IncrementWaveCounter()
	}

	function OnGameEvent_mvm_wave_complete(params)
	{
		IncrementWaveCounter()
		local collected = GetPropInt(MvMStats, "m_currentWaveStats.nCreditsAcquired")
		local missed = GetPropInt(MvMStats, "m_currentWaveStats.nCreditsDropped")
		local TotalCredits = collected+missed

		PrintToChatAll(format("Collected %.2f %% of Total %i", (collected.tofloat()/TotalCredits.tofloat())*100, TotalCredits))
	}


	// function OnGameEvent_mvm_tank_destroyed_by_players(params)
	// {
	// 	RunWithDelay( @() CollectNewDroppedCurrency(), 0.015)
	// }
}
__CollectGameEventCallbacks(Events)