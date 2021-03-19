# UT2004-NoMut

The NoMut contains a couple of mutators that will allow you to alter the content of levels as you see fit.
You will be able to either remove items completely or to replace one item with the other.

Note: changing content of levels has an impact on the game play. Thus using these mutators won't make your server show up as a standard server

This package contains the following mutators:

   - NoMut: Removes items from a level.
       - NoMut per Map: Per map configuration
   - ReMut: Replaces items in a level.
       - ReMut per Map: Per map configuration

# Revision history
## Changes since v100

- Pickup bases, weapon lockers and vehicles factories will now be checked and updated/removed when needed. This will have a more polished result.
- (NoMut only) Non removable actors (bNoDelete = true or bStatic = true) will now simply be hidden.
- Fixed the bRecurse option for ReMut, it didn't work at all

# NoMut
This mutator can remove certain elements from the level. You can remove things like pickups, vehicles, pretty much everything.

## Installation
The mutator name is: `NoMut.mutNoMut`

You can install it as any other mutator. When installed and configured correctly it will add a new field to the server info list:
```
NoMut Removes: ...
```

This contains a list actors that are removed from the game.

## Configuration
The configuration of this mutator goes into the system configuration file (UT2004.ini):

```
[NoMut.mutNoMut]
bLog=false
No=(ClassName="Package.Class",bRecurse=false,bSafeCheck=false,Exempt=("Package.Class","Package.Class"))
No=(ClassName="Package.Class",bRecurse=false,bSafeCheck=false)
No=(ClassName="Package.Class",bRecurse=false)
No=(ClassName="Package.Class")
...
```

### bLog
If set to true it will log the items removed from the game. This is a debug setting and is not recuired to be enabled.

### No

This is a list with classes to be removed. Virtually you can ad as much entries as you want. Only ClassName is required.

#### ClassName
This is the fully qualified name of the class to be removed, for example the fully qualified name of Assault rifle is: xWeapons.AssaultRiflePickup. If the ClassName is invalid it will be reported in the log.

You can use tools like UnCodeX, or it's output to find the full class names.

#### bRecurse
If this is set to true all subclasses of the specified classname will also be removed from this game. For example if the ClassName is Engine.Vehicle it will remove all vehicles from the game. False by default

#### bSafeCheck
Only remove actors if it's not vital for the game. The checks performed are listed below. Defaults to false.

#### Exempt
Exempt these classes from being replaced. This is only used when bRecurse=true. These subclasses will be left alone, this is also recursive.

# NoMut per Map
This mutator does the name as NoMut but it has a per map configuration. This will allow you to use different rules for each map.

## Installation
The mutator name is: `NoMut.mutNoMutPerMap`

## Configuration
The configuration is pretty much identical to the on of NoMut. The No= configuration is the default configuration if the current map doesn't have it's own configuration.

```
[NoMut.mutNoMutPerMap]
bLog=false
bAutoCreateConfig=false
ConfigClassName=NoMut.NoMutConfig
No=(ClassName="Package.Class",bRecurse=false,bSafeCheck=false,Exempt=("Package.Class","Package.Class"))
No=(ClassName="Package.Class",bRecurse=false,bSafeCheck=false)
No=(ClassName="Package.Class",bRecurse=false)
No=(ClassName="Package.Class")
...
```

### bAutoCreateConfig
If set to true a configuration entry is created for the map if it didn't have one already.

### ConfigClassName
This defines the configuration class used to store the per map configuration. See below for more info

## Per map configuration
Each map will have it's own section in the configuration file (depends on the ConfigClassName). Each section will look like this:

```
[MapName ConfigClass]
No=(ClassName="Package.Class",bRecurse=false,bSafeCheck=false,Exempt=("Package.Class","Package.Class"))
No=(ClassName="Package.Class",bRecurse=false,bSafeCheck=false)
No=(ClassName="Package.Class",bRecurse=false)
No=(ClassName="Package.Class")
...
```

