--Firemodes largely related to the Day of Defeat series. Can have other games' props defined!

local eject = "brass"
util.PrecacheModel("models/scav/shells/shell_large.mdl")
util.PrecacheModel("models/scav/shells/shell_medium.mdl")
util.PrecacheModel("models/scav/shells/shell_small.mdl")

local dodsshelleject = function(self,shellsize)
	if not self.Owner:GetViewModel() then return end
	local size = shellsize or "large"
	local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
	if attach == nil then
		attach = self:GetAttachment(self:LookupAttachment(eject))
	end
	if attach then
		local brass = ents.CreateClientProp("models/scav/shells/shell_".. size ..".mdl")
		if IsValid(brass) then
			brass:SetPos(attach.Pos)
			brass:SetAngles(attach.Ang)
			brass:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			brass:AddCallback("PhysicsCollide",function(ent,data)
				if ( data.Speed > 50 ) then ent:EmitSound(Sound("Weapon.Shell")) end
			end)
			brass:Spawn()
			brass:DrawShadow(false)
			local angShellAngles = self.Owner:EyeAngles()
			--angShellAngles:RotateAroundAxis(Vector(0,0,1),90)
			local vecShellVelocity = self.Owner:GetAbsVelocity()
			vecShellVelocity = vecShellVelocity + angShellAngles:Right() * math.Rand( 50, 70 );
			vecShellVelocity = vecShellVelocity + angShellAngles:Up() * math.Rand( 100, 150 );
			vecShellVelocity = vecShellVelocity + angShellAngles:Forward() * 25;
			local phys = brass:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(vecShellVelocity)
				phys:SetAngleVelocity(angShellAngles:Forward()*1000)
			end
			timer.Simple(10,function() if IsValid(brass) then brass:Remove() end end)
		end
	end
end

--[[==============================================================================================
	--.30 cal
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.30cal"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < 20000 then
							if self.Owner:Crouching() and self.Owner:GetVelocity():LengthSqr() < 800 then --900 would be crouching with walk key held
								bullet.Spread = Vector(0.1,0.1,0) --"true" spread for bipod is .01 in DoD, but this player has a lot more freedom of movement
								if CLIENT then self.Owner:SetEyeAngles((vector_up*0.01+self:GetAimVector()):Angle()) end
							else
								bullet.Spread = Vector(0.2,0.2,0)
								if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
							end
						else
							bullet.Spread = Vector(0.3,0.3,0)
							if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 85
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.7,math.Rand(-0.4,0.4),0),0.2,true)
					if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_30cal.Shoot")
					if CLIENT then
						dodsshelleject(self)
					else
						--self:SetBlockPoseInstant(1,4)
						self:SetPanelPoseInstant(0.25,2)
						self:TakeSubammo(item,1)
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
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(tab.ChargeAttack,item)
				if SERVER then
					self:SetBarrelRestSpeed(1000)	
				end								
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_30cal.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),150,0) end
				ScavData.CollectFuncs["models/weapons/w_30calpr.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/weapons/w_30cal.mdl"),150,0) end
				ScavData.CollectFuncs["models/weapons/w_30calsr.mdl"] = ScavData.CollectFuncs["models/weapons/w_30calpr.mdl"]
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/weapons/w_30cal.mdl")
		
