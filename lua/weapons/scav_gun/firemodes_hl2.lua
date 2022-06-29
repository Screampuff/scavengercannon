--Firemodes largely related to the Half-Life series. Can have other games' props defined!

local eject = "brass"

/*==============================================================================================
	--Turret Gun
==============================================================================================*/
	
		local tab = {}
			tab.Name = "#scav.scavcan.turret"
			tab.Level = 4
			tab.anim = ACT_VM_RECOIL1
			tab.tracep = {}
			tab.tracep.mask = MASK_SHOT
			tab.tracep.mins = Vector(-32,-32,-32)
			tab.tracep.maxs = Vector(32,32,32)
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local tab = ScavData.models["models/combine_turrets/floor_turret.mdl"]
					tab.tracep.start = self.Owner:GetShootPos()+self:GetAimVector()*48
					tab.tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*20000
					tab.tracep.filter = self.Owner
					local tr = util.TraceHull(tab.tracep)
					local dir
					if tr.Entity:IsValid() then
						dir = (tr.Entity:GetPos()+tr.Entity:OBBCenter()-self.Owner:GetShootPos()):GetNormalized()
					else
						dir = self:GetAimVector()
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					local bullet = {}
						bullet.Num = 1
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = dir
						bullet.Spread = Vector(0.02,0.02,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 4
					if string.find(item.ammo,"models/buildables/sentry") then
						if SERVER then
							if item.ammo == "models/buildables/sentry1.mdl" then
								self.Owner:EmitSound("weapons/sentry_shoot.wav")
							else
								self.Owner:EmitSound("weapons/sentry_shoot2.wav")
							end
						end
						bullet.TracerName = "ef_scav_tr_b"
					elseif item.ammo == "models/sentry.mdl" then
						if SERVER then self.Owner:EmitSound("turret/tu_fire1.wav",75,160,1) end
						bullet.TracerName = "Tracer"
					else
						if SERVER then self.Owner:EmitSound("npc/turret_floor/shoot"..math.random(1,3)..".wav") end
						bullet.TracerName = "AR2Tracer"
					end
					self.Owner:FireBullets(bullet)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if CLIENT then
						self.Owner:ScavViewPunch(Angle(math.Rand(0,1),math.Rand(-1,1),0),0.5)
					else
						self:TakeSubammo(item,1)
					end
				end
				local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
				if !continuefiring and SERVER then
					self.ChargeAttack = nil
				end
				if item.ammo == "models/buildables/sentry1.mdl" then
					return 0.25
				else
					return 0.1
				end
			end
			tab.FireFunc = function(self,item)
				self.ChargeAttack = ScavData.models["models/combine_turrets/floor_turret.mdl"].ChargeAttack
				self.chargeitem = item							
				return false
			end
			tab.OnArmed = function(self,item,olditemname)
				if SERVER then
					local newitem = item
					if newitem.ammo != olditemname then
						if newitem.ammo == "models/props/turret_01.mdl" then
							self.Owner:EmitSound("npc/turret_floor/turret_deploy_"..math.random(1,6)..".wav")
						elseif string.find(newitem.ammo,"models/buildables/sentry") then
							self.Owner:EmitSound("weapons/sentry_spot_client.wav")
						elseif newitem.ammo == "models/sentry.mdl" then
							self.Owner:EmitSound("turret/tu_ping.wav")
						else
							self.Owner:EmitSound("npc/turret_floor/active.wav")
						end
					end
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,ent:GetSkin(),1) end
				--Portal
				ScavData.CollectFuncs["models/props/turret_01.mdl"] = ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"]
				--TF2
				ScavData.CollectFuncs["models/buildables/sentry1.mdl"] = ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"]
				ScavData.CollectFuncs["models/buildables/sentry1_heavy.mdl"] = function(self,ent) self:AddItem("models/buildables/sentry1.mdl",100,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/buildables/sentry2_heavy.mdl"] = function(self,ent) self:AddItem("models/buildables/sentry1.mdl",100,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/buildables/sentry2.mdl"] = ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"]
				ScavData.CollectFuncs["models/buildables/sentry3_heavy.mdl"] = function(self,ent) self:AddItem("models/buildables/sentry2.mdl",100,ent:GetSkin(),1) end
				--HLS
				ScavData.CollectFuncs["models/sentry.mdl"] = ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"]
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/combine_turrets/floor_turret.mdl")
		--Portal
		ScavData.RegisterFiremode(tab,"models/props/turret_01.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/buildables/sentry1.mdl")
		ScavData.RegisterFiremode(tab,"models/buildables/sentry2.mdl")
		--HLS
		ScavData.RegisterFiremode(tab,"models/sentry.mdl")
		
		
/*==============================================================================================
	--Strider Buster
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.magnusson"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 7
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("scav_projectile_mag")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj.Inflictor = proj
						proj.Attacker = self.Owner
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Up()*-1):Angle())
						proj:Spawn()
						proj:SetSkin(item.data)
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableGravity(true)
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*2500*self.dt.ForceScale) --self:GetAimVector():Angle():Up()*0.1
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(0,10000,0)) end)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)			
						return self:TakeSubammo(item,1)
				end
				ScavData.CollectFuncs["models/magnusson_teleporter.mdl"] = function(self,ent) self:AddItem("models/magnusson_device.mdl", SCAV_SHORT_MAX, ent:GetSkin()) end
				ScavData.CollectFuncs["models/magnusson_teleporter_off.mdl"] = ScavData.CollectFuncs["models/magnusson_teleporter.mdl"]
				ScavData.CollectFuncs["models/weapons/w_magnade.mdl"] = function(self,ent) self:AddItem("models/magnusson_device.mdl",1, ent:GetSkin()) end
			end
			tab.Cooldown = 1.5
		ScavData.RegisterFiremode(tab,"models/magnusson_device.mdl")
		ScavData.RegisterFiremode(tab,"models/props_outland/pumpkin01.mdl")
		ScavData.RegisterFiremode(tab,"models/magnusson_teleporter.mdl")
		
		
/*==============================================================================================
	--Bounding Mine
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.hopper"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("scav_bounding_mine")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self.Owner:GetShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Up()*-1):Angle())
						proj:Spawn()
						proj:SetSkin(item.data)				
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():SetMass(1)
						proj:GetPhysicsObject():EnableDrag(true)
						proj:GetPhysicsObject():EnableGravity(true)
						proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector()+Vector(0,0,0.1))*5000,Vector(0,0,3)) --self:GetAimVector():Angle():Up()*0.1
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(0,10000,0)) end)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						//gamemode.Call("ScavFired",self.Owner,proj)
						return true
					end
				ScavData.CollectFuncs["models/shield_scanner.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/props_combine/combine_mine01.mdl"),1,0,2) end
			end
			tab.Cooldown = 0.75
		ScavData.RegisterFiremode(tab,"models/props_combine/combine_mine01.mdl")
		
/*==============================================================================================
	--SMG1 Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.smg1nade"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 6
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("grenade_ar2")
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles((self:GetAimVector():Angle()))
						proj:Spawn()		
						proj:SetVelocity(self:GetAimVector()*1000)
						--TODO: figure out how to make the L4D2 grenade model usable without its own physics model (this makes it immediately collide with the firing player)
						--if item.ammo == "models/w_models/weapons/w_grenade_launcher.mdl" then
						--	proj:SetModel("models/Items/AR2_Grenade.mdl")
						--	proj:PhysicsInit(SOLID_VPHYSICS)
						--	proj:SetModel("models/w_models/weapons/w_he_grenade.mdl")
						--end
						if item.ammo == "models/weapons/p_garand_rg_grenade.mdl" or item.ammo == "models/weapons/w_garand_rg_grenade.mdl" then
							proj:SetModel("models/weapons/w_garand_rg_grenade.mdl")
							self.Owner:EmitSound("Weapon_Grenade.Shoot")
						elseif item.ammo == "models/weapons/p_k98_rg_grenade.mdl" or item.ammo == "models/weapons/w_k98_rg_grenade.mdl" then
							proj:SetModel("models/weapons/w_k98_rg_grenade.mdl")
							self.Owner:EmitSound("Weapon_Grenade.Shoot")
						else
							self.Owner:EmitSound("weapons/ar2/ar2_altfire.wav")
						end
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						//gamemode.Call("ScavFired",self.Owner,proj)					
						return true
					end
				ScavData.CollectFuncs["models/items/ammocrate_smg2.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/items/ar2_grenade.mdl"),1,0,3) end
				--DoD:S
				ScavData.CollectFuncs["models/weapons/w_garand_gren.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/weapons/w_garand_rg_grenade.mdl"),1,0,1) end
				ScavData.CollectFuncs["models/weapons/w_k98_rg.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/weapons/w_k98_rg_grenade.mdl"),1,0,1) end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/items/ar2_grenade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/ar2_grenade.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_grenade_launcher.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/weapons/p_garand_rg_grenade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/p_k98_rg_grenade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_garand_rg_grenade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_k98_rg_grenade.mdl")

/*==============================================================================================
	--Strider Cannon
==============================================================================================*/
		
	
		local tab = {}
			tab.Name = "#scav.scavcan.stridercannon"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			if SERVER then
				local tracep = {}
				tracep.mins = Vector(-4,-4,-4)
				tracep.maxs = Vector(4,4,4)
				
				function ScavData.PostDissolveDamage(ent,attacker,inflictor,impactpos)
					if !ent:IsValid() then
						return
					end
					local dmg = DamageInfo()
					dmg:SetDamage(1000)
					dmg:SetAttacker(attacker)
					dmg:SetInflictor(inflictor)
					dmg:SetDamageForce((impactpos-ent:GetPos()):GetNormalized()*5000)
					dmg:SetDamagePosition(impactpos)
					dmg:SetDamageType(DMG_DISSOLVE)
					//ent:DispatchTraceAttack(dmg,impactpos,ent:GetPos())
					ent:TakeDamageInfo(dmg)
					--[[
					if ent:IsPlayer() && ent:GetRagdollEntity() && ent:GetRagdollEntity():IsValid() then
						local dis = self:CreateEnt("env_entity_dissolver")
						dis:SetPos(impactpos)
						dis:SetKeyValue("magnitude",0)
						dis:SetKeyValue("dissolvetype",0)
						dis:SetEntity("target",ent)
						ent:GetRagdollEntity():SetKeyValue("targetname","willdissolve")
						dis:Fire("Dissolve","willdissolve",0)
						dis:Fire("Kill",1,"1")
					end
					]]
				end
				tab.ChargeAttack = function(self,item)
				
				
									tracep.start = self.Owner:GetShootPos()
									tracep.endpos = self.Owner:GetShootPos()+(self:GetAimVector()*10000)
									tracep.filter = self.Owner
									local tr = util.TraceHull(tracep)
									local tabents
									if tr.Hit && tr.Entity:IsValid() then
										local ent = tr.Entity
										if ent:GetPhysicsObject():IsValid() then
											local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone)
											phys:ApplyForceOffset(tr.Normal*90000,tr.HitPos)
										end
										local HP = ent:Health()
										local dmg = DamageInfo()
										dmg:SetDamage(350)
										dmg:SetAttacker(self.Owner)
										dmg:SetInflictor(self)
										dmg:SetDamageForce((tr.HitPos-ent:GetPos()):GetNormalized()*5000)
										dmg:SetDamagePosition(tr.HitPos)
										dmg:SetDamageType(bit.bor(DMG_BLAST,DMG_DISSOLVE))
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
									tabents = ents.FindInSphere(tr.HitPos,100)
									local expl = self:CreateEnt("scav_concussiveblast")
									expl:SetOwner(self.Owner)
									expl:SetPos(tr.HitPos)
									expl:Spawn()
									expl:Activate()
									self.Owner:EmitSound("npc/strider/fire.wav")
									util.ScreenShake(tr.HitPos,20,10,5,4000)
									self.ChargeAttack = nil
									self:SetPanelPose(0,2)
									self:SetBlockPose(0,2)
									self:SetBarrelRestSpeed(0)
										return 1
									end
				tab.FireFunc = function(self,item)
									self.ChargeAttack = ScavData.models["models/combine_strider.mdl"].ChargeAttack
									self.Owner:EmitSound("npc/strider/charging.wav")
									self.chargeitem = item
									local ef = EffectData()
									ef:SetEntity(self)
									ef:SetOrigin(self.Owner:GetShootPos())
									util.Effect("ef_scav_laser2",ef,true,true)
									self:SetPanelPose(1,1.5)
									self:SetBlockPose(1,1.5)
									self:SetBarrelRestSpeed(720)
									return true
								end

				ScavData.CollectFuncs["models/combine_strider.mdl"] = function(self,ent)
																	self:AddItem("models/gibs/strider_weapon.mdl",1,0,1) --strider cannon
																	self:AddItem("models/gibs/strider_head.mdl",100,0,1) --strider minigun
																end
				ScavData.CollectFuncs["models/combine_strider_vsdog.mdl"] = ScavData.CollectFuncs["models/combine_strider.mdl"]
			else
				tab.ChargeAttack = function(self,item)
										self.ChargeAttack = nil
										return 1
									end
				tab.FireFunc = function(self,item)
									self.chargeitem = item
									self.ChargeAttack = ScavData.models["models/combine_strider.mdl"].ChargeAttack									
									return true
								end
			end
			tab.Cooldown = 1.3
			
		ScavData.RegisterFiremode(tab,"models/combine_strider.mdl")
		--ScavData.RegisterFiremode(tab,"models/combine_strider_vsdog.mdl")
		ScavData.RegisterFiremode(tab,"models/gibs/strider_weapon.mdl")
		
