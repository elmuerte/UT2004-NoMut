/*******************************************************************************
	Removes anything from the game (from Weapons, to vehicles, almost
	everything) per map configuration

	Creation date: 06/08/2004 16:53
	Copyright (c) 2004, Michiel "El Muerte" Hendriks
	<!-- $Id: mutNoMutPerMap.uc,v 1.1 2004/08/06 16:59:20 elmuerte Exp $ -->
*******************************************************************************/

class mutNoMutPerMap extends mutNoMut config;

/** automatically create config entries for each map */
var() config bool bAutoCreateConfig;
/** class to use for loading the configuration */
var() config string ConfigClassName;
var class<NoMutConfig> ConfigClass;

event PreBeginPlay()
{
	ConfigClass = class<NoMutConfig>(DynamicLoadObject(ConfigClassName, class'class'));
	if (ConfigClass == none) ConfigClass = default.ConfigClass;
	LoadPerMapConfig();
	super.PreBeginPlay();
	No = default.No; // reset default configuration
}

/** load the configuration for this map */
function LoadPerMapConfig()
{
	local array<string> MapConfigs;
	local int i;
	local NoMutConfig MapCfg;
	local string MapName;
	local bool MapCfgFile;

	MapName = Left(string(Level), InStr(string(Level), "."));
	MapCfgFile = ConfigClass.default.ConfigFile ~= "@MAP";
	if (MapCfgFile) MapConfigs = GetPerObjectNames(MapName, string(ConfigClass.name));
	else MapConfigs = GetPerObjectNames(ConfigClass.default.ConfigFile, string(ConfigClass.name));
	for (i = 0; i < MapConfigs.length; i++)
	{
		if (MapConfigs[i] ~= MapName) break;
	}
	if (i == MapConfigs.length)
	{
		if (bAutoCreateConfig)
		{
			if (MapCfgFile) MapCfg = new(self, MapName) ConfigClass;
			else MapCfg = new(none, MapName) ConfigClass;
			MapCfg.No = No;
			MapCfg.SaveConfig();
		}
		Log("No configuration for"@MapName$", using default", name);
		return;
	}
	if (MapCfgFile) MapCfg = new(self, MapName) ConfigClass;
	else MapCfg = new(none, MapName) ConfigClass;
	No = MapCfg.No;
	Log("Loaded per map configuration for"@MapName, name);
}

defaultproperties
{
	FriendlyName="NoMut per Map"
	Description="Removes anything from the game (from Weapons, to vehicles, almost everything) per map configuration"

	ConfigClassName="NoMut.NoMutConfig"
	ConfigClass=class'NoMutConfig'
	bAutoCreateConfig=false
}
