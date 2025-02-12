-- GOLD ROCKS

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("entities/config/config.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal - Vector(0, 0, 5)
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local self = ents.Create( ClassName )
	self:SetModel(table.Random(SM.rockModels))
	self:SetPos( SpawnPos )
	self:SetAngles( SpawnAng )
	self:Spawn()
	self:Activate()
	self:SetColor( Color( 255, 190, 0 ) )
	self:SetMaterial("models/antlion/antlion_innards")
	self:SetRenderMode( RENDERMODE_GLOW ) -- I dont think this does anything
	self:SetCollisionGroup( 20 )
	self.shouldRespawn = true
	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
	self:SetNWBool( "lightOn", true )

	return self
end

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow( false )
	self:GetPhysicsObject():SetMass(1000)
	if self:GetPhysicsObject():IsValid() then self:GetPhysicsObject():Wake() end

	self:SetHealth( 100 )
end

function ENT:UpdateTransmitState()
	if self.shouldRespawn then
		return TRANSMIT_PVS
	else
		return TRANSMIT_NEVER
	end
end

function ENT:OnTakeDamage( dmginfo )
	if ( not self.m_bApplyingDamage ) then
		self.m_bApplyingDamage = true
		self:TakeDamageInfo( dmginfo )

		if self:Health() <= 0 && self.shouldRespawn then
			self.shouldRespawn = false
			self:EmitSound( "physics/concrete/concrete_break2.wav" )
			dmginfo:GetAttacker():addMoney(table.KeyFromValue(SM.rockModels, self:GetModel()))
			self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
			self:SetNWBool( "lightOn", false )
			timer.Simple( SM.respawnTime, function()
				self:SetHealth( 100 )
				self.shouldRespawn = true
				self.m_bApplyingDamage = false
				self:RemoveAllDecals()
				self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
				self:SetNWBool( "lightOn", true )
			end )
		else
			if ( IsValid(dmginfo:GetAttacker()) ) then self:SetHealth( self:Health() - dmginfo:GetDamage() ) end
		end
		self.m_bApplyingDamage = false
	end
end

function ENT:Think()
end