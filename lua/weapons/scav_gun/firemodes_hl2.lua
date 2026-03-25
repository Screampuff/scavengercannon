--Firemodes largely related to the Half-Life series. Can have other games' props defined!

--[[==============================================================================================
	--Turret Gun
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.turret"
			tab.Level = 4
			tab.MaxAmmo = 200
			local identify = {
				--[Combine Turret] = 0,
				--[[Level 1 Sentry]]["models/buildables/sentry1.mdl"] = 1,
				--[[Level 2 Sentry]]["models/buildables/sentry2.mdl"] = 2,
				--[[Portal Turret]]["models/props/turret_01.mdl"] = 3,
				["models/props_bts/bts_turret.mdl"] = 3,
				["models/npcs/turret/turret.mdl"] = 3,
				["models/npcs/turret/turret_boxed.mdl"] = 3,
				["models/npcs/turret/turret_fx_fizzler.mdl"] = 3,
				--[[HLS Turret]]["models/sentry.mdl"] = 4,
				--[[ASW Turret]]["models/swarm/sentrygun/remoteturret.mdl"] = 5,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.anim = ACT_VM_RECOIL1
			tab.tracep = {}
			tab.tracep.mask = MASK_SHOT
			tab.tracep.mins = Vector(-32, -32, -32)
			tab.tracep.maxs = Vector(32, 32, 32)
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local tab = ScavData.models[item.ammo]
					tab.tracep.start = self.Owner:GetShootPos() + self:GetAimVector() * 48
					tab.tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 20000
					tab.tracep.filter = self.Owner
					local tr = util.TraceHull(tab.tracep)
					local dir
					if IsValid(tr.Entity) then
						dir = (tr.Entity:GetPos() + tr.Entity:OBBCenter()-self.Owner:GetShootPos()):GetNormalized()
					else
						dir = self:GetAimVector()
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					local bullet = {}
						bullet.Num = 1
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = dir
						bullet.Spread = Vector(0.02, 0.02, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 4
					local shootfx = {
						[0] = function(self)
							if SERVER then self.Owner:EmitSound("npc/turret_floor/shoot" .. math.random(1, 3) .. ".wav") end
							self:MuzzleFlash2(2)
							bullet.TracerName = "AR2Tracer"
						end,
						[1] = function(self)
							self.Owner:EmitSound("weapons/sentry_shoot.wav")
							self:MuzzleFlash2()
						end,
						[2] = function(self)
							self.Owner:EmitSound("weapons/sentry_shoot2.wav")
							self:MuzzleFlash2()
						end,
						[3] = function(self)
							if SERVER then self.Owner:EmitSound("npc/turret_floor/shoot" .. math.random(1, 3) .. ".wav") end
							bullet.TracerName = "AR2Tracer"
							self:MuzzleFlash2(2)
						end,
						[4] = function(self)
							if SERVER then self.Owner:EmitSound("turret/tu_fire1.wav", 75, 160, 1) end
							bullet.TracerName = "Tracer"
							self:MuzzleFlash2()
						end,
						[5] = function(self)
							if SERVER then self.Owner:EmitSound("weapons/3d/turret/mgsingle.wav", 75, 160, 1) end
							bullet.TracerName = "Tracer"
							self:MuzzleFlash2()
						end,
					}
					shootfx[tab.Identify[item.ammo]](self)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if CLIENT then
						self.Owner:ScavViewPunch(Angle(math.Rand(0, 1), math.Rand(-1, 1), 0), 0.5)
					else
						self:TakeSubammo(item, 1)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring and SERVER then
					self:SetChargeAttack()
				end
				return tab.Identify[item.ammo] == 1 and 0.25 or tab.Identify[item.ammo] == 5 and 0.083333 or 0.1
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)						
				return false
			end
			if SERVER then
			tab.OnArmed = function(self, item, olditemname)
				if item.ammo ~= olditemname then
					local tab = ScavData.models[item.ammo]
					local beepfx = {
						[0] = function(self)
							self.Owner:EmitSound("npc/turret_floor/active.wav")
						end,
						[1] = function(self)
							self.Owner:EmitSound("weapons/sentry_spot_client.wav")
						end,
						[2] = function(self)
							self.Owner:EmitSound("weapons/sentry_spot_client.wav")
						end,
						[3] = function(self)
							self.Owner:EmitSound("npc/turret_floor/turret_deploy_" .. math.random(1, 6) .. ".wav")
						end,
						[4] = function(self)
							self.Owner:EmitSound("turret/tu_ping.wav")
						end,
						[5] = function(self)
							self.Owner:EmitSound("weapons/3d/turret/lowammo.wav")
						end,
					}
					beepfx[tab.Identify[item.ammo]](self)
				end
			end
				--TF2
				ScavData.CollectFuncs["models/buildables/sentry1_heavy.mdl"] = function(self, ent) return {{"models/buildables/sentry1.mdl", 100, ent:GetSkin()}} end
				--[[sort of a weird one on the _heavy models, these are the build/upgrade animations,
				so technically it could be 1 or 2 / 2 or 3 depending on where it's at in its animation.
				Going off of the start since that's how most people will see them when they're simply spawned.]]
				ScavData.CollectFuncs["models/buildables/sentry2_heavy.mdl"] = function(self, ent) return {{"models/buildables/sentry1.mdl", 100, ent:GetSkin()}} end
				ScavData.CollectFuncs["models/buildables/sentry3_heavy.mdl"] = function(self, ent) return {{"models/buildables/sentry2.mdl", 100, ent:GetSkin()}} end
				--Portal
				ScavData.CollectFuncs["models/props_bts/bts_turret.mdl"] = function(self, ent) return {{ScavData.FormatModelname(ent:GetModel()), math.random(25, 75), ent:GetSkin()}} end
				--ASW
				ScavData.CollectFuncs["models/swarm/sentrygun/sentryguncase.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/swarm/sentrygun/remoteturret.mdl"), 100, ent:GetSkin()}} end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/combine_turrets/floor_turret.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/props_lab/labturret.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/combine_turrets/ground_turret.mdl", 100)
		--TF2
		ScavData.RegisterFiremode(tab, "models/buildables/sentry1.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/buildables/sentry2.mdl", 100)
		--Portal
		ScavData.RegisterFiremode(tab, "models/props/turret_01.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/props_bts/bts_turret.mdl")
		--Portal 2
		ScavData.RegisterFiremode(tab, "models/npcs/turret/turret.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/npcs/turret/turret_boxed.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/npcs/turret/turret_fx_fizzler.mdl", 100)
		--HLS
		ScavData.RegisterFiremode(tab, "models/sentry.mdl", 100)
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarm/sentrygun/remoteturret.mdl", 100)
		
		
--[[==============================================================================================
	--Strider Buster
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.magnusson"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 7
			local identify = {
				--[Default] = 0,
				--[[Pumpkin]]["models/props_outland/pumpkin01.mdl"] = 1,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 3
			if SERVER then
				tab.FireFunc = function(self, item)
					self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
					local proj = self:CreateEnt("scav_projectile_mag")
					proj:SetModel(item.ammo)
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetPhysicsAttacker(self.Owner)
					proj.Inflictor = proj
					proj.Attacker = self.Owner
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles((self:GetAimVector():Angle():Up() * -1):Angle())
					proj:Spawn()
					proj:SetSkin(item.data)
					proj:GetPhysicsObject():Wake()
					proj:GetPhysicsObject():EnableGravity(true)
					proj:GetPhysicsObject():SetVelocity(self:GetAimVector() * 2500 * self:GetForceScale()) --self:GetAimVector():Angle():Up() * 0.1 
					proj:GetPhysicsObject():AddAngleVelocity(Vector(0, 10000, 0)) 
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound(self.shootsound)
					return self:TakeSubammo(item, 1)
				end
				ScavData.CollectFuncs["models/magnusson_teleporter.mdl"] = function(self, ent) return {{"models/magnusson_device.mdl", SCAV_SHORT_MAX, ent:GetSkin()}} end
				ScavData.CollectFuncs["models/magnusson_teleporter_off.mdl"] = ScavData.CollectFuncs["models/magnusson_teleporter.mdl"]
				ScavData.CollectFuncs["models/weapons/w_magnade.mdl"] = function(self, ent) return {{"models/magnusson_device.mdl", 1, ent:GetSkin()}} end
			end
			tab.Cooldown = 1.5
		ScavData.RegisterFiremode(tab, "models/magnusson_device.mdl")
		ScavData.RegisterFiremode(tab, "models/props_outland/pumpkin01.mdl")
		
		
--[[==============================================================================================
	--Bounding Mine
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.hopper"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[Default] = 0,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 4
			if SERVER then
				tab.FireFunc = function(self, item)
					self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
					local proj = self:CreateEnt("scav_bounding_mine")
					proj:SetModel(item.ammo)
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetPos(self.Owner:GetShootPos())
					proj:SetAngles((self:GetAimVector():Angle():Up() * -1):Angle())
					proj:Spawn()
					proj:SetSkin(item.data)				
					proj:GetPhysicsObject():Wake()
					proj:GetPhysicsObject():SetMass(1)
					proj:GetPhysicsObject():EnableDrag(true)
					proj:GetPhysicsObject():EnableGravity(true)
					proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector() + Vector(0, 0, 0.1)) * 5000, Vector(0, 0, 3)) --self:GetAimVector():Angle():Up() * 0.1
					timer.Simple(0, function()
						if not IsValid(proj) then return end
						proj:GetPhysicsObject():AddAngleVelocity(Vector(0, 10000, 0))
					end)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound(self.shootsound)
					--gamemode.Call("ScavFired", self.Owner, proj)
					return self:TakeSubammo(item, 1)
				end
				ScavData.CollectFuncs["models/shield_scanner.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/props_combine/combine_mine01.mdl"), 2, 0}} end
			end
			tab.Cooldown = 0.75
		ScavData.RegisterFiremode(tab, "models/props_combine/combine_mine01.mdl")
		
--[[==============================================================================================
	--SMG1 Grenade
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.smg1nade"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 6
			local identify = {
				--[HL2] = SCAV_SMGNADE_DEFAULT,
				--[[DoD:S Garand]]["models/weapons/p_garand_rg_grenade.mdl"] = SCAV_SMGNADE_GARAND,
				["models/weapons/w_garand_rg_grenade.mdl"] = SCAV_SMGNADE_GARAND,
				--[[DoD:S Kar98]]["models/weapons/p_k98_rg_grenade.mdl"] = SCAV_SMGNADE_KAR98,
				["models/weapons/w_k98_rg_grenade.mdl"] = SCAV_SMGNADE_KAR98,
				--[[L4D2]]["models/w_models/weapons/w_grenade_launcher.mdl"] = SCAV_SMGNADE_L4D2,
				--[[HL1]]["models/grenade.mdl"] = SCAV_SMGNADE_HL1,
				--[[BMS]]["models/weapons/w_argrenade.mdl"] = SCAV_SMGNADE_BMS,
				["models/weapons/w_argrenade_mp.mdl"] = SCAV_SMGNADE_BMS,
				["models/weapons/w_mp5grenade.mdl"] = SCAV_SMGNADE_BMS,
				["models/weapons/w_mp5grenade_mp.mdl"] = SCAV_SMGNADE_BMS,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_SMGNADE_DEFAULT end})
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self, item)
					local tab = ScavData.models[item.ammo]
					self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
					local proj = self:CreateEnt("grenade_ar2")
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles((self:GetAimVector():Angle()))
					proj:Spawn()		
					proj:SetVelocity(self:GetAimVector() * 1000)
					local modelfx = {
						[SCAV_SMGNADE_DEFAULT] = function(self, proj)
							self.Owner:EmitSound("weapons/ar2/ar2_altfire.wav")
						end,
						[SCAV_SMGNADE_GARAND] = function(self, proj)
							proj:SetModel("models/weapons/w_garand_rg_grenade.mdl")
							self.Owner:EmitSound("Weapon_Grenade.Shoot")
						end,
						[SCAV_SMGNADE_KAR98] = function(self, proj)
							proj:SetModel("models/weapons/w_k98_rg_grenade.mdl")
							self.Owner:EmitSound("Weapon_Grenade.Shoot")
						end,
						[SCAV_SMGNADE_L4D2] = function(self, proj)
							proj:SetModel("models/w_models/weapons/w_he_grenade.mdl")
							self.Owner:EmitSound("weapons/grenade_launcher/grenadefire/grenade_launcher_fire_1.wav")
						end,
						[SCAV_SMGNADE_HL1] = function(self, proj)
							proj:SetModel("models/grenade.mdl")
							self.Owner:EmitSound(math.random(2) == 1 and "weapons/glauncher.wav" or "weapons/glauncher2.wav")
						end,
						[SCAV_SMGNADE_BMS] = function(self, proj)
							proj:SetModel("models/weapons/w_mp5grenade.mdl")
							self.Owner:EmitSound("weapons/ar2/ar2_altfire.wav")
						end,
					}
					modelfx[tab.Identify[item.ammo]](self, proj)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					--gamemode.Call("ScavFired", self.Owner, proj)
					return self:TakeSubammo(item, 1)
				end
				--DoD:S
				ScavData.CollectFuncs["models/weapons/w_garand_gren.mdl"] = function(self, ent) return {
					{ScavData.FormatModelname("models/weapons/w_garand_rg_grenade.mdl"), 1, 0},
					{ScavData.FormatModelname("models/weapons/w_garand.mdl"), 8, 0}
				} end
				ScavData.CollectFuncs["models/weapons/w_k98_rg.mdl"] = function(self, ent) return {
					{ScavData.FormatModelname("models/weapons/w_k98_rg_grenade.mdl"), 1, 0},
					{ScavData.FormatModelname("models/weapons/w_k98.mdl"), 5, 0}
				} end
				--HL:S
				ScavData.CollectFuncs["models/w_argrenade.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/grenade.mdl"), 2, 0}} end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/items/ar2_grenade.mdl")
		ScavData.RegisterFiremode(tab, "models/items/ammocrate_smg2.mdl", SCAV_SHORT_MAX)
		--ScavData.RegisterFiremode(tab, "models/weapons/ar2_grenade.mdl") --no phys
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_grenade_launcher.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/weapons/p_garand_rg_grenade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/p_k98_rg_grenade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_garand_rg_grenade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_k98_rg_grenade.mdl")
		--HL1
		ScavData.RegisterFiremode(tab, "models/grenade.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_argrenade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_argrenade_mp.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_mp5grenade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_mp5grenade_mp.mdl")