--[[==============================================================================================
	--BAR
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.bar"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < 20000 then
							if self.Owner:Crouching() and self.Owner:GetVelocity():LengthSqr() < 800 then --900 would be crouching with walk key held
								bullet.Spread = Vector(0.02,0.02,0)
							else
								bullet.Spread = Vector(0.025,0.025,0)
							end
						else
							bullet.Spread = Vector(0.125,0.125,0)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 50
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						self.Owner:ScavViewPunch(Angle(-0.7,math.Rand(-0.4,0.4),0),0.2,true)
						if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
					if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_Bar.Shoot")
					if CLIENT then
						dodsshelleject(self)
					else
						self:SetPanelPoseInstant(0.125,2)
						self:TakeSubammo(item,1)
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
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(tab.ChargeAttack,item)
				if SERVER then
					self:SetBarrelRestSpeed(500)	
				end								
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_bar.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/weapons/w_bar.mdl")

--[[==============================================================================================
	--C96
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.c96"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < 20000 then
							bullet.Spread = Vector(0.065,0.065,0)
						else
							bullet.Spread = Vector(0.165,0.165,0)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 40
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.7,math.Rand(-0.4,0.4),0),0.2,true)
					if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
					if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_C96.Shoot")
					if CLIENT then
						dodsshelleject(self,"small")
					else
						self:TakeSubammo(item,1)
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
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(tab.ChargeAttack,item)
				if SERVER then
					self:SetBarrelRestSpeed(250)	
				end								
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_c96.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,0) end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/weapons/w_c96.mdl")

--[[==============================================================================================
	--Kar 98
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.kar98"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			tab.FireFunc = function(self,item)
				local bullet = {}
					bullet.Num = 1
					if self.Owner:GetVelocity():LengthSqr() < 20000 then
						bullet.Spread = Vector(0.014,0.014,0)
					else
						bullet.Spread = Vector(0.164,0.164,0)
					end
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 110
					bullet.TracerName = "ef_scav_tr_b"
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
				self.Owner:ScavViewPunch(Angle(-3,math.Rand(-0.2,0.2),0),0.4,true)
				if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
				if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Kar.Shoot")
				if CLIENT then
					timer.Simple(.375,function()
						self.Owner:EmitSound("Weapon_K98.BoltBack1")
						timer.Simple(.2,function() self.Owner:EmitSound("Weapon_K98.BoltBack2") end)
						timer.Simple(.6,function() self.Owner:EmitSound("Weapon_K98.BoltForward2") end)
						dodsshelleject(self)
					end)
				else
					return self:TakeSubammo(item,1)
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_k98.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,0) end
				ScavData.CollectFuncs["models/weapons/w_k98s.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,0) end
			end
			tab.Cooldown = 1.6
		ScavData.RegisterFiremode(tab,"models/weapons/w_k98.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_k98s.mdl")

--[[==============================================================================================
	--M1 Carbine
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.carbine"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.FireFunc = function(self,item)
				local bullet = {}
					bullet.Num = 1
					if self.Owner:GetVelocity():LengthSqr() < 20000 then
						bullet.Spread = Vector(0.019,0.019,0)
					else
						bullet.Spread = Vector(0.119,0.119,0)
					end
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 40
					bullet.TracerName = "ef_scav_tr_b"
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
				self.Owner:ScavViewPunch(Angle(-3,math.Rand(-0.2,0.2),0),0.4,true)
				if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
				if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Carbine.Shoot")
				self.nextfireearly = CurTime()+0.1
				if CLIENT then
					dodsshelleject(self,"medium")
				else
					return self:TakeSubammo(item,1)
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_m1carb.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,0) end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab,"models/weapons/w_m1carb.mdl")

--[[==============================================================================================
	--M1 Garand
==============================================================================================]]--
		
		util.PrecacheModel("models/scav/shells/garand_clip.mdl")
		local tab = {}
			tab.Name = "#scav.scavcan.garand"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.FireFunc = function(self,item)
				local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < 20000 then
							bullet.Spread = Vector(0.014,0.014,0)
						else
							bullet.Spread = Vector(0.114,0.114,0)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 80
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-3,math.Rand(-0.2,0.2),0),0.4,true)
					if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
					if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_Garand.Shoot")
					self.nextfireearly = CurTime()+0.37
					if CLIENT then
						dodsshelleject(self)
					end
					if (item.subammo <= 1 and SERVER) or (item.subammo <= 0 and CLIENT) then --garand ping
						timer.Simple(0.025,function()
							self.Owner:EmitSound("Weapon_Garand.ClipDing")
							if CLIENT then
								local ping = ents.CreateClientProp("models/scav/shells/garand_clip.mdl")
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ping:SetPos(attach.Pos)
									ping:SetAngles(attach.Ang)
									ping:Spawn()
									local angShellAngles = self.Owner:EyeAngles()
									local vecShellVelocity = self.Owner:GetAbsVelocity()
									vecShellVelocity = vecShellVelocity + angShellAngles:Right() * math.Rand( 50, 70 );
									vecShellVelocity = vecShellVelocity + angShellAngles:Up() * math.Rand( 200, 250 );
									vecShellVelocity = vecShellVelocity + angShellAngles:Forward() * 25;
									local phys = ping:GetPhysicsObject()
									if IsValid(phys) then
										phys:SetVelocity(vecShellVelocity)
										phys:SetAngleVelocity(angShellAngles:Forward()*1000)
									end
									timer.Simple(10,function() if IsValid(ping) then ping:Remove() end end)
								end
							end
						end)
					end
					if SERVER then return self:TakeSubammo(item,1) end
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_garand.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,0) end
			end
			tab.Cooldown = 0.74
		ScavData.RegisterFiremode(tab,"models/weapons/w_garand.mdl")

