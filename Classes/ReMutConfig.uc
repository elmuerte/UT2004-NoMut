/*******************************************************************************
	Per map configuration for mutReMutPerMap. Name of the instance is the map
	name

	Creation date: 06/08/2004 16:53
	Copyright (c) 2004, Michiel "El Muerte" Hendriks
	<!-- $Id: ReMutConfig.uc,v 1.1 2004/08/06 17:59:51 elmuerte Exp $ -->
*******************************************************************************/

class ReMutConfig extends Object dependson(mutReMut) config(System) perobjectconfig;

/** configuration file this class uses for storage */
var const string ConfigFile;
/** per map storage */
var config array<mutReMut.ConStruct> Re;

defaultproperties
{
	ConfigFile="System"
}
