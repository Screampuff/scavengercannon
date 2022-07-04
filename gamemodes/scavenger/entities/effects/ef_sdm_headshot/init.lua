function EFFECT:Init(data)
	self.Created = CurTime()
	self:EmitSound("weapons/ar1/ar1_dist1.wav",100,100)
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:GetPhysicsObject():SetVelocity(Vector(math.Rand(-5,5),math.Rand(5,5),math.Rand(170,240)))
	self:GetPhysicsObject():SetMaterial("gmod_silent")
end

function EFFECT:Think()
	if self.Created+1 < CurTime() then
		return false
	end
	return true
end

function EFFECT:Render()
	local pos = self:GetPos():ToScreen()
	local progress = math.Clamp(CurTime()-self.Created,0,1)
	cam.Start2D()
		surface.SetTextColor(255,255,255,(1-progress)*255)
		surface.SetFont("ConsoleText")
		local text = ("Headshot!")
		local w,h = surface.GetTextSize(text)
		surface.SetTextPos(pos.x-w/2,pos.y-progress*48)
		surface.DrawText(text)
	cam.End2D()
	return true
end