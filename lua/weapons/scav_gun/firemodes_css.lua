--Firemodes largely related to the Counter-Strike series. Can have other games' props defined!

local eject = "brass"

--[[==============================================================================================
	--C4
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.c4"
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
						--proj:SetAngles((self:GetAimVector():Angle():Up()*-1):Angle())
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
						--gamemode.Call("ScavFired",self.Owner,proj)
						return true
					end
				--ScavData.CollectFuncs["models/weapons/w_suitcase_passenger.mdl"] = ScavData.GiveOneOfItem
				ScavData.CollectFuncs["models/weapons/w_c4.mdl"] = function(self,ent) self:AddItem("models/weapons/w_c4_planted.mdl",1,0) end
				--ScavData.CollectFuncs["models/weapons/w_c4_planted.mdl"] = ScavData.GiveOneOfItem
				--DoD:S
				ScavData.CollectFuncs["models/props_crates/tnt_crate1.mdl"] = function(self,ent) self:AddItem("models/weapons/w_tnt.mdl",1,0,3) end
				ScavData.CollectFuncs["models/props_crates/tnt_crate2.mdl"] = function(self,ent) self:AddItem("models/weapons/w_tnt.mdl",1,0,3) end
				ScavData.CollectFuncs["models/props_crates/tnt_dump.mdl"] = function(self,ent) self:AddItem("models/weapons/w_tnt.mdl",1,0,6) end
			end
			tab.Cooldown = 5
		--ScavData.RegisterFiremode(tab,"models/weapons/w_c4.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_suitcase_passenger.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/briefcase001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/suitcase001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/suitcase_passenger_physics.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/weapons/w_c4_planted.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/weapons/w_tnt.mdl")
		

--[[==============================================================================================
	--Smoke Grenade
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.smoke"
			PrecacheParticleSystem("scav_exp_smoke_1")
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 7
			if SERVER then
				tab.FireFunc = function(self,item)
						if not self.smokegrenade or not self.smokegrenade:IsValid() then
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
		ScavData.RegisterFiremode(tab,"models/weapons/w_eq_smokegrenade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_eq_smokegrenade_thrown.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/weapons/p_smoke_us.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/p_smoke_ger.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_smoke_ger.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_smoke_us.mdl")
		
--[[==============================================================================================
	--P90
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.p90"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
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
				if SERVER then
					self.Owner:EmitSound("Weapon_P90.Single")
					self:AddBarrelSpin(300)
				else
					timer.Simple(.025,function() 
						local ef = EffectData()
						local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
						if attach then
							ef:SetOrigin(attach.Pos)
							ef:SetAngles(attach.Ang)
							ef:SetFlags(75) --velocity
							util.Effect("EjectBrass_57",ef)
						end
					end)
				end
				self:AddInaccuracy(1/175,0.1)
				self:MuzzleFlash2()
				if SERVER then return self:TakeSubammo(item,1) end
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_p90.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
			end
			tab.Cooldown = 0.07
		ScavData.RegisterFiremode(tab,"models/weapons/w_smg_p90.mdl")

--[[==============================================================================================
	--AK-47
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.ak47"
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
							self.Owner:EmitSound("Weapon_AK47.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_762Nato",ef)
								end
							end)
						end
						self:AddInaccuracy(1/200,0.125)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_ak47.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),25,0) end
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_rifle_ak47.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),40,0) end
			end
			tab.Cooldown = 0.1
		ScavData.RegisterFiremode(tab,"models/weapons/w_rif_ak47.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_rifle_ak47.mdl")

--[[==============================================================================================
	--AUG
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.aug"
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
							self.Owner:EmitSound("Weapon_AUG.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_556",ef)
								end
							end)
						end
						self:AddInaccuracy(1/215,0.125)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_aug.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.09
		ScavData.RegisterFiremode(tab,"models/weapons/w_rif_aug.mdl")

--[[==============================================================================================
	--AWP
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.awp"
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
							self.Owner:EmitSound("Weapon_AWP.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.4,function() 
								self.Owner:EmitSound("weapons/awp/awp_bolt.wav",75,100,1)
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_338Mag",ef)
								end
							end)
						end
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_snip_awp.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_sniper_awp.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_csgo_awp/c_csgo_awp.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
			end
			tab.Cooldown = 1.455
		ScavData.RegisterFiremode(tab,"models/weapons/w_snip_awp.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_sniper_awp.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_csgo_awp/c_csgo_awp.mdl")

--[[==============================================================================================
	--Desert Eagle
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.deagle"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.015,0.015,0)
					bullet.Tracer = 1
					bullet.Force = 5
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
						self.Owner:EmitSound("Weapon_Deagle.Single")
						self:AddBarrelSpin(300)
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
					self.nextfireearly = CurTime()+0.225
					self:AddInaccuracy(0.1,0.2)
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_deagle.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),7,0) end
				ScavData.CollectFuncs["models/w_models/weapons/w_desert_eagle.mdl"]	= function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,0) end
			end
			tab.Cooldown = 0.7
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_deagle.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_desert_eagle.mdl")

--[[==============================================================================================
	--Elites
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.elites"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 5
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
						self.Owner:EmitSound("Weapon_Elite.Single")
						self:AddBarrelSpin(300)
					else
						timer.Simple(.025,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("EjectBrass_9mm",ef)
							end
						end)
					end
					self.nextfireearly = CurTime()+0.075
					self:AddInaccuracy(0.1,0.2)
					if SERVER then return self:TakeSubammo(item,1) end
				end
			tab.OnArmed = function(self,item,olditemname)
					if IsMounted(240) and SERVER then
						self.Owner:EmitSound("weapons/elite/elite_deploy.wav")
					end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_elite_single.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,0) end
				ScavData.CollectFuncs["models/weapons/w_pist_elite.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
				ScavData.CollectFuncs["models/weapons/w_pist_elite_dropped.mdl"] = ScavData.CollectFuncs["models/weapons/w_pist_elite.mdl"]
				ScavData.CollectFuncs["models/weapons/w_eq_eholster_elite.mdl"] = ScavData.CollectFuncs["models/weapons/w_pist_elite_single.mdl"]
				--L4D/2
				ScavData.CollectFuncs["models/w_models/weapons/w_dual_pistol_1911.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
				ScavData.CollectFuncs["models/w_models/weapons/w_pistol_1911.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,0) end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_elite_single.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_elite.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_elite_dropped.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_elite_single.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_dual_pistol_1911.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_eq_eholster_elite.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_pistol_1911.mdl")
		
--[[==============================================================================================
	--FAMAS
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.famas"
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
							self.Owner:EmitSound("Weapon_FAMAS.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_556",ef)
								end
							end)
						end
						self:AddInaccuracy(1/215,0.125)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_famas.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),25,0) end
			end
			tab.Cooldown = 0.09
		ScavData.RegisterFiremode(tab,"models/weapons/w_rif_famas.mdl")

--[[==============================================================================================
	--FiveSeven
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.fiveseven"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 5
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
						self.Owner:EmitSound("Weapon_FiveSeven.Single")
						self:AddBarrelSpin(300)
					else
						timer.Simple(.025,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("EjectBrass_57",ef)
							end
						end)
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_fiveseven.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_fiveseven.mdl")

--[[==============================================================================================
	--Galil
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.galil"
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
							self.Owner:EmitSound("Weapon_Galil.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_556",ef)
								end
							end)
						end
						self:AddInaccuracy(1/200,0.125)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_galil.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),35,0) end
				--DoD:S
				ScavData.CollectFuncs["models/weapons/w_bar.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
			end
			tab.Cooldown = 0.09
		ScavData.RegisterFiremode(tab,"models/weapons/w_rif_galil.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/weapons/w_bar.mdl")

--[[==============================================================================================
	--Glock
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.glock"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 5
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
						self.Owner:EmitSound("Weapon_Glock.Single")
						self:AddBarrelSpin(300)
					else
						timer.Simple(.025,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("EjectBrass_9mm",ef)
							end
						end)
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_glock18.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_pistol_b.mdl"]	= function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,0) end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_glock18.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_pistol_b.mdl")

--[[==============================================================================================
	--m3super90
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m3super90"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 9
					bullet.Spread = Vector(0.1,0.1,0)
					bullet.Tracer = 1
					bullet.Force = 4
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
						self.Owner:EmitSound("Weapon_M3.Single")
					else
						timer.Simple(.5,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("EjectBrass_12Gauge",ef)
							end
						end)
					end
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_shot_m3super90.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,0) end
			end
			tab.Cooldown = 0.88
		ScavData.RegisterFiremode(tab,"models/weapons/w_shot_m3super90.mdl")

--[[==============================================================================================
	--M4A1
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m4a1"
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
							self.Owner:EmitSound("Weapon_M4A1.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_556",ef)
								end
							end)
						end
						self:AddInaccuracy(1/220,0.1)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_m4a1.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
				--L4D
				ScavData.CollectFuncs["models/w_models/weapons/w_rifle_m16a2.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
			end
			tab.Cooldown = 0.09
		ScavData.RegisterFiremode(tab,"models/weapons/w_rif_m4a1.mdl")
		--L4D
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_rifle_m16a2.mdl")

--[[==============================================================================================
	--Silenced M4A1
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m4a1sil"
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
						--self:MuzzleFlash2() --no flash on silenced weapon!
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitSound("Weapon_M4A1.Silenced")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_556",ef)
								end
							end)
						end
						self:AddInaccuracy(1/220,0.1)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_m4a1_silencer.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.09
		ScavData.RegisterFiremode(tab,"models/weapons/w_rif_m4a1_silencer.mdl")

--[[==============================================================================================
	--M249 Para
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m249"
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
							self.Owner:EmitSound("Weapon_M249.Single")
							self:AddBarrelSpin(300)
							self:SetBlockPoseInstant(1,4)
							self:SetPanelPoseInstant(0.25,2)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(85) --velocity
									util.Effect("EjectBrass_556",ef)
								end
							end)
						end
						self:AddInaccuracy(1/175,0.09)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_mach_m249para.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,0) end
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_m60.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),150,0) end
			end
			tab.Cooldown = 0.08
		ScavData.RegisterFiremode(tab,"models/weapons/w_mach_m249para.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_m60.mdl")
		
--[[==============================================================================================
	--MAC10
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.mac10"
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
							self.Owner:EmitSound("Weapon_MAC10.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_9mm",ef)
								end
							end)
						end
						self:AddInaccuracy(1/200,0.165)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_mac10.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
				--L4D/2
				ScavData.CollectFuncs["models/w_models/weapons/w_smg_uzi.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
				ScavData.CollectFuncs["models/w_models/weapons/w_smg_a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
			end
			tab.Cooldown = 0.075
		ScavData.RegisterFiremode(tab,"models/weapons/w_smg_mac10.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_smg_uzi.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_smg_a.mdl")

--[[==============================================================================================
	--MP5
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.mp5"
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
							self.Owner:EmitSound("Weapon_MP5Navy.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_9mm",ef)
								end
							end)
						end
						self:AddInaccuracy(1/220,0.075)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_mp5.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_smg_mp5.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
			end
			tab.Cooldown = 0.08
		ScavData.RegisterFiremode(tab,"models/weapons/w_smg_mp5.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_smg_mp5.mdl")

--[[==============================================================================================
	--p228
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.p228"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 5
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
						self.Owner:EmitSound("Weapon_P228.Single")
						self:AddBarrelSpin(300)
					else
						timer.Simple(.025,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("EjectBrass_9mm",ef)
							end
						end)
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_p228.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),13,0) end
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_pistol_a.mdl"]	= function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,0) end --p220
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_p228.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_pistol_a.mdl")

--[[==============================================================================================
	--Scout
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.scoutsnipe"
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
							self.Owner:EmitSound("Weapon_Scout.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.5,function()
								self.Owner:EmitSound("weapons/scout/scout_bolt.wav",75,100,1)
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_762Nato",ef)
								end
							end)
						end
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_snip_scout.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
				--L4D/2
				ScavData.CollectFuncs["models/w_models/weapons/w_sniper_scout.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,0) end
				ScavData.CollectFuncs["models/w_models/weapons/w_sniper_mini14.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,0) end
			end
			tab.Cooldown = 1.25
		ScavData.RegisterFiremode(tab,"models/weapons/w_snip_scout.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_sniper_scout.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_sniper_mini14.mdl")

--[[==============================================================================================
	--sg550
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.sg550"
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
							self.Owner:EmitSound("Weapon_SG550.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_556",ef)
								end
							end)
						end
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_snip_sg550.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_sniper_military.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.25
		ScavData.RegisterFiremode(tab,"models/weapons/w_snip_sg550.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_sniper_military.mdl")

--[[==============================================================================================
	--sg552
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.sg552"
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
							self.Owner:EmitSound("Weapon_SG552.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_556",ef)
								end
							end)
						end
						self:AddInaccuracy(1/220,0.1)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_rif_sg552.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_rifle_sg552.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
			end
			tab.Cooldown = 0.09
		ScavData.RegisterFiremode(tab,"models/weapons/w_rif_sg552.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_rifle_sg552.mdl")

--[[==============================================================================================
	--TMP
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.tmp"
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
						--self:MuzzleFlash2() --no flash on silenced weapon!
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitSound("Weapon_TMP.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_9mm",ef)
								end
							end)
						end
						self:AddInaccuracy(1/200,0.14)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_tmp.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0.07
		ScavData.RegisterFiremode(tab,"models/weapons/w_smg_tmp.mdl")

--[[==============================================================================================
	--UMP45
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.ump45"
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
							self.Owner:EmitSound("Weapon_UMP45.Single")
							self:AddBarrelSpin(300)
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_9mm",ef)
								end
							end)
						end
						self:AddInaccuracy(1/210,0.1)
						if SERVER then return self:TakeSubammo(item,1) end
					end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_smg_ump45.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),25,0) end
			end
			tab.Cooldown = 0.105
		ScavData.RegisterFiremode(tab,"models/weapons/w_smg_ump45.mdl")

--[[==============================================================================================
	--USP
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.usp"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 5
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
						self.Owner:EmitSound("Weapon_USP.Single")
						self:AddBarrelSpin(300)
					else
						timer.Simple(.025,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("EjectBrass_9mm",ef)
							end
						end)
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_usp.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),12,0) end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_usp.mdl")

--[[==============================================================================================
	--Silenced USP
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.uspsil"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0,0.0,0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 34
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self,item)
					self.Owner:ScavViewPunch(Angle(-1,math.Rand(-0.2,0.2),0),0.3)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					--self:MuzzleFlash2() --no flash on silenced weapon!
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						if item.ammo == "models/w_silencer.mdl" then --HL:S
							self.Owner:EmitSound("weapons/pl_gun2.wav")
						else
							self.Owner:EmitSound("Weapon_USP.SilencedShot")
						end
						self:AddBarrelSpin(300)
					else
						if item.ammo == "models/w_silencer.mdl" then --HL:S
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									--lovingly borrowed from https:--steamcommunity.com/sharedfiles/filedetails/?id=1360233031
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
						else
							timer.Simple(.025,function() 
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetFlags(75) --velocity
									util.Effect("EjectBrass_9mm",ef)
								end
							end)
						end
					end
					self.nextfireearly = CurTime()+0.15
					self:AddInaccuracy(0.1,0.2)
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_pist_usp_silencer.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),12,0) end
				--ScavData.CollectFuncs["models/w_silencer.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),17,0) end --no phys model
			end
			tab.Cooldown = 0.3
		--CSS
		ScavData.RegisterFiremode(tab,"models/weapons/w_pist_usp_silencer.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab,"models/w_silencer.mdl")

--[[==============================================================================================
	--xm1014
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.xm1014"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local bullet = {}
					bullet.Num = 6
					bullet.Spread = Vector(0.1,0.1,0)
					bullet.Tracer = 1
					bullet.Force = 4
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
						self.Owner:EmitSound("Weapon_XM1014.Single")
					else
						timer.Simple(.025,function() 
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("EjectBrass_12Gauge",ef)
							end
						end)
					end
					self.nextfireearly = CurTime()+0.25
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_shot_xm1014.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),7,0) end
				ScavData.CollectFuncs["models/w_models/weapons/w_autoshot_m4super.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
				ScavData.CollectFuncs["models/w_models/weapons/w_shotgun_spas.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
			end
			tab.Cooldown = 0.88
		ScavData.RegisterFiremode(tab,"models/weapons/w_shot_xm1014.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_autoshot_m4super.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_shotgun_spas.mdl")
		
--[[==============================================================================================
	--SCAR
==============================================================================================]]--
		
		
		
		local tab = {}
			tab.Name = "#scav.scavcan.scar"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.chargeanim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
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
					if SERVER then self:TakeSubammo(item,1) end
					item.shotsleft = item.shotsleft-1
					

					if (item.subammo <= 0) or (item.shotsleft <= 0) then
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
			if SERVER then
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_desert_rifle.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
				ScavData.CollectFuncs["models/w_models/weapons/w_rifle_b.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/w_models/weapons/w_desert_rifle.mdl"),50,0) end
			end
			tab.Cooldown = 0
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_desert_rifle.mdl")
