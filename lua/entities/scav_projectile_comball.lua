AddCSLuaFile()

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

if CLIENT then
	--ENT.mat = Material("effects/eball_finite_life")
	ENT.mat = Material("effects/ar2_altfire1")
	ENT.mat2 = Material("models/Effects/comball_glow1")
	killicon.AddAlias("scav_projectile_comball","prop_combine_ball")

	function ENT:Draw()
		render.SetMaterial(self.mat)
		render.DrawSprite(self:GetPos(),32,32,color_white)
	end
end

if SERVER then
	ENT.trmin = Vector(-72,-72,-72)
	ENT.trmax = Vector(72,72,72)
	ENT.lifetime = 4

	function ENT:PhysicsCollide(data,physobj)
		if IsValid(data.HitEntity) then
			local dir = physobj:GetVelocity():GetNormalized()
			physobj:SetVelocity((dir-(-2*data.HitNormal*dir:Dot(-1*data.HitNormal)))*1500)

			local tracep = {}
				tracep.start = self:GetPos()
				tracep.endpos = self:GetPos()+physobj:GetVelocity():GetNormalized()*1000
				tracep.filter = {self,self.Owner,game.GetWorld(),data.HitEntity}
				tracep.mask = MASK_SHOT
				tracep.mins = self.trmin
				tracep.maxs = self.trmax
				local tr = util.TraceHull(tracep)
			if IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:IsNextBot()) and (tr.HitPos() ~= self:GetPos()) then
				local mins = tr.Entity:OBBMaxs()
				local maxs = tr.Entity:OBBMins()
				pos = tr.Entity:GetPos()+Vector(math.Rand(mins.x,maxs.x),math.Rand(mins.y,maxs.y),math.Rand(mins.z,maxs.z))
				physobj:SetVelocity((pos-self:GetPos()):GetNormalized()*1500)
			end
			if IsValid(data.HitObject) then
				data.HitObject:ApplyForceOffset(data.OurOldVelocity*100,data.HitPos)
			end

			if data.HitEntity ~= self.Owner then
				--data.HitEntity:TakeDamage(1000,self.Owner,self)
				local dmg = DamageInfo()
				dmg:SetAttacker(self.Owner)
				dmg:SetInflictor(self)
				dmg:SetDamageForce(vector_origin)
				dmg:SetDamagePosition(data.HitPos)
				dmg:SetDamageType(DMG_DISSOLVE)
				dmg:SetDamage(1000)
				data.HitEntity:TakeDamageInfo(dmg)
				if IsValid(data.HitEntity) and (data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() or data.HitEntity:IsNextBot()) then
					data.HitEntity:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
				end
			end
			--[[
			if (data.HitEntity:Health() <= 1000) and data.HitEntity:IsPlayer() and IsValid(data.HitEntity:GetRagdollEntity()) then

			end

			if (data.HitEntity:Health() <= 1000) and data.HitEntity:IsNPC() then
				local dis = ents.Create("env_entity_dissolver")
				dis:SetPos(self:GetPos())
				dis:SetKeyValue("magnitude",0)
				dis:SetKeyValue("dissolvetype",0)
				dis:SetEntity("target",data.HitEntity)
				data.HitEntity:SetKeyValue("targetname","willdissolve")
				dis:Spawn()
				dis:Fire("Dissolve","willdissolve",0)
				dis:Fire("Kill",1,"1")
				data.HitEntity:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
			end
			]]





		end
		local ef = EffectData()
		ef:SetOrigin(data.HitPos)
		ef:SetNormal(data.HitNormal)
		util.Effect("cball_bounce",ef)
		self:EmitSound("weapons/physcannon/energy_bounce"..math.random(1,2)..".wav")

	end

	--[[
	hook.Add("PlayerDeath","scavcomballkill",
		function(pl,inflictor,attacker)
			if IsValid(inflictor) and (inflictor:GetClass() == "scav_projectile_comball") then
				local dissolver = ents.Create("env_entity_dissolver")
				dissolver:SetPos(pl:GetPos())
				dissolver:SetKeyValue("magnitude",0)
				dissolver:SetKeyValue("dissolvetype",0)
				dissolver:SetEntity("target",pl)
				pl:GetRagdollEntity():SetKeyValue("targetname","dissolved")
				dissolver:Spawn()
				dissolver:Fire("Dissolve","dissolved",0)
				dissolver:Fire("Kill",1,"1")
				pl:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
			end
		end)
		]]

	function ENT:Think()
		if (not self.grabbedtime and (self.lifetime+self.Created < CurTime())) or (self.grabbedtime and self.grabbedtime+7 < CurTime()) then
			local ef = EffectData()
			ef:SetOrigin(self:GetPos())
			util.Effect("cball_explode",ef)
			self:EmitSound("weapons/physcannon/energy_sing_explosion2.wav")
			if self.sound then
				self.sound:Stop()
			end
			self:Remove()
		end
	end

	function ENT:StartTouch()
	end

	function ENT:EndTouch()
	end

	function ENT:Touch(hitent)
	end

	function ENT:OnTakeDamage()
	end

	function ENT:OnRemove()
	end

	hook.Add("GravGunOnPickedUp","scav_comballpickup",function(pl,ent) if IsValid(ent) and ent:GetClass() == "scav_projectile_comball" then ent.Owner = pl ent.sound:Play() ent.grabbedtime = CurTime() end end)
	hook.Add("GravGunOnDropped","scav_comballdrop",function(pl,ent) if IsValid(ent) and ent:GetClass() == "scav_projectile_comball" then ent.Owner = pl ent.sound:Stop() ent.lifetime = (ent.lifetime+CurTime()-ent.grabbedtime) end end)
	--local function dissolvesound(ent,inflictor,killer)
	--	if (inflictor:GetClass() == "scav_projectile_comball") or (killer:GetClass() == "scav_projectile_comball") then
	--		ent:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
	--	end
	--end

	--hook.Add("PlayerDeath","ScavComBallKillSound",dissolvesound)
	--hook.Add("OnNPCKilled","ScavComBallKillSound",dissolvesound)
end
