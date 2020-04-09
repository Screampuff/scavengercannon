EFFECT.v_grav = Vector(0,0,-96)
EFFECT.em = ParticleEmitter(vector_origin)
local icemodels = {"models/props_junk/watermelon01_chunk02a.mdl","models/props_debris/concrete_chunk03a.mdl","models/props_combine/breenbust_Chunk03.mdl"}

function EFFECT:Init(data)
	self:SetModel(table.Random(icemodels))
	self.Created = CurTime()
	self:SetMaterial("models/shiny")
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetAngles(data:GetNormal():Angle())
	local phys = self.Entity:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMaterial("gmod_ice")
		phys:AddAngleVelocity(VectorRand()*math.random(1,360))
		self:GetPhysicsObject():SetVelocity(data:GetStart())
	end
	for i=1,4 do
		local part = self.em:Add("particle/smokesprites_000"..math.random(1,9),self:GetPos())
		if part then
			part:SetColor(150,180,200)
			local vel = Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500))
			local lifeoffset = math.Rand(0,1)
			part:SetVelocity(vel)
			part:SetAirResistance(500)
			part:SetGravity(Vector(0,0,-50))
			part:SetDieTime(lifeoffset+1)
			part:SetStartSize(32)
			part:SetEndSize(128)
			part:SetStartAlpha(255)
			part:SetEndAlpha(20)
		end
--		self.em:Finish()
	end
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetColor(Color(175,227,255,255))
end

function EFFECT:Think()
	if (CurTime()-self.Created) > 10 then
		return false
	else
		return true
	end
end

function EFFECT:Render()
	self:DrawModel()
	return true
end