/*==============================================================================================
	--Spit Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.acidspit"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			tab.models = {"models/spitball_large.mdl","models/spitball_medium.mdl","models/spitball_small.mdl"}
			if SERVER then
				tab.FireFunc = function(self,item)
					self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local pos = self:GetProjectileShootPos()
						for i=1,7 do
							local proj = self:CreateEnt("grenade_spit")
							proj.Owner = self.Owner
							proj:SetOwner(self.Owner)
							proj:SetPos(pos)
							//proj:SetAngles((self:GetAimVector():Angle():Right()):Angle())
							proj:Spawn()
							proj:SetModel(ScavData.models[item.ammo].models[math.random(1,3)])
							proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1)*1000)
						end
						self.Owner:EmitSound(self.shootsound)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						return self:TakeSubammo(item,1)
					end
				ScavData.CollectFuncs["models/antlion_worker.mdl"] = function(self,ent) self:AddItem("models/spitball_large.mdl",6,0,1) end --6 spit rounds from an antlion worker
				ScavData.CollectFuncs["models/spitball_large.mdl"] = ScavData.GiveOneOfItem
				ScavData.CollectFuncs["models/spitball_medium.mdl"] = ScavData.GiveOneOfItem
				ScavData.CollectFuncs["models/spitball_small.mdl"] = ScavData.GiveOneOfItem
				ScavData.CollectFuncs["models/gibs/antlion_worker_gibs_head.mdl"] = ScavData.CollectFuncs["models/antlion_worker.mdl"]
				else
					tab.FireFunc = function(self,item)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						--return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/spitball_large.mdl")
		ScavData.RegisterFiremode(tab,"models/spitball_medium.mdl")
		ScavData.RegisterFiremode(tab,"models/spitball_small.mdl")
		//ScavData.RegisterFiremode(tab,"models/gibs/antlion_worker_gibs_head.mdl")
		
/*==============================================================================================
	--bugbait
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#weapon_bugbait"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 1
			if SERVER then
				tab.antlionfriend =	function(ent) 
										if ent:IsValid() && (ent:GetClass() == "npc_antlion") then
											for k,v in ipairs(player.GetAll()) do
												if v:GetWeapon("scav_gun"):IsValid() then
													local hate = true
													for i,j in ipairs(v:GetWeapon("scav_gun").inv.items) do													
														if j.ammo == "models/weapons/w_bugbait.mdl" then
															ent:AddEntityRelationship(v,D_LI,999)
															//print(ent.." should like "..v.."...")
															hate = false
															break
														end
													end
													if hate then
														//print(ent.." should hate "..v.."...")
														ent:AddEntityRelationship(v,D_HT,99)
													end
												end
											end
										end
									end
				tab.allantlions = function() for l,m in ipairs(ents.FindByClass("npc_antlion")) do ScavData.models["models/weapons/w_bugbait.mdl"].antlionfriend(m) end end
				tab.PostRemove = tab.allantlions
				tab.FireFunc = function(self,item)
					self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("npc_grenade_bugbait")
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Right()):Angle())
						proj:Spawn()
						proj:SetVelocity((self:GetAimVector()+vector_up*0.1)*1000)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
					return false
				end
				ScavData.CollectFuncs["models/weapons/w_bugbait.mdl"] = function(self,ent) ScavData.GiveOneOfItemInf(self,ent) ScavData.models["models/weapons/w_bugbait.mdl"].allantlions() end
				hook.Add("OnEntityCreated","scav_bugbait",tab.antlionfriend)
				hook.Add("PlayerSpawn","scav_bugbait2",tab.allantlions)
				ScavData.CollectFuncs["models/antlion_guard.mdl"] = ScavData.CollectFuncs["models/weapons/w_bugbait.mdl"]
				--BUG TODO: doesn't currently make antlions friendly
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/weapons/w_bugbait.mdl")
		ScavData.RegisterFiremode(tab,"models/antlion_guard.mdl")
		

/*==============================================================================================
	--Gravity Gun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#weapon_physcannon"
			tab.Level = 7
			tab.anim = ACT_VM_RECOIL3
			tab.dmginfo = DamageInfo()
			tab.vmin = Vector(-8,-8,-8)
			tab.vmax = Vector(8,8,8)
			if SERVER then
				tab.FireFunc = function(self,item)
				
										local tr = self.Owner:GetEyeTraceNoCursor()
										local tab = ScavData.models[item.ammo]
										if !tr.Entity || !tr.Entity:IsValid() then
											local tracep = {}
												tracep.start = self.Owner:GetShootPos()
												tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*850
												tracep.filter = self.Owner
												tracep.mask = MASK_SHOT
												tracep.mins = tab.vmin
												tracep.maxs = tab.vmax
											self.Owner:LagCompensation(true)
											tr = util.TraceHull(tracep)
											self.Owner:LagCompensation(false)
										end
										if tr.Entity:IsValid() && tr.Entity:GetPhysicsObject():IsValid() && ((tr.HitPos-tr.StartPos):Length() < 250+600*item.data) then
											self.Owner:ViewPunch(Angle(-5,math.Rand(-5,5),0))
											local ef = EffectData()
											ef:SetStart(self.Owner:GetShootPos())
											ef:SetOrigin(tr.HitPos)
											ef:SetEntity(self)
											local dmg = tab.dmginfo
											if item.data == 0 then
												util.Effect("ef_scav_tr3",ef)
												tr.Entity:GetPhysicsObject():ApplyForceOffset(tr.Normal*200000,tr.HitPos)
												dmg:SetDamage(1)
												dmg:SetDamageForce(tr.Normal*200000)
												dmg:SetAttacker(self.Owner)
												dmg:SetInflictor(self)
												dmg:SetDamagePosition(tr.HitPos)
												dmg:SetDamageType(DMG_PHYSGUN)
												tr.Entity:TakeDamageInfo(dmg)
											else
												util.Effect("ef_scav_tr4",ef) --TO DO: Merge into ef_scav_tr3
												tr.Entity:GetPhysicsObject():ApplyForceOffset(tr.Normal*3000000,tr.HitPos)
												if tr.Entity:IsPlayer() then
													tr.Entity:SetVelocity(tr.Normal*3000)
												end
												dmg:SetDamage(75)
												dmg:SetDamageForce(tr.Normal*3000000)
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
				ScavData.CollectFuncs["models/weapons/w_physics.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/dog.mdl"] = ScavData.GiveOneOfItemInf
			else
				tab.FireFunc = function(self,item)
						local tr = self.Owner:GetEyeTraceNoCursor()
						local tab = ScavData.models[item.ammo]
							if !tr.Entity || !tr.Entity:IsValid() then
								local tracep = {}
									tracep.start = self.Owner:GetShootPos()
									tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*850
									tracep.filter = self.Owner
									tracep.mask = MASK_SHOT
									tracep.mins = tab.vmin
									tracep.maxs = tab.vmax
								tr = util.TraceHull(tracep)
							end
						
						if tr.Entity:IsValid() && tr.Entity:GetPhysicsObject() && ((tr.HitPos-tr.StartPos):Length() < 250+600*item.data) then
								local ef = EffectData()
								ef:SetStart(self.Owner:GetShootPos())
								ef:SetOrigin(tr.HitPos)
								ef:SetEntity(self)
								local dmg = tab.dmginfo
								if item.data == 0 then
									util.Effect("ef_scav_tr3",ef)

								else
									util.Effect("ef_scav_tr4",ef)
								end
						else
							self.Owner:EmitSound("weapons/physcannon/physcannon_dryfire.wav")
						end
					return false
				end
			end
			tab.Cooldown = 0.5
		ScavData.RegisterFiremode(tab,"models/weapons/w_physics.mdl")
		ScavData.RegisterFiremode(tab,"models/dog.mdl")
		
/*==============================================================================================
	--Frag Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#weapon_frag"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("npc_grenade_frag")
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Right()):Angle())
						proj:Spawn()
						proj:SetModel(item.ammo)
						proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector())*5000,Vector(0,0,3)) --+Vector(0,0,0.1)
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(-5000,5000,0)) end)
						proj:Fire("SetTimer",2,"0")
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						//gamemode.Call("ScavFired",self.Owner,proj)					
						return true
					end
				ScavData.CollectFuncs["models/items/ammocrate_grenade.mdl"] = function(self,ent) self:AddItem("models/weapons/w_grenade.mdl",1,0,5) end --5 frag grenades from a grenade crate
				ScavData.CollectFuncs["models/items/grenadeammo.mdl"] = function(self,ent) self:AddItem("models/weapons/w_grenade.mdl",1,0,1) end --convert to grenade w_model
				--Ep2
				ScavData.CollectFuncs["models/zombie/zombie_soldier.mdl"] = function(self,ent)
					self:AddItem("models/zombie/zombie_soldier_legs.mdl",1,0,1)
					self:AddItem("models/weapons/w_grenade.mdl",1,0,2)
					self:AddItem("models/zombie/zombie_soldier_torso.mdl",1,0,1)
					if tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
						self:AddItem("models/headcrabclassic.mdl",1,0,1)
					end
				end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/weapons/w_grenade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_npcnade.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/weapons/w_frag.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_stick.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_eq_pipebomb.mdl")





/*==============================================================================================
	--Helicopter Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.helinade"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("grenade_helicopter")
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj.Inflictor = proj
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Right()):Angle())
						proj:Spawn()
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*5000)
						proj:SetPhysicsAttacker(self.Owner)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)				
						return true
					end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/combine_helicopter/helicopter_bomb01.mdl")
		
/*==============================================================================================
	--Armor Battery
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#item_battery"
			tab.anim = ACT_VM_FIDGET
			tab.Level = 1
			if SERVER then
				tab.FireFunc = function(self,item)
									if self.Owner:Armor() >= self.Owner:GetMaxArmor() then
										self.Owner:EmitSound("buttons/button11.wav")
										return false
									end
									self.Owner:SetArmor(math.min(self.Owner:GetMaxArmor(),self.Owner:Armor()+15))
									if item.ammo == "models/pickups/pickup_powerup_defense.mdl" or
										item.ammo == "models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl" or
										item.ammo == "models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl" or
										item.ammo == "models/pickups/pickup_powerup_resistance.mdl" then
										self.Owner:SetArmor(math.min(self.Owner:GetMaxArmor(),self.Owner:Armor()+35)) --50 total armor for Defense Powerup
										self.Owner:EmitSound("items/powerup_pickup_reduced_damage.wav")
									end
									if item.ammo == "models/helmets/helmet_american.mdl" or
										item.ammo == "models/helmets/helmet_german.mdl" then
										self.Owner:SetArmor(math.min(self.Owner:GetMaxArmor(),self.Owner:Armor()+10)) --25 total armor for helmets
									end
									self.Owner:EmitSound("items/battery_pickup.wav")
									self.Owner:SendHUDOverlay(Color(0,100,255,100),0.25)
						return true
					end
				ScavData.CollectFuncs["models/player/american_assault.mdl"] = function(self,ent) self:AddItem("models/helmets/helmet_american.mdl",1,0,1) end
				ScavData.CollectFuncs["models/player/american_mg.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/american_rifleman.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/american_rocket.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/american_sniper.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/american_support.mdl"] = ScavData.CollectFuncs["models/player/american_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_assault.mdl"] = function(self,ent) self:AddItem("models/helmets/helmet_german.mdl",1,0,1) end
				ScavData.CollectFuncs["models/player/german_mg.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_rifleman.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_rocket.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_sniper.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
				ScavData.CollectFuncs["models/player/german_support.mdl"] = ScavData.CollectFuncs["models/player/german_assault.mdl"]
			end
			tab.Cooldown = 0.2
		ScavData.RegisterFiremode(tab,"models/items/battery.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_defense.mdl")
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_resistance.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/helmets/helmet_american.mdl")
		ScavData.RegisterFiremode(tab,"models/helmets/helmet_german.mdl")
		
/*==============================================================================================
	--Shotgun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#weapon_shotgun"
			//tab.anim = ACT_VM_RECOIL3
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 3

			local bullet = {}
				bullet.Num = 10
				bullet.Spread = Vector(0.075,0.03,0)
				bullet.Tracer = 1
				bullet.Force = 4
				bullet.Damage = 5
				bullet.TracerName = "ef_scav_tr_b"
			function tab.OnArmed(self,item,olditemname)
				if SERVER then
					if olditemname == "" or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
						if item.ammo == "models/weapons/shells/shell_shotgun.mdl" then
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(.25,function() self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end)
						elseif item.ammo == "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl" or
							item.ammo == "models/workshop_partner/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl" then
						elseif item.ammo == "models/shotgunshell.mdl" then
							self.Owner:EmitSound("weapons/scock1.wav")
						else
							self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
						end
					end
				end
			end
			tab.FireFunc = function(self,item)
				self.Owner:ScavViewPunch(Angle(-10,math.Rand(-0.1,0.1),0),0.3)
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self:GetAimVector()
				self.Owner:FireBullets(bullet)
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				if item.ammo == "models/weapons/shells/shell_shotgun.mdl" then --TF2
					if SERVER then
						if self.Owner:GetStatusEffect("DamageX") then
							self.Owner:EmitSound("weapons/shotgun_shoot_crit.wav") --crit sound
						else
							self.Owner:EmitSound("weapons/shotgun_shoot.wav")
						end
					end
					timer.Simple(0.4,function()
						if SERVER then
							self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
							timer.Simple(.25,function() self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end)
						else
							tf2shelleject(self,"shotgun")
						end
					end)
				else
					if item.ammo == "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl" or
					item.ammo == "models/workshop_partner/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl" then --Widowmaker
						if SERVER then self.Owner:EmitSound("weapons/widow_maker_shot_02.wav") end
					elseif item.ammo == "models/shotgunshell.mdl" then --HL1
						if SERVER then
							self.Owner:EmitSound("weapons/sbarrel1.wav")
						end
						timer.Simple(0.4,function()
							if SERVER then
								self.Owner:EmitSound("weapons/scock1.wav")
							else
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach == nil then
									attach = self:GetAttachment(self:LookupAttachment(eject))
								end
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									--lovingly borrowed from https://steamcommunity.com/sharedfiles/filedetails/?id=1360233031
									local angShellAngles = self.Owner:EyeAngles()
									local vecShellVelocity = self.Owner:GetAbsVelocity()
									vecShellVelocity = vecShellVelocity + angShellAngles:Right() * math.Rand( 50, 70 );
									vecShellVelocity = vecShellVelocity + angShellAngles:Up() * math.Rand( 100, 150 );
									vecShellVelocity = vecShellVelocity + angShellAngles:Forward() * 25;
									ef:SetStart(vecShellVelocity)
									ef:SetEntity(self.Owner)
									ef:SetFlags(1) --shotgun shell
									util.Effect("HL1ShellEject",ef)
								end
							end
						end)
					else --HL2
						if SERVER then
							self.Owner:EmitSound("weapons/shotgun/shotgun_fire6.wav")
						end
						timer.Simple(0.4,function()
							if SERVER then
								self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
							else
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									util.Effect("ShotgunShellEject",ef)
								end
							end
						end)
					end
				end
				if SERVER then return self:TakeSubammo(item,1) end
			end
			if SERVER then		
				ScavData.CollectFuncs["models/items/boxbuckshot.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell.mdl",20,0,1) end --20 shotgun shells from a box of shells
				ScavData.CollectFuncs["models/weapons/w_shotgun.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell.mdl",6,0,1) end --6 shotgun shells from a shotgun
				ScavData.CollectFuncs["models/scav/shells/shell_shotgun_tf2.mdl"] = function(self,ent) self:AddItem("models/weapons/shells/shell_shotgun.mdl",1,0,1) end --convert Scav TF2 shell
				--Ep2
				ScavData.CollectFuncs["models/items/ammocrate_buckshot.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell.mdl",6,0,5) end --5 x 6 shotgun shells from a shotgun crate
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] = function(self,ent) self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0,1) end --6 shotgun shells from a shotgun (TF2)
				ScavData.CollectFuncs["models/weapons/c_models/c_shotgun/c_shotgun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] --6 shotgun shells from a shotgun(TF2)
				ScavData.CollectFuncs["models/weapons/c_models/c_scattergun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] --6 shotgun shells from a shotgun(TF2)
				ScavData.CollectFuncs["models/weapons/w_models/w_scattergun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] --6 shotgun shells from a shotgun(TF2)
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] --6 shotgun shells from a Panic Attack
				ScavData.CollectFuncs["models/weapons/c_models/c_double_barrel.mdl"] = function(self,ent) self:AddItem("models/weapons/shells/shell_shotgun.mdl",2,0,1) end --2 shotgun shells from the FaN
				ScavData.CollectFuncs["models/weapons/c_models/c_xms_double_barrel.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_double_barrel.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_soda_popper/c_soda_popper.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_double_barrel.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_soda_popper/c_soda_popper.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_soda_popper/c_soda_popper.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_pep_scattergun.mdl"] = function(self,ent) self:AddItem("models/weapons/shells/shell_shotgun.mdl",4,0,1) end --4 shotgun shells from the BFB
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_pep_scattergun/c_pep_scattergun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_pep_scattergun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_pep_scattergun.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_russian_riot/c_russian_riot.mdl"] = function(self,ent) self:AddItem("models/weapons/shells/shell_shotgun.mdl",8,0,1) end --8 shotgun shells from the Family Business
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_russian_riot/c_russian_riot.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_russian_riot/c_russian_riot.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_shortstop/c_shortstop.mdl"] = function(self,ent) self:AddItem("models/weapons/shells/shell_shotgun.mdl",4,0,1) end --4 shotgun shells from the Shortstop
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_shortstop/c_shortstop.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_shortstop/c_shortstop.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_scatterdrum/c_scatterdrum.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_shortstop/c_shortstop.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl"] = function(self,ent) self:AddItem("models/weapons/shells/shell_shotgun.mdl",3,0,1) end --3 shotgun shells from the Frontier Justice
				ScavData.CollectFuncs["models/weapons/c_models/c_frontierjustice/c_frontierjustice_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl"]
				ScavData.CollectFuncs["models/weapons/w_models/w_frontierjustice.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_frontierjustice/c_frontierjustice.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl"] = ScavData.GiveOneOfItemInf --infinite shotgun shells from a Widowmaker
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl"]
				--L4D/2
				ScavData.CollectFuncs["models/w_models/weapons/w_pumpshotgun_a.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell.mdl",8,0,1) end --8 shotgun shells from a L4D pump shotgun
				ScavData.CollectFuncs["models/w_models/weapons/w_shotgun.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell.mdl",8,0,1) end --8 shotgun shells from a L4D pump shotgun
				--FoF
				ScavData.CollectFuncs["models/weapons/w_sawed_shotgun.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell2.mdl",2,0,1) end --2 shotgun shells from a sawed off
				ScavData.CollectFuncs["models/weapons/w_sawed_shotgun2.mdl"] = ScavData.CollectFuncs["models/weapons/w_sawed_shotgun.mdl"]
				ScavData.CollectFuncs["models/weapons/w_coachgun.mdl"] = ScavData.CollectFuncs["models/weapons/w_sawed_shotgun.mdl"]
				ScavData.CollectFuncs["models/weapons/w_ghostgun.mdl"] = ScavData.CollectFuncs["models/weapons/w_sawed_shotgun.mdl"]
				ScavData.CollectFuncs["models/weapons/w_ghostgun2.mdl"] = ScavData.CollectFuncs["models/weapons/w_ghostgun.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/weapons/shotgun_shell.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/shells/shell_shotgun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/weapons/shotgun_shell2.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab,"models/shotgunshell.mdl")
		
/*==============================================================================================
	--Pistol
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.pistol"
			//tab.anim = ACT_VM_RECOIL3
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 3
			tab.bullet = {}
				tab.bullet.Num = 1
				tab.bullet.Spread = Vector(0.03,0.03,0)
				tab.bullet.Tracer = 1
				tab.bullet.Force = 0
				tab.bullet.Damage = 5
				tab.bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
				local tab = ScavData.models[self.inv.items[1].ammo]
				self.Owner:ScavViewPunch(Angle(math.Rand(-1,1),math.Rand(-1,1),0),0.5)
				tab.bullet.Src = self.Owner:GetShootPos()
				tab.bullet.Dir = self:GetAimVector()

				self.Owner:FireBullets(tab.bullet)
				if SERVER then self.Owner:SetAnimation(PLAYER_ATTACK1) end
				self:MuzzleFlash2()
				if item.ammo == "models/items/boxsrounds.mdl" or item.ammo == "models/weapons/w_pistol.mdl" then
					if SERVER then
						self.Owner:EmitSound("Weapon_Pistol.Single")
					else
						timer.Simple(.025,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								util.Effect("ShellEject",ef)
							end
						end)
					end
				elseif item.ammo == "models/w_9mmhandgun.mdl" then --HL:S
					if SERVER then
						self.Owner:EmitSound("weapons/pl_gun3.wav")
					else
						timer.Simple(.025,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach == nil then
								attach = self:GetAttachment(self:LookupAttachment(eject))
							end
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								--lovingly borrowed from https://steamcommunity.com/sharedfiles/filedetails/?id=1360233031
								local angShellAngles = self.Owner:EyeAngles()
								local vecShellVelocity = self.Owner:GetAbsVelocity()
								vecShellVelocity = vecShellVelocity + angShellAngles:Right() * math.Rand( 50, 70 );
								vecShellVelocity = vecShellVelocity + angShellAngles:Up() * math.Rand( 100, 150 );
								vecShellVelocity = vecShellVelocity + angShellAngles:Forward() * 25;
								ef:SetStart(vecShellVelocity)
								ef:SetEntity(self.Owner)
								ef:SetFlags(0) --pistol shell
								util.Effect("HL1ShellEject",ef)
							end
						end)
					end
				else --TF2
					if SERVER then
						if self.Owner:GetStatusEffect("DamageX") then
							self.Owner:EmitSound("weapons/pistol_shoot_crit.wav",75,100) --crit sound
						else
							self.Owner:EmitSound("weapons/pistol_shoot.wav",75,100)
						end
					else
						timer.Simple(.025,function() 
							tf2shelleject(self)
						end)
					end
				end
				self.nextfireearly = CurTime()+0.1
				if SERVER then return self:TakeSubammo(item,1) end
			end
			function tab.OnArmed(self,item,olditemname)
				if SERVER then
					if olditemname == "" or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
						self.Owner:EmitSound("physics/metal/weapon_impact_soft3.wav") --TODO: nice slide sound
					end
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/items/boxsrounds.mdl"] = function(self,ent) self:AddItem("models/items/boxsrounds.mdl",20,0) end --20 pistol rounds from a box of bullets
				ScavData.CollectFuncs["models/weapons/w_pistol.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),18,0) end --18 pistol rounds from a HL2 pistol
				--Ep2
				ScavData.CollectFuncs["models/items/ammocrate_pistol.mdl"] = function(self,ent) self:AddItem("models/weapons/w_pistol.mdl",18,0,8) end --8 x 18 pistol rounds from a pistol crate
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_pistol.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),12,ent:GetSkin()) end --12 pistol rounds from a TF2 pistol
				ScavData.CollectFuncs["models/weapons/c_models/c_pistol.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_pistol.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_ttg_max_gun/c_ttg_max_gun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_pistol.mdl"]
				ScavData.CollectFuncs["models/weapons/w_models/w_ttg_max_gun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_ttg_max_gun/c_ttg_max_gun.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_ttg_max_gun/c_ttg_max_gun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_ttg_max_gun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_pistol/c_pistol.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_pistol.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_winger_pistol/c_winger_pistol.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,ent:GetSkin()) end --5 pistol rounds from a Winger
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_winger_pistol/c_winger_pistol.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_winger_pistol/c_winger_pistol.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),9,ent:GetSkin()) end --9 pistol rounds from a Pretty Boy's Pocket Pistol
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl"]
				--HLS
				ScavData.CollectFuncs["models/hl1bar.mdl"] = function(self,ent) self:AddItem("models/w_9mmhandgun.mdl",17,0) end --17 pistol rounds from a HL1 pistol
				--FoF
				ScavData.CollectFuncs["models/weapons/w_deringer.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),2,0,1) end --2 pistol rounds from the Deringer
				ScavData.CollectFuncs["models/weapons/w_deringer2.mdl"] = ScavData.CollectFuncs["models/weapons/w_deringer.mdl"]
			end
			tab.Cooldown = 0.4
		ScavData.RegisterFiremode(tab,"models/items/boxsrounds.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_pistol.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_pistol.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_pistol.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_pistol/c_pistol.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_ttg_max_gun/c_ttg_max_gun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_ttg_max_gun.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_ttg_max_gun/c_ttg_max_gun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_winger_pistol/c_winger_pistol.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_winger_pistol/c_winger_pistol.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_pep_pistol/c_pep_pistol.mdl")
		--HLS
		ScavData.RegisterFiremode(tab,"models/w_9mmhandgun.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/weapons/w_deringer.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_deringer2.mdl")
		
/*==============================================================================================
	--pulse rifle
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#weapon_ar2"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 3
			tab.Callback = function(attacker,tr,dmg)
				local ef = EffectData()
				ef:SetOrigin(tr.HitPos)
				ef:SetNormal(tr.HitNormal)
				util.Effect("AR2Impact",ef)
			end
			tab.ChargeAttack = function(self,item)
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
							scale1 = 1+math.Clamp((CurTime()-self.mousepressed),0,3)
						end
						if CLIENT then self.Owner:ScavViewPunch(Angle(math.Rand(0,-1*scale1),math.Rand(-1*scale1,1*scale1),0),0.5) end
						bullet.Spread = Vector(0.02*scale1,0.02*scale1,0)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:FireBullets(bullet)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:MuzzleFlash2(2)
					if SERVER then
						self.Owner:EmitSound("Weapon_AR2.Single")
						self:AddBarrelSpin(500)
						self:SetPanelPose(math.Min(.5,math.Max(0,scale1-1.5)),scale1/2)
						timer.Simple(tab.Cooldown,function() self:SetPanelPose(0,scale1/4) end)
						self:TakeSubammo(item,1)
					end
				end
				local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
				if !continuefiring then
					if SERVER then
						self.ChargeAttack = nil
					end
				end
				return 0.1
			end
			tab.FireFunc = function(self,item)
				self.ChargeAttack = ScavData.models["models/weapons/w_irifle.mdl"].ChargeAttack
				self.chargeitem = item							
				return false
			end
			function tab.OnArmed(self,item,olditemname)
				if SERVER then
					--if item.ammo == "models/weapons/w_irifle.mdl" then
						self.Owner:EmitSound("weapons/ar2/ar2_reload_push.wav")
					--end
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/items/ammocrate_ar2.mdl"] = function(self,ent) self:AddItem("models/items/combine_rifle_cartridge01.mdl",30,0,3) end
				ScavData.CollectFuncs["models/items/combine_rifle_cartridge01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end				
				ScavData.CollectFuncs["models/weapons/w_irifle.mdl"] = ScavData.CollectFuncs["models/items/combine_rifle_cartridge01.mdl"]
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/items/combine_rifle_cartridge01.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_irifle.mdl")
		
/*==============================================================================================
	--Strider Minigun
==============================================================================================*/
		local tab = {}
			tab.Name = "#scav.scavcan.stridergun"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 7
			tab.Callback = function(attacker,tr,dmg)
				local ef = EffectData()
				ef:SetOrigin(tr.HitPos)
				ef:SetNormal(tr.HitNormal)
				//ef:SetScale(1)
				//ef:SetMagnitude(10)
				//util.Effect("HelicopterImpact",ef)
				util.Effect("AR2Impact",ef)
			end
			local bullet = {}
				bullet.Num = 1
				bullet.Tracer = 1
				bullet.Force = 20
				bullet.Damage = 30
				bullet.TracerName = "ef_scav_tr_strider"
				bullet.Callback = tab.Callback
			local ef = EffectData()
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local scale1 = 1
					if self.mousepressed then
						scale1 = 4-math.Clamp((CurTime()-self.mousepressed),0,3)
					end
					if CLIENT then
						self.Owner:ScavViewPunch(Angle(math.Rand(0,-1*scale1),math.Rand(-1*scale1,1*scale1),0),0.5)
					end
					bullet.Spread = Vector(0.02*scale1,0.02*scale1,0)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					self.Owner:FireBullets(bullet)
					ef:SetEntity(self)
					if CLIENT and self.Owner == GetViewEntity() then
						ef:SetEntity(self.Owner:GetViewModel())
						ef:SetOrigin(self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos)
					else
						ef:SetOrigin(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
					end
					ef:SetNormal(bullet.Dir)
					ef:SetScale(0.25)
					util.Effect("StriderMuzzleFlash",ef)
					if SERVER then
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound("NPC_Strider.FireMinigun")
						self:TakeSubammo(item,1)
					end
				end
				local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
				if !continuefiring and SERVER then
					self.ChargeAttack = nil
				end
				return 0.2
			end
			tab.FireFunc = function(self,item)
				self.ChargeAttack = ScavData.models["models/gibs/strider_head.mdl"].ChargeAttack
				self.chargeitem = item							
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/gibs/strider_head.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,0,1) end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/gibs/strider_head.mdl")
		
