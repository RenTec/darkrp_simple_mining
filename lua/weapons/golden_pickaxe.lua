if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = "Golden Pickaxe"

SWEP.Purpose = "Mine some ores but faster!"
SWEP.Instructions = "Primary attack: Swing at glowing rocks."
SWEP.Category = "Simple Mining"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/hl2meleepack/v_pickaxe.mdl"
SWEP.WorldModel = "models/weapons/hl2meleepack/w_pickaxe.mdl"
SWEP.ViewModelFOV = 70
SWEP.UseHands = true

SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Slot               = 1
SWEP.SlotPos 			= 0
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = true

function SWEP:Initialize()
	self:SetHoldType( "melee2" )
end

SWEP.HitRate			= 1.35
SWEP.HitDamage			= 25

local SwingSound = Sound( "WeaponFrag.Roll" )
local HitSoundCrystal = Sound( "Canister.ImpactHard" )
local HitSoundWorld = Sound( "Default.BulletImpact" )
local HitSoundBody = Sound( "Flesh.ImpactHard" )

function SWEP:Initialize()

	self:SetHoldType( "melee2" )
end

function SWEP:PrimaryAttack()


	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.HitRate )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.HitRate )

	local tr = util.TraceLine( {
		start = self.Owner:EyePos(),
		endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 80,
		filter = self.Owner
	} )

	local vm = self.Owner:GetViewModel()

	if IsValid(tr.Entity) then
		if ( string.EndsWith(tr.Entity:GetClass(), "_rocks" ) ) then
			self:EmitSound( HitSoundCrystal )
			util.Decal( "Impact.Glass", self.Owner:EyePos(), tr.HitPos, self.Owner )
		elseif ( string.match( tr.Entity:GetClass(), "player" ) ) then
			self:EmitSound( HitSoundBody )
		else
			self:EmitSound( HitSoundWorld )
		end
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "hitcenter1" ) )
		if SERVER then
			local dmg = DamageInfo() -- Create a server-side damage information class
			if ( string.match( tr.Entity:GetClass(), "player" ) ) then
				dmg:SetDamage( 0 )
			else
				dmg:SetDamage( self.HitDamage )
			end
			dmg:SetAttacker( self.Owner )
			dmg:SetInflictor( self )
			dmg:SetDamageType( DMG_GENERIC )
			tr.Entity:TakeDamageInfo( dmg )
		end
	else
		self:EmitSound( SwingSound )
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "misscenter1" ) )
	end
	
	self:GetOwner():ViewPunch( Angle( -1, 0, 0 ) )
end

function SWEP:SecondaryAttack()
	-- do nothing
end