### MapName
This is the name of the map, it's just filename without the extention. It's not case sensitive.
### ConfigClass
The name of the config class used, it's one of the following: NoMutConfig, NoMutConfigGlobal, NoMutConfigMap

### No
This configuration is identical to the mutator configuration.

### Configuration classes

#### NoMut.NoMutConfig
This is the default configuration class, it will store the per map configuration in the system configuration file (UT2004.ini). The ConfigClass name to use in the map configuration section is: NoMutConfig

#### NoMut.NoMutConfigGlobal
This will store the configuration per map in a global configuration file NoMutConfig.ini, this is usefull to share the complete configuration between servers. The ConfigClass name to use in the map configuration section is: NoMutConfigGlobal

#### NoMut.NoMutConfigMap
This will store the configuration in a seperate file for each map: MapName.ini. The ConfigClass name to use in the map configuration section is: NoMutConfigMap

# ReMut
This mutator can replace certain elements in the level. You can replace things pretty much anything for anything else, e.g. replace a vehicle for a weapon. This mutator is pretty much identical to the Arena mutators, except this gives you a more advanced method to configure.

Technical: every Actor with properties bNoDelete=false and bStatic=false can be replaced. Notice: Replacing actors is more difficult than simply removing them. For example, if you replace a weapon you also need to replace the weaponpickup and the weapon's ammo class. So when you replace actors do some research in other items that also might need to be replaced. ReMut will not do this automatically for your (because sometimes you want a complete different behavior).

## Installation
The mutator name is: `NoMut.mutReMut`

You can install it as any other mutator. When installed and configured correctly it will add a new field to the server info list:

```
ReMut Replaces: ...
```

This contains a list actors that are replaced.

## Configuration
The configuration of this mutator goes into the system configuration file (UT2004.ini):

```
[NoMut.mutReMut]
bLog=false
Re=(From="Package.Class",To="Package.Class",bRecurse=false,bSafeCheck=false,Exempt=("Package.Class","Package.Class"))
Re=(From="Package.Class",To="Package.Class",bRecurse=false,bSafeCheck=false)
Re=(From="Package.Class",To="Package.Class",bRecurse=false)
Re=(From="Package.Class",To="Package.Class")
...
```

### bLog
If set to true it will log the items removed from the game. This is a debug setting and is not recuired to be enabled.

### Re
This is a list with classes to be removed. Virtually you can ad as much entries as you want. Only From and To are required.

#### From, To
This is the fully qualified name of the class to be removed, for example the fully qualified name of Assault rifle is: xWeapons.AssaultRiflePickup. If the ClassName is invalid it will be reported in the log.
at the bottom of this page is a small list with fully qualified names of some game elements.
#### bRecurse
If this is set to true all subclasses of the specified From class will also be replaced. For example if From is Engine.Vehicle it will replace all vehicles. False by default
#### bSafeCheck
Only remove actors if it's not vital for the game. The checks performed are listed below. Defaults to false.
#### Exempt
Exempt these classes from being replaced. This is only used when bRecurse=true. These subclasses will be left alone, this is also recursive.

## ReMut per Map
This mutator is just like the NoMut per Map mutator a per map configuration of ReMut.

The mutator works the same as the NoMut version, the only difference is the class names used for the ConfigClassName variable.

| NoMut per Map class	| ReMut per Map class |
| ------------------- | ------------------- |
|NoMut.NoMutConfig	| NoMut.ReMutConfig|
|NoMut.NoMutConfigGlobal	| NoMut.ReMutConfigGlobal|
|NoMut.NoMutConfigMap	| NoMut.ReMutConfigMap|

# Appendix
## Safe Check
The following checks are performed to check if a actor is safe to be replaced\removed.

### Vehicle classes
bKeyVehicle variable is set to false. By default only the ONSMobileAssaultStation and ONSHoverTank_IonPlasma have these set.
### Weapon classes
bCanThrow variable is set to true. Weapons you can not throw are usualy important for the game (like the ball launcher)
### Controller classes
In case of Team Games the result of the function CriticalPlayer defines the safe state. This is game type depended, usualy you don't replace\remove controller classes 
    
