-- RUBY ROCKS

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("entities/config/config.lua")

local health = SM.rubyHealth
local basePay = SM.rubyValue
local respawnTime = SM.rubyRespawn

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos
	local dist = tr.HitPos - ( tr.HitNormal * 1.5 )
	local Axis = Vector(0,0,0)
	SpawnPos = dist

	if tr.HitNormal.z < 0 then
		Axis = Vector(0, 1, 0):Cross(tr.HitNormal)
		Axis:Normalize()
	else
		Axis = Vector(0, 0, 1):Cross(tr.HitNormal)
		Axis:Normalize()
	end

	local dot = Vector(0,0,1):Dot(tr.HitNormal)
	local dotang = math.acos(dot)

	local SpawnAng = Angle(0, ply:EyeAngles().y, 0)
	SpawnAng:RotateAroundAxis(Axis, math.deg(dotang))

	local self = ents.Create( ClassName )
	self:SetModel(table.Random(SM.rockModels))
	self:SetPos( SpawnPos )
	self:SetAngles( SpawnAng )
	self:Spawn()
	self:Activate()
	self:SetColor( Color( 255, 0, 97 ) )
	self:SetRenderMode( RENDERMODE_NORMAL ) -- I dont think this does anything
	self:SetCollisionGroup( 20 )
	self.shouldRespawn = true
	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )

	return self
end

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow( false )
	self:GetPhysicsObject():SetMass(1000)
	if self:GetPhysicsObject():IsValid() then self:GetPhysicsObject():Wake() end

	self:SetHealth( health )
end

function ENT:UpdateTransmitState()
	if ( self.shouldRespawn ) then
		return TRANSMIT_PVS
	end
	
	return TRANSMIT_NEVER
end

function ENT:OnTakeDamage( dmginfo )
	if ( not self.m_bApplyingDamage ) then
		self.m_bApplyingDamage = true
		self:TakeDamageInfo( dmginfo )

		if dmginfo:GetDamage() >= self:Health() && self.shouldRespawn then
			self.shouldRespawn = false
			self:EmitSound( "physics/concrete/concrete_break2.wav" )
			SM.Payout(dmginfo:GetAttacker(), basePay, math.floor(self:GetModelRadius()))
			self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
			timer.Simple( respawnTime, function()
				self:SetHealth( health )
				self.shouldRespawn = true
				self.m_bApplyingDamage = false
				self:RemoveAllDecals()
				self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
			end )
		else
			if ( IsValid(dmginfo:GetAttacker()) ) then self:SetHealth( self:Health() - dmginfo:GetDamage() ) end
		end
		self.m_bApplyingDamage = false
	end
end

function ENT:Think()
end