/*==============================================================================================
	--Airboat Gun
==============================================================================================*/

		if SERVER then util.AddNetworkString("scv_setsubammo") end

		local tab = {}
			tab.Name = "#func_tankairboatgun"
			tab.anim = ACT_VM_IDLE
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 9
			local returnval = {false,true}
			local function rechargeairboatgun(self,item)
				if item:IsValid() then
					if !item.isfiring then
						if item:GetSubammo() < 100 then
							if SERVER then
								item:SetSubammo(math.min(item:GetSubammo()+1,100))
								net.Start("scv_setsubammo")
									net.WriteEntity(self)
									net.WriteInt(item.subammo,16)
									net.WriteInt(item.pos,8)
								net.Send(self.Owner)
							end
						end
					end
					timer.Simple(0.05, function() rechargeairboatgun(self,item) end)
				end
			end
			tab.Callback = function(attacker,tr,dmg)
									dmg:SetDamageType(bit.bor(DMG_NEVERGIB,DMG_AIRBOAT))
									local ef = EffectData()
									ef:SetOrigin(tr.HitPos)
									ef:SetNormal(tr.HitNormal)
									util.Effect("AR2Impact",ef)
									util.Effect("MetalSpark",ef)
									if SERVER then
										tr.Entity:TakeDamageInfo(dmg)
									end
									return returnval
								end
			tab.OnPickup = function(self,item)
									timer.Simple(0.05, function() rechargeairboatgun(self,item) end)
								end
			
			tab.ChargeAttack = function(self,item)
								local bullet = {}
									bullet.Num = 3
									bullet.Spread = Vector(0.01,0.01,0)
									bullet.Tracer = 3
									bullet.Force = 5
									bullet.Damage = GetConVar("sk_plr_dmg_airboat"):GetFloat()
									bullet.TracerName = "AirboatGunTracer"
									bullet.Callback = tab.Callback
									bullet.DamageType = bit.bor(DMG_NEVERGIB,DMG_AIRBOAT)
								if item.subammo <= 0 then
									self.ChargeAttack = nil
									if SERVER then self.soundloops.airboatgunfire:Stop() end
									item.isfiring = false
									self.Owner:EmitSound("weapons/airboat/airboat_gun_lastshot"..math.random(1,2)..".wav")
									return 0
								end
								if !self.Owner:KeyDown(IN_ATTACK) then
									self.ChargeAttack = nil
									if SERVER then self.soundloops.airboatgunfire:Stop() end
									item.isfiring = false
									self.Owner:EmitSound("weapons/airboat/airboat_gun_lastshot"..math.random(1,2)..".wav")
								end
									bullet.Src = self.Owner:GetShootPos()
									bullet.Dir = self:GetAimVector()
									self.Owner:FireBullets(bullet)
									self.Owner:SetAnimation(PLAYER_ATTACK1)
									self:MuzzleFlash2(2)
									if SERVER then self:TakeSubammo(item,1) end
								return 0.05
			end

			tab.FireFunc = function(self,item)
				if (item.subammo > 0 and SERVER) or (item.subammo > -1 and CLIENT) then
					item.isfiring = true
					if SERVER then
						self.soundloops.airboatgunfire = CreateSound(self.Owner,"weapons/airboat/airboat_gun_loop2.wav")
						self.soundloops.airboatgunfire:Play()
					end
					self.chargeitem = item
					self.ChargeAttack = ScavData.models["models/airboatgun.mdl"].ChargeAttack
				end
				return false
			end
			if SERVER then	
				ScavData.CollectFuncs["models/airboat.mdl"] = function(self,ent) self:AddItem("models/airboatgun.mdl",100,0,1) end
				ScavData.CollectFuncs["models/props_combine/bunker_gun01.mdl"] = function(self,ent) self:AddItem("models/props_combine/bunker_gun01.mdl",100,0,1) end
				--HLDM:S
				ScavData.CollectFuncs["models/mp/turret.mdl"] = function(self,ent) self:AddItem("models/mp/turret.mdl",100,0,1) end
			end
			tab.Cooldown = 0.05
		ScavData.RegisterFiremode(tab,"models/airboatgun.mdl")
		ScavData.RegisterFiremode(tab,"models/props_combine/bunker_gun01.mdl")
		ScavData.RegisterFiremode(tab,"models/gunship.mdl")
		ScavData.RegisterFiremode(tab,"models/gibs/gunship_gibs_nosegun.mdl")
		--HLDM:S
		ScavData.RegisterFiremode(tab,"models/mp/turret.mdl")
