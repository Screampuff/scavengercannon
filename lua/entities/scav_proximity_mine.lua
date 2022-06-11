AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "base_anim"
ENT.PrintName 			= "Proximity Mine"
ENT.Author 				= "Ghor"

ENT.WarningRange 		= 400
ENT.DetonationRange 	= 150
ENT.Damage 				= 128
ENT.Range 				= 200

PrecacheParticleSystem("scav_proxmine_green")
PrecacheParticleSystem("scav_proxmine_green_colorblind")
PrecacheParticleSystem("scav_proxmine_red")
PrecacheParticleSystem("scav_proxmine_red_colorblind")

function ENT:SetupDataTables()
	self:DTVar("Int",0,"state")
	self:DTVar("Bool",0,"sticky")
	self:DTVar("Bool",1,"silent")
	self:DTVar("Bool",2,"showrings")
	self:DTVar("Bool",2,"showrings")
	self.dt.sticky = true
	self.dt.silent = false
	self.dt.showrings = true
end

function ENT:Initialize()

	self.Created = CurTime()
	
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self.sound1 = CreateSound(self,"ambient/alarms/apc_alarm_loop1.wav")
		self.sound1:ChangePitch(255)
		self.expl = false
	end

end

function ENT:Think()

	if SERVER then
	
		if IsValid(self) and self.Explode and not self.exploded then
		
			self.exploded = true
			
			local edata = EffectData()
			edata:SetOrigin(self:GetPos())
			edata:SetNormal(vector_up)
			util.Effect("ef_scav_exp",edata)
			
			if IsValid(self.Owner) then
				util.BlastDamage(self,self.Owner,self:GetPos(),self.Range,self.Damage)
			end
			
			self:Remove()
			
		end
	
		local prox = false
		
		if CurTime() > self.Created + 3 then
		
			local tab = ents.FindInSphere(self:GetPos(),self.WarningRange)
			local ownerless = not IsValid(self.Owner)
			
			for i=1,table.getn(tab),1 do
				if (tab[i]:IsPlayer() or tab[i]:IsNPC()) and (ownerless or not tab[i]:IsFriendlyToPlayer(self.Owner)) then
					if tab[i]:GetPos():Distance(self:GetPos()) < self.DetonationRange then
						self.Explode = true
						break
					else
						prox = true
					end
				end
			end
			
			if prox then
				self:SetState(2)
			else
				self:SetState(1)
			end
			
		end

		if CurTime() > self.Created + 3 and not self.ready then
			self.ready = true
			self:EmitSound("buttons/button17.wav")
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
	
	self:NextThink(CurTime() + 0.1)
	return true
	
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

if SERVER then

	function ENT:OnTakeDamage(dmginfo)
		if not self.exploded and dmginfo:GetDamageType() ~= DMG_PHYSGUN then
			timer.Simple(0.2, function() 
				if IsValid(self) and not self.exploded then 
					self.Explode = true
				end 
			end)
		end
	end

	ENT.constraint = NULL

	function ENT:PhysicsCollide(data,physobj)
		if not self.dt.sticky then return end
		local ent = data.HitEntity
		if not IsValid(self.constraint) and ((ent:GetPhysicsObjectCount() == 1 and not (ent:IsPlayer() or ent:IsNPC())) or ent:IsWorld()) then
			timer.Simple(0, function() self:Constrain(ent, data.HitPos - self:OBBCenter()) end)
		end
	end

	function ENT:Constrain(hitent,weldpos)
		if weldpos then
			self:SetPos(weldpos)
		end
		self.constraint = constraint.Weld(self,hitent,0,0,2000,false)
	end

	function ENT:SetState(state)

		if state ~= self.dt.state then
		
			self:StopParticles()
			self.dt.state = state
			
			if state == 1 then --friendly
			
				if self.dt.showrings then
					if self.dt.showrings then
						if not GetConVar("cl_scav_colorblindmode"):GetBool() then
							ParticleEffectAttach("scav_proxmine_green",PATTACH_ABSORIGIN_FOLLOW,self,0)
						else
							ParticleEffectAttach("scav_proxmine_green_colorblind",PATTACH_ABSORIGIN_FOLLOW,self,0)
						end
					end
				end
				
				self.sound1:Stop()
				
			elseif state == 2 then --enemy
			
				if self.dt.showrings then
					if self.dt.showrings then
						if not GetConVar("cl_scav_colorblindmode"):GetBool() then
							ParticleEffectAttach("scav_proxmine_red",PATTACH_ABSORIGIN_FOLLOW,self,0)
						else
							ParticleEffectAttach("scav_proxmine_red_colorblind",PATTACH_ABSORIGIN_FOLLOW,self,0)
						end
					end
				end
				
				if not self.dt.silent then
					self.sound1:PlayEx(15,255)
				end
				
			end
			
		end
		
	end

	function ENT:OnRemove()
		if self.sound1 then
			self.sound1:Stop()
		end
	end

end