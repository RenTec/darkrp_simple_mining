include('shared.lua')

function ENT:Think()
	if self:GetNWBool( "lightOn" ) then
		local pos = self:GetPos()
		local speed = 1
		local time = CurTime() * speed
		local lighting = DynamicLight( self:EntIndex() )
		if ( lighting ) then
			lighting.Pos = pos + self:GetUp() * 30
			lighting.r = math.sin(time) * 127 + 128
			lighting.g = math.sin(time + 2) * 127 + 128
			lighting.b = math.sin(time + 4) * 127 + 128
			lighting.Brightness = 1
			lighting.Size = 215
			lighting.Decay = 2500
			lighting.DieTime = CurTime() + 0.1
		end
	end
end