/*==============================================================================================
	--Combine Ball
==============================================================================================*/
	
		local tab = {}
			tab.Name = "#scav.scavcan.pulseorb"
			tab.anim = ACT_VM_FIDGET
			tab.Level = 4
			tab.chargeanim = ACT_VM_SECONDARYATTACK
			if SERVER then
				tab.ChargeAttack = function(self,item)
										self.soundloops.cballcharge:Stop()
										local proj = self:CreateEnt("scav_projectile_comball")
										proj.Owner = self.Owner
										//proj:SetModel("models/items/combine_rifle_ammo01.mdl")
										proj:SetPos(self:GetProjectileShootPos())
										proj:SetAngles(self:GetAimVector():Angle())
										proj:SetOwner(self.Owner)
										proj:Spawn()
										self.Owner:SetAnimation(PLAYER_ATTACK1)
										proj:GetPhysicsObject():Wake()
										proj:GetPhysicsObject():EnableDrag(false)
										proj:GetPhysicsObject():EnableGravity(false)
										proj:GetPhysicsObject():SetVelocity((self:GetAimVector())*2500)
										proj:GetPhysicsObject():SetBuoyancyRatio(0)
										self.Owner:ViewPunch(Angle(math.Rand(-2,0),math.Rand(-0.1,0.1),0))
										self.Owner:EmitSound("weapons/Irifle/irifle_fire2.wav")
										self.ChargeAttack = nil
										//self:RemoveItem(1)
										return 0.5
									end
				tab.FireFunc = function(self,item)
									self.ChargeAttack = ScavData.models["models/items/combine_rifle_ammo01.mdl"].ChargeAttack
									self.soundloops.cballcharge = CreateSound(self.Owner,"weapons/cguard/charging.wav")
									self.soundloops.cballcharge:Play()
									self:SetPanelPose(1,1.5)
									timer.Simple(0.5,function() self:SetPanelPose(0,10) end)
									self.chargeitem = item
									return true
								end
				ScavData.CollectFuncs["models/effects/combineball.mdl"] = function(self,ent) self:AddItem("models/items/combine_rifle_ammo01.mdl",1,0) end
			else
				tab.ChargeAttack = function(self,item)
										self.ChargeAttack = nil
										//self:RemoveItem(1)
										return 0.5
									end
				tab.FireFunc = function(self,item)
									self.ChargeAttack = ScavData.models["models/items/combine_rifle_ammo01.mdl"].ChargeAttack
									self.chargeitem = item
									return true
								end
			end
			function tab.OnArmed(self,item,olditemname)
				if SERVER then
					--if item.ammo == "models/items/combine_rifle_ammo01.mdl" then
						self.Owner:EmitSound("weapons/ar2/ar2_reload_rotate.wav")
					--end
				end
			end
			tab.Cooldown = 0.5
			
		ScavData.RegisterFiremode(tab,"models/items/combine_rifle_ammo01.mdl")
		--Portal
		ScavData.RegisterFiremode(tab,"models/props/combine_ball_launcher.mdl")

