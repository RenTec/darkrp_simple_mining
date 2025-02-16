if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = "Simple Pickaxe"

SWEP.Purpose = "Mine some ores!"
SWEP.Instructions = "Primary attack: Swing at glowing rocks."
SWEP.Category = "Simple Mining"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV = 75
SWEP.UseHands = true

SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Slot               = 1
SWEP.SlotPos 			= 0
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = true

function SWEP:Initialize()
	self:SetHoldType( "melee2" )
end

SWEP.HitDistance		= 40
SWEP.HitInclination		= 0.4
SWEP.HitPushback		= 1000
SWEP.HitRate			= 1.35
SWEP.MinDamage			= 34
SWEP.MaxDamage			= 50

local SwingSound = Sound( "WeaponFrag.Roll" )
local HitSoundWorld = Sound( "Canister.ImpactHard" )
local HitSoundBody = Sound( "Flesh.ImpactHard" )
local PushSoundBody = Sound( "Flesh.ImpactSoft" )

function SWEP:Initialize()

	self:SetHoldType( "melee2" )
end

function SWEP:PrimaryAttack()

	self.Owner:AnimRestartGesture(0, 64, true)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )	
	self:EmitSound( SwingSound )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.HitRate )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.HitRate )

end