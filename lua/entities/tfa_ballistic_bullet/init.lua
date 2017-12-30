AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/bullets/w_pbullet1.mdl" )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )

	timer.Simple( 0.05, function()
		util.SpriteTrail( self, 1, Color(255, 152, 43), false, 0.1, 0, 0.01, 1, "trails/smoke.vmt")
	end )

end