/*==============================================================================================
	--Helicopter Minigun
==============================================================================================*/
	
		local tab = {}
			tab.Name = "#scav.scavcan.heligun"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 8
			if SERVER then
				tab.ChargeAttack = function(self,item)
										self.Owner.scav_helisound:Play()
										local bullet = {}
											bullet.Num = 5
											bullet.Src = self.Owner:GetShootPos()
											bullet.Dir = self:GetAimVector()
											bullet.Spread = Vector(0.1,0.1,0)
											bullet.Tracer = 1
											bullet.Force = 5
											bullet.Damage = 6
											bullet.TracerName = "HelicopterTracer"
											bullet.Callback = ScavData.models[self.chargeitem.ammo].Callback
										self.Owner:FireBullets(bullet)
										self.Owner:SetAnimation(PLAYER_ATTACK1)
										self:MuzzleFlash2("ChopperMuzzleFlash")
										self.Owner:GetPhysicsObject(wake)
										self.Owner:SetVelocity(self:GetAimVector()*-70)
									//	self.Owner:EmitToAllButSelf("Weapon_AR2.Single")
										self:TakeSubammo(item,1)
										if self.chargeitem.subammo <= 0 then
											self.Owner.scav_helisound:Stop()
											self.ChargeAttack = nil
											if item.subammo <= 0 then
												self:RemoveItemValue(item)
											end
											self:SetPanelPose(0,1)
											self:SetBlockPose(0,1)
											self:SetBarrelRestSpeed(0)
											return 0.5
										end
										return 0.1
									end
				tab.FireFunc = function(self,item)
									self.ChargeAttack = ScavData.models["models/combine_helicopter.mdl"].ChargeAttack
									self.Owner:EmitSound("npc/attack_helicopter/aheli_charge_up.wav")
									self.chargeitem = item
									self.Owner.scav_helisound = CreateSound(self.Owner,"npc/attack_helicopter/aheli_weapon_fire_loop3.wav")
									self:SetPanelPose(1,1)
									self:SetBlockPose(1,1)
									self:SetBarrelRestSpeed(900)
									//return true
								end
				ScavData.CollectFuncs["models/combine_helicopter.mdl"] = function(self,ent) self:AddItem("models/combine_helicopter.mdl",100,0) end
			else
				tab.ChargeAttack = function(self,item)
										local bullet = {}
											bullet.Num = 5
											bullet.Src = self.Owner:GetShootPos()
											bullet.Dir = self:GetAimVector()
											bullet.Spread = Vector(0.1,0.1,0)
											bullet.Tracer = 1
											bullet.Force = 5
											bullet.Damage = 6
											bullet.TracerName = "HelicopterTracer"
											bullet.Callback = ScavData.models[self.chargeitem.ammo].Callback
										self.Owner:FireBullets(bullet)
										self.Owner:SetAnimation(PLAYER_ATTACK1)
										self:MuzzleFlash2("ChopperMuzzleFlash")
										//self.Owner:EmitSound("Weapon_AR2.Single")
										if SERVER then self:TakeSubammo(item,1) end
										if self.chargeitem.subammo <= 0 then
											self.ChargeAttack = nil
											return 0.5
										end
										return 0.1
									end
				tab.FireFunc = function(self,item)
									self.chargeitem = item
									self.ChargeAttack = ScavData.models["models/combine_helicopter.mdl"].ChargeAttack						
									//return true
								end
			end
			tab.Cooldown = 2
			
		ScavData.RegisterFiremode(tab,"models/combine_helicopter.mdl")

		
