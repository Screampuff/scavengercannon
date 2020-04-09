local refangle = Angle(0,0,0)
local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")
local SWEP = SWEP
local ScavData = ScavData

/*==============================================================================================
	--Scav Rockets
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Rocket Launcher"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.computers = {
								"models/props_lab/harddrive01.mdl",
								"models/props_lab/harddrive02.mdl",
								"models/props/cs_office/computer_case.mdl",
								"models/props/cs_office/computer_caseb.mdl",
								"models/props/cs_office/computer_caseb_p2.mdl",
								"models/props/cs_office/computer_caseb_p2a.mdl",
								"models/props/cs_office/computer_caseb_p3.mdl",
								"models/props/cs_office/computer_caseb_p3a.mdl",
								"models/props/cs_office/computer_caseb_p4.mdl",
								"models/props/cs_office/computer_caseb_p5.mdl",
								"models/props/cs_office/computer_caseb_p6.mdl",
								"models/props/pc_case02/pc_case02.mdl",
								"models/props/pc_case_open/pc_case_open.mdl"
							}
			tab.tracep = {}
			tab.tracep.mask = MASK_SHOT
			tab.tracep.mins = Vector(-16,-16,-16)
			tab.tracep.maxs = Vector(16,16,16)
			if SERVER then
				tab.FireFunc = function(self,item)
						local tab = ScavData.models[self.inv.items[1].ammo]
						local proj = self:CreateEnt("scav_projectile_rocket")
						proj.Owner = self.Owner
						proj:SetModel(item.ammo)
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles(self:GetAimVector():Angle())
						proj:SetOwner(self.Owner)
						local seeking = false
						for k,v in ipairs(tab.computers) do	
							if self:HasItemName(v) then
								seeking = true
								//print("Seeking")
								break
							end
						end
						if seeking then
							tab.tracep.start = self.Owner:GetShootPos()
							tab.tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*20000
							tab.tracep.filter = self.Owner
							local tr = util.TraceHull(tab.tracep)
							//print(tr.Entity)
							if tr.Entity:IsValid() then
								proj.target = tr.Entity
							end
						end
						proj:Spawn()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound("weapons/stinger_fire1.wav",40,100)
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(false)
						proj:GetPhysicsObject():EnableGravity(false)
						proj.SpeedScale = self.dt.ForceScale
						proj:GetPhysicsObject():SetVelocityInstantaneous((self:GetAimVector())*2000*self.dt.ForceScale)
						proj:GetPhysicsObject():SetBuoyancyRatio(0)
						//self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("fire3"))
						//gamemode.Call("ScavFired",self.Owner,proj)
						self:AddBarrelSpin(575)
						self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
						return true
					end
				ScavData.CollectFuncs["models/weapons/w_rocket_launcher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_missile.mdl",1,0,3) end --3 rockets from HL2 launcher
				ScavData.CollectFuncs["models/items/ammocrate_rockets.mdl"] = function(self,ent) self:AddItem("models/weapons/w_missile.mdl",1,0,3) end --4 rockets from HL2 rocket create
				ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_rocket.mdl",1,0,4) end --5 rockets from TF2 launcher
				ScavData.CollectFuncs["models/buildables/sentry3.mdl"] = function(self,ent) self:AddItem("models/buildables/sentry3_rockets.mdl",1,0,1) end --1 rocket from TF2 sentry (level 3)
				ScavData.CollectFuncs["models/weapons/w_missile_launch.mdl"] = function(self,ent) self:AddItem("models/weapons/w_missile.mdl",1,0,1) end --converts the rocket into a usable one
				ScavData.CollectFuncs["models/weapons/w_missile_closed.mdl"] = ScavData.CollectFuncs["models/weapons/w_missile_launch.mdl"]
			end
			tab.Cooldown = 1
		ScavData.models["models/weapons/w_missile.mdl"] = tab
		ScavData.models["models/weapons/w_missile_closed.mdl"] = tab
		ScavData.models["models/props_bts/rocket.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_rocket.mdl"] = tab
		ScavData.models["models/buildables/sentry3_rockets.mdl"] = tab
		

/*==============================================================================================
	--Ice Beam
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Ice Beam"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.tracep = {}
			tab.tracep.mask = MASK_SHOT
			tab.tracep.mins = Vector(-16,-16,-16)
			tab.tracep.maxs = Vector(16,16,16)
			if SERVER then
				tab.FireFunc = function(self,item)
						local tab = ScavData.models[self.inv.items[1].ammo]
						local proj = self:CreateEnt("scav_projectile_ice")
						proj.Owner = self.Owner
						proj:SetModel(item.ammo)
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles(self:GetAimVector():Angle())
						proj:SetOwner(self.Owner)
						proj:Spawn()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound("physics/glass/glass_strain1.wav",100,100)
						self.Owner:EmitSound("weapons/ar2/npc_ar2_altfire.wav",100,100)
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(false)
						proj:GetPhysicsObject():EnableGravity(false)
						proj.SpeedScale = self.dt.ForceScale
						proj:GetPhysicsObject():SetVelocity((self:GetAimVector())*2000*self.dt.ForceScale)
						proj:GetPhysicsObject():SetBuoyancyRatio(0)
						self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
						return false
					end
				ScavData.CollectFuncs["models/dav0r/hoverball.mdl"] = ScavData.GiveOneOfItemInf
			end
			tab.Cooldown = 1
		ScavData.models["models/dav0r/hoverball.mdl"] = tab


		
		
/*==============================================================================================
	--Turret Gun
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Auto-Target Rifle"
			tab.Level = 4
			tab.anim = ACT_VM_RECOIL1
			tab.tracep = {}
			tab.tracep.mask = MASK_SHOT
			tab.tracep.mins = Vector(-32,-32,-32)
			tab.tracep.maxs = Vector(32,32,32)
			if SERVER then
				tab.FireFunc = function(self,item)
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
							if item.ammo == "models/buildables/sentry1.mdl" then
								self.Owner:EmitToAllButSelf("weapons/sentry_shoot.wav")
							else
								self.Owner:EmitToAllButSelf("weapons/sentry_shoot2.wav")
							end
							bullet.TracerName = "ef_scav_tr_b"
						else
							self.Owner:EmitToAllButSelf("npc/turret_floor/shoot"..math.random(1,3)..".wav")
							bullet.TracerName = "AR2Tracer"
						end
						self.Owner:FireBullets(bullet)
						self.Owner:SetAnimation(PLAYER_ATTACK1)


						if item.ammo == "models/buildables/sentry1.mdl" then
							tab.Cooldown = 0.25
						else
							tab.Cooldown = 0.1
						end
						return self:TakeSubammo(item,1)
					end
				tab.OnArmed = function(self,item,olditemname)
					local newitem = item
					if newitem.ammo != olditemname then
						if newitem.ammo == "models/props/turret_01.mdl" then
							self.Owner:EmitSound("npc/turret_floor/turret_deploy_"..math.random(1,6)..".wav")
						elseif string.find(newitem.ammo,"models/buildables/sentry") then
							self.Owner:EmitSound("weapons/sentry_spot_client.wav")
						else
							self.Owner:EmitSound("npc/turret_floor/active.wav")
						end
					end
				end
				ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/props/turret_01.mdl"] = ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"]
				ScavData.CollectFuncs["models/buildables/sentry1.mdl"] = ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"]
				ScavData.CollectFuncs["models/buildables/sentry2.mdl"] = ScavData.CollectFuncs["models/combine_turrets/floor_turret.mdl"]
			else
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
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
						self.Owner:ScavViewPunch(Angle(math.Rand(0,1),math.Rand(-1,1),0),0.5)
						local bullet = {}
						bullet.Num = 1
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = dir
						bullet.Spread = Vector(0.02,0.02,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 4
						if string.find(item.ammo,"models/buildables/sentry") then
							if item.ammo == "models/buildables/sentry1.mdl" then
								self.Owner:EmitSound("weapons/sentry_shoot.wav")
							else
								self.Owner:EmitSound("weapons/sentry_shoot2.wav")
							end
							bullet.TracerName = "ef_scav_tr_b"
						else
							self.Owner:EmitSound("npc/turret_floor/shoot"..math.random(1,3)..".wav")
							bullet.TracerName = "AR2Tracer"
						end
						if item.ammo == "models/buildables/sentry1.mdl" then
							tab.Cooldown = 0.25
						else
							tab.Cooldown = 0.1
						end
						
						self.Owner:FireBullets(bullet)
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.1
		ScavData.models["models/combine_turrets/floor_turret.mdl"] = tab
		ScavData.models["models/props/turret_01.mdl"] = tab
		ScavData.models["models/buildables/sentry1.mdl"] = tab
		ScavData.models["models/buildables/sentry2.mdl"] = tab
	
/*==============================================================================================
	--Flares
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Flare Gun"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			if SERVER then
				tab.FireFunc = function(self,item)
						//local proj = self:CreateEnt("scav_projectile_flare")
						local proj = self:CreateEnt("scav_projectile_flare2")
						proj.Owner = self.Owner
						proj:SetModel(item.ammo)
						proj:SetPos(self.Owner:GetShootPos()-self:GetAimVector()*15+self:GetAimVector():Angle():Right()*2-self:GetAimVector():Angle():Up()*2)
						proj:SetAngles(self:GetAimVector():Angle())
						proj:SetOwner(self.Owner)
						//proj:SetSkin(item.data)
						proj:SetSkin(item.data)
						proj:Spawn()
						//"weapons/flaregun/burn"
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(false)
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*4000)
						proj:GetPhysicsObject():SetBuoyancyRatio(0)
						proj:SetPhysicsAttacker(self.Owner)
						self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
						return true
					end
				ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_flaregun_shell.mdl",1,ent:GetSkin(),5) end --5 flares from the TF2 flaregun
			else
				tab.fov = 10
			end
			tab.Cooldown = 1
		ScavData.models["models/weapons/w_models/w_flaregun_shell.mdl"] = tab
		ScavData.models["models/props_junk/flare.mdl"] = tab
		
/*==============================================================================================
	--Arrows and Bolts
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Impaler"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 8
			if SERVER then
				tab.FireFunc = function(self,item)
						local proj = self:CreateEnt("scav_projectile_arrow")
						proj.Owner = self.Owner
						proj:SetModel(item.ammo)
						proj:SetPos(self.Owner:GetShootPos()-self:GetAimVector()*15+self:GetAimVector():Angle():Right()*2-self:GetAimVector():Angle():Up()*2)
						proj.angoffset = ScavData.GetEntityFiringAngleOffset(proj)
						proj:SetAngles(self:GetAimVector():Angle()+proj.angoffset)
						proj:SetOwner(self.Owner)
						proj:SetSkin(item.data)
						proj:Spawn()				
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if item.ammo == "models/props_mining/railroad_spike01.mdl" then --yes this is in recognition of the railway rifle from Fallout 3
							self.Owner:EmitSound("ambient/machines/train_horn_1.wav")
						end
						self.Owner:EmitSound(self.shootsound)
						self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
						return true
					end
				PLAYER.GetRagdollEntityOld = PLAYER.GetRagdollEntity
				ENTITY.ArrowRagdoll = NULL
				function PLAYER:GetRagdollEntity()
					if self.ArrowRagdoll:IsValid() then
						return self.ArrowRagdoll
					else
						return self:GetRagdollEntityOld()
					end
				end
				hook.Add("PlayerSpawn","ResetArrowRagdoll",function(pl) pl.ArrowRagdoll = NULL end)
				hook.Add("PlayerDeath","NoArrowRagdoll",function(pl) if pl.ArrowRagdoll:IsValid() && pl:GetRagdollEntityOld() then pl:GetRagdollEntityOld():Remove() end end)
				hook.Add("CreateEntityRagdoll","NoArrowRagdoll2",function(ent,rag) if ent.ArrowRagdoll:IsValid() then rag:Remove() end end)
				ScavData.CollectFuncs["models/items/crossbowrounds.mdl"] = function(self,ent) self:AddItem("models/crossbow_bolt.mdl",1,ent:GetSkin(),6) end --6 crossbow bolts from a bundle of bolts
				ScavData.CollectFuncs["models/weapons/w_crossbow.mdl"] = function(self,ent) self:AddItem("models/crossbow_bolt.mdl",1,ent:GetSkin(),1) end --1 bolt from the crossbow
			else
				tab.fov = 10
			end
			tab.Cooldown = 1
			
			
		ScavData.models["models/weapons/w_models/w_arrow.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_arrow_xmas.mdl"] = tab
		ScavData.models["models/crossbow_bolt.mdl"] = tab
		ScavData.models["models/props_mining/railroad_spike01.mdl"] = tab
		ScavData.models["models/weapons/c_models/c_claymore/c_claymore.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_machete.mdl"] = tab
		ScavData.models["models/mixerman3d/other/arrow.mdl"] = tab
		
/*==============================================================================================
	--Scav Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Grenade Launcher"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			if SERVER then
				tab.OnArmed = function(self,item,olditemname)
					if (item.ammo == "models/props_junk/popcan01a.mdl") then
						self.Owner:EmitSound("player/pl_scout_dodge_can_open.wav")
				    end
				end
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("scav_projectile_grenade")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Up()*-1):Angle())
						proj:Spawn()
						proj:SetSkin(item.data)
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():SetMass(1)
						proj:GetPhysicsObject():EnableDrag(true)
						proj:GetPhysicsObject():EnableGravity(true)
						proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector())*2300,Vector(0,0,3)) --self:GetAimVector():Angle():Up()*0.1
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(0,10000,0)) end)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						//gamemode.Call("ScavFired",self.Owner,proj)				
						return true
					end
				ScavData.CollectFuncs["models/weapons/w_models/w_grenadelauncher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_grenade_grenadelauncher.mdl",1,0,6) end --6 grenades from TF2 grenade launcher
				ScavData.CollectFuncs["models/props_interiors/vendingmachinesoda01a.mdl"] = function(self,ent) self:AddItem("models/props_junk/popcan01a.mdl",1,math.random(0,2),9) self:AddItem("models/props_interiors/VendingMachineSoda01a_door.mdl",0,0) end --nine grenades + door from vending machine	
			else
				tab.FireFunc = function(self,item)
					return true
				end
			end
			tab.Cooldown = 0.75
		ScavData.models["models/weapons/w_models/w_grenade_grenadelauncher.mdl"] = tab
		ScavData.models["models/props_junk/popcan01a.mdl"] = tab
		ScavData.models["models/weapons/w_eq_fraggrenade.mdl"] = tab
		ScavData.models["models/weapons/w_eq_fraggrenade_thrown.mdl"] = tab
		
/*==============================================================================================
	--Strider Buster
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Strider Buster"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 7
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("scav_projectile_mag")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
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
						return true
					end
			end
			tab.Cooldown = 1.5
		ScavData.models["models/magnusson_device.mdl"] = tab
		
		
		
/*==============================================================================================
	--Payload Gun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Payload Gun"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-20,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("scav_projectile_payload")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self.Owner:GetShootPos())
						//proj:SetAngles((self:GetAimVector():Angle():Up()*-1):Angle())
						proj:Spawn()
						proj:SetSkin(item.data)
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(true)
						proj:GetPhysicsObject():SetDragCoefficient(-10000)
						proj:GetPhysicsObject():EnableGravity(true)
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*2500)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						//gamemode.Call("ScavFired",self.Owner,proj)					
						return true
					end
				ScavData.CollectFuncs["models/props_trainyard/bomb_cart.mdl"] = function(self,ent) self:AddItem("models/props_trainyard/cart_bomb_separate.mdl",1,0,1) end
				ScavData.CollectFuncs["models/props_trainyard/bomb_cart_red.mdl"] = ScavData.CollectFuncs["models/props_trainyard/bomb_cart.mdl"]
			end
			tab.Cooldown = 5
		ScavData.models["models/props_trainyard/cart_bomb_separate.mdl"] = tab

		
/*==============================================================================================
	--Proximity Mine
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Proximity Mine"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("scav_proximity_mine")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self.Owner:GetShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Up()*-1):Angle())
						proj:Spawn()
						if (item.ammo == "models/weapons/w_models/w_stickybomb2.mdl") || (item.ammo == "models/props_c17/doll01.mdl") then
							proj.dt.sticky = false
						end
						proj:SetSkin(item.data)				
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():SetMass(1)
						proj:GetPhysicsObject():EnableDrag(true)
						proj:GetPhysicsObject():EnableGravity(true)
						//proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector()+Vector(0,0,0.1))*5000,Vector(0,0,3)) --self:GetAimVector():Angle():Up()*0.1
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*17000) --self:GetAimVector():Angle():Up()*0.1
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(0,10000,0)) end)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						self.Owner:AddScavExplosive(proj)
						//gamemode.Call("ScavFired",self.Owner,proj)
						return true
					end
				ScavData.CollectFuncs["models/weapons/w_models/w_stickybomb_launcher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_stickybomb.mdl",1,0,6) end --6 prox mines from the TF2 stickybomb launcher
			else
				tab.FireFunc = function(self,item)
					return true
				end
			end
			tab.Cooldown = 0.75
		ScavData.models["models/weapons/w_models/w_stickybomb.mdl"] = tab
		ScavData.models["models/props_c17/doll01.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_stickybomb3.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_stickybomb_d.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_stickybomb2.mdl"] = tab
		ScavData.models["models/scav/proxmine.mdl"] = tab

/*==============================================================================================
	--Bounding Mine
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Bounding Mine"
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
			end
			tab.Cooldown = 0.75
		ScavData.models["models/props_combine/combine_mine01.mdl"] = tab
		
/*==============================================================================================
	--Tripmines
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Tripmine"
			tab.anim = ACT_VM_MISSCENTER
			tab.Level = 6
			if SERVER then
				tab.FireFunc = function(self,item)
					local tr = self.Owner:GetEyeTraceNoCursor()
						if ((tr.HitPos-tr.StartPos):Length() > 64) || (!tr.HitWorld && (tr.Entity:GetMoveType() != MOVETYPE_VPHYSICS)) then
							self.Owner:EmitSound("buttons/button11.wav")
							return false
						end	
						local proj = self:CreateEnt("scav_tripmine")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						if item.ammo == "models/weapons/w_slam.mdl" then
							proj:SetPos(tr.HitPos+tr.HitNormal*2)
						else
							proj:SetPos(tr.HitPos)
						end
						proj:SetAngles(tr.HitNormal:Angle()+Angle(90,0,0))
						proj:Spawn()
						proj:SetMoveType(MOVETYPE_NONE)
						if !tr.HitWorld then
							proj:SetParent(tr.Entity)
						end
						proj:SetSkin(item.data)
						self.Owner:EmitSound("npc/roller/blade_cut.wav")
						self.Owner:AddScavExplosive(proj)
						return true
					end
			end
			tab.Cooldown = 0.75
		ScavData.models["models/weapons/w_slam.mdl"] = tab
		ScavData.models["models/props_lab/huladoll.mdl"] = tab

/*==============================================================================================
	--Energy Drink
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Stim Pack"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 6
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:InflictStatus("Speed",20,3)
						self.Owner:InflictStatus("Shock",30,40)
						self.Owner:EmitSound("player/pl_scout_dodge_can_open.wav")
						self.Owner:EmitSound("player/pl_scout_dodge_can_drink_fast.wav")
						return true
					end
			end
			tab.Cooldown = 0.5
		ScavData.models["models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"] = tab
		
/*==============================================================================================
	--Cloaking Watch
==============================================================================================*/
		
		local function cloakcheck(self)
			if self.Cloak && (self.Cloak.subammo > 0) then
				self.Cloak.subammo = self.Cloak.subammo-1
				timer.Simple(1, function() cloakcheck(self) end)
			else
				if SERVER && self.Cloak then
					self.Owner:InflictStatus("Cloak",-self.Cloak.subammo,1)
					self:RemoveItemValue(self.Cloak)
				end
				self.Cloak = false
			end
		end
		
		local tab = {}
			tab.Name = "Cloaking Device"
			tab.anim = ACT_VM_FIDGET
			tab.Level = 7
			if SERVER then
				tab.FireFunc = function(self,item)
					if self.Cloak && (self.Cloak != item) then
						local leftover = item.subammo-self.Cloak.subammo
						self.Cloak = item
						self.Owner:InflictStatus("Cloak",leftover,1)
					elseif !self.Cloak then
						self.Owner:InflictStatus("Cloak",item.subammo,1)
						self.Cloak = item
						timer.Simple(1, function() cloakcheck(self) end)
					else
						self.Owner:InflictStatus("Cloak",-self.Cloak.subammo,1)
						self.Cloak = false				
					end
				end
					
				function tab.PostRemove(self,item)
					if item == self.Cloak then
						self.Owner:InflictStatus("Cloak",-self.Cloak.subammo,1)
						self.Cloak = false
					end
				end
				ScavData.CollectFuncs["models/weapons/c_models/c_spy_watch.mdl"] = function(self,ent) self:AddItem("models/weapons/c_models/c_spy_watch.mdl",30,0) end --30 seconds of cloak from a spy watch
			else
				tab.FireFunc = function(self,item)
						if self.Cloak && (self.Cloak != item) then
							self.Cloak = item
						elseif !self.Cloak then
							self.Cloak = item
							timer.Simple(1, function() cloakcheck(self) end)
						else
							self.Cloak = false				
						end
						return false
					end
			end
			

			tab.Cooldown = 1
		ScavData.models["models/weapons/c_models/c_spy_watch.mdl"] = tab
		
	

