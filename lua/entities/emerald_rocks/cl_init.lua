include('shared.lua')
include("entities/config/config.lua")

local mode = GetConVar("sm_dlights")
function ENT:Draw()

	self:DrawModel()

	if mode:GetInt() == 0 then
		return
	elseif mode:GetInt() == 1 then
		SM.lqLighting(self)
	elseif mode:GetInt() == 2 then
		SM.hqLighting(self)
	elseif mode:GetInt() == 3 then
		SM.lqLighting(self)
		SM.hqLighting(self)
	end
end