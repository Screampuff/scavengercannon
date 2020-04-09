ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "scav vphysics-projectile base"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"

ENT.BBMins = Vector(-5,-5,-5)
ENT.BBMaxs = Vector(5,5,5)
ENT.target = NULL
ENT.hashit = false
ENT.Speed = 2000

function ENT:PhysicsUpdate()

	if self.dead then return end
	
	if SERVER then
	
		local delta = CurTime() - self.lastupdate
		
		if IsValid(self.target) and (not self.target:IsPlayer() or (self.target:IsPlayer() and self.target:Alive())) then
			local vel = self:GetVelocity():Angle()
			local vec1 = (self.target:GetPos() + self.target:OBBCenter() - self:GetPos()):Angle()
			local amt = 45 * (CurTime() - self.Created) * delta
			vel.p = math.ApproachAngle(vel.p,vec1.p,amt)
			vel.y = math.ApproachAngle(vel.y,vec1.y,amt)
			vel.r = math.ApproachAngle(vel.r,vec1.r,amt)
			self:GetPhysicsObject():SetVelocity(vel:Forward() * self.Speed * self.SpeedScale)
		else
			if self.PhysInstantaneous then
				self:GetPhysicsObject():SetVelocityInstantaneous(self:GetPhysicsObject():GetVelocity():GetNormalized() * self.Speed * self.SpeedScale)
			else
				self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity():GetNormalized() * self.Speed * self.SpeedScale)
			end
			self.target = NULL
		end
		
		if self.Gravity then
			self:GetPhysicsObject():AddVelocity(self.Gravity * delta)
		end
		
		if self:GetVelocity():Length() ~= 0 then
			self:SetLocalAngles(self:GetPhysicsObject():GetVelocity():GetNormalized():Angle())
		end
		
		self.lastupdate = CurTime()
		
	end
end

function ENT:Initialize()

	if self.Model then
		self:SetModel(self.Model)
	end
	
	self.Created = CurTime()
	self:DrawShadow(false)
	
	if SERVER then
	
		self:PhysicsInitBox(self.BBMins,self.BBMaxs)
		self:SetCollisionBounds(self.BBMins,self.BBMaxs)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		self.lastupdate = CurTime()
		self:SetTrigger(true)
		
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
		
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		
			if self.PhysType == 1 then
				phys:SetBuoyancyRatio(0)
				phys:EnableDrag(false)
				phys:EnableGravity(false)
			end
			
			if self.vel then
				phys:SetVelocity(self.vel)
			end
		
		end
		
	else
		self:SetMoveType(MOVETYPE_NONE)
	end
	
	self:OnInit()
	
end

function ENT:OnInit()
end

function ENT:Use()
end

