// Ficool2's Tracefilter library
try {
	IncludeScript("trace_filter")
}
catch (e)
{
	try {
		IncludeScript("chaosmvm/trace_filter")
	}
	catch(_) {
		throw "FAILED TO INCLUDE DEPENDENCY \"trace_filter\"!"
	}
}
IncludeScript("fatcat_library")

local isDebug = false

SetScriptVersion("flame_sentry", "2.1.1")

local DMG_SENTRY_BURN = DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE

// Damage
const FLAME_SENTRY_DAMAGE = 3000
const FLAME_SENTRY_WRANGLE_MULT = 1.5
const FLAME_SENTRY_DAMAGE_DELAY = 0.1

// Sound
const FLAME_SENTRY_SOUND = "misc/flame_engulf.wav"
const FLAME_SENTRY_SOUND_EMIT_RATE = 0.025

::FlameSentryEvents <-{
	function OnScriptEvent_SentryBuilt(params)
	{
		local player = params.player
		if(player.GetWeaponIDXInSlotNew(SLOT_MELEE) != TF_WEAPON_SOUTHERN_HOSPITALITY)
			return

		local sentry = params.object
		if(GetPropBool(sentry, "m_bDisposableBuilding") == true)
			return

		AddThinkToEnt(sentry, "FlameSentry")

		EntFireNew(sentry, "Color", "255 120 50")
		EntFireNew(sentry, "SetModelScale", "1")
		EntFireNew(sentry, "skin", "1")

		if(IsListenServer())
		{
			GetListenServerHost().AddCustomAttribute("engy sentry damage bonus", 0.0, -1)
			GetListenServerHost().AddCustomAttribute("engy sentry fire rate increased", 100000, -1)
			GetListenServerHost().AddCustomAttribute("engy sentry radius increased", 0.545454, -1)
			GetListenServerHost().GetWeaponInSlot(SLOT_MELEE).AddAttribute("mod wrench builds minisentry", 1, 0)
			GetListenServerHost().GetWeaponInSlot(SLOT_MELEE).AddAttribute("weapon burn dmg increased", 10, 0)
		}

		local scope = GetScope(sentry)
		scope.NextDamageTime <- 0
		scope.m_flNextSoundEmit <- 0
		scope.hParticle <- null
	}
	function OnGameEvent_object_destroyed(params) {
		local building = EntIndexToHScript(params.index)
		ClearThinks(building)
		if(params.objecttype == OBJ_SENTRY && "hParticle" in GetScope(building) && GetScope(building).hParticle != null)
		{
			GetScope(building).hParticle.AcceptInput("Stop", "", null, null)
			GetScope(building).hParticle.Destroy()
		}
	}
	function OnGameEvent_object_detonated(params) {
		local building = EntIndexToHScript(params.index)
		ClearThinks(building)
		if(params.objecttype == OBJ_SENTRY && "hParticle" in GetScope(building) && GetScope(building).hParticle != null)
		{
			GetScope(building).hParticle.AcceptInput("Stop", "", null, null)
			GetScope(building).hParticle.Destroy()
		}
	}
}
__CollectGameEventCallbacks(FlameSentryEvents)

//////////
function FlameSentry()
{
	if(!self || !self.IsValid())
		return 500
	if(GetPropBool(self, "m_bBuilding")) 
		return -1

	// Netprop related veriables
	local hOwner = GetBuilder(self)
	local m_iShells = GetPropInt(self, "m_iAmmoShells")
	local m_iState = GetState(self)

	// Object related variables
	local Angle 	= GetSentryAngles(self)
	local flPitch 	= Angle.Pitch()
	local flYaw 	= Angle.Yaw()
	local vecEyePos = self.EyePosition()+Vector(0, 0, 6)
	
	local CanDealDamage = NextDamageTime <= Time()

	///////////
	// Trace //
	///////////
	local trace = {
		start = vecEyePos,
		end = vecEyePos + ConvertAngleToEndpoint(Angle)-Vector(0, 0, 6),
		hullmin = Vector(-12, 12, -12)
		hullmax = Vector(12, -12, 12)
		// ignore = self,
		mask = MASK_SHOT_HULL,
		filter = function(entity)
		{
			if(IsValidEnemy(entity)) return TRACE_OK_CONTINUE
			else return TRACE_CONTINUE
			return TRACE_STOP
		}
	}

	DebugDrawClear()
	local EntitysHit = []
	if(CanDealDamage)
	{
		TraceHullGather(trace)
		foreach (index, hit in trace.hits)
		{
			EntitysHit.append(hit.enthit)
		}
	}

	// if(CanDealDamage && IsListenServer()) DrawTraceHull(trace)

	////////////
	// Damage //
	////////////
	local IsWrangled = false
	local IsFiring = false

	IsWrangled = GetPropBool(self, "m_bPlayerControlled")
	if(IsWrangled && hOwner.IsPressingButton(IN_ATTACK) && (hOwner.GetWeaponInSlotNew(SLOT_SECONDARY) == hOwner.GetActiveWeapon()))
		IsFiring = true
	else if(!IsWrangled && m_iState == 2)
		IsFiring = true

	if(m_iShells != 0 && IsFiring && CanDealDamage)
	{
		if(hParticle == null)
		{
			hParticle = SpawnEntityFromTable("info_particle_system", {
				targetname = "Sentry_flame"
				effect_name = "flamethrower_giant_mvm"
				start_active = 1
			})
			hParticle.SetAbsOrigin(vecEyePos + Vector(0, 0, 0))
		}

		if(isDebug == false && m_iShells > 0)
			m_iShells--
		SetPropInt(self, "m_iAmmoShells", m_iShells)


		NextDamageTime <- Time() + FLAME_SENTRY_DAMAGE_DELAY
		foreach (entity in EntitysHit)
		{
			if(!hOwner || !hOwner.IsValid())
				break

			if(entity.IsPlayer())
				entity.AddCondEx(TF_COND_GAS, 1, hOwner)
			entity.TakeDamageCustom(self, hOwner, hOwner.GetWeaponInSlotNew(SLOT_MELEE), Vector(), Vector(), IsWrangled ? FLAME_SENTRY_DAMAGE * FLAME_SENTRY_WRANGLE_MULT : FLAME_SENTRY_DAMAGE, DMG_SENTRY_BURN, TF_DMG_CUSTOM_BURNING)
		}

		if(m_flNextSoundEmit <= Time())
		{
			PrecacheSound(FLAME_SENTRY_SOUND)

			if(!self.IsValid())
				return 500

			EmitSoundEx({
				sound_name = FLAME_SENTRY_SOUND
				channel = 1
				sound_level = 80
				entity = self
				origin = self.EyePosition()
				flags = 16
				delay = -0.3
			})
			m_flNextSoundEmit <- Time() + FLAME_SENTRY_SOUND_EMIT_RATE
		}
	}
	if(hParticle == null)
	{
		hParticle = SpawnEntityFromTable("info_particle_system", {
			targetname = "Sentry_flame"
			effect_name = "flamethrower_giant_mvm"
			start_active = 1
		})
		hParticle.SetAbsOrigin(vecEyePos + Vector(0, 0, 0))
	}
	hParticle.SetAbsAngles(QAngle(flPitch * RAD2DEG, flYaw * RAD2DEG, 0))
	if(m_iShells == 0)
		hParticle.AcceptInput("Stop", "", null, null)
	else if((IsFiring && !IsWrangled) || (IsFiring && IsWrangled))
		hParticle.AcceptInput("Start", "", null, null)
	else 
		hParticle.AcceptInput("Stop", "", null, null)
	return -1
}