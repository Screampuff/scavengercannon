ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "hyper beam"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.mins = Vector(-24,-24,-24)
ENT.maxs = Vector(24,24,24)
ENT.lasttrace = 0
ENT.PhysInstantaneous = true
PrecacheParticleSystem("scav_hyper")

function ENT:Initialize()
	self:SetModel("models/Effects/combineball.mdl")
	self.Created = CurTime()
	self:SetMoveType(MOVETYPE_NONE)
	if SERVER then	
		if not self.filter then
			self.filter = {self.Owner}
		end
	else
		ParticleEffectAttach("scav_hyper",PATTACH_ABSORIGIN_FOLLOW,self,0)
		self.vel = self:GetAngles():Forward()*2000
		self.Weapon = self:GetOwner():GetActiveWeapon()
		self.Owner = self:GetOwner()
		self.Created = CurTime()
	end
	self:DrawShadow(false)
	self.lasttrace = CurTime()

end


function ENT:Think()
	if CLIENT then
		local vel = self.vel*(CurTime()-self.lasttrace)
		self:SetPos(self:GetPos()+vel)
	else
		if self.Created+10 < CurTime() then
			self:Remove()
			return
		end
		self:NextThink(CurTime()+0.05)
	--MOVEMENT CODE
		local tr = {}
		tr.Hit = true
		local vel = self.vel*(CurTime()-self.lasttrace)
			local tracep = {}
		tracep.start = self:GetPos()
		tracep.filter = self.filter
		tracep.endpos = self:GetPos()+vel
		tracep.mask = MASK_SHOT-CONTENTS_SOLID
		tracep.mins = self.mins
		tracep.maxs = self.maxs
		while (tr.Hit) do
			tr = util.TraceHull(tracep)
			if tr.Hit then
				table.insert(self.filter,tr.Entity)
				self:OnHit(tr)
				if (tr.Entity:GetClass() == "npc_strider") then
					break
				end
			else
				self:SetPos(self:GetPos()+vel)
			end
		end
	end
	self.lasttrace = CurTime()
end

local DMG_HYPER = bit.bor(DMG_ENERGYBEAM,DMG_GENERIC,DMG_DIRECT,DMG_BLAST,DMG_PLASMA,DMG_FREEZE,DMG_SHOCK)

function ENT:OnHit(tr)
	local hitent = tr.Entity
	if IsValid(hitent) then
		if tr.Entity:IsNPC() then
			tr.Entity:SetSchedule(SCHED_BIG_FLINCH)
		end
		local HP = tr.Entity:Health()
		local dmg = DamageInfo()
		dmg:SetDamage(200)
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		dmg:SetDamageForce(vector_origin)
		dmg:SetDamagePosition(tr.HitPos)
		dmg:SetDamageType(DMG_HYPER)
		tr.Entity:TakeDamageInfo(dmg)
		if tr.Entity:Health() == HP then
			dmg:SetDamageType(DMG_GENERIC)
			tr.Entity:TakeDamageInfo(dmg)
		end
		if tr.Entity:Health() == HP then
			dmg:SetDamageType(DMG_DIRECT)
			tr.Entity:TakeDamageInfo(dmg)
		end
		if tr.Entity:Health() == HP then
			dmg:SetDamageType(DMG_BLAST)
			tr.Entity:TakeDamageInfo(dmg)
		end
		local a = ents.Create("env_explosion")
		a:SetPos(tr.HitPos)
		a:SetKeyValue("iMagnitude",0)
		a:Spawn()
		a:Fire("Explode",1,"0")
		a:Fire("kill",1,"1")
		

	end
end

function ENT:Use()
end

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end
