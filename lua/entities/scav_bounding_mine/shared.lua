ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "scav_proximity_mine"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "okay, you can spawn this"
ENT.Owner = NULL

function ENT:SetupDataTables()
	self:DTVar("Int",0,"state")
end

function ENT:Initialize()
	self:SetPoseParameter("blendstates",65)
	self.Created = CurTime()
	if SERVER then
		self.sound1 = CreateSound(self,"npc/roller/mine/combine_mine_active_loop1.wav")
		self.sound1:ChangePitch(255)
		self.expl = false
		self.Owner:AddScavExplosive(self)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
	end
	if CLIENT then
		self.ready = false
	end

end




function ENT:Use()
end

function ENT:Think()
	if self.Explode and not self.exploded and IsValid(self.Owner) then
		self.exploded = true
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		fx:SetRadius(100)
		util.Effect("Explosion",fx)
		util.BlastDamage(self,self.Owner,self:GetPos(),200,128)
		self:Remove()
	end
	if self.nothink then
		return
	end
	if SERVER then
		if !self.constraint:IsValid() && self.constrained then
			self:Disarm()
		elseif self.constraint:IsValid() && !self.constrained then
			self:Arm()
		end
		local prox
		if self.constraint:IsValid() then
			local tab = ents.FindInSphere(self:GetPos(),300)
			for i=1,table.getn(tab),1 do
				if (tab[i]:IsPlayer() or tab[i]:IsNPC()) then
					if (tab[i]:GetPos():Distance(self:GetPos()) < 150) && !tab[i]:IsFriendlyToPlayer(self.Owner) then
						self.constraint:Remove()
						timer.Simple(0, function() self:GetPhysicsObject():Wake() end)
						timer.Simple(0, function() self:GetPhysicsObject():SetVelocity(VectorRand()*300+Vector(0,0,1000)) end)
						timer.Simple(0, function() self:GetPhysicsObject():AddAngleVelocity(VectorRand()*400) end)
						self:GetPhysicsObject():AddGameFlag(FVPHYSICS_WAS_THROWN)
						self:EmitSound("npc/roller/mine/rmine_blip3.wav")	
						self:Disarm()
						self.dt.state = 0
						self.nothink = true
						break
					else
						if prox && !prox:IsFriendlyToPlayer(self.Owner) then
							prox = tab[i]
						elseif !prox then
							prox = tab[i]
						end
					end
				end
			end
			if prox then
				if prox:IsFriendlyToPlayer(self.Owner) then
					self.dt.state = 1
				else
					self.sound1:Play()
					self.dt.state = 2
				end
			else
				self.sound1:Stop()
				self.dt.state = 0
			end
		elseif self:IsHeld() then
			self:SetPoseParameter("blendstates",math.sin(CurTime()*7)*32+32)
		end
		if (self:GetPhysicsObject():GetVelocity() == vector_origin) && !(self.constraint && self.constraint:IsValid()) then
				local tracep = {}
				tracep.start = self:GetPos()+self:OBBCenter()
				tracep.filter = self
				tracep.endpos = tracep.start-self:GetAngles():Up()*10
				tracep.mask = MASK_SHOT
				tr = util.TraceLine(tracep)
			//if tr.Entity:IsValid() && (tr.Entity:GetPhysicsObjectCount() == 1) || tr.Entity:IsWorld() && (tr.HitNormal.z > 0.5) && (self:GetAngles():Up().z > 0.5) then
			if tr.HitWorld && (tr.HitNormal.z > 0.5) && (self:GetAngles():Up().z > 0.5) then
				self:Constrain(tr.Entity)
			elseif self.hascollided then
				self:GetPhysicsObject():SetVelocity(VectorRand()*100+Vector(0,0,700))
				self:GetPhysicsObject():AddAngleVelocity(VectorRand()*600)
				self:EmitSound("npc/roller/mine/rmine_blip3.wav")
				self.hascollided = false
			end
		end
		if (CurTime() > self.Created+3) && !self.ready then
			self.ready = true
		end
		
		
	end



	if CLIENT then
		self.inrange = false
		local tab = ents.FindInSphere(self:GetPos(),250)
		for i=1,table.getn(tab),1 do
			if tab[i]:IsPlayer() or tab[i]:IsNPC() then
				self.inrange = true
			end
		end
	end	
	





	self:NextThink(CurTime()+0.1)
	return true
end