--[[==============================================================================================
	--M1903 Springfield
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.springfield"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			tab.FireFunc = function(self,item)
				local bullet = {}
					bullet.Num = 1
					if self.Owner:GetVelocity():LengthSqr() < 20000 then
						bullet.Spread = Vector(0.06,0.06,0)
					else
						bullet.Spread = Vector(0.16,0.16,0)
					end
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 120
					bullet.TracerName = "ef_scav_tr_b"
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
				self.Owner:ScavViewPunch(Angle(-3,math.Rand(-0.2,0.2),0),0.4,true)
				if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
				if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Springfield.Shoot")
				if CLIENT then
					timer.Simple(.5,function()
						self.Owner:EmitSound("Weapon_K98.BoltBack1")
						timer.Simple(.2,function() self.Owner:EmitSound("Weapon_K98.BoltBack2") end)
						timer.Simple(.6,function() self.Owner:EmitSound("Weapon_K98.BoltForward2") end)
						dodsshelleject(self)
					end)
				else
					return self:TakeSubammo(item,1)
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_spring.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,0) end
			end
			tab.Cooldown = 1.85
		ScavData.RegisterFiremode(tab,"models/weapons/w_spring.mdl")

--[[==============================================================================================
	--M1911
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.m1911"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			tab.FireFunc = function(self,item)
				local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < 20000 then
							bullet.Spread = Vector(0.055,0.055,0)
						else
							bullet.Spread = Vector(0.155,0.155,0)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 40
						bullet.TracerName = "ef_scav_tr_b"
				self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.2)
				if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self:GetAimVector()
				if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Colt.Shoot")
				self.nextfireearly = CurTime()+0.1
				if CLIENT then
					dodsshelleject(self,"small")
				else
					return self:TakeSubammo(item,1)
				end
			end
			tab.OnArmed = function(self,item,olditemname)
				end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_colt.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),7,0) end
				ScavData.CollectFuncs["models/player/american_assault.mdl"] = function(self,ent) self:AddItem("models/weapons/w_colt.mdl",7,0) end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab,"models/weapons/w_colt.mdl")