/*==============================================================================================
	-- Health Charger
==============================================================================================*/

		local tab = {}
			tab.Name = "#item_healthcharger"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.vmin = Vector(-12,-12,-12)
			tab.vmax = Vector(12,12,12)
			tab.Cooldown = .1
			tab.StopBeep = false
			local nextBeep = CurTime()
			local fullBeep = function(self,item)
				if self.StopBeep then return end
				if self.Owner:KeyDown(IN_ATTACK) and nextBeep <= CurTime() then
					self.Owner:EmitSound("items/medshotno1.wav",75,100,1)
					if SERVER then self.soundloops.healthCharger:Stop() end
					nextBeep = CurTime() + 1
				end
			end

			tab.ChargeAttack = function(self,item)
				local target = self.Owner
					local tracep = {}
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*100
					tracep.filter = self.Owner
					tracep.mask = MASK_SHOT
					tracep.mins = tab.vmin
					tracep.maxs = tab.vmax
					local tr = util.TraceHull(tracep)
					if (tr.Entity:IsPlayer() || tr.Entity:IsNPC()) && (tr.Entity:Health() < tr.Entity:GetMaxHealth()) then
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
					util.Effect("ef_scav_heal",ef,nil,true)

					--restart healing sound, in case we were holding down attack and got a valid healing target (either by looking around or our current one getting hurt)
					self.StopBeep = true
					if SERVER and not IsValid(self.soundloops.healthCharger) then
						self.soundloops.healthCharger = CreateSound(self.Owner,"items/medcharge4.wav")
						self.soundloops.healthCharger:Play()
					end
					target:SetHealth(math.min(target:GetMaxHealth(),target:Health()+1))
					if SERVER then self:TakeSubammo(item,1) end
				elseif SERVER then --our target is full health, switch over to beep loop
					self.StopBeep = false
					fullBeep(self,item)
					self.soundloops.healthCharger:Stop()
				end
				local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
				if !continuefiring then
					if SERVER then
						self.soundloops.healthCharger:Stop()
						self.StopBeep = true
						self.ChargeAttack = nil
						self:SetBarrelRestSpeed(0)
					else
						--hook.Remove( "RenderScreenspaceEffects", "ScavHealthCharger")
						fullBeep(self,item)
					end

					return 0.05
				else
					if SERVER and target:GetMaxHealth() > target:Health() then self.soundloops.healthCharger:Play() end
					return 0.1
				end
			end
			tab.FireFunc = function(self,item)
				self.ChargeAttack = ScavData.models["models/props_combine/health_charger001.mdl"].ChargeAttack
				self.chargeitem = item
				if SERVER then
					self.Owner:EmitSound("player/suit_denydevice.wav")
					if not IsValid(self.soundloops.healthCharger) then self.soundloops.healthCharger = CreateSound(self.Owner,"items/medcharge4.wav") end
					self:SetBarrelRestSpeed(400)
				else
					timer.Simple(1,function()
						if self:ProcessLinking(item) && self:StopChargeOnRelease() then --make sure the player didn't cancel the charge before we even got to it
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
			if SERVER then
				ScavData.CollectFuncs["models/props_combine/health_charger001.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),math.Round(GetConVar("sk_healthcharger"):GetFloat()) or 50,ent:GetSkin()) end --(default 50) health for chargers
			end
		
		ScavData.RegisterFiremode(tab,"models/props_combine/health_charger001.mdl")



/*==============================================================================================
	-- Suit Charger
==============================================================================================*/

		local tab = {}
			tab.Name = "#item_suitcharger"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.Cooldown = .1
			tab.StopBeep = false
			local nextBeep = CurTime()
			local fullBeep = function(self,item)
				if self.StopBeep then return end
				if self.Owner:KeyDown(IN_ATTACK) and nextBeep <= CurTime() then
					self.Owner:EmitSound("items/suitchargeno1.wav",75,100,1)
					if SERVER then self.soundloops.suitCharger:Stop() end
					nextBeep = CurTime() + 1
				end
			end

			tab.ChargeAttack = function(self,item)
				local target = self.Owner
					local tracep = {}
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*100
					tracep.filter = self.Owner
					tracep.mask = MASK_SHOT
					tracep.mins = Vector(-12,-12,-12)
					tracep.maxs = Vector(12,12,12)
					local tr = util.TraceHull(tracep)
					if tr.Entity:IsPlayer() && (tr.Entity:Armor() < tr.Entity:GetMaxArmor()) then
						target = tr.Entity
					end
				if target:GetMaxArmor() > target:Armor() then
					local att = self:LookupAttachment("muzzle")
					local posang = self:GetAttachment(att)

					/*local ef = EffectData() --TODO: Suit charge effect
						ef:SetEntity(target)
						ef:SetRadius(1)
						ef:SetOrigin(self.Owner:GetPos())
						ef:SetNormal(posang.Ang:Forward())
						ef:SetStart(posang.Pos)
						ef:SetScale(self.Owner:EntIndex())
						ef:SetAttachment(att)
					util.Effect("ef_scav_heal",ef,nil,true)*/

					--restart charge sound, in case we were holding down attack and got a valid charge target (either by looking around or our current one getting damaged)
					self.StopBeep = true
					if SERVER and not IsValid(self.soundloops.suitCharger) then
						self.soundloops.suitCharger = CreateSound(self.Owner,"items/suitcharge1.wav")
						self.soundloops.suitCharger:Play()
					end
					if SERVER then
						target:SetArmor(math.min(target:GetMaxArmor(),target:Armor()+1))
						self:TakeSubammo(item,1)
					end
				elseif SERVER then --our target is full armor, switch over to beep loop
					self.StopBeep = false
					fullBeep(self,item)
					self.soundloops.suitCharger:Stop()
				end
				local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
				if !continuefiring then
					if SERVER then
						self.soundloops.suitCharger:Stop()
						self.StopBeep = true
						self.ChargeAttack = nil
						self:SetBarrelRestSpeed(0)
					else
						hook.Remove( "RenderScreenspaceEffects", "ScavSuitCharger")
						fullBeep(self,item)
					end

					return 0.05
				else
					if SERVER and target:GetMaxArmor() > target:Armor() then self.soundloops.suitCharger:Play() end
					return 0.1
				end
			end
			tab.FireFunc = function(self,item)
				self.ChargeAttack = ScavData.models["models/props_combine/suit_charger001.mdl"].ChargeAttack
				self.chargeitem = item
				if SERVER then
					self.Owner:EmitSound("player/suit_denydevice.wav")
					if not IsValid(self.soundloops.suitCharger) then self.soundloops.suitCharger = CreateSound(self.Owner,"items/suitcharge1.wav") end
					self:SetBarrelRestSpeed(400)
				/*else --not worth it
						if not self.StopBeep then
							hook.Add( "RenderScreenspaceEffects", "ScavSuitCharger", function()
								surface.SetDrawColor(0,100,255,100*math.sin(CurTime()))
								surface.DrawRect(0,0,ScrW(),ScrH())
							end )
						else
							self.StopBeep = true
						end*/
				end
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_combine/suit_charger001.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),math.Round(GetConVar("sk_suitcharger"):GetFloat()) or 75,ent:GetSkin()) end --(default 75) battery for chargers
				ScavData.CollectFuncs["models/props_lab/hevplate.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),math.Round(GetConVar("sk_suitcharger"):GetFloat()) or 75,ent:GetSkin()) end --(default 75) battery for chargers
			end
		
		ScavData.RegisterFiremode(tab,"models/props_combine/suit_charger001.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/hevplate.mdl")
		
/*==============================================================================================
	-- .357 rounds
==============================================================================================*/

		local tab = {}
			tab.Name = "#weapon_357"
			tab.anim = ACT_VM_RECOIL2
			tab.Level = 4
			tab.FireFunc = function(self,item)
				local bullet = {}
				bullet.Num = 1
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self:GetAimVector()
				bullet.Spread = vector_origin
				bullet.Tracer = 1
				bullet.Force = 5
				bullet.Damage = 40
				bullet.TracerName = "ef_scav_tr_b"
				self.Owner:FireBullets(bullet)
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_357.Single")
				self.Owner:ScavViewPunch(Angle(-15,math.Rand(-0.1,0.1),0),0.5)
				if CLIENT then
					self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle())
				end
				if item.ammo == "models/weapons/w_357.mdl" then
					if (item.subammo <= 1 and SERVER) or (item.subammo <= 0 and CLIENT) then --drop shells at end
						timer.Simple(0.5,function()
							if SERVER then
								self.Owner:EmitSound("weapons/357/357_reload1.wav",75,100,1,CHAN_WEAPON)
							else
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									for i=1,6 do
										util.Effect("ShellEject",ef)
									end
								end
							end
						end)
					end
				else
					timer.Simple(0.4,function() --lever action
						if SERVER then
							self.Owner:EmitSound("weapons/smg1/switch_burst.wav",75,85,1,CHAN_WEAPON)
						else
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								util.Effect("ShellEject",ef)
							end
						end
					end)
				end
				if SERVER then
					return self:TakeSubammo(item,1)
				end
			end
			function tab.OnArmed(self,item,olditemname)
				if SERVER then
					if item.ammo == "models/weapons/w_357.mdl"
					or item.ammo == "models/items/357ammo.mdl"
					or item.ammo == "models/items/357ammobox.mdl" then
						self.Owner:EmitSound("weapons/357/357_spin1.wav")
					end
				end
			end
			if SERVER then
				--TODO: give these their own models/sounds where appropriate
				ScavData.CollectFuncs["models/weapons/w_357.mdl"] = function(self,ent) self:AddItem("models/weapons/w_357.mdl",6,0,1) end --6 .357 rounds from a box of bullets
				ScavData.CollectFuncs["models/items/357ammo.mdl"] = ScavData.CollectFuncs["models/weapons/w_357.mdl"]
				ScavData.CollectFuncs["models/items/357ammobox.mdl"] = ScavData.CollectFuncs["models/items/357ammo.mdl"]
				ScavData.CollectFuncs["models/weapons/w_annabelle.mdl"] = function(self,ent) self:AddItem("models/weapons/w_annabelle.mdl",2,0,1) end --2 .357 rounds from the Annabelle
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"] = ScavData.CollectFuncs["models/items/357ammo.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_ambassador/c_ambassador.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_revolver/c_revolver.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_ambassador/c_ambassador_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_revolver/c_revolver_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_ambassador/c_ambassador_xmas.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_snub_nose/c_snub_nose.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_snub_nose/c_snub_nose.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_snub_nose/c_snub_nose.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_ttg_sam_gun/c_ttg_sam_gun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_letranger/c_letranger.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_letranger/c_letranger.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_letranger/c_letranger.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl"] = function(self,ent) self:AddItem("models/weapons/w_357.mdl",5,0,1) end --5 .357 rounds from the Diamondback
				--CSS
				ScavData.CollectFuncs["models/props/cs_militia/gun_cabinet.mdl"] = function(self,ent) self:AddItem("models/weapons/w_annabelle.mdl",2,0,2) end --2 x 2 .357 rounds from the gun cabinet
				--FoF
				ScavData.CollectFuncs["models/weapons/w_carbine.mdl"] = function(self,ent) self:AddItem("models/weapons/w_annabelle.mdl",1,0,1) end --1 .357 round from the Carbine
				ScavData.CollectFuncs["models/weapons/w_dualnavy.mdl"] = function(self,ent) self:AddItem("models/weapons/w_357.mdl",6,0,2) end --2 x 6 .357 round from the duals
				ScavData.CollectFuncs["models/weapons/w_henryrifle.mdl"] = function(self,ent) self:AddItem("models/weapons/w_annabelle.mdl",16,0,1) end --16 .357 rounds from the Henry Rifle
				ScavData.CollectFuncs["models/weapons/w_maresleg.mdl"] = function(self,ent) self:AddItem("models/weapons/w_annabelle.mdl",8,0,1) end --8 .357 rounds from the Mare's Leg
				ScavData.CollectFuncs["models/weapons/w_spencer.mdl"] = function(self,ent) self:AddItem("models/weapons/w_annabelle.mdl",7,0,1) end --7 .357 rounds from the Spencer
				ScavData.CollectFuncs["models/weapons/w_volcanic.mdl"] = function(self,ent) self:AddItem("models/weapons/w_annabelle.mdl",9,0,1) end --9 .357 rounds from the Volcanic
				ScavData.CollectFuncs["models/weapons/w_volcanic2.mdl"] = ScavData.CollectFuncs["models/weapons/w_volcanic.mdl"]
				ScavData.CollectFuncs["models/weapons/w_mauser.mdl"] = ScavData.CollectFuncs["models/weapons/w_volcanic.mdl"]
				ScavData.CollectFuncs["models/weapons/w_mauser2.mdl"] = ScavData.CollectFuncs["models/weapons/w_mauser.mdl"]
				ScavData.CollectFuncs["models/weapons/w_maresleg2.mdl"] = ScavData.CollectFuncs["models/weapons/w_maresleg.mdl"]
				ScavData.CollectFuncs["models/weapons/w_dualpeacemaker.mdl"] = ScavData.CollectFuncs["models/weapons/w_dualnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"] = ScavData.CollectFuncs["models/weapons/w_357.mdl"] --6 .357 round from the Colt
				ScavData.CollectFuncs["models/weapons/w_coltnavy2.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_hammerless.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_hammerless2.mdl"] = ScavData.CollectFuncs["models/weapons/w_hammerless.mdl"]
				ScavData.CollectFuncs["models/weapons/w_peacemaker.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_peacemaker2.mdl"] = ScavData.CollectFuncs["models/weapons/w_peacemaker.mdl"]
				ScavData.CollectFuncs["models/weapons/w_remington_army.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_remington_army2.mdl"] = ScavData.CollectFuncs["models/weapons/w_remington_army.mdl"]
				ScavData.CollectFuncs["models/weapons/w_schofield.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_schofield2.mdl"] = ScavData.CollectFuncs["models/weapons/w_schofield.mdl"]
				ScavData.CollectFuncs["models/weapons/w_walker.mdl"] = ScavData.CollectFuncs["models/weapons/w_coltnavy.mdl"]
				ScavData.CollectFuncs["models/weapons/w_walker2.mdl"] = ScavData.CollectFuncs["models/weapons/w_walker.mdl"]
				ScavData.CollectFuncs["models/weapons/w_sharps.mdl"] = ScavData.CollectFuncs["models/weapons/w_carbine.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/weapons/w_357.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_annabelle.mdl")
		
