ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "comball"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"

function ENT:Initialize()
	self:SetModel("models/Effects/combineball.mdl")
	self.Created = CurTime()
	if SERVER then
		self.expl = false
		--self.Entity:PhysicsInitBox(Vector(-5,-5,-5),Vector(5,5,5))
		--self.Entity:SetCollisionBounds(Vector(-5,-5,-5),Vector(5,5,5))
		self:PhysicsInitSphere(8)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self:GetPhysicsObject():EnableGravity(false)
		local ef = EffectData()
		ef:SetOrigin(self:GetPos())
		ef:SetEntity(self)
		util.Effect("ef_comball",ef)
		--util.SpriteTrail(self,1,Color(255,255,255),false,32,0,1,0.0625,"trails/smoke.vmt")
		self.sound = CreateSound(self,"weapons/physcannon/energy_sing_loop4.wav")
	else
		--self.loop = CreateSound(self,"weapons/rpg/rocket1.wav")
		--self.loop:Play()
		self.expl = false
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_NONE)
		self:EmitSound("weapons/physcannon/energy_sing_flyby"..math.random(1,2)..".wav")
	end
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:Use()
end

function ENT:PhysicsUpdate()
	if SERVER then
		if self:GetPhysicsObject():GetVelocity() == vector_origin then
			self:GetPhysicsObject():SetVelocity(self:GetLocalAngles():Forward())
		end
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity():GetNormalized()*1500)
		self:SetLocalAngles(self:GetPhysicsObject():GetVelocity():GetNormalized():Angle())
	end
end
