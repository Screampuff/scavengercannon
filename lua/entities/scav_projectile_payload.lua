AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "payload bomb"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.dettime = 2
ENT.tf2 = false

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	if not self.Entity:GetPhysicsObject():IsValid() then
		self.Entity:PhysicsInitBox(Vector(-24,-24,-24),Vector(24,24,24))
		self.Entity:SetSolid(SOLID_VPHYSICS)
	end
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	
	if self.Entity:GetModel() == "models/props_trainyard/cart_bomb_separate.mdl" then
		self.tf2 = true
	end

	if SERVER then
		for k,v in ipairs(ents.GetAll()) do
			if v:IsNPC() then
				v:AddEntityRelationship(self,D_FR,99)
			end
		end
	else
		if self.tf2 then
			self:EmitSound("items/cart_explode_trigger.wav")
		else
			self:EmitSound("ambient/explosions/explode_4.wav",75,100,.75)
		end
	end
end

function ENT:Use()
end

function ENT:PhysicsUpdate()
	local ang = self:GetPhysicsObject():GetVelocity():Angle()
	if self.Entity:GetModel() == "models/props_phx/misc/flakshell_big.mdl" then
		ang:Add(Angle(90,0,0))
	elseif self.Entity:GetModel() == "models/props_trainyard/cart_bomb_separate.mdl" then
		ang:Add(Angle(180,0,0))
	end
	self:SetLocalAngles(ang)
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

	function ENT:DrawTranslucent()
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
				if self.tf2 then
					net.WriteString("items/cart_explode.wav")
				else
					net.WriteString("ambient/explosions/explode_5.wav")
				end
			net.Send(rf)

			self:SetPos(self:GetPos() + vector_up * 200)
			self:SetLocalAngles((vector_up * -1):Angle())
			util.ScreenShake(self:GetPos(),16,50,1,5000)
			util.BlastDamage(self,self.Owner,self:GetPos(),1000,500)
			if self.tf2 then
				ParticleEffectAttach("cinefx_goldrush",PATTACH_ABSORIGIN_FOLLOW,self,0)
			else
				ParticleEffectAttach("scav_exp_fireball3",PATTACH_ABSORIGIN_FOLLOW,self,0)
			end
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
