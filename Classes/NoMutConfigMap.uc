/*******************************************************************************
	Saves the configuration to a file with the same name as the map

	Creation date: 06/08/2004 16:53
	Copyright (c) 2004, Michiel "El Muerte" Hendriks
	<!-- $Id: NoMutConfigMap.uc,v 1.1 2004/08/06 16:59:20 elmuerte Exp $ -->
*******************************************************************************/

class NoMutConfigMap extends NoMutConfig config;

defaultproperties
{
	ConfigFile="@MAP"
}