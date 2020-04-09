EFFECT.v_grav = Vector(0,0,-96)

function EFFECT:Init(data)
	self:SetModel("models/props_combine/breenbust_Chunk0"..math.random(3,7)..".mdl")
	self.Created = CurTime()
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self.Entity:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		self:GetPhysicsObject():SetVelocity(data:GetStart())
	end
	
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