--[[==============================================================================================
	--MG42
==============================================================================================]]--
		
		if SERVER then util.AddNetworkString("scv_setheat") end
		--PrecacheParticleSystem("grenadetrail")

		local tab = {}
			tab.Name = "#scav.scavcan.mg42"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_IDLE
			tab.Level = 2
			tab.Heat = 0
			tab.Overheated = false
			--tab.Particle = nil
			local heat = heat or tab.Heat
			local overheated = overheat or tab.Overheated
			local function mgcooloff(self,item)
				if IsValid(item) then
					--local tab = ScavData.models[item.ammo]
					if not (self:ProcessLinking(item) and self:StopChargeOnRelease()) then
						if heat > 0 then
							if SERVER then
								heat = math.max(0,heat - 1)
								net.Start("scv_setheat")
									net.WriteEntity(self)
									net.WriteInt(heat,8)
									net.WriteBool(overheated)
								net.Send(self.Owner)
							elseif IsFirstTimePredicted() then
								net.Receive("scv_setheat", function() 
									local self = net.ReadEntity()
									local c_heat = net.ReadInt(8)
									local c_overheated = net.ReadBool()
									if IsValid(self) then 
										heat = c_heat
										overheated = c_overheated
									end 
								end)
							end
							timer.Simple(0.05, function() mgcooloff(self,item) end)
						else
							overheated = false
							if CLIENT then--and IsValid(tab.Particle) then
								--tab.Particle:StopEmission(true,false)
								hook.Remove("ScavScreenDrawOverridePost","Cooldown")
							end
						end
						--print(heat .. " " .. tostring(overheated))
					end
					if SERVER then
						self:SetBlockPoseInstant(heat/100)
					end
				else
					heat = tab.heat
					overheated = tab.overheated
					if CLIENT then
						hook.Remove("ScavScreenDrawOverridePost","Cooldown")
					end
				end
			end
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local tab = ScavData.models[item.ammo]
					if SERVER then
						heat = math.min(100,heat + 1)
						if heat >= 100 then
							overheated = true
						end
						net.Start("scv_setheat")
							net.WriteEntity(self)
							net.WriteInt(heat,8)
							net.WriteBool(overheated)
						net.Send(self.Owner)
					else
						net.Receive("scv_setheat", function() 
							local self = net.ReadEntity()
							local c_heat = net.ReadInt(8)
							local c_overheated = net.ReadBool()
							if IsValid(self) then 
								heat = c_heat
								overheated = c_overheated
							end
						end)
						--if overheated == true then
							--if IsValid(tab.Particle) then
							--	tab.Particle:Restart()
							--else
							--	tab.Particle = CreateParticleSystem(self,"grenadetrail",PATTACH_POINT_FOLLOW,0,0)
							--end
						--end
					end
					if overheated == false then
						local bullet = {}
							bullet.Num = 1
							if self.Owner:GetVelocity():LengthSqr() < 20000 then
								if self.Owner:Crouching() and self.Owner:GetVelocity():LengthSqr() < 800 then --900 would be crouching with walk key held
									bullet.Spread = Vector(0.1,0.1,0) --"true" spread for bipod is .025 in DoD, but this player has a lot more freedom of movement and can aim anywhere
									if CLIENT then self.Owner:SetEyeAngles((vector_up*0.01+self:GetAimVector()):Angle()) end
								else
									bullet.Spread = Vector(0.2,0.2,0)
									if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
								end
							else
								bullet.Spread = Vector(0.3,0.3,0)
								if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
							end
							bullet.Tracer = 1
							bullet.Force = 5
							bullet.Damage = 85
							bullet.TracerName = "ef_scav_tr_b"
							bullet.Src = self.Owner:GetShootPos()
							bullet.Dir = self:GetAimVector()
						--self.Owner:ScavViewPunch(Angle(-5,math.Rand(-0.2,0.2),0),0.5,true) --TODO: DoD:S viewpunch
						self.Owner:ScavViewPunch(Angle(-0.7,math.Rand(-0.4,0.4),0),0.2,true)
						if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
							self.Owner:FireBullets(bullet)
						end
						self:MuzzleFlash2()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						if CLIENT then
							dodsshelleject(self)
							hook.Add("ScavScreenDrawOverridePost","Cooldown",function()
								surface.SetDrawColor(0,0,0)
								surface.DrawOutlinedRect(75,78,106,14,2)
								surface.DrawRect(78,81,heat,8)
							end)
						else
							self.Owner:EmitSound("Weapon_Mg42.Shoot")
							self:SetBlockPoseInstant(heat/100)
							self:SetPanelPoseInstant(0.25,2)
							self:TakeSubammo(item,1)
						end
					else
						if SERVER then
							self:SetBlockPoseInstant(heat/100)
						--else
						--	if not IsValid(tab.Particle) then
						--		tab.Particle = CreateParticleSystem(self,"grenadetrail",PATTACH_POINT_FOLLOW,0,0)
						--	end
						end
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					timer.Simple(0.25, function() mgcooloff(self,item) end)
					if SERVER then
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
				end
				return 0.05
			end
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(tab.ChargeAttack,item)
				if SERVER then
					self:SetBarrelRestSpeed(1000)	
				end								
				return false
			end
			tab.PostRemove = function(self,item)
				if CLIENT then
					hook.Remove("ScavScreenDrawOverridePost","Cooldown")
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_mg42bd.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),250,0) end
				ScavData.CollectFuncs["models/weapons/w_mg42bu.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),250,0) end
				ScavData.CollectFuncs["models/weapons/w_mg42pr.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/weapons/w_mg42bd.mdl"),250,0) end
				ScavData.CollectFuncs["models/weapons/w_mg42sr.mdl"] = ScavData.CollectFuncs["models/weapons/w_mg42pr.mdl"]
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/weapons/w_mg42bd.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_mg42bu.mdl")
		