--[[==============================================================================================
	--Strider Cannon
==============================================================================================]]--
		
	
		local tab = {}
			tab.Name = "#scav.scavcan.stridercannon"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			local identify = {} --all strider cannons are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				local tracep = {}
				tracep.mins = Vector(-4, -4, -4)
				tracep.maxs = Vector(4, 4, 4)
				
				function ScavData.PostDissolveDamage(ent, attacker, inflictor, impactpos)
					if not IsValid(ent) then
						return
					end
					local dmg = DamageInfo()
					dmg:SetDamage(1000)
					dmg:SetAttacker(attacker)
					dmg:SetInflictor(inflictor)
					dmg:SetDamageForce((impactpos - ent:GetPos()):GetNormalized() * 5000)
					dmg:SetDamagePosition(impactpos)
					dmg:SetDamageType(DMG_DISSOLVE)
					--ent:DispatchTraceAttack(dmg, impactpos, ent:GetPos())
					ent:TakeDamageInfo(dmg)
					--[[
					if ent:IsPlayer() and IsValid(ent:GetRagdollEntity()) then
						local dis = self:CreateEnt("env_entity_dissolver")
						dis:SetPos(impactpos)
						dis:SetKeyValue("magnitude", 0)
						dis:SetKeyValue("dissolvetype", 0)
						dis:SetEntity("target", ent)
						ent:GetRagdollEntity():SetKeyValue("targetname", "willdissolve")
						dis:Fire("Dissolve", "willdissolve", 0)
						dis:Fire("Kill", 1, 1)
					end
					]]
				end
				tab.ChargeAttack = function(self, item)
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = self.Owner:GetShootPos() + (self:GetAimVector() * 10000)
					tracep.filter = self.Owner
					local tr = util.TraceHull(tracep)
					local tabents
					if tr.Hit and IsValid(tr.Entity) then
						local ent = tr.Entity
						if ent:GetPhysicsObject():IsValid() then
							local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone)
							phys:ApplyForceOffset(tr.Normal * 90000, tr.HitPos)
						end
						local HP = ent:Health()
						local dmg = DamageInfo()
						dmg:SetDamage(350)
						dmg:SetAttacker(self.Owner)
						dmg:SetInflictor(self)
						dmg:SetDamageForce((tr.HitPos-ent:GetPos()):GetNormalized() * 5000)
						dmg:SetDamagePosition(tr.HitPos)
						dmg:SetDamageType(bit.bor(DMG_BLAST, DMG_DISSOLVE))
						ent:TakeDamageInfo(dmg)
						if ent:Health() == HP then
							dmg:SetDamageType(DMG_GENERIC)
							ent:TakeDamageInfo(dmg)
						end
						if ent:Health() == HP then
							dmg:SetDamageType(DMG_DIRECT)
							ent:TakeDamageInfo(dmg)
						end
						if ent:Health() == HP then
							dmg:SetDamageType(DMG_BLAST)
							ent:TakeDamageInfo(dmg)
						end
						if ent:Health() == HP then
							dmg:SetDamageType(DMG_DISSOLVE)
							ent:TakeDamageInfo(dmg)
						end
					end
					tabents = ents.FindInSphere(tr.HitPos, 100)
					local expl = self:CreateEnt("scav_concussiveblast")
					expl:SetOwner(self.Owner)
					expl:SetPos(tr.HitPos)
					expl:Spawn()
					expl:Activate()
					self.Owner:EmitSound("npc/strider/fire.wav")
					util.ScreenShake(tr.HitPos, 20, 10, 5, 4000)
					self:SetChargeAttack()
					self:SetPanelPose(0, 2)
					self:SetBlockPose(0, 2)
					self:SetBarrelRestSpeed(0)
					return 1
				end
				tab.FireFunc = function(self, item)
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
					self.Owner:EmitSound("npc/strider/charging.wav")
					local ef = EffectData()
					ef:SetEntity(self)
					ef:SetOrigin(self.Owner:GetShootPos())
					util.Effect("ef_scav_laser2", ef, true, true)
					self:SetPanelPose(1, 1.5)
					self:SetBlockPose(1, 1.5)
					self:SetBarrelRestSpeed(720)
					return true
				end

				ScavData.CollectFuncs["models/combine_strider.mdl"] = function(self, ent)
					return {{"models/gibs/strider_weapon.mdl", 1, 0}, --strider cannon
							{"models/gibs/strider_head.mdl", 100, 0}} --strider minigun
				end
				ScavData.CollectFuncs["models/combine_strider_vsdog.mdl"] = ScavData.CollectFuncs["models/combine_strider.mdl"]
			else
				tab.ChargeAttack = function(self, item)
					self:SetChargeAttack()
					return 1
				end
				tab.FireFunc = function(self, item)
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
					return true
				end
			end
			tab.Cooldown = 1.3
			
		ScavData.RegisterFiremode(tab, "models/combine_strider.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/strider_weapon.mdl")
		
