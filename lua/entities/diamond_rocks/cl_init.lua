include('shared.lua')

function ENT:Think()
	if self:GetNWBool( "lightOn" ) then
		local pos = self:GetPos()
		local lighting = DynamicLight( self:EntIndex() )
		if ( lighting ) then
			lighting.Pos = pos + self:GetUp() * 30
			lighting.r = 185
			lighting.g = 242
			lighting.b = 255
			lighting.Brightness = 1
			lighting.Size = 215
			lighting.Decay = 2500
			lighting.DieTime = CurTime() + 0.1
		end
	end
end