/*******************************************************************************
	Removes anything from the game (from Weapons, to vehicles, almost
	everything)

	Creation date: 06/08/2004 16:53
	Copyright (c) 2004, Michiel "El Muerte" Hendriks
	<!-- $Id: mutNoMut.uc,v 1.7 2004/08/12 19:49:12 elmuerte Exp $ -->
*******************************************************************************/

class mutNoMut extends Mutator config;

/** actual structure that contains resolved classes */
struct NoStruct
{
	var class<Actor> ClassType;
	var bool bRecurse;
	var bool bSafeCheck;
	var array< class<Actor> > Exempt;
};
var array<NoStruct> NoC;

/** the configuration structure, used strings that will be resolved during loading */
struct NoConfigStruct
{
	/** the full name of the class to remove: Engine.Vehicle */
	var string ClassName;
	/** if true also remove subclasses */
	var bool bRecurse;
	/** check if the class is safe to replace, e.g. not required for the game */
	var bool bSafeCheck;
	/** if bRecurse exempt these classes (recursively) from being deleted */
	var array<string> Exempt;
};
/** configuration array, to reset the configuration to an empty list simply use "No=" */
var config array<NoConfigStruct> No;

/** log removals */
var globalconfig bool bLog;

/** used for updating bases */
var protected int cntPickup, cntVehicle, cntWeapon, cntTournamentPickup;

/** static IsA using classes */
static function bool SIsA(class A, class B)
{
	return ClassIsChildOf(A, B) || (A == B);
}

event PreBeginPlay()
{
	local int i, j, n;
	local class<Actor> A, Ax;

	super.PreBeginPlay();

	cntPickup = 0;
	cntVehicle = 0;
	cntWeapon = 0;
	cntTournamentPickup = 0;

	for (i = 0; i < No.length; i++)
	{
		if (No[i].ClassName == "") continue;
		A = class<Actor>(DynamicLoadObject(No[i].ClassName, class'Class', true));
		if (A != none)
		{
			/*
			if (A.default.bNoDelete && !No[i].bRecurse)
			{
				log(No[i].ClassName@"can never be removed from the game (bNoDelete = true)", name);
			}
			else if (A.default.bStatic && !No[i].bRecurse)
			{
				log(No[i].ClassName@"can never be removed from the game (bStatic = true)", name);
			}
			else {
			*/
				if (SIsA(A, class'Pickup')) cntPickup++;
				if (SIsA(A, class'Vehicle')) cntVehicle++;
				if (SIsA(A, class'Weapon')) cntWeapon++;
				if (SIsA(A, class'TournamentPickup')) cntTournamentPickup++;

				n = NoC.length;
				NoC.length = n+1;
				NoC[n].ClassType = A;
				NoC[n].bRecurse = No[i].bRecurse;
				NoC[n].bSafeCheck = No[i].bSafeCheck;
				// process exempt
				if (No[i].bRecurse && No[i].Exempt.length > 0)
				{
					for (j = 0; j < No[i].Exempt.length; j++)
					{
						Ax = class<Actor>(DynamicLoadObject(No[i].Exempt[j], class'Class', true));
						if (Ax != none )
						{
							NoC[n].Exempt[NoC[n].Exempt.length] = Ax;
						}
					}
				}
			/*
			}
			*/
		}
		else {
			log(No[i].ClassName@"could not be loaded, invalid class", name);
		}
	}
}

/** hide pickup bases when their pickup isn't allowed */
function updateXPickUpBase(xPickUpBase xbase)
{
	local int i, j;
	local bool bUpdate;
	local class<Actor> cmpc;

	cmpc = xbase.PowerUp;
	if (xWeaponBase(xbase) != none) cmpc = xWeaponBase(xbase).WeaponType.default.PickupClass;

	if (cmpc == none) return;
	for (i = 0; i < NoC.length; i++)
	{
		if (!NoC[i].bRecurse) bUpdate = (cmpc == NoC[i].ClassType);
		else {
			bUpdate = SIsA(cmpc, NoC[i].ClassType);
			if (bUpdate)
			{
				for (j = 0; j < NoC[i].Exempt.length; j++)
				{
					if (SIsA(cmpc, NoC[i].Exempt[j]))
					{
						bUpdate = false;
						break;
					}
				}
			}
		}
		if (bUpdate)
		{
			if (bLog) log("Hide xPickUpBase"@xbase.class@"@"@xbase.Location, name);
			xbase.bHidden = true;
			break;
		}
	}
}

/** hide+disable vehicle factories when their vehicle isn't allowed */
function updateVehicleFactory(SVehicleFactory sbase)
{
	local int i, j;
	local bool bUpdate;

	for (i = 0; i < NoC.length; i++)
	{
		if (!NoC[i].bRecurse) bUpdate = (sbase.VehicleClass == NoC[i].ClassType);
		else {
			bUpdate = SIsA(sbase.VehicleClass, NoC[i].ClassType);
			if (bUpdate)
			{
				for (j = 0; j < NoC[i].Exempt.length; j++)
				{
					if (SIsA(sbase.VehicleClass, NoC[i].Exempt[j]))
					{
						bUpdate = false;
						break;
					}
				}
			}
		}

		if (bUpdate)
		{
			if (NoC[i].bSafeCheck) if (sbase.VehicleClass.default.bKeyVehicle) return;
			if (bLog) log("Hide SVehicleFactory"@sbase.class@"@"@sbase.Location, name);
			sbase.bHidden = true;
			if (ONSVehicleFactory(sbase) != none) ONSVehicleFactory(sbase).bActive = false;
			if (ASVehicleFactory(sbase) != none)
			{
				if (NoC[i].bSafeCheck) ASVehicleFactory(sbase).bEnabled = !ASVehicleFactory(sbase).bKeyVehicle;
				else ASVehicleFactory(sbase).bEnabled = false;
			}
			break;
		}
	}
}

