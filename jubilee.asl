/*
--------------------------------------
	Jubilee Autosplitter
	
	By CursedToast 11.18.2021
	Last updated 11.19.2021
--------------------------------------
*/

state("Jubilee")
{
	double jubileeChanState : "Jubilee.exe", 0x004A1164, 0x0, 0x2C, 0x10, 0x540, 0x1C0;
}

split
{
	return current.jubileeChanState != old.jubileeChanState;
}

start
{
	return current.jubileeChanState == 44133777;
}

reset
{
	return current.jubileeChanState == 44133700;
}