/*==============================================================================================
	--machinegun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.smg"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 3
			tab.ChargeAttack = function(self,item)
				local tf2 = item.ammo == "models/weapons/w_models/w_smg.mdl" or item.ammo == "models/weapons/c_models/c_smg/c_smg.mdl"
				local cleanerscarbine = item.ammo == "models/weapons/c_models/c_pro_smg/c_pro_smg.mdl" or item.ammo == "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl"
				if self.Owner:KeyDown(IN_ATTACK) then
					self.Owner:ScavViewPunch(Angle(math.Rand(-0.2,0.2),math.Rand(-0.2,0.2),0),0.1)
					local bullet = {}
						bullet.Num = 1
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = Vector(0.05,0.05,0)
						bullet.Tracer = 2
						bullet.Force = 5
						bullet.Damage = 4
						bullet.TracerName = "ef_scav_tr_b"
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self:AddBarrelSpin(200)
						self:TakeSubammo(item,1)
					end
					if tf2 then --TF2
						if SERVER then
							if self.Owner:GetStatusEffect("DamageX") then
								self.Owner:EmitSound("weapons/smg_shoot_crit.wav",75,100) --crit sound
							else
								self.Owner:EmitSound("weapons/smg_shoot.wav",75,100)
							end
						else
							timer.Simple(.025,function() 
								tf2shelleject(self)
							end)
						end
					elseif cleanerscarbine then --Cleaner's Carbine
						if SERVER then
							if self.Owner:GetStatusEffect("DamageX") then
								self.Owner:EmitSound("weapons/doom_sniper_smg_crit.wav",75,100) --crit sound
							else
								self.Owner:EmitSound("weapons/doom_sniper_smg.wav",75,100)
							end
						else
							timer.Simple(.025,function() 
								tf2shelleject(self)
							end)
						end
					else
						if item.ammo == "models/w_9mmar.mdl" then --HL:S
							if SERVER then
								self.Owner:EmitSound("weapons/hks"..math.floor(math.Rand(1,4))..".wav")
							else
								timer.Simple(.025,function() 
									local ef = EffectData()
									local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
									if attach then
										ef:SetOrigin(attach.Pos)
										ef:SetAngles(attach.Ang)
										--lovingly borrowed from https://steamcommunity.com/sharedfiles/filedetails/?id=1360233031
										local angShellAngles = self.Owner:EyeAngles()
										local vecShellVelocity = self.Owner:GetAbsVelocity()
										vecShellVelocity = vecShellVelocity + angShellAngles:Right() * math.Rand( 50, 70 );
										vecShellVelocity = vecShellVelocity + angShellAngles:Up() * math.Rand( 100, 150 );
										vecShellVelocity = vecShellVelocity + angShellAngles:Forward() * 25;
										ef:SetStart(vecShellVelocity)
										ef:SetEntity(self.Owner)
										ef:SetFlags(0) --pistol shell
										util.Effect("HL1ShellEject",ef)
									end
								end)
							end
						elseif item.ammo == "models/weapons/w_alyx_gun.mdl" then
							if SERVER then
								self.Owner:EmitSound("Weapon_Alyx_Gun.Single")
							else
								timer.Simple(.025,function() 
									local ef = EffectData()
									local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
									if attach then
										ef:SetOrigin(attach.Pos)
										ef:SetAngles(attach.Ang)
										util.Effect("ShellEject",ef)
									end
								end)
							end
						else--if item.ammo == "models/items/boxmrounds.mdl" or item.ammo == "models/weapons/w_smg1.mdl" then
							if SERVER then
								self.Owner:EmitSound("Weapon_SMG1.Single")
							else
								timer.Simple(.025,function() 
									local ef = EffectData()
									local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
									if attach then
										ef:SetOrigin(attach.Pos)
										ef:SetAngles(attach.Ang)
										util.Effect("ShellEject",ef)
									end
								end)
							end
						end
					end
				end
				local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()	
				if !continuefiring and SERVER then
					self.ChargeAttack = nil
				end
				if tf2 then
					return 0.105
				elseif cleanerscarbine then
					return 0.135
				else
					return 0.065
				end
			end
			tab.FireFunc = function(self,item)
				self.ChargeAttack = ScavData.models["models/weapons/w_smg1.mdl"].ChargeAttack
				self.chargeitem = item							
				return false
			end
			function tab.OnArmed(self,item,olditemname)
				if SERVER then
					--if item.ammo == "models/weapons/w_smg1.mdl" then
						self.Owner:EmitSound("weapons/smg1/switch_burst.wav")
					--end
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/items/ammocrate_smg1.mdl"] = function(self,ent) self:AddItem("models/weapons/w_smg1.mdl",45,0,3) end
				--ScavData.CollectFuncs["models/items/ammocrate_smg2.mdl"] = ScavData.CollectFuncs["models/items/ammocrate_smg1.mdl"]
				ScavData.CollectFuncs["models/items/boxmrounds.mdl"] = function(self,ent) self:AddItem("models/items/boxmrounds.mdl",20,0) end
				ScavData.CollectFuncs["models/weapons/w_smg1.mdl"] = function(self,ent) self:AddItem("models/weapons/w_smg1.mdl",45,0) end
				ScavData.CollectFuncs["models/weapons/w_alyx_gun.mdl"] = function(self,ent) self:AddItem("models/weapons/w_alyx_gun.mdl",30,0) end
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_smg.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),25,0) end
				ScavData.CollectFuncs["models/weapons/c_models/c_smg/c_smg.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_smg.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_pro_smg/c_pro_smg.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_pro_smg/c_pro_smg.mdl"]
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/items/boxmrounds.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_smg1.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_alyx_gun.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_smg.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_smg/c_smg.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_pro_smg/c_pro_smg.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab,"models/w_9mmar.mdl")

/*==============================================================================================
	--Hunter Flechettes
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.flechettes"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			if SERVER then
				tab.FireFunc = function(self,item)
									local proj = self:CreateEnt("hunter_flechette")
									proj:SetPos(self:GetProjectileShootPos())
									proj:SetAngles(self:GetAimVector():Angle())
									proj:SetPhysicsAttacker(self.Owner)
									proj:Spawn()
									proj:SetOwner(self.Owner)
									proj:SetVelocity(self:GetAimVector()*2000)
									self.Owner:EmitSound("npc/ministrider/ministrider_fire1.wav")
									proj:Fire("kill",1,"10")
									self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
									return self:TakeSubammo(item,1)		
						
								end
				ScavData.CollectFuncs["models/hunter.mdl"] = function(self,ent) self:AddItem("models/weapons/hunter_flechette.mdl",50,0) end
				ScavData.CollectFuncs["models/renderng_regression_test_hunter.mdl"] = ScavData.CollectFuncs["models/hunter.mdl"]
				--Ep1
				ScavData.CollectFuncs["models/ministrider.mdl"] = ScavData.CollectFuncs["models/hunter.mdl"]
			end
			tab.Cooldown = 0.1
		ScavData.RegisterFiremode(tab,"models/weapons/hunter_flechette.mdl")
		
/*==============================================================================================
	--Grunt Hornets
==============================================================================================*/
		
		local tab = {} --TODO: recharge ammo (like airboat gun)
			tab.Name = "#scav.scavcan.hornets"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 5
			if SERVER then
				tab.FireFunc = function(self,item)
									local proj = self:CreateEnt("hornet")
									proj:SetPos(self:GetProjectileShootPos())
									proj:SetAngles(self:GetAimVector():Angle())
									proj:SetPhysicsAttacker(self.Owner)
									proj:Spawn()
									proj:SetOwner(self.Owner)
									proj:SetVelocity(self:GetAimVector()*2000)
									self.Owner:EmitSound("agrunt/ag_fire"..math.random(1,3)..".wav")
									proj:Fire("kill",1,"10")
									self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
									return self:TakeSubammo(item,1)		
								end
				ScavData.CollectFuncs["models/agrunt.mdl"] = function(self,ent) self:AddItem("models/agrunt.mdl",50,0) end
			end
			tab.Cooldown = 0.2
		ScavData.RegisterFiremode(tab,"models/agrunt.mdl")
		
