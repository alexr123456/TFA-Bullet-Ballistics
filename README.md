# TFA Bullet Ballistics
This is currently not intended for players, if you are a developer please read below.

To get ballistics working with your weapon you only have to do two things.

1. Change the SWEP base to "tfa_ballistic_base"
```lua
SWEP.Base = "tfa_ballistic_base"
```
2. Setup the bullet velocity ( This defaults to 500 )
```lua
SWEP.Primary.Velocity = 760 // Velocity in Meters
```
