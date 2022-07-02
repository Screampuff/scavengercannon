AddCSLuaFile()
EFFECT.Base = "ef_base_onoff"
EFFECT.RBmin = Vector(-16,-16,-16)
EFFECT.RBmax = Vector(16,16,16)
EFFECT.shoulddie = false
local mat = Material("sprites/physbeama")
local col = Color(100,100,255,255)

function EFFECT:Init(data)
	self.Owner = data:GetEntity()
	self.Weapon = self.Owner:GetActiveWeapon()
	self.Gravity = VectorRand()*math.Rand(0,1)
	self.LengthPerPart = math.random(2,20)
	self.norm = (data:GetNormal()+VectorRand()*0.05):GetNormalized()
	self.Created = CurTime()
end

function EFFECT:Think()
	if (CurTime()-self.Created > 0.2) or not self.Weapon:IsValid() then
		return false
	end
	return true
end

function EFFECT:Render()
	if not self.Owner then return false end
	local pos = self:GetTracerShootPos(self.Owner:GetShootPos(),self.Weapon,1)
	if not self.SetupBeam then
		local norm = self.norm
		self.points = {}
		self.points[1] = Vector(0,0,0)
		for i=1,9 do
			self.norm = (self.norm+VectorRand()*0.075):GetNormalized()
			table.insert(self.points,self.points[i]+self.norm*self.LengthPerPart)
		end	
		self.SetupBeam = true
	end
	self.shootpos = self:GetTracerShootPos(self.Owner:GetShootPos(),self.Weapon,1)
	local wscale = (1-(CurTime()-self.Created)*5)*3
	local offset = math.Clamp(math.floor((CurTime()-self.Created)*40),0,5)
	render.SetMaterial(mat)
	render.StartBeam(10)
		for i=1,10 do
			render.AddBeam(pos+self.points[i],(10-i)*wscale,i/10,col)
		end
	render.EndBeam()
	return true
end
