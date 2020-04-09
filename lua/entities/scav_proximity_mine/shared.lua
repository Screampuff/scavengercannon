ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "scav_proximity_mine"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "okay, you can spawn this"

ENT.WarningRange = 400
ENT.DetonationRange = 150
ENT.Damage = 128
ENT.Range = 200

PrecacheParticleSystem("scav_proxmine_green")
PrecacheParticleSystem("scav_proxmine_red")

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
		self.sound1 = CreateSound(self,"ambient/alarms/apc_alarm_loop1.wav")
		self.sound1:ChangePitch(255)
		self.expl = false
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
	end

end

function ENT:Use()
end

function ENT:Think()

	if SERVER then
		local prox = false
		if CurTime() > self.Created+3 then
			local tab = ents.FindInSphere(self:GetPos(),self.WarningRange)
			local ownerless = !self.Owner || !self.Owner:IsValid()
			for i=1,table.getn(tab),1 do
				if (tab[i]:IsPlayer() or tab[i]:IsNPC()) && (ownerless || !tab[i]:IsFriendlyToPlayer(self.Owner)) then
					if (tab[i]:GetPos():Distance(self:GetPos()) < self.DetonationRange) then
						self:Explode()
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

		//if CurTime() > self.Created+60 then
		//	self:Explode()
		//end

		if (CurTime() > self.Created+3) && !self.ready then
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
	





	self:NextThink(CurTime()+0.1)
	return true
end