/*==============================================================================================
	--Key
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Universal Key"
			tab.anim = ACT_VM_IDLE
			tab.Level = 7
			if SERVER then
				tab.FireFunc = function(self,item)
					//local tr = self.Owner:GetEyeTraceNoCursor()
						local tracep = {}
							tracep.start = self.Owner:GetShootPos()
							tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*48
							tracep.filter = self.Owner
							tracep.mask = MASK_SOLID_BRUSHONLY
							local tr = util.TraceHull(tracep)
							//print(tr.Entity)
						if ((tr.HitPos-tr.StartPos):Length() > 48) || !tr.Entity:IsValid() || !(string.find(tr.Entity:GetClass(),"func_door",0,true)) then
							self.Owner:EmitSound("buttons/button11.wav")
							return false
						end
							tr.Entity:Fire("Open",1,0)
						return true
					end
			end
			tab.Cooldown = 2
		ScavData.models["models/props_lab/keypad.mdl"] = tab
		ScavData.models["models/lostcoast/fisherman/keys.mdl"] = tab

/*==============================================================================================
	--Remote
==============================================================================================*/
		
	do
		local tab = {}
			tab.Name = "Universal Remote"
			tab.anim = ACT_VM_IDLE
			tab.Level = 7
			tab.Cooldown = 0.05
			local tracep = {}
			tracep.mins = Vector(-2,-2,-2)
			tracep.maxs = Vector(2,2,2)
			local interactions = {}
			interactions["gmod_hoverball"] = {
				["HackTime"]=2,
				["Action"]= function(self,ent)
					if !ent.oldstrength then
						ent.oldstrength = ent.strength
						ent.strength = 0
					else
						ent.strength = ent.oldstrength
						ent.oldstrength = nil
					end
				end
				}
			interactions["scav_c4"] = {
				["HackTime"]=5,
				["Action"]= function(self,ent)
					ent:Disarm()
				end
				}
			interactions["scav_tripmine"] = {
				["HackTime"]=5,
				["Action"]= function(self,ent)
					ent:SetArmed(!ent:IsArmed())
				end
				}
			interactions["gmod_thruster"] = {
				["HackTime"]=6,
				["Action"]= function(self,ent)
					ent:Switch(!ent:IsOn())
				end
				}
			interactions["gmod_turret"] = {
				["HackTime"]=6,
				["Action"]= function(self,ent)
					ent:SetOn(!ent:GetOn())
				end
				}
			interactions["gmod_emitter"] = interactions["gmod_turret"]
			interactions["gmod_dynamite"] = {
				["HackTime"]=7,
				["Action"]= function(self,ent)
					ent:Explode()
				end
				}
			interactions["gmod_wheel"] = {
				["HackTime"]=3,
				["Action"]= function(self,ent)
					ent:Reverse()
				end
				}
			interactions["npc_rollermine"] = {
				["HackTime"]=2,
				["Action"]= function(self,ent)
					ent:Fire("PowerDown",nil,0)
				end
				}
			interactions["npc_turret_floor"] = {
				["HackTime"]=2,
				["Action"]= function(self,ent)
					ent:Fire("SelfDestruct",nil,0)
				end
				}
			interactions["npc_manhack"] = {
				["HackTime"]=1,
				["Action"]= function(self,ent)
					ent:Fire("InteractivePowerDown",nil,0)
				end
				}
			interactions["prop_vehicle_jeep"] = {
				["HackTime"]=2,
				["Action"]= function(self,ent)
					if ent.HackedOff then
						ent:Fire("TurnOn",nil,0)
					else
						ent:Fire("TurnOff",nil,0)
					end
					ent.HackedOff = !ent.HackedOff
				end
				}
			
			interactions["prop_vehicle_jeep_old"] = interactions["prop_vehicle_jeep"]
			interactions["prop_vehicle_airboat"] = interactions["prop_vehicle_jeep"]
			function tab.ChargeAttack(self,item)
				self.HackingProgress = (self.HackingProgress||0)+0.05
				//if SERVER then --SERVER
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = tracep.start+self.Owner:GetAimVector()*1000
					tracep.filter = self.Owner
					local tr = util.TraceHull(tracep)
				//end
				self.BarrelRotation = self.BarrelRotation+math.random(-17,17)
				if !self.Owner:KeyDown(IN_ATTACK) || (self.HackingProgress > self.HackTime) || !IsValid(self.HackTarget) || (tr.Entity != self.HackTarget) then
					if IsValid(self.ef_radio) then
						self.ef_radio:Kill()
					end
					if tr.Entity != self.HackTarget then
						self:EmitSound("buttons/combine_button_locked.wav")
					elseif IsValid(self.HackTarget) && (self.HackingProgress > self.HackTime) then
						if SERVER then
							self.Owner:EmitSound("buttons/combine_button1.wav")
							local interaction = interactions[string.lower(self.HackTarget:GetClass())]
							if interaction then
								interaction.Action(self,self.HackTarget)
							else
								self.HackTarget:Fire("Use",nil,0)
							end
						end
					else
						self:EmitSound("buttons/combine_button_locked.wav")
					end
					self:SetChargeAttack()
					self.HackingProgress = 0
					return 1
				end
				return 0.05
			end
			function tab.FireFunc(self,item)
				tracep.start = self.Owner:GetShootPos()
				tracep.endpos = tracep.start+self.Owner:GetAimVector()*1000
				tracep.filter = self.Owner
				local tr = util.TraceHull(tracep)
				if IsValid(tr.Entity) then
					self.HackTarget = tr.Entity
					local interaction = interactions[string.lower(self.HackTarget:GetClass())]
					if interaction then
						self.HackTime = interaction.HackTime
					else
						self.HackTime = 5
					end
					self:SendWeaponAnim(ACT_VM_FIDGET)
					tab.Cooldown = 0.05
				else
					self:EmitSound("buttons/combine_button_locked.wav")
					tab.Cooldown = 1
					return false
				end
				if SERVER then
					self.ef_radio = self:CreateToggleEffect("scav_stream_radio")
				end
				self:SetChargeAttack(tab.ChargeAttack,item)
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/props/cs_office/projector_remote.mdl"] = GiveOneOfItemInf
			end
			ScavData.models["models/props/cs_office/projector_remote.mdl"] = tab
	end
		
		
		
/*==============================================================================================
	--SMG1 Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Grenade Launcher"
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
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound("weapons/ar2/ar2_altfire.wav")
						//gamemode.Call("ScavFired",self.Owner,proj)					
						return true
					end
			end
			tab.Cooldown = 1
		ScavData.models["models/items/ar2_grenade.mdl"] = tab
		ScavData.models["models/weapons/ar2_grenade.mdl"] = tab

/*==============================================================================================
	--Nailgun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Nail Gun"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
									local proj = self:CreateEnt("scav_projectile_shuriken")
									proj.Owner = self.Owner
									proj:SetOwner(self.Owner)
									proj:SetPos(self:GetProjectileShootPos())
									local ang = self.Owner:EyeAngles()
									ang:RotateAroundAxis(self.Owner:GetAimVector(),90)
									proj:SetAngles(ang)
									proj:SetModel(item.ammo)
									proj.Damage = 8
									proj.Penetration = 2
									proj:Spawn()
									proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*3000)
									proj:GetPhysicsObject():EnableGravity(false)
									self.Owner:SetAnimation(PLAYER_ATTACK1)
									self:EmitSound("Weapon_Pistol.Single")
									return self:TakeSubammo(item,1)
								end
				ScavData.CollectFuncs["models/weapons/w_models/w_nailgun.mdl"] = function(self,ent) self:AddItem("models/scav/nail.mdl",50,ent:GetSkin()) end
			else
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
						self:EmitSound("Weapon_Pistol.Single")
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.075
		ScavData.models["models/scav/nail.mdl"] = tab
		
/*==============================================================================================
	--Shurikens
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Shuriken Launcher"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
						//self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("scav_projectile_shuriken")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self:GetProjectileShootPos())
						local ang = self.Owner:EyeAngles()
						ang:RotateAroundAxis(self.Owner:GetAimVector(),90)
						proj:SetAngles(ang)
						proj:Spawn()
						if item.ammo == "models/scav/shuriken.mdl" then
							proj.Trail = util.SpriteTrail(proj,0,Color(255,255,255,255),true,2,0,0.3,0.25,"trails/smoke.vmt")
						end
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*3000)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound("weapons/ar2/fire1.wav")
						//gamemode.Call("ScavFired",self.Owner,proj)					
						return true
					end
			end
			tab.Cooldown = 0.2
		ScavData.models["models/scav/shuriken.mdl"] = tab
		
		
/*==============================================================================================
	--Tank shell
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Tank Rifle"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			PrecacheParticleSystem("scav_exp_fireball3_a")
			if SERVER then
				for i=3,7 do
					util.PrecacheModel("models/props_combine/breenbust_Chunk0"..i..".mdl")
				end
				tab.FireFunc = function(self,item)
						local tr = self.Owner:GetEyeTraceNoCursor()
						local ef = EffectData()
							ef:SetStart(self:GetPos())
							ef:SetOrigin(tr.HitPos)
							ef:SetEntity(self)
							ef:SetScale(4)
							util.Effect("ef_scav_tr2",ef,nil,true)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound("ambient/explosions/explode_1.wav")
						self.Owner:ViewPunch(Angle(-50,math.Rand(-0.1,0.1),0))
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
						sound.Play("ambient/explosions/explode_3.wav",self:GetPos(),100,100)
						//gamemode.Call("ScavFired",self.Owner,proj)					
						return true
					end
				ScavData.CollectFuncs["models/props/de_prodigy/ammo_can_02.mdl"] = function(self,ent) self:AddItem("models/weapons/w_bullet.mdl",1,0,4) end --4 tank shells from an ammo box
			end
			tab.Cooldown = 5
		ScavData.models["models/weapons/w_bullet.mdl"] = tab
		ScavData.models["models/scav/tankshell.mdl"] = tab

/*==============================================================================================
	--Strider Cannon
==============================================================================================*/
		
	
		local tab = {}
			tab.Name = "Strider Cannon"
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
			
		ScavData.models["models/combine_strider.mdl"] = tab
		ScavData.models["models/combine_strider_vsdog.mdl"] = tab
		ScavData.models["models/gibs/strider_weapon.mdl"] = tab
		
