/*******************************************************************************
    Removes anything from the game (from Weapons, to vehicles, almost
    everything)

    Creation date: 06/08/2004 16:53
    Copyright (c) 2004, Michiel "El Muerte" Hendriks
    <!-- $Id: mutReMut.uc,v 1.7 2004/10/20 14:04:45 elmuerte Exp $ -->
*******************************************************************************/

class mutReMut extends Mutator config;

/** the actual struct used for replacements */
struct ReStruct
{
    var class<Actor> From;
    var class<Actor> To;
    var bool bRecurse;
    var bool bSafeCheck;
    var array< class<Actor> > Exempt;
};
var array<ReStruct> ReC;

/** the config structure */
struct ConStruct
{
    var string From;
    var string To;
    var bool bRecurse;
    var bool bSafeCheck;
    var array< string > Exempt;
};
/** replacement configuration */
var() config array<ConStruct> Re;

/** log replacements, not adviced to enable */
var() config bool bLog;

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
    local class<Actor> A, B, Ax;

    super.PreBeginPlay();

    cntPickup = 0;
    cntVehicle = 0;
    cntWeapon = 0;
    cntTournamentPickup = 0;

    for (i = 0; i < Re.length; i++)
    {
        if (Re[i].From == "") continue;
        if (Re[i].To == "") continue;

        A = class<Actor>(DynamicLoadObject(Re[i].From, class'Class', true));
        B = class<Actor>(DynamicLoadObject(Re[i].To, class'Class', true));
        if (A != none && B != none)
        {
            if (A.default.bNoDelete && !Re[i].bRecurse)
            {
                log(Re[i].From@"can never be replaced (bNoDelete = true)", name);
            }
            else if (A.default.bStatic && !Re[i].bRecurse)
            {
                log(Re[i].From@"can never be replaced (bStatic = true)", name);
            }
            else {
                if (SIsA(A, class'Pickup')) cntPickup++;
                if (SIsA(A, class'Vehicle')) cntVehicle++;
                if (SIsA(A, class'Weapon')) cntWeapon++;
                if (SIsA(A, class'TournamentPickup')) cntTournamentPickup++;

                n = ReC.length;
                ReC.length = n+1;
                ReC[n].From = A;
                ReC[n].To = B;
                ReC[n].bSafeCheck = Re[i].bSafeCheck;
                ReC[n].bRecurse = Re[i].bRecurse;
                // process exempt
                if (Re[i].bRecurse && Re[i].Exempt.length > 0)
                {
                    for (j = 0; j < Re[i].Exempt.length; j++)
                    {
                        Ax = class<Actor>(DynamicLoadObject(Re[i].Exempt[j], class'Class', true));
                        if (Ax != none )
                        {
                            ReC[n].Exempt[ReC[n].Exempt.length] = Ax;
                        }
                    }
                }
            }
        }
        else {
            if (A == none) log(Re[i].From@"could not be loaded, invalid class", name);
            if (B == none) log(Re[i].To@"could not be loaded, invalid class", name);
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
    for (i = 0; i < ReC.length; i++)
    {
        if (!ReC[i].bRecurse) bUpdate = (cmpc == ReC[i].From);
        else {
            bUpdate = SIsA(cmpc, ReC[i].From);
            if (bUpdate)
            {
                for (j = 0; j < ReC[i].Exempt.length; j++)
                {
                    if (SIsA(cmpc, ReC[i].Exempt[j]))
                    {
                        bUpdate = false;
                        break;
                    }
                }
            }
        }
        if (bUpdate)
        {
            if (!SIsA(ReC[i].To, class'Pickup'))
            {
                xbase.bHidden = true;
            }
            else {
                xbase.PowerUp = class<Pickup>(ReC[i].To);
                if (xWeaponBase(xbase) != none)
                {
                    xWeaponBase(xbase).WeaponType = class<Weapon>(class<Pickup>(ReC[i].To).default.InventoryType);
                }
            }
            if (bLog) log("Updated xPickUpBase"@xbase.class@"@"@xbase.Location, name);
            break;
        }
    }
}

/** hide+disable vehicle factories when their vehicle isn't allowed */
function updateVehicleFactory(SVehicleFactory sbase)
{
    local int i, j;
    local bool bUpdate;

    for (i = 0; i < ReC.length; i++)
    {
        if (!ReC[i].bRecurse) bUpdate = (sbase.VehicleClass == ReC[i].From);
        else {
            bUpdate = SIsA(sbase.VehicleClass, ReC[i].From);
            if (bUpdate)
            {
                for (j = 0; j < ReC[i].Exempt.length; j++)
                {
                    if (SIsA(sbase.VehicleClass, ReC[i].Exempt[j]))
                    {
                        bUpdate = false;
                        break;
                    }
                }
            }
        }

        if (bUpdate)
        {
            if (ReC[i].bSafeCheck) if (sbase.VehicleClass.default.bKeyVehicle) return;
            if (!SIsA(ReC[i].To, class'Vehicle'))
            {
                // not a vehicle, remove it
                sbase.bHidden = true;
                if (ONSVehicleFactory(sbase) != none)
                {
                    ONSVehicleFactory(sbase).bActive = false;
                    ONSVehicleFactory(sbase).bNeverActivate = true; // to remove the initial effect
                }
                if (ASVehicleFactory(sbase) != none)
                {
                    if (ReC[i].bSafeCheck) ASVehicleFactory(sbase).bEnabled = !ASVehicleFactory(sbase).bKeyVehicle;
                    else ASVehicleFactory(sbase).bEnabled = false;
                }
            }
            else {
                sbase.VehicleClass = class<Vehicle>(ReC[i].To);
            }
            if (bLog) log("Updated SVehicleFactory"@sbase.class@"@"@sbase.Location, name);
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
        for (i = 0; i < ReC.length; i++)
        {
            if (!ReC[i].bRecurse) bUpdate = (wc == ReC[i].From);
            else {
                bUpdate = SIsA(wc, ReC[i].From);
                if (bUpdate)
                {
                    for (j = 0; j < ReC[i].Exempt.length; j++)
                    {
                        if (SIsA(wc, ReC[i].Exempt[j]))
                        {
                            bUpdate = false;
                            break;
                        }
                    }
                }
            }
            if (bUpdate)
            {
                if (!SIsA(ReC[i].To, class'Weapon'))
                {
                    weap.Weapons.remove(n, 1);
                }
                else {
                    if (bLog) log("Updated WeaponLocker"@weap.class@"@"@weap.Location@": changed"@weap.Weapons[n].WeaponClass@"to"@ReC[i].To , name);
                    weap.Weapons[n].WeaponClass = class<Weapon>(ReC[i].To);
                }
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

    log("WildcardBase"@wbase.class@"@"@wbase.Location@":no pickups anymore", name);
    for (n = ArrayCount(wbase.PickupClasses); n > 0; n--)
    {
        wc = wbase.PickupClasses[n];
        for (i = 0; i < ReC.length; i++)
        {
            if (!ReC[i].bRecurse) bUpdate = (wc == ReC[i].From);
            else {
                bUpdate = SIsA(wc, ReC[i].From);
                if (bUpdate)
                {
                    for (j = 0; j < ReC[i].Exempt.length; j++)
                    {
                        if (SIsA(wc, ReC[i].Exempt[j]))
                        {
                            bUpdate = false;
                            break;
                        }
                    }
                }
            }
            if (bUpdate)
            {
                if (!SIsA(ReC[i].To, class'TournamentPickup'))
                {   // no tournament pickup, remove it
                    wbase.PickupClasses[n] = none;
                    for (y = n+1; y < ArrayCount(wbase.PickupClasses)-1; y++)
                    {
                        wbase.PickupClasses[y-1] = wbase.PickupClasses[y];
                    }
                    wbase.PickupClasses[y] = none;
                }
                else {
                    log("Removed wildcard item:"@wbase.PickupClasses[n]);
                    wbase.PickupClasses[n] = class<TournamentPickup>(ReC[i].To);
                }
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

/** check replacements to replace/update unallowed actors */
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local int i, j;
    local bool bReplace;

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

    for (i = 0; i < ReC.Length; i++)
    {
        if (ReC[i].bRecurse)
        {
            bReplace = Other.IsA(ReC[i].From.name);
            if (bReplace)
            {
                for (j = 0; j < ReC[i].Exempt.length; j++)
                {
                    if (Other.IsA(ReC[i].Exempt[j].name))
                    {
                        bReplace = false;
                        break;
                    }
                }
            }
        }
        else bReplace = (Other.Class == ReC[i].From);
        if (Other.Class == ReC[i].To) bReplace = false;

        if (bReplace && (!ReC[i].bSafeCheck || class'mutNoMut'.static.IsSafe(Level, Other)))
        {
            if (Other.bNoDelete || Other.bStatic) return true;
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
        if (ReC[i].Exempt.Length > 0) s $= "~";
        s $= ReC[i].From.name@"->"@ReC[i].To.name;
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
