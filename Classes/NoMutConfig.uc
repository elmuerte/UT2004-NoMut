/*******************************************************************************
    Per map configuration for mutNoMutPerMap. Name of the instance is the map
    name

    Creation date: 06/08/2004 16:53
    Copyright (c) 2004, Michiel "El Muerte" Hendriks
    <!-- $Id: NoMutConfig.uc,v 1.2 2004/10/20 14:04:44 elmuerte Exp $ -->
*******************************************************************************/

class NoMutConfig extends Object dependson(mutNoMut) config(System) perobjectconfig;

/** configuration file this class uses for storage */
var const string ConfigFile;
/** per map storage */
var config array<mutNoMut.NoConfigStruct> No;

defaultproperties
{
    ConfigFile="System"
}