/*==============================================================================================
	--Spit Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Acid Lobber"
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
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 1
		ScavData.models["models/spitball_large.mdl"] = tab
		ScavData.models["models/spitball_medium.mdl"] = tab
		ScavData.models["models/spitball_small.mdl"] = tab
		//ScavData.models["models/gibs/antlion_worker_gibs_head.mdl"] = tab
		
/*==============================================================================================
	--bugbait
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Bugbait"
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
			end
			tab.Cooldown = 1
		ScavData.models["models/weapons/w_bugbait.mdl"] = tab
		

/*==============================================================================================
	--Gravity Gun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Gravity Gun"
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
		ScavData.models["models/weapons/w_physics.mdl"] = tab
		
		
/*==============================================================================================
	--Teleporter
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Teleporter"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 6
			tab.vmin = Vector(-24,-24,0)
			tab.vmax = Vector(24,24,0)
			PrecacheParticleSystem("portal_1_projectile_stream")
			if SERVER then
			
				util.AddNetworkString("scv_sfl")
				
				tab.Callback = function(self,tr)
									if tr.HitSky then
										return
									end
										local tracep = {}
										tracep.start = tr.HitPos+vector_up+tr.HitNormal*32
										tracep.endpos = tracep.start+vector_up*72
										tracep.filter = self.Owner
										tracep.mask = MASK_SHOT
										tracep.mins = Vector(-24,-24,0)
										tracep.maxs = Vector(24,24,0)
										local tr2 = util.TraceHull(tracep)
										if tr2.Hit then
											self.Owner:EmitSound("weapons/portalgun/portal_invalid_surface3.wav")
											return
										end
										local offset = tr.HitNormal*18
										if offset.z < 0 then
											self.Owner:EmitSound("weapons/portalgun/portal_invalid_surface3.wav")
											return
										else
											offset.z = 0
										end
										if tr.Hit then
											net.Start("scv_sfl")
												net.WriteEntity(self.Owner:GetWeapon("scav_gun"))
												net.WriteFloat(130)
												net.WriteFloat(1)
											net.Send(self.Owner)
											self.Owner:SetPos(tr.HitPos+offset)
											self.Owner:EmitSound("weapons/portalgun/portal_open3.wav")
										else
											self.Owner:EmitSound("weapons/portalgun/portal_invalid_surface3.wav")
										end
								end
				tab.proj = GProjectile()
				tab.proj:SetCallback(tab.Callback)
				tab.proj:SetBBox(Vector(-3,-3,-3),Vector(3,3,3))
				tab.proj:SetPiercing(false)
				tab.proj:SetGravity(vector_origin)
				tab.proj:SetMask(MASK_SHOT)
				local proj = tab.proj
			
				tab.FireFunc = function(self,item)
										local pos = self.Owner:GetShootPos()+self:GetAimVector()*24+self:GetAimVector():Angle():Right()*4-self:GetAimVector():Angle():Up()*4
										local tab = ScavData.models[item.ammo]
										local shootz = self.Owner:GetShootPos().z-self.Owner:GetPos().z
										//s_proj.AddProjectile(self.Owner,self.Owner:GetShootPos(),self:GetAimVector()*5000,ScavData.models[self.inv.items[1].ammo].Callback,false,false,vector_origin,self.Owner,Vector(-8,-8,-8),Vector(8,8,8))
										//					(Owner,     pos,                     velocity,                      callback,                                  ignoreworld,pierce,gravity,tablefilter,mins,maxs) --what the FUCK was I doing here?
										proj:SetOwner(self.Owner)
										proj:SetFilter(self.Owner)
										proj:SetPos(self.Owner:GetShootPos())
										proj:SetVelocity(self:GetAimVector()*2000*self.dt.ForceScale)
										proj:Fire()
										self.Owner:EmitSound("weapons/portalgun/portalgun_shoot_blue1.wav")
										local ef = EffectData()
										ef:SetOrigin(pos)
										ef:SetStart(self:GetAimVector()*2000*self.dt.ForceScale)
										ef:SetEntity(self.Owner)
										util.Effect("ef_scav_portalbeam",ef,nil,true)

										return false
								end
				ScavData.CollectFuncs["models/weapons/w_portalgun.mdl"] = ScavData.GiveOneOfItemInf
			else
				tab.FireFunc = function(self,item)
										local tr = self.Owner:GetEyeTraceNoCursor()
										local tab = ScavData.models[item.ammo]
										return false
								end
			end
			tab.Cooldown = 1
		ScavData.models["models/weapons/w_portalgun.mdl"] = tab
		
/*==============================================================================================
	--Frag Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Grenade Launcher"
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
						proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector())*5000,Vector(0,0,3)) --+Vector(0,0,0.1)
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(-5000,5000,0)) end)
						proj:Fire("SetTimer",2,"0")
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						//gamemode.Call("ScavFired",self.Owner,proj)					
						return true
					end
				ScavData.CollectFuncs["models/items/ammocrate_grenade.mdl"] = function(self,ent) self:AddItem("models/weapons/w_grenade.mdl",1,0,5) end --5 frag grenades from a grenade crate
			end
			tab.Cooldown = 1
		ScavData.models["models/items/grenadeammo.mdl"] = tab
		ScavData.models["models/weapons/w_grenade.mdl"] = tab





/*==============================================================================================
	--Helicopter Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Bomb"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
						local proj = self:CreateEnt("grenade_helicopter")
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
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
		ScavData.models["models/combine_helicopter/helicopter_bomb01.mdl"] = tab
		
/*==============================================================================================
	--Armor Battery
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Armor Battery"
			tab.anim = ACT_VM_FIDGET
			tab.Level = 1
			if SERVER then
				tab.FireFunc = function(self,item)
									if self.Owner:Armor() >= self.Owner:GetMaxArmor() then
										self.Owner:EmitSound("buttons/button11.wav")
										return false
									end
									self.Owner:SetArmor(math.min(self.Owner:GetMaxArmor(),self.Owner:Armor()+15))
									self.Owner:EmitSound("items/battery_pickup.wav")
									self.Owner:SendHUDOverlay(Color(0,100,255,100),0.25)
						return true
					end
			end
			tab.Cooldown = 0.2
		ScavData.models["models/items/battery.mdl"] = tab
		
/*==============================================================================================
	--Shotgun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Shotgun"
			//tab.anim = ACT_VM_RECOIL3
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 3
			if SERVER then
				local bullet = {}
					bullet.Num = 10
					bullet.Spread = Vector(0.075,0.03,0)
					bullet.Tracer = 1
					bullet.Force = 1000
					bullet.Damage = 5
					bullet.TracerName = "ef_scav_tr_b"
				function tab.OnArmed(self,item,olditemname)
					self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
				end
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-10,math.Rand(-0.1,0.1),0),0.3)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if item.ammo == "models/weapons/shells/shell_shotgun.mdl" then
							self.Owner:EmitToAllButSelf("weapons/shotgun_shoot.wav")
						else
							self.Owner:EmitToAllButSelf("weapons/shotgun/shotgun_fire6.wav")
						end
						self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
						return self:TakeSubammo(item,1)
					end
					
				ScavData.CollectFuncs["models/items/boxbuckshot.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell.mdl",20,0,1) end --20 shotgun shells from a box of shells
				ScavData.CollectFuncs["models/weapons/w_shotgun.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell.mdl",6,0,1) end --6 shotgun shells from a shotgun
				ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] = function(self,ent) self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0,1) end --6 shotgun shells from a shotgun (TF2)
				ScavData.CollectFuncs["models/weapons/c_models/c_scattergun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] --6 shotgun shells from a shotgun(TF2)
				ScavData.CollectFuncs["models/weapons/w_models/w_scattergun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] --6 shotgun shells from a shotgun(TF2)
				ScavData.CollectFuncs["models/weapons/c_models/c_double_barrel.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_shotgun.mdl"] --6 shotgun shells from a shotgun(TF2)
				ScavData.CollectFuncs["models/weapons/w_shot_m3super90.mdl"] = function(self,ent) self:AddItem("models/weapons/shotgun_shell.mdl",8,0,1) end --8 shotgun shells from a pump shotgun
			else
				local bullet = {}
					bullet.Num = 10
					bullet.Spread = Vector(0.075,0.03,0)
					bullet.Tracer = 1
					bullet.Force = 1000
					bullet.Damage = 7
					bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)		
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						if item.ammo == "models/weapons/shells/shell_shotgun.mdl" then
							self.Owner:EmitSound("weapons/shotgun_shoot.wav")
						else
							self.Owner:EmitSound("weapons/shotgun/shotgun_fire6.wav")
						end
						self.Owner:ScavViewPunch(Angle(-5,math.Rand(-0.1,0.1),0),0.3)
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 1
		ScavData.models["models/weapons/shells/shell_shotgun.mdl"] = tab
		ScavData.models["models/weapons/shotgun_shell.mdl"] = tab
		
/*==============================================================================================
	--Pistol
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Pistol"
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
			if SERVER then
				tab.FireFunc = function(self,item)
						local tab = ScavData.models[self.inv.items[1].ammo]
						self.Owner:ScavViewPunch(Angle(math.Rand(-1,1),math.Rand(-1,1),0),0.5)
						tab.bullet.Src = self.Owner:GetShootPos()
						tab.bullet.Dir = self:GetAimVector()

						self.Owner:FireBullets(tab.bullet)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self:MuzzleFlash2()
						if item.ammo == "models/weapons/w_models/w_pistol.mdl" then
							self.Owner:EmitToAllButSelf("weapons/pistol_shoot.wav")
						else
							self.Owner:EmitToAllButSelf("Weapon_Pistol.Single")
						end
						self.nextfireearly = CurTime()+0.1
						return self:TakeSubammo(item,1)
					end
				ScavData.CollectFuncs["models/items/boxsrounds.mdl"] = function(self,ent) self:AddItem("models/items/boxsrounds.mdl",20,0) end --20 pistol rounds from a box of bullets
				ScavData.CollectFuncs["models/weapons/w_pistol.mdl"] = function(self,ent) self:AddItem("models/weapons/w_pistol.mdl",18,0) end --18 pistol rounds from a HL2 pistol
				ScavData.CollectFuncs["models/weapons/w_models/w_pistol.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0) end --12 pistol rounds from a TF2 pistol
				ScavData.CollectFuncs["models/weapons/c_models/c_pistol.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_pistol.mdl"] --12 pistol rounds from a TF2 pistol
			else
				tab.FireFunc = function(self,item)
						local tab = ScavData.models["models/weapons/w_models/w_pistol.mdl"]
						self.Owner:ScavViewPunch(Angle(math.Rand(-1,1),math.Rand(-1,1),0),0.5)
						tab.bullet.Src = self.Owner:GetShootPos()
						tab.bullet.Dir = self:GetAimVector()
						tab.bullet.Spread = Vector(0.03,0.03,0)
						self.Owner:FireBullets(tab.bullet)
						self:MuzzleFlash2()
						if item.ammo == "models/weapons/w_models/w_pistol.mdl" then
							self.Owner:EmitSound("weapons/pistol_shoot.wav")
						else
							self.Owner:EmitSound("Weapon_Pistol.Single")
						end
						self.nextfireearly = CurTime()+0.1
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.4
		ScavData.models["models/items/boxsrounds.mdl"] = tab
		ScavData.models["models/weapons/w_pistol.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_pistol.mdl"] = tab
		ScavData.models["models/weapons/c_models/c_pistol.mdl"] = tab
		
/*==============================================================================================
	--pulse rifle
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Pulse Rifle"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 3
			tab.Callback = function(attacker,tr,dmg)
									local ef = EffectData()
									ef:SetOrigin(tr.HitPos)
									ef:SetNormal(tr.HitNormal)
									util.Effect("AR2Impact",ef)
								end
			if SERVER then
				local bullet = {}
					bullet.Num = 1
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 8
					bullet.TracerName = "AR2Tracer"
					bullet.Callback = tab.Callback
				tab.FireFunc = function(self,item)
						local scale1 = 1
						if self.mousepressed then
							scale1 = 1+math.Clamp((CurTime()-self.mousepressed),0,3)
						end
						bullet.Spread = Vector(0.02*scale1,0.02*scale1,0)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self:MuzzleFlash2(2)
						self:AddBarrelSpin(500)
						self.Owner:EmitToAllButSelf("Weapon_AR2.Single")
						return self:TakeSubammo(item,1)
					end
				
				ScavData.CollectFuncs["models/items/ammocrate_ar2.mdl"] = function(self,ent) self:AddItem("models/items/combine_rifle_cartridge01.mdl",30,0,3) end
				ScavData.CollectFuncs["models/items/combine_rifle_cartridge01.mdl"] = function(self,ent) self:AddItem("models/items/combine_rifle_cartridge01.mdl",30,0) end				
				ScavData.CollectFuncs["models/weapons/w_irifle.mdl"] = ScavData.CollectFuncs["models/items/combine_rifle_cartridge01.mdl"]
			else
				local bullet = {}
					bullet.Num = 1
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 11
					bullet.TracerName = "AR2Tracer"
					bullet.Callback = tab.Callback
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
						local scale1 = 1
						if self.mousepressed then
							scale1 = 1+math.Clamp((CurTime()-self.mousepressed),0,3)
						end
						self.Owner:ScavViewPunch(Angle(math.Rand(0,-1*scale1),math.Rand(-1*scale1,1*scale1),0),0.5)
						bullet.Spread = Vector(0.02*scale1,0.02*scale1,0)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2(2)
						self.Owner:EmitSound("Weapon_AR2.Single")
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.1
		ScavData.models["models/items/combine_rifle_cartridge01.mdl"] = tab
		
/*==============================================================================================
	--Strider Minigun
==============================================================================================*/
		local tab = {}
			tab.Name = "Strider Minigun"
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
			if SERVER then
				local bullet = {}
					bullet.Num = 1
					bullet.Tracer = 1
					bullet.Force = 20
					bullet.Damage = 30
					bullet.TracerName = "ef_scav_tr_strider"
					bullet.Callback = tab.Callback
				local ef = EffectData()
				tab.FireFunc = function(self,item)
						local scale1 = 1
						if self.mousepressed then
							scale1 = 4-math.Clamp((CurTime()-self.mousepressed),0,3)
						end

						bullet.Spread = Vector(0.02*scale1,0.02*scale1,0)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						ef:SetEntity(self)
						ef:SetOrigin(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
						ef:SetNormal(bullet.Dir)
						ef:SetScale(0.25)
						util.Effect("StriderMuzzleFlash",ef)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitToAllButSelf("NPC_Strider.FireMinigun")
						return self:TakeSubammo(item,1)
					end
				ScavData.CollectFuncs["models/gibs/strider_head.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,0,1) end
			else
				local bullet = {}
					bullet.Num = 1
					bullet.Tracer = 1
					bullet.Force = 20
					bullet.Damage = 30
					bullet.TracerName = "ef_scav_tr_strider"
					bullet.Callback = tab.Callback
				local ef = EffectData()
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
						local scale1 = 1
						if self.mousepressed then
							scale1 = 4-math.Clamp((CurTime()-self.mousepressed),0,3)
						end
						self.Owner:ScavViewPunch(Angle(math.Rand(0,-1*scale1),math.Rand(-1*scale1,1*scale1),0),0.5)
						bullet.Spread = Vector(0.02*scale1,0.02*scale1,0)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						ef:SetEntity(self)
						ef:SetScale(0.25)
						if self.Owner == GetViewEntity() then
							ef:SetEntity(self.Owner:GetViewModel())
							ef:SetOrigin(self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos)
						else
							ef:SetOrigin(self:GetAttachment(self:LookupAttachment("muzzle")).Pos)
						end
						ef:SetNormal(bullet.Dir)
						util.Effect("StriderMuzzleFlash",ef)
						self.Owner:EmitSound("NPC_Strider.FireMinigun")
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.2
		ScavData.models["models/gibs/strider_head.mdl"] = tab
		
/*==============================================================================================
	--Airboat Gun
==============================================================================================*/

		local tab = {}
			tab.Name = "Airboat Gun"
			tab.anim = ACT_VM_IDLE
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 9
			local returnval = {false,true}
			local function rechargeairboatgun(item)
				if item:IsValid() then
					if !item.isfiring then
						item:SetSubammo(math.min(item:GetSubammo()+1,100))
					end
					timer.Simple(0.05, function() rechargeairboatgun(item) end)
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
				timer.Simple(0.05, function() rechargeairboatgun(item) end)
			end
			if SERVER then
				local bullet = {}
					bullet.Num = 3
					bullet.Spread = Vector(0.01,0.01,0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 8
					bullet.TracerName = "AirboatGunTracer"
					bullet.Callback = tab.Callback
					bullet.DamageType = bit.bor(DMG_NEVERGIB,DMG_AIRBOAT)
				tab.ChargeAttack = function(self,item)
					if item.subammo <= 0 then
						self.ChargeAttack = nil
						self.soundloops.airboatgunfire:Stop()
						item.isfiring = false
						self.Owner:EmitToAllButSelf("weapons/airboat/airboat_gun_lastshot"..math.random(1,2)..".wav")
						return 0
					end
					if !self.Owner:KeyDown(IN_ATTACK) then
						self.ChargeAttack = nil
						self.soundloops.airboatgunfire:Stop()
						item.isfiring = false
						self.Owner:EmitToAllButSelf("weapons/airboat/airboat_gun_lastshot"..math.random(1,2)..".wav")
					end
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					self.Owner:FireBullets(bullet)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:MuzzleFlash2(2)
					self:TakeSubammo(item,1)
					return 0.05
				end

				tab.FireFunc = function(self,item)
					if item.subammo > 0 then
						item.isfiring = true
						self.soundloops.airboatgunfire = CreateSound(self.Owner,"weapons/airboat/airboat_gun_loop2.wav")
						self.soundloops.airboatgunfire:Play()
						self.chargeitem = item
						self.ChargeAttack = ScavData.models["models/airboatgun.mdl"].ChargeAttack
					end
					return false
				end
				
				ScavData.CollectFuncs["models/airboat.mdl"] = function(self,ent) self:AddItem("models/airboatgun.mdl",100,0,1) end
				ScavData.CollectFuncs["models/props_combine/bunker_gun01.mdl"] = function(self,ent) self:AddItem("models/props_combine/bunker_gun01.mdl",100,0,1) end
				
			else
				local bullet = {}
					bullet.Num = 3
					bullet.Spread = Vector(0.01,0.01,0)
					bullet.Tracer = 3
					bullet.Force = 5
					bullet.Damage = 11
					bullet.TracerName = "AirboatGunTracer"
					bullet.Callback = tab.Callback
				tab.ChargeAttack = function(self,item)
					if item.subammo <= 0 then
						item.isfiring = false
						self.ChargeAttack = nil
						self.Owner:EmitSound("weapons/airboat/airboat_gun_lastshot"..math.random(1,2)..".wav")
						return 0
					end
					if !self.Owner:KeyDown(IN_ATTACK) then
						item.isfiring = false
						self.ChargeAttack = nil
						self.Owner:EmitSound("weapons/airboat/airboat_gun_lastshot"..math.random(1,2)..".wav")
					end
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					self.Owner:FireBullets(bullet)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:MuzzleFlash2(2)
					self:TakeSubammo(item,1,true)
					return 0.05
				end
				tab.FireFunc = function(self,item)
					if item.subammo > 0 then
						item.isfiring = true
						self.chargeitem = item
						self.ChargeAttack = ScavData.models["models/airboatgun.mdl"].ChargeAttack
					end
					return false
				end
			end
			tab.Cooldown = 0.05
		ScavData.models["models/airboatgun.mdl"] = tab
		ScavData.models["models/props_combine/bunker_gun01.mdl"] = tab
/*==============================================================================================
	--Combine Ball
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Energy Ball"
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
			tab.Cooldown = 0.5
			
		ScavData.models["models/items/combine_rifle_ammo01.mdl"] = tab
		
/*==============================================================================================
	--Electricity beam
==============================================================================================*/

	local DoChargeSound
		local tab = {}
			tab.Name = "Shock Beam"
			tab.anim = ACT_VM_RECOIL2
			tab.Level = 4
			if SERVER then
				DoChargeSound = function(self,item,olditemname)
					if item.ammo != olditemname then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
				tab.OnArmed = DoChargeSound
				tab.FireFunc = function(self,item)
									if self.Owner:WaterLevel() > 1 then
										ScavData.Electrocute(self,self.Owner,self.Owner:GetPos(),500,500,true)
									else
										local proj = self:CreateEnt("scav_projectile_elec")
										proj.Owner = self.Owner
										proj:SetPos(self:GetProjectileShootPos())
										proj:SetAngles(self:GetAimVector():Angle())
										proj.vel = self:GetAimVector()*1500
										proj:SetOwner(self.Owner)
										proj.SpeedScale = self.dt.ForceScale
										proj:Spawn()
									end
									self.Owner:SetAnimation(PLAYER_ATTACK1)
									self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
									//self.Owner:EmitSound("ambient/energy/NewSpark1"..math.random(0,1)..".wav")
									//self.Owner:EmitSound("weapons/physcannon/superphys_small_zap4.wav")
									self.Owner:EmitSound("npc/scanner/scanner_electric1.wav")
									return self:TakeSubammo(item,1)
								end
								
				ScavData.CollectFuncs["models/props_c17/substation_transformer01d.mdl"] = function(self,ent) self:AddItem("models/props_c17/substation_transformer01d.mdl",15,0) end
				ScavData.CollectFuncs["models/weapons/w_stunbaton.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,0) end
				ScavData.CollectFuncs["models/weapons/w_models/w_sapper.mdl"] = ScavData.CollectFuncs["models/weapons/w_stunbaton.mdl"]
				ScavData.CollectFuncs["models/buildables/sapper_dispenser.mdl"] = ScavData.CollectFuncs["models/weapons/w_stunbaton.mdl"]
				ScavData.CollectFuncs["models/buildables/gibs/sapper_gib002.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),3,0) end
				ScavData.CollectFuncs["models/buildables/gibs/sapper_gib001.mdl"] = ScavData.CollectFuncs["models/buildables/gibs/sapper_gib002.mdl"]
			else
				tab.FireFunc = function(self,item)
									return self:TakeSubammo(item,1)
								end
			end
			tab.Cooldown = 0.5
			
		ScavData.models["models/props_c17/substation_transformer01d.mdl"] = tab
		ScavData.models["models/weapons/w_stunbaton.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_sapper.mdl"] = tab
		ScavData.models["models/buildables/gibs/sapper_gib001.mdl"] = tab
		ScavData.models["models/buildables/gibs/sapper_gib002.mdl"] = tab
		ScavData.models["models/buildables/sapper_dispenser.mdl"] = tab

/*==============================================================================================
	--Hyper beam
==============================================================================================*/
	local DoChargeSound
		local tab = {}
			tab.Name = "Hyper Beam"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			if SERVER then
				tab.OnArmed = DoChargeSound
				tab.FireFunc = function(self,item)
										local proj = self:CreateEnt("scav_projectile_hyper")
										self.Owner:EmitSound("ambient/explosions/explode_7.wav",100,190)
										proj.Owner = self.Owner
										proj:SetPos(self:GetProjectileShootPos())
										proj:SetAngles(self:GetAimVector():Angle())
										proj.vel = self:GetAimVector()*2000
										proj:SetOwner(self.Owner)
										proj:Spawn()
										self.Owner:SetAnimation(PLAYER_ATTACK1)
										self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
									return false
								end
				ScavData.CollectFuncs["models/metroid.mdl"] = ScavData.GiveOneOfItemInf
			else
				tab.FireFunc = function(self,item)
									return false
								end
			end
			tab.Cooldown = 0.3
			
		ScavData.models["models/metroid.mdl"] = tab
		
/*==============================================================================================
	--I just couldn't resist: The BFG9000
==============================================================================================*/
	local DoChargeSound
		
		local tab = {}
			tab.Name = "Plasma Charge"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = nil
			tab.RemoveOnCharge = false
			tab.Level = 9
			if SERVER then
				DoChargeSound = function(self,item,olditemname)
					if item.ammo != olditemname then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
				tab.OnArmed = DoChargeSound
				tab.ChargeAttack = function(self,item)
										local tab = ScavData.models["models/props_vehicles/generatortrailer01.mdl"]
										self.soundloops.bfgcharge:PlayEx(100,60+math.min(self.WeaponCharge,4)*40)
										self.soundloops.bfgcharge2:PlayEx(100,60+math.min(self.WeaponCharge,4)*40)
										if !self.Owner:KeyDown(IN_ATTACK) && (self.WeaponCharge >= 1) then
											local proj = self:CreateEnt("scav_projectile_bigshot")
											proj.Charge = math.floor(math.min(self.WeaponCharge,4))
											proj.Owner = self.Owner
											proj:SetPos(self:GetProjectileShootPos())
											proj:SetAngles(self:GetAimVector():Angle())
											proj:SetOwner(self.Owner)
											proj.SpeedScale = self.dt.ForceScale
											proj:Spawn()
											if proj:GetPhysicsObject():IsValid() then
												proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*500)
											end
											self.Owner:SetAnimation(PLAYER_ATTACK1)
											self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
											net.Start("scv_falloffsound")
												local rf = RecipientFilter()
												rf:AddAllPlayers()
												net.WriteVector(self:GetPos())
												net.WriteString("weapons/physgun_off.wav")
											net.Send(rf)
											self.soundloops.bfgcharge:Stop()
											self.soundloops.bfgcharge2:Stop()
											self.ChargeAttack = nil
											self.WeaponCharge = 0
											tab.chargeanim = ACT_VM_SECONDARYATTACK
											item.subammo = item.subammo-proj.Charge
											self:KillEffect()
											if item.subammo <= 0 then
												self:RemoveItemValue(item)
											end
											self:SetPanelPose(0,2)
											self:SetBlockPose(0,2)
											if IsValid(self.ef_plasmacharge) then
												self.ef_plasmacharge:Kill()
											end
											return 3
										else
											tab.chargeanim = nil
											self.WeaponCharge = self.WeaponCharge+0.05
											if self.WeaponCharge >= 6 and IsValid(self.Owner) then
												local proj = self:CreateEnt("scav_projectile_bigshot")
												proj.Charge = math.floor(math.min(self.WeaponCharge,4))
												proj.Owner = self.Owner
												proj:SetPos(self:GetProjectileShootPos())
												proj:SetAngles(self:GetAimVector():Angle())
												proj:SetOwner(self.Owner)
												proj.SpeedScale = self.dt.ForceScale
												proj:Spawn()
												proj:SetMoveType(MOVETYPE_NONE)
												proj:SetNoDraw(true)
												proj:ProcessImpact(self.Owner)
												net.Start("scv_falloffsound")
													local rf = RecipientFilter()
													rf:AddAllPlayers()
													net.WriteVector(self:GetPos())
													net.WriteString("weapons/physgun_off.wav")
												net.Send(rf)
												self.Owner:EmitSound("ambient/explosions/explode_3.wav")
												self.Owner:EmitSound("physics/body/body_medium_break3.wav")
												self.WeaponCharge = 0
												self.ChargeAttack = nil
												if self.Owner:Alive() then
													self.Owner:Kill()
												end
												return 3
											end
										end
										return 0.025
								end
				tab.FireFunc = function(self,item)
									self.ChargeAttack = ScavData.models["models/props_vehicles/generatortrailer01.mdl"].ChargeAttack
									self.Owner:EmitSound("HL1/ambience/particle_suck1.wav",100,200)
									if !self.soundloops.bfgcharge then
										self.soundloops.bfgcharge = CreateSound(self.Owner,"ambient/machines/combine_shield_loop3.wav")
										self.soundloops.bfgcharge2 = CreateSound(self.Owner,"npc/attack_helicopter/aheli_crash_alert2.wav")
									end
									self.chargeitem = item
									self.ef_plasmacharge = self:CreateToggleEffect("scav_stream_plasmacharge")
									self:SetPanelPose(0.5,0.25)
									self:SetBlockPose(0.5,0.25)
									return false
								end
				ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),4,0) end
				ScavData.CollectFuncs["models/props_mining/diesel_generator.mdl"] = ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"]
			else
				tab.ChargeAttack = function(self,item)
									local tab = ScavData.models["models/props_vehicles/generatortrailer01.mdl"]
										if !self.Owner:KeyDown(IN_ATTACK) && (self.WeaponCharge >= 1) then
											self.Owner:SetAnimation(PLAYER_ATTACK1)
											self.ChargeAttack = nil
											item.subammo = item.subammo-math.floor(math.min(self.WeaponCharge,4))
											self.WeaponCharge = 0
											tab.chargeanim = ACT_VM_SECONDARYATTACK											
											return 3
										else
											self.WeaponCharge = self.WeaponCharge+0.05
											tab.chargeanim = ACT_VM_FIDGET
											if self.WeaponCharge >= 6 then
												ParticleEffect("scav_exp_bigshot",self.Owner:GetPos(),Angle(0,0,0),Entity(0))
												self.WeaponCharge = 0
												self.ChargeAttack = nil
												return 3
											end
										end
										return 0.025
								end
				tab.FireFunc = function(self,item)
					//ParticleEffectAttach("scav_bigshot_charge",PATTACH_POINT_FOLLOW,self.Owner:GetViewModel(),self.Owner:GetViewModel():LookupAttachment("muzzle"))
					self.ChargeAttack = ScavData.models["models/props_vehicles/generatortrailer01.mdl"].ChargeAttack
					self.chargeitem = item
					return false
				end
			end
			tab.Cooldown = 0.1
			
		ScavData.models["models/props_vehicles/generatortrailer01.mdl"] = tab
		ScavData.models["models/props_mining/diesel_generator.mdl"] = tab
		
/*==============================================================================================
	--..Or this..
==============================================================================================*/
		local tab = {}
			tab.Name = "Cannon"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_FIDGET
			tab.RemoveOnCharge = false
			tab.Level = 7
			if SERVER then
				tab.ChargeAttack = function(self,item)
										local tab = ScavData.models["models/props_phx/cannonball.mdl"]
										if (!self.Owner:KeyDown(IN_ATTACK) && (self.WeaponCharge >= 0)) || (self.WeaponCharge >= 1) then
											local proj = self:CreateEnt("scav_projectile_cannonball")
											proj:SetModel(item.ammo)
											proj.Charge = self.WeaponCharge
											proj.Owner = self.Owner
											proj:SetPos(self:GetProjectileShootPos())
											proj:SetAngles(self:GetAimVector():Angle())
											proj:SetOwner(self.Owner)
											proj:Spawn()
											proj:SetPos(self.Owner:GetShootPos()-proj:OBBCenter())
											proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*((self.WeaponCharge*3000)+500))
											proj:SetPhysicsAttacker(self.Owner)
											proj:GetPhysicsObject():SetDragCoefficient(-10000)
											self.Owner:SetAnimation(PLAYER_ATTACK1)
											//self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
											self.ChargeAttack = nil
											self.WeaponCharge = 0
											tab.chargeanim = ACT_VM_SECONDARYATTACK
											item.subammo = item.subammo-proj.Charge
											self:KillEffect()
											self:RemoveItemValue(item)
											self.soundloops.cannon:Stop()
											self.Owner:EmitSound(self.shootsound)
											return 1
										else
											tab.chargeanim = ACT_VM_FIDGET
											self.WeaponCharge = self.WeaponCharge+0.05
										end
										return 0.1
								end
				tab.FireFunc = function(self,item)
									if !self.soundloops.cannon then
										self.soundloops.cannon = CreateSound(self.Owner,"weapons/stickybomblauncher_charge_up.wav")
										self.soundloops.cannon:ChangePitch(160)
									end
									self.soundloops.cannon:Play()
									self.ChargeAttack = ScavData.models["models/props_phx/cannonball.mdl"].ChargeAttack
									self.chargeitem = item
									return false
								end
			else
				tab.ChargeAttack = function(self,item)
									local tab = ScavData.models["models/props_phx/cannonball.mdl"]
										if (!self.Owner:KeyDown(IN_ATTACK) && (self.WeaponCharge >= 0)) || (self.WeaponCharge >= 1) then
											self.Owner:SetAnimation(PLAYER_ATTACK1)
											self.ChargeAttack = nil
											self.WeaponCharge = 0
											tab.chargeanim = ACT_VM_SECONDARYATTACK											
											return 1
										else
											self.WeaponCharge = self.WeaponCharge+0.05
											tab.chargeanim = ACT_VM_FIDGET
										end
										return 0.1
								end
				tab.FireFunc = function(self,item)
					self.ChargeAttack = ScavData.models["models/props_phx/cannonball.mdl"].ChargeAttack
					self.chargeitem = item
					return false
				end
			end
			tab.Cooldown = 0.1
			
		ScavData.models["models/props_phx/cannonball.mdl"] = tab

		

/*==============================================================================================
	--Grappling Beam
==============================================================================================*/
 

		local tab = {}
			tab.Name = "Grappling Beam"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 3
			tab.chargeanim = ACT_VM_FIDGET
			tab.RemoveOnCharge = false
			tab.Cooldown = 0.1
			if SERVER then
				hook.Add("PlayerDeath","scv_cleargrapple",function(pl) if pl.GrappleAssist && pl.GrappleAssist:IsValid() then pl.GrappleAssist:Remove() end end)
				tab.ChargeAttack = function(self,item)
										local tab = ScavData.models["models/props_wasteland/cranemagnet01a.mdl"]
										if self.grapplenohit then
											self.grapplenohit = nil
											if IsValid(self.ef_grapplebeam) then
												self.ef_grapplebeam:Kill()
											end
											self.ChargeAttack = nil
											tab.chargeanim = ACT_VM_IDLE
											return 0.5
										end
										if !self.Owner:KeyDown(IN_ATTACK) || !self.GrappleAssist:IsValid() then --let go
											//local eyeang = self.Owner:EyeAngles()
											//eyeang.r = 0
											self.ChargeAttack = nil
											tab.chargeanim = ACT_VM_PRIMARYATTACK
											if IsValid(self.ef_grapplebeam) then
												self.ef_grapplebeam:Kill()
											end
											self.Owner:SetMoveType(MOVETYPE_WALK)
											if self.GrappleAssist:IsValid() then
												local vel = self.GrappleAssist:GetVelocity()
												//vel.x = vel.x*16
												//vel.y = vel.y*16
												if vel.z < 0 then
													vel.z = 0
												end
												local length = math.max(vel:Length(),200)
												self.Owner:SetVelocity(vel:GetNormalized()*length)
												self.GrappleAssist:Remove()
												self.dt.NWFiremodeEnt = NULL
											//else
											
											end
											return 0.25
										else --grappling
											tab.chargeanim = ACT_VM_FIDGET
											self.Owner:SetLocalPos(vector_origin)
											if self.Owner:KeyDown(IN_JUMP) then
												self.GrappleTargetLength = math.min(self.GrappleTargetLength+3,1024)
											end
											if self.Owner.scavGoDown then
												self.GrappleTargetLength = math.max(self.GrappleTargetLength-3,64)
											end
											if self.Owner:KeyDown(IN_MOVELEFT) then
												self.GrappleAssist:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAngles()):Right()*-200)
											end
											if self.Owner:KeyDown(IN_MOVERIGHT) then
												self.GrappleAssist:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAngles()):Right()*200)
											end
											if self.Owner:KeyDown(IN_FORWARD) then
												self.GrappleAssist:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAngles()):Forward()*200)
											end
											if self.Owner:KeyDown(IN_BACK) then
												self.GrappleAssist:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAngles()):Forward()*-200)
											end
											
											if self.GrappleAssistConstraint && self.GrappleAssistConstraint:IsValid() then
												local length = math.Approach(self.GrappleAssistConstraint.length,self.GrappleTargetLength,3)
												self.GrappleAssistConstraint.length = length
												self.GrappleAssistConstraint:Fire("SetSpringLength",length,0)
												table.insert(self.GrappleAssist.AvgVel,1,self.GrappleAssist:GetPhysicsObject():GetVelocity())
												if self.GrappleAssist.AvgVel[15] then
													table.remove(self.GrappleAssist.AvgVel,15)
												end
											end
										end
										return 0.01
								end
				tab.FireFunc = function(self,item)
									local tracep = {}
										tracep.mask = MASK_SHOT
										tracep.mins = Vector(-8,-8,-8)
										tracep.maxs = Vector(8,8,8)
										tracep.start = self.Owner:GetShootPos()
										tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*1024
										tracep.filter = self.Owner
										local tr = util.TraceHull(tracep)
									self.chargeitem = item
									self.ChargeAttack = ScavData.models["models/props_wasteland/cranemagnet01a.mdl"].ChargeAttack
									if tr.Hit && ((tr.MatType == MAT_METAL) || (tr.MatType == MAT_GRATE)) then
										if !tr.Entity:IsValid() then
											tr.Entity = game.GetWorld()
										end
										self.ef_grapplebeam = self:CreateToggleEffect("scav_stream_grapplebeam")
										self.ef_grapplebeam:SetEndPoint(tr.Entity:WorldToLocal(tr.HitPos))
										self.ef_grapplebeam:SetEndEnt(tr.Entity)
										local eyeang = self.Owner:EyeAngles()
										self.GrappleAssist = ents.Create("scav_grappleassist")
										self.Owner.GrappleAssist = self.GrappleAssist
											self.GrappleAssist:SetModel("models/props_c17/canister_propane01a.mdl")
											self.GrappleAssist:SetPos(self.Owner:GetPos())
											//self.GrappleAssist:SetAngles(self.Owner:GetAngles())
											self.GrappleAssist:Spawn()
											self.dt.NWFiremodeEnt = self.GrappleAssist
											self.GrappleAssist:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
											self.GrappleAssist:GetPhysicsObject():SetDamping(0,9000)
											self.GrappleAssist:GetPhysicsObject():SetMaterial("gmod_silent")
											self.GrappleAssist:SetNoDraw(true)
											self.GrappleAssist:DrawShadow(false)
											self.GrappleAssist.NoScav = true
											self.GrappleAssist.AvgVel = {}
											//self.GrappleAssist:GetPhysicsObject():SetDragCoefficient(10) --keep it from going too fast
											self.GrappleAssist:GetPhysicsObject():SetMass(85) --keep it from being wobbly
										self.Owner:SetMoveType(MOVETYPE_VPHYSICS)
										self.Owner:SetParent(self.GrappleAssist)
										self.Owner:SetLocalPos(vector_origin)
										self.Owner:SetLocalAngles(Angle(0,0,0))
										local constr,rope = constraint.Elastic(self.GrappleAssist,tr.Entity,0,0,Vector(0,0,72),tr.HitPos-tr.Entity:GetPos(),99999,50,0,"cable/physbeam",0,false)
										//self.GrappleTargetLength = math.min((self.GrappleAssist:GetPos()+Vector(0,0,72)):Distance(tr.HitPos),150)
										self.GrappleTargetLength = 200
										self.GrappleAssistConstraint = constr
										//self.Owner:SnapEyeAngles(eyeang)
										//print(constr:GetClass())
									elseif tr.Hit then
										self.grapplenohit = true
										tr.Entity:TakeDamage(10,self.Owner,self)
										self.ef_grapplebeam = self:CreateToggleEffect("scav_stream_grapplebeam")
										self.ef_grapplebeam:SetEndPoint(tr.HitPos)
									else
										self.grapplenohit = true
										self.GrappleAssist = NULL
										self.GrappleTargetLength = 0
										self.ef_grapplebeam = self:CreateToggleEffect("scav_stream_grapplebeam")
										self.ef_grapplebeam:SetEndPoint(tr.HitPos)
									end
									return false
								end
			ScavData.CollectFuncs["models/props_wasteland/cranemagnet01a.mdl"] = ScavData.GiveOneOfItemInf
			else
				tab.ChargeAttack = function(self,item)
									local tab = ScavData.models["models/props_wasteland/cranemagnet01a.mdl"]
										local par = self.dt.NWFiremodeEnt
										if !self.Owner:KeyDown(IN_ATTACK) then
											self.Owner:SetAnimation(PLAYER_ATTACK1)
											self.ChargeAttack = nil
											//self.WeaponCharge = 0
											tab.chargeanim = ACT_VM_PRIMARYATTACK
											if par:IsValid() then
												self:SetViewLerp(EyeAngles(),0.3)
												local ang = self:GetAimVector():Angle()
												ang.r = 0
												self.Owner:SetEyeAngles(ang)
											end
											return 0.25
										elseif IsValid(par) then
											//self.WeaponCharge = self.WeaponCharge+0.2
											tab.chargeanim = ACT_VM_FIDGET
										else
											tab.chargeanim = nil
										end
										return 0.01
								end
				tab.FireFunc = function(self,item)
					self.ChargeAttack = ScavData.models["models/props_wasteland/cranemagnet01a.mdl"].ChargeAttack
					self.chargeitem = item
					return false
				end
			end
			
			concommand.Add("+sgrapdown",function(pl,cmd,args) pl.scavGoDown = true end)
			concommand.Add("-sgrapdown",function(pl,cmd,args) pl.scavGoDown = false end)
			
			if CLIENT then
				hook.Add("PlayerBindPress","scavgrap",function(pl,bind,pressed)
					local ent = pl:GetParent()
					if (bind == "+duck") && IsValid(ent) && (ent:GetClass() == "scav_grappleassist") then
						if pressed then
							RunConsoleCommand("+sgrapdown")
						else
							RunConsoleCommand("-sgrapdown")
						end
						return true
					end
				end)
			end
			
		ScavData.RegisterFiremode(tab,"models/props_wasteland/cranemagnet01a.mdl")
		


