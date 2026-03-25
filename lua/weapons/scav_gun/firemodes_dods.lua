--Firemodes largely related to the Day of Defeat series. Can have other games' props defined!

local WALK_SPEED = 20000
local PRONE_SPEED = 800 --900 would be crouching with walk key held

local dodviewpunch = function(self, kick)
	if SERVER then return end 
	self.Owner:SetEyeAngles((vector_up * (kick or 0.05) + self:GetAimVector()):Angle())
end

--[[==============================================================================================
	--.30 cal
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.30cal"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 300
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < WALK_SPEED then
							if self.Owner:Crouching() and self.Owner:GetVelocity():LengthSqr() < PRONE_SPEED then 
								bullet.Spread = Vector(0.1, 0.1, 0) --"true" spread for bipod is .01 in DoD, but this player has a lot more freedom of movement
								dodviewpunch(self, 0.01)
							else
								bullet.Spread = Vector(0.2, 0.2, 0)
								dodviewpunch(self)
							end
						else
							bullet.Spread = Vector(0.3, 0.3, 0)
							dodviewpunch(self)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 85
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.7, math.Rand(-0.4, 0.4), 0), 0.2, true)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_30cal.Shoot")
					self:EjectShellDoDS()
					if SERVER then
						--self:SetBlockPoseInstant(1, 4)
						self:SetPanelPoseInstant(0.25, 2)
						self:TakeSubammo(item, 1)
					end
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
				if SERVER then
					self:SetBarrelRestSpeed(1000)	
				end								
				return false
			end
			tab.Cooldown = 0.1
		ScavData.RegisterFiremode(tab, "models/weapons/w_30cal.mdl", 150)
		ScavData.RegisterFiremode(tab, "models/weapons/w_30calpr.mdl", 150)
		ScavData.RegisterFiremode(tab, "models/weapons/w_30calsr.mdl", 150)
		
