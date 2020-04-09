include('shared.lua')
ENT.mat = Material("effects/softglow")

local color_blue = Color(0,0,255,255)
local color_green = Color(0,255,0,255)
local color_red = Color(255,0,0,255)

function ENT:Draw()
	render.SetMaterial(self.mat)
	local pos = self:GetBonePosition(self:LookupBone("body"))
	if self.dt.state == 1 then --ally
		render.DrawSprite(pos,24,24,color_green)
	elseif self.dt.state == 2 then --enemy
		render.DrawSprite(pos,24,24,color_red)
	elseif self.dt.state == 3 then --disarmed
		render.DrawSprite(pos,24,24,color_blue)
	end
	self.Entity:DrawModel()
end

function ENT:PhysicsUpdate()
end