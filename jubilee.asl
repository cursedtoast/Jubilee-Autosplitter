/*
--------------------------------------
	Jubilee Autosplitter

	By CursedToast 11.18.2021
	Last updated by Gaphodil 12.13.2023
--------------------------------------
*/

state("Jubilee")
{
	// 44133700 = title
	// 44133777 = first input of new game i.e. waking up
	// 44133700 + int = # of warpable shrine reached
	// 44133766 = hellgate cutscene begins
	// 44133798 = ending 1
	// 44133799 = ending 2
	double jubileeChanState : "Jubilee.exe", 0x004A1164, 0x0, 0x2C, 0x10, 0x540, 0x1C0;

	// when a campfire or shrine is touched, set to (x+8, y)
	// can be used to mark uniquely visited campfires
	double respawn_x : "Jubilee.exe", 0x004A1164, 0x0, 0x2C, 0x10, 0x540, 0x60;
	double respawn_y : "Jubilee.exe", 0x004A1164, 0x0, 0x2C, 0x10, 0x540, 0x50;
	
	// can't figure out animals/pages: stored in dynamic map so different each load

	double deathCount : "Jubilee.exe", 0x004A1164, 0x0, 0x2C, 0x10, 0x540, 0x120;
	double gems : "Jubilee.exe", 0x004A1164, 0x0, 0x2C, 0x10, 0x540, 0x170; // may be redundant
}

startup
{
	// settings.Add("endingOnly", false, "Split Only Ending");
	// settings.SetToolTip("endingOnly", "Split only on ending the game. Useful for casual runs and routing.");

	settings.Add("ending1", true, "Split on Normal Ending");
	settings.Add("ending2", true, "Split on H.E.C.K. Ending");

	settings.Add("hellgate", false, "Split on H.E.C.K. Gate Cutscene");

	settings.Add("splitCheckpoints", false, "Split on Checkpoints");
	settings.SetToolTip("splitCheckpoints", "Does not work if visiting the same checkpoint twice, including warps.");

	settings.Add("splitShrines", false, "Shrines", "splitCheckpoints");
	settings.Add("shrinesUnique", true, "Unique Shrines", "splitShrines");
	settings.SetToolTip("shrinesUnique", "Only split each shrine once. If disabled, repeats are allowed.");
	var shrineNames = new string[] {
		"Ruined Prison",
		"Bayou Entrance",
		"Top of the Waterfall",
		"The Mother Tree",
		"Insect Hive",
		"Canyon: Base Camp",
		"Canyon: Stone Village",
		"Mountain Mine",
		"Factory Control Room",
		"Factory Assembly Line",
		"Skylantis Gate",
		"Skylantis Overlook",
		"Belly of H.E.C.K.",
	};
	for (int i = 1; i <= 13; i++)
		settings.Add("shrine" + i, true, shrineNames[i-1], "splitShrines");
	
	settings.Add("splitCamps", false, "Campfires", "splitCheckpoints");
	settings.Add("campsUnique", true, "Unique Campfires", "splitCamps");
	settings.SetToolTip("campsUnique", "Only split each campfire once. If disabled, repeats are allowed.");

	vars.Shrines = new bool[13];
	vars.Checkpoints = new Dictionary<Tuple<int, int>, bool>();
}

onStart
{
	if (settings["splitShrines"])
		Array.Clear(vars.Shrines, 0, 13);
	if (settings["splitCheckpoints"])
		vars.Checkpoints.Clear();
}

split
{
	int isShrine = 0;
	if (current.jubileeChanState != old.jubileeChanState)
	{
		double cur = current.jubileeChanState;
		if (settings["ending1"] && cur == 44133798) return true;
		if (settings["ending2"] && cur == 44133799) return true;
		if (settings["hellgate"] && cur == 44133766) return true;
		if (settings["splitCheckpoints"])
		{
			for (int i = 1; i <= 13; i++)
			{
				if (cur == 44133700 + i)
				{
					// no splits here; shrine -> checkpoint -> shrine won't change state
					isShrine = i;
				}
			}
		}
	}

	int oldx = (int)old.respawn_x;
	int oldy = (int)old.respawn_y;
	int curx = (int)current.respawn_x;
	int cury = (int)current.respawn_y;
	if (settings["splitCheckpoints"] && (oldx != curx || oldy != cury))
	{
		var key = Tuple.Create(curx, cury);
		if (isShrine > 0)
		{
			if (settings["splitShrines"] && settings["shrine" + isShrine])
			{
				if (settings["shrinesUnique"])
				{
					if (!vars.Shrines[isShrine - 1])
					{
						vars.Checkpoints[key] = false; // failsafe for s -> c -> s
						vars.Shrines[isShrine - 1] = true;
						return true;
					}
					return false;
				}
				vars.Checkpoints[key] = true;
			}
			else
			{
				vars.Checkpoints[key] = false;
				return false;
			}
			
		}
		bool allowRepeat = false;
		bool wasVisited = vars.Checkpoints.TryGetValue(key, out allowRepeat);
		if (!settings["campsUnique"])
		{
			if (wasVisited && !allowRepeat) return false; // !cU & sU 
			return true;
		}
		if (!wasVisited) // cU
		{
			vars.Checkpoints[key] = false;
			return true;
		}
		if (wasVisited && allowRepeat) return true; // cU & !sU
	}
}

start
{
	return current.jubileeChanState == 44133777;
}

reset
{
	// won't work from continued save, but it wouldn't have anyway
	return old.jubileeChanState != 44133700 && current.jubileeChanState == 44133700;
}
