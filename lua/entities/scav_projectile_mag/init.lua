AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.attachedent = NULL
ENT.constraint = NULL
ENT.lastping = 0
ENT.pingparticle = NULL

function ENT:Think()
	self.constraint = self.constraint or NULL
	if self.constraint:IsValid() and (self.lastping+3 < CurTime()) then
		self.lastping = CurTime()
		self:Ping()
	end
	if not self.constraint:IsValid() and self.pingparticle:IsValid() then
		self.pingparticle:Fire("Stop",nil,0)
	end
end

function ENT:Ping()
	self:EmitSound("Weapon_StriderBuster.Ping")
	if self.pingparticle:IsValid() then
		self.pingparticle:Fire("Start",nil,0)
	else
		self.pingparticle = ScavData.GetNewInfoParticleSystem("striderbuster_attached_pulse",self:GetPos(),self)
	end
end

function ENT:Attach(ent,bone)
	self:SetOwner()
	self.attachedent = ent
	ParticleEffectAttach("striderbuster_attach",PATTACH_ABSORIGIN_FOLLOW,self,0)
		self.constraint = constraint.Weld(self,ent,0,bone,0,true)
	self:EmitSound("Weapon_StriderBuster.StickToEntity")
	self:Ping()
end

function ENT:Detach()
	self.attachedent = NULL
	if self.constraint:IsValid() then
		self.constraint:Remove()
	end
end

function ENT:PhysicsCollide(data,physobj)
	self.constraint = self.constraint or NULL
	local ent = data.HitEntity
	local hitobj = data.HitObject
	if (data.Speed > 500) and ent:IsWorld() then
		timer.Simple(0, function() self:ExplodeDud() end)
		return
	end
	if (data.Speed > 500) and (not self.attachedent:IsValid() or not self.constraint:IsValid()) and (ent:GetSolid() == SOLID_VPHYSICS) then
		local bone
		for i=0,ent:GetPhysicsObjectCount()-1 do
			if ent:GetPhysicsObjectNum(i) == hitobj then
				bone = i
				break
			end
		end
		if bone then
			timer.Simple(0, function() self:Attach(ent,bone) end)
		end
	end
end

function ENT:Touch(hitent)
end

local breakables = {
	["npc_turret_floor"] = true,
	["npc_rollermine"] = true,
	["npc_combinegunship"] = true,
	["npc_manhack"] = true,
	["npc_strider"] = true,
	["npc_helicopter"] = true
	}

local gibmodels = {
	"models/Gibs/manhack_gib01.mdl",
	"models/Gibs/manhack_gib02.mdl",
	"models/Gibs/manhack_gib03.mdl",
	"models/Gibs/manhack_gib04.mdl"
	}

function ENT:Gib()
	for k,v in ipairs(gibmodels) do
		local gib = ents.Create("gib")
		gib:SetPos(self:GetPos())
		gib:SetModel(v)
		gib:Spawn()
		gib:PhysicsInit(SOLID_VPHYSICS)
		gib:GetPhysicsObject():SetVelocity(VectorRand()*1000)
		gib:GetPhysicsObject():SetMaterial("gmod_ice")
		gib:Fire("Kill",nil,20)
		ParticleEffectAttach("striderbuster_trail",PATTACH_ABSORIGIN_FOLLOW,gib,1)
	end
end

function ENT:Explode(activator)
	if not self.expl and self.attachedent:IsValid() then
		self.expl = true
		local constrainedents = constraint.GetAllConstrainedEntities(self.attachedent)
		for k,v in pairs(constrainedents) do
			--print("removing constraints for "..tostring(v))
			constraint.RemoveAll(v)
		end
		if (self.attachedent:GetClass() == "phys_bone_follower") and (self.attachedent:GetOwner():GetClass() == "npc_strider") then --if we hit a strider, then we've ACTUALLY hit one of its bone-followers instead, so we'll need to look up the strider that owns it to bust it
			gamemode.Call("OnNPCKilled",self.attachedent:GetOwner(),activator,self)
			self.attachedent:GetOwner():Fire("break",nil,0) --this should only cause the strider to break if we've hit the bone-follower for the head, but at the moment there is no way to access what bone the follower is assigned to through lua
			local data = EffectData()
			local radstep = (2*math.pi)/6
			local normvec = Vector()
			for i=0,5 do
				data:SetOrigin(self:GetPos()+VectorRand()*32)
				normvec.x = math.cos(radstep*i)
				normvec.y = math.sin(radstep*i)
				normvec.z = 0
				data:SetNormal(normvec)
				if (math.random(0,5) == 0) then
					data:SetScale(1)
				else
					data:SetScale(2)
				end
				util.Effect("StriderBlood",data)
			end
			util.ScreenShake(self:GetPos(),20,150,1,1250)
			data:SetOrigin(self:GetPos())
			util.Effect("cball_explode",data)
		end

		if breakables[self.attachedent:GetClass()] then
			--print("BREAKING!")
			gamemode.Call("OnNPCKilled",self.attachedent,activator,self)
			self.attachedent:Fire("break",nil,0)
			
		end
		ParticleEffect("striderbuster_explode_core",self:GetPos(),self:GetAngles(),Entity(0))
		self:Gib()
		self:EmitSound("Weapon_StriderBuster.Detonate")
		util.ScreenShake(self:GetPos(),700,1,1,800)
		self:Remove()
	elseif not self.expl then
		self:ExplodeDud()
	end
end



function ENT:ExplodeDud()
	ParticleEffect("striderbuster_explode_dummy_core",self:GetPos(),self:GetAngles(),Entity(0))
	ParticleEffect("striderbuster_break",self:GetPos(),self:GetAngles(),Entity(0))
	self:Gib()
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetInflictor():GetClass() ~= "hunter_flechette" then
		self:Explode(dmginfo:GetAttacker())
	else
		self:Detach()
	end
end
	