--[[==============================================================================================
	--BAR
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.bar"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 60
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < WALK_SPEED then
							if self.Owner:Crouching() and self.Owner:GetVelocity():LengthSqr() < PRONE_SPEED then
								bullet.Spread = Vector(0.02, 0.02, 0)
							else
								bullet.Spread = Vector(0.025, 0.025, 0)
							end
						else
							bullet.Spread = Vector(0.125, 0.125, 0)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 50
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:ScavViewPunch(Angle(-0.7, math.Rand(-0.4, 0.4), 0), 0.2, true)
						dodviewpunch(self)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_Bar.Shoot")
					self:EjectShellDoDS()
					if SERVER then
						self:SetPanelPoseInstant(0.125, 2)
						self:TakeSubammo(item, 1)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.12
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				if SERVER then
					self:SetBarrelRestSpeed(500)	
				end								
				return false
			end
			tab.Cooldown = 0.12
		ScavData.RegisterFiremode(tab, "models/weapons/w_bar.mdl", 20)

--[[==============================================================================================
	--C96
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.c96"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 60
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.065, 0.065, 0) or Vector(0.165, 0.165, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 40
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.7, math.Rand(-0.4, 0.4), 0), 0.2, true)
					dodviewpunch(self)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_C96.Shoot")
					self:EjectShellDoDS("small")
					if SERVER then
						self:TakeSubammo(item, 1)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.065
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				if SERVER then
					self:SetBarrelRestSpeed(250)	
				end								
				return false
			end
			tab.Cooldown = 0.065
		ScavData.RegisterFiremode(tab, "models/weapons/w_c96.mdl", 20)

--[[==============================================================================================
	--Kar 98
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.kar98"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 15
			tab.FireFunc = function(self, item)
				local bullet = {}
					bullet.Num = 1
					bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.014, 0.014, 0) or Vector(0.164, 0.164, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 110
					bullet.TracerName = "ef_scav_tr_b"
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
				self.Owner:ScavViewPunch(Angle(-3, math.Rand(-0.2, 0.2), 0), 0.4, true)
				dodviewpunch(self)
				if SERVER or not game.SinglePlayer() then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Kar.Shoot")
				timer.Simple(.375, function()
					if SERVER then
						self.Owner:EmitSound("Weapon_K98.BoltBack1")
						timer.Simple(.2, function() self.Owner:EmitSound("Weapon_K98.BoltBack2") end)
						timer.Simple(.6, function() self.Owner:EmitSound("Weapon_K98.BoltForward2") end)
					end
					self:EjectShellDoDS()
				end)
				if SERVER then
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 1.6
		ScavData.RegisterFiremode(tab, "models/weapons/w_k98.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/weapons/w_k98s.mdl", 5)

--[[==============================================================================================
	--M1 Carbine
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.carbine"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 45
			tab.FireFunc = function(self, item)
				local bullet = {}
					bullet.Num = 1
					bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.019, 0.019, 0) or Vector(0.119, 0.119, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 40
					bullet.TracerName = "ef_scav_tr_b"
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
				self.Owner:ScavViewPunch(Angle(-3, math.Rand(-0.2, 0.2), 0), 0.4, true)
				dodviewpunch(self)
				if SERVER or not game.SinglePlayer() then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Carbine.Shoot")
				self.nextfireearly = CurTime()+0.1
				self:EjectShellDoDS("medium")
				if SERVER then
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab, "models/weapons/w_m1carb.mdl", 15)

--[[==============================================================================================
	--M1 Garand
==============================================================================================]]--
		
		util.PrecacheModel("models/scav/shells/garand_clip.mdl")
		local tab = {}
			tab.Name = "#scav.scavcan.garand"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 24
			tab.FireFunc = function(self, item)
				local bullet = {}
						bullet.Num = 1
						bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.014, 0.014, 0) or Vector(0.114, 0.114, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 80
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-3, math.Rand(-0.2, 0.2), 0), 0.4, true)
					dodviewpunch(self)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_Garand.Shoot")
					self.nextfireearly = CurTime()+0.37
					self:EjectShellDoDS()
					if (item.subammo <= 1 and SERVER) or (item.subammo <= 0 and CLIENT) then --garand ping
						timer.Simple(0.025, function()
							if not IsValid(self) or not IsValid(self.Owner) then return end

							self.Owner:EmitSound("Weapon_Garand.ClipDing")
							local attach = self:GetShellEjectAttachment()
							if not attach then return end

							local ping = SERVER and ents.Create("prop_physics") or ents.CreateClientProp("models/scav/shells/garand_clip.mdl")
							if not IsValid(ping) then return end

							ping:SetPos(attach.Pos)
							ping:SetAngles(attach.Ang)
							if SERVER then
								ping:SetModel("models/scav/shells/garand_clip.mdl")
								ping:PhysicsInit(SOLID_VPHYSICS)
							end
							ping:Spawn()
							if SERVER then
								ping:DrawShadow(false)
								ping.NoScav = true
							else
								ping:SetupBones()
							end
							local angShellAngles = self.Owner:EyeAngles()
							local vecShellVelocity = self.Owner:GetAbsVelocity()
							vecShellVelocity = vecShellVelocity + angShellAngles:Right() * math.Rand(50, 70);
							vecShellVelocity = vecShellVelocity + angShellAngles:Up() * math.Rand(200, 250);
							vecShellVelocity = vecShellVelocity + angShellAngles:Forward() * 25;
							local phys = ping:GetPhysicsObject()
							if IsValid(phys) then
								phys:SetVelocity(vecShellVelocity)
								phys:SetAngleVelocity(angShellAngles:Forward() * 1000)
							end
							timer.Simple(10, function() if IsValid(ping) then ping:Remove() end end)
						end)
					end
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.Cooldown = 0.74
		ScavData.RegisterFiremode(tab, "models/weapons/w_garand.mdl", 8)

--[[==============================================================================================
	--M1903 Springfield
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.springfield"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			tab.MaxAmmo = 15
			tab.FireFunc = function(self, item)
				local bullet = {}
					bullet.Num = 1
					bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.06, 0.06, 0) or Vector(0.16, 0.16, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 120
					bullet.TracerName = "ef_scav_tr_b"
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
				self.Owner:ScavViewPunch(Angle(-3, math.Rand(-0.2, 0.2), 0), 0.4, true)
				dodviewpunch(self)
				if SERVER or not game.SinglePlayer() then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Springfield.Shoot")
				timer.Simple(.5, function()
					if CLIENT then
						self.Owner:EmitSound("Weapon_K98.BoltBack1")
						timer.Simple(.2, function() self.Owner:EmitSound("Weapon_K98.BoltBack2") end)
						timer.Simple(.6, function() self.Owner:EmitSound("Weapon_K98.BoltForward2") end)
					end
					self:EjectShellDoDS()
				end)
				if SERVER then
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 1.85
		ScavData.RegisterFiremode(tab, "models/weapons/w_spring.mdl", 5)

--[[==============================================================================================
	--M1911
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m1911"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 21
			tab.FireFunc = function(self, item)
				local bullet = {}
						bullet.Num = 1
						bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.055, 0.055, 0) or Vector(0.155, 0.155, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 40
						bullet.TracerName = "ef_scav_tr_b"
				self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.2)
				dodviewpunch(self)
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self:GetAimVector()
				if SERVER or not game.SinglePlayer() then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Colt.Shoot")
				self.nextfireearly = CurTime()+0.1
				self:EjectShellDoDS("small")
				if SERVER then
					return self:TakeSubammo(item, 1)
				end
			end
			tab.OnArmed = function(self, item, olditemname)
				end
			if SERVER then
				ScavData.CollectFuncs["models/player/american_assault.mdl"] = function(self, ent) return {{"models/weapons/w_colt.mdl", 7, 0}} end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab, "models/weapons/w_colt.mdl", 7)

--[[==============================================================================================
	--MG42
==============================================================================================]]--
		
		if SERVER then
			util.AddNetworkString("scv_setheat")
		else
			
			net.Receive("scv_setheat", function()
				local self = net.ReadEntity()
				if not IsValid(self) then return end
				self.Heat = net.ReadInt(8)
				self.Overheated = net.ReadBool()
			end)
		end
		--PrecacheParticleSystem("grenadetrail")

		local tab = {}
			tab.Name = "#scav.scavcan.mg42"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_IDLE
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 500
			--tab.Particle = nil
			local function mgcooloff(self, item)
				if not IsValid(self) then return end
				if self.Heat and self.Heat > 0 then
					if SERVER then
						self.Heat = math.max(0, self.Heat - 1)
						net.Start("scv_setheat")
							net.WriteEntity(self)
							net.WriteInt(self.Heat or 0, 8)
							net.WriteBool(self.Overheated or false)
						net.Send(self.Owner)
					end
					timer.Create(tostring(self) .. "ScavMGCooloff", 0.05, 1, function() mgcooloff(self, item) end)
				else
					self.Overheated = nil
					self.Heat = nil
					--[[if CLIENT and IsValid(tab.Particle) then
						tab.Particle:StopEmission(true, false)
					end]]
				end
				--print(self.Heat .. " " .. tostring(self.Overheated))
				if SERVER then
					self:SetBlockPoseInstant((self.Heat or 0) / 100)
				end
			end
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					if SERVER then
						if self.Heat and self.Heat >= 100 then
							self.Heat = 100
							self.Overheated = true
						end
						net.Start("scv_setheat")
							net.WriteEntity(self)
							net.WriteInt(self.Heat or 0, 8)
							net.WriteBool(self.Overheated or false)
						net.Send(self.Owner)
					--else
						--if self.Overheated == true then
							--if IsValid(tbl.Particle) then
							--	tbl.Particle:Restart()
							--else
							--	tbl.Particle = CreateParticleSystem(self, "grenadetrail", PATTACH_POINT_FOLLOW, 0, 0)
							--end
						--end
					end
					if not self.Overheated then
						self.Heat = math.min(100, (self.Heat or 0) + 1)
						local bullet = {}
							bullet.Num = 1
							if self.Owner:GetVelocity():LengthSqr() < WALK_SPEED then
								if self.Owner:Crouching() and self.Owner:GetVelocity():LengthSqr() < PRONE_SPEED then
									bullet.Spread = Vector(0.1, 0.1, 0) --"true" spread for bipod is .025 in DoD, but this player has a lot more freedom of movement and can aim anywhere
									dodviewpunch(self, 0.01)
								else
									bullet.Spread = Vector(0.2, 0.2, 0)
									dodviewpunch(self)
								end
							else
								bullet.Spread = Vector(0.3, 0.3, 0)
								dodviewpunch(self)
							end
							bullet.Tracer = 1
							bullet.Force = 5
							bullet.Damage = 85
							bullet.TracerName = "ef_scav_tr_b"
							bullet.Src = self.Owner:GetShootPos()
							bullet.Dir = self:GetAimVector()
						--self.Owner:ScavViewPunch(Angle(-5, math.Rand(-0.2, 0.2), 0), 0.5, true) --TODO: DoD:S viewpunch
						self.Owner:ScavViewPunch(Angle(-0.7, math.Rand(-0.4, 0.4), 0), 0.2, true)
						if SERVER or not game.SinglePlayer() then
							self.Owner:FireBullets(bullet)
						end
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self:EjectShellDoDS()
						if SERVER then
							self.Owner:EmitSound("Weapon_Mg42.Shoot")
							self:SetPanelPoseInstant(0.25, 2)
							self:TakeSubammo(item, 1)
						end
					end
					if SERVER then
						self:SetBlockPoseInstant((self.Heat or 0) / 100)
					--elseif not IsValid(tab.Particle) then
					--	tab.Particle = CreateParticleSystem(self, "grenadetrail", PATTACH_POINT_FOLLOW, 0, 0)
					--end
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if not timer.Exists(tostring(self) .. "ScavMGCooloff") then
						timer.Create(tostring(self) .. "ScavMGCooloff", 0.25, 1, function() mgcooloff(self, item) end)
					end
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
					return 0.25
				end
				if not self.Overheated then timer.Remove(tostring(self) .. "ScavMGCooloff") end
				return 0.05
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				if SERVER then
					self:SetBarrelRestSpeed(1000)
				end
				return false
			end
			if CLIENT then
				--Add cooldown bar to the existing status screen
				tab.ScreenAdd = function(self, item)
					if not self.Heat or self.Heat <= 0 then return end

					local _, use = math.modf(CurTime())
					local col = color_black
					if self.Overheated and use > 0.5 then col = color_white end

					surface.SetDrawColor(col)
					surface.DrawOutlinedRect(75, 78, 106, 14, 2)
					surface.DrawRect(78, 81, self.Heat or 0, 8)

					local _, flashtime = math.modf(CurTime())
					if self.Overheated or (self.Heat > 65 and flashtime > 0.5) then
						draw.DrawText("!", "ScavScreenFontSmX", 184, 72, col, TEXT_ALIGN_LEFT)
					end
				end
				--let's be silly
				tab.ScreenFiring = function(self, item)
					DrawScreenBKG(self.Overheated and redscr or greenscr)
					local _, use = math.modf(CurTime())
					local textcol = color_black
					if self.Overheated and use > 0.5 then textcol = color_white end
					--note: we specifically *want* these in German, so no localization tokens here
					--(gives a little flavor, and ensures the heat meter isn't getting drawn over)
					draw.DrawText("STATUS:", "ScavScreenFont", 128, 12, textcol, TEXT_ALIGN_CENTER)
					use = math.floor(use * 4) % 4
					local dots = " "
					for i = 1, 3 do
						dots = dots .. (use >= i and ". " or "  ")
					end
					draw.DrawText(self.Overheated and "ÜBERHITZTE" or ("FEUEREN" .. dots), "ScavScreenFontSm", 128, 40, textcol, TEXT_ALIGN_CENTER)
				end
				tab.Screen = function(self, item)
					if self:ScreenCooldown() then return self:DrawCooldown() end --tab.ScreenCooldown(self, item) end
					if self.ChargeAttack then return tab.ScreenFiring(self, item) end

					DrawScreenBKG(self.Overheated and redscr or greenscr)
					local _, use = math.modf(CurTime())
					local textcol = color_black
					if self.Overheated and use > 0.5 then textcol = color_white end
					draw.DrawText("STATUS:" .. (self.Overheated and "" or " OK"), "ScavScreenFont", 128, self.Overheated and 12 or 32, textcol, TEXT_ALIGN_CENTER)
					if not self.Overheated then return end
					draw.DrawText("ÜBERHITZTE", "ScavScreenFontSm", 128, 40, textcol, TEXT_ALIGN_CENTER)
				end
			end
			tab.Cooldown = 0.05
		ScavData.RegisterFiremode(tab, "models/weapons/w_mg42bd.mdl", 250)
		ScavData.RegisterFiremode(tab, "models/weapons/w_mg42bu.mdl", 250)
		ScavData.RegisterFiremode(tab, "models/weapons/w_mg42pr.mdl", 250)
		ScavData.RegisterFiremode(tab, "models/weapons/w_mg42sr.mdl", 250)
		
--[[==============================================================================================
	--MP40
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.mp40"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 96
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.055, 0.055, 0) or Vector(0.155, 0.155, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 40
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					dodviewpunch(self)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_MP40.Shoot")
					self:EjectShellDoDS("small")
					if SERVER then
						self:TakeSubammo(item, 1)
					end
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
				if SERVER then
					self:SetBarrelRestSpeed(250)	
				end								
				return false
			end
			tab.Cooldown = 0.09
		ScavData.RegisterFiremode(tab, "models/weapons/w_mp40.mdl", 32)

--[[==============================================================================================
	--MP44
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.mp44"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 90
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.025, 0.025, 0) or Vector(0.125, 0.125, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 50
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					dodviewpunch(self)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_MP44.Shoot")
					self:EjectShellDoDS("medium")
					if SERVER then
						self:TakeSubammo(item, 1)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.12
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				if SERVER then
					self:SetBarrelRestSpeed(250)	
				end								
				return false
			end
			tab.Cooldown = 0.12
		ScavData.RegisterFiremode(tab, "models/weapons/w_mp44.mdl", 30)

--[[==============================================================================================
	--P38
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.p38"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			tab.MaxAmmo = 24
			tab.FireFunc = function(self, item)
				local bullet = {}
					bullet.Num = 1
					bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.055, 0.055, 0) or Vector(0.155, 0.155, 0)
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 40
					bullet.TracerName = "ef_scav_tr_b"
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
				self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.2)
				dodviewpunch(self)
				if SERVER or not game.SinglePlayer() then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Luger.Shoot")
				self.nextfireearly = CurTime()+0.1
				self:EjectShellDoDS("small")
				if SERVER then
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab, "models/weapons/w_p38.mdl", 8)

--[[==============================================================================================
	--Tommy Gun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.tommy"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.MaxAmmo = 90
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						bullet.Spread = self.Owner:GetVelocity():LengthSqr() < WALK_SPEED and Vector(0.055, 0.055, 0) or Vector(0.155, 0.155, 0)
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 40
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.5, math.Rand(-0.2, 0.2), 0), 0.1, true)
					dodviewpunch(self)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_Thompson.Shoot")
					self:EjectShellDoDS("small")
					if SERVER then
						self:TakeSubammo(item, 1)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.085
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(tab.ChargeAttack, item)
				if SERVER then
					self:SetBarrelRestSpeed(500)	
				end								
				return false
			end
			tab.Cooldown = 0.085
		ScavData.RegisterFiremode(tab, "models/weapons/w_thompson.mdl", 30)
