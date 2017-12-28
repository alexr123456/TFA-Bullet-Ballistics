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
