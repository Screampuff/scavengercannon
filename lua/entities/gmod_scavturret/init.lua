
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
CreateConVar("sbox_maxscav_turrets",4,{FCVAR_REPLICATED,FCVAR_ARCHIVE})
include('shared.lua')

--ENT.Mode = "Rocket"
ENT.Charge = 0

--[=[---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------]=]
function ENT:Initialize()

	self.Entity:SetModel( "models/weapons/w_IRifle.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self.Firing 	= false
	self.NextShot 	= 0
	self.Inputs = Wire_CreateInputs(self.Entity, { "Fire" })
	if not self.Mode then
		self.Mode = self.Owner:GetInfo("scavturret_type")
	end
	self.soundloops = {}
end


function ENT:FireShot()
	
	if ( self.NextShot > CurTime() ) then return end
	

	
	-- Get the muzzle attachment (this is pretty much always 1)
	local Attachment = self.Entity:GetAttachment( 1 )
	local shootOrigin = Attachment.Pos
	local shootAngles = self.Entity:GetAngles()
	local shootDir = shootAngles:Forward()*-1
	
	if self.Firefuncs[self.Mode] then
		self.Firefuncs[self.Mode](self)
	end


	-- Make a muzzle flash
	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( shootAngles )
		effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )
	
end

ENT.Firefuncs = {}
	ENT.Firefuncs["rocket"] = function(self)
		-- Get the shot angles and stuff.
		local Attachment = self.Entity:GetAttachment( 1 )
		local shootAngles = self.Entity:GetAngles()
		local shootDir = shootAngles:Forward()*-1
		local shootOrigin = Attachment.Pos+shootDir*64+self:GetVelocity()*0.1
		local proj = ents.Create("scav_projectile_rocket")
		proj.Owner = self.pl
		proj:SetModel("models/weapons/w_missile_closed.mdl")
		proj:SetPos(shootOrigin)
		proj:SetAngles(shootAngles)
		proj:SetOwner(self)
		proj:Spawn()
		self:EmitSound("weapons/stinger_fire1.wav",40,100)
		proj:GetPhysicsObject():Wake()
		proj:GetPhysicsObject():EnableDrag(false)
		proj:GetPhysicsObject():EnableGravity(false)
		proj:GetPhysicsObject():SetVelocity(shootDir*2500+self:GetVelocity())
		proj:GetPhysicsObject():SetBuoyancyRatio(0)
		self.NextShot = CurTime() + 1
	end
	
	ENT.Firefuncs["seekrocket"] = function(self)
		-- Get the shot angles and stuff.
		local Attachment = self.Entity:GetAttachment( 1 )
		local shootAngles = self.Entity:GetAngles()
		local shootDir = shootAngles:Forward()*-1
		local shootOrigin = Attachment.Pos+shootDir*64+self:GetVelocity()*0.1
		local proj = ents.Create("scav_projectile_rocket")
			local tracep = {}
			tracep.mask = MASK_SHOT
			tracep.mins = Vector(-16,-16,-16)
			tracep.maxs = Vector(16,16,16)
			tracep.start = shootOrigin
			tracep.endpos = shootOrigin+shootDir*20000
			tracep.filter = self.Owner
			local tr = util.TraceHull(tracep)
			if IsValid(tr.Entity) then
				proj.target = tr.Entity
			end
		proj.Owner = self.pl
		proj:SetModel("models/weapons/w_missile_closed.mdl")
		proj:SetPos(shootOrigin)
		proj:SetAngles(shootAngles)
		proj:SetOwner(self)
		proj:Spawn()
		self:EmitSound("weapons/stinger_fire1.wav",40,100)
		proj:GetPhysicsObject():Wake()
		proj:GetPhysicsObject():EnableDrag(false)
		proj:GetPhysicsObject():EnableGravity(false)
		proj:GetPhysicsObject():SetVelocity(shootDir*2500+self:GetVelocity())
		proj:GetPhysicsObject():SetBuoyancyRatio(0)
		self.NextShot = CurTime() + 1
	end
	
	ENT.Firefuncs["grenade"] = function(self)
		-- Get the shot angles and stuff.
		local Attachment = self.Entity:GetAttachment( 1 )
		local shootAngles = self.Entity:GetAngles()
		local shootDir = shootAngles:Forward()*-1
		local shootOrigin = Attachment.Pos+shootDir*64+self:GetVelocity()*0.1
		local proj = ents.Create("scav_projectile_grenade")
		proj.Owner = self.pl
		proj:SetModel("models/props_junk/popcan01a.mdl")
		proj:SetPos(shootOrigin)
		proj:SetAngles(shootAngles)
		proj:SetOwner(self)
		proj:Spawn()
		--self:EmitSound("weapons/stinger_fire1.wav",40,100)
		proj:GetPhysicsObject():Wake()
		proj:GetPhysicsObject():SetVelocity(shootDir*2500+self:GetVelocity())
		self.NextShot = CurTime() + 1
	end
	
	ENT.Firefuncs["plasma"] = function(self)
			local Attachment = self.Entity:GetAttachment( 1 )
			local shootAngles = self.Entity:GetAngles()
			local shootDir = shootAngles:Forward()*-1
			local shootOrigin = Attachment.Pos+shootDir*64+self:GetVelocity()*0.1
			local proj = ScavData.models["models/items/car_battery01.mdl"].proj
				proj:SetOwner(self.Owner)
					proj:SetInflictor(self)
					proj:SetFilter(self)
					proj:SetPos(self:GetShootPos())
					proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*2000*math.Rand(1,6)+self:GetVelocity())
					proj:Fire()
			local ef = EffectData()
			ef:SetOrigin(shootOrigin)
			ef:SetStart(shootDir*2000+self:GetVelocity())
			ef:SetEntity(self.Owner)
			util.Effect("ef_scav_plasma",ef)
			self.Owner:EmitSound("weapons/physcannon/energy_bounce2.wav",80,150)
			self.NextShot = CurTime() + 0.1
	end
	
	ENT.Firefuncs["laser"] = function(self)
			local Attachment = self.Entity:GetAttachment( 1 )
			local shootAngles = self.Entity:GetAngles()
			local shootDir = shootAngles:Forward()*-1
			local shootOrigin = Attachment.Pos
			local tab = ScavData.models["models/roller.mdl"]
			if self:IsFirstShot() then
				local efdata = EffectData()
				efdata:SetEntity(self)
				efdata:SetOrigin(self:GetPos())
				self:AddToggleEffect(efdata,"ef_scav_laser")
			end
			local tracep = {}
			tracep.mask = MASK_SHOT
			tracep.mins = Vector(-2,-2,-2)
			tracep.maxs = Vector(2,2,2)
			tracep.start = shootOrigin
			tracep.endpos = shootOrigin+shootDir*20000
			tracep.filter = self
			local tr = util.TraceHull(tracep)
			if IsValid(tr.Entity) then
				dmg = DamageInfo()
				dmg:SetDamage(5)
				dmg:SetDamageForce(vector_origin)
				dmg:SetDamagePosition(tr.HitPos)
				dmg:SetAttacker(self.Owner)
				dmg:SetInflictor(self)
				dmg:SetDamageType(DMG_ENERGYBEAM)
				tr.Entity:TakeDamageInfo(dmg)
			end
			self.NextShot = CurTime() + 0.05
	end

	local frag12cb = function(attacker,tr,dmginfo)
									if tr.HitSky then
										return true
									end
									dmginfo:SetInflictor(attacker)
									dmginfo:SetAttacker(attacker.Owner)
									local ef = EffectData()
										ef:SetOrigin(tr.HitPos)
										util.Effect("ef_scav_expsmall",ef)
									if SERVER then
										util.Decal("fadingscorch",tr.HitPos+tr.HitNormal*8,tr.HitPos-tr.HitNormal*8)
										util.BlastDamage(attacker,attacker.Owner,tr.HitPos,128,50)
									end
								end
	
	ENT.Firefuncs["frag12"] = function(self)
			local Attachment = self.Entity:GetAttachment( 1 )
			local shootAngles = self.Entity:GetAngles()
			local shootDir = shootAngles:Forward()*-1
			local shootOrigin = Attachment.Pos
			local bullet = {}
			bullet.Num = 1
			bullet.Spread = Vector(0.03,0.03,0)
			bullet.Tracer = 1
			bullet.Force = 0
			bullet.Damage = 5
			bullet.TracerName = "Tracer"
			bullet.Callback = frag12cb
			bullet.Src = shootOrigin
			bullet.Dir = shootDir
			self:FireBullets(bullet)
			self.NextShot = CurTime() + 0.2
	end
	
	ENT.Firefuncs["flamethrower"] = function(self)
			local tab = ScavData.models["models/props_junk/propanecanister001a.mdl"]
			if self:IsFirstShot() then
				local efdata = EffectData()
				efdata:SetEntity(self)
				efdata:SetOrigin(self:GetPos())
				self:AddToggleEffect(efdata,"ef_scav_fthrow")
			end
			local tracep = {}
				tracep.start = self:GetProjectileShootPos()
				tracep.endpos = self:GetProjectileShootPos()+self:GetAimVector()*300
				tracep.filter = self
				tracep.mask = MASK_SHOT
				tracep.mins = tab.vmin
				tracep.maxs = tab.vmax
				local tr = util.TraceHull(tracep)
			local extpos = self:GetShootPos()+self:GetAimVector()*75
			for k,v in ipairs(ents.FindByClass("env_fire")) do
				if v:GetPos():Distance(extpos) < 75 then
					v:Fire("StartFire",1,0)
				end
			end
			local ent = tr.Entity
			if IsValid(ent) and (not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage",ent,self.Owner)) and (self:WaterLevel() < 2) then
					local proj = ScavData.models["models/props_junk/propanecanister001a.mdl"].proj
					proj:SetOwner(self.Owner)
						proj:SetInflictor(self)
						proj:SetFilter(self)
						proj:SetPos(self:GetShootPos())
						proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*300*math.Rand(1,6)+self:GetVelocity())
						proj:Fire()
			end
			self.NextShot = CurTime() + 0.1
		end
		
		local freezecb = function(self,tr)
			local ent = tr.Entity
			if IsValid(ent) and (not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage",ent,self.Owner)) then
				local dmg = DamageInfo()
				dmg:SetAttacker(self.Owner)
				if IsValid(self.inflictor) then
					dmg:SetInflictor(self.inflictor)
				else
					dmg:SetInflictor(self.Owner)
				end
				dmg:SetDamage(1)
				dmg:SetDamageForce(vector_origin)
				dmg:SetDamagePosition(tr.HitPos)
				dmg:SetDamageType(DMG_FREEZE)
				tr.Entity:TakeDamageInfo(dmg)
				if not ent:GetStatusEffect("Frozen") or (ent:GetStatusEffect("Frozen").EndTime-30 < CurTime()) then
				ent:InflictStatusEffect("Slow",0.1,-10,self.Owner)
					if ent:IsPlayer() and (ent:GetWalkSpeed() == 0) then
						ent:InflictStatusEffect("Frozen",0.1,0,self.Owner)
					elseif not ent:IsPlayer() and ((ent:IsNPC() and ((ent:Health() < 10) or (ent:GetStatusEffect("Slow").EndTime > CurTime()+10))) or not ent:IsNPC()) then
						ent:InflictStatusEffect("Frozen",0.2,0,self.Owner)
					end
				end
			end
			if tr.MatType == MAT_SLOSH then
				local ice = NULL
				local model = "models/props_wasteland/rockgranite01a.mdl"
				for k,v in ipairs(ents.FindInSphere(tr.HitPos,100)) do
					if model == string.lower(v:GetModel()) then
						ice = v
						break
					end
				end
				if not IsValid(ice) then
					local ice = ents.Create("prop_physics")
					ice:SetModel(model)
					ice:SetPos(tr.HitPos-Vector(0,0,30))
					ice:SetAngles(Angle(0,tr.Normal:Angle().y+180,0))
					ice:SetMaterial("models/shiny")
					ice:SetColor(Color(175,227,255,180))
					ice:SetRenderMode(RENDERMODE_TRANSALPHA)
					ice:Spawn()
					ice.StatusImmunities = {["Frozen"] = true}
					ice.noscav = true
					ice:GetPhysicsObject():SetMaterial("gmod_ice")
					ice:SetMoveType(MOVETYPE_NONE)
				end
			end
			if tr.HitWorld then
				return false
			end
			return true
		end
	ENT.Firefuncs["freeze"] = function(self)
			local tab = ScavData.models["models/props_c17/furniturefridge001a.mdl"]
			if self:IsFirstShot() then
				local efdata = EffectData()
				efdata:SetEntity(self)
				efdata:SetOrigin(self:GetPos())
				self:AddToggleEffect(efdata,"ef_scav_freeze")
			end
			local extpos = self:GetShootPos()+self:GetAimVector()*75
					local proj = ScavData.models["models/props_c17/furniturefridge001a.mdl"].proj
					proj:SetOwner(self.Owner)
						proj:SetInflictor(self)
						proj:SetFilter(self)
						proj:SetPos(self:GetShootPos())
						proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*100*math.Rand(1,6)+self:GetVelocity())
						proj:Fire()
			self.NextShot = CurTime() + 0.1
		end			
	
	ENT.Firefuncs["tankshell"] = function(self)
		local tr = self:GetEyeTraceNoCursor()
		local ef = EffectData()
			ef:SetStart(self:GetPos())
			ef:SetOrigin(tr.HitPos)
			ef:SetEntity(self)
			ef:SetScale(4)
			util.Effect("ef_scav_tr2",ef,nil,true)
		self:EmitSound("ambient/explosions/explode_1.wav")
		if tr.HitSky then
			return true
		end
		local ef = EffectData()
			ef:SetOrigin(tr.HitPos)
			ef:SetNormal(tr.HitNormal)
			util.Effect("ef_scav_exp3",ef,nil,true)	
		util.Decal("Scorch",tr.HitPos+tr.HitNormal*8,tr.HitPos-tr.HitNormal*8)
		util.ScreenShake(self:GetPos(),500,10,4,4000)
		util.BlastDamage(self,self.Owner,tr.HitPos,512,250)
		self:GetPhysicsObject():SetVelocity(self:GetVelocity()+self:GetAngles():Forward()*5000)
		self.NextShot = CurTime() + 10
	end
	
	function ENT:BFGShoot()
		if IsValid(self) then
			local proj = ents.Create("scav_projectile_bigshot")
			proj.Owner = self.Owner
			proj:SetPos(self:GetProjectileShootPos())
			proj:SetAngles(self:GetAimVector():Angle())
			proj.vel = self:GetAimVector()*500
			proj:SetOwner(self)
			proj.filter = {self}
			proj.Charge = math.floor(math.min(self.Charge,4))
			proj:Spawn()
			self.soundloops.bfgcharge:Stop()
			self.soundloops.bfgcharge2:Stop()
			net.Start("scv_falloffsound")
				local rf = RecipientFilter()
				rf:AddAllPlayers()
				net.WriteVector(self:GetPos())
				net.WriteString("weapons/physgun_off.wav")
			net.Send(rf)
			self:KillEffect()
			self.Charge = 0
		end
	end
	
	ENT.Firefuncs["BFG"] = function(self)
		if not self.soundloops.bfgcharge then
			self.soundloops.bfgcharge = CreateSound(self.Owner,"ambient/machines/combine_shield_loop3.wav")
			self.soundloops.bfgcharge2 = CreateSound(self.Owner,"npc/attack_helicopter/aheli_crash_alert2.wav")
		end
		if self:IsFirstShot() then
			self:EmitSound("HL1/ambience/particle_suck1.wav")
			local efdata = EffectData()
			efdata:SetEntity(self)
			efdata:SetOrigin(self:GetPos())
			self:AddToggleEffect(efdata,"ef_bigshot_charge")
		end
		self.Charge = self.Charge+0.2
		self.soundloops.bfgcharge:PlayEx(100,60+math.min(self.Charge,4)*40)
		self.soundloops.bfgcharge2:PlayEx(100,60+math.min(self.Charge,4)*40)
		if self.Charge >= 6 then
			util.ScreenShake(self:GetPos(),500,10,4,4000)
			util.BlastDamage(self,self.Owner,self:GetPos(),360,400) --540,300
			ParticleEffect("scav_exp_bigshot",self:GetPos(),Angle(0,0,0),Entity(0))
			self:EmitSound("ambient/explosions/explode_3.wav")
			self:EmitSound("physics/body/body_medium_break3.wav")
			self.Charge = 0
			self.soundloops.bfgcharge:Stop()
			self.soundloops.bfgcharge2:Stop()
			self:Remove()
		end
		self.NextShot = CurTime() + 0.1
	end

