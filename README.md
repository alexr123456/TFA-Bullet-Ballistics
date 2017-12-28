# TFA Bullet Ballistics
This is an in development build, this is not meant for players just yet.

To get ballistics working with your weapon you only have to do two things.

1. Change the SWEP base to "tfa_ballistic_base"
```lua
SWEP.Base = "tfa_ballistic_base"
```
2. Setup the bullet velocity
```lua
SWEP.Primary.Velocity = 760 // Velocity in Meters
```

# To Do
1. Fix bugs
2. Add wind system
3. Proper bullet drop using verlet integration ( Done I think )
4. Eötvös Effect

# Bugs
1. Aimcone doesn't do anything
2. Firing at feet causes bullet to go through surface ( Fixed )

Please report other bugs [here](https://github.com/Daxble/TFA-Bullet-Ballistics/issues) issues if possible.

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
