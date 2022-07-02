local ENT = {}
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.NoScav = true

PrecacheParticleSystem("alch_break")

function ENT:Initialize()
	--self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetColor(Color(255,255,255,254))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	if SERVER then
		self.LocalAng = Angle(0,0,0)
		self:StartMotionController()
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:GetPhysicsObject():Wake()
		self.ShadowParams = {}
	else
		self:CreateParticleEffect("alch_ghost",self:GetOwner():LookupAttachment("muzzle"))
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"LastDamaged")
end

if SERVER then
	function ENT:PhysicsSimulate(phys,deltatime)
		local owner = self:GetOwner()
		self.ShadowParams.secondstoarrive = 0.01 -- How long it takes to move to pos and rotate accordingly - only if it _could_ move as fast as it want - damping and max speed/angular will make this invalid (Cannot be 0! Will give errors if you do)
		local radius = self:OBBMins():Distance(self:OBBCenter())
		self.ShadowParams.pos = owner:GetShootPos()+owner:GetAimVector()*(32+radius)-self:GetPhysicsObject():GetMassCenter() -- Where you want to move to
		local _,ang = LocalToWorld(vector_origin,self.LocalAng,vector_origin,owner:GetAimVector():Angle())
		--local ang = owner:GetAimVector():Angle()
		--local up = ang:Up()
		--local right = ang:Right()
		--local forward = ang:Forward()
		--ang:RotateAroundAxis(up,self.LocalAng.y)
		--ang:RotateAroundAxis(right,self.LocalAng.p)
		--ang = ang+self.LocalAng
		--ang:RotateAroundAxis(forward,self.LocalAng.r)
		
		self.ShadowParams.angle = ang -- Angle you want to move to
		 
		self.ShadowParams.maxangular = 5000 --What should be the maximal angular force applied
		self.ShadowParams.maxangulardamp = 10000 -- At which force/speed should it start damping the rotation
		self.ShadowParams.maxspeed = 1000000 -- Maximal linear force applied
		self.ShadowParams.maxspeeddamp = 10000-- Maximal linear force/speed before  damping
		self.ShadowParams.dampfactor = 0.8 -- The percentage it should damp the linear/angular force if it reaches it's max amount
		self.ShadowParams.teleportdistance = 200 -- If it's further away than this it'll teleport (Set to 0 to not teleport)
		self.ShadowParams.deltatime = deltatime -- The deltatime it should use - just use the PhysicsSimulate one
		phys:ComputeShadowControl(self.ShadowParams)
	end
	
	function ENT:OnTakeDamage(dmginfo)
		local ctime = CurTime()
		self:SetLastDamaged(ctime)
		local owner = self:GetOwner()
		self:EmitSound("npc/scanner/scanner_pain"..math.random(1,2)..".wav")
		owner:SetEnergy(owner:GetEnergy()-1*dmginfo:GetDamage(),1,true)
		if owner:GetEnergy() < dmginfo:GetDamage() then
			owner:GetActiveWeapon():Lock(ctime,ctime+4)
			self:Break()
		end
	end
	
	local function ghostrepulsion(ghost,gun,owner,hitent,hitpos,force)
		if not IsValid(hitent) then
			return
		end
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(20)
		dmginfo:SetDamageType(DMG_SHOCK)
		dmginfo:SetDamagePosition(hitpos)
		if IsValid(ghost) then
			dmginfo:SetInflictor(ghost)
		elseif IsValid(gun) then
			dmginfo:SetInflictor(gun)
		else
			dmginfo:SetInflictor(game.GetWorld())
		end
		if IsValid(owner) then
			dmginfo:SetAttacker(owner)
		else
			dmginfo:SetAttacker(game.GetWorld())
		end
		dmginfo:SetDamageForce(force)
		if hitent:GetPhysicsObject():IsValid() then
			hitent:GetPhysicsObject():SetVelocity(hitent:GetPhysicsObject():GetVelocity()*-1+force/hitent:GetPhysicsObject():GetMass())
			--hitent:GetPhysicsObject():ApplyForceCenter(force)
		end
		hitent:TakeDamageInfo(dmginfo)
		dmginfo:SetDamage(10)
		ghost:TakeDamageInfo(dmginfo)
		local edata = EffectData()
		edata:SetNormal(force:GetNormalized())
		edata:SetOrigin(hitpos)
		util.Effect("manhacksparks",edata)
	end
	
	ENT.LastCollide = 0
	function ENT:PhysicsCollide(data,physobj)
	end
	
	function ENT:Break()
		if not self.Killed then
			self.Killed = true
			timer.Simple(0, function() ParticleEffectAttach("alch_break",PATTACH_ABSORIGIN_FOLLOW,self,0) end)
			self:EmitSound("physics/glass/glass_sheet_break3.wav")
			self:Fire("Kill",nil,0.2)
		end
	end
	
end

ENT.Alpha = 1
function ENT:Think()
	local parent = self:GetParent()
	if SERVER then
		self:GetPhysicsObject():Wake()
	end
	if IsValid(parent) or (self.Alpha ~= 1) then
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self.Alpha = self.Alpha-FrameTime()
	end
	if SERVER and ((self.Alpha < 0) or not IsValid(self.Weapon)) then
		self:Remove()
	end
end

if CLIENT then

	function ENT:IsTranslucent()
		return true
	end
	
	function ENT:DrawTranslucent()
		self:Draw()
	end

	local shinymat = Material("models/shiny")
	function ENT:Draw()
		local damageglow = math.Clamp(1-(CurTime()-self:GetLastDamaged()),0,1)
		render.MaterialOverride(shinymat)
		render.SetBlend(0.6*self.Alpha+damageglow*0.2)
		local extracolor = damageglow*0.5
		render.SetColorModulation(0.67+extracolor,extracolor,0.94+extracolor)
		render.SuppressEngineLighting(true)
			self:DrawModel()
		render.SuppressEngineLighting(false)
		render.SetColorModulation(1,1,1)
		render.SetBlend(1)
		render.MaterialOverride()
	end
end

scripted_ents.Register(ENT,"scav_alchghost",true)