--[[==============================================================================================
	--Spit Grenade
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.acidspit"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[Antlion] = 0,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 30
			tab.models = {"models/spitball_large.mdl", "models/spitball_medium.mdl", "models/spitball_small.mdl"}
			if SERVER then
				tab.FireFunc = function(self, item)
					self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
						local pos = self:GetProjectileShootPos()
						for i=1, 7 do
							local proj = self:CreateEnt("grenade_spit")
							proj.Owner = self.Owner
							proj:SetOwner(self.Owner)
							proj:SetPos(pos)
							--proj:SetAngles((self:GetAimVector():Angle():Right()):Angle())
							proj:Spawn()
							proj:SetModel(ScavData.models[item.ammo].models[math.random(1, 3)])
							proj:SetVelocity((self:GetAimVector() + VectorRand() * 0.1) * 1000)
						end
						self.Owner:EmitSound(self.shootsound)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						return self:TakeSubammo(item, 1)
					end
				ScavData.CollectFuncs["models/antlion_worker.mdl"] = function(self, ent) return {{"models/spitball_large.mdl", 6, 0}} end --6 spit rounds from an antlion worker
				ScavData.CollectFuncs["models/gibs/antlion_worker_gibs_head.mdl"] = ScavData.CollectFuncs["models/antlion_worker.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/spitball_large.mdl")
		ScavData.RegisterFiremode(tab, "models/spitball_medium.mdl")
		ScavData.RegisterFiremode(tab, "models/spitball_small.mdl")
		
--[[==============================================================================================
	--bugbait
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#weapon_bugbait"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 1
			local identify = {} --all bugbait is the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.antlionfriend =	function(ent) 
					if IsValid(ent) and (ent:GetClass() == "npc_antlion") then
						for _, v in ipairs(player.GetAll()) do
							if IsValid(v:GetWeapon("scav_gun")) then
								local hate = true
								for _, j in ipairs(v:GetWeapon("scav_gun").inv.items) do
									if j.ammo == "models/weapons/w_bugbait.mdl" then
										ent:AddEntityRelationship(v, D_LI, 999)
										--print(ent .. " should like " .. v .. "...")
										hate = false
										break
									end
								end
								if hate then
									--print(ent .. " should hate " .. v .. "...")
									ent:AddEntityRelationship(v, D_HT, 99)
								end
							end
						end
					end
				end
				--[[tab.allantlions = function() for l, m in ipairs(ents.FindByClass("npc_antlion")) do ScavData.models["models/weapons/w_bugbait.mdl"].antlionfriend(m) end end
				tab.PostRemove = tab.allantlions]]
				tab.FireFunc = function(self, item)
					self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
						local proj = self:CreateEnt("npc_grenade_bugbait")
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Right()):Angle())
						proj:Spawn()
						proj:SetVelocity((self:GetAimVector() + vector_up * 0.1) * 1000)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
					return self:TakeSubammo(item, 1)
				end
				--[[hook.Add("OnEntityCreated", "scav_bugbait", tab.antlionfriend)
				hook.Add("PlayerSpawn", "scav_bugbait2", tab.allantlions)]]
				--BUG TODO: doesn't currently make antlions friendly
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/weapons/w_bugbait.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/antlion_guard.mdl", SCAV_SHORT_MAX)
		

--[[==============================================================================================
	--Gravity Gun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#weapon_physcannon"
			tab.Level = 7
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.anim = ACT_VM_RECOIL3
			tab.dmginfo = DamageInfo()
			tab.vmin = Vector(-8, -8, -8)
			tab.vmax = Vector(8, 8, 8)
			if SERVER then
				tab.FireFunc = function(self, item)
						local tr = self.Owner:GetEyeTraceNoCursor()
						local tab = ScavData.models[item.ammo]
						if not IsValid(tr.Entity) then
							local tracep = {}
								tracep.start = self.Owner:GetShootPos()
								tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 850
								tracep.filter = self.Owner
								tracep.mask = MASK_SHOT
								tracep.mins = tab.vmin
								tracep.maxs = tab.vmax
							self.Owner:LagCompensation(true)
							tr = util.TraceHull(tracep)
							self.Owner:LagCompensation(false)
						end
						if IsValid(tr.Entity) and tr.Entity:GetPhysicsObject():IsValid() and ((tr.HitPos-tr.StartPos):Length() < 250 + 600 * item.data) then
							self.Owner:ViewPunch(Angle(-5, math.Rand(-5, 5), 0))
							local ef = EffectData()
							ef:SetStart(self.Owner:GetShootPos())
							ef:SetOrigin(tr.HitPos)
							ef:SetEntity(self)
							local dmg = tab.dmginfo
							if item.data == 0 then
								util.Effect("ef_scav_tr3", ef)
								tr.Entity:GetPhysicsObject():ApplyForceOffset(tr.Normal * 200000, tr.HitPos)
								dmg:SetDamage(1)
								dmg:SetDamageForce(tr.Normal * 200000)
								dmg:SetAttacker(self.Owner)
								dmg:SetInflictor(self)
								dmg:SetDamagePosition(tr.HitPos)
								dmg:SetDamageType(DMG_PHYSGUN)
								tr.Entity:TakeDamageInfo(dmg)
							else
								util.Effect("ef_scav_tr4", ef) --TO DO: Merge into ef_scav_tr3
								tr.Entity:GetPhysicsObject():ApplyForceOffset(tr.Normal * 3000000, tr.HitPos)
								if tr.Entity:IsPlayer() then
									tr.Entity:SetVelocity(tr.Normal * 3000)
								end
								dmg:SetDamage(75)
								dmg:SetDamageForce(tr.Normal * 3000000)
								dmg:SetAttacker(self.Owner)
								dmg:SetInflictor(self)
								dmg:SetDamagePosition(tr.HitPos)
								dmg:SetDamageType(DMG_PHYSGUN)
								tr.Entity:TakeDamageInfo(dmg)
							end
							tr.Entity:SetPhysicsAttacker(self.Owner)
						else
							self.Owner:EmitToAllButSelf("weapons/physcannon/physcannon_dryfire.wav")
						end
						return false
				end
			else
				tab.FireFunc = function(self, item)
					local tr = self.Owner:GetEyeTraceNoCursor()
					local tab = ScavData.models[item.ammo]
					if not IsValid(tr.Entity) then
						local tracep = {}
							tracep.start = self.Owner:GetShootPos()
							tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 850
							tracep.filter = self.Owner
							tracep.mask = MASK_SHOT
							tracep.mins = tab.vmin
							tracep.maxs = tab.vmax
						tr = util.TraceHull(tracep)
					elseif tr.Entity:GetPhysicsObject():IsValid() and ((tr.HitPos-tr.StartPos):Length() < 250 + 600 * item.data) then
						local ef = EffectData()
							ef:SetStart(self.Owner:GetShootPos())
							ef:SetOrigin(tr.HitPos)
							ef:SetEntity(self)
						local dmg = tab.dmginfo
						util.Effect(item.data == 0 and "ef_scav_tr3" or "ef_scav_tr4", ef)
					else
						self.Owner:EmitSound("weapons/physcannon/physcannon_dryfire.wav")
					end
					return false
				end
			end
			tab.Cooldown = 0.5
		ScavData.RegisterFiremode(tab, "models/weapons/w_physics.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/dog.mdl", SCAV_SHORT_MAX)
		
--[[==============================================================================================
	--Frag Grenade
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#weapon_frag"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[HL2] = 0,
				--[[HL:S]]["models/w_grenade.mdl"] = 1,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self, item)
					local tab = ScavData.models[item.ammo]
					self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
					local proj = self:CreateEnt("npc_grenade_frag")
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles((self:GetAimVector():Angle():Right()):Angle())
					proj:SetPhysicsAttacker(self.Owner)
					proj:SetSaveValue("m_hThrower", self.Owner)
					proj:SetSaveValue("m_hOriginalThrower", self.Owner)
					proj:Spawn()
					proj:SetModel(item.ammo)
					proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector()) * 2000, Vector(0, 0, 3))
					timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(1000, 1000, 0)) end)
					proj:Fire("SetTimer", 2, 0)
					if tab.Identify[item.ammo] == 1 then
						proj:AddCallback("PhysicsCollide", function(ent, data)
							if ( data.Speed > 50 ) then
								ent:EmitSound(Sound("weapons/grenade_hit" .. math.random(3) .. ".wav"))
							end
						end)
						if proj:GetInternalVariable("m_flNextBlipTime") then
							proj:SetSaveValue("m_flNextBlipTime", CurTime() + 1000)
						end
						timer.Simple(0, function()
							local fxent = nil
							if IsValid(proj) and proj:GetInternalVariable("m_pGlowTrail") then
								fxent = proj:GetInternalVariable("m_pGlowTrail")
								if IsValid(fxent) then
									fxent:Remove()
								end
							end
							if IsValid(proj) and proj:GetInternalVariable("m_pMainGlow") then
								fxent = proj:GetInternalVariable("m_pMainGlow")
								if IsValid(fxent) then
									fxent:Remove()
								end
							end
						end)
					end
					proj:SetSaveValue("m_pGlowTrail", nil)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound(self.shootsound)
					--gamemode.Call("ScavFired", self.Owner, proj)
					return self:TakeSubammo(item, 1)
				end
				ScavData.CollectFuncs["models/items/ammocrate_grenade.mdl"] = function(self, ent) return {{"models/weapons/w_grenade.mdl", SCAV_SHORT_MAX, 0}} end
				ScavData.CollectFuncs["models/zombie/zombie_soldier.mdl"] = function(self, ent)
					local items = {
						{"models/zombie/zombie_soldier_legs.mdl", 1, 0},
						{"models/weapons/w_grenade.mdl", 2, 0},
						{"models/zombie/zombie_soldier_torso.mdl", 1, 0}
					}
					if tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
						table.insert(items, {"models/headcrabclassic.mdl", 1, 0})
					end
					return items
				end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/weapons/w_grenade.mdl")
		ScavData.RegisterFiremode(tab, "models/items/grenadeammo.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_npcnade.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/weapons/w_frag.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_stick.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_grenade.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_eq_pipebomb.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_grenade_mp.mdl")





--[[==============================================================================================
	--Helicopter Grenade
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.helinade"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[HL2] = 0,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 5
			if SERVER then
				tab.FireFunc = function(self, item)
					self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
					local proj = self:CreateEnt("grenade_helicopter")
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj.Inflictor = proj
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles((self:GetAimVector():Angle():Right()):Angle())
					proj:Spawn()
					proj:GetPhysicsObject():SetVelocity(self:GetAimVector() * 5000)
					proj:SetPhysicsAttacker(self.Owner)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound(self.shootsound)
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/combine_helicopter/helicopter_bomb01.mdl")
		
--[[==============================================================================================
	--Armor Battery
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#item_battery"
			tab.anim = ACT_VM_FIDGET
			tab.Level = 1
			local identify = {
				--[HL2] = SCAV_BATTERY_DEFAULT,
				--[[Battalion's Backup]]["models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl"] = SCAV_BATTERY_BATTALION,
				["models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl"] = SCAV_BATTERY_BATTALION,
				--[[MannPower Resistance]]["models/pickups/pickup_powerup_defense.mdl"] = SCAV_BATTERY_RESISTANCE,
				["models/pickups/pickup_powerup_resistance.mdl"] = SCAV_BATTERY_RESISTANCE,
				--[[DoD:S]]["models/helmets/helmet_american.mdl"] = SCAV_BATTERY_DODSHELMET,
				["models/helmets/helmet_german.mdl"] = SCAV_BATTERY_DODSHELMET,
				--[[BM Helmet]]["models/props_am/helmet.mdl"] = SCAV_BATTERY_BMSHELMET,
				["models/props_marines/helmet.mdl"] = SCAV_BATTERY_BMSHELMET,
				["models/props_2fort/hardhat001.mdl"] = SCAV_BATTERY_BMSHELMET,
				["models/props_junk/hardhat.mdl"] = SCAV_BATTERY_BMSHELMET,
				--[[Vest]]["models/props_am/guard_vest.mdl"] = SCAV_BATTERY_VEST,
				--[[HEV]]["models/props_am/hev_suit.mdl"] = SCAV_BATTERY_HEV,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_BATTERY_DEFAULT end})
			tab.MaxAmmo = 6
			tab.ReturnArmor = function(self, item)
				local t = ScavData.models[item.ammo]
				local amount = {
					[SCAV_BATTERY_DEFAULT] = 15,
					[SCAV_BATTERY_BATTALION] = 50,
					[SCAV_BATTERY_RESISTANCE] = 50,
					[SCAV_BATTERY_DODSHELMET] = 25,
					[SCAV_BATTERY_BMSHELMET] = 40,
					[SCAV_BATTERY_VEST] = 60,
					[SCAV_BATTERY_HEV] = 100
				}
				return amount[t.Identify[item.ammo]]
			end
			if SERVER then
				tab.FireFunc = function(self, item)
					local t = ScavData.models[item.ammo]
					if self.Owner:Armor() >= self.Owner:GetMaxArmor() then
						self.Owner:EmitSound("buttons/button11.wav")
						return false
					end
					self.Owner:SetArmor(math.min(self.Owner:GetMaxArmor(), self.Owner:Armor() + t.ReturnArmor(self, item)))
					local itemfx = {
						[SCAV_BATTERY_BATTALION] = function(self)
							self.Owner:EmitSound( math.random(2) == 1 and "weapons/battalions_backup_red.wav" or "weapons/battalions_backup_blue.wav")
						end,
						[SCAV_BATTERY_RESISTANCE] = function(self)
							self.Owner:EmitSound("items/powerup_pickup_reduced_damage.wav")
						end,
						[SCAV_BATTERY_DODSHELMET] = function(self)
							self.Owner:EmitSound("physics/helmet.wav")
						end,
					}
					setmetatable(itemfx, {__index = function() return function(self) self.Owner:EmitSound("items/battery_pickup.wav") end end})
					itemfx[t.Identify[item.ammo]](self)
					self.Owner:SendHUDOverlay(Color(0, 100, 255, 100), 0.25)
					return self:TakeSubammo(item, 1)
				end
				--DoD:S
				ScavData.CollectFuncs["models/player/american_assault.mdl"] = function(self, ent) return {{"models/helmets/helmet_american.mdl", 1, 0}} end
				ScavData.CollectFuncs["models/player/american_mg.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/american_rifleman.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/american_rocket.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/american_sniper.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/american_support.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_assault.mdl"] = function(self, ent) return {{"models/helmets/helmet_german.mdl", 1, 0}} end
				ScavData.CollectFuncs["models/player/german_mg.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_rifleman.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_rocket.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_sniper.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_support.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				--BMS
				ScavData.CollectFuncs["models/humans/hev_gordon.mdl"] = function(self, ent) return {
					{"models/props_am/hev_suit.mdl", 1, 0},
					{"models/weapons/w_crowbar_mp.mdl", 1, 0},
				} end
				ScavData.CollectFuncs["models/player/mp_scientist_hev.mdl"] = function(self, ent) return {{"models/props_am/hev_suit.mdl", 1, 0}} end
				ScavData.CollectFuncs["models/humans/hev_male_xen.mdl"] = ScavData.CollectFuncs["models/player/mp_scientist_hev.mdl"]
			end
			tab.Cooldown = 0.2
		ScavData.RegisterFiremode(tab, "models/items/battery.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_defense.mdl")
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_resistance.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl")
		ScavData.RegisterFiremode(tab, "models/props_2fort/hardhat001.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/helmets/helmet_american.mdl")
		ScavData.RegisterFiremode(tab, "models/helmets/helmet_german.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_battery.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_battery.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/helmet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/helmet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/guard_vest.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/hev_suit.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/hardhat.mdl")
		
--[[==============================================================================================
	--Shotgun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#weapon_shotgun"
			--tab.anim = ACT_VM_RECOIL3
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 3
			local identify = {
				--[HL2] = SCAV_SG_DEFAULT,
				--[[TF2 Stock]]["models/weapons/shells/shell_shotgun.mdl"] = SCAV_SG_TF2,
				["models/weapons/w_models/w_shotgun.mdl"] = SCAV_SG_TF2,
				["models/weapons/c_models/c_shotgun/c_shotgun.mdl"] = SCAV_SG_TF2,
				["models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl"] = SCAV_SG_TF2,
				--[[Widowmaker]]["models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl"] = SCAV_SG_WIDOWMAKER,
				["models/workshop_partner/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl"] = SCAV_SG_WIDOWMAKER,
				--[[HL:S]]["models/shotgunshell.mdl"] = SCAV_SG_HL,
				--[[TF2 Scattergun]]["models/weapons/c_models/c_scattergun.mdl"] = SCAV_SG_SCATTER,
				["models/weapons/w_models/w_scattergun.mdl"] = SCAV_SG_SCATTER,
				--[[TF2 FaN]]["models/weapons/c_models/c_double_barrel.mdl"] = SCAV_SG_FAN,
				["models/weapons/c_models/c_xms_double_barrel.mdl"] = SCAV_SG_FAN,
				--[[TF2 Soda Popper]]["models/weapons/c_models/c_soda_popper/c_soda_popper.mdl"] = SCAV_SG_SODAPOP,
				["models/workshop/weapons/c_models/c_soda_popper/c_soda_popper.mdl"] = SCAV_SG_SODAPOP,
				--[[F2 Frontier Justice]]["models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl"] = SCAV_SG_TF2FJ,
				["models/weapons/c_models/c_frontierjustice/c_frontierjustice_xmas.mdl"] = SCAV_SG_TF2FJ,
				["models/weapons/w_models/w_frontierjustice.mdl"] = SCAV_SG_TF2FJ,
				--[[TF2 Reserve Shooter]]["models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl"] = SCAV_SG_RESERVE,
				["models/workshop/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl"] = SCAV_SG_RESERVE,
				--[[TF2 Family Business]]["models/weapons/c_models/c_russian_riot/c_russian_riot.mdl"] = SCAV_SG_FAMBIZ,
				["models/workshop/weapons/c_models/c_russian_riot/c_russian_riot.mdl"] = SCAV_SG_FAMBIZ,
				--[[TF2 Shortstop]]["models/weapons/c_models/c_shortstop/c_shortstop.mdl"] = SCAV_SG_SHORTSTOP,
				["models/workshop/weapons/c_models/c_shortstop/c_shortstop.mdl"] = SCAV_SG_SHORTSTOP,
				--[[TF2 Baby Face's Blaster]]["models/weapons/c_models/c_pep_scattergun.mdl"] = SCAV_SG_BFB,
				["models/workshop/weapons/c_models/c_pep_scattergun/c_pep_scattergun.mdl"] = SCAV_SG_BFB,
				--[[TF2 Backscatter]]["models/workshop/weapons/c_models/c_scatterdrum/c_scatterdrum.mdl"] = SCAV_SG_BACKSCATTER,
				--[[ASW]]["models/swarm/ammo/ammoshotgun.mdl"] = SCAV_SG_ASW,
				["models/weapons/shotgun/shotgun.mdl"] = SCAV_SG_ASW,
				--[[Vindicator]]["models/weapons/vindicator/vindicator.mdl"] = SCAV_SG_VINDICATOR,
				--[[BMS]]["models/weapons/w_shotgun_mp.mdl"] = SCAV_SG_BMS,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_SG_DEFAULT end})
			tab.MaxAmmo = 125

			local bullet = {}
				bullet.Num = 10
				bullet.Spread = Vector(0.075, 0.03, 0)
				bullet.Tracer = 1
				bullet.Force = 4
				bullet.Damage = 5
				bullet.TracerName = "ef_scav_tr_b"
			function tab.OnArmed(self, item, olditemname)
				if SERVER then
					if olditemname ~= "" and ScavData.models[olditemname] and ScavData.models[item.ammo].Name == ScavData.models[olditemname].Name then return end
					local soundfx = {
						[SCAV_SG_DEFAULT] = function(self)
							self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
						end,
						[SCAV_SG_TF2] = function(self)
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
						end,
						[SCAV_SG_WIDOWMAKER] = function(self)
							self.Owner:EmitSound("weapons/widow_maker_pump_action_back.wav") --not used in TF2, but works here.
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/widow_maker_pump_action_forward.wav") end end)
						end,
						[SCAV_SG_HL] = function(self)
							self.Owner:EmitSound("weapons/scock1.wav")
						end,
						[SCAV_SG_SCATTER] = function(self)
							self.Owner:EmitSound("weapons/scatter_gun_reload.wav")
						end,
						[SCAV_SG_FAN] = function(self)
							self.Owner:EmitSound("weapons/scatter_gun_double_tube_close.wav")
						end,
						[SCAV_SG_SODAPOP] = function(self)
							self.Owner:EmitSound("weapons/scatter_gun_double_tube_close.wav")
						end,
						[SCAV_SG_TF2FJ] = function(self)
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
						end,
						[SCAV_SG_RESERVE] = function(self)
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
						end,
						[SCAV_SG_FAMBIZ] = function(self)
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
						end,
						[SCAV_SG_SHORTSTOP] = function(self)
							self.Owner:EmitSound("weapons/short_stop_reload.wav")
						end,
						[SCAV_SG_BFB] = function(self)
							self.Owner:EmitSound("weapons/scatter_gun_reload.wav")
						end,
						[SCAV_SG_BACKSCATTER] = function(self)
							self.Owner:EmitSound("weapons/scatter_gun_reload.wav")
						end,
						[SCAV_SG_ASW] = function(self)
							self.Owner:EmitSound("weapons/3d/reloads/shotgun_c.wav")
						end,
						[SCAV_SG_VINDICATOR] = function(self)
							self.Owner:EmitSound("weapons/3d/reloads/vindicator_c.wav")
						end,
						[SCAV_SG_BMS] = function(self)
							self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
						end,
					}
					local tab = ScavData.models[item.ammo]
					soundfx[tab.Identify[item.ammo]](self)
				end
			end
			tab.FireFunc = function(self, item)
				local tab = ScavData.models[item.ammo]
				self.Owner:ScavViewPunch(Angle(-10, math.Rand(-0.1, 0.1), 0), 0.3)
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self:GetAimVector()
				if SERVER or not game.SinglePlayer() then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)

				local shootfx = {
					[SCAV_SG_DEFAULT] = function(self)
						timer.Simple(0.4, function()
							if not IsValid(self) then return end
							self:EjectShell("ShotgunShellEject", false)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
						end)
						if CLIENT then return end
						self.Owner:EmitSound("weapons/shotgun/shotgun_fire6.wav")
					end,
					[SCAV_SG_TF2] = function(self)
						timer.Simple(0.4, function()
							self:EjectShellTF2("shotgun")
							if CLIENT then return end
							if not IsValid(self) or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
						end)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/shotgun_shoot_crit.wav" or "weapons/shotgun_shoot.wav")
					end,
					[SCAV_SG_WIDOWMAKER] = function(self)
						if SERVER then self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/widow_maker_shot_crit_0" .. math.random(3) .. ".wav" or "weapons/widow_maker_shot_0" .. math.random(3) .. ".wav") end
					end,
					[SCAV_SG_HL] = function(self)
						timer.Simple(0.4, function()
							if not IsValid(self) then return end
							self:EjectShellHL1(true)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("weapons/scock1.wav")
						end)
						if CLIENT then return end
						self.Owner:EmitSound("weapons/sbarrel1.wav")
					end,
					[SCAV_SG_SCATTER] = function(self)
						timer.Simple(0.4, function()
							if SERVER then self.Owner:EmitSound("weapons/scatter_gun_reload.wav") end
							self:EjectShellTF2("shotgun")
						end)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/scatter_gun_shoot_crit.wav" or "weapons/scatter_gun_shoot.wav")
					end,
					[SCAV_SG_FAN] = function(self)
						--TODO: double barrel eject/reload sounds every other shot
						--[[timer.Simple(0.4, function()
							if SERVER then self.Owner:EmitSound("weapons/scatter_gun_reload.wav") end
							self:EjectShellTF2("shotgun")
						end)]]
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/scatter_gun_double_shoot_crit.wav" or "weapons/scatter_gun_double_shoot.wav")
					end,
					[SCAV_SG_SODAPOP] = function(self)
						--TODO: double barrel eject/reload sounds every other shot
						--[[timer.Simple(0.4, function()
							if SERVER then self.Owner:EmitSound("weapons/scatter_gun_reload.wav") end
							self:EjectShellTF2("shotgun")
						end)]]
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/scatter_gun_double_bonk_shoot_crit.wav" or "weapons/scatter_gun_double_bonk_shoot.wav")
					end,
					[SCAV_SG_TF2FJ] = function(self)
						timer.Simple(0.4, function()
							self:EjectShellTF2("shotgun")
							if CLIENT then return end
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
						end)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/frontier_justice_shoot_crit.wav" or "weapons/frontier_justice_shoot.wav")
					end,
					[SCAV_SG_RESERVE] = function(self)
						timer.Simple(0.4, function()
							self:EjectShellTF2("shotgun")
							if CLIENT then return end
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
						end)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/reserve_shooter_0" .. math.random(4) .. "_crit.wav" or "weapons/reserve_shooter_0" .. math.random(4) .. ".wav")
					end,
					[SCAV_SG_FAMBIZ] = function(self)
						timer.Simple(0.4, function()
							self:EjectShellTF2("shotgun")
							if CLIENT then return end
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
						end)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/family_business_shoot_crit.wav" or "weapons/family_business_shoot.wav")
					end,
					[SCAV_SG_SHORTSTOP] = function(self)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "Weapon_Short_Stop.SingleCrit" or "Weapon_Short_Stop.Single")
					end,
					[SCAV_SG_BFB] = function(self)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "Weapon_Brawler_Blaster.SingleCrit" or "Weapon_Brawler_Blaster.Single")
					end,
					[SCAV_SG_BACKSCATTER] = function(self)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "Weapon_Back_Scatter.SingleCrit" or "Weapon_Back_Scatter.Single")
					end,
					[SCAV_SG_ASW] = function(self)
						if CLIENT then return end
						self.Owner:EmitSound("weapons/2d/shotgun/fire_and_loadfp.wav")
					end,
					[SCAV_SG_VINDICATOR] = function(self)
						if CLIENT then return end
						self.Owner:EmitSound("weapons/2d/vindicator/fire_and_loadfp.wav")
					end,
					[SCAV_SG_BMS] = function(self)
						timer.Simple(0.4, function()
							if not IsValid(self) then return end
							self:EjectShell("ShotgunShellEject", false)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("weapons/shotgun/shotgun_pump" .. tostring(math.random(2)) .. ".wav")
						end)
						if CLIENT then return end
						self.Owner:EmitSound("weapons/shotgun/single.wav")
					end,
				}
				shootfx[tab.Identify[item.ammo]](self)
				if SERVER then return self:TakeSubammo(item, 1) end
			end
			if SERVER then		
				ScavData.CollectFuncs["models/scav/shells/shell_shotgun_tf2.mdl"] = function(self, ent) return {{"models/weapons/shells/shell_shotgun.mdl", 1, 0}} end --convert Scav TF2 shell
				ScavData.CollectFuncs["models/items/ammocrate_buckshot.mdl"] = function(self, ent) return {{"models/weapons/shotgun_shell.mdl", SCAV_SHORT_MAX, 0}} end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_double_barrel.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_xms_double_barrel.mdl" or ScavData.FormatModelname(ent:GetModel()), 2, self.christmas and ent:GetSkin() % 2 or ent:GetSkin()}} end --2 shotgun shells from the FaN
				ScavData.CollectFuncs["models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_frontierjustice/c_frontierjustice_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 3, 0}} end --3 shotgun shells from the Frontier Justice
				ScavData.CollectFuncs["models/weapons/w_models/w_frontierjustice.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl"]
				--FoF
				ScavData.CollectFuncs["models/weapons/w_sawed_shotgun.mdl"] = function(self, ent) return {{"models/weapons/shotgun_shell2.mdl", 2, 0}} end --2 shotgun shells from a sawed off
				ScavData.CollectFuncs["models/weapons/w_sawed_shotgun2.mdl"] = ScavData.CollectFuncs["models/weapons/w_sawed_shotgun.mdl"]
				ScavData.CollectFuncs["models/weapons/w_ghostgun.mdl"] = ScavData.CollectFuncs["models/weapons/w_sawed_shotgun.mdl"]
				ScavData.CollectFuncs["models/weapons/w_ghostgun2.mdl"] = ScavData.CollectFuncs["models/weapons/w_ghostgun.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/weapons/shotgun_shell.mdl")
		ScavData.RegisterFiremode(tab, "models/items/boxbuckshot.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/weapons/w_shotgun.mdl", 6)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/shells/shell_shotgun.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_shotgun.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_shotgun/c_shotgun.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_scattergun.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_scattergun.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl", 6) --Panic Attack
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_double_barrel.mdl") --Force-A-Nature
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_xms_double_barrel.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_soda_popper/c_soda_popper.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_soda_popper/c_soda_popper.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_pep_scattergun.mdl", 4) --Baby Face's Blaster
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_pep_scattergun/c_pep_scattergun.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_russian_riot/c_russian_riot.mdl", 8) --Family Business
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_russian_riot/c_russian_riot.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_shortstop/c_shortstop.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_shortstop/c_shortstop.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_scatterdrum/c_scatterdrum.mdl", 4) --Backscatter
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_frontierjustice/c_frontierjustice_xmas.mdl", 3)
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_frontierjustice.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl", SCAV_SHORT_MAX) --Widowmaker
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl", SCAV_SHORT_MAX)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_pumpshotgun_a.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_shotgun.mdl", 8)
		--FoF
		ScavData.RegisterFiremode(tab, "models/weapons/shotgun_shell2.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab, "models/shotgunshell.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarm/ammo/ammoshotgun.mdl", 12)
		ScavData.RegisterFiremode(tab, "models/weapons/shotgun/shotgun.mdl", 12)
		ScavData.RegisterFiremode(tab, "models/weapons/vindicator/vindicator.mdl", 12)
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_shotgun_mp.mdl", 8)
		
--[[==============================================================================================
	--Pistol
==============================================================================================]]--

		local tab = {}
			tab.Name = "#scav.scavcan.pistol"
			--tab.anim = ACT_VM_RECOIL3
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 3
			local identify = {
				--[[HL2]]["models/items/boxsrounds.mdl"] = 0,
				["models/weapons/w_pistol.mdl"] = 0,
				["models/weapons/pistol/pistol.mdl"] = 0,
				["models/items/ammocrate_pistol.mdl"] = 0,
				--[TF2] = 1,
				--[[HL:S]]["models/w_9mmhandgun.mdl"] = 2,
				--[[FoF]]--[] = 3,
				--TODO: with this, can split up TF2/FoF's various pistols much more easily
			}
			tab.Identify = setmetatable(identify, {__index = function() return 1 end})
			tab.MaxAmmo = 250
			tab.FireFunc = function(self, item)
				local tab = ScavData.models[item.ammo]
				local bullet = {}
					bullet.Num = 1
					bullet.Spread = Vector(0.01, 0.01, 0)
					bullet.Tracer = 1
					bullet.Force = 0
					bullet.Damage = 5
					bullet.TracerName = "ef_scav_tr_b"
				self.Owner:ScavViewPunch(Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0), 0.5)
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self:GetAimVector()
				if not game.SinglePlayer() or SERVER then
					self.Owner:FireBullets(bullet)
				end
				if SERVER then self.Owner:SetAnimation(PLAYER_ATTACK1) end
				self:MuzzleFlash2()
				local weaponfx = {
					[0] = function(self)
						timer.Simple(0.025, function()
							if not IsValid(self) then return end
							self:EjectShell("ShellEject", false)
						end)
						if CLIENT then return end
						self.Owner:EmitSound("Weapon_Pistol.Single")
					end,
					[1] = function(self)
						timer.Simple(0.025, function()
							if not IsValid(self) then return end
							self:EjectShellTF2()
						end)
						if CLIENT then return end
						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/pistol_shoot_crit.wav" or "weapons/pistol_shoot.wav")
					end,
					[2] = function(self)
						timer.Simple(0.025, function()
							if not IsValid(self) then return end
							self:EjectShellHL1()
						end)
						if CLIENT then return end
						self.Owner:EmitSound("weapons/pl_gun3.wav")
					end,
				}
				weaponfx[tab.Identify[item.ammo]](self)
				self.nextfireearly = CurTime() + 0.1
				if SERVER then return self:TakeSubammo(item, 1) end
				return false
			end
			function tab.OnArmed(self, item, olditemname)
				if SERVER then
					if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
						self.Owner:EmitSound("physics/metal/weapon_impact_soft3.wav") --TODO: nice slide sound
					end
				end
			end
			if SERVER then
				--HLS
				ScavData.CollectFuncs["models/hl1bar.mdl"] = function(self, ent) return {{"models/w_9mmhandgun.mdl", 17, 0}} end --17 pistol rounds from a HL1 pistol
			end
			tab.Cooldown = 0.4
		ScavData.RegisterFiremode(tab, "models/items/boxsrounds.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/weapons/w_pistol.mdl", 18)
		ScavData.RegisterFiremode(tab, "models/items/ammocrate_pistol.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_pistol.mdl", 12)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_pistol.mdl", 12)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_pistol/c_pistol.mdl", 12)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_ttg_max_gun/c_ttg_max_gun.mdl", 12) --Lugermorph
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_ttg_max_gun.mdl", 12)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_ttg_max_gun/c_ttg_max_gun.mdl", 12)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_winger_pistol/c_winger_pistol.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_winger_pistol/c_winger_pistol.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl", 9) --Pretty Boy's Pocket Pistol
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl", 9)
		--HLS
		ScavData.RegisterFiremode(tab, "models/w_9mmhandgun.mdl")
		--FoF
		ScavData.RegisterFiremode(tab, "models/weapons/w_deringer.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/weapons/w_deringer2.mdl", 2)
		--ASW
		ScavData.RegisterFiremode(tab, "models/weapons/pistol/pistol.mdl", 24)
		
--[[==============================================================================================
	--pulse rifle
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#weapon_ar2"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 3
			local identify = {} --all pulse rifles are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 90 --60 + 30
			tab.Callback = function(attacker, tr, dmg)
				local ef = EffectData()
				ef:SetOrigin(tr.HitPos)
				ef:SetNormal(tr.HitNormal)
				util.Effect("AR2Impact", ef)
			end
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 8
						bullet.TracerName = "AR2Tracer"
						bullet.Callback = tab.Callback
						local scale1 = 1
						if self.mousepressed then
							scale1 = 1 + math.Clamp((CurTime() - self.mousepressed), 0, 3)
						end
						if CLIENT then self.Owner:ScavViewPunch(Angle(math.Rand(0, -scale1), math.Rand(-scale1, scale1), 0), 0.5) end
						bullet.Spread = Vector(0.02 * scale1, 0.02 * scale1, 0)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:MuzzleFlash2(2)
					if SERVER then
						self.Owner:EmitSound("Weapon_AR2.Single")
						self:AddBarrelSpin(500)
						self:SetPanelPose(math.Min(0.5, math.Max(0, scale1 - 1.5)), scale1 / 2)
						timer.Simple(tab.Cooldown, function() self:SetPanelPose(0, scale1 / 4) end)
						self:TakeSubammo(item, 1)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
					end
				end
				return 0.1
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)							
				return false
			end
			function tab.OnArmed(self, item, olditemname)
				if SERVER then
					if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
						self.Owner:EmitSound("weapons/ar2/ar2_reload_push.wav")
					end
				end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/items/combine_rifle_cartridge01.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/weapons/w_irifle.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/items/ammocrate_ar2.mdl", SCAV_SHORT_MAX)
		
--[[==============================================================================================
	--Strider Minigun
==============================================================================================]]--
		local tab = {}
			tab.Name = "#scav.scavcan.stridergun"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 7
			local identify = {} --all strider miniguns are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 100
			tab.Callback = function(attacker, tr, dmg)
				local ef = EffectData()
				ef:SetOrigin(tr.HitPos)
				ef:SetNormal(tr.HitNormal)
				--ef:SetScale(1)
				--ef:SetMagnitude(10)
				--util.Effect("HelicopterImpact", ef)
				util.Effect("AR2Impact", ef)
			end
			local bullet = {}
				bullet.Num = 1
				bullet.Tracer = 1
				bullet.Force = 20
				bullet.Damage = 30
				bullet.TracerName = "ef_scav_tr_strider"
				bullet.Callback = tab.Callback
			local ef = EffectData()
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local scale1 = 1
					if self.mousepressed then
						scale1 = 4 - math.Clamp((CurTime() - self.mousepressed), 0, 3)
					end
					if CLIENT then
						self.Owner:ScavViewPunch(Angle(math.Rand(0, -scale1), math.Rand(-scale1, scale1), 0), 0.5)
					end
					bullet.Spread = Vector(0.02 * scale1, 0.02 * scale1, 0)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					ef:SetEntity(self)
					if CLIENT and self.Owner == GetViewEntity() then
						ef:SetEntity(self.Owner:GetViewModel())
						ef:SetOrigin(self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos)
					else
						ef:SetOrigin(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
					end
					ef:SetNormal(bullet.Dir)
					ef:SetScale(0.25)
					util.Effect("StriderMuzzleFlash", ef)
					if SERVER then
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound("NPC_Strider.FireMinigun")
						self:TakeSubammo(item, 1)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring and SERVER then
					self:SetChargeAttack()
				end
				return 0.2
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item	)						
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/gibs/strider_head.mdl", 100)
		
--[[==============================================================================================
	--Airboat Gun
==============================================================================================]]--

		if SERVER then util.AddNetworkString("scv_setsubammo") end

		local tab = {}
			tab.Name = "#func_tankairboatgun"
			tab.anim = ACT_VM_IDLE
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 9
			tab.MaxAmmo = 100
			local returnval = {false, true}
			local function rechargeairboatgun(self, item)
				if IsValid(item) then
					if not item.isfiring and item:GetSubammo() < 100 then
						item:SetSubammo(math.min(item:GetSubammo() + 1, item:GetFiremodeInfo().MaxAmmo))
						net.Start("scv_setsubammo")
							net.WriteEntity(self)
							net.WriteInt(item.subammo, 16)
							net.WriteInt(item.pos, 8)
						net.Send(self.Owner)
					end
					timer.Simple(0.05, function() rechargeairboatgun(self, item) end)
				end
			end
			tab.Callback = function(attacker, tr, dmg)
				dmg:SetDamageType(bit.bor(DMG_NEVERGIB, DMG_AIRBOAT))
				local ef = EffectData()
				ef:SetOrigin(tr.HitPos)
				ef:SetNormal(tr.HitNormal)
				util.Effect("AR2Impact", ef)
				util.Effect("MetalSpark", ef)
				if SERVER then
					tr.Entity:TakeDamageInfo(dmg)
				end
				return returnval
			end
			if SERVER then
				tab.OnPickup = function(self, item)
					timer.Simple(0.05, function() rechargeairboatgun(self, item) end)
				end
			end
			
			tab.ChargeAttack = function(self, item)
				local bullet = {}
					bullet.Num = 3
					bullet.Spread = Vector(0.01, 0.01, 0)
					bullet.Tracer = 3
					bullet.Force = 5
					bullet.Damage = GetConVar("sk_plr_dmg_airboat"):GetFloat()
					bullet.TracerName = "AirboatGunTracer"
					bullet.Callback = tab.Callback
					bullet.DamageType = bit.bor(DMG_NEVERGIB, DMG_AIRBOAT)
				if item.subammo <= 0 then
					self:SetChargeAttack()
					if SERVER then self.soundloops.airboatgunfire:Stop() end
					item.isfiring = false
					self.Owner:EmitSound("weapons/airboat/airboat_gun_lastshot" .. math.random(1, 2) .. ".wav")
					return 0
				end
				if not self.Owner:KeyDown(IN_ATTACK) then
					self:SetChargeAttack()
					if SERVER then self.soundloops.airboatgunfire:Stop() end
					item.isfiring = false
					self.Owner:EmitSound("weapons/airboat/airboat_gun_lastshot" .. math.random(1, 2) .. ".wav")
				end
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:MuzzleFlash2(2)
					if SERVER then self:TakeSubammo(item, 1) end
				return 0.05
			end

			tab.FireFunc = function(self, item)
				if (item.subammo > 0 and SERVER) or (item.subammo > -1 and CLIENT) then
					item.isfiring = true
					if SERVER then
						self.soundloops.airboatgunfire = CreateSound(self.Owner, "weapons/airboat/airboat_gun_loop2.wav")
						self.soundloops.airboatgunfire:Play()
					end
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				end
				return false
			end
			tab.Cooldown = 0.05
		ScavData.RegisterFiremode(tab, "models/airboatgun.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/props_combine/bunker_gun01.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/gunship.mdl", 100)
		ScavData.RegisterFiremode(tab, "models/gibs/gunship_gibs_nosegun.mdl", 100)
		--HLDM:S
		ScavData.RegisterFiremode(tab, "models/mp/turret.mdl", 100)
		--BMS
		ScavData.RegisterFiremode(tab, "models/gibs/m1a1_abrams_gibs/m1_gib_turret_machinegun.mdl", 2)
--[[==============================================================================================
	--Combine Ball
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.pulseorb"
			tab.anim = ACT_VM_FIDGET
			tab.Level = 4
			local identify = {} --all pulse orbs are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 3
			tab.chargeanim = ACT_VM_SECONDARYATTACK
			if SERVER then
				tab.ChargeAttack = function(self, item)
					self.soundloops.cballcharge:Stop()
					local proj = self:CreateEnt("scav_projectile_comball")
					proj.Owner = self.Owner
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles(self:GetAimVector():Angle())
					proj:SetOwner(self.Owner)
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					proj:GetPhysicsObject():Wake()
					proj:GetPhysicsObject():EnableDrag(false)
					proj:GetPhysicsObject():EnableGravity(false)
					proj:GetPhysicsObject():SetVelocity((self:GetAimVector()) * 2500)
					proj:GetPhysicsObject():SetBuoyancyRatio(0)
					self.Owner:ViewPunch(Angle(math.Rand(-2, 0), math.Rand(-0.1, 0.1), 0))
					self.Owner:EmitSound("weapons/Irifle/irifle_fire2.wav")
					self:SetChargeAttack()
					return 0.5
				end
				tab.FireFunc = function(self, item)
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
					self.soundloops.cballcharge = CreateSound(self.Owner, "weapons/cguard/charging.wav")
					self.soundloops.cballcharge:Play()
					self:SetPanelPose(1, 1.5)
					timer.Simple(0.5, function() self:SetPanelPose(0, 10) end)
					return self:TakeSubammo(item, 1)
				end
				tab.OnArmed = function(self, item, olditemname)
					self.Owner:EmitSound("weapons/ar2/ar2_reload_rotate.wav")
				end
			else
				tab.ChargeAttack = function(self, item)
					self:SetChargeAttack()
					return 0.5
				end
				tab.FireFunc = function(self, item)
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
					return true
				end
			end
			tab.Cooldown = 0.5
			
		ScavData.RegisterFiremode(tab, "models/effects/combineball.mdl")
		ScavData.RegisterFiremode(tab, "models/items/combine_rifle_ammo01.mdl")
		--Portal
		ScavData.RegisterFiremode(tab, "models/props/combine_ball_launcher.mdl")

--[[==============================================================================================
	--Helicopter Minigun
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.heligun"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 8
			tab.MaxAmmo = 100
			tab.ChargeAttack = function(self, item)
				local bullet = {}
					bullet.Num = 5
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = Vector(0.1, 0.1, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 6
					bullet.TracerName = "HelicopterTracer"
					bullet.Callback = ScavData.models[self.chargeitem.ammo].Callback
				if SERVER or not game.SinglePlayer() then
					self.Owner:FireBullets(bullet)
				end
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self:MuzzleFlash2("ChopperMuzzleFlash")
				if SERVER then
					self.Owner.scav_helisound:Play()
					self.Owner:GetPhysicsObject(wake)
					self.Owner:SetVelocity(self:GetAimVector() * -70)
					self:TakeSubammo(item, 1)
				end
				if self.chargeitem.subammo <= 0 then
					self:SetChargeAttack()
					if SERVER then
						self.Owner.scav_helisound:Stop()
						if item.subammo <= 0 then
							self:RemoveItemValue(item)
						end
						self:SetPanelPose(0, 1)
						self:SetBlockPose(0, 1)
						self:SetBarrelRestSpeed(0)
					end
					return 0.5
				end
				return 0.1
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				if SERVER then
					self.Owner:EmitSound("npc/attack_helicopter/aheli_charge_up.wav")
					self.Owner.scav_helisound = CreateSound(self.Owner, "npc/attack_helicopter/aheli_weapon_fire_loop3.wav")
					self:SetPanelPose(1, 1)
					self:SetBlockPose(1, 1)
					self:SetBarrelRestSpeed(900)
				end
				--return true
			end
			tab.Cooldown = 2
			
		ScavData.RegisterFiremode(tab, "models/combine_helicopter.mdl", 100)

		
--[[==============================================================================================
	-- Health Charger
==============================================================================================]]--

		local tab = {}
			tab.Name = "#item_healthcharger"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {
				--[HL2] = 0,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 100
			tab.vmin = Vector(-12, -12, -12)
			tab.vmax = Vector(12, 12, 12)
			tab.Cooldown = .1
			tab.StopBeep = false
			local nextBeep = CurTime()
			local fullBeep = function(self, item)
				if self.StopBeep then return end
				if self.Owner:KeyDown(IN_ATTACK) and nextBeep <= CurTime() then
					self.Owner:EmitSound("items/medshotno1.wav", 75, 100, 1)
					if SERVER then self.soundloops.healthCharger:Stop() end
					nextBeep = CurTime() + 1
				end
			end

			tab.ChargeAttack = function(self, item)
				local target = self.Owner
					local tracep = {}
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 100
					tracep.filter = self.Owner
					tracep.mask = MASK_SHOT
					tracep.mins = tab.vmin
					tracep.maxs = tab.vmax
					local tr = util.TraceHull(tracep)
					if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) and tr.Entity.Health and tr.Entity.GetMaxHealth and tr.Entity.SetHealth and tr.Entity:GetMaxHealth() > 0 and (tr.Entity:Health() < tr.Entity:GetMaxHealth()) then
						target = tr.Entity
					end
				if target:GetMaxHealth() <= target:Health() then
					if target ~= self.Owner and self.Owner:GetMaxHealth() > self.Owner:Health() then
						target = self.Owner
					end
				end
				if target:GetMaxHealth() > target:Health() then --check again, in case we switched to ourself
					local att = self:LookupAttachment("muzzle")
					local posang = self:GetAttachment(att)

					local ef = EffectData()
						ef:SetEntity(target)
						ef:SetRadius(1)
						ef:SetOrigin(self.Owner:GetPos())
						ef:SetNormal(posang.Ang:Forward())
						ef:SetStart(posang.Pos)
						ef:SetScale(self.Owner:EntIndex())
						ef:SetAttachment(att)
					util.Effect("ef_scav_heal", ef, nil, true)

					--restart healing sound, in case we were holding down attack and got a valid healing target (either by looking around or our current one getting hurt)
					self.StopBeep = true
					if SERVER and not IsValid(self.soundloops.healthCharger) then
						self.soundloops.healthCharger = CreateSound(self.Owner, "items/medcharge4.wav")
						self.soundloops.healthCharger:Play()
					end
					target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + 1))
					if SERVER then self:TakeSubammo(item, 1) end
				elseif SERVER then --our target is full health, switch over to beep loop
					self.StopBeep = false
					fullBeep(self, item)
					self.soundloops.healthCharger:Stop()
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self.soundloops.healthCharger:Stop()
						self.StopBeep = true
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					else
						--hook.Remove( "RenderScreenspaceEffects", "ScavHealthCharger")
						fullBeep(self, item)
					end

					return 0.25
				else
					if SERVER and target:GetMaxHealth() > target:Health() then
						self.soundloops.healthCharger:Play()
					end
					return 0.1
				end
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				if SERVER then
					self.Owner:EmitSound("player/suit_denydevice.wav")
					if not IsValid(self.soundloops.healthCharger) then self.soundloops.healthCharger = CreateSound(self.Owner, "items/medcharge4.wav") end
					self:SetBarrelRestSpeed(400)
				else
					timer.Simple(1, function()
						if self:ProcessLinking(item) and self:StopChargeOnRelease() then --make sure the player didn't cancel the charge before we even got to it
							--hook.Add( "RenderScreenspaceEffects", "ScavHealthCharger", function() --TODO: screen effect?
								--DrawMaterialOverlay( "models/shadertest/shader3", -0.01 )
							--end )
						else
							self.StopBeep = true
						end
					end)
				end
				return false
			end
			tab.ReturnHealth = function(self, item)
				return 1 --counting functions already account for subammo
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_combine/health_charger001.mdl"] = function(self, ent) return {{ScavData.FormatModelname(ent:GetModel()), math.Round(GetConVar("sk_healthcharger"):GetFloat()) or 50, ent:GetSkin()}} end --(default 50) health for chargers
				--BMS
				ScavData.CollectFuncs["models/props_blackmesa/health_charger.mdl"] = ScavData.CollectFuncs["models/props_combine/health_charger001.mdl"]
				ScavData.CollectFuncs["models/props_blackmesa/health_charger_clean.mdl"] = ScavData.CollectFuncs["models/props_blackmesa/health_charger.mdl"]
			end
		
		ScavData.RegisterFiremode(tab, "models/props_combine/health_charger001.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/health_charger.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/health_charger_clean.mdl")



--[[==============================================================================================
	-- Suit Charger
==============================================================================================]]--

		local tab = {}
			tab.Name = "#item_suitcharger"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {
				--[HL2] = 0,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 200
			tab.Cooldown = .1
			tab.StopBeep = false
			local nextBeep = CurTime()
			local fullBeep = function(self, item)
				if self.StopBeep then return end
				if self.Owner:KeyDown(IN_ATTACK) and nextBeep <= CurTime() then
					self.Owner:EmitSound("items/suitchargeno1.wav", 75, 100, 1)
					if SERVER then self.soundloops.suitCharger:Stop() end
					nextBeep = CurTime() + 1
				end
			end

			tab.ChargeAttack = function(self, item)
				local target = self.Owner
					local tracep = {}
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 100
					tracep.filter = self.Owner
					tracep.mask = MASK_SHOT
					tracep.mins = Vector(-12, -12, -12)
					tracep.maxs = Vector(12, 12, 12)
					local tr = util.TraceHull(tracep)
					if tr.Entity:IsPlayer() and (tr.Entity:Armor() < tr.Entity:GetMaxArmor()) then
						target = tr.Entity
					end
				if target:GetMaxArmor() > target:Armor() then
					local att = self:LookupAttachment("muzzle")
					local posang = self:GetAttachment(att)

					--[[local ef = EffectData() --TODO: Suit charge effect
						ef:SetEntity(target)
						ef:SetRadius(1)
						ef:SetOrigin(self.Owner:GetPos())
						ef:SetNormal(posang.Ang:Forward())
						ef:SetStart(posang.Pos)
						ef:SetScale(self.Owner:EntIndex())
						ef:SetAttachment(att)
					util.Effect("ef_scav_heal", ef, nil, true)]]--

					--restart charge sound, in case we were holding down attack and got a valid charge target (either by looking around or our current one getting damaged)
					self.StopBeep = true
					if SERVER and not IsValid(self.soundloops.suitCharger) then
						self.soundloops.suitCharger = CreateSound(self.Owner, "items/suitcharge1.wav")
						self.soundloops.suitCharger:Play()
					end
					if SERVER then
						target:SetArmor(math.min(target:GetMaxArmor(), target:Armor() + 1))
						self:TakeSubammo(item, 1)
					end
				elseif SERVER then --our target is full armor, switch over to beep loop
					self.StopBeep = false
					fullBeep(self, item)
					self.soundloops.suitCharger:Stop()
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self.soundloops.suitCharger:Stop()
						self.StopBeep = true
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					--[[else
						hook.Remove( "RenderScreenspaceEffects", "ScavSuitCharger")
						fullBeep(self, item)]]
					end

					return 0.25
				else
					if SERVER and target:GetMaxArmor() > target:Armor() then self.soundloops.suitCharger:Play() end
					return 0.1
				end
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				if SERVER then
					self.Owner:EmitSound("player/suit_denydevice.wav")
					if not IsValid(self.soundloops.suitCharger) then self.soundloops.suitCharger = CreateSound(self.Owner, "items/suitcharge1.wav") end
					self:SetBarrelRestSpeed(400)
				--[[else --not worth it
						if not self.StopBeep then
							hook.Add( "RenderScreenspaceEffects", "ScavSuitCharger", function()
								surface.SetDrawColor(0, 100, 255, 100 * math.sin(CurTime()))
								surface.DrawRect(0, 0, ScrW(), ScrH())
							end )
						else
							self.StopBeep = true
						end]]--
				end
				return false
			end
			tab.ReturnArmor = function(self, item)
				return 1 --counting functions already account for subammo
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_combine/suit_charger001.mdl"] = function(self, ent) return {{ScavData.FormatModelname(ent:GetModel()), math.Round(GetConVar("sk_suitcharger"):GetFloat()) or 75, ent:GetSkin()}} end --(default 75) battery for chargers
				ScavData.CollectFuncs["models/props_lab/hevplate.mdl"] = ScavData.CollectFuncs["models/props_combine/suit_charger001.mdl"]
				ScavData.CollectFuncs["models/props_blackmesa/hev_charger.mdl"] = ScavData.CollectFuncs["models/props_lab/hevplate.mdl"]
				ScavData.CollectFuncs["models/props_blackmesa/hev_charger_clean.mdl"] = ScavData.CollectFuncs["models/props_blackmesa/hev_charger.mdl"]
			end
		
		ScavData.RegisterFiremode(tab, "models/props_combine/suit_charger001.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lab/hevplate.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/hev_charger.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/hev_charger_clean.mdl")
		
--[[==============================================================================================
	-- .357 rounds
==============================================================================================]]--

 --drop shells at end
local function revolver_reload(self, item, reload, style, count)
	if (item.subammo <= 1 and SERVER) or (item.subammo <= 0 and CLIENT) then
		timer.Simple(0.5, function()
			local count = count or 6
			if not IsValid(self) or not IsValid(self.Owner) then return end

			if SERVER then
				local reload = type(reload) == "table" and reload or {reload, 75, 100, 1, CHAN_WEAPON}
				self.Owner:EmitSound(unpack(reload))
			end
			if CLIENT == game.SinglePlayer() then return end

			if style == SCAV_REVOLVER_DEFAULT then
				for i = 1, count do
					self:EjectShell("ShellEject", false)
				end
			elseif style == SCAV_REVOLVER_HL1 then
				for i = 1, count do
					self:EjectShellHL1()
				end
			else
				for i = 1, count do
					self:EjectShellTF2()
				end
			end
		end)
	end
end

		local tab = {}
			tab.Name = "#weapon_357"
			tab.anim = ACT_VM_RECOIL2
			tab.Level = 4
			local identify = {
				--[Revolver] = 0,
				--[[Annabelle/Lever Action]]["models/weapons/w_annabelle.mdl"] = SCAV_REVOLVER_LEVER,
				--[[TF2]]["models/weapons/w_models/w_revolver.mdl"] = SCAV_REVOLVER_TF2,
				["models/weapons/c_models/c_revolver/c_revolver.mdl"] = SCAV_REVOLVER_TF2,
				["models/weapons/c_models/c_revolver/c_revolver_xmas.mdl"] = SCAV_REVOLVER_TF2,
				--[[TF2 Ambassador]]["models/weapons/c_models/c_ambassador/c_ambassador.mdl"] = SCAV_REVOLVER_AMBY,
				["models/weapons/c_models/c_ambassador/c_ambassador_xmas.mdl"] = SCAV_REVOLVER_AMBY,
				--[[TF2 Enforcer]]["models/weapons/c_models/c_snub_nose/c_snub_nose.mdl"] = SCAV_REVOLVER_ENFORCER,
				["models/workshop/weapons/c_models/c_snub_nose/c_snub_nose.mdl"] = SCAV_REVOLVER_ENFORCER,
				--[[TF2 Big Kill]]["models/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl"] = SCAV_REVOLVER_BIGKILL,
				["models/workshop/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl"] = SCAV_REVOLVER_BIGKILL,
				--[[TF2 L'etranger]]["models/weapons/c_models/c_letranger/c_letranger.mdl"] = SCAV_REVOLVER_LETRANGER,
				["models/workshop/weapons/c_models/c_letranger/c_letranger.mdl"] = SCAV_REVOLVER_LETRANGER,
				--[[TF2 Diamondback]]["models/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl"] = SCAV_REVOLVER_DIAMONDBACK,
				["models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl"] = SCAV_REVOLVER_DIAMONDBACK,
				--[[HL1]]["models/w_357.mdl"] = SCAV_REVOLVER_HL1,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_REVOLVER_DEFAULT end})
			tab.MaxAmmo = 42 -- 36 + 6
			local firesounds357 = {
				[SCAV_REVOLVER_DEFAULT] = function(self) self.Owner:EmitSound("Weapon_357.Single") end,
				[SCAV_REVOLVER_LEVER] = function(self) self.Owner:EmitSound("Weapon_357.Single") end,
				[SCAV_REVOLVER_ENFORCER] = function(self) self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/tf_spy_enforcer_revolver_crit.wav" or ("weapons/tf_spy_enforcer_revolver_0" .. tostring(math.random(6)) .. ".wav")) end,
				[SCAV_REVOLVER_LETRANGER] = function(self) self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/letranger_shoot_crit.wav" or "weapons/letranger_shoot.wav") end,
				[SCAV_REVOLVER_DIAMONDBACK] = function(self) self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and ("weapons/diamond_back_0".. tostring(math.random(3)) .. "_crit.wav") or ("weapons/diamond_back_0".. tostring(math.random(3)) .. ".wav")) end,
				[SCAV_REVOLVER_HL1] = function(self) self.Owner:EmitSound("weapons/357_shot" .. tostring(math.random(2)) .. ".wav") end,
			}
			--set TF2 stock revolver sounds as default as a couple of them use it
			setmetatable(firesounds357, {__index = function() return function(self) self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/revolver_shoot_crit.wav" or "weapons/revolver_shoot.wav") end end})
			
			tab.FireFunc = function(self, item)
				local tab = ScavData.models[self.inv.items[1].ammo]
				local ident = tab.Identify[item.ammo]
				local bullet = {}
				bullet.Num = 1
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self:GetAimVector()
				bullet.Spread = vector_origin
				bullet.Tracer = 1
				bullet.Force = 5
				bullet.Damage = 40
				bullet.TracerName = "ef_scav_tr_b"
				if not game.SinglePlayer() or SERVER then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				firesounds357[ident](self)
				self.Owner:ScavViewPunch(Angle(-15, math.Rand(-0.1, 0.1), 0), 0.5)
				if CLIENT then
					self.Owner:SetEyeAngles((vector_up * 0.05 + self:GetAimVector()):Angle())
				end
				local itemfx = {
					[SCAV_REVOLVER_DEFAULT] = function(self, item) revolver_reload(self, item, "weapons/357/357_reload1.wav", SCAV_REVOLVER_DEFAULT) end,
					[SCAV_REVOLVER_LEVER] = function(self, item)
						timer.Simple(0.4, function() --lever action
							if not IsValid(self) then return end
							self:EjectShell("ShellEject", false)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("weapons/smg1/switch_burst.wav", 75, 85, 1, CHAN_WEAPON)
						end)
					end,
					[SCAV_REVOLVER_TF2] = function(self, item) revolver_reload(self, item, "weapons/revolver_worldreload.wav", SCAV_REVOLVER_TF2) end,
					[SCAV_REVOLVER_AMBY] = function(self, item) revolver_reload(self, item, "weapons/revolver_worldreload.wav", SCAV_REVOLVER_TF2) end,
					[SCAV_REVOLVER_ENFORCER] = function(self, item) revolver_reload(self, item, "weapons/revolver_worldreload.wav", SCAV_REVOLVER_TF2) end,
					[SCAV_REVOLVER_BIGKILL] = function(self, item) revolver_reload(self, item, "weapons/revolver_worldreload.wav", SCAV_REVOLVER_TF2) end,
					[SCAV_REVOLVER_LETRANGER] = function(self, item) revolver_reload(self, item, "weapons/revolver_worldreload.wav", SCAV_REVOLVER_TF2) end,
					[SCAV_REVOLVER_DIAMONDBACK] = function(self, item) revolver_reload(self, item, "weapons/revolver_worldreload.wav", SCAV_REVOLVER_TF2) end,
					[SCAV_REVOLVER_HL1] = function(self, item) revolver_reload(self, item, "weapons/357_reload1.wav", SCAV_REVOLVER_HL1) end,
				}
				itemfx[ident](self, item)
				if SERVER then
					return self:TakeSubammo(item, 1)
				end
			end
			if SERVER then
				tab.OnArmed = function(self, item, olditemname)
					if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
						local tab = ScavData.models[self.inv.items[1].ammo]
						if tab.Identify[item.ammo] ~= SCAV_REVOLVER_LEVER then
							self.Owner:EmitSound("weapons/357/357_spin1.wav")
						end
					end
				end
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_revolver/c_revolver_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 6, self.christmas and ent:GetSkin() % 2 or ent:GetSkin()}} end
				ScavData.CollectFuncs["models/weapons/c_models/c_revolver/c_revolver.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_ambassador/c_ambassador.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_ambassador/c_ambassador_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 6, self.christmas and ent:GetSkin() % 2 or ent:GetSkin()}} end
				--CSS
				ScavData.CollectFuncs["models/props/cs_militia/gun_cabinet.mdl"] = function(self, ent) return {{"models/weapons/w_annabelle.mdl", 4, 0}} end --2 x 2 .357 rounds from the gun cabinet
				--FoF 
				ScavData.CollectFuncs["models/weapons/w_dualnavy.mdl"] = function(self, ent) return {{ScavData.FormatModelname(ent:GetModel()), 12, 0}} end --2 x 6 .357 round from the duals
				ScavData.CollectFuncs["models/weapons/w_henryrifle.mdl"] = function(self, ent) return {{"models/weapons/w_annabelle.mdl", 16, 0}} end --16 .357 rounds from the Henry Rifle
				ScavData.CollectFuncs["models/weapons/w_maresleg.mdl"] = function(self, ent) return {{"models/weapons/w_annabelle.mdl", 8, 0}} end --8 .357 rounds from the Mare's Leg
				ScavData.CollectFuncs["models/weapons/w_spencer.mdl"] = function(self, ent) return {{"models/weapons/w_annabelle.mdl", 7, 0}} end --7 .357 rounds from the Spencer
				ScavData.CollectFuncs["models/weapons/w_volcanic.mdl"] = function(self, ent) return {{"models/weapons/w_annabelle.mdl", 9, 0}} end --9 .357 rounds from the Volcanic
				ScavData.CollectFuncs["models/weapons/w_volcanic2.mdl"] = ScavData.CollectFuncs["models/weapons/w_volcanic.mdl"]
				ScavData.CollectFuncs["models/weapons/w_mauser.mdl"] = ScavData.CollectFuncs["models/weapons/w_volcanic.mdl"]
				ScavData.CollectFuncs["models/weapons/w_mauser2.mdl"] = ScavData.CollectFuncs["models/weapons/w_mauser.mdl"]
				ScavData.CollectFuncs["models/weapons/w_maresleg2.mdl"] = ScavData.CollectFuncs["models/weapons/w_maresleg.mdl"]
				ScavData.CollectFuncs["models/weapons/w_dualpeacemaker.mdl"] = ScavData.CollectFuncs["models/weapons/w_dualnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"] = function(self, ent) return {{"models/weapons/w_357.mdl", 6, 0}} end --6 .357 round from the Colt
				ScavData.CollectFuncs["models/weapons/w_coltnavy2.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_hammerless.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_hammerless2.mdl"] = ScavData.CollectFuncs["models/weapons/w_hammerless.mdl"]
				ScavData.CollectFuncs["models/weapons/w_peacemaker.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_peacemaker2.mdl"] = ScavData.CollectFuncs["models/weapons/w_peacemaker.mdl"]
				ScavData.CollectFuncs["models/weapons/w_remington_army.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_remington_army2.mdl"] = ScavData.CollectFuncs["models/weapons/w_remington_army.mdl"]
				ScavData.CollectFuncs["models/weapons/w_walker.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_walker2.mdl"] = ScavData.CollectFuncs["models/weapons/w_walker.mdl"]
				ScavData.CollectFuncs["models/weapons/w_sharps.mdl"] = function(self, ent) return {{"models/weapons/w_annabelle.mdl", 1, 0}} end --1 .357 round from the Sharps
				ScavData.CollectFuncs["models/props/gun_cabinet/gun_cabinet.mdl"] = ScavData.CollectFuncs["models/props/cs_militia/gun_cabinet.mdl"] --2 x 2 .357 rounds from the gun cabinet
				ScavData.CollectFuncs["models/props/gun_cabinet/gun_cabinet_gold.mdl"] = function(self, ent) --8 x 1, 6 x 2 .357 rounds from the gun cabinet
					return {{"models/weapons/w_annabelle.mdl", 8, 0},
							{"models/weapons/w_357.mdl", 12, 0}}
				end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/weapons/w_357.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/items/357ammo.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/items/357ammobox.mdl", 12)
		ScavData.RegisterFiremode(tab, "models/weapons/w_annabelle.mdl", 2)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_revolver.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_revolver/c_revolver.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_revolver/c_revolver_xmas.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_ambassador/c_ambassador.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_ambassador/c_ambassador_xmas.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_snub_nose/c_snub_nose.mdl", 6) --Enforcer
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_snub_nose/c_snub_nose.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl", 6) --Big Kill
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_letranger/c_letranger.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_letranger/c_letranger.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl", 6) --Diamondback
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl", 6)
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_357.mdl", 6)
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_357_mp.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/w_357ammobox.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/w_357ammobox_mp.mdl", 6)
		
--[[==============================================================================================
	--machinegun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.smg"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 3
			local identify = {
				--[HL2/Default] = 0,
				--[[Alyx Gun]]["models/weapons/w_alyx_gun.mdl"] = 1,
				["models/weapons/pdw/pdw.mdl"] = 1,
				--[[TF2 SMG]]["models/weapons/w_models/w_smg.mdl"] = 2,
				["models/weapons/c_models/c_smg/c_smg.mdl"] = 2,
				--[[TF2 Cleaner's Carbine]]["models/weapons/c_models/c_pro_smg/c_pro_smg.mdl"] = 3,
				["models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl"] = 3,
				--[[HL:S]]["models/w_9mmar.mdl"] = 4,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 270 --225 + 45
			tab.ChargeAttack = function(self, item)
				local tab = ScavData.models[item.ammo]
				if self.Owner:KeyDown(IN_ATTACK) then
					self.Owner:ScavViewPunch(Angle(math.Rand(-0.2, 0.2), math.Rand(-0.2, 0.2), 0), 0.1)
					local bullet = {}
						bullet.Num = 1
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = Vector(0.05, 0.05, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 4
						bullet.TracerName = "ef_scav_tr_b"
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self:AddBarrelSpin(200)
						self:TakeSubammo(item, 1)
					end
					local itemfx = {
						[0] = function(self)
							timer.Simple(0.025, function()
								if not IsValid(self) then return end
								self:EjectShell("ShellEject", false)
							end)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("Weapon_SMG1.Single")
						end,
						[1] = function(self)
							timer.Simple(0.025, function()
								if not IsValid(self) then return end
								self:EjectShell("ShellEject", false)
							end)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("Weapon_Alyx_Gun.Single")
						end,
						[2] = function(self)
							timer.Simple(0.025, function()
								if not IsValid(self) then return end
								self:EjectShellTF2()
							end)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/smg_shoot_crit.wav" or "weapons/smg_shoot.wav")
						end,
						[3] = function(self)
							timer.Simple(0.025, function()
								if not IsValid(self) then return end
								self:EjectShellTF2()
							end)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/doom_sniper_smg_crit.wav" or "weapons/doom_sniper_smg.wav")
						end,
						[4] = function(self)
							timer.Simple(0.025, function()
								if not IsValid(self) then return end
								self:EjectShellHL1()
							end)
							if CLIENT or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("weapons/hks" .. math.random(3) .. ".wav")
						end,
					}
					itemfx[tab.Identify[item.ammo]](self)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring and SERVER then
					self:SetChargeAttack()
				end
				if tab.Identify[item.ammo] == 2 then
					return 0.105
				elseif tab.Identify[item.ammo] == 3 then
					return 0.135
				else
					return 0.065
				end
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				return false
			end
			function tab.OnArmed(self, item, olditemname)
				if SERVER then
					if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
						self.Owner:EmitSound("weapons/smg1/switch_burst.wav")
					end
				end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/items/boxmrounds.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/weapons/w_smg1.mdl", 45)
		ScavData.RegisterFiremode(tab, "models/weapons/w_alyx_gun.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/items/ammocrate_smg1.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_smg.mdl", 25)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_smg/c_smg.mdl", 25)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_pro_smg/c_pro_smg.mdl", 20) --Cleaner's Carbine
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl", 20)
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_9mmar.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/weapons/pdw/pdw.mdl", 80)

--[[==============================================================================================
	--Hunter Flechettes
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.flechettes"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			local identify = {} --all flechettes are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 50
			if SERVER then
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("hunter_flechette")
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles(self:GetAimVector():Angle())
					proj:SetPhysicsAttacker(self.Owner)
					proj:Spawn()
					proj:SetOwner(self.Owner)
					proj:SetVelocity(self:GetAimVector() * 2000)
					self.Owner:EmitSound("npc/ministrider/ministrider_fire1.wav")
					proj:Fire("kill", 1, 10)
					self.Owner:ViewPunch(Angle(math.Rand(-1, 0), math.Rand(-0.1, 0.1), 0))
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 0.1
		ScavData.RegisterFiremode(tab, "models/weapons/hunter_flechette.mdl")
		ScavData.RegisterFiremode(tab, "models/hunter.mdl", 25)
		ScavData.RegisterFiremode(tab, "models/renderng_regression_test_hunter.mdl", 25)
		ScavData.RegisterFiremode(tab, "models/ministrider.mdl", 25)
		
--[[==============================================================================================
	--Grunt Hornets
==============================================================================================]]--
		
		local tab = {} --TODO: recharge ammo (like airboat gun)
			tab.Name = "#scav.scavcan.hornets"
			local identify = {
				--[[HL:S]]["models/agrunt.mdl"] = SCAV_HORNET_DEFAULT,
				["models/w_hgun.mdl"] = SCAV_HORNET_DEFAULT,
				--[[ASW]]["models/swarm/buzzer/buzzer.mdl"] = SCAV_HORNET_ASW,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_HORNET_BMS end})
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 5
			tab.MaxAmmo = 50 --8
			if SERVER then
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("hornet")
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles(self:GetAimVector():Angle())
					proj:SetPhysicsAttacker(self.Owner)
					proj:Spawn()
					if tab.Identify[item.ammo] ~= SCAV_HORNET_DEFAULT then
						local bms = (tab.Identify[item.ammo] == SCAV_HORNET_BMS)
						proj:SetModel(bms and "models/weapons/w_hornet.mdl" or "models/swarm/buzzer/buzzer.mdl")
						proj:SetModelScale(bms and 0.5 or 0.1)
					end
					proj:SetOwner(self.Owner)
					proj:SetVelocity(self:GetAimVector() * 2000)
					self.Owner:EmitSound("agrunt/ag_fire" .. math.random(1, 3) .. ".wav")
					proj:Fire("kill", 1, 10)
					self.Owner:ViewPunch(Angle(math.Rand(-1, 0), math.Rand(-0.1, 0.1), 0))
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 0.2
		ScavData.RegisterFiremode(tab, "models/agrunt.mdl", 50)
		ScavData.RegisterFiremode(tab, "models/w_hgun.mdl", 50)
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarm/buzzer/buzzer.mdl", 50)
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_hgun.mdl", 50)
		ScavData.RegisterFiremode(tab, "models/weapons/w_hgun_lowpoly.mdl", 50)
		ScavData.RegisterFiremode(tab, "models/weapons/w_hgun_mp.mdl", 50)
		ScavData.RegisterFiremode(tab, "models/weapons/w_hgun_mp.mdl", 50)
		ScavData.RegisterFiremode(tab, "models/xenians/agrunt.mdl", 50)
		ScavData.RegisterFiremode(tab, "models/xenians/agrunt_02.mdl", 50)
		ScavData.RegisterFiremode(tab, "models/weapons/w_hornet.mdl", 1)
		
--[[==============================================================================================
	--Controller Energy Ball
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.aliencontroller"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 5
			tab.MaxAmmo = 50
			if SERVER then
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("controller_energy_ball")
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles(self:GetAimVector():Angle())
					proj:SetPhysicsAttacker(self.Owner)
					proj:Spawn()
					proj:SetOwner(self.Owner)
					proj:SetVelocity(self:GetAimVector() * 2000)
					self.Owner:EmitSound("weapons/electro4.wav")
					proj:Fire("kill", 1, 10)
					self.Owner:ViewPunch(Angle(math.Rand(-1, 0), math.Rand(-0.1, 0.1), 0))
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 0.15
		--HL:S
		ScavData.RegisterFiremode(tab, "models/controller.mdl", 50)
		--BMS
		ScavData.RegisterFiremode(tab, "models/xenians/controller.mdl", 50)
	
--[[==============================================================================================
	--Squid Spit
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.bullsquid"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.MaxAmmo = 50
			if SERVER then
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("squidspit")
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles(self:GetAimVector():Angle())
					proj:SetPhysicsAttacker(self.Owner)
					proj:Spawn()
					proj:SetOwner(self.Owner)
					proj:SetVelocity(self:GetAimVector() * 2000)
					self.Owner:EmitSound("bullchicken/bc_attack" .. math.random(2, 3) .. ".wav")
					proj:Fire("kill", 1, 10)
					self.Owner:ViewPunch(Angle(math.Rand(-1, 0), math.Rand(-0.1, 0.1), 0))
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 0.6
		--HL:S
		ScavData.RegisterFiremode(tab, "models/bullsquid.mdl", 5)
		--BMS
		ScavData.RegisterFiremode(tab, "models/xenians/bullsquid.mdl", 5)

--[[==============================================================================================
	--Vortigaunt Beam
==============================================================================================]]--

		PrecacheParticleSystem("vortigaunt_beam")
		PrecacheParticleSystem("scav_vm_vort")
		local tab = {}
			tab.Name = "#scav.scavcan.vortigaunt"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[HL2] = 0,
				--[[HL:S]]["models/islave.mdl"] = 1,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 10
			local dmg = DamageInfo()
			local tracep = {}
			tracep.mask = MASK_SHOT
			tracep.mins = Vector(-2, -2, -2)
			tracep.maxs = Vector(2, 2, 2)
			if CLIENT then
				local ef = EffectData()
			end
			tab.ChargeAttack = function(self, item)
				local tab = ScavData.models[item.ammo]
				local shootpos = self.Owner:GetShootPos()
				tracep.start = shootpos
				tracep.endpos = shootpos + self:GetAimVector() * 2000
				tracep.filter = self.Owner
				local tr = util.TraceHull(tracep)
				if SERVER then
					util.ParticleTracerEx("vortigaunt_beam", self:GetAttachment(self:LookupAttachment("muzzle")).Pos, tr.HitPos, false, self:EntIndex(), 1)
					if IsValid(tr.Entity) then
						dmg:SetAttacker(self.Owner)
						dmg:SetInflictor(self)
						dmg:SetDamagePosition(tr.HitPos)
						dmg:SetDamageType(DMG_SHOCK)
						dmg:SetDamage(50)
						dmg:SetDamageForce(tr.Normal * 12000)
						tr.Entity:TakeDamageInfo(dmg)
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					local soundfx = {
						[0] = function(tr)
							sound.Play("npc/vort/vort_explode2.wav" , tr.HitPos)
						end,
						[1] = function(tr)
							sound.Play("weapons/electro4.wav", tr.HitPos, 75, math.Rand(140, 160))
						end
					}
					soundfx[tab.Identify[item.ammo]](tr)
					self.soundloops.scavvort:Stop()
					self:SetBlockPose(0, 4)
					self:TakeSubammo(item, 1)
				else
					if self.Owner == GetViewEntity() then
						util.ParticleTracerEx("vortigaunt_beam", self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos, self.Owner:GetEyeTraceNoCursor().HitPos, false, 0, -1)
					else
						util.ParticleTracerEx("vortigaunt_beam", self:GetAttachment(self:LookupAttachment("muzzle")).Pos, self.Owner:GetEyeTraceNoCursor().HitPos, false, self:EntIndex(), 1)
					end
					ef:SetOrigin(tr.HitPos)
					ef:SetNormal(tr.HitNormal)
					if GetConVar("cl_scav_high"):GetBool() then
						self.dlight = DynamicLight(0)
							self.dlight.Pos = tr.HitPos
							self.dlight.r = 110
							self.dlight.g = 200
							self.dlight.b = 75
							self.dlight.Brightness = .5
							self.dlight.Size = 512
							self.dlight.Decay = 750
							self.dlight.DieTime = CurTime() + .75
					end
					util.Effect("StunstickImpact", ef)
				end
				local soundfx = {
					[0] = function(self)
						self.Owner:EmitSound("npc/vort/vort_explode1.wav", 75, 100, 0.5)
						self.Owner:EmitSound("npc/vort/attack_shoot.wav", 75, 100, 0.25) --God why is this so LOUD all of a sudden
					end,
					[1] = function(self)
						self.Owner:EmitSound("weapons/electro4.wav", 75, math.Rand(140, 160))
						self.Owner:EmitSound("hassault/hw_shoot1.wav", 75, math.Rand(130, 160))
					end
				}
				soundfx[tab.Identify[item.ammo]](self)
				self:ProcessLinking(item)
				self:SetChargeAttack()
				return 0.5
			end
			tab.FireFunc = function(self, item)
				local tab = ScavData.models[item.ammo]
				self:SetChargeAttack(tab.ChargeAttack, item)
				if SERVER then
					if self.Owner.snd_scavvort then
						self.Owner.snd_scavvort:Stop()
					end
					if not self.soundloops.scavvort then
						self.soundloops.scavvort = CreateSound(self.Owner, tab.Identify[item.ammo] == 0 and "npc/vort/attack_charge.wav" or "debris/zap4.wav")
					end
					if self.soundloops.scavvort then
						self.soundloops.scavvort:PlayEx(0.5, 100)
						if tab.Identify[item.ammo] == 1 then
							self.soundloops.scavvort:ChangePitch(140, 1.5)
						end
					end
					self:SetBlockPose(1, 4)
					return false
				else
					ParticleEffectAttach("scav_vm_vort", PATTACH_POINT_FOLLOW, self.Owner:GetViewModel(), self:LookupAttachment("muzzle"))
					if GetConVar("cl_scav_high"):GetBool() then
						self.dlight = DynamicLight(0)
							self.dlight.Pos = self.Owner:GetShootPos()
							self.dlight.r = 110
							self.dlight.g = 200
							self.dlight.b = 75
							self.dlight.Brightness = .625
							self.dlight.Size = 512
							self.dlight.Decay = 250
							self.dlight.DieTime = CurTime() + 1.5
					end
				end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/vortigaunt.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/vortigaunt_slave.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/vortigaunt_blue.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/vortigaunt_doctor.mdl", 4)
		--HL:S
		ScavData.RegisterFiremode(tab, "models/islave.mdl", 4)