/*==============================================================================================
	--Controller Energy Ball
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.aliencontroller"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 5
			if SERVER then
				tab.FireFunc = function(self,item)
									local proj = self:CreateEnt("controller_energy_ball")
									proj:SetPos(self:GetProjectileShootPos())
									proj:SetAngles(self:GetAimVector():Angle())
									proj:SetPhysicsAttacker(self.Owner)
									proj:Spawn()
									proj:SetOwner(self.Owner)
									proj:SetVelocity(self:GetAimVector()*2000)
									self.Owner:EmitSound("weapons/electro4.wav")
									proj:Fire("kill",1,"10")
									self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
									return self:TakeSubammo(item,1)		
						
								end
				ScavData.CollectFuncs["models/controller.mdl"] = function(self,ent) self:AddItem("models/controller.mdl",50,0) end
			end
			tab.Cooldown = 0.15
		ScavData.RegisterFiremode(tab,"models/controller.mdl")
	
/*==============================================================================================
	--Squid Spit
==============================================================================================*/
		
		local tab = {}
			tab.Name = "#scav.scavcan.bullsquid"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			if SERVER then
				tab.FireFunc = function(self,item)
									local proj = self:CreateEnt("squidspit")
									proj:SetPos(self:GetProjectileShootPos())
									proj:SetAngles(self:GetAimVector():Angle())
									proj:SetPhysicsAttacker(self.Owner)
									proj:Spawn()
									proj:SetOwner(self.Owner)
									proj:SetVelocity(self:GetAimVector()*2000)
									self.Owner:EmitSound("bullchicken/bc_attack"..math.random(2,3).."wav")
									proj:Fire("kill",1,"10")
									self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
									return self:TakeSubammo(item,1)		
						
								end
				ScavData.CollectFuncs["models/bullsquid.mdl"] = function(self,ent) self:AddItem("models/bullsquid.mdl",50,0) end
			end
			tab.Cooldown = 0.6
		ScavData.RegisterFiremode(tab,"models/bullsquid.mdl") 

/*==============================================================================================
	--Vortigaunt Beam
==============================================================================================*/

		PrecacheParticleSystem("vortigaunt_beam")
		PrecacheParticleSystem("scav_vm_vort")
		local tab = {}
			tab.Name = "#scav.scavcan.vortigaunt"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				local dmg = DamageInfo()
				local tracep = {}
				tracep.mask = MASK_SHOT
				tracep.mins = Vector(-2,-2,-2)
				tracep.maxs = Vector(2,2,2)
				tab.ChargeAttack = function(self,item)
					local shootpos = self.Owner:GetShootPos()
					tracep.start = shootpos
					tracep.endpos = shootpos+self:GetAimVector()*2000
					tracep.filter = self.Owner
					local tr = util.TraceHull(tracep)
					util.ParticleTracerEx("vortigaunt_beam",self:GetAttachment(self:LookupAttachment("muzzle")).Pos,tr.HitPos,false,self:EntIndex(),1)
					if tr.Entity:IsValid() then
						dmg:SetAttacker(self.Owner)
						dmg:SetInflictor(self)
						dmg:SetDamagePosition(tr.HitPos)
						dmg:SetDamageType(DMG_SHOCK)
						dmg:SetDamage(50)
						dmg:SetDamageForce(tr.Normal*12000)
						tr.Entity:TakeDamageInfo(dmg)
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitToAllButSelf("npc/vort/vort_explode1.wav")
					self.Owner:EmitToAllButSelf("npc/vort/attack_shoot.wav",45)
					sound.Play("npc/vort/vort_explode2.wav",tr.HitPos)
					self.soundloops.scavvort:Stop()
					self.ChargeAttack = nil
					self:SetBlockPose(0,4)
					return 0.5
				end
				tab.FireFunc = function(self,item)
					self.ChargeAttack = ScavData.models["models/vortigaunt.mdl"].ChargeAttack
					if self.Owner.snd_scavvort then
						self.Owner.snd_scavvort:Stop()
					end
					if !self.soundloops.scavvort then
						self.soundloops.scavvort = CreateSound(self.Owner,"npc/vort/attack_charge.wav")
					end
					self.soundloops.scavvort:Play()
					self.chargeitem = item
					self:SetBlockPose(1,4)
					if SERVER then return self:TakeSubammo(item,1) end
				end
				ScavData.CollectFuncs["models/vortigaunt.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),10,ent:GetSkin()) end
				ScavData.CollectFuncs["models/vortigaunt_slave.mdl"] = ScavData.CollectFuncs["models/vortigaunt.mdl"]
				--Ep1
				ScavData.CollectFuncs["models/vortigaunt_blue.mdl"] = ScavData.CollectFuncs["models/vortigaunt.mdl"]
				--Ep2
				ScavData.CollectFuncs["models/vortigaunt_doctor.mdl"] = ScavData.CollectFuncs["models/vortigaunt.mdl"]
				--HL:S
				ScavData.CollectFuncs["models/islave.mdl"] = ScavData.CollectFuncs["models/vortigaunt.mdl"]
			else
				local dmg = DamageInfo()
				local tracep = {}
				tracep.mask = MASK_SHOT
				tracep.mins = Vector(-2,-2,-2)
				tracep.maxs = Vector(2,2,2)
				local ef = EffectData()
				tab.ChargeAttack = function(self,item)
					local shootpos = self.Owner:GetShootPos()
					tracep.start = shootpos
					tracep.endpos = shootpos+self:GetAimVector()*2000
					tracep.filter = self.Owner
					local tr = util.TraceHull(tracep)
					if self.Owner == GetViewEntity() then
						util.ParticleTracerEx("vortigaunt_beam",self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos,self.Owner:GetEyeTraceNoCursor().HitPos,false,0,-1)
					else
						util.ParticleTracerEx("vortigaunt_beam",self:GetAttachment(self:LookupAttachment("muzzle")).Pos,self.Owner:GetEyeTraceNoCursor().HitPos,false,self:EntIndex(),1)
					end
					self.Owner:EmitSound("npc/vort/vort_explode1.wav")
					self.Owner:EmitSound("npc/vort/attack_shoot.wav",45)
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
					util.Effect("StunstickImpact",ef)
					self.ChargeAttack = nil
					return 0.5
					
				end
				tab.FireFunc = function(self,item)
					self.ChargeAttack = ScavData.models["models/vortigaunt.mdl"].ChargeAttack
					self.chargeitem = item
					ParticleEffectAttach("scav_vm_vort",PATTACH_POINT_FOLLOW,self.Owner:GetViewModel(),self:LookupAttachment("muzzle"))
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
		ScavData.RegisterFiremode(tab,"models/vortigaunt.mdl")
		ScavData.RegisterFiremode(tab,"models/vortigaunt_slave.mdl")
		--Ep1
		ScavData.RegisterFiremode(tab,"models/vortigaunt_blue.mdl")
		--Ep2
		ScavData.RegisterFiremode(tab,"models/vortigaunt_doctor.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab,"models/islave.mdl")
