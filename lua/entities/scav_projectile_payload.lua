AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "payload bomb"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.dettime = 2

function ENT:Initialize()
	self.Entity:PhysicsInitBox(Vector(-24,-24,-24),Vector(24,24,24))
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	if SERVER then
		for k,v in ipairs(ents.GetAll()) do
			if v:IsNPC() then
				v:AddEntityRelationship(self,2,99)
			end
		end
	else
		self:EmitSound("items/cart_explode_trigger.wav")
	end
end

function ENT:Use()
end

function ENT:PhysicsUpdate()
	self:SetLocalAngles((self:GetPhysicsObject():GetVelocity()*-1):Angle())
end

function ENT:OnTakeDamage()
end

function ENT:PhysicsCollide(data,physobj)
end

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch(hitent)
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:Think()
	end
end

if SERVER then

	ENT.drag = 1

	function ENT:Think()

		if self.Explode and not self.expl then

			self.expl = true

			net.Start("scv_falloffsound")
				local rf = RecipientFilter()
				rf:AddAllPlayers()
				net.WriteVector(self:GetPos())
				net.WriteString("items/cart_explode.wav")
			net.Send(rf)

			self:SetPos(self:GetPos() + vector_up * 200)
			self:SetLocalAngles((vector_up * -1):Angle())
			util.ScreenShake(self:GetPos(),16,50,1,5000)
			util.BlastDamage(self,self.Owner,self:GetPos(),1000,500)
			ParticleEffectAttach("cinefx_goldrush",PATTACH_ABSORIGIN_FOLLOW,self,0)
			self:Fire("kill",1,10)
			self:SetNoDraw(true)
			self:DrawShadow(false)
			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_NONE)

		end

	end

	function ENT:PhysicsCollide(data,physobj)
		self.Explode = true
	end

	function ENT:Touch(hitent)
	end

end
