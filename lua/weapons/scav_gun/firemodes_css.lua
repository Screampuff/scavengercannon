--Firemodes largely related to the Counter-Strike series. Can have other games' props defined!

--[[==============================================================================================
	--C4
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.c4"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			PrecacheParticleSystem("scav_exp_fireball3")
			if SERVER then
				tab.FireFunc = function(self, item)
						self.Owner:ViewPunch(Angle(-20, math.Rand(-0.1, 0.1), 0))
						local proj = ents.Create("scav_c4")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self.Owner:GetShootPos())
						--proj:SetAngles((self:GetAimVector():Angle():Up() * -1):Angle())
						proj:Spawn()
						proj:Arm(30)
						proj:SetSkin(item.data)
						if not IsValid(proj:GetPhysicsObject()) then
							local mins, maxs = proj:GetModelBounds()
							proj:PhysicsInitBox(mins, maxs, "weapon")
						end
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(true)
						proj:GetPhysicsObject():SetDragCoefficient(-100)
						proj:GetPhysicsObject():EnableGravity(true)
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector() * 500)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						--gamemode.Call("ScavFired", self.Owner, proj)
						return true
					end
				ScavData.CollectFuncs["models/weapons/w_c4.mdl"] = function(self, ent) return {{"models/weapons/w_c4_planted.mdl", 1, 0}} end
				--DoD:S
				ScavData.CollectFuncs["models/props_crates/tnt_crate1.mdl"] = function(self, ent) return {{"models/weapons/w_tnt.mdl", 1, 0, 3}} end
				ScavData.CollectFuncs["models/props_crates/tnt_crate2.mdl"] = function(self, ent) return {{"models/weapons/w_tnt.mdl", 1, 0, 3}} end
				ScavData.CollectFuncs["models/props_crates/tnt_dump.mdl"] = function(self, ent) return {{"models/weapons/w_tnt.mdl", 1, 0, 6}} end
				--L4D/2
				ScavData.CollectFuncs["models/props_waterfront/suitcase_open.mdl"] = function(self, ent) return {{"models/props_unique/airport/luggage2.mdl", 1, 1}} end
				ScavData.CollectFuncs["models/props_unique/airport/luggage_pile1.mdl"] = function(self, ent)
					local items = {}
					for i=1, 5 do
						table.insert(items,{"models/props_unique/airport/luggage" .. tostring(math.random(4)) .. ".mdl", 1, math.random(0,1)})
					end
					return items
				end
			end
			tab.Cooldown = 5
		ScavData.RegisterFiremode(tab, "models/dav0r/tnt/tnt.mdl")
		ScavData.RegisterFiremode(tab, "models/dav0r/tnt/tnttimed.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_suitcase_passenger.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/briefcase001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/suitcase001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/suitcase_passenger_physics.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/weapons/w_c4_planted.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/flag/briefcase.mdl")
		ScavData.RegisterFiremode(tab, "models/props_doomsday/australium_container.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/weapons/w_tnt.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/luggage1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/luggage1_floating.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/luggage2.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/luggage2_floating.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/luggage3.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/luggage3_floating.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/luggage4.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/luggage4_floating.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_satchel.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarmprops/miscdeco/bridgeexplosivesmesh.mdl")
		ScavData.RegisterFiremode(tab, "models/props/explosive/explosive.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_satchel.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_satchel_mp.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/c4_explosive.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/blastingkit01_c4.mdl")
		

--[[==============================================================================================
	--Smoke Grenade
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.smoke"
			PrecacheParticleSystem("scav_exp_smoke_1")
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 7
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 3
			if SERVER then
				tab.FireFunc = function(self, item)
					if not IsValid(self.smokegrenade) then
						self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
						local proj = ents.Create("scav_projectile_smoke")
						self.smokegrenade = proj
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
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(0, 10000, 0)) end)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)				
						return self:TakeSubammo(item, 1)
					else
						self.Owner:EmitSound("buttons/button18.wav")
						return false
					end
				end
			end
			tab.Cooldown = 0.75
		ScavData.RegisterFiremode(tab, "models/weapons/w_eq_smokegrenade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_eq_smokegrenade_thrown.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/weapons/p_smoke_us.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/p_smoke_ger.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_smoke_ger.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_smoke_us.mdl")
		
--[[==============================================================================================
	--P90
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.p90"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 150
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.045, 0.045, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(math.Rand(-0.2, 0.2), math.Rand(-0.2, 0.2), 0), 0.1)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 175, 0.1)
					if SERVER then
						self.Owner:EmitSound("Weapon_P90.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_57")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.07
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_smg_p90.mdl", 50)