/** remove weapons from the weapon lockers, and hide the weapon locker if it's empty */
function updateWeaponLocker(WeaponLocker weap)
{
	local int i, j, n;
	local bool bUpdate;
	local class<Weapon> wc;

	for (n = weap.Weapons.Length-1; n >= 0; n--)
	{
		wc = weap.Weapons[n].WeaponClass;
		for (i = 0; i < NoC.length; i++)
		{
			if (!NoC[i].bRecurse) bUpdate = (wc == NoC[i].ClassType);
			else {
				bUpdate = SIsA(wc, NoC[i].ClassType);
				if (bUpdate)
				{
					for (j = 0; j < NoC[i].Exempt.length; j++)
					{
						if (SIsA(wc, NoC[i].Exempt[j]))
						{
							bUpdate = false;
							break;
						}
					}
				}
			}
			if (bUpdate)
			{
				weap.Weapons.remove(n, 1);
				break;
			}
		}
	}
	if (weap.Weapons.Length == 0)
	{
		weap.bHidden = true;
		if (bLog) log("Hide WeaponLocker"@weap.class@"@"@weap.Location@":no weapons anymore", name);
	}
}

/** update wildcard bases */
function updateWildcardBase(WildcardBase wbase)
{
	local int i, j, n, y;
	local bool bUpdate;
	local class<TournamentPickup> wc;

	for (n = ArrayCount(wbase.PickupClasses); n > 0; n--)
	{
		wc = wbase.PickupClasses[n];
		for (i = 0; i < NoC.length; i++)
		{
			if (!NoC[i].bRecurse) bUpdate = (wc == NoC[i].ClassType);
			else {
				bUpdate = SIsA(wc, NoC[i].ClassType);
				if (bUpdate)
				{
					for (j = 0; j < NoC[i].Exempt.length; j++)
					{
						if (SIsA(wc, NoC[i].Exempt[j]))
						{
							bUpdate = false;
							break;
						}
					}
				}
			}
			if (bUpdate)
			{
				wbase.PickupClasses[n] = none;
				for (y = n+1; y < ArrayCount(wbase.PickupClasses)-1; y++)
				{
					wbase.PickupClasses[y-1] = wbase.PickupClasses[y];
				}
				wbase.PickupClasses[y] = none;
				break;
			}
		}
	}

	i = 0;
	for (n = 0; n < ArrayCount(wbase.PickupClasses); n++)
	{
		if (wbase.PickupClasses[n] != none) i++;
	}
	wbase.NumClasses = i;
	if (i == 0)
	{
		wbase.bHidden = true;
		if (bLog) log("Hide WildcardBase"@wbase.class@"@"@wbase.Location@":no pickups anymore", name);
	}
	else wbase.CurrentClass = wbase.CurrentClass % wbase.NumClasses;
}

/** check replacements to remove/update unallowed actors */
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int i, j;
	local bool bRemove;

	if (SVehicleFactory(Other) != none && cntVehicle > 0)
	{
		updateVehicleFactory(SVehicleFactory(Other));
		return true;
	}
	if (WildcardBase(Other) != none && cntTournamentPickup > 0)
	{
		updateWildcardBase(WildcardBase(Other));
		return true;
	}
	if (xPickUpBase(Other) != none && cntPickup > 0)
	{
		updateXPickUpBase(xPickUpBase(Other));
		return true;
	}
	if (WeaponLocker(Other) != none && cntWeapon > 0)
	{
		updateWeaponLocker(WeaponLocker(Other));
		return true;
	}

	for (i = 0; i < NoC.length; i++)
	{
		if (NoC[i].bRecurse)
		{
			bRemove = Other.IsA(NoC[i].ClassType.name);
			if (bRemove)
			{
				for (j = 0; j < NoC[i].Exempt.length; j++)
				{
					if (Other.IsA(NoC[i].Exempt[j].name))
					{
						bRemove = false;
						break;
					}
				}
			}
		}
		else bRemove = (Other.Class == NoC[i].ClassType);
		if (bRemove && (!NoC[i].bSafeCheck || IsSafe(Level, Other)))
		{
			if (Other.bNoDelete || Other.bStatic)
			{
				if (bLog) log("Hiding"@Other.Class@"@"@Other.Location, name);
				Other.bHidden = true;
			}
			else {
				if (bLog) log("Removed"@Other.Class@"@"@Other.Location, name);
				bSuperRelevant = 1;
				return false;
			}
		}
	}
	return true;
}

/**
	returns true when it's safe to remove the actor.
*/
static function bool IsSafe(LevelInfo Level, Actor Other)
{
	if (Vehicle(Other) != none) return !Vehicle(Other).bKeyVehicle;
	if (Controller(Other) != none && TeamGame(Level.Game) != none) return !TeamGame(Level.Game).CriticalPlayer(Controller(Other));
	if (Weapon(Other) != none) return Weapon(Other).bCanThrow;
	return true;
}

/**
	Append details on the actors removed
*/
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local int i;
	local string s;
	super.GetServerDetails(ServerState);
	for (i = 0; i < NoC.length; i++)
	{
		if (s != "") s $= ", ";
		if (NoC[i].Exempt.Length > 0) s $= "~";
		if (NoC[i].bRecurse) s $= "!";
		s $= NoC[i].ClassType.name;
	}
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "NoMut Removes";
	ServerState.ServerInfo[i].Value = s;
}

defaultproperties
{
	FriendlyName="NoMut"
	Description="Removes anything from the game (from Weapons, to vehicles, almost everything)"
	GroupName="NoMut"
	bLog=false
}
