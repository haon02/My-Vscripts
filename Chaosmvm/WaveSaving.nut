if(!("SetLibraryVersion" in getroottable()) || ("FatCatLibForce" in ROOT && FatCatLibForce == true))
	IncludeScript("fatcat_library")

SetScriptVersion("WaveSave", "1.0.0")

::CHECKPOINT_ERROR <- "\x07bf4137"

::SECPERMIN 	<- 60
::SECPERHOUR 	<- SECPERMIN*60

::WAVE_SAVE_FILE 	<- "checkpoint.txt"
::SAVE_LIFETIME 	<- (69*SECPERMIN) // 60 mins

::CheckpointCommand <- ""

::WaveVoteCallback <- function(player, ...) {

	local ret = ReadCheckpoint(player)

	if(typeof ret != "integer")
	{
		player.PrintToChat(ret)
		return
	}

	if(!FindByClassname(null, "point_populator_interface"))
		SpawnEntityFromTable("point_populator_interface", {})

	TranslateToChatAll("CHECKPOINT_RESTORE")
	TranslateToHudAll("CHECKPOINT_RESTORE_HUD")

	// ONLY WORKS WITH RAFMOD
	EntFireNew(FindByClassname(null, "point_populator_interface"), "$JumpToWave", ret.tostring())

	RemoveChatTrigger(CheckpointCommand)
}

function ReadCheckpoint(player)
{
	local file = split(FileToString(WAVE_SAVE_FILE), ":")
	foreach (string in file)
	{
		local temp = StringToArray(string)
		while (temp.find("\n") != null)
		{
			local index = temp.find("\n")
			if(index == null)
				break
			temp.remove(index)
		}
		file[file.find(string)] = temp
	}

	// printl(file.len())
	Assert(file.len() == 7, "Checkpoint File is BAD!")


	local map = "FUCK"
	local mission = "FUCK the second"
	local waves = "1/1"
	local endTime = 1
	local command = "0000"
	local valid = false

	try {
	map = ArrayToString(file[0])
	mission = ArrayToString(file[1])
	waves = ArrayToString(file[2])
	endTime = ArrayToString(file[3]).tointeger()
	command = ArrayToString(file[4])
	valid = file[5][2].tointeger() == 1
	}
	catch (e)
	{
		PrintToChatAllF("Something fucked up : %s", e)
		return
	}

	// printl(map)
	// printl(mission)
	// printl(waves)
	// printl(endTime)
	// printl(command)
	// printl(valid)

	// printl(endTime - GetTimeOfDay())

	if(GetMapName() != map)
		return player.GetTranslatedAndFormattedString("CHECKPOINT_WRONG_MAP")

	if(GetPopfileName() != mission)
		return player.GetTranslatedAndFormattedString("CHECKPOINT_WRONG_MISS")

	waves = split(waves, "/")

	local starting_wave = waves[0].tointeger()
	local max_wave = waves[1].tointeger()

	// if(starting_wave == 1)
		// return "The Checkpoint Saved on wave 1?"

	if(max_wave != GetMaximumWaveNumber())
		return "Checkpoints Maximum waves is different from current Maximum!"

	if(endTime < GetTimeOfDay())
		return player.GetTranslatedAndFormattedString("CHECKPOINT_EXPIRE")

	if(!valid)
		return "That Checkpoint is not Valid!"

	InvalidateCheckpoint()

	return starting_wave
}

function InvalidateCheckpoint()
{
	local file = StringToArray(FileToString(WAVE_SAVE_FILE))
	local index = null
	local last_2s = []
	local letter_idx = 0
	foreach (string in file)
	{
		letter_idx += 1
		last_2s.append(string)
		if(last_2s.len() > 2)
			last_2s.remove(0)
		if(last_2s[0] == "_" && last_2s[1] == "_")
		{
			index = letter_idx
			break
		}
	}

	if(index == null)
		return //printl("GUG")

	// printl(file[index])

	file[index] = 0

	// printl(file[index])

	StringToFile(WAVE_SAVE_FILE, ArrayToString(file))
}

function GetTimeOfDay()
{
	local cur_time = {}
	LocalTime(cur_time)

	local ActualTime = 0.0
	ActualTime += cur_time.hour * SECPERHOUR
	ActualTime += cur_time.minute * SECPERMIN
	ActualTime += cur_time.second

	return ActualTime
}

function SaveWaveData()
{
	local save 		= ""
	local wave 		= GetCurrentWaveNumber()
	local max_wave 	= GetMaximumWaveNumber()
	local map_name 	= GetMapName()

	local ActualTime = GetTimeOfDay()

	local Command = format("%04d", RandomInt(0, 9999))

	save += map_name + ":\n"
	save += GetPopfileName() + ":\n"
	save += (wave + "/" + max_wave) + ":\n"
	save += (ActualTime + SAVE_LIFETIME) + ":\n"
	save += Command + ":\n"
	save += "__" + 1 + ":\n"
	StringToFile(WAVE_SAVE_FILE, save)

	return Command
}

function WaveEndLogic()
{
	if(GetCurrentWaveNumber() == GetMaximumWaveNumber())
		return	// final wave complete
	if(CheckpointCommand != "")
		RemoveChatTrigger(CheckpointCommand)
	::CheckpointCommand <- SaveWaveData()
	AddChatTrigger(CheckpointCommand, WaveVoteCallback)

	TranslateToChatAll("CHECKPOINT_CREATED", CheckpointCommand)

	// PrintToChatAllF("\x077c8cc2Checkpoint created:\x078165cf [/%s]", CheckpointCommand)
	// PrintToChatAllF("Use \x03/%s\x01 to return back to this wave on a server Crash / Restart!", CheckpointCommand)
}

if("WaveSaving" in ROOT) ::WaveSaving.clear()
::WaveSaving <- {
	function OnScriptEvent_WaveComplete(_)
	{
		RunWithDelay(@() WaveEndLogic(), 0.1)
	}
}
__CollectGameEventCallbacks(WaveSaving)