ENT.Releasefuncs = {}
	ENT.Releasefuncs["BFG"] = function(self)
		--ParticleEffectAttach("scav_bigshot_charge",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("muzzle"))
		self:EmitSound("HL1/ambience/particle_suck1.wav")
		self:BFGShoot()
		self.NextShot = CurTime() + 7
	end
	
ENT.IsFiring = false
	
function ENT:IsFirstShot()
	local val = self.IsFiring
	self.IsFiring = self.Firing
	return not val
end
	
function ENT:KillEffect()
	if self.toggleeffect then
		timer.Simple(0.1, function() self:TimerKillEffect(self.toggleeffect) end)
		--print("killing effect "..self.toggleeffect)
		--effects_onoff[self.toggleeffect] = false
		self.toggleeffect = nil
	end
end

function ENT:TimerKillEffect(effectno)
end

function ENT:AddToggleEffect(efdata,name)
	local efindex = self.toggleeffect
	self:KillEffect()
	--[[
	local tablelength = table.maxn(effects_onoff)
	local pos = tablelength+1
	for i=1,tablelength do
		if (effects_onoff[i] == nil) then
			pos = i
			break
		elseif (effects_onoff[i] == false) then
			effects_onoff[i] = nil
		end
	end
	self.toggleeffect = pos
	effects_onoff[pos] = self.Owner
	]]--
	efdata:SetScale(pos)
	util.Effect(name,efdata,nil,true)