--[[==============================================================================================
	--MP40
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.mp40"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < 20000 then
							bullet.Spread = Vector(0.055,0.055,0)
						else
							bullet.Spread = Vector(0.155,0.155,0)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 40
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
					if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
					if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_MP40.Shoot")
					if CLIENT then
						dodsshelleject(self,"small")
					else
						self:TakeSubammo(item,1)
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
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(tab.ChargeAttack,item)
				if SERVER then
					self:SetBarrelRestSpeed(250)	
				end								
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_mp40.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),32,0) end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/weapons/w_mp40.mdl")

--[[==============================================================================================
	--MP44
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.mp44"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < 20000 then
							bullet.Spread = Vector(0.025,0.025,0)
						else
							bullet.Spread = Vector(0.125,0.125,0)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 50
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
					if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
					if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_MP44.Shoot")
					if CLIENT then
						dodsshelleject(self,"medium")
					else
						self:TakeSubammo(item,1)
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
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(tab.ChargeAttack,item)
				if SERVER then
					self:SetBarrelRestSpeed(250)	
				end								
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_mp44.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/weapons/w_mp44.mdl")

--[[==============================================================================================
	--P38
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.p38"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			tab.FireFunc = function(self,item)
				local bullet = {}
					bullet.Num = 1
					if self.Owner:GetVelocity():LengthSqr() < 20000 then
						bullet.Spread = Vector(0.055,0.055,0)
					else
						bullet.Spread = Vector(0.155,0.155,0)
					end
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 40
					bullet.TracerName = "ef_scav_tr_b"
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
				self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.2)
				if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
				if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
					self.Owner:FireBullets(bullet)
				end
				self:MuzzleFlash2()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("Weapon_Luger.Shoot")
				self.nextfireearly = CurTime()+0.1
				if CLIENT then
					dodsshelleject(self,"small")
				else return self:TakeSubammo(item,1) end
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_p38.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,0) end
			end
			tab.Cooldown = 0.3
		ScavData.RegisterFiremode(tab,"models/weapons/w_p38.mdl")

--[[==============================================================================================
	--Tommy Gun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.tommy"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 2
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local bullet = {}
						bullet.Num = 1
						if self.Owner:GetVelocity():LengthSqr() < 20000 then
							bullet.Spread = Vector(0.055,0.055,0)
						else
							bullet.Spread = Vector(0.155,0.155,0)
						end
						bullet.Tracer = 1
						bullet.Force = 5
						bullet.Damage = 40
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
					self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2,0.2),0),0.1,true)
					if CLIENT then self.Owner:SetEyeAngles((vector_up*0.05+self:GetAimVector()):Angle()) end
					if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("Weapon_Thompson.Shoot")
					if CLIENT then
						dodsshelleject(self,"small")
					else
						self:TakeSubammo(item,1)
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
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(tab.ChargeAttack,item)
				if SERVER then
					self:SetBarrelRestSpeed(500)	
				end								
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/weapons/w_thompson.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab,"models/weapons/w_thompson.mdl")
