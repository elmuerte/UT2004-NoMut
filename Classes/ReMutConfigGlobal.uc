/*******************************************************************************
	Saves the configuraion to a global config file: NoMutConfig

	Creation date: 06/08/2004 16:53
	Copyright (c) 2004, Michiel "El Muerte" Hendriks
	<!-- $Id: ReMutConfigGlobal.uc,v 1.1 2004/08/06 17:59:51 elmuerte Exp $ -->
*******************************************************************************/

class ReMutConfigGlobal extends ReMutConfig config(NoMutConfig);

defaultproperties
{
	ConfigFile="NoMutConfig"
}
