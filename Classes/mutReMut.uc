/*******************************************************************************
	Removes anything from the game (from Weapons, to vehicles, almost
	everything)

	Creation date: 06/08/2004 16:53
	Copyright (c) 2004, Michiel "El Muerte" Hendriks
	<!-- $Id: mutReMut.uc,v 1.2 2004/08/08 09:33:00 elmuerte Exp $ -->
*******************************************************************************/

class mutReMut extends Mutator config;

/** the actual struct used for replacements */
struct ReStruct
{
	var class<Actor> From;
	var class<Actor> To;
	var bool bRecurse;
	var bool bSafeCheck;
};
var array<ReStruct> ReC;

/** the config structure */
struct ConStruct
{
	var string From;
	var string To;
	var bool bRecurse; //TODO: implement this feature
	var bool bSafeCheck; //TODO: implement this feature
};
/** replacement configuration */
var() config array<ConStruct> Re;

/** log replacements, not adviced to enable */
var() config bool bLog;

event PreBeginPlay()
{
	local int i;
	local class<Actor> A, B;

	super.PreBeginPlay();
	for (i = 0; i < Re.length; i++)
	{
		if (Re[i].From == "") continue;
		if (Re[i].To == "") continue;

		A = class<Actor>(DynamicLoadObject(Re[i].From, class'Class', true));
		B = class<Actor>(DynamicLoadObject(Re[i].To, class'Class', true));
		if (A != none && B != none)
		{
			if (A.default.bNoDelete)
			{
				log(ReC[i].From@"can never be removed from the game (bNoDelete = true)", name);
			}
			else if (A.default.bStatic)
			{
				log(ReC[i].From@"can never be removed from the game (bStatic = true)", name);
			}
			else {
				ReC.length = ReC.length+1;
				ReC[ReC.length-1].From = A;
				ReC[ReC.length-1].To = B;
			}
		}
		else {
			if (A == none) log(Re[i].From@"could not be loaded, invalid class", name);
			if (B == none) log(Re[i].To@"could not be loaded, invalid class", name);
		}
	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int i;
	local bool bReplace;
	for (i = 0; i < ReC.Length; i++)
	{
		bReplace = (Other.Class == ReC[i].From);

		if (bReplace && (!ReC[i].bSafeCheck || class'mutNoMut'.static.IsSafe(Level, Other)))
		{
			if (bLog) log("Replaced"@Other.Class@"@"@Other.Location@"with"@Rec[i].To, name);
			ReplaceWith( Other, string(Rec[i].To));
			return false;
		}
	}
	return True;
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local int i;
	local string s;
	super.GetServerDetails(ServerState);
	for (i = 0; i < Rec.length; i++)
	{
		if (s != "") s $= ", ";
		s $= Rec[i].From.name@"->"@Rec[i].To.name;
	}
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "ReMut Replaces";
	ServerState.ServerInfo[i].Value = s;
}

defaultproperties
{
	FriendlyName="ReMut"
	Description="Replaces one object for the other. Anything can be replaced to anything."
	GroupName="ReMut"
	bLog=false
}