/*==============================================================================================
	--Supersonic Shockwave
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Supersonic Shockwave"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
										local proj = self:CreateEnt("scav_projectile_shockwave")
										proj.Owner = self.Owner
										proj:SetPos(self:GetProjectileShootPos())
										//proj:SetPos(self.Owner:GetShootPos()-self:GetAimVector()*15+self:GetAimVector():Angle():Right()*6-self:GetAimVector():Angle():Up()*8)
										proj:SetAngles(self:GetAimVector():Angle())
										proj.vel = self:GetAimVector()*2500
										proj:SetOwner(self.Owner)
										proj:Spawn()
										self.Owner:SetAnimation(PLAYER_ATTACK1)
										self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
										self.Owner:EmitSound("ambient/explosions/explode_9.wav")
										self.Owner:EmitSound("ambient/explosions/explode_9.wav")
										self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav")
										return self:TakeSubammo(item,1)
								end
				ScavData.CollectFuncs["models/props/cs_office/radio.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
				ScavData.CollectFuncs["models/props/cs_office/radio_p1.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/props_c17/canister01a.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/props_c17/canister02a.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
			else
				tab.FireFunc = function(self,item)
									return self:TakeSubammo(item,1)
								end
			end
			tab.Cooldown = 0.75
			
		ScavData.models["models/props/cs_office/radio.mdl"] = tab
		ScavData.models["models/props/cs_office/radio_p1.mdl"] = tab
		ScavData.models["models/props_c17/canister01a.mdl"] = tab
		ScavData.models["models/props_c17/canister02a.mdl"] = tab

/*==============================================================================================
	--Disease Shot
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Disease Shot"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
										local proj = self:CreateEnt("scav_projectile_bio")
										proj.Owner = self.Owner
										proj:SetPos(self:GetProjectileShootPos())
										//proj:SetPos(self.Owner:GetShootPos()-self:GetAimVector()*15+self:GetAimVector():Angle():Right()*6-self:GetAimVector():Angle():Up()*8)
										proj:SetAngles(self:GetAimVector():Angle())
										proj.vel = self:GetAimVector()*2500
										proj.SpeedScale = self.dt.ForceScale
										proj:SetOwner(self.Owner)
										proj:Spawn()
										self.Owner:SetAnimation(PLAYER_ATTACK1)
										self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
										return self:TakeSubammo(item,1)
								end
				ScavData.CollectFuncs["models/props/de_train/biohazardtank.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props/cs_militia/toilet.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_badlands/barrel01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),2,ent:GetSkin()) end
			else
				tab.FireFunc = function(self,item)
									return self:TakeSubammo(item,1)
								end
			end
			tab.Cooldown = 1
			
		ScavData.models["models/props/de_train/biohazardtank.mdl"] = tab
		ScavData.models["models/props/cs_militia/toilet.mdl"] = tab
		ScavData.models["models/props_badlands/barrel01.mdl"] = tab

/*==============================================================================================
	--Helicopter Minigun
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Helicopter Minigun"
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
										self:TakeSubammo(item,1)
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
			
		ScavData.models["models/combine_helicopter.mdl"] = tab		
		
/*==============================================================================================
	--sniper rifle
==============================================================================================*/

		do
			local tab = {}
			local dmgmodifier = function(attacker,tr,dmg)
					if tr.HitGroup == HITGROUP_HEAD then
						dmg:ScaleDamage(10)
					end
				end
			local bullet = {}
				bullet.Num = 1
				bullet.Spread = vector_origin
				bullet.Tracer = 1
				bullet.Force = 5
				bullet.Damage = 40
				bullet.TracerName = "ef_scav_tr_strider"
				tab.Name = "Sniper Rifle"
				tab.anim = ACT_VM_IDLE
				tab.Level = 6
				tab.Cooldown = 0.01
				tab.fov = 5
				function tab.ChargeAttack(self,item)
					if CurTime()-self.sniperzoomstart > 0.5 then
						self.dt.Zoomed = true
					end
					if !self.Owner:KeyDown(IN_ATTACK) then
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						self:TakeSubammo(item,1)
						self:SetChargeAttack()
						self:EmitSound("NPC_Sniper.FireBullet")
						if SERVER then
							if IsValid(self.ef_lsight) then
								self.ef_lsight:Kill()
							end
							if (item.subammo <= 0) then
								self:RemoveItemValue(item)
							end
						end
						self.dt.Zoomed = false
						tab.chargeanim = ACT_VM_SECONDARYATTACK
						return 1
					end
					tab.chargeanim = ACT_VM_IDLE
					return 0.05
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_lsight = self:CreateToggleEffect("scav_stream_sniper")
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					self.sniperzoomstart = CurTime()
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"] = function(self,ent) self:AddItem("models/weapons/rifleshell.mdl",1,0,5) end
					ScavData.CollectFuncs["models/weapons/w_combine_sniper.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
					ScavData.CollectFuncs["models/weapons/shells/shell_sniperrifle.mdl"] = function(self,ent) self:AddItem("models/weapons/rifleshell.mdl",1,0,1) end
				end
				ScavData.RegisterFiremode(tab,"models/weapons/rifleshell.mdl")
		end
		

/*==============================================================================================
	-- Combine Binoculars
==============================================================================================*/
		
local tab = {}
			tab.Name = "Scope"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			if SERVER then
				tab.FireFunc = function(self,item)
					end
				ScavData.CollectFuncs["models/props_combine/combine_binocular01.mdl"] = ScavData.GiveOneOfItemInf
			else
				tab.fov = 2
				tab.FireFunc = function(self,item)
									local tab = ScavData.models[item.ammo]
									if !self.dt.Zoomed then
										tab.fov = 10
										self.dt.Zoomed = true
									elseif (tab.fov == 10) && self.dt.Zoomed then
										tab.fov = 5
									elseif tab.fov == 5 then
										tab.fov = 2
									elseif tab.fov == 2 then
										tab.fov = 1
									elseif tab.fov == 1 then
										tab.fov = 10
										self.dt.Zoomed = false
									end
									self.Owner:EmitSound("buttons/lightswitch2.wav")
								end
			end
			tab.Cooldown = 0.25
		ScavData.models["models/props_combine/combine_binocular01.mdl"] = tab
		
/*==============================================================================================
	-- Medkits
==============================================================================================*/
		
local tab = {}
			tab.Name = "Medkit"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.vmin = Vector(-12,-12,-12)
			tab.vmax = Vector(12,12,12)			
			if SERVER then
				tab.FireFunc = function(self,item)
									local healent = self.Owner
									local tab = ScavData.models[self.inv.items[1].ammo]
									local tracep = {}
									tracep.start = self.Owner:GetShootPos()
									tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*100
									tracep.filter = self.Owner
									tracep.mask = MASK_SHOT
									tracep.mins = tab.vmin
									tracep.maxs = tab.vmax
									local tr = util.TraceHull(tracep)
									if (tr.Entity:IsPlayer() || tr.Entity:IsNPC()) && (tr.Entity:Health() < tr.Entity:GetMaxHealth()) then
										healent = tr.Entity
									end
									if healent:Health() >= healent:GetMaxHealth() then
											healent:EmitSound("buttons/button11.wav")
											tab.Cooldown = 0.2
										return false
									end
									local starthealth = healent:Health()
									if item.ammo == "models/items/healthkit.mdl" then
										healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+25))
										healent:EmitSound("items/smallmedkit1.wav")
									elseif item.ammo == "models/healthvial.mdl" then
										healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+10))
										healent:EmitSound("items/smallmedkit1.wav")
									elseif item.ammo == "models/items/medkit_small.mdl" then
										healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+healent:GetMaxHealth()/4))
										healent:EmitSound("items/smallmedkit1.wav")
									elseif item.ammo == "models/items/medkit_medium.mdl" then
										healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+healent:GetMaxHealth()/2))
										healent:EmitSound("items/smallmedkit1.wav")
									elseif item.ammo == "models/items/medkit_large.mdl" then
										healent:SetHealth(healent:GetMaxHealth())
										healent:EmitSound("items/smallmedkit1.wav")
									end
									local ef = EffectData()
									ef:SetRadius(healent:Health()-starthealth)
									ef:SetOrigin(self.Owner:GetPos())
									ef:SetScale(self.Owner:EntIndex())
									ef:SetEntity(healent)
									util.Effect("ef_scav_heal",ef,nil,true)
									tab.Cooldown = 2
									return true
								end
			end
			tab.Cooldown = 2
		ScavData.models["models/items/healthkit.mdl"] = tab
		ScavData.models["models/healthvial.mdl"] = tab
		ScavData.models["models/items/medkit_small.mdl"] = tab
		ScavData.models["models/items/medkit_medium.mdl"] = tab
		ScavData.models["models/items/medkit_large.mdl"] = tab
		
		
