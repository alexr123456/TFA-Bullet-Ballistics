AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/bullets/w_pbullet1.mdl" )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )

	ParticleEffectAttach( "dax_bullettrail2", PATTACH_ABSORIGIN_FOLLOW, self, 1)

end