--[[==============================================================================================
	--AK-47
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.ak47"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 120
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.035, 0.035, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 36
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.3, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 200, 0.125)
					if SERVER then
						self.Owner:EmitSound("Weapon_AK47.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_762Nato")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.1
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_rif_ak47.mdl", 25)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_rifle_ak47.mdl", 40)

--[[==============================================================================================
	--AUG
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.aug"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 120
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03, 0.03, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 32
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.3, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 215, 0.125)
					if SERVER then
						self.Owner:EmitSound("Weapon_AUG.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_556")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.09
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_rif_aug.mdl", 30)

--[[==============================================================================================
	--AWP
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.awp"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 40
			
				local bullet = {}
						bullet.Num = 1
						bullet.Spread = Vector(0.00, 0.00, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 115
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self, item)
						self.Owner:ScavViewPunch(Angle(-5, math.Rand(-0.2, 0.2), 0), 0.5, true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						if SERVER or not game.SinglePlayer() then
							self.Owner:FireBullets(bullet)
						end
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitSound("Weapon_AWP.Single")
							self:AddBarrelSpin(300)
						end
						timer.Simple(.4, function()
							if not IsValid(self) or not IsValid(self.Owner) then return end
							self.Owner:EmitSound("weapons/awp/awp_bolt.wav", 75, 100, 1)
							self:EjectShell("EjectBrass_338Mag")
						end)
						if SERVER then return self:TakeSubammo(item, 1) end
					end
			tab.Cooldown = 1.455
		ScavData.RegisterFiremode(tab, "models/weapons/w_snip_awp.mdl", 10)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_sniper_awp.mdl", 20)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_csgo_awp/c_csgo_awp.mdl", 25)

--[[==============================================================================================
	--Desert Eagle
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.deagle"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 42
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.015, 0.015, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 54
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(math.Rand(-8,-9), math.Rand(-0.2, 0.2), 0), 0.5)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("Weapon_Deagle.Single")
						self:AddBarrelSpin(300)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("ShellEject", false)
					end)
					self.nextfireearly = CurTime() + 0.225
					self:AddInaccuracy(0.1, 0.2)
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.Cooldown = 0.7
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_deagle.mdl", 7)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_desert_eagle.mdl", 8)

--[[==============================================================================================
	--Elites
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.elites"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 150
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0, 0.0, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 45
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.2)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("Weapon_Elite.Single")
						self:AddBarrelSpin(300)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_9mm")
					end)
					self.nextfireearly = CurTime() + 0.075
					self:AddInaccuracy(0.1, 0.2)
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			if SERVER then
				tab.OnArmed = function(self, item, olditemname)
					if CSS then
						if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
							self.Owner:EmitSound("weapons/elite/elite_deploy.wav")
						end
					end
				end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_elite_single.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_elite.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_elite_dropped.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/weapons/w_eq_eholster_elite.mdl", 15)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_dual_pistol_1911.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_pistol_1911.mdl", 15)
		
--[[==============================================================================================
	--FAMAS
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.famas"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 115
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03, 0.03, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 30
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 215, 0.125)
					if SERVER then
						self.Owner:EmitSound("Weapon_FAMAS.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_556")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.09
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_rif_famas.mdl", 25)

--[[==============================================================================================
	--FiveSeven
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.fiveseven"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			tab.MaxAmmo = 120
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0, 0.0, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 25
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("Weapon_FiveSeven.Single")
						self:AddBarrelSpin(300)
					end
					if CLIENT ~= game.SinglePlayer() then
						timer.Simple(.025, function()
							if not IsValid(self) then return end
							self:EjectShell("EjectBrass_57")
						end)
					end
					self.nextfireearly = CurTime() + 0.15
					self:AddInaccuracy(0.1, 0.2)
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_fiveseven.mdl", 20)

--[[==============================================================================================
	--Galil
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.galil"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 125
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.035, 0.035, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 30
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 200, 0.125)
					if SERVER then
						self.Owner:EmitSound("Weapon_Galil.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_556")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.09
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_rif_galil.mdl", 35)

--[[==============================================================================================
	--Glock
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.glock"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 140
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0, 0.0, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 25
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:FireBullets(bullet)
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("Weapon_Glock.Single")
						self:AddBarrelSpin(300)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_9mm")
					end)
					self.nextfireearly = CurTime() + 0.15
					self:AddInaccuracy(0.1, 0.2)
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_glock18.mdl", 20)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_pistol_b.mdl", 15)
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_glock.mdl", 17)
		ScavData.RegisterFiremode(tab, "models/weapons/w_glock_lh.mdl", 17)
		ScavData.RegisterFiremode(tab, "models/weapons/w_glock_mp.mdl", 17)
		ScavData.RegisterFiremode(tab, "models/weapons/w_9mmclip.mdl", 17)
		ScavData.RegisterFiremode(tab, "models/weapons/w_9mmclip_mp.mdl", 17)

--[[==============================================================================================
	--m3super90
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m3super90"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			tab.MaxAmmo = 40
			local bullet = {}
					bullet.Num = 9
					bullet.Spread = Vector(0.1, 0.1, 0)
					bullet.Tracer = 1
					bullet.Force = 4
					bullet.Damage = 22
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-5, math.Rand(-0.2, 0.2), 0), 0.5)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					timer.Simple(.5, function() 
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_12Gauge")
					end)
					if SERVER then
						self.Owner:EmitSound("Weapon_M3.Single")
						return self:TakeSubammo(item, 1)
					end
				end
			tab.Cooldown = 0.88
		ScavData.RegisterFiremode(tab, "models/weapons/w_shot_m3super90.mdl", 8)

--[[==============================================================================================
	--M4A1
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m4a1"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 120
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03, 0.03, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 33
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 220, 0.1)
					if SERVER then
						self.Owner:EmitSound("Weapon_M4A1.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_556")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.09
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_rif_m4a1.mdl", 30)
		--L4D
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_rifle_m16a2.mdl", 50)

--[[==============================================================================================
	--Silenced M4A1
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m4a1sil"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 120
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03, 0.03, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 33
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					--self:MuzzleFlash2() --no flash on silenced weapon!
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 220, 0.1)
					if SERVER then
						self.Owner:EmitSound("Weapon_M4A1.Silenced")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_556")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.09
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_rif_m4a1_silencer.mdl", 30)

--[[==============================================================================================
	--M249 Para
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m249"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 300
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.04, 0.04, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 32
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 175, 0.09)
					if SERVER then
						self.Owner:EmitSound("Weapon_M249.Single")
						self:AddBarrelSpin(300)
						self:SetBlockPoseInstant(1, 4)
						self:SetPanelPoseInstant(0.25, 2)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_556", 85)
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.08
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_mach_m249para.mdl", 100)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_m60.mdl", 150)
		
--[[==============================================================================================
	--MAC10
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.mac10"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 130
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.06, 0.06, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 29
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.7, math.Rand(-0.4, 0.4), 0), 0.2, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 200, 0.165)
					if SERVER then
						self.Owner:EmitSound("Weapon_MAC10.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_9mm")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.075
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_smg_mac10.mdl", 30)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_smg_uzi.mdl", 50)

--[[==============================================================================================
	--MP5
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.mp5"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 150
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.045, 0.045, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-1, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 220, 0.075)
					if SERVER then
						self.Owner:EmitSound("Weapon_MP5Navy.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_9mm")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.08
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_smg_mp5.mdl", 30)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_smg_mp5.mdl", 50)
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_mp5.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/weapons/w_mp5_mp.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/weapons/w_9mmarclip.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/weapons/w_9mmarclip_mp.mdl", 30)

--[[==============================================================================================
	--p228
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.p228"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 65
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0, 0.0, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 40
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-1, math.Rand(-0.2, 0.2), 0), 0.1)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("Weapon_P228.Single")
						self:AddBarrelSpin(300)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_9mm")
					end)
					self.nextfireearly = CurTime() + 0.15
					self:AddInaccuracy(0.1, 0.2)
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_p228.mdl", 13)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_pistol_a.mdl", 15) --p220

--[[==============================================================================================
	--Scout
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.scoutsnipe"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 100
			
				local bullet = {}
						bullet.Num = 1
						bullet.Spread = Vector(0.0, 0.0, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 75
						bullet.TracerName = "ef_scav_tr_b"
				tab.FireFunc = function(self, item)
						self.Owner:ScavViewPunch(Angle(-3, math.Rand(-0.2, 0.2), 0), 0.4, true)
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						if SERVER or not game.SinglePlayer() then
							self.Owner:FireBullets(bullet)
						end
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if SERVER then
							self.Owner:EmitSound("Weapon_Scout.Single")
							self:AddBarrelSpin(300)
						end
						timer.Simple(.5, function()
							if not IsValid(self) then return end
							self:EjectShell("EjectBrass_762Nato")
							if not IsValid(self.Owner) or CLIENT then return end
							self.Owner:EmitSound("weapons/scout/scout_bolt.wav", 75, 100, 1)
						end)
						if SERVER then return self:TakeSubammo(item, 1) end
					end
			tab.Cooldown = 1.25
		ScavData.RegisterFiremode(tab, "models/weapons/w_snip_scout.mdl", 10)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_sniper_scout.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_sniper_mini14.mdl", 15)

--[[==============================================================================================
	--sg550
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.sg550"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 120
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.0, 0.0, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 70
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-5, math.Rand(-0.2, 0.2), 0), 0.5, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("Weapon_SG550.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_556")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.25
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_snip_sg550.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/weapons/w_snip_g3sg1.mdl", 30)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_sniper_military.mdl", 30)

--[[==============================================================================================
	--sg552
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.sg552"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 120
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.03, 0.03, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 33
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 220, 0.1)
					if SERVER then
						self.Owner:EmitSound("Weapon_SG552.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_556")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.09
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_rif_sg552.mdl", 30)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_rifle_sg552.mdl", 50)

--[[==============================================================================================
	--TMP
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.tmp"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 150
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.055, 0.055, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					--self:MuzzleFlash2() --no flash on silenced weapon!
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 200, 0.14)
					if SERVER then
						self.Owner:EmitSound("Weapon_TMP.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_9mm")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.07
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_smg_tmp.mdl", 30)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_smg_a.mdl", 50)

--[[==============================================================================================
	--UMP45
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.ump45"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 125
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.AccuracyOffset = Vector(0.055, 0.055, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 26
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:AddInaccuracy(1 / 210, 0.1)
					if SERVER then
						self.Owner:EmitSound("Weapon_UMP45.Single")
						self:AddBarrelSpin(300)
						self:TakeSubammo(item, 1)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_9mm")
					end)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.105
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/weapons/w_smg_ump45.mdl", 25)

--[[==============================================================================================
	--USP
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.usp"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			tab.MaxAmmo = 112
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0, 0.0, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 34
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("Weapon_USP.Single")
						self:AddBarrelSpin(300)
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_9mm")
					end)
					self.nextfireearly = CurTime() + 0.15
					self:AddInaccuracy(0.1, 0.2)
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_usp.mdl", 12)

--[[==============================================================================================
	--Silenced USP
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.uspsil"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			tab.MaxAmmo = 112
			local bullet = {}
					bullet.Num = 1
					bullet.AccuracyOffset = Vector(0.0, 0.0, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 34
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-1, math.Rand(-0.2, 0.2), 0), 0.3)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					--self:MuzzleFlash2() --no flash on silenced weapon!
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound(item.ammo == "models/w_silencer.mdl" and "weapons/pl_gun2.wav" or "Weapon_USP.SilencedShot")
						self:AddBarrelSpin(300)
					end
					if item.ammo == "models/w_silencer.mdl" then --HL:S
						timer.Simple(.025, function()
							if not IsValid(self) then return end
							self:EjectShellHL1()
						end)
					else
						timer.Simple(.025, function()
							if not IsValid(self) then return end
							self:EjectShell("EjectBrass_9mm")
						end)
					end
					self.nextfireearly = CurTime() + 0.15
					self:AddInaccuracy(0.1, 0.2)
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.Cooldown = 0.3
		--CSS
		ScavData.RegisterFiremode(tab, "models/weapons/w_pist_usp_silencer.mdl", 12)
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_silencer.mdl"--[[, 17]]) --no phys model

--[[==============================================================================================
	--xm1014
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.xm1014"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 39
			local bullet = {}
					bullet.Num = 6
					bullet.Spread = Vector(0.1, 0.1, 0)
					bullet.Tracer = 1
					bullet.Force = 4
					bullet.Damage = 20
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					if not IsValid(self.Owner) then return end
					self.Owner:ScavViewPunch(Angle(-5, math.Rand(-0.2, 0.2), 0), 0.5)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("Weapon_XM1014.Single")
					end
					timer.Simple(.025, function()
						if not IsValid(self) then return end
						self:EjectShell("EjectBrass_12Gauge")
					end)
					self.nextfireearly = CurTime() + 0.25
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.Cooldown = 0.88
		ScavData.RegisterFiremode(tab, "models/weapons/w_shot_xm1014.mdl", 7)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_autoshot_m4super.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_shotgun_spas.mdl", 10)
		
--[[==============================================================================================
	--SCAR
==============================================================================================]]--
		
		
		
		local tab = {}
			tab.Name = "#scav.scavcan.scar"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.chargeanim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 420
				local bullet = {}
					bullet.Num = 1
					bullet.Spread = Vector(0.015, 0.015, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 7
					bullet.TracerName = "Tracer"
				tab.ChargeAttack = function(self, item)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self.Owner:GetAimVector()
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("weapons/rifle_desert/gunfire/rifle_fire_1.wav")
					if SERVER then self:TakeSubammo(item, 1) end
					item.shotsleft = item.shotsleft-1
					

					if (item.subammo <= 0) or (item.shotsleft <= 0) then
						self:SetChargeAttack()
						if item.subammo <= 0 then
							item:Remove()
						end
						return 0.2
					end
					return 0.1
				end
				tab.FireFunc = function(self, item)
					item.shotsleft = 3
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
					return false
				end
			tab.Cooldown = 0
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_desert_rifle.mdl", 50)
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_rifle_b.mdl", 50)