/*==============================================================================================
	-- Sandwich
==============================================================================================*/
		
local tab = {}
			tab.Name = "Sandwich?"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			if SERVER then
				tab.FireFunc = function(self,item)
									if self.Owner:Health() >= self.Owner:GetMaxHealth() then
										self.Owner:EmitSound("vo/heavy_no02.wav")
										return false
									else
										self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(),self.Owner:Health()+50))
										self.Owner:EmitSound("vo/SandwichEat09.wav")
									end
									return true
								end
			end
			tab.Cooldown = 2
		ScavData.models["models/weapons/c_models/c_sandwich/c_sandwich.mdl"] = tab
		
/*==============================================================================================
	-- .357 rounds
==============================================================================================*/

		local tab = {}
			tab.Name = ".357 Revolver"
			tab.anim = ACT_VM_RECOIL2
			tab.Level = 4
			if SERVER then
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
						self.Owner:EmitToAllButSelf("Weapon_357.Single")
						self.Owner:ScavViewPunch(Angle(-15,math.Rand(-0.1,0.1),0),0.5)
						return self:TakeSubammo(item,1)
					end
				
				ScavData.CollectFuncs["models/items/357ammo.mdl"] = function(self,ent) self:AddItem("models/weapons/w_357.mdl",6,0,1) end --6 .357 rounds from a box of bullets
				ScavData.CollectFuncs["models/items/357ammobox.mdl"] = ScavData.CollectFuncs["models/items/357ammo.mdl"] --6 .357 rounds from a box of bullets
				ScavData.CollectFuncs["models/weapons/w_models/w_revolver.mdl"] = ScavData.CollectFuncs["models/items/357ammo.mdl"] --6 .357 rounds from a box of bullets
				ScavData.CollectFuncs["models/weapons/c_models/c_ambassador/c_ambassador.mdl"] = ScavData.CollectFuncs["models/items/357ammo.mdl"] --6 .357 rounds from a box of bullets
				ScavData.CollectFuncs["models/weapons/c_models/c_revolver/c_revolver.mdl"] = ScavData.CollectFuncs["models/items/357ammo.mdl"] --6 .357 rounds from a box of bullets		
				ScavData.CollectFuncs["models/weapons/w_357.mdl"] = ScavData.CollectFuncs["models/items/357ammo.mdl"] --6 .357 rounds from a box of bullets
				ScavData.CollectFuncs["models/weapons/w_annabelle.mdl"] = function(self,ent) self:AddItem("models/weapons/w_357.mdl",2,0,1) end --2 .357 rounds from the Annabelle
			else
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
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
						self.Owner:EmitSound("Weapon_357.Single")
						self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle())
						self.Owner:ScavViewPunch(Angle(-15,math.Rand(-0.1,0.1),0),0.5)
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 1
		ScavData.models["models/weapons/w_357.mdl"] = tab
		
/*==============================================================================================
	--machinegun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Sub-Machine Gun"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 3
			if SERVER then
					
				tab.FireFunc = function(self,item)
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
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitToAllButSelf("Weapon_SMG1.Single")
						self:MuzzleFlash2()
						self:AddBarrelSpin(200)
						return self:TakeSubammo(item,1)
					end
				
				ScavData.CollectFuncs["models/items/ammocrate_smg1.mdl"] = function(self,ent) self:AddItem("models/weapons/w_smg1.mdl",45,0,3) end
				ScavData.CollectFuncs["models/items/ammocrate_smg2.mdl"] = ScavData.CollectFuncs["models/items/ammocrate_smg1.mdl"]
				ScavData.CollectFuncs["models/items/boxmrounds.mdl"] = function(self,ent) self:AddItem("models/items/boxmrounds.mdl",20,0) end
				ScavData.CollectFuncs["models/weapons/w_smg1.mdl"] = function(self,ent) self:AddItem("models/weapons/w_smg1.mdl",45,0) end
				ScavData.CollectFuncs["models/weapons/w_models/w_smg.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_smg.mdl",25,0) end
			else
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
						local bullet = {}
						bullet.Num = 1
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = Vector(0.05,0.05,0)
						bullet.Tracer = 2
						bullet.Force = 5
						bullet.Damage = 12
						bullet.TracerName = "ef_scav_tr_b"
						self.Owner:FireBullets(bullet)
						self.Owner:EmitSound("Weapon_SMG1.Single")
						self:MuzzleFlash2()
						self.Owner:ScavViewPunch(Angle(math.Rand(-0.2,0.2),math.Rand(-0.2,0.2),0),0.1)
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.05
		ScavData.models["models/items/boxmrounds.mdl"] = tab
		ScavData.models["models/weapons/w_smg1.mdl"] = tab
		ScavData.models["models/weapons/w_models/w_smg.mdl"] = tab

/*==============================================================================================
	--plasmagun
==============================================================================================*/

PrecacheParticleSystem("scav_plasma_1")
PrecacheParticleSystem("scav_exp_plasma")

		local tab = {}
			tab.Name = "Plasma Gun"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 4
			if SERVER then
				tab.Callback = function(self,tr)	
								if tr.Entity && tr.Entity:IsValid() then
									local dmg = DamageInfo()
									dmg:SetDamage(15)
									dmg:SetDamageForce(vector_origin)
									dmg:SetDamagePosition(tr.HitPos)
									if self:GetOwner():IsValid() then
										dmg:SetAttacker(self:GetOwner())
									end
									if self:GetInflictor():IsValid() then
										dmg:SetInflictor(self:GetInflictor())
									end
									dmg:SetDamageType(DMG_PLASMA)
									tr.Entity:TakeDamageInfo(dmg)
									//tr.Entity:TakeDamage(15,self.Owner,self.Owner)
								end 
							end
				tab.proj = GProjectile()
				tab.proj:SetCallback(tab.Callback)
				tab.proj:SetBBox(Vector(-8,-8,-8),Vector(8,8,8))
				tab.proj:SetPiercing(false)
				tab.proj:SetGravity(vector_origin)
				tab.proj:SetMask(MASK_SHOT)
				local proj = tab.proj
				tab.OnArmed = DoChargeSound
				tab.FireFunc = function(self,item)
									local pos = self.Owner:GetShootPos()+self:GetAimVector()*24+self:GetAimVector():Angle():Right()*4-self:GetAimVector():Angle():Up()*4
									local vel = self:GetAimVector()*2000*self.dt.ForceScale
									//local proj = s_proj.AddProjectile(self.Owner,pos,self:GetAimVector()*2000,ScavData.models[self.inv.items[1].ammo].Callback,false,false,vector_origin,self.Owner,Vector(-8,-8,-8),Vector(8,8,8))
									proj:SetOwner(self.Owner)
									proj:SetInflictor(self)
									proj:SetPos(pos)
									proj:SetVelocity(vel)
									proj:SetFilter(self.Owner)
									proj:Fire()
									local ef = EffectData()
									ef:SetOrigin(pos)
									ef:SetStart(vel)
									ef:SetEntity(self.Owner)
									util.Effect("ef_scav_plasma",ef)
									self:MuzzleFlash2(3)
									//self.Owner:EmitToAllButSelf("weapons/physcannon/energy_bounce2.wav",80,150)
									item.lastsound = item.lastsound||0
									self:StopSound("weapons/physcannon/energy_disintegrate"..(4+item.lastsound)..".wav")
									item.lastsound = 1-(item.lastsound)
									self:AddBarrelSpin(200)
									self:EmitSound("weapons/physcannon/energy_disintegrate"..(4+item.lastsound)..".wav",80,255)
									return self:TakeSubammo(item,1)
								end
				ScavData.CollectFuncs["models/items/car_battery01.mdl"] = function(self,ent) self:AddItem("models/items/car_battery01.mdl",50,0) end
			else
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
						local pos = self.Owner:GetShootPos()+self:GetAimVector()*24+self:GetAimVector():Angle():Right()*4-self:GetAimVector():Angle():Up()*4
						local ef = EffectData()
						ef:SetOrigin(pos)
						ef:SetStart(self:GetAimVector()*2000*self.dt.ForceScale)
						ef:SetEntity(self.Owner)
						util.Effect("ef_scav_plasma",ef)
						self:MuzzleFlash2(3)
						item.lastsound = item.lastsound||0
						self:StopSound("weapons/physcannon/energy_disintegrate"..(4+item.lastsound)..".wav")
						item.lastsound = 1-(item.lastsound)
						self:EmitSound("weapons/physcannon/energy_disintegrate"..(4+item.lastsound)..".wav",80,255)
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.1
		ScavData.models["models/items/car_battery01.mdl"] = tab

/*==============================================================================================
	--Frag 12 High-Explosive round
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Explosive Shell"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 7
			tab.bullet = {}
			tab.bullet.Num = 1
			tab.bullet.Spread = Vector(0.03,0.03,0)
			tab.bullet.Tracer = 1
			tab.bullet.Force = 0
			tab.bullet.Damage = 5
			tab.bullet.TracerName = "ef_scav_tr_b"
			tab.bullet.Callback = function(attacker,tr,dmginfo)
									if tr.HitSky then
										return true
									end
									local ef = EffectData()
										ef:SetOrigin(tr.HitPos)
										util.Effect("ef_scav_expsmall",ef)
									if SERVER then
										util.Decal("fadingscorch",tr.HitPos+tr.HitNormal*8,tr.HitPos-tr.HitNormal*8)
										util.BlastDamage(attacker:GetActiveWeapon(),attacker,tr.HitPos,128,50)
									end
								end
			if SERVER then	
				tab.FireFunc = function(self,item)
									local tab = ScavData.models[self.inv.items[1].ammo]
									tab.bullet.Src = self.Owner:GetShootPos()
									tab.bullet.Dir = self:GetAimVector()
									self.Owner:FireBullets(tab.bullet)
									self.Owner:SetAnimation(PLAYER_ATTACK1)
									self.Owner:EmitToAllButSelf("weapons/ar2/fire1.wav")
									return true
								end
			else
				tab.FireFunc = function(self,item)
									local tab = ScavData.models[self.inv.items[1].ammo]
									tab.bullet.Src = self.Owner:GetShootPos()
									tab.bullet.Dir = self:GetAimVector()
									self.Owner:FireBullets(tab.bullet)
									self.Owner:SetAnimation(PLAYER_ATTACK1)
									self.Owner:EmitSound("weapons/ar2/fire1.wav")
									return true
					end
			end
			tab.Cooldown = 0.2
		ScavData.models["models/items/ammo/frag12round.mdl"] = tab

/*==============================================================================================
	--Syringe Gun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Syringe Gun"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			tab.dmginfo = DamageInfo()
			if SERVER then
				tab.Callback = function(self,tr)
						if tr.Entity && tr.Entity:IsValid() then
							if tr.Entity:IsPlayer() || tr.Entity:IsNPC() then
								tr.Entity:InflictStatus("Disease",5,1)
							end
							local dmg = ScavData.models["models/weapons/w_models/w_syringegun.mdl"].dmginfo
							dmg:SetDamage(1)
							dmg:SetDamageForce(vector_origin)
							dmg:SetDamagePosition(tr.HitPos)
							dmg:SetDamageType(DMG_BULLET)
							if self:GetOwner():IsValid() then
								dmg:SetAttacker(self:GetOwner())
							end
							if self:GetInflictor():IsValid() then
								dmg:SetInflictor(self:GetInflictor())
							end
							tr.Entity:TakeDamageInfo(dmg)
						end 
					end
				tab.proj = GProjectile()
				tab.proj:SetCallback(tab.Callback)
				tab.proj:SetBBox(Vector(-1,-1,-1),Vector(1,1,1))
				tab.proj:SetPiercing(false)
				tab.proj:SetGravity(Vector(0,0,-96))
				tab.proj:SetMask(MASK_SHOT)	
				local proj = tab.proj
				tab.FireFunc = function(self,item)			
									local vel = (VectorRand()*0.01+self:GetAimVector()):GetNormalized()*1500*self.dt.ForceScale
									local pos = self.Owner:GetShootPos()+self:GetAimVector()*24+self:GetAimVector():Angle():Right()*4-self:GetAimVector():Angle():Up()*4
									//local proj = s_proj.AddProjectile(self.Owner,self.Owner:GetShootPos()+(self:GetAimVector():Angle():Right()*2-self:GetAimVector():Angle():Up()*2)*1,vel,ScavData.models["models/weapons/w_models/w_syringegun.mdl"].Callback,false,false,Vector(0,0,-96))
									proj:SetOwner(self.Owner)
									proj:SetInflictor(self)
									proj:SetPos(pos)
									proj:SetVelocity(vel)
									proj:SetFilter(self.Owner)
									proj:Fire()
									local ef = EffectData()
									ef:SetOrigin(pos)
									ef:SetStart(vel)
									ef:SetEntity(self.Owner)
									ef:SetScale(item.data)
									util.Effect("ef_scav_syringe",ef)
									if self.currentmodel != item.ammo then
										self:EmitSound("weapons/syringegun_reload_air1.wav")
										timer.Simple(0.25,function() self.Owner:EmitSound("weapons/syringegun_reload_air2.wav") end)
									end
									return self:TakeSubammo(item,1)
								end
				ScavData.CollectFuncs["models/weapons/w_models/w_syringegun.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),40,ent:GetSkin()) end
				ScavData.CollectFuncs["models/weapons/c_models/c_syringegun/c_syringegun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_syringegun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_leechgun/c_leechgun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_syringegun.mdl"]
			else
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
						local vel = (VectorRand()*0.01+self:GetAimVector()):GetNormalized()*1500*self.dt.ForceScale
						local pos = self.Owner:GetShootPos()+self:GetAimVector()*24+self:GetAimVector():Angle():Right()*4-self:GetAimVector():Angle():Up()*4
						local ef = EffectData()
						ef:SetOrigin(pos)
						ef:SetStart(vel)
						ef:SetEntity(self.Owner)
						ef:SetScale(item.data)
						util.Effect("ef_scav_syringe",ef)
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.1
		ScavData.models["models/weapons/w_models/w_syringegun.mdl"] = tab
		ScavData.models["models/weapons/c_models/c_syringegun/c_syringegun.mdl"] = tab
		ScavData.models["models/weapons/c_models/c_leechgun/c_leechgun.mdl"] = tab		

		
/*==============================================================================================
	--Physics Super Shotgun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Physics Super Shotgun"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				tab.FireFunc = function(self,item)
									for i=1,7,1 do
											local projmod = "models/props_combine/breenbust_Chunk0"..i..".mdl"
											local proj = self:CreateEnt("prop_physics")
											local randvec = Vector(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),math.Rand(-0.1,0.1))
											proj:SetModel(projmod)
											proj:SetPos(self.Owner:GetShootPos()+self:GetAimVector()*30+(randvec))
											proj:SetAngles(self.Owner:GetAngles())
											proj:SetPhysicsAttacker(self.Owner)
											proj:SetCollisionGroup(13)
											proj:Spawn()
											proj:SetOwner(self.Owner)
											proj:GetPhysicsObject():SetMass(10)
											proj:GetPhysicsObject():AddGameFlag(FVPHYSICS_PENETRATING)
											proj:GetPhysicsObject():SetVelocity((self:GetAimVector()+randvec)*2500+self.Owner:GetVelocity())
											proj:GetPhysicsObject():SetBuoyancyRatio(0)
											proj:Fire("kill",1,"3")
											//gamemode.Call("ScavFired",self.Owner,proj)
									end
									self.Owner:GetPhysicsObject(wake)
									self.Owner:SetVelocity(self.Owner:GetVelocity()-self:GetAimVector()*200)
									self.Owner:SetAnimation(PLAYER_ATTACK1)
									self.Owner:ViewPunch(Angle(math.Rand(-1,0)-8,math.Rand(-0.1,0.1),0))
									self.Owner:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav")
									timer.Simple(0.5, function() self:SendWeaponAnim(ACT_VM_HOLSTER) end)
									timer.Simple(0.75, function() self.Owner:EmitSound("weapons/shotgun/shotgun_reload3.wav",100,65) end)
									timer.Simple(1.75, function() self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav",100,120) end)
									return true
								end
			end
			tab.Cooldown = 2
		ScavData.models["models/props_combine/breenbust.mdl"] = tab
	
	
	
/*==============================================================================================
	--Physics Shotgun
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Physics Shotgun"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			if SERVER then
				tab.models = {"a","b","c","d","e","f","g","h","i","j","k","l","m"}
				tab.FireFunc = function(self,item)	
									for i=1,7 do
											math.randomseed(CurTime()+i)
											local proj = self:CreateEnt("prop_physics")
											proj:SetModel("models/props_wasteland/prison_toiletchunk01"..ScavData.models[self.inv.items[1].ammo].models[i]..".mdl")
											local randvec = Vector(math.sin(i),math.cos(i),math.sin(i)*math.cos(i))*0.05
											//local randvec = Vector(math.Rand(-0.05,0.05),math.Rand(-0.05,0.05),math.Rand(-0.05,0.05))
											//local randvec = Vector((i+math.random(-7,7))*0.01*(math.floor(CurTime())-CurTime()),(i+math.random(-6,6))*0.01*(math.floor(CurTime())-CurTime()),(i+math.random(-5,5))*0.01*(math.floor(CurTime())-CurTime()))
											proj:SetPos(self.Owner:GetShootPos()+self:GetAimVector()*30+(randvec))
											proj:SetAngles(self:GetAimVector():Angle())
											proj:SetPhysicsAttacker(self.Owner)
											proj:SetCollisionGroup(13)
											proj:SetGravity(0)
											proj:Spawn()
											proj:SetOwner(self.Owner)
											proj:GetPhysicsObject():SetMass(7)
											
											proj:GetPhysicsObject():SetVelocity((self:GetAimVector()+randvec)*2500)
											proj:GetPhysicsObject():SetBuoyancyRatio(0)
											proj:Fire("kill",1,"2")
											//gamemode.Call("ScavFired",self.Owner,proj)
											self.Owner:SetAnimation(PLAYER_ATTACK1)
									end
							
									self.Owner:ViewPunch(Angle(math.Rand(-1,0)-8,math.Rand(-0.1,0.1),0))
									self.Owner:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav")
									timer.Simple(0.25, function() self:SendWeaponAnim(ACT_VM_HOLSTER) end)
									timer.Simple(0.5, function() self.Owner:EmitSound("weapons/shotgun/shotgun_reload3.wav",100,65) end)
									timer.Simple(1, function() self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav",100,120) end)
									return true
								end
			end
			tab.Cooldown = 1.25
			ScavData.models["models/props_wasteland/prison_toilet01.mdl"] = tab
	
/*==============================================================================================
	--Flamethrower
==============================================================================================*/
		
		local creditfix = {
			["grenade_helicopter"] = true,
			["prop_ragdoll"] = true,
			["scav_projectile_mag"] = true,
			["npc_tripmine"] = true,
			["scav_projectile_flare2"] = true
			}
		
		local firecredit = function(ent,dmginfo)
								local inflictor = dmginfo:GetInflictor()
								local attacker = dmginfo:GetAttacker()
								local amount = dmginfo:GetDamage()
								if attacker:IsValid() && (attacker == inflictor) then
									if ((attacker:GetClass() == "entityflame") && ent.ignitedby && ent.ignitedby:IsValid()) then
										dmginfo:SetInflictor(attacker)
										dmginfo:SetAttacker(ent.ignitedby)
									end
									if creditfix[attacker:GetClass()] && attacker.thrownby && attacker.thrownby:IsValid() then
										dmginfo:SetInflictor(attacker)
										dmginfo:SetAttacker(attacker.thrownby)
									end
								end
							end
		hook.Add("EntityTakeDamage","GiveFireCredit",firecredit)
		
		do
			local tab = {}
				tab.Name = "Flamethrower"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.Cooldown = 0.1
				function tab.ChargeAttack(self,item)
					if SERVER then --SERVER
						local tab = ScavData.models[self.inv.items[1].ammo]
						local proj = tab.proj
						local extpos = self.Owner:GetShootPos()+self:GetAimVector()*75
						for k,v in ipairs(ents.FindByClass("env_fire")) do
							if v:GetPos():Distance(extpos) < 75 then
								v:Fire("StartFire",1,0)
							end
						end
							local tab = ScavData.models["models/props_junk/propanecanister001a.mdl"]
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*360) --was 460 --+self.Owner:GetVelocity()
							proj:SetLifetime(self.dt.ForceScale)
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector()*-45)
						end
						self:AddBarrelSpin(400)
					end
					self:TakeSubammo(item,1)
					local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
					if !continuefiring then
						if IsValid(self.ef_fthrow) then
							self.ef_fthrow:Kill()
						end
						self:SetChargeAttack()
					end
					return 0.1
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_fthrow = self:CreateToggleEffect("scav_stream_fthrow")
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					//tab.ChargeAttack(self,item)
					return false
				end
				if SERVER then
					local proj = GProjectile()
					local function callback(self,tr)
									local ent = tr.Entity
									if ent && ent:IsValid() && (!ent:IsPlayer()||gamemode.Call("PlayerShouldTakeDamage",ent,self.Owner)) then
										ent:Ignite(5,0)
										ent.ignitedby = self.Owner
										local dmg = DamageInfo()
										dmg:SetDamage((self.deathtime-CurTime())*7)
										dmg:SetDamageForce(tr.Normal*30)
										dmg:SetDamagePosition(tr.HitPos)
										if self:GetOwner():IsValid() then
											dmg:SetAttacker(self:GetOwner())
										end
										if self:GetInflictor():IsValid() then
											dmg:SetInflictor(self:GetInflictor())
										end
										dmg:SetDamageType(DMG_DIRECT)
										ent:TakeDamageInfo(dmg)
									end
									if !tr.Entity:IsPlayer() || !tr.Entity:IsNPC() then
										return false
									end
									return true
								end
					proj:SetCallback(callback)
					proj:SetBBox(Vector(-7,-7,-7),Vector(7,7,7))
					proj:SetPiercing(true)
					proj:SetGravity(vector_origin)
					proj:SetMask(bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME))
					proj:SetLifetime(1)
					tab.proj = proj

					ScavData.CollectFuncs["models/props_junk/propanecanister001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,ent:GetSkin(),1) end
					ScavData.CollectFuncs["models/props_junk/propane_tank001a.mdl"] = ScavData.CollectFuncs["models/props_junk/propanecanister001a.mdl"]
					ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),200,ent:GetSkin()) end	
					ScavData.CollectFuncs["models/weapons/w_models/w_flamethrower.mdl"] = ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"]
					ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_flamethrower.mdl"] = ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"]
					ScavData.CollectFuncs["models/props_citizen_tech/firetrap_propanecanister01a.mdl"] = ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"]
					ScavData.CollectFuncs["models/props_citizen_tech/firetrap_propanecanister01b.mdl"] = ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"]
					ScavData.CollectFuncs["models/props_farm/oilcan01.mdl"] = function(self,ent) self:AddItem("models/props_farm/oilcan01.mdl",75,ent:GetSkin()) end
					ScavData.CollectFuncs["models/props_farm/oilcan01b.mdl"] = function(self,ent) self:AddItem("models/props_farm/oilcan01b.mdl",50,ent:GetSkin()) end
					ScavData.CollectFuncs["models/props_farm/oilcan02.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),25,ent:GetSkin()) end
					ScavData.CollectFuncs["models/props_farm/gibs/shelf_props01_gib_oilcan01.mdl"] = ScavData.CollectFuncs["models/props_farm/oilcan02.mdl"]
					ScavData.CollectFuncs["models/props_junk/metalgascan.mdl"] = ScavData.CollectFuncs["models/props_farm/oilcan02.mdl"]
					ScavData.CollectFuncs["models/props_junk/gascan001a.mdl"] = ScavData.CollectFuncs["models/props_farm/oilcan02.mdl"]
				end
				ScavData.RegisterFiremode(tab,"models/props_junk/propanecanister001a.mdl")
				ScavData.RegisterFiremode(tab,"models/props_junk/propane_tank001a.mdl")
				ScavData.RegisterFiremode(tab,"models/props_c17/canister_propane01a.mdl")
				ScavData.RegisterFiremode(tab,"models/props_citizen_tech/firetrap_propanecanister01a.mdl")
				ScavData.RegisterFiremode(tab,"models/props_citizen_tech/firetrap_propanecanister01b.mdl")
				ScavData.RegisterFiremode(tab,"models/props_farm/oilcan01.mdl")
				ScavData.RegisterFiremode(tab,"models/props_farm/oilcan01b.mdl")
				ScavData.RegisterFiremode(tab,"models/props_farm/gibs/shelf_props01_gib_oilcan01.mdl")
				ScavData.RegisterFiremode(tab,"models/props_farm/oilcan02.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_flamethrower.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_flamethrower/c_flamethrower.mdl")
				ScavData.RegisterFiremode(tab,"models/props_junk/metalgascan.mdl")
				ScavData.RegisterFiremode(tab,"models/props_junk/gascan001a.mdl")
		end

/*==============================================================================================
	--Fire Extinguisher
==============================================================================================*/
		
		do
			local tab = {}
				tab.Name = "Fire Extinguisher"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.Cooldown = 0.1
				local tracep = {}

				local vmin = Vector(-12,-12,-12)
				local vmax = Vector(12,12,12)
				tracep.mins = vmin
				tracep.maxs = vmax
				tracep.mask = MASK_SHOT
				function tab.ChargeAttack(self,item)
					if SERVER then --SERVER
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*150
						tracep.filter = self.Owner
						local tr = util.TraceHull(tracep)
						if tr.Hit and tr.HitPos then
							local extents = ents.FindInSphere(tr.HitPos, 80)
							for index,ent in pairs(extents) do
								if ent then
									ent:Extinguish()
									if ent:GetMoveType() ~= MOVETYPE_VPHYSICS and (not ent:IsPlayer() or ent ~= self.Owner) then
										if ent:IsPlayer() then
											ent:SendHUDOverlay(color_white,2)
										end
										local dmg = DamageInfo()
										dmg:SetAttacker(self.Owner)
										dmg:SetInflictor(self)
										dmg:SetDamage(1)
										dmg:SetDamageForce(vector_origin)
										dmg:SetDamagePosition(tr.HitPos)
										dmg:SetDamageType(DMG_CHEMICAL)
										ent:TakeDamageInfo(dmg)
										ent:SetVelocity((ent:GetPos()-self:GetPos()):GetNormalized()*1000)
									elseif ent:GetPhysicsObject():IsValid() then
										ent:GetPhysicsObject():ApplyForceOffset((ent:GetPos()-self:GetPos()):GetNormalized()*1000,tr.HitPos)
									end
								end
							end
						end
						local extpos = self.Owner:GetShootPos()+self:GetAimVector()*75
						for k,v in ipairs(ents.FindByClass("env_fire")) do
							if v:GetPos():Distance(extpos) < 75 then
								v:Fire("ExtinguishTemporary",0,0)
							end
						end
						local proj = GProjectile()
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*100*math.Rand(1,6)*self.dt.ForceScale+self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector()*-54)
						end
						self:AddBarrelSpin(100)
					end
					self:TakeSubammo(item,1)
					local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
					if !continuefiring then
						if IsValid(self.ef_exting) then
							self.ef_exting:Kill()
						end
						self:SetChargeAttack()
					end
					return 0.1
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_exting = self:CreateToggleEffect("scav_stream_extinguisher")
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/props/cs_office/fire_extinguisher.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,0,1) end
					ScavData.CollectFuncs["models/props_2fort/fire_extinguisher.mdl"] = ScavData.CollectFuncs["models/props/cs_office/fire_extinguisher.mdl"]
				end
			ScavData.RegisterFiremode(tab,"models/props/cs_office/fire_extinguisher.mdl")
			ScavData.RegisterFiremode(tab,"models/props_2fort/fire_extinguisher.mdl")
		end
		