end

--[=[---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------]=]
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end

function ENT:Think()
	if self.BaseClass then self.BaseClass.Think(self) end
	if( self.Firing ) then
		self:FireShot()
	elseif ( self.NextShot < CurTime() ) then
		if self.IsFiring and self.Releasefuncs[self.Mode] then
			self.Releasefuncs[self.Mode](self)
		end
		self.IsFiring = false
		self:KillEffect()
	end
	
	self.Entity:NextThink(CurTime())
	return true
end

--[=[---------------------------------------------------------
   Name: TriggerInput
   Desc: the inputs
---------------------------------------------------------]=]
function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		self.Firing = value > 0
	end
end


function MakeScavTurret( ply, Pos, Ang, mode, frozen, nocollide )
	
	if not ply:CheckLimit( "scav_turrets" ) then return nil end
	
	local turret = ents.Create( "gmod_scavturret")
	if not IsValid(turret) then return false end
	
	turret:SetPos( Pos )
	turret.Owner = ply
	if Ang then turret:SetAngles( Ang ) end
	turret.Mode = mode
	turret:Spawn()
	
	-- Clamp stuff in multiplayer.. because people are idiots

	turret:SetPlayer( ply )
	
	if nocollide then turret:GetPhysicsObject():EnableCollisions( false ) end

	local ttable = {
		pl			= ply,
		nocollide 	= nocollide,
	}
	table.Merge( turret:GetTable(), ttable )
	
	ply:AddCount( "scav_turrets", turret )
	ply:AddCleanup( "scav_turrets", turret )
	
	return turret
end

duplicator.RegisterEntityClass( "gmod_scavturret", MakeScavTurret, "Pos", "Ang", "Mode", "frozen", "nocollide" )


