/*******************************************************************************
	Removes anything from the game (from Weapons, to vehicles, almost
	everything)

	Creation date: 06/08/2004 16:53
	Copyright (c) 2004, Michiel "El Muerte" Hendriks
	<!-- $Id: mutNoMut.uc,v 1.1 2004/08/06 16:59:20 elmuerte Exp $ -->
*******************************************************************************/

class mutNoMut extends Mutator config;

/** actual structure that contains resolved classes */
struct NoStruct
{
	var class<Actor> ClassType;
	var bool bRecurse;
};
var array<NoStruct> NoC;

/** the configuration structure, used strings that will be resolved during loading */
struct NoConfigStruct
{
	/** the full name of the class to remove: Engine.Vehicle */
	var string ClassName;
	/** if true also remove subclasses */
	var bool bRecurse;
};
/** configuration array, to reset the configuration to an empty list simply use "No=" */
var config array<NoConfigStruct> No;

/** log removals */
var globalconfig bool bLog;

event PreBeginPlay()
{
	local int i;
	local class<Actor> A;

	super.PreBeginPlay();
	for (i = 0; i < No.length; i++)
	{
		if (No[i].ClassName == "") continue;
		A = class<Actor>(DynamicLoadObject(No[i].ClassName, class'Class', true));
		if (A != none)
		{
			if (A.default.bNoDelete && !No[i].bRecurse)
			{
				log(No[i].ClassName@"can never be removed from the game (bNoDelete = true)", name);
			}
			else if (A.default.bStatic && !No[i].bRecurse)
			{
				log(No[i].ClassName@"can never be removed from the game (bStatic = true)", name);
			}
			else {
				NoC.length = NoC.length+1;
				NoC[NoC.length-1].ClassType = A;
				NoC[NoC.length-1].bRecurse = No[i].bRecurse;
			}
		}
		else {
			log(No[i].ClassName@"could not be loaded, invalid class", name);
		}
	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int i;
	local bool bRemove;
	for (i = 0; i < NoC.length; i++)
	{
		if (NoC[i].bRecurse) bRemove = Other.IsA(NoC[i].ClassType.name);
		else bRemove = (Other.Class == NoC[i].ClassType);
		if (bRemove)
		{
			if (bLog) log("Removed"@Other.Class@"@"@Other.Location, name);
			bSuperRelevant = 1;
			return false;
		}
	}
	return true;
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local int i;
	local string s;
	super.GetServerDetails(ServerState);
	for (i = 0; i < NoC.length; i++)
	{
		if (s != "") s $= ", ";
		if (NoC[i].bRecurse) s $= "!";
		s $= NoC[i].ClassType.name;
	}
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "NoMuT Removes";
	ServerState.ServerInfo[i].Value = s;
}

defaultproperties
{
	FriendlyName="NoMut"
	Description="Removes anything from the game (from Weapons, to vehicles, almost everything)"
	GroupName="NoMut"
	bLog=false
}