/*==============================================================================================
	--Acid Sprayer
==============================================================================================*/
		
		do
			local tab = {}
				tab.Name = "Acid Spray"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.Cooldown = 0.1
				function tab.ChargeAttack(self,item)
					if SERVER then --SERVER
						local proj = tab.proj
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*100*math.Rand(1,6)*self.dt.ForceScale+self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector()*-35)
						end
						self:AddBarrelSpin(100)
					end
					self:TakeSubammo(item,1)
					local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
					if !continuefiring then
						if IsValid(self.ef_aspray) then
							self.ef_aspray:Kill()
						end
						self:SetChargeAttack()
					end
					return 0.1
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_aspray = self:CreateToggleEffect("scav_stream_aspray")
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					local proj = GProjectile()
					local function callback(self,tr)
						local ent = tr.Entity
						if ent && ent:IsValid() && (!ent:IsPlayer()||gamemode.Call("PlayerShouldTakeDamage",ent,self.Owner)) then
							ent:InflictStatus("Acid",100,(self.deathtime-CurTime())/2,self:GetOwner())
							ent:EmitSound("ambient/levels/canals/toxic_slime_sizzle"..math.random(2,4)..".wav")
						end
						if !tr.Entity:IsPlayer() || !tr.Entity:IsNPC() then
							return false
						end
						return true
					end
					proj:SetCallback(callback)
					proj:SetBBox(Vector(-8,-8,-8),Vector(8,8,8))
					proj:SetPiercing(true)
					proj:SetGravity(Vector(0,0,-96))
					proj:SetMask(bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME))
					proj:SetLifetime(1)
					tab.proj = proj
					ScavData.CollectFuncs["models/props/cs_italy/orange.mdl"] = function(self,ent) self:AddItem("models/props/cs_italy/orange.mdl",1,0) end
					ScavData.CollectFuncs["models/props/de_inferno/crate_fruit_break_gib2.mdl"] = function(self,ent) self:AddItem("models/props/cs_italy/orange.mdl",1,0) end
					ScavData.CollectFuncs["models/props/de_inferno/crate_fruit_break.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/crate_fruit_break.mdl",400,0) end
					ScavData.CollectFuncs["models/props/de_inferno/crate_fruit_break_p1.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/crate_fruit_break_pl.mdl"]
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit1.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/crate_fruit_break.mdl",400,0,18) end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit1_p1.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/crate_fruit_break.mdl",400,0,15) end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/crate_fruit_break.mdl",400,0,13) end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2_p1.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2.mdl"]
					ScavData.CollectFuncs["models/props_lab/crematorcase.mdl"] = function(self,ent) self:AddItem("models/props_lab/crematorcase.mdl",1000,0) end
				end
			ScavData.RegisterFiremode(tab,"models/props/cs_italy/orange.mdl")
			ScavData.RegisterFiremode(tab,"models/props_lab/crematorcase.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_inferno/crate_fruit_break.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_inferno/crate_fruit_break_p1.mdl")
		end

