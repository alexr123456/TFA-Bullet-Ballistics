# TFA Bullet Ballistics
This is currently not intended for players, if you are a developer please read [below](https://github.com/Daxble/TFA-Bullet-Ballistics#installationsetup).

# Info
Shotguns will not work on this base, even if the weapon is set to use this it will not work on weapons that fire more than one bullet per shot.

# FAQ
Q. It doesn't seem like it's working up close?  
A. Hitscan bullets are used on shots less than 1000 source units ( ~19.5 Meters )

___

Q. Why are the bullets so fast  
A. This aims to simulate real bullets, not Battlefield bullets.  
**Kar98K: Muzzle velocity = 760m/s, 300m shot, distance/velocity = 0.39 seconds to hit**

___

Q. Why isn't my weapon using the bullets?  
A. You need to do the setup for **Every** weapon that needs ballistics

# Installation/Setup

1. Download the addon as a zip
2. Extract the *TFA-Bullet-Ballistics-master* folder to your addons folder

**The following steps need to be completed for each weapon that will use ballistics**

3. Change the SWEP base to "tfa_ballistic_base"
```lua
SWEP.Base = "tfa_ballistic_base"
```
4. Place the following lines somewhere in your weapon
```lua
SWEP.Primary.Velocity = 760 // Velocity in Meters ( Defaults to 500 )
SWEP.TracerEffect = "dax_bullettrail3_green" // dax_bullettrail2, dax_bullettrail2_red, dax_bullettrail2_green, dax_bullettrail3, dax_bullettrail3_red, dax_bullettrail3_green, nil to disable ( Defaults to dax_bullettrail3_green )
```

# To Do
1. Fix bugs ( Always in Progress )
2. Add wind system ( Done )
3. Proper bullet drop using verlet integration ( Done )
4. Eötvös effect ( Maybe )
5. Spin Drift ( Maybe )

# Bugs
1. Aimcone doesn't do anything
2. Firing at feet causes bullet to go through surface ( Fixed )

Please report other bugs [here](https://github.com/Daxble/TFA-Bullet-Ballistics/issues) if possible.

# Credits
TFA - Helping with bullet drop and velocity code  
Matsilagi - Particles and Workarounds  
Daxble - Everything else  

# License

**TFA Bullet Ballistics is licensed under GNU General Public License v3.0**

| **Can**  | **Cannot** | **Must** |
| ------------- | ------------- | ------------- |
| Commercial Use  | Sublicense  | Include Original*  |
| Modify  | Hold Liable  | State Changes*  |
| Distribute  |   | Disclose Source*  |
| Place Warranty  |   | Include License  |
| Use Patent Claims  |   | Include Copyright  |
| Modify  |   | Include Install Instructions  |

**Include Original:** You must include a link to this page or a copy of the code itself.

**State Changes:** You must state **significant** changes made to the code.

**Disclose Source:** You must expose all source code to all users.
