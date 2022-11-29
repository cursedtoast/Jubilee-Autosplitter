/*
--------------------------------------
	Jubilee Autosplitter

	By CursedToast 11.18.2021
	Update by Gaphodil 11.28.2022
--------------------------------------
*/

state("Jubilee")
{
	double jubileeChanState : "Jubilee.exe", 0x004A1164, 0x0, 0x2C, 0x10, 0x540, 0x1C0;
	double clearTime : "Jubilee.exe", 0x004A1164, 0x0, 0x2C, 0x10, 0x540, 0x180; // not sure what datatype this should be
}

startup
{
	settings.Add("endingOnly", false, "Split Only Ending");
    settings.SetToolTip("endingOnly", "Split only on ending the game. Useful for casual runs and routing.");
}

split
{
	if (settings["endingOnly"])
	{
		return current.clearTime != old.clearTime && current.clearTime != 0;
	}
	else
	{
		return current.jubileeChanState != old.jubileeChanState;
	}
}

start
{
	return current.jubileeChanState == 44133777;
}

reset
{
	return current.jubileeChanState == 44133700;
}