/*==============================================================================================
	--Freezing Gas
==============================================================================================*/
		
		do
			local tab = {}
				tab.Name = "Freezing Gas"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.Cooldown = 0.1
				function tab.ChargeAttack(self,item)
					if SERVER then --SERVER
						local proj = tab.proj
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*100*math.Rand(1,6)*self.dt.ForceScale+self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector()*-35)
						end
						self:AddBarrelSpin(100)
					end
					self:TakeSubammo(item,1)
					local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
					if !continuefiring then
						if IsValid(self.ef_frzgas) then
							self.ef_frzgas:Kill()
						end
						self:SetChargeAttack()
					end
					return 0.1
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_frzgas = self:CreateToggleEffect("scav_stream_freezegas")
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					local proj = GProjectile()
					local function callback(self,tr)
						local ent = tr.Entity
						if ent && ent:IsValid() && (!ent:IsPlayer()||gamemode.Call("PlayerShouldTakeDamage",ent,self:GetOwner())) then
							local dmg = DamageInfo()
							dmg:SetAttacker(self:GetOwner())
							if self:GetOwner():IsValid() then
								dmg:SetAttacker(self:GetOwner())
							end
							if self:GetInflictor():IsValid() then
								dmg:SetInflictor(self:GetInflictor())
							end
							dmg:SetDamage(1)
							dmg:SetDamageForce(vector_origin)
							dmg:SetDamagePosition(tr.HitPos)
							dmg:SetDamageType(DMG_FREEZE)
							tr.Entity:TakeDamageInfo(dmg)
							local slowfactor = 0.8
							local slowstatus = ent:GetStatus("Slow")
							if slowstatus then
								slowfactor = slowstatus.Value*0.8
							end
							ent:InflictStatus("Slow",0.1,slowfactor,self:GetOwner())
							local slow = ent:GetStatus("Slow")
							if slow then
								if ent:IsPlayer() && (slow.Value < 0.3) then
									ent:InflictStatus("Frozen",0.1,0,self:GetOwner())
								elseif !ent:IsPlayer() && ((ent:IsNPC() && ((ent:Health() < 10) || (slow.EndTime > CurTime()+10))) || !ent:IsNPC()) then
									ent:InflictStatus("Frozen",0.2,0,self:GetOwner())
								end
							end
						end
						if tr.MatType == MAT_SLOSH then
							local pos = tr.HitPos*1
							local ice = NULL
							local model = "models/scav/iceplatform.mdl"
							for k,v in ipairs(ents.FindInSphere(pos,10)) do
								if v:GetModel() && (model == string.lower(v:GetModel())) then
									ice = v
									break
								end
							end
							if !ice:IsValid() then
								ice = ents.Create("scav_iceplatform")
								ice:SetModel(model)
								ice:SetPos(pos)
								ice:SetAngles(Angle(0,math.random(0,360),0))
								ice:SetMaterial("models/shiny")
								ice:SetColor(Color(175,227,255,200))
								ice:SetRenderMode(RENDERMODE_TRANSALPHA)
								ice:Spawn()
								ice.StatusImmunities = {["Frozen"] = true}
								ice.NoScav = true
								ice:GetPhysicsObject():SetMaterial("gmod_ice")
								ice:SetMoveType(MOVETYPE_NONE)
							end
						end
						if !tr.Entity:IsPlayer() || !tr.Entity:IsNPC() then
							return false
						end
						return true
					end
					proj:SetCallback(callback)
					proj:SetBBox(Vector(-8,-8,-8),Vector(8,8,8))
					proj:SetPiercing(true)
					proj:SetGravity(vector_origin)
					proj:SetMask(bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME))
					proj:SetLifetime(1)
					tab.proj = proj
					ScavData.CollectFuncs["models/props_c17/furniturefridge001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,0) end
					ScavData.CollectFuncs["models/props/cs_assault/acunit01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,0) end
					ScavData.CollectFuncs["models/props/cs_assault/acunit02.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefridge001a.mdl"]
					ScavData.CollectFuncs["models/props/de_train/acunit1.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),150,0) end
					ScavData.CollectFuncs["models/props/de_train/acunit2.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefridge001a.mdl"]
					ScavData.CollectFuncs["models/props_silo/acunit01.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/acunit01.mdl"]
					ScavData.CollectFuncs["models/props_silo/acunit02.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/acunit02.mdl"]
					ScavData.CollectFuncs["models/props_wasteland/kitchen_fridge001a.mdl"] = ScavData.CollectFuncs["models/props/de_train/acunit1.mdl"]			
				end
			ScavData.RegisterFiremode(tab,"models/props_c17/furniturefridge001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props/cs_assault/acunit01.mdl")
			ScavData.RegisterFiremode(tab,"models/props/cs_assault/acunit02.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_train/acunit1.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_train/acunit2.mdl")
			ScavData.RegisterFiremode(tab,"models/props_silo/acunit01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_silo/acunit02.mdl")
			ScavData.RegisterFiremode(tab,"models/props_wasteland/kitchen_fridge001a.mdl")
		end

/*==============================================================================================
	--Plasma Blade
==============================================================================================*/

		do
			local tab = {}
				tab.Name = "Plasma Blade"
				tab.anim = ACT_VM_SWINGMISS
				tab.Level = 4
				tab.Cooldown = 0.15
				local tracep = {}
				tracep.mins = Vector(-8,-8,-8)
				tracep.maxs = Vector(8,8,8)
				function tab.ChargeAttack(self,item)
					self.slicestage = self.slicestage+1
					if SERVER then --SERVER
						
						local vm = self.Owner:GetViewModel()
						local att = vm:GetAttachment(vm:LookupAttachment("muzzle"))
						if self.slicestage == 1 then
							tracep.start = self.Owner:GetShootPos()
						else
							tracep.start = att.Pos
						end
						tracep.endpos = tracep.start+self.Owner:GetAimVector()*50
						tracep.filter = self.Owner
						local tr = util.TraceHull(tracep)
						if tr.Hit then
							//self.Owner:EmitSound("ambient/energy/NewSpark08.wav")
							self.Owner:EmitSound("ambient/energy/weld1.wav")
						end
						if IsValid(tr.Entity) then
							local dmg = DamageInfo()
							dmg:SetDamageType(bit.bor(DMG_SLASH,DMG_PLASMA,DMG_ENERGYBEAM))
							dmg:SetDamage(30)
							dmg:SetDamagePosition(tr.HitPos)
							dmg:SetAttacker(self.Owner)
							dmg:SetInflictor(self)
							dmg:SetDamageForce(tr.Normal*900)
							tr.Entity:TakeDamageInfo(dmg)
						end
						if tr.Hit then
							local edata = EffectData()
							edata:SetOrigin(tr.HitPos)
							edata:SetNormal(tr.HitNormal)
							edata:SetEntity(tr.Entity)
							if tr.MatType == MAT_FLESH then
								util.Effect("BloodImpact",edata,true,true)
							else
								util.Effect("StunstickImpact",edata,true,true)
							end
						end
					end
					if self.slicestage > 8 then
						if IsValid(self.ef_pblade) then
							self.ef_pblade:Kill()
						end
						self:SetHoldType("pistol")
						self:SetChargeAttack()
					end
					return 0.025
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_pblade = self:CreateToggleEffect("scav_stream_pblade")
					end
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = tracep.start+self.Owner:GetAimVector()*50
					tracep.filter = self.Owner
					local tr = util.TraceHull(tracep)
					if tr.Hit then
						tab.anim = ACT_VM_SWINGHIT
					else
						tab.anim = ACT_VM_SWINGMISS
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					self:SetHoldType("melee")
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.slicestage = 0
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/props_phx2/garbage_metalcan001a.mdl"] = ScavData.GiveOneOfItemInf
				end
				ScavData.RegisterFiremode(tab,"models/props_phx2/garbage_metalcan001a.mdl")
		end
		
/*==============================================================================================
	--Buzzsaw
==============================================================================================*/

		do
			local tab = {}
				tab.Name = "Buzzsaw"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.Cooldown = 0.025
				local tracep = {}
				tracep.mins = Vector(-12,-12,-12)
				tracep.maxs = Vector(12,12,12)
				function tab.ChargeAttack(self,item)
					if SERVER then --SERVER
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = tracep.start+self.Owner:GetAimVector()*60
						tracep.filter = self.Owner
						local tr = util.TraceHull(tracep)
						if IsValid(tr.Entity) then
							//if tr.Entity:IsNPC() then
							//	tr.Entity:SetSchedule(SCHED_BIG_FLINCH)
							//end
							local dmg = DamageInfo()
							dmg:SetDamageType(DMG_SLASH)
							dmg:SetDamage(4)
							dmg:SetDamagePosition(tr.HitPos)
							dmg:SetAttacker(self.Owner)
							dmg:SetInflictor(self)
							tr.Entity:TakeDamageInfo(dmg)
						end
						if tr.Hit then
							local edata = EffectData()
							edata:SetOrigin(tr.HitPos)
							edata:SetNormal(tr.HitNormal)
							edata:SetEntity(tr.Entity)
							if tr.MatType == MAT_FLESH then
								sound.Play("npc/manhack/grind_flesh"..math.random(1,3)..".wav",tr.HitPos)
								//self.Owner:ViewPunch(Angle(math.Rand(-1,-3),0,0))
								util.Effect("BloodImpact",edata,true,true)
							else
								sound.Play("npc/manhack/grind"..math.random(1,5)..".wav",tr.HitPos)
								//self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2),0,0))
								util.Effect("ManhackSparks",edata,true,true)
							end
						end
						self:AddBarrelSpin(100)
					end
					local continuefiring = self:StopChargeOnRelease()
					if !continuefiring then
						if IsValid(self.ef_pblade) then
							self.ef_pblade:Kill()
						end
						self:SetChargeAttack()
						return 0.5
					end
					return 0.025
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_pblade = self:CreateToggleEffect("scav_stream_saw")
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"] = ScavData.GiveOneOfItemInf
				end
				ScavData.RegisterFiremode(tab,"models/props_junk/sawblade001a.mdl")
		end

/*==============================================================================================
	--Laser Beam
==============================================================================================*/

		do
			local tab = {}
				tab.Name = "Laser Beam"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.Cooldown = 0.01
				local tracep = {}
				tracep.mins = Vector(-2,-2,-2)
				tracep.maxs = Vector(2,2,2)
				function tab.ChargeAttack(self,item)
					if SERVER then --SERVER
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = tracep.start+self.Owner:GetAimVector()*10000
						tracep.filter = self.Owner
						local tr = util.TraceHull(tracep)
						if IsValid(tr.Entity) then
							local dmg = DamageInfo()
							dmg:SetDamageType(DMG_ENERGYBEAM)
							dmg:SetDamage(5)
							dmg:SetDamagePosition(tr.HitPos)
							dmg:SetAttacker(self.Owner)
							dmg:SetInflictor(self)
							tr.Entity:TakeDamageInfo(dmg)
						end
						self:AddBarrelSpin(200)
					end
					self:TakeSubammo(item,1)
					local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
					if !continuefiring then
						if IsValid(self.ef_beam) then
							self.ef_beam:Kill()
						end
						self:SetChargeAttack()
						return 0.05
					end
					return 0.05
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_beam = self:CreateToggleEffect("scav_stream_laser")
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/roller.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,0,1) end
					ScavData.CollectFuncs["models/roller_spikes.mdl"] = ScavData.CollectFuncs["models/roller.mdl"]
					ScavData.CollectFuncs["models/roller_vehicledriver.mdl"] = ScavData.CollectFuncs["models/roller.mdl"]
				end
				ScavData.RegisterFiremode(tab,"models/roller.mdl")
				ScavData.RegisterFiremode(tab,"models/roller_spikes.mdl")
				ScavData.RegisterFiremode(tab,"models/roller_vehicledriver.mdl")
		end
		
/*==============================================================================================
	--Arc Beam
==============================================================================================*/

		do
			local tab = {}
				tab.Name = "Arc Beam"
				tab.chargeanim = ACT_VM_FIDGET
				tab.Level = 6
				tab.Cooldown = 0.01
				function tab.ChargeAttack(self,item)
					if SERVER then
						self:SetPanelPoseInstant(0.4,6)
						self:SetBlockPoseInstant(1,1)
					end
					self:TakeSubammo(item,1)
					local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
					if !continuefiring then
						if IsValid(self.ef_parc) then
							self.ef_parc:Kill()
						end
						self:SetChargeAttack()
						//tab.anim = ACT_VM_IDLE
						return 0.05
					end
					//tab.anim = ACT_VM_FIDGET
					return 0.05
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_parc = self:CreateToggleEffect("scav_stream_tesla")
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,0,1) end
					ScavData.CollectFuncs["models/props_c17/utilityconnecter006c.mdl"] = ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"]
				end
				ScavData.RegisterFiremode(tab,"models/props_c17/utilityconnecter006.mdl")
				ScavData.RegisterFiremode(tab,"models/props_c17/utilityconnecter006c.mdl")
		end

/*==============================================================================================
	--TF2 Medigun
==============================================================================================*/

		do
			local tab = {}
				tab.Name = "Medigun"
				tab.chargeanim = ACT_VM_FIDGET
				tab.Level = 6
				tab.Cooldown = 0.01
				function tab.ChargeAttack(self,item)
					if SERVER then
						self:SetBlockPoseInstant(1,1)
					end
					local continuefiring = self:StopChargeOnRelease()
					if !continuefiring then
						if IsValid(self.ef_medigun) then
							self.ef_medigun:Kill()
						end
						self:SetChargeAttack()
						//tab.anim = ACT_VM_IDLE
						return 0.05
					end
					//tab.anim = ACT_VM_FIDGET
					return 0.05
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_medigun = self:CreateToggleEffect("scav_stream_medigun")
						self.ef_medigun.dt.blue = (item.data == 1)
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/weapons/c_models/c_medigun/c_medigun.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/weapons/w_models/w_medigun.mdl"] = ScavData.GiveOneOfItemInf
				end
				ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_medigun/c_medigun.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_medigun.mdl")
		end

/*==============================================================================================
	--GammaBeam
==============================================================================================*/
		
		PrecacheParticleSystem("scav_exp_rad")
		
		local tab = {}
			tab.Name = "Gamma Ray Beam"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 7
			tab.vmin = Vector(-4,-4,-4)
			tab.vmax = Vector(4,4,4)
			tab.dmginfo = DamageInfo()
			if SERVER then
				tab.OnArmed = DoChargeSound
				tab.FireFunc = function(self,item)
						local tab = ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"]
						local startpos = self.Owner:GetShootPos()
						local filter = {self.Owner,Entity(0)}
						local tr
						local tracep = {}
						tracep.start = startpos
						tracep.endpos = self.Owner:GetShootPos()+(self:GetAimVector()+VectorRand()*0.02):GetNormalized()*10000
						tracep.filter = filter
						tracep.mask = MASK_SHOT
						tracep.mins = tab.vmin
						tracep.maxs = tab.vmax
						for i=1,32 do
							tr = util.TraceHull(tracep)
							local ent = tr.Entity
							if ent && ent:IsValid() && !ent:IsWorld() then
								if !ent:IsFriendlyToPlayer(self.Owner) then
									ent:InflictStatus("Radiation",10,3,self.Owner)
									local dmg = tab.dmginfo
									dmg:SetAttacker(self.Owner)
									dmg:SetInflictor(self)
									dmg:SetDamage(30)
									dmg:SetDamageForce(vector_origin)
									dmg:SetDamagePosition(tr.HitPos)
									dmg:SetDamageType(DMG_RADIATION)
									ent:TakeDamageInfo(dmg)
								end
								ParticleEffect("scav_exp_rad",tr.HitPos,Angle(0,0,0),Entity(0))
								table.insert(tracep.filter,ent)
								if (tr.Entity:GetClass() == "npc_strider") then
									break
								end
							else
								break
							end
							startpos = tr.HitPos
						end
						local efdata = EffectData()
						efdata:SetEntity(self)
						efdata:SetOrigin(self:GetPos())
						efdata:SetStart(tr.HitPos)
						util.Effect("ef_scav_radbeam",efdata)
						self:AddBarrelSpin(1000)
						self:MuzzleFlash2(4)
						self.Owner:EmitToAllButSelf("npc/scanner/scanner_electric2.wav")
						self.nextfireearly = CurTime()+0.1
						return self:TakeSubammo(item,1)
					end			
				ScavData.CollectFuncs["models/props/de_nuke/nuclearcontainerboxclosed.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/props_badlands/barrel03.mdl"] = ScavData.CollectFuncs["models/props/de_nuke/nuclearcontainerboxclosed.mdl"]
				ScavData.CollectFuncs["models/props_badlands/barrel_flatbed01.mdl"] = function(self,ent) self:AddItem("models/props_badlands/barrel03.mdl",10,ent:GetSkin(),3) end
			else
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
						local startpos = self.Owner:GetShootPos()
						local filter = {self.Owner,Entity(0)}
						local tr
						local tracep = {}
						tracep.start = startpos
						tracep.endpos = self.Owner:GetShootPos()+(self:GetAimVector()+VectorRand()*0.02):GetNormalized()*10000
						tracep.filter = filter
						tracep.mask = MASK_SHOT
						tracep.mins = tab.vmin
						tracep.maxs = tab.vmax
						while (true) do
							tr = util.TraceHull(tracep)
							local ent = tr.Entity
							if ent && ent:IsValid() && !ent:IsWorld() then
								ParticleEffect("scav_exp_rad",tr.HitPos,Angle(0,0,0),Entity(0))
								table.insert(filter,ent)
								if (tr.Entity:GetClass() == "npc_strider") then
									break
								end
							else
								break
							end
							startpos = tr.HitPos
						end
						local efdata = EffectData()
						efdata:SetEntity(self)
						efdata:SetOrigin(self:GetPos())
						efdata:SetStart(tr.HitPos)
						util.Effect("ef_scav_radbeam",efdata)
						self.Owner:EmitSound("npc/scanner/scanner_electric2.wav")
						self:MuzzleFlash2(4)
						self.nextfireearly = CurTime()+0.1
						//self.Owner:ScavViewPunch(Angle(math.Rand(-3,-4),math.Rand(-2,2),0),0.25)
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 1
		ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"] = tab
		ScavData.models["models/props_badlands/barrel03.mdl"] = tab

/*==============================================================================================
	--Radioactive/Biohazard Barrels
==============================================================================================*/
		
		local tab = {}
			function tab.GetName(self,item)
				if (item:GetData() > 1) && (item:GetData() < 7) then
					return "Disease Shot"
				else
					return "Gamma Ray Beam"
				end
			end
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			tab.FireFunc = function(self,item)
				local tab = ScavData.models["models/props/de_train/barrel.mdl"]
				if (item.data > 1) && (item.data < 7) then
					tab.Cooldown = ScavData.models["models/props/de_train/biohazardtank.mdl"].Cooldown
					tab.anim = ScavData.models["models/props/de_train/biohazardtank.mdl"].anim
					return ScavData.models["models/props/de_train/biohazardtank.mdl"].FireFunc(self,item)
				else
					tab.Cooldown = ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].Cooldown
					tab.anim = ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].anim
					return ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].FireFunc(self,item)
				end
			end
			if SERVER then
				tab.OnArmed = function(self,item,olditemname)
					if (item.ammo != olditemname) && ((item.data < 2) || (item.data > 6)) then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
				ScavData.CollectFuncs["models/props/de_train/barrel.mdl"] = function(self,ent) if (ent:GetSkin() > 1) && (ent:GetSkin() < 7) then self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,ent:GetSkin()) else self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin()) end end
				ScavData.CollectFuncs["models/props/de_train/pallet_barrels.mdl"] = function(self,ent) self:AddItem("models/props/de_train/barrel.mdl",1,2) self:AddItem("models/props/de_train/barrel.mdl",1,3) self:AddItem("models/props/de_train/barrel.mdl",1,4) self:AddItem("models/props/de_train/barrel.mdl",1,5) end
			end
			tab.Cooldown = 0.1
		ScavData.models["models/props/de_train/barrel.mdl"] = tab

/*==============================================================================================
	--Hunter Flechettes
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Hunter Flechettes"
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
			else
				tab.FireFunc = function(self,item)
					return self:TakeSubammo(item,1)
				end
			end
			tab.Cooldown = 0.1
		ScavData.models["models/weapons/hunter_flechette.mdl"] = tab
		
/*==============================================================================================
	--Grunt Hornets
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Hornets"
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
			else
				tab.FireFunc = function(self,item)
					return self:TakeSubammo(item,1)
				end
			end
			tab.Cooldown = 0.2
		ScavData.models["models/agrunt.mdl"] = tab
		
/*==============================================================================================
	--Controller Energy Ball
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Controller Energy Ball"
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
			else
				tab.FireFunc = function(self,item)
					return self:TakeSubammo(item,1)
				end
			end
			tab.Cooldown = 0.15
		ScavData.models["models/controller.mdl"] = tab
	
/*==============================================================================================
	--Squid Spit
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Bullsquid Spit"
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
			else
				tab.FireFunc = function(self,item)
					return self:TakeSubammo(item,1)
				end
			end
			tab.Cooldown = 0.6
		ScavData.models["models/bullsquid.mdl"] = tab 

/*==============================================================================================
	--Vortigaunt Beam
==============================================================================================*/

		PrecacheParticleSystem("vortigaunt_beam")
		PrecacheParticleSystem("scav_vm_vort")
		local tab = {}
			tab.Name = "Vortigaunt Beam"
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
						return self:TakeSubammo(item,1)
					end
				ScavData.CollectFuncs["models/vortigaunt.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),10,ent:GetSkin()) end
				ScavData.CollectFuncs["models/vortigaunt_blue.mdl"] = ScavData.CollectFuncs["models/vortigaunt.mdl"]
				ScavData.CollectFuncs["models/vortigaunt_doctor.mdl"] = ScavData.CollectFuncs["models/vortigaunt.mdl"]
				ScavData.CollectFuncs["models/vortigaunt_slave.mdl"] = ScavData.CollectFuncs["models/vortigaunt.mdl"]
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
						util.Effect("StunstickImpact",ef)
						self.ChargeAttack = nil
						return 0.5
						
					end
					G_ATTACH = 1
					tab.FireFunc = function(self,item)
										self.ChargeAttack = ScavData.models["models/vortigaunt.mdl"].ChargeAttack
										self.chargeitem = item
										ParticleEffectAttach("scav_vm_vort",PATTACH_POINT_FOLLOW,self.Owner:GetViewModel(),G_ATTACH)
										return self:TakeSubammo(item,1)
									end
			end
			tab.Cooldown = 1
		ScavData.models["models/vortigaunt.mdl"] = tab
		ScavData.models["models/vortigaunt_blue.mdl"] = tab
		ScavData.models["models/vortigaunt_doctor.mdl"] = tab
		ScavData.models["models/vortigaunt_slave.mdl"] = tab
		
/*==============================================================================================
	--Phazon Beam
==============================================================================================*/
		PrecacheParticleSystem("scav_exp_phazon_1")
		PrecacheParticleSystem("scav_vm_phazon")
		local tab = {}
			tab.Name = "Phazon Beam"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.chargeanim = ACT_VM_PRIMARYATTACK
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
						tracep.filter = self.Owner
						for i=1,2 do
							tracep.endpos = shootpos+(self:GetAimVector()+VectorRand()*0.075):GetNormalized()*400
							local tr = util.TraceHull(tracep)
							if tr.Hit then
								ParticleEffect("scav_exp_phazon_1",tr.HitPos,refangle,Entity(0))
							end
							if tr.Entity:IsValid() then
								dmg:SetAttacker(self.Owner)
								dmg:SetInflictor(self)
								dmg:SetDamagePosition(tr.HitPos)
								dmg:SetDamageType(bit.bor(DMG_ENERGYBEAM,DMG_RADIATION,DMG_BLAST,DMG_GENERIC,DMG_ALWAYSGIB))
								dmg:SetDamage(4)
								dmg:SetDamageForce(tr.Normal*24000)
								if tr.Entity:IsNPC() then
									//tr.Entity:SetSchedule(SCHED_BIG_FLINCH)
									tr.Entity:SetSchedule(SCHED_FLINCH_PHYSICS)
								end
								if tr.Entity:GetClass() == "prop_ragdoll" then
									for i=0,tr.Entity:GetPhysicsObjectCount()-1 do
										local phys = tr.Entity:GetPhysicsObjectNum(i)
										if phys then
											phys:SetVelocity(VectorRand()*math.random(3,90))
										end
									end
								end
								tr.Entity:TakeDamageInfo(dmg)
							end
						end
						
							local edata = EffectData()
							edata:SetOrigin(self.Owner:GetShootPos())
							edata:SetEntity(self.Owner)
							edata:SetNormal(self:GetAimVector())
							util.Effect("ef_scav_phazon",edata)
							util.Effect("ef_scav_phazon",edata)
							self.Owner:EmitSound("weapons/physcannon/energy_sing_flyby"..math.random(1,2)..".wav",100,255)				
							

							self.Owner:SetAnimation(PLAYER_ATTACK1)
							self:TakeSubammo(item,1)
							self:ProcessLinking(item)
							self:StopChargeOnRelease()
							return 0.025		
						end
					tab.FireFunc = function(self,item)
						self.chargeitem = item
						self.ChargeAttack = ScavData.models["models/dav0r/hoverball.mdl"].ChargeAttack
						self.Owner:EmitSound("ambient/fire/gascan_ignite1.wav",100,90)
						return false
					end
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
						tracep.filter = self.Owner
						for i=1,2 do
							tracep.endpos = shootpos+(self:GetAimVector()+VectorRand()*0.075):GetNormalized()*400
							local tr = util.TraceHull(tracep)
							if tr.Hit then
								ParticleEffect("scav_exp_phazon_1",tr.HitPos,refangle,Entity(0))
							end
						end
						ParticleEffectAttach("scav_vm_phazon",PATTACH_POINT_FOLLOW,self.Owner:GetViewModel(),G_ATTACH)
						local edata = EffectData()
							edata:SetOrigin(self.Owner:GetShootPos())
							edata:SetEntity(self.Owner)
							edata:SetNormal(self:GetAimVector())
							util.Effect("ef_scav_phazon",edata)
							util.Effect("ef_scav_phazon",edata)
				
						self:TakeSubammo(item,1)
						self:ProcessLinking(item)
						self:StopChargeOnRelease()
						
						return 0.025

					end
					tab.FireFunc = function(self,item)
										self.chargeitem = item
										self.ChargeAttack = ScavData.models["models/dav0r/hoverball.mdl"].ChargeAttack
										return false
									end
			end
			tab.Cooldown = 0.025

/*==============================================================================================
	--Minigun
==============================================================================================*/
	
		local tab = {}
			tab.Name = "Minigun"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 5
			tab.BarrelRestSpeed = 1000
			if SERVER then
				tab.ChargeAttack = function(self,item)
										local bullet = {}
											bullet.Num = 2
											bullet.Src = self.Owner:GetShootPos()
											bullet.Dir = self:GetAimVector()
											bullet.Spread = Vector(0.05,0.05,0)
											bullet.Tracer = 3
											bullet.Force = 5
											bullet.Damage = 6
											bullet.TracerName = "ef_scav_tr_b"
											bullet.Callback = ScavData.models[self.chargeitem.ammo].Callback
										self.Owner:FireBullets(bullet)
										self:MuzzleFlash2()
										self.Owner:SetAnimation(PLAYER_ATTACK1)
							self:TakeSubammo(item,1)
							local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
										if !continuefiring then
											self.soundloops.minigunfire:Stop()
											self.soundloops.minigunspin:Stop()
											self.Owner:EmitSound("weapons/minigun_wind_down.wav")
											self.ChargeAttack = nil
											self:SetBarrelRestSpeed(0)
											return 2
										else
											self.soundloops.minigunfire:Play()
											self.soundloops.minigunspin:Play()
											return 0.05
										end
									end
				tab.FireFunc = function(self,item)
									self.ChargeAttack = ScavData.models["models/weapons/w_models/w_minigun.mdl"].ChargeAttack
									self.chargeitem = item
									self.Owner:EmitSound("weapons/minigun_wind_up.wav")
									self.soundloops.minigunspin = CreateSound(self.Owner,"weapons/minigun_spin.wav")
									self.soundloops.minigunfire = CreateSound(self.Owner,"weapons/minigun_shoot.wav")
									self:SetBarrelRestSpeed(900)									
									return false
								end
				ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_minigun.mdl",200,0) end
			else
				tab.ChargeAttack = function(self,item)
										local bullet = {}
											bullet.Num = 2
											bullet.Src = self.Owner:GetShootPos()
											bullet.Dir = self:GetAimVector()
											bullet.Spread = Vector(0.05,0.05,0)
											bullet.Tracer = 3
											bullet.Force = 5
											bullet.Damage = 6
											bullet.TracerName = "ef_scav_tr_b"
										self.Owner:FireBullets(bullet)
										self:MuzzleFlash2()
										if !self.Owner:Crouching() || !(self.Owner:GetGroundEntity():IsValid()||self.Owner:GetGroundEntity():IsWorld()) then
											self.Owner:SetEyeAngles((VectorRand()*0.1+self:GetAimVector()):Angle())
										else
											self.Owner:SetEyeAngles((VectorRand()*0.02+self:GetAimVector()):Angle())
										end
										self.Owner:SetAnimation(PLAYER_ATTACK1)
										self:TakeSubammo(item,1)
										local continuefiring = self:ProcessLinking(item) && self:StopChargeOnRelease()
										if !continuefiring then
											return 2
										else
											return 0.05
										end
									end
				tab.FireFunc = function(self,item)
									self.chargeitem = item
									self.ChargeAttack = ScavData.models["models/weapons/w_models/w_minigun.mdl"].ChargeAttack						
									return false
								end
			end
			tab.Cooldown = 1
			
		ScavData.models["models/weapons/w_models/w_minigun.mdl"] = tab	
	
	
	
	
	if SERVER then
		ScavData.CollectFuncs["models/items/ammopack_small.mdl"] = function(self,ent)
																	self:AddItem("models/weapons/shells/shell_shotgun.mdl",1,0,2)
																	self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0,1)
																end
		ScavData.CollectFuncs["models/items/ammopack_medium.mdl"] = function(self,ent)
																	self:AddItem("models/weapons/shells/shell_shotgun.mdl",1,0,4)
																	self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0,2)
																end
		ScavData.CollectFuncs["models/items/ammopack_large.mdl"] = function(self,ent)
																	self:AddItem("models/weapons/w_models/w_rocket.mdl",1,0,2)
																	self:AddItem("models/weapons/w_models/w_minigun.mdl",50,0)
																end
		ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"] = function(self,ent)
																	self:AddItem("models/props_c17/trappropeller_engine.mdl",1,0)
																	self:AddItem("models/props_vehicles/carparts_tire01a.mdl",1,0)
																	self:AddItem("models/props_vehicles/carparts_axel01a.mdl",1,0)
																	self:AddItem("models/props_vehicles/carparts_muffler01a.mdl",1,0)
																	self:AddItem("models/props_vehicles/carparts_wheel01a.mdl",1,0)
																	self:AddItem("models/props_vehicles/carparts_wheel01a.mdl",1,0)
																	self:AddItem("models/props_vehicles/carparts_door01a.mdl",1,0)
																	self:AddItem("models/props_vehicles/carparts_tire01a.mdl",1,0)
																	self:AddItem("models/props_vehicles/carparts_axel01a.mdl",1,0)
																	self:AddItem("models/items/car_battery01.mdl",20,0)
																end
		ScavData.CollectFuncs["models/props_vehicles/car001a_hatchback.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car002a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car002b.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car003a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car003b.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car004a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car004b.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car005a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car005b.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/van001a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/vehicles/vehicle_van.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/truck003a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/truck001a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/truck002a_cab.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car002a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car001b_phy.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car001a_phy.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car002b_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car003a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car003b_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car004a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car004b_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car005a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car005b_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/van001a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/van001a_nodoor.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/van001a_nodoor_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
	end

/*==============================================================================================
	--C4
==============================================================================================*/
		
		local tab = {}
			tab.Name = "C4 Explosive"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			PrecacheParticleSystem("scav_exp_fireball3")
			if SERVER then
				tab.FireFunc = function(self,item)
						self.Owner:ViewPunch(Angle(-20,math.Rand(-0.1,0.1),0))
						local proj = ents.Create("scav_c4")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self.Owner:GetShootPos())
						//proj:SetAngles((self:GetAimVector():Angle():Up()*-1):Angle())
						proj:Spawn()
						proj:Arm(30)
						proj:SetSkin(item.data)
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(true)
						proj:GetPhysicsObject():SetDragCoefficient(-100)
						proj:GetPhysicsObject():EnableGravity(true)
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*500)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						//gamemode.Call("ScavFired",self.Owner,proj)
						return true
					end
				ScavData.CollectFuncs["models/weapons/w_c4.mdl"] = function(self,ent) self:AddItem("models/weapons/w_c4_planted.mdl",1,0) end
				ScavData.CollectFuncs["models/weapons/w_c4_planted.mdl"] = ScavData.GiveOneOfItem
			end
			tab.Cooldown = 5
		//ScavData.models["models/weapons/w_c4.mdl"] = tab
		ScavData.models["models/weapons/w_c4_planted.mdl"] = tab
		

/*==============================================================================================
	--Smoke Grenade
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Smoke Grenade"
			PrecacheParticleSystem("scav_exp_smoke_1")
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 7
			if SERVER then
				tab.FireFunc = function(self,item)
						if !self.smokegrenade || !self.smokegrenade:IsValid() then
							self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
							local proj = ents.Create("scav_projectile_smoke")
							self.smokegrenade = proj
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
							return true
						else
							self.Owner:EmitSound("buttons/button18.wav")
							return false
						end
					end
			end
			tab.Cooldown = 0.75
		ScavData.models["models/weapons/w_eq_smokegrenade.mdl"] = tab
		ScavData.models["models/weapons/w_eq_smokegrenade_thrown.mdl"] = tab
		
/*==============================================================================================
	--P90
==============================================================================================*/
		
		local tab = {}
			tab.Name = "P90"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			if SERVER then
				local bullet = {}
						bullet.Num = 1
						bullet.BaseSpread = Vector(0.045,0.045,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(math.Rand(-0.2,0.2),math.Rand(-0.2,0.2),0),0.1)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.BaseSpread)
						self.Owner:FireBullets(bullet)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitToAllButSelf("Weapon_P90.Single")
						self:AddInaccuracy(1/175,0.1)
						self:AddBarrelSpin(300)
						self:MuzzleFlash2()
						return self:TakeSubammo(item,1)
					end
				ScavData.CollectFuncs["models/weapons/w_smg_p90.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
			else
				local bullet = {}
						bullet.Num = 1
						bullet.BaseSpread = Vector(0.045,0.045,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						if item.subammo <= 0 then
							return
						end
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.BaseSpread)
						self.Owner:FireBullets(bullet)
						self.Owner:EmitSound("Weapon_P90.Single")
						self.Owner:ScavViewPunch(Angle(math.Rand(-0.2,0.2),math.Rand(-0.2,0.2),0),0.1)
						self:AddInaccuracy(1/175,0.1)
						self:MuzzleFlash2()
						return self:TakeSubammo(item,1)
					end
			end
			tab.Cooldown = 0.07
		ScavData.models["models/weapons/w_smg_p90.mdl"] = tab

/*==============================================================================================
	--AK-47
==============================================================================================*/
		
		local tab = {}
			tab.Name = "AK-47"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.035,0.035,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 36
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.3,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_AK47.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_AK47.Single")
						end
						self:AddInaccuracy(1/200,0.125)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_ak47.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),25,0) end
			end
			tab.Cooldown = 0.1
		ScavData.models["models/weapons/w_rif_ak47.mdl"] = tab

/*==============================================================================================
	--AUG
==============================================================================================*/
		
		local tab = {}
			tab.Name = "AUG"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03,0.03,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 32
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.3,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_AUG.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_AUG.Single")
						end
						self:AddInaccuracy(1/215,0.125)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_aug.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.09
		ScavData.models["models/weapons/w_rif_aug.mdl"] = tab

/*==============================================================================================
	--AWP
==============================================================================================*/
		
		local tab = {}
			tab.Name = "AWP"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.Spread = Vector(0.00,0.00,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 115
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-5,math.Rand(-0.2,0.2),0),0.5,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_AWP.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_AWP.Single")
						end
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_snip_awp.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
			end
			tab.Cooldown = 1.455
		ScavData.models["models/weapons/w_snip_awp.mdl"] = tab

/*==============================================================================================
	--Desert Eagle
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Desert Eagle"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.015,0.015,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 54
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(math.Rand(-8,-9),math.Rand(-0.2,0.2),0),0.5)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_Deagle.Single")
						self:AddBarrelSpin(300)
					else
						self.Owner:EmitSound("Weapon_Deagle.Single")
					end
					self.nextfireearly = CurTime()+0.225
					self:AddInaccuracy(0.1,0.2)
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_deagle.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),7,0) end
			end
			tab.Cooldown = 0.7
		ScavData.models["models/weapons/w_pist_deagle.mdl"] = tab

/*==============================================================================================
	--Elites
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Elite"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 45
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.2)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_Elite.Single")
						self:AddBarrelSpin(300)
					else
						self.Owner:EmitSound("Weapon_Elite.Single")
					end
					self.nextfireearly = CurTime()+0.075
					self:AddInaccuracy(0.1,0.2)
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_elite_single.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,0) end
				ScavData.CollectFuncs["models/weapons/w_pist_elite.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
				ScavData.CollectFuncs["models/weapons/w_pist_elite_dropped.mdl"] = ScavData.CollectFuncs["models/weapons/w_pist_elite.mdl"]
				ScavData.CollectFuncs["models/weapons/w_eq_eholster_elite.mdl"] = ScavData.CollectFuncs["models/weapons/w_pist_elite_single.mdl"]
			end
			tab.Cooldown = 0.3
		ScavData.models["models/weapons/w_pist_elite_single.mdl"] = tab
		ScavData.models["models/weapons/w_pist_elite.mdl"] = tab
		ScavData.models["models/weapons/w_pist_elite_dropped.mdl"] = tab
		ScavData.models["models/weapons/w_pist_elite_single.mdl"] = tab
		
/*==============================================================================================
	--FAMAS
==============================================================================================*/
		
		local tab = {}
			tab.Name = "FAMAS"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03,0.03,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 30
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_FAMAS.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_FAMAS.Single")
						end
						self:AddInaccuracy(1/215,0.125)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_famas.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),25,0) end
			end
			tab.Cooldown = 0.09
		ScavData.models["models/weapons/w_rif_famas.mdl"] = tab

/*==============================================================================================
	--FiveSeven
==============================================================================================*/
		
		local tab = {}
			tab.Name = "FiveSeven"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 25
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_FiveSeven.Single")
						self:AddBarrelSpin(300)
					else
						self.Owner:EmitSound("Weapon_FiveSeven.Single")
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_fiveseven.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
			end
			tab.Cooldown = 0.3
		ScavData.models["models/weapons/w_pist_fiveseven.mdl"] = tab

/*==============================================================================================
	--Galil
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Galil"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.035,0.035,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 30
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_Galil.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_Galil.Single")
						end
						self:AddInaccuracy(1/200,0.125)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_galil.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),35,0) end
			end
			tab.Cooldown = 0.09
		ScavData.models["models/weapons/w_rif_galil.mdl"] = tab

/*==============================================================================================
	--Glock
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Glock"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 25
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_Glock.Single")
						self:AddBarrelSpin(300)
					else
						self.Owner:EmitSound("Weapon_Glock.Single")
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_glock18.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
			end
			tab.Cooldown = 0.3
		ScavData.models["models/weapons/w_pist_glock18.mdl"] = tab		

/*==============================================================================================
	--m3super90
==============================================================================================*/
		
		local tab = {}
			tab.Name = "m3super90"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 9
					bullet.Spread = Vector(0.1,0.1,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 22
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-5,math.Rand(-0.2,0.2),0),0.5)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_M3.Single")
					else
						self.Owner:EmitSound("Weapon_M3.Single")
					end
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_shot_m3super90.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,0) end
			end
			tab.Cooldown = 0.88
		ScavData.models["models/weapons/w_shot_m3super90.mdl"] = tab

/*==============================================================================================
	--M4A1
==============================================================================================*/
		
		local tab = {}
			tab.Name = "M4A1"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03,0.03,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 33
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_M4A1.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_M4A1.Single")
						end
						self:AddInaccuracy(1/220,0.1)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_m4a1.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.09
		ScavData.models["models/weapons/w_rif_m4a1.mdl"] = tab

/*==============================================================================================
	--Silenced M4A1
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Silenced M4A1"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03,0.03,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 33
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_M4A1.Silenced")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_M4A1.Silenced")
						end
						self:AddInaccuracy(1/220,0.1)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_m4a1_silencer.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.09
		ScavData.models["models/weapons/w_rif_m4a1_silencer.mdl"] = tab

/*==============================================================================================
	--M249 Para
==============================================================================================*/
		
		local tab = {}
			tab.Name = "M249"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.04,0.04,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 32
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_M249.Single")
							self:AddBarrelSpin(300)
							self:SetBlockPoseInstant(1,4)
							self:SetPanelPoseInstant(0.25,2)
						else
							self.Owner:EmitSound("Weapon_M249.Single")
						end
						self:AddInaccuracy(1/175,0.09)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_mach_m249para.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,0) end
			end
			tab.Cooldown = 0.08
		ScavData.models["models/weapons/w_mach_m249para.mdl"] = tab
		
/*==============================================================================================
	--MAC10
==============================================================================================*/
		
		local tab = {}
			tab.Name = "MAC10"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.06,0.06,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 29
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.7,math.Rand(-0.4,0.4),0),0.2,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_MAC10.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_MAC10.Single")
						end
						self:AddInaccuracy(1/200,0.165)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_mac10.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.075
		ScavData.models["models/weapons/w_smg_mac10.mdl"] = tab

/*==============================================================================================
	--MP5
==============================================================================================*/
		
		local tab = {}
			tab.Name = "MP5"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.045,0.045,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-1,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_MP5Navy.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_MP5Navy.Single")
						end
						self:AddInaccuracy(1/220,0.075)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_mp5.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.08
		ScavData.models["models/weapons/w_smg_mp5.mdl"] = tab

/*==============================================================================================
	--p228
==============================================================================================*/
		
		local tab = {}
			tab.Name = "p228"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 40
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-1,math.Rand(-0.2,0.2),0),0.1)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_P228.Single")
						self:AddBarrelSpin(300)
					else
						self.Owner:EmitSound("Weapon_P228.Single")
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_p228.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),13,0) end
			end
			tab.Cooldown = 0.3
		ScavData.models["models/weapons/w_pist_p228.mdl"] = tab

/*==============================================================================================
	--Scout
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Scout"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.Spread = Vector(0.0,0.0,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 75
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-3,math.Rand(-0.2,0.2),0),0.4,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_Scout.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_Scout.Single")
						end
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_snip_scout.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
			end
			tab.Cooldown = 1.25
		ScavData.models["models/weapons/w_snip_scout.mdl"] = tab

/*==============================================================================================
	--sg550
==============================================================================================*/
		
		local tab = {}
			tab.Name = "sg550"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.Spread = Vector(0.0,0.0,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 70
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-5,math.Rand(-0.2,0.2),0),0.5,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_SG550.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_SG550.Single")
						end
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_snip_sg550.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.25
		ScavData.models["models/weapons/w_snip_sg550.mdl"] = tab

/*==============================================================================================
	--sg552
==============================================================================================*/
		
		local tab = {}
			tab.Name = "sg552"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03,0.03,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 33
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_SG552.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_SG552.Single")
						end
						self:AddInaccuracy(1/220,0.1)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_sg552.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.09
		ScavData.models["models/weapons/w_rif_sg552.mdl"] = tab

/*==============================================================================================
	--TMP
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Silenced TMP"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.055,0.055,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_TMP.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_TMP.Single")
						end
						self:AddInaccuracy(1/200,0.14)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_tmp.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.07
		ScavData.models["models/weapons/w_smg_tmp.mdl"] = tab

/*==============================================================================================
	--UMP45
==============================================================================================*/
		
		local tab = {}
			tab.Name = "UMP45"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			
				local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.055,0.055,0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self,item)
						self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
						self.Owner:FireBullets(bullet)
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitToAllButSelf("Weapon_UMP45.Single")
							self:AddBarrelSpin(300)
						else
							self.Owner:EmitSound("Weapon_UMP45.Single")
						end
						self:AddInaccuracy(1/210,0.1)
						return self:TakeSubammo(item,1)
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_ump45.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),25,0) end
			end
			tab.Cooldown = 0.105
		ScavData.models["models/weapons/w_smg_ump45.mdl"] = tab

/*==============================================================================================
	--USP
==============================================================================================*/
		
		local tab = {}
			tab.Name = "USP"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 34
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_USP.Single")
						self:AddBarrelSpin(300)
					else
						self.Owner:EmitSound("Weapon_USP.Single")
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_usp.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),12,0) end
			end
			tab.Cooldown = 0.3
		ScavData.models["models/weapons/w_pist_usp.mdl"] = tab

/*==============================================================================================
	--Silenced USP
==============================================================================================*/
		
		local tab = {}
			tab.Name = "Silenced USP"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 34
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-1,math.Rand(-0.2,0.2),0),0.3)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_USP.SilencedShot")
						self:AddBarrelSpin(300)
					else
						self.Owner:EmitSound("Weapon_USP.SilencedShot")
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_usp_silencer.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),12,0) end
			end
			tab.Cooldown = 0.3
		ScavData.models["models/weapons/w_pist_usp_silencer.mdl"] = tab

/*==============================================================================================
	--xm1014
==============================================================================================*/
		
		local tab = {}
			tab.Name = "xm1014"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 6
					bullet.Spread = Vector(0.1,0.1,0)
					bullet.Tracer = 1
					bullet.Force = 50
					bullet.Damage = 20
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-5,math.Rand(-0.2,0.2),0),0.5)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitToAllButSelf("Weapon_XM1014.Single")
					else
						self.Owner:EmitSound("Weapon_XM1014.Single")
					end
					self.nextfireearly = CurTime()+0.25
					return self:TakeSubammo(item,1)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_shot_xm1014.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),7,0) end
			end
			tab.Cooldown = 0.88
		ScavData.models["models/weapons/w_shot_xm1014.mdl"] = tab
		
/*==============================================================================================
	--SCAR
==============================================================================================*/
		
		
		
		local tab = {}
			tab.Name = "SCAR"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.chargeanim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			if SERVER then
				local bullet = {}
					bullet.Num = 1
					bullet.Spread = Vector(0.015,0.015,0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 7
					bullet.TracerName = "Tracer"
				tab.ChargeAttack = function(self,item)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self.Owner:GetAimVector()
					self.Owner:FireBullets(bullet)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitToAllButSelf("weapons/rifle_desert/gunfire/rifle_fire_1.wav")
					self:TakeSubammo(item,1)
					item.shotsleft = item.shotsleft-1
					

					if (item.subammo <= 0) || (item.shotsleft <= 0) then
						self.ChargeAttack = nil
						if item.subammo <= 0 then
							item:Remove()
						end
						return 0.2
					end
					return 0.1
				end
				tab.FireFunc = function(self,item)
					item.shotsleft = 3
					self.ChargeAttack = ScavData.models["models/w_models/weapons/w_desert_rifle.mdl"].ChargeAttack
					self.chargeitem = item
					return false
				end
				ScavData.CollectFuncs["models/w_models/weapons/w_desert_rifle.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
			else
			
				local bullet = {}
					bullet.Num = 1
					bullet.Spread = Vector(0.015,0.015,0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 7
					bullet.TracerName = "Tracer"
				tab.ChargeAttack = function(self,item)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self.Owner:GetAimVector()
					self.Owner:FireBullets(bullet)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("weapons/rifle_desert/gunfire/rifle_fire_1.wav")
					self.Owner:ScavViewPunch(Angle(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),0),0.1)
					self:TakeSubammo(item,1)
					item.shotsleft = item.shotsleft-1
					if (item.subammo <= 0) || (item.shotsleft <= 0) then
						self.ChargeAttack = nil
						return 0.2
					end
					return 0.1
				end
				tab.FireFunc = function(self,item)
					item.shotsleft = 3
					self.ChargeAttack = ScavData.models["models/w_models/weapons/w_desert_rifle.mdl"].ChargeAttack
					self.chargeitem = item
					return false
				end
			end
			tab.Cooldown = 0
		ScavData.models["models/w_models/weapons/w_desert_rifle.mdl"] = tab