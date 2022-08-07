AddCSLuaFile("firemodes_hl2.lua")
AddCSLuaFile("firemodes_css.lua")
AddCSLuaFile("firemodes_dods.lua")

local refangle = Angle(0,0,0)
local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")
local SWEP = SWEP
local ScavData = ScavData

--damage fix
DMG_FREEZE = 16
DMG_CHEMICAL = 1048576

local eject = "brass"

util.PrecacheModel("models/scav/shells/shell_pistol_tf2.mdl")
util.PrecacheModel("models/scav/shells/shell_shotgun_tf2.mdl")
util.PrecacheModel("models/scav/shells/shell_sniperrifle_tf2.mdl")
util.PrecacheModel("models/scav/shells/shell_minigun_tf2.mdl")
tf2shelleject = function(self,shelltype)
	if not self.Owner:GetViewModel() then return end
	local shell = shelltype or "pistol"
	local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
	if attach == nil then
		attach = self:GetAttachment(self:LookupAttachment(eject))
	end
	if attach then
		local brass = ents.CreateClientProp("models/scav/shells/shell_" .. shell .."_tf2.mdl")
		if IsValid(brass) then
			brass:SetPos(attach.Pos)
			brass:SetAngles(attach.Ang)
			brass:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			brass:AddCallback("PhysicsCollide",function(ent,data)
				if ( data.Speed > 50 ) then
					if shell == "shotgun" then
						ent:EmitSound(Sound("Bounce.ShotgunShell"))
					else
						ent:EmitSound(Sound("Bounce.Shell"))
					end
				end
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
	--Scav Rockets
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.rocket"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.MaxAmmo = 24
			tab.Seeking = false
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
					--Look for seeking items
					for _,v in pairs(self.inv.items) do
						if ScavData.models[v.ammo] and ScavData.models[v.ammo].Name == "#scav.scavcan.computer" then
							tab.Seeking = ScavData.models[v.ammo].On
							break
						end
					end
					if tab.Seeking then
						tab.tracep.start = self.Owner:GetShootPos()
						tab.tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*20000
						tab.tracep.filter = self.Owner
						local tr = util.TraceHull(tab.tracep)
						--print(tr.Entity)
						if IsValid(tr.Entity) then
							proj.target = tr.Entity
						end
					end
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if item.ammo == "models/weapons/w_models/w_rocket.mdl" or item.ammo == "models/props_halloween/eyeball_projectile.mdl" then --TF2
						if self.Owner:GetStatusEffect("DamageX") then
							self.Owner:EmitSound("weapons/rocket_shoot_crit.wav",75,100) --crit sound
						else
							self.Owner:EmitSound("weapons/rocket_shoot.wav",75,100)
						end
					elseif item.ammo == "models/buildables/sentry3_rockets.mdl" then --TF2 sentry
						self.Owner:EmitSound("weapons/sentry_rocket.wav",75,100)
					elseif item.ammo == "models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl" then --TF2 Air Strike
						if self.Owner:GetStatusEffect("DamageX") then
							self.Owner:EmitSound("weapons/airstrike_fire_crit.wav",75,100) --crit sound
						else
							self.Owner:EmitSound("weapons/airstrike_fire_01.wav",75,100)
						end
					elseif item.ammo == "models/weapons/w_bazooka_rocket.mdl" or item.ammo == "models/weapons/w_panzerschreck_rocket.mdl" then --DoD:S
						self.Owner:EmitSound("^weapons/rocket1.wav",75,100)
					else --HL2/default
						self.Owner:EmitSound("weapons/stinger_fire1.wav",75,100)
					end
					proj:GetPhysicsObject():Wake()
					proj:GetPhysicsObject():EnableDrag(false)
					proj:GetPhysicsObject():EnableGravity(false)
					proj.SpeedScale = self:GetForceScale()
					proj:GetPhysicsObject():SetVelocityInstantaneous((self:GetAimVector())*2000*self:GetForceScale())
					proj:GetPhysicsObject():SetBuoyancyRatio(0)
					--self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("fire3"))
					--gamemode.Call("ScavFired",self.Owner,proj)
					self:AddBarrelSpin(575)
					self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
					return self:TakeSubammo(item,1)
				end
				ScavData.CollectFuncs["models/weapons/w_rocket_launcher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_missile.mdl",3,0,1) end --3 rockets from HL2 launcher - add seeking?
				ScavData.CollectFuncs["models/items/ammocrate_rockets.mdl"] = function(self,ent) self:AddItem("models/weapons/w_missile.mdl",3,0,1) end --3 rockets from HL2 rocket crate
				ScavData.CollectFuncs["models/weapons/w_missile_launch.mdl"] = function(self,ent) self:AddItem("models/weapons/w_missile.mdl",1,0,1) end --converts the rocket into a usable one
				ScavData.CollectFuncs["models/weapons/w_missile_closed.mdl"] = ScavData.CollectFuncs["models/weapons/w_missile_launch.mdl"]
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_rocket.mdl",4,0,1) end --4 rockets from TF2 launcher
				ScavData.CollectFuncs["models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_directhit/c_directhit.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl",4,0,1) end
				ScavData.CollectFuncs["models/weapons/c_models/c_rocketjumper/c_rocketjumper.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"] --TODO: No damage?
				ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_rocket.mdl",3,0,1) end --3 rockets from Black Box
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_blackbox/c_blackbox.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_blackbox/c_blackbox_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_rocket.mdl",5,0,1) end --5 rockets from Libery Launcher
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl"]
				ScavData.CollectFuncs["models/buildables/sentry3.mdl"] = function(self,ent) self:AddItem("models/buildables/sentry3_rockets.mdl",1,0,1) end --1 rocket from TF2 sentry (level 3)
				ScavData.CollectFuncs["models/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/pickups/pickup_powerup_supernova.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				--Portal
				ScavData.CollectFuncs["models/props_bts/rocket_sentry.mdl"] = function(self,ent) self:AddItem("models/props_bts/rocket.mdl",5,0,1) end --5 rockets from Portal rocket sentry
				--DoD:S
				ScavData.CollectFuncs["models/weapons/w_bazooka.mdl"] = function(self,ent) self:AddItem("models/weapons/w_bazooka_rocket.mdl",1,0,1) end --1 rocket from Bazooka
				ScavData.CollectFuncs["models/weapons/w_pschreck.mdl"] = function(self,ent) self:AddItem("models/weapons/w_panzerschreck_rocket.mdl",1,0,1) end --1 rocket from Panzer
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/weapons/w_missile.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_missile_closed.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_rocket.mdl")
		ScavData.RegisterFiremode(tab,"models/buildables/sentry3_rockets.mdl")
		ScavData.RegisterFiremode(tab,"models/props_halloween/eyeball_projectile.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl")
		--ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl") --TODO: infinite rockets from Cowmanger (on its own entity, probably)
		--Portal
		ScavData.RegisterFiremode(tab,"models/props_bts/rocket.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/weapons/w_bazooka_rocket.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_panzerschreck_rocket.mdl")
		

--[[==============================================================================================
	--Auto-Targeting System
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.computer"
			tab.anim = ACT_VM_IDLE
			tab.Level = 5
			tab.On = true
			tab.FireFunc = function(self,item)
				tab.On = not tab.On
				if SERVER then
					if tab.On then
						self.Owner:EmitSound("buttons/button5.wav",75)
						--self:Lock(CurTime(),CurTime()+5) --testing
					else
						self.Owner:EmitSound("buttons/button8.wav",75)
					end
				end
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_lab/harddrive01.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/harddrive02.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/reciever01a.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/reciever01b.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/reciever01c.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/reciever01d.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/reciever_cart.mdl"] = ScavData.GiveOneOfItemInf
				--CSS
				ScavData.CollectFuncs["models/props/cs_office/computer_case.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/computer_caseb.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/computer_caseb_p2.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/computer_caseb_p2a.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/computer_caseb_p3.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/computer_caseb_p3a.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/computer_caseb_p4.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/computer_caseb_p5.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/computer_caseb_p6.mdl"] = ScavData.GiveOneOfItemInf
				--TF2
				ScavData.CollectFuncs["models/props_spytech/control_room_console02.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_spytech/control_room_console04.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_spytech/computer_wall.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_spytech/computer_wall02.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_spytech/computer_wall03.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_spytech/computer_wall04.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_spytech/computer_wall05.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_spytech/computer_wall06.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_powerhouse/powerhouse_console01.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_powerhouse/powerhouse_console02.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_moonbase/moon_interior_computer01.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_moonbase/moon_interior_computer02.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_moonbase/moon_interior_computer03.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_moonbase/moon_interior_computer04.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_moonbase/moon_interior_computer05.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_moonbase/moon_interior_computer06.mdl"] = ScavData.GiveOneOfItemInf
				--Portal
				ScavData.CollectFuncs["models/props/pc_case02/pc_case02.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/pc_case_open/pc_case_open.mdl"] = ScavData.GiveOneOfItemInf
				--DoD:S
				ScavData.CollectFuncs["models/props_misc/german_radio.mdl"] = ScavData.GiveOneOfItemInf
			end
			tab.Cooldown = .25
		ScavData.RegisterFiremode(tab,"models/props_lab/harddrive01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/harddrive02.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/reciever01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/reciever01b.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/reciever01c.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/reciever01d.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/reciever_cart.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_case.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_caseb.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_caseb_p2.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_caseb_p2a.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_caseb_p3.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_caseb_p3a.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_caseb_p4.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_caseb_p5.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/computer_caseb_p6.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/props_spytech/control_room_console02.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/control_room_console04.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/computer_wall.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/computer_wall02.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/computer_wall03.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/computer_wall04.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/computer_wall05.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/computer_wall06.mdl")
		ScavData.RegisterFiremode(tab,"models/props_powerhouse/powerhouse_console01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_powerhouse/powerhouse_console02.mdl")
		ScavData.RegisterFiremode(tab,"models/props_moonbase/moon_interior_computer01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_moonbase/moon_interior_computer02.mdl")
		ScavData.RegisterFiremode(tab,"models/props_moonbase/moon_interior_computer03.mdl")
		ScavData.RegisterFiremode(tab,"models/props_moonbase/moon_interior_computer04.mdl")
		ScavData.RegisterFiremode(tab,"models/props_moonbase/moon_interior_computer05.mdl")
		ScavData.RegisterFiremode(tab,"models/props_moonbase/moon_interior_computer06.mdl")
		--Portal
		ScavData.RegisterFiremode(tab,"models/props/pc_case02/pc_case02.mdl")
		ScavData.RegisterFiremode(tab,"models/props/pc_case_open/pc_case_open.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/props_misc/german_radio.mdl")
		

--[[==============================================================================================
	--Ice Beam
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.icebeam"
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
					proj.SpeedScale = self:GetForceScale()
					proj:GetPhysicsObject():SetVelocity((self:GetAimVector())*2000*self:GetForceScale())
					proj:GetPhysicsObject():SetBuoyancyRatio(0)
					self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
					return false
				end
				ScavData.CollectFuncs["models/maxofs2d/hover_classic.mdl"] = ScavData.GiveOneOfItemInf
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl"] = function(self,ent)
						if self.christmas then
							self:AddItem("models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder_festivizer.mdl",SCAV_SHORT_MAX,ent:GetSkin(),1)
						else
							self:AddItem("models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl",SCAV_SHORT_MAX,ent:GetSkin(),1)
						end
					end
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl"] = function(self,ent)
						if self.christmas then
							self:AddItem("models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder_festivizer.mdl",SCAV_SHORT_MAX,ent:GetSkin(),1)
						else
							self:AddItem("models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl",SCAV_SHORT_MAX,ent:GetSkin(),1)
						end
					end
				--CSS
				ScavData.CollectFuncs["models/props/cs_office/snowman_body.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/snowman_face.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props/cs_office/snowman_head.mdl"] = ScavData.GiveOneOfItemInf
				--L4D2
				ScavData.CollectFuncs["models/props_urban/ice_machine001.mdl"] = ScavData.GiveOneOfItemInf
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/maxofs2d/hover_classic.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder_festivizer.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_office/snowman_body.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/snowman_face.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/snowman_head.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/props_urban/ice_machine001.mdl")
	
--[[==============================================================================================
	--Flares
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.flare"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			tab.MaxAmmo = 16
			if SERVER then
				tab.FireFunc = function(self,item)
						--local proj = self:CreateEnt("scav_projectile_flare")
						local proj = self:CreateEnt("scav_projectile_flare2")
						proj.Owner = self.Owner
						proj:SetModel(item.ammo)
						proj:SetPos(self.Owner:GetShootPos()-self:GetAimVector()*15+self:GetAimVector():Angle():Right()*2-self:GetAimVector():Angle():Up()*2)
						proj:SetAngles(self:GetAimVector():Angle())
						proj:SetOwner(self.Owner)
						--proj:SetSkin(item.data)
						proj:SetSkin(item.data)
						proj:Spawn()
						--"weapons/flaregun/burn"
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(false)
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*4000)
						proj:GetPhysicsObject():SetBuoyancyRatio(0)
						proj:SetPhysicsAttacker(self.Owner)
						self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
						return self:TakeSubammo(item,1)
					end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_flaregun_shell.mdl",5,ent:GetSkin()) end --5 flares from the TF2 flaregun
				ScavData.CollectFuncs["models/weapons/c_models/c_scorch_shot/c_scorch_shot.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_scorch_shot/c_scorch_shot.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_scorch_shot/c_scorch_shot.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_xms_flaregun/c_xms_flaregun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_detonator/c_detonator.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_detonator/c_detonator.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_detonator/c_detonator.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_drg_manmelter/c_drg_manmelter.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"] --TODO: infinite slower flares from manmelter
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_drg_manmelter/c_drg_manmelter.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_drg_manmelter/c_drg_manmelter.mdl"]
				--L4D2
				ScavData.CollectFuncs["models/props_fairgrounds/pyrotechnics_launcher.mdl"]	= function(self,ent) self:AddItem("models/items/flare.mdl",3,ent:GetSkin()) end --3 flares from the L4D2 Pyrotechnics
				ScavData.CollectFuncs["models/props_fairgrounds/mortar_rack.mdl"] = function(self,ent) self:AddItem("models/items/flare.mdl",7,ent:GetSkin()) end --7 flares from the L4D2 Pyrotechnics Mortar
				---ASW
				ScavData.CollectFuncs["models/swarm/flare/flarebox.mdl"] = function(self,ent) self:AddItem("models/swarm/flare/flareweapon.mdl",5,ent:GetSkin()) end --5 flares from the TF2 flaregun
			else
				tab.fov = 10
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/items/flare.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_flaregun_shell.mdl")
		--Ep1
		ScavData.RegisterFiremode(tab,"models/props_junk/flare.mdl")
		--ASW
		ScavData.RegisterFiremode(tab,"models/swarm/flare/flareweapon.mdl")
		ScavData.RegisterFiremode(tab,"models/swarmprops/miscdeco/greenflare.mdl")
		
--[[==============================================================================================
	--Arrows and Bolts (Impaler)
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.impaler"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 8
			tab.MaxAmmo = 6
			if SERVER then
				tab.FireFunc = function(self,item)
					local proj = self:CreateEnt("scav_projectile_impaler")
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
					

					elseif item.ammo == "models/props_c17/trappropeller_blade.mdl" then
						proj.Trail = util.SpriteTrail(proj,0,Color(255,255,255,255),true,2,0,0.3,0.25,"trails/smoke.vmt")
						proj.DmgAmt = 100
						proj.NoPin = true
						proj.Drop = vector_origin
						proj:SetAngles(self.Owner:EyeAngles())
						self.Owner:EmitSound("ambient/machines/catapult_throw.wav")
					

					elseif item.ammo == "models/props_junk/harpoon002a.mdl" then
						self.Owner:EmitSound("ambient/machines/catapult_throw.wav")
						proj.DmgAmt = 100
					end

					self.Owner:EmitSound(self.shootsound)
					self.Owner:ViewPunch(Angle(math.Rand(-1,0),math.Rand(-0.1,0.1),0))
					return self:TakeSubammo(item,1)
				end
				--[[
				PLAYER.GetRagdollEntityOld = PLAYER.GetRagdollEntity
				ENTITY.ArrowRagdoll = NULL
				function PLAYER:GetRagdollEntity()
					if IsValid(self.ArrowRagdoll) then
						return self.ArrowRagdoll
					else
						return self:GetRagdollEntityOld()
					end
				end
				hook.Add("PlayerSpawn","ResetArrowRagdoll",function(pl) pl.ArrowRagdoll = NULL end)
				hook.Add("PlayerDeath","NoArrowRagdoll",function(pl) if IsValid(pl.ArrowRagdoll) and pl:GetRagdollEntityOld() then pl:GetRagdollEntityOld():Remove() end end)
				hook.Add("CreateEntityRagdoll","NoArrowRagdoll2",function(ent,rag) if IsValid(ent.ArrowRagdoll) then rag:Remove() end end)
				--]]

				ScavData.CollectFuncs["models/items/crossbowrounds.mdl"] = function(self,ent) self:AddItem("models/crossbow_bolt.mdl",6,ent:GetSkin(),1) end --6 crossbow bolts from a bundle of bolts
				ScavData.CollectFuncs["models/weapons/w_crossbow.mdl"] = function(self,ent) self:AddItem("models/crossbow_bolt.mdl",1,ent:GetSkin(),1) end --1 bolt from the crossbow
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_arrow.mdl"] = function(self,ent) --Christmas check
					if self.christmas then
						self:AddItem("models/weapons/w_models/w_arrow_xmas.mdl",1,0,1)
					else
						self:AddItem("models/weapons/w_models/w_arrow.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/weapons/c_models/c_claymore/c_claymore.mdl"] = function(self,ent) --Christmas check
					if self.christmas then
						self:AddItem("models/weapons/c_models/c_claymore/c_claymore_xmas.mdl",1,math.fmod(ent:GetSkin(),2),1)
					else
						self:AddItem("models/weapons/c_models/c_claymore/c_claymore.mdl",1,ent:GetSkin(),1)
					end
				end
				ScavData.CollectFuncs["models/weapons/c_models/c_dartgun.mdl"] = function(self,ent) self:AddItem("models/weapons/c_models/c_dart.mdl",5,ent:GetSkin(),1) end --5 darts from Sydney Sleeper
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_sydney_sleeper/c_sydney_sleeper.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_dartgun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow.mdl"] = function(self,ent) --3 arrows from Huntsman
						if self.christmas then
							self:AddItem("models/weapons/w_models/w_arrow_xmas.mdl",3,0,1)
						else
							self:AddItem("models/weapons/w_models/w_arrow.mdl",3,0,1)
						end
					end
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_bow_thief/c_bow_thief.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl"] = function(self,ent) --1 arrow from Crusader's Crossbow TODO: syringe
					if self.christmas then
						self:AddItem("models/weapons/w_models/w_arrow_xmas.mdl",1,0,1)
					else
						self:AddItem("models/weapons/w_models/w_arrow.mdl",1,0,1)
					end
				end
				function tab.OnArmed(self,item,olditemname)
					if SERVER then
						if item.ammo == "models/crossbow_bolt.mdl" then
							self.Owner:EmitSound("weapons/crossbow/reload1.wav")
						end
					end
				end
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow_xmas.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_arrow_xmas.mdl",3,ent:GetSkin(),1) end --3 festive arrows from festive Huntsman
				ScavData.CollectFuncs["models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow_xmas.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_arrow_xmas.mdl",1,ent:GetSkin(),1) end --1 arrows from Crusader's Crossbow TODO: candy cane
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow_xmas.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_tele_shotgun/c_tele_shotgun.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_repair_claw.mdl",4,ent:GetSkin(),1) end --4 claws from Rescue Ranger
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_tele_shotgun/c_tele_shotgun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_tele_shotgun/c_tele_shotgun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow_thief.mdl"] = ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_bow_thief/c_bow_thief.mdl"]
				ScavData.CollectFuncs["models/pickups/pickup_powerup_precision.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow.mdl"]
				--FoF
				ScavData.CollectFuncs["models/weapons/w_bow.mdl"] = function(self,ent) self:AddItem("models/weapons/bowarrow_bolt.mdl",1,0,1) end --1 arrow from bows
				ScavData.CollectFuncs["models/weapons/w_bow_black.mdl"] = ScavData.CollectFuncs["models/weapons/w_bow.mdl"]
				ScavData.CollectFuncs["models/weapons/w_xbow.mdl"] = ScavData.CollectFuncs["models/weapons/w_bow.mdl"]
				ScavData.CollectFuncs["models/weapons/w_axe_proj.mdl"] = function(self,ent) self:AddItem("models/weapons/w_axe.mdl",1,0,1) end --1 unscuffed axe model
			else
				tab.fov = 10
			end
			tab.Cooldown = 1
			
			

		ScavData.RegisterFiremode(tab,"models/crossbow_bolt.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/harpoon002a.mdl")
		ScavData.RegisterFiremode(tab,"models/mixerman3d/other/arrow.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/trappropeller_blade.mdl")
		--Ep2
		ScavData.RegisterFiremode(tab,"models/props_mining/railroad_spike01.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/weapons/w_knife_ct.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_knife_t.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_knife_t.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_knife/c_knife.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_arrow.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_arrow_xmas.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_claymore/c_claymore.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_claymore/c_claymore_xmas.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_scout_sword/c_scout_sword.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_scout_sword/c_scout_sword.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_demo_sultan_sword/c_demo_sultan_sword.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_demo_sultan_sword/c_demo_sultan_sword.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_machete/c_machete.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_croc_knife/c_croc_knife.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_scimitar/c_scimitar.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_scimitar/c_scimitar.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_wood_machete/c_wood_machete.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_wood_machete/c_wood_machete.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_prinny_knife/c_prinny_knife.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl") --TODO: needs to be flipped around
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl") --TODO: needs to be flipped around
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_dart.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_sydney_sleeper/c_sydney_sleeper_dart.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_repair_claw.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_knife.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_ava_roseknife/c_ava_roseknife_v.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_switchblade/c_switchblade.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_switchblade/c_switchblade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/weapons/melee/w_machete.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/melee/w_katana.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/melee/w_pitchfork.mdl")
		--Lost Coast
		ScavData.RegisterFiremode(tab,"models/lostcoast/fisherman/harpoon.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/weapons/bowarrow_bolt.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_axe.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_knife.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_machete.mdl")
		
--[[==============================================================================================
	--Scav Grenade
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.nadelauncher"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.MaxAmmo = 20
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
					--gamemode.Call("ScavFired",self.Owner,proj)
					return self:TakeSubammo(item,1)
				end
				ScavData.CollectFuncs["models/props_interiors/vendingmachinesoda01a.mdl"] = function(self,ent) --nine grenades + door from vending machine
					self:AddItem("models/props_junk/popcan01a.mdl",9,math.random(0,2),0)
					self:AddItem("models/props_interiors/VendingMachineSoda01a_door.mdl",1,0)
				end
				--CSS
				ScavData.CollectFuncs["models/props/cs_office/vending_machine.mdl"] = function(self,ent) self:AddItem("models/props/cs_office/water_bottle.mdl",9,0,1) end --nine grenades from vending machine
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_grenadelauncher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_grenade_grenadelauncher.mdl",4,math.fmod(ent:GetSkin(),2),1) end --4 grenades from TF2 grenade launcher
				ScavData.CollectFuncs["models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_grenadelauncher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_grenadelauncher/c_grenadelauncher_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_grenadelauncher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_lochnload/c_lochnload.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_grenade_grenadelauncher.mdl",2,math.fmod(ent:GetSkin(),2),1) end --2 grenades from TF2 Loch N Load
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_lochnload/c_lochnload.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_lochnload/c_lochnload.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_quadball/c_quadball.mdl"] = function(self,ent) self:AddItem("models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl",4,math.fmod(ent:GetSkin(),2),1) end --4 round grenades from Iron Bomber
				--FoF
				ScavData.CollectFuncs["models/weapons/w_dynamite.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),2,0,1) end --2 dynamite from red
				ScavData.CollectFuncs["models/weapons/w_dynamite_black.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),4,0,1) end --4 dynamite from black
				ScavData.CollectFuncs["models/weapons/w_dynamite_yellow.mdl"] = ScavData.GiveOneOfItemInf --inf dynamite from yellow
			end
			tab.Cooldown = 0.75
		
		ScavData.RegisterFiremode(tab,"models/props_junk/popcan01a.mdl")	
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_grenade_grenadelauncher.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_caber/c_caber.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_caber/c_caber.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/weapons/w_eq_fraggrenade.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_eq_fraggrenade_thrown.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/water_bottle.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/weapons/w_dynamite.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_dynamite_black.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_dynamite_yellow.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_sodacan01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_sodacan01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_sodacan01a_crushed.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_sodacan01a_crushed_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_beercan01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_beercan01a_crushed.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_beercan01a_fullsheet.mdl")
		

--[[==============================================================================================
	--Payload Gun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.payload"
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
					--proj:SetAngles((self:GetAimVector():Angle():Up()*-1):Angle())
					proj:Spawn()
					proj:SetSkin(item.data)
					proj:GetPhysicsObject():Wake()
					proj:GetPhysicsObject():EnableDrag(true)
					proj:GetPhysicsObject():SetDragCoefficient(-10000)
					proj:GetPhysicsObject():EnableGravity(true)
					proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*2500)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound(self.shootsound)
					--gamemode.Call("ScavFired",self.Owner,proj)
					return true
				end
				ScavData.CollectFuncs["models/props_trainyard/bomb_cart.mdl"] = function(self,ent) self:AddItem("models/props_trainyard/cart_bomb_separate.mdl",1,0,1) end
				ScavData.CollectFuncs["models/props_trainyard/bomb_cart_red.mdl"] = ScavData.CollectFuncs["models/props_trainyard/bomb_cart.mdl"]
			end
			tab.Cooldown = 5
		ScavData.RegisterFiremode(tab,"models/props_phx/misc/flakshell_big.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/mk-82.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/torpedo.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/ww2bomb.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/amraam.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/props_trainyard/cart_bomb_separate.mdl")

		
--[[==============================================================================================
	--Proximity Mine
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.proxmine"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.MaxAmmo = 6
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
						if item.ammo == "models/weapons/w_models/w_stickybomb2.mdl" or item.ammo == "models/props_c17/doll01.mdl" or item.ammo == "models/props_unique/doll01.mdl" then
							proj:SetSticky(false)
						end
						proj:SetSkin(item.data)				
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():SetMass(1)
						proj:GetPhysicsObject():EnableDrag(true)
						proj:GetPhysicsObject():EnableGravity(true)
						--proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector()+Vector(0,0,0.1))*5000,Vector(0,0,3)) --self:GetAimVector():Angle():Up()*0.1
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*17000) --self:GetAimVector():Angle():Up()*0.1
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(0,10000,0)) end)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						self.Owner:AddScavExplosive(proj)
						--gamemode.Call("ScavFired",self.Owner,proj)
						return self:TakeSubammo(item,1)
					end
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_stickybomb_launcher.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_stickybomb.mdl",6,math.fmod(ent:GetSkin(),2),1) end --6 prox mines from the TF2 stickybomb launcher
				ScavData.CollectFuncs["models/weapons/c_models/c_stickybomb_launcher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_stickybomb_launcher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_stickybomb_launcher/c_stickybomb_launcher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_stickybomb_launcher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_scottish_resistance.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_stickybomb_d.mdl",6,math.fmod(ent:GetSkin(),2),1) end --6 prox mines from the Scottish Resistance
				ScavData.CollectFuncs["models/weapons/c_models/c_scottish_resistance/c_scottish_resistance.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_scottish_resistance.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_sticky_jumper/c_sticky_jumper.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_stickybomb2.mdl",2,math.fmod(ent:GetSkin(),2),1) end --2 prox mines from the Sticky Jumper TODO: no damage, self/teammates trigger too?
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_kingmaker_sticky/c_kingmaker_sticky.mdl"] = function(self,ent) self:AddItem("models/workshop/weapons/c_models/c_kingmaker_sticky/w_kingmaker_stickybomb.mdl",4,math.fmod(ent:GetSkin(),2),1) end --4 prox mines from the Quickie TODO: faster arm time, limit to 4?
			else
				tab.FireFunc = function(self,item)
					return false
				end
			end
			tab.Cooldown = 0.75
		ScavData.RegisterFiremode(tab,"models/scav/proxmine.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/doll01.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_stickybomb.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_stickybomb3.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_stickybomb_d.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_stickybomb2.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_kingmaker_sticky/w_kingmaker_stickybomb.mdl")
		--ScavData.RegisterFiremode(tab,"models/props_halloween/pumpkin_explode.mdl") --TODO: make it its own entity
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_unique/doll01.mdl")
		--ASW
		--ScavData.RegisterFiremode(tab,"models/items/mine/mine.mdl") -- physics are screwy
		
--[[==============================================================================================
	--Tripmines
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.tripmine"
			tab.anim = ACT_VM_MISSCENTER
			tab.Level = 6
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self,item)
					local tr = self.Owner:GetEyeTraceNoCursor()
						if ((tr.HitPos-tr.StartPos):Length() > 64) or tr.Entity:GetClass() == "scav_tripmine" or (not tr.HitWorld and IsValid(tr.Entity) and (tr.Entity:GetMoveType() ~= MOVETYPE_VPHYSICS and tr.Entity:GetMoveType() ~= MOVETYPE_NONE and tr.Entity:GetMoveType() ~= MOVETYPE_PUSH)) then
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
						if not tr.HitWorld then
							proj:SetParent(tr.Entity)
						end
						proj:SetSkin(item.data)
						self.Owner:EmitSound("npc/roller/blade_cut.wav")
						self.Owner:AddScavExplosive(proj)
						return self:TakeSubammo(item,1)
					end
			end
			function tab.OnArmed(self,item,olditemname)
				if SERVER then
					if item.ammo == "models/weapons/w_slam.mdl" then
						self.Owner:EmitSound("weapons/slam/mine_mode.wav")
					end
				end
			end
			tab.Cooldown = 0.75
		ScavData.RegisterFiremode(tab,"models/props_lab/huladoll.mdl")
		--HL2:DM
		ScavData.RegisterFiremode(tab,"models/weapons/w_slam.mdl")

--[[==============================================================================================
	--Energy Drink/Stim Pack
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.stim"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 6
			tab.MaxAmmo = 6
			if SERVER then
				tab.FireFunc = function(self,item)
					if item.ammo == "models/props_junk/garbage_energydrinkcan001a.mdl" or
						item.ammo == "models/weapons/c_models/c_energy_drink/c_energy_drink.mdl" or
						item.ammo == "models/weapons/c_models/c_xms_energy_drink/c_xms_energy_drink.mdl" then
						self.Owner:InflictStatusEffect("Shock",30,40)
						self.Owner:InflictStatusEffect("Speed",20,3)
						if IsMounted(440) then --TF2
							self.Owner:EmitSound("player/pl_scout_dodge_can_open.wav")
							self.Owner:EmitSound("player/pl_scout_dodge_can_drink_fast.wav")
						else
							self.Owner:EmitSound("hl1/fvox/hiss.wav",75,150)
							self.Owner:EmitSound("ambient/levels/canals/toxic_slime_gurgle4.wav")
						end
					elseif item.ammo == "models/props_junk/garbage_syringeneedle001a.mdl" or
						item.ammo == "models/w_models/weapons/w_eq_adrenaline.mdl" then
						if self.Owner:GetStatusEffect("TemporaryHealth") then
							self.Owner:EmitSound("buttons/button11.wav")
							tab.Cooldown = 0.2
							return false
						else
							self.Owner:InflictStatusEffect("Shock",30,40)
							self.Owner:InflictStatusEffect("Speed",20,3)
							if IsMounted(550) then --L4D2
								self.Owner:EmitSound("weapons/adrenaline/adrenaline_cap_off.wav")
							else
								self.Owner:EmitSound("hl1/fvox/hiss.wav",75,180)
							end
							self.Owner:InflictStatusEffect("TemporaryHealth",25,1)
						end
					elseif item.ammo == "models/weapons/c_models/c_riding_crop/c_riding_crop.mdl" or
						item.ammo == "models/workshop/weapons/c_models/c_riding_crop/c_riding_crop.mdl" then
						self.Owner:InflictStatusEffect("Shock",2,40)
						self.Owner:InflictStatusEffect("Speed",5,3)
						self.Owner:EmitSound("weapons/discipline_device_impact_01.wav")
						self.Owner:EmitSound("weapons/discipline_device_power_up.wav")
					elseif item.ammo == "models/pickups/pickup_powerup_agility.mdl" then
						self.Owner:InflictStatusEffect("Shock",30,40)
						self.Owner:InflictStatusEffect("Speed",20,3)
						self.Owner:EmitSound("items/powerup_pickup_agility.wav")
					elseif item.ammo == "models/pickups/pickup_powerup_haste.mdl" then
						self.Owner:InflictStatusEffect("Shock",30,40)
						self.Owner:InflictStatusEffect("Speed",20,3)
						self.Owner:EmitSound("items/powerup_pickup_haste.wav")
					elseif item.ammo == "models/items/powerup_speed.mdl" or
							item.ammo == "models/props_junk/shoe001a.mdl" then
						self.Owner:InflictStatusEffect("Speed",20,3)
						self.Owner:EmitSound("npc/metropolice/gear"..math.random(1,6)..".wav")
					else
						self.Owner:InflictStatusEffect("Shock",30,40)
						self.Owner:InflictStatusEffect("Speed",20,3)
						self.Owner:EmitSound("npc/scanner/scanner_nearmiss1.wav")
					end
					return self:TakeSubammo(item,1)
				end
				--CSS
				ScavData.CollectFuncs["models/props/cs_office/trash_can.mdl"] = function(self,ent)
					self:AddItem("models/props/cs_office/trash_can_p7.mdl",1,ent:GetSkin(),1)
					self:AddItem("models/props/cs_office/trash_can_p8.mdl",1,ent:GetSkin(),1)
				end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"] = function(self,ent)
					if self.christmas and ent:GetSkin() < 2 then
						self:AddItem("models/weapons/c_models/c_xms_energy_drink/c_xms_energy_drink.mdl",1,ent:GetSkin(),1)
					else
						self:AddItem("models/weapons/c_models/c_energy_drink/c_energy_drink.mdl",1,ent:GetSkin(),1)
					end
				end
			end
			tab.Cooldown = 0.5
		ScavData.RegisterFiremode(tab,"models/items/powerup_speed.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_syringeneedle001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_energydrinkcan001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_coffeemug001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_plasticbottle003a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/shoe001a.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_energy_drink/c_energy_drink.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_xms_energy_drink/c_xms_energy_drink.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_eq_adrenaline.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_riding_crop/c_riding_crop.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_riding_crop/c_riding_crop.mdl")
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_agility.mdl")
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_haste.mdl")
		ScavData.RegisterFiremode(tab,"models/props_2fort/coffeepot.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_office/trash_can_p7.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/trash_can_p8.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/coffee_mug.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/coffee_mug2.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/coffee_mug3.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_interiors/coffee_maker.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_coffeecup01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_coffeecup01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_coffeemug001a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_unique/coffeepot01.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_cola.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/garbage_drinks_container.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_sodacup01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_sodacup01a_fullsheet.mdl")
		--Portal/2
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_coffeemug001a_forevergibs.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_02.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_03.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_04.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_05.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_06.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_07.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_08.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_09.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_10.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_11.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_12.mdl")
		ScavData.RegisterFiremode(tab,"models/props_office/coffee_mug_17.mdl")
		
--[[==============================================================================================
	--Cloaking Watch
==============================================================================================]]--
		
		local function cloakcheck(self)
			if self.Cloak and (self.Cloak.subammo > 0) then
				--self.Cloak.subammo = self.Cloak.subammo-1
				self.Cloak:SetSubammo(math.max(self.Cloak:GetSubammo()-1,0)) --properly updates HUD
				timer.Simple(1, function() cloakcheck(self) end)
			else
				if SERVER and self.Cloak then
					self.Owner:InflictStatusEffect("Cloak",-self.Cloak.subammo,1)
					self:RemoveItemValue(self.Cloak)
				end
				self.Cloak = false
			end
		end
		
		local tab = {}
			tab.Name = "#scav.scavcan.cloak"
			tab.anim = ACT_VM_FIDGET
			tab.Level = 7
			tab.MaxAmmo = 90
			if SERVER then
				tab.FireFunc = function(self,item)
					if self.Cloak and (self.Cloak ~= item) then
						local leftover = item.subammo-self.Cloak.subammo
						self.Cloak = item
						self.Owner:InflictStatusEffect("Cloak",leftover,1)
					elseif not self.Cloak then
						self.Owner:InflictStatusEffect("Cloak",item.subammo,1)
						self.Cloak = item
						timer.Simple(1, function() cloakcheck(self) end)
					else
						self.Owner:InflictStatusEffect("Cloak",-self.Cloak.subammo,1)
						self.Cloak = false
					end
				end
					
				function tab.PostRemove(self,item)
					if item == self.Cloak then
						self.Owner:InflictStatusEffect("Cloak",-self.Cloak.subammo,1)
						self.Cloak = false
					end
				end
				ScavData.CollectFuncs["models/maxofs2d/hover_basic.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) end --30 seconds of cloak
				ScavData.CollectFuncs["models/props_junk/metal_paintcan001a.mdl"] = ScavData.CollectFuncs["models/maxofs2d/hover_basic.mdl"]
				ScavData.CollectFuncs["models/props_junk/metal_paintcan001b.mdl"] = ScavData.CollectFuncs["models/maxofs2d/hover_basic.mdl"]
				--CSS
				ScavData.CollectFuncs["models/props/cs_militia/paintbucket01.mdl"] = ScavData.CollectFuncs["models/maxofs2d/hover_basic.mdl"]
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_spy_watch.mdl"] = ScavData.CollectFuncs["models/maxofs2d/hover_basic.mdl"]
				ScavData.CollectFuncs["models/props_farm/paint_can001.mdl"] = ScavData.CollectFuncs["models/maxofs2d/hover_basic.mdl"]
				ScavData.CollectFuncs["models/props_farm/paint_can002.mdl"] = ScavData.CollectFuncs["models/props_farm/paint_can001.mdl"]
				--L4D/2
				ScavData.CollectFuncs["models/props_junk/garbage_spraypaintcan01a.mdl"] = ScavData.CollectFuncs["models/maxofs2d/hover_basic.mdl"]
				ScavData.CollectFuncs["models/props_junk/garbage_spraypaintcan01a_fullsheet.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_spraypaintcan01a.mdl"]
				ScavData.CollectFuncs["models/props_junk/metal_paintcan001b_static.mdl"] = ScavData.CollectFuncs["models/props_junk/metal_paintcan001b.mdl"]
				ScavData.CollectFuncs["models/props_debris/paintbucket01.mdl"] = ScavData.CollectFuncs["models/props/cs_militia/paintbucket01.mdl"]
				ScavData.CollectFuncs["models/props_debris/paintbucket01_static.mdl"] = ScavData.CollectFuncs["models/props/cs_militia/paintbucket01.mdl"]
				--HL:S
				ScavData.CollectFuncs["models/hassassin.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,0) self:AddItem("models/w_silencer.mdl",17,0,2) end --30 seconds of cloak + 2 silenced pistols from a HL1 Assassin
			else
				tab.FireFunc = function(self,item)
					if self.Cloak and (self.Cloak ~= item) then
						self.Cloak = item
					elseif not self.Cloak then
						self.Cloak = item
						timer.Simple(1, function() cloakcheck(self) end)
					else
						self.Cloak = false
					end
					return false
				end
			end
			

			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/maxofs2d/hover_basic.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/metal_paintcan001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/metal_paintcan001b.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_militia/paintbucket01.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_spy_watch.mdl")
		ScavData.RegisterFiremode(tab,"models/props_farm/paint_can001.mdl")
		ScavData.RegisterFiremode(tab,"models/props_farm/paint_can002.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_spraypaintcan01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_spraypaintcan01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/metal_paintcan001b_static.mdl")
		ScavData.RegisterFiremode(tab,"models/props_debris/paintbucket01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_debris/paintbucket01_static.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab,"models/hassassin.mdl")
		
	

--[[==============================================================================================
	--Key
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.key"
			tab.anim = ACT_VM_IDLE
			tab.Level = 7
			tab.MaxAmmo = 6
			if SERVER then
				tab.FireFunc = function(self,item)
					--local tr = self.Owner:GetEyeTraceNoCursor()
					local tracep = {}
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*48
						tracep.filter = self.Owner
						tracep.mask = MASK_SOLID --MASK_SOLID_BRUSHONLY
						local tr = util.TraceHull(tracep)
						--print(tr.Entity)
					if ((tr.HitPos-tr.StartPos):Length() > 48) or not IsValid(tr.Entity) or not (string.find(tr.Entity:GetClass(),"_door",0,true)) then
						self.Owner:EmitSound("buttons/button11.wav")
						return false
					end
					if tr.Entity:GetInternalVariable("m_bLocked") or --door is locked
						(bit.band(tr.Entity:GetEFlags(),256) == 0 and bit.band(tr.Entity:GetEFlags(),1024) == 0 and string.find(tr.Entity:GetClass(),"func_door",0)) or --neither Use nor Touch Opens (func_door/_rotating)
						(bit.band(tr.Entity:GetEFlags(),32768) ~= 0 and tr.Entity:GetClass() == "prop_door_rotating") then --Use doesn't open (prop_door_rotating)
						tr.Entity:Fire("Unlock",1,0)
						if tr.Entity:GetClass() == "prop_door_rotating" and tr.Entity:GetInternalVariable("m_eDoorState") == 0 then --don't smack ourself in the face with the door if we can help it
							tr.Entity:Fire("OpenAwayFrom","!activator",0.01,self.Owner)
						else
							tr.Entity:Fire("Toggle",1,0.01)
						end
						return self:TakeSubammo(item,1)
					else
						if tr.Entity:GetClass() == "prop_door_rotating" and tr.Entity:GetInternalVariable("m_eDoorState") == 0 then
							tr.Entity:Fire("OpenAwayFrom","!activator",0,self.Owner)
						else
							tr.Entity:Fire("Toggle",1,0)
						end
						return false
					end
				end
				-- ScavData.CollectFuncs["models/lostcoast/fisherman/fisherman.mdl"] = function(self,ent) --effect
				-- 	self:AddItem(ScavData.FormatModelname("models/lostcoast/fisherman/keys.mdl"),1,0)
				-- 	self:AddItem(ScavData.FormatModelname("models/lostcoast/fisherman/harpoon.mdl"),1,0)
				-- end
			end
			tab.Cooldown = 2
		ScavData.RegisterFiremode(tab,"models/props_lab/keypad.mdl")
		--Lost Coast
		ScavData.RegisterFiremode(tab,"models/lostcoast/fisherman/keys.mdl")
		--Wiremod
		ScavData.RegisterFiremode(tab,"models/bull/buttons/key_switch.mdl")

--[[==============================================================================================
	--Remote
==============================================================================================]]--
		
if SERVER then
	util.AddNetworkString("scav_hackdone")
end

	do
		local tab = {}
			tab.Name = "#scav.scavcan.remote"
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
					if not ent.oldstrength then
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
					ent:SetArmed(not ent:IsArmed())
				end
				}
			interactions["gmod_thruster"] = {
				["HackTime"]=6,
				["Action"]= function(self,ent)
					ent:Switch(not ent:IsOn())
				end
				}
			interactions["gmod_turret"] = {
				["HackTime"]=6,
				["Action"]= function(self,ent)
					ent:SetOn(not ent:GetOn())
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
					ent:SetSaveValue("m_bHackedByAlyx",not ent:GetInternalVariable("m_bHackedByAlyx"))
					ent:Fire("Skin",1,0) --for whatever reason GMod doesn't have a rollermine model with skins in it (and the hack status doesn't automatically apply it) but in case the player has a fixed model, make it appear correctly
					ent:Fire("InteractivePowerDown",nil,15,self.Owner,self)
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
					ent.HackedOff = not ent.HackedOff
				end
				}
			
			interactions["prop_vehicle_jeep_old"] = interactions["prop_vehicle_jeep"]
			interactions["prop_vehicle_airboat"] = interactions["prop_vehicle_jeep"]
			function tab.ChargeAttack(self,item)
				self.HackingProgress = (self.HackingProgress or 0)+0.05
				self.BarrelRotation = self.BarrelRotation+math.random(-17,17)
				if SERVER then
					local dist = 9999999
					if IsValid(self.HackTarget) then
						dist = self.Owner:GetShootPos():DistToSqr(self.HackTarget:GetPos())
					end
					if not self.Owner:KeyDown(IN_ATTACK) or (self.HackingProgress > self.HackTime) or not IsValid(self.HackTarget) or dist > 1000000 then
						local success = false
						if IsValid(self.ef_radio) then
							self.ef_radio:Kill()
						end
						--if IsValid(self.ef_wires) then
						--	self.ef_wires:Kill()
						--end
						if dist > 1000000 then
							self:EmitSound("buttons/combine_button_locked.wav")
						elseif IsValid(self.HackTarget) and (self.HackingProgress > self.HackTime) then
							self:EmitSound("buttons/combine_button1.wav")
							success = true
							local interaction = interactions[string.lower(self.HackTarget:GetClass())]
							if interaction then
								interaction.Action(self,self.HackTarget)
							else
								self.HackTarget:Fire("Use",nil,0)
							end
						else
							self:EmitSound("buttons/combine_button_locked.wav")
						end
						self:SetChargeAttack()
						self.HackingProgress = 0
						net.Start("scav_hackdone")
							net.WriteEntity(self)
							net.WriteBool(success)
						net.Send(self.Owner)
						return 1
					end
				else
					net.Receive("scav_hackdone",function()
						local wep = net.ReadEntity()
						local success = net.ReadBool()
						if IsValid(wep) then
							wep:SetChargeAttack()
							wep.HackingProgress = 0
							if success then
								wep:EmitSound("buttons/combine_button1.wav")
							else
								wep:EmitSound("buttons/combine_button_locked.wav")
							end
							wep.nextfire = CurTime() + 1 * wep:GetCooldownScale()
						end
					end)
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
					--self.ef_wires = self:CreateToggleEffect("scav_stream_cord")
					--if IsValid(self.ef_wires) and IsValid(self.HackTarget) then
					--	self.ef_wires:Setendent(self.HackTarget)
					--end
				end
				self:SetChargeAttack(tab.ChargeAttack,item)
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/alyx_emptool_prop.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/alyx.mdl"] = function(self,ent)
					self:AddItem(ScavData.FormatModelname("models/alyx_emptool_prop.mdl"),SCAV_SHORT_MAX,0)
					self:AddItem(ScavData.FormatModelname("models/weapons/w_alyx_gun.mdl"),30,0)
				end
				ScavData.CollectFuncs["models/alyx_interior.mdl"] = ScavData.CollectFuncs["models/alyx.mdl"]
				ScavData.CollectFuncs["models/alyx_ep2.mdl"] = ScavData.CollectFuncs["models/alyx.mdl"]
				ScavData.CollectFuncs["models/player/alyx.mdl"] = ScavData.CollectFuncs["models/alyx.mdl"]
				--CSS
				ScavData.CollectFuncs["models/props/cs_office/projector_remote.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/weapons/w_defuser.mdl"] = ScavData.GiveOneOfItemInf
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_wrangler.mdl"] = function(self,ent)
					if self.christmas then
						self:AddItem("models/weapons/c_models/c_wrangler_xmas.mdl",SCAV_SHORT_MAX,ent:GetSkin(),1)
					else
						self:AddItem(ScavData.FormatModelname(ent:GetModel()),SCAV_SHORT_MAX,ent:GetSkin(),1)
					end
				end
				ScavData.CollectFuncs["models/weapons/c_models/c_wrangler.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_wrangler.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_wrangler_xmas.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_invasion_wrangler/c_invasion_wrangler.mdl"] = ScavData.GiveOneOfItemInf
				--L4D/2
				ScavData.CollectFuncs["models/props_junk/garbage_remotecontrol01a.mdl"] = ScavData.GiveOneOfItemInf
			end
		ScavData.RegisterFiremode(tab,"models/alyx_emptool_prop.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_office/projector_remote.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_defuser.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_wrangler.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_wrangler.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_wrangler_xmas.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_invasion_wrangler/c_invasion_wrangler.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_remotecontrol01a.mdl")
	end
		
		

--[[==============================================================================================
	--Nailgun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.nailgun"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 150
			if SERVER then
				tab.FireFunc = function(self,item)
					local proj = self:CreateEnt("scav_projectile_impaler")
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetPos(self:GetProjectileShootPos())
					local ang = self.Owner:EyeAngles()
					ang:RotateAroundAxis(self.Owner:GetAimVector(),90)
					proj:SetAngles(ang)
					proj:SetModel(item.ammo)
					proj:SetSkin(item.data)
					proj.DmgAmt = 12
					proj.NoPin = true
					proj.Drop = vector_origin
					proj.Trail = util.SpriteTrail(proj,0,Color(255,255,255,255),true,1,0,0.1,0.25,"trails/smoke.vmt")
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("physics/metal/weapon_impact_hard3.wav",75,70,1)
					return self:TakeSubammo(item,1)
				end
				ScavData.CollectFuncs["models/props_lab/cactus.mdl"] = function(self,ent) self:AddItem("models/scav/nail.mdl",15,ent:GetSkin()) end
				--TF2
				ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"] = function(self,ent) self:AddItem("models/scav/nail.mdl",30,ent:GetSkin()) end
				ScavData.CollectFuncs["models/weapons/w_models/w_nailgun.mdl"] = function(self,ent) self:AddItem("models/scav/nail.mdl",50,ent:GetSkin()) end
				ScavData.CollectFuncs["models/weapons/c_models/c_boston_basher/c_boston_basher.mdl"] = function(self,ent) self:AddItem("models/scav/nail.mdl",21,ent:GetSkin()) end
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_boston_basher/c_boston_basher.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_boston_basher/c_boston_basher.mdl"]
				--FoF
				ScavData.CollectFuncs["models/elpaso/cactus1.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
				ScavData.CollectFuncs["models/elpaso/cactus2.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
				ScavData.CollectFuncs["models/elpaso/cactus3.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
			end
			tab.Cooldown = 0.075
		ScavData.RegisterFiremode(tab,"models/scav/nail.mdl")
		ScavData.RegisterFiremode(tab,"models/scav/nailsmall.mdl")
		--TF2
		--ScavData.RegisterFiremode(tab,"models/props_2fort/nail001.mdl") --TODO: needs to be flipped around
		
--[[==============================================================================================
	--Shurikens
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.shuriken"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 20
			if SERVER then
				tab.FireFunc = function(self,item)
					--self.Owner:ViewPunch(Angle(-5,math.Rand(-0.1,0.1),0))
					local proj = self:CreateEnt("scav_projectile_impaler")
					proj:SetModel(item.ammo)
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetSkin(item.data)
					proj:SetPos(self:GetProjectileShootPos())
					local ang = self.Owner:EyeAngles()
					ang:RotateAroundAxis(self.Owner:GetAimVector(),90)
					if item.ammo == "models/scav/shuriken.mdl" or
						item.ammo == "models/weapons/scav/shuriken.mdl" then
						proj.Trail = util.SpriteTrail(proj,0,Color(255,255,255,255),true,2,0,0.3,0.25,"trails/smoke.vmt")
						proj.DmgAmt = 8
						self.Owner:EmitSound("weapons/ar2/fire1.wav")
					end
					proj:SetAngles(ang)
					proj.NoPin = true
					proj.Drop = vector_origin
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					return self:TakeSubammo(item,1)
				end
			end
			tab.Cooldown = 0.2
		ScavData.RegisterFiremode(tab,"models/scav/shuriken.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/scav/shuriken.mdl")
		
		
--[[==============================================================================================
	--Tank shell
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.tankshell"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			tab.MaxAmmo = 4
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
						return self:TakeSubammo(item,1)
					end
					local ef = EffectData()
						ef:SetOrigin(tr.HitPos)
						ef:SetNormal(tr.HitNormal)
						util.Effect("ef_scav_exp3",ef,nil,true)
					util.Decal("Scorch",tr.HitPos+tr.HitNormal*8,tr.HitPos-tr.HitNormal*8)
					
					util.ScreenShake(self:GetPos(),500,10,4,4000)
					util.BlastDamage(self,self.Owner,tr.HitPos,512,250)
					sound.Play("ambient/explosions/explode_3.wav",self:GetPos(),100,100)
					--gamemode.Call("ScavFired",self.Owner,proj)
					return self:TakeSubammo(item,1)
				end
				--CSS
				ScavData.CollectFuncs["models/props/de_prodigy/ammo_can_01.mdl"] = function(self,ent) self:AddItem("models/weapons/w_bullet.mdl",4,0,2) end
				ScavData.CollectFuncs["models/props/de_prodigy/ammo_can_02.mdl"] = function(self,ent) self:AddItem("models/weapons/w_bullet.mdl",4,0,1) end --4 tank shells from an ammo box
				ScavData.CollectFuncs["models/props/de_prodigy/ammo_can_03.mdl"] = function(self,ent) self:AddItem("models/weapons/w_bullet.mdl",4,0,3) end
			end
			tab.Cooldown = 5
		ScavData.RegisterFiremode(tab,"models/weapons/w_bullet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/gibs/flakgib1.mdl")
		ScavData.RegisterFiremode(tab,"models/scav/tankshell.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/props_fortifications/flak38.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/halftrackgun_us1.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/sherman_tank.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/sherman_tank_snow.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/tiger_tank.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/tiger_tank_navyb.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/tiger_tank_tan.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/tiger_tank_snow.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_signs/burgersign.mdl")
		ScavData.RegisterFiremode(tab,"models/props_signs/burgersign_beacon.mdl")
		ScavData.RegisterFiremode(tab,"models/props_signs/raisedbillboard.mdl")
		
		
--[[==============================================================================================
	--Teleporter
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.teleporter"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 6
			tab.vmin = Vector(-24,-24,0)
			tab.vmax = Vector(24,24,0)
			PrecacheParticleSystem("portal_1_projectile_stream")
			PrecacheParticleSystem("Rocket_Smoke")
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
						if IsMounted(400) then --Portal
							self.Owner:EmitSound("weapons/portalgun/portal_invalid_surface3.wav")
						else
							self.Owner:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav")
						end
						return
					end
					local offset = tr.HitNormal*18
					if offset.z < 0 then
						if IsMounted(400) then --Portal
							self.Owner:EmitSound("weapons/portalgun/portal_invalid_surface3.wav")
						else
							self.Owner:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav")
						end
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
						local item = self.Owner:GetActiveWeapon()
						if item.ammo == "models/weapons/w_portalgun.mdl" then
							self.Owner:EmitSound("weapons/portalgun/portal_open3.wav")
						elseif item.ammo == "models/buildables/teleporter_light.mdl" then
							self.Owner:EmitSound("weapons/teleporter_send.wav")
						else
							self.Owner:EmitSound("ambient/machines/teleport1.wav")
						end
					else
						if IsMounted(400) then --Portal
							self.Owner:EmitSound("weapons/portalgun/portal_invalid_surface3.wav")
						else
							self.Owner:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav")
						end
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
					--s_proj.AddProjectile(self.Owner,self.Owner:GetShootPos(),self:GetAimVector()*5000,ScavData.models[self.inv.items[1].ammo].Callback,false,false,vector_origin,self.Owner,Vector(-8,-8,-8),Vector(8,8,8))
					--					(Owner,     pos,                     velocity,                      callback,                                  ignoreworld,pierce,gravity,tablefilter,mins,maxs) --what the FUCK was I doing here?
					proj:SetOwner(self.Owner)
					proj:SetFilter(self.Owner)
					proj:SetPos(self.Owner:GetShootPos())
					proj:SetVelocity(self:GetAimVector()*2000*self:GetForceScale())
					proj:Fire()
					local ef = EffectData()
					ef:SetOrigin(pos)
					ef:SetStart(self:GetAimVector()*2000*self:GetForceScale())
					ef:SetEntity(self.Owner)
					if item.ammo == "models/weapons/w_portalgun.mdl" then
						self.Owner:EmitSound("weapons/portalgun/portalgun_shoot_blue1.wav")
					elseif item.ammo == "models/buildables/teleporter_light.mdl" then
						self.Owner:EmitSound("weapons/teleporter_ready.wav")
					elseif item.ammo == "models/props_combine/combine_teleport_2.mdl" then
						self.Owner:EmitSound("buttons/combine_button2.wav")
					else
						self.Owner:EmitSound("ambient/machines/catapult_throw.wav")
					end
					
					if IsMounted(400) then --Portal
						util.Effect("ef_scav_portalbeam",ef,nil,true)
					else
						util.Effect("ef_scav_portalbeam_hl2",ef,nil,true)
					end
					return false
				end
				ScavData.CollectFuncs["models/maxofs2d/hover_rings.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/miniteleport.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/teleportbulk.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_lab/teleportbulkeli.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_combine/combine_teleport_2.mdl"] = ScavData.GiveOneOfItemInf
				--Portal
				ScavData.CollectFuncs["models/weapons/w_portalgun.mdl"] = ScavData.GiveOneOfItemInf
				--TF2
				ScavData.CollectFuncs["models/buildables/teleporter_light.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/buildables/teleporter.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/buildables/teleporter_light.mdl"), SCAV_SHORT_MAX, ent:GetSkin()) end
			else
				tab.FireFunc = function(self,item)
					local tr = self.Owner:GetEyeTraceNoCursor()
					local tab = ScavData.models[item.ammo]
					return false
				end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/maxofs2d/hover_rings.mdl")
		ScavData.RegisterFiremode(tab,"models/buildables/teleporter_light.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/miniteleport.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/teleportbulk.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/teleportbulkeli.mdl")
		ScavData.RegisterFiremode(tab,"models/props_combine/combine_teleport_2.mdl")
		--Portal
		ScavData.RegisterFiremode(tab,"models/weapons/w_portalgun.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/buildables/teleporter_light.mdl")
		
--[[==============================================================================================
	--Electricity beam
==============================================================================================]]--

	local DoChargeSound
		local tab = {}
			tab.Name = "#scav.scavcan.shockbeam"
			tab.anim = ACT_VM_RECOIL2
			tab.Level = 4
			tab.MaxAmmo = 500
			if SERVER then
				DoChargeSound = function(self,item,olditemname)
					if item.ammo ~= olditemname then
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
						proj.SpeedScale = self:GetForceScale()
						proj:Spawn()
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
					--self.Owner:EmitSound("ambient/energy/NewSpark1"..math.random(0,1)..".wav")
					--self.Owner:EmitSound("weapons/physcannon/superphys_small_zap4.wav")
					self.Owner:EmitSound("npc/scanner/scanner_electric1.wav")
					return self:TakeSubammo(item,1)
				end
								
				ScavData.CollectFuncs["models/props_c17/substation_transformer01d.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),15,ent:GetSkin()) end
				ScavData.CollectFuncs["models/weapons/w_stunbaton.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_c17/consolebox01a.mdl"] = ScavData.CollectFuncs["models/weapons/w_stunbaton.mdl"]
				ScavData.CollectFuncs["models/props_c17/consolebox03a.mdl"] = ScavData.CollectFuncs["models/props_c17/consolebox01a.mdl"]
				ScavData.CollectFuncs["models/props_c17/consolebox05a.mdl"] = ScavData.CollectFuncs["models/props_c17/consolebox01a.mdl"]
				ScavData.CollectFuncs["models/props_c17/utilityconducter001.mdl"] = ScavData.CollectFuncs["models/props_c17/consolebox01a.mdl"]
				ScavData.CollectFuncs["models/props_lab/powerbox01a.mdl"] = ScavData.CollectFuncs["models/props_c17/substation_transformer01d.mdl"]
				ScavData.CollectFuncs["models/props_lab/powerbox02a.mdl"] = ScavData.CollectFuncs["models/props_c17/consolebox01a.mdl"]
				ScavData.CollectFuncs["models/props_lab/powerbox02b.mdl"] = ScavData.CollectFuncs["models/props_c17/consolebox01a.mdl"]
				ScavData.CollectFuncs["models/props_lab/powerbox02c.mdl"] = ScavData.CollectFuncs["models/props_c17/consolebox01a.mdl"]
				ScavData.CollectFuncs["models/props_lab/powerbox02d.mdl"] = ScavData.CollectFuncs["models/props_c17/consolebox01a.mdl"]
				ScavData.CollectFuncs["models/props_lab/powerbox03a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,ent:GetSkin()) end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),4,0) end --TODO: put pomson on its own firemode. Don't forget cloak drain!
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),4,0) end
				ScavData.CollectFuncs["models/weapons/c_models/c_drg_righteousbison/c_drg_righteousbison.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_drg_righteousbison/c_drg_righteousbison.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl"]
				ScavData.CollectFuncs["models/weapons/w_models/w_sapper.mdl"] = function(self,ent) --holiday check
						if self.christmas then
							self:AddItem("models/weapons/c_models/c_sapper/c_sapper_xmas.mdl",8,math.floor(math.Rand(0,2)))
						else
							self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,ent:GetSkin())
						end
					end
				ScavData.CollectFuncs["models/weapons/w_models/w_sd_sapper.mdl"] = ScavData.CollectFuncs["models/weapons/w_stunbaton.mdl"]
				ScavData.CollectFuncs["models/buildables/sd_sapper_dispenser.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sd_sapper.mdl"]
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_sd_sapper/c_sd_sapper.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sd_sapper.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_sapper/c_sapper.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sapper.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_sapper/c_sapper_xmas.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),8,ent:GetSkin()) end
				ScavData.CollectFuncs["models/weapons/c_models/c_p2rec/c_p2rec.mdl"] = ScavData.CollectFuncs["models/weapons/w_stunbaton.mdl"]
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_sd_neonsign/c_sd_neonsign.mdl"] = ScavData.CollectFuncs["models/weapons/w_stunbaton.mdl"]
				ScavData.CollectFuncs["models/buildables/sapper_dispenser.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sapper.mdl"]
				ScavData.CollectFuncs["models/buildables/gibs/sapper_gib002.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),3,0) end
				ScavData.CollectFuncs["models/buildables/gibs/sapper_gib001.mdl"] = ScavData.CollectFuncs["models/buildables/gibs/sapper_gib002.mdl"]
			end
			tab.Cooldown = 0.5
			
		ScavData.RegisterFiremode(tab,"models/props_c17/substation_transformer01d.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_stunbaton.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/consolebox01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/consolebox03a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/consolebox05a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/utilityconducter001.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/powerbox01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/powerbox02a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/powerbox02b.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/powerbox02c.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/powerbox02d.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/powerbox03a.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_drg_righteousbison/c_drg_righteousbison.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_drg_righteousbison/c_drg_righteousbison.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_sapper.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_sd_sapper.mdl")
		ScavData.RegisterFiremode(tab,"models/buildables/sd_sapper_dispenser.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_sd_sapper/c_sd_sapper.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_sapper/c_sapper.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_sapper/c_sapper_xmas.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_p2rec/c_p2rec.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_dex_arm/c_dex_arm.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_sd_neonsign/c_sd_neonsign.mdl")
		ScavData.RegisterFiremode(tab,"models/buildables/gibs/sapper_gib001.mdl")
		ScavData.RegisterFiremode(tab,"models/buildables/gibs/sapper_gib002.mdl")
		ScavData.RegisterFiremode(tab,"models/buildables/sapper_dispenser.mdl")

--[[==============================================================================================
	--Hyper beam
==============================================================================================]]--
	local DoChargeSound
		local tab = {}
			tab.Name = "#scav.scavcan.hyperbeam"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			if SERVER then
				tab.OnArmed = DoChargeSound
				tab.FireFunc = function(self,item)
					local proj = self:CreateEnt("scav_projectile_hyper")
					self.Owner:EmitSound("ambient/explosions/explode_7.wav",100,190,0.65)
					proj.Owner = self.Owner
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles(self:GetAimVector():Angle())
					proj.vel = self:GetAimVector()*2000
					proj:SetOwner(self.Owner)
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
					return self:TakeSubammo(item,1)
				end
				ScavData.CollectFuncs["models/metroid.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_combine/introomarea.mdl"] = ScavData.GiveOneOfItemInf
			else
				tab.FireFunc = function(self,item)
					return false
				end
			end
			tab.Cooldown = 0.3
			
		ScavData.RegisterFiremode(tab,"models/metroid.mdl")
		ScavData.RegisterFiremode(tab,"models/props_combine/introomarea.mdl")
		
--[[==============================================================================================
	--I just couldn't resist: The BFG9000
==============================================================================================]]--
	local DoChargeSound
		
		local tab = {}
			tab.Name = "#scav.scavcan.bfg9000"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = nil
			tab.RemoveOnCharge = false
			tab.Level = 9
			if SERVER then
				tab.OnArmed = function(self,item,olditemname)
					if item.ammo ~= olditemname then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
			end
			tab.ChargeAttack = function(self,item)
				local tab = ScavData.models["models/props_vehicles/generatortrailer01.mdl"]
				if SERVER then
					self.soundloops.bfgcharge:PlayEx(100,60+math.min(self.WeaponCharge,4)*40)
					self.soundloops.bfgcharge2:PlayEx(100,60+math.min(self.WeaponCharge,4)*40)
				end
				if not self.Owner:KeyDown(IN_ATTACK) and (self.WeaponCharge >= 1) then
					if SERVER then
						local proj = self:CreateEnt("scav_projectile_bigshot")
							proj.Charge = math.floor(math.min(self.WeaponCharge,4))
							proj.Owner = self.Owner
							proj:SetPos(self:GetProjectileShootPos())
							proj:SetAngles(self:GetAimVector():Angle())
							proj:SetOwner(self.Owner)
							proj.SpeedScale = self:GetForceScale()
							proj:Spawn()
						if proj:GetPhysicsObject():IsValid() then
							proj:GetPhysicsObject():SetVelocity(self:GetAimVector()*500)
						end
						self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
						net.Start("scv_falloffsound")
							local rf = RecipientFilter()
							rf:AddAllPlayers()
							net.WriteVector(self:GetPos())
							net.WriteString("weapons/physgun_off.wav")
						net.Send(rf)
						self.soundloops.bfgcharge:Stop()
						self.soundloops.bfgcharge2:Stop()
						self:TakeSubammo(item,proj.Charge)
						self:KillEffect()
						if item.subammo <= 0 then
							self:RemoveItemValue(item)
						end
						self:SetPanelPose(0,2)
						self:SetBlockPose(0,2)
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:SetChargeAttack()
					self.WeaponCharge = 0
					tab.chargeanim = ACT_VM_SECONDARYATTACK
					if IsValid(self.ef_plasmacharge) then
						if CLIENT then self:GetModel():StopParticleEmission() end
						self.ef_plasmacharge:Kill()
					end
					return 3
				else
					tab.chargeanim = ACT_VM_FIDGET
					self.WeaponCharge = self.WeaponCharge+0.05
					if self.WeaponCharge >= 6 and IsValid(self.Owner) then
						if SERVER then
							local proj = self:CreateEnt("scav_projectile_bigshot")
								proj.Charge = math.floor(math.min(self.WeaponCharge,4))
								proj.Owner = self.Owner
								proj:SetPos(self:GetProjectileShootPos())
								proj:SetAngles(self:GetAimVector():Angle())
								proj:SetOwner(self.Owner)
								proj.SpeedScale = self:GetForceScale()
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
							if self.Owner:Alive() then
								self.Owner:Kill()
							end
						else
							ParticleEffect("scav_exp_bigshot",self.Owner:GetPos(),Angle(0,0,0),Entity(0))
						end
						self.WeaponCharge = 0
						self:SetChargeAttack()
						return 3
					end
				end
				return 0.025
			end
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(ScavData.models["models/props_vehicles/generatortrailer01.mdl"].ChargeAttack,item)
				if SERVER then
					self.Owner:EmitSound("HL1/ambience/particle_suck1.wav",100,200)
					if not self.soundloops.bfgcharge then
						self.soundloops.bfgcharge = CreateSound(self.Owner,"ambient/machines/combine_shield_loop3.wav")
						self.soundloops.bfgcharge2 = CreateSound(self.Owner,"npc/attack_helicopter/aheli_crash_alert2.wav")
					end
					self.ef_plasmacharge = self:CreateToggleEffect("scav_stream_plasmacharge")
					self:SetPanelPose(0.5,0.25)
					self:SetBlockPose(0.5,0.25)
				end
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),4,0) end
				--Ep2
				ScavData.CollectFuncs["models/props_mining/diesel_generator.mdl"] = ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"]
				--L4D
				ScavData.CollectFuncs["models/props_vehicles/floodlight_generator_nolight.mdl"] = ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"]
				ScavData.CollectFuncs["models/props_vehicles/floodlight_generator_nolight_static.mdl"] = ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"]
				ScavData.CollectFuncs["models/props_vehicles/floodlight_generator_pose01_static.mdl"] = ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"]
				ScavData.CollectFuncs["models/props_vehicles/floodlight_generator_pose02_static.mdl"] = ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"]
				--DoD:S
				ScavData.CollectFuncs["models/props_vehicles/generator.mdl"] = ScavData.CollectFuncs["models/props_vehicles/generatortrailer01.mdl"]
			end
			tab.Cooldown = 0.1
			
		ScavData.RegisterFiremode(tab,"models/props_vehicles/generatortrailer01.mdl")
		--Ep2
		ScavData.RegisterFiremode(tab,"models/props_mining/diesel_generator.mdl")
		--L4D
		ScavData.RegisterFiremode(tab,"models/props_vehicles/floodlight_generator_nolight.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/floodlight_generator_nolight_static.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/floodlight_generator_pose01_static.mdl")
		ScavData.RegisterFiremode(tab,"models/props_vehicles/floodlight_generator_pose02_static.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/props_vehicles/generator.mdl")
		
--[[==============================================================================================
	--..Or this..
==============================================================================================]]--
		local tab = {}
			tab.Name = "#scav.scavcan.cannon"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_FIDGET
			tab.RemoveOnCharge = false
			tab.Level = 7
			tab.ChargeAttack = function(self,item)
				local tab = ScavData.models["models/props_phx/cannonball.mdl"]
				if (not self.Owner:KeyDown(IN_ATTACK) and (self.WeaponCharge >= 0)) or (self.WeaponCharge >= 1) then
					if SERVER then
						local proj = self:CreateEnt("scav_projectile_cannonball")
							proj:SetModel(item.ammo)
							proj:SetSkin(item.data)
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
						self:TakeSubammo(item,proj.Charge)
						self:KillEffect()
						self:RemoveItemValue(item)
						self.soundloops.cannon:Stop()
						self.Owner:EmitSound(self.shootsound)
						--self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:SetChargeAttack()
					self.WeaponCharge = 0
					tab.chargeanim = ACT_VM_SECONDARYATTACK
					return 1
				else
					tab.chargeanim = ACT_VM_FIDGET
					self.WeaponCharge = self.WeaponCharge+0.05
				end
				return 0.1
			end
			tab.FireFunc = function(self,item)
				if SERVER then
					if not self.soundloops.cannon then
						self.soundloops.cannon = CreateSound(self.Owner,"weapons/stickybomblauncher_charge_up.wav")
						self.soundloops.cannon:ChangePitch(160)
					end
					self.soundloops.cannon:Play()
				end
				self:SetChargeAttack(ScavData.models["models/props_phx/cannonball.mdl"].ChargeAttack,item)
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_phx/cannon.mdl"] = function(self,ent) self:AddItem("models/props_phx/cannonball.mdl",1,0,1) end --1 cannonball from cannon
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl"] = function(self,ent) self:AddItem("models/weapons/w_models/w_cannonball.mdl",1,math.fmod(ent:GetSkin(),2),1) end --1 cannonball from TF2 Loose cannon
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl"]
				--CSS
				ScavData.CollectFuncs["models/props/de_inferno/cannon_gun.mdl"] = function(self,ent) self:AddItem("models/props_phx/misc/smallcannonball.mdl",1,0,1) end --1 cannonball from de_inferno cannon
				--L4D/2
				ScavData.CollectFuncs["models/props_unique/airport/atlas.mdl"] = function(self,ent) --1 world from Atlas
					self:AddItem("models/props_unique/airport/atlas.mdl",1,0,1)
					self:AddItem("models/props_unique/airport/atlas_break_ball.mdl",1,0,1)
				end
				--FoF
				ScavData.CollectFuncs["models/weapons/cannon_top.mdl"] = function(self,ent) self:AddItem("models/weapons/cannon_ball.mdl",1,0,1) end --1 cannonball from cannon
			end
			tab.Cooldown = 0.1
			
		ScavData.RegisterFiremode(tab,"models/props_phx/cannonball.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/misc/smallcannonball.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/cannonball_solid.mdl")
		ScavData.RegisterFiremode(tab,"models/dynamite/dynamite.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_cannonball.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lakeside_event/bomb_temp.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lakeside_event/bomb_temp_hat.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_unique/airport/atlas_break_ball.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/weapons/cannon_ball.mdl")



--[[==============================================================================================
	--Conference Call (Crossfire Shotgun)
==============================================================================================]]--
		
		local tab = {}
		tab.Name = "#scav.scavcan.crossfire"
		--tab.anim = ACT_VM_RECOIL3
		tab.anim = ACT_VM_SECONDARYATTACK
		tab.Level = 4
		tab.MaxAmmo = 125
		local bullet = {}
			bullet.Num = 5
			bullet.Spread = Vector(0.0625,0.0625,0)
			bullet.Tracer = 1
			bullet.Force = 4
			bullet.Damage = 5
			bullet.Distance = 56756
			bullet.TracerName = "Tracer" --ef_scav_tr_b throws errors if we use it with penetration
		tab.Callback = function(attacker,tr,dmginfo)
			--bullet penetration
			if IsValid(tr.Entity) and not tr.Entity:IsWorld() then --our bullets don't penetrate the world
				local newbullet = table.Copy(bullet)
					newbullet.Num = 1
					newbullet.IgnoreEntity = tr.Entity
					newbullet.Spread = Vector(0,0,0)
					newbullet.Src = tr.StartPos + tr.Normal * (bullet.Distance * tr.Fraction)
					newbullet.Dir = tr.Normal
					bullet.TracerName = "Tracer" --ef_scav_tr_b throws errors if we use it with penetration
					newbullet.Attacker = attacker
					newbullet.Callback = tab.Callback --strips the splintering code from subsequent bullets
				if SERVER then
					timer.Simple(0.0025,function()
						local startpos = ents.Create("info_null")
						if IsValid(startpos) then
							startpos:SetPos(newbullet.Src)
							startpos:Spawn() --info_null removes itself, so no need for cleanup
							if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
								startpos:FireBullets(newbullet)
							end
						end
					end)
				end
			end
		end
		function tab.OnArmed(self,item,olditemname)
			if SERVER then
				if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
					if item.ammo == "models/props_2fort/telephone001.mdl" or --TF2
							item.ammo == "models/props_spytech/control_room_console01.mdl" or
							item.ammo == "models/props_spytech/control_room_console03.mdl" then
						self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
						timer.Simple(.25,function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
					else --HL2
						self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
					end
				end
			end
		end
		tab.FireFunc = function(self,item)
			self.Owner:ScavViewPunch(Angle(-10,math.Rand(-0.1,0.1),0),0.3)
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self:GetAimVector()
			bullet.Callback = function(attacker,tr,dmginfo)
				tab.Callback(attacker,tr,dmginfo)
				if SERVER then
					--splintering
					local tracep = util.QuickTrace(tr.StartPos,tr.Normal*bullet.Distance,function( ent ) return ( ent:IsWorld() ) end)
					local dist = Vector(tracep.StartPos - tracep.HitPos):LengthSqr()
					local start, interval, max = 160, 32, 4 --distance to travel before starting splintering, interval between splinters, splinter this many times
					if dist >= start then
						for i=0,math.min(max-1,math.floor((dist - start) / interval)) do
							local bullet1 = {}
								bullet1.Num = 1
								bullet1.Attacker = attacker
								bullet1.Spread = Vector(0,0,0)
								bullet1.Tracer = 1
								bullet.TracerName = "Tracer" --ef_scav_tr_b throws errors if we use it with penetration
								bullet1.Force = bullet.Force
								bullet1.Damage = bullet.Damage / 2
								bullet1.Src = tracep.StartPos + tracep.Normal * (start + interval * i + math.random(-1,1))
								bullet1.Dir = tracep.Normal:Angle():Right()
							local bullet2 = table.Copy(bullet1)
								bullet2.Dir = tracep.Normal:Angle():Right() * -1
							timer.Simple(i/100,function() --gotta offset these calls slightly so they can all go through
								local ent = ents.Create("info_null") --this is really gross but if we just use the attacker the tracer draws from the muzzle of the gun instead of its spawn pos
									if IsValid(ent) then
										ent:SetPos(bullet1.Src)
										ent:Spawn() --info_null removes itself, so no need for cleanup
										if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
											ent:FireBullets(bullet1)
										end
									end
							end)
							timer.Simple((i + .5)/100,function()
								local ent = ents.Create("info_null")
									if IsValid(ent) then
										ent:SetPos(bullet2.Src)
										ent:Spawn()
										if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
											ent:FireBullets(bullet2)
										end
									end
							end)
						end
					end
				end
			end
			if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
				self.Owner:FireBullets(bullet)
			end
			self:MuzzleFlash2()
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			if item.ammo == "models/props_2fort/telephone001.mdl" or --TF2
				item.ammo == "models/props_spytech/control_room_console01.mdl" or
				item.ammo == "models/props_spytech/control_room_console03.mdl" then
				if SERVER then
					self.Owner:EmitSound("weapons/shotgun_shoot.wav")
				end
				timer.Simple(0.4,function()
					if SERVER then
						self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
						timer.Simple(.25,function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
					else
						tf2shelleject(self,"shotgun")
					end
				end)
			else --HL2
				if SERVER then
					self.Owner:EmitSound("weapons/shotgun/shotgun_fire6.wav")
				else
					timer.Simple(0.4,function()
						self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
						local ef = EffectData()
						local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
						if attach then
							ef:SetOrigin(attach.Pos)
							ef:SetAngles(attach.Ang)
							ef:SetEntity(self)
							util.Effect("ShotgunShellEject",ef)
						end
					end)
				end
			end
			if SERVER then return self:TakeSubammo(item,1) end
		end
		if SERVER then		
			ScavData.CollectFuncs["models/props_trainstation/payphone001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,ent:GetSkin(),1) end --20 shells from a phone booth
			ScavData.CollectFuncs["models/props_trainstation/payphone_reciever001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),6,ent:GetSkin(),1) end --6 shells from a receiver
			--CSS
			ScavData.CollectFuncs["models/props/cs_office/phone.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin(),1) end -- 10 shells from a telephone
			ScavData.CollectFuncs["models/props/cs_office/phone_p1.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),4,ent:GetSkin(),1) end -- 4 shells from a base
			ScavData.CollectFuncs["models/props/cs_office/phone_p2.mdl"] = ScavData.CollectFuncs["models/props_trainstation/payphone_reciever001a.mdl"]
			ScavData.CollectFuncs["models/props/cs_militia/oldphone01.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone.mdl"]
			ScavData.CollectFuncs["models/props/de_prodigy/desk_console1.mdl"] = ScavData.CollectFuncs["models/props_trainstation/payphone001a.mdl"]
			ScavData.CollectFuncs["models/props/de_prodigy/desk_console1a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),14,ent:GetSkin(),1) end --14 shells from a phone console
			ScavData.CollectFuncs["models/props/de_prodigy/desk_console1b.mdl"] = ScavData.CollectFuncs["models/props_trainstation/payphone_reciever001a.mdl"]
			--Ep2
			ScavData.CollectFuncs["models/props_silo/desk_console1.mdl"] = ScavData.CollectFuncs["models/props/de_prodigy/desk_console1.mdl"]
			ScavData.CollectFuncs["models/props_silo/desk_console1a.mdl"] = ScavData.CollectFuncs["models/props/de_prodigy/desk_console1a.mdl"]
			ScavData.CollectFuncs["models/props_silo/desk_console1b.mdl"] = ScavData.CollectFuncs["models/props/de_prodigy/desk_console1b.mdl"]
			--TF2
			ScavData.CollectFuncs["models/props_2fort/telephone001.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone.mdl"]
			ScavData.CollectFuncs["models/props_spytech/control_room_console01.mdl"] = ScavData.CollectFuncs["models/props_trainstation/payphone001a.mdl"]
			ScavData.CollectFuncs["models/props_spytech/control_room_console03.mdl"] = ScavData.CollectFuncs["models/props_trainstation/payphone001a.mdl"]
			--Portal
			ScavData.CollectFuncs["models/props_bts/phone_body.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone_p1.mdl"]
			ScavData.CollectFuncs["models/props_bts/phone_reciever.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone_p2.mdl"]
			--L4D/2
			ScavData.CollectFuncs["models/props_interiors/phone.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone.mdl"]
			ScavData.CollectFuncs["models/props_interiors/phone_p1.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone_p1.mdl"]
			ScavData.CollectFuncs["models/props_interiors/phone_p2.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone_p2.mdl"]
			ScavData.CollectFuncs["models/props_interiors/phone_motel.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone.mdl"]
			ScavData.CollectFuncs["models/props_equipment/phone_booth.mdl"] = ScavData.CollectFuncs["models/props_trainstation/payphone001a.mdl"]
			ScavData.CollectFuncs["models/props_equipment/phone_booth_indoor.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone.mdl"]
			ScavData.CollectFuncs["models/props_unique/airport/phone_booth_airport.mdl"] = ScavData.CollectFuncs["models/props_trainstation/payphone001a.mdl"]
			ScavData.CollectFuncs["models/props_junk/garbage_cellphone01a.mdl"] = ScavData.CollectFuncs["models/props/cs_office/phone_p2.mdl"]
		end
		tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/props_trainstation/payphone001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_trainstation/payphone_reciever001a.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_office/phone.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/phone_p1.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/phone_p2.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_militia/oldphone01.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_prodigy/desk_console1.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_prodigy/desk_console1a.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_prodigy/desk_console1b.mdl")
		--Ep2
		ScavData.RegisterFiremode(tab,"models/props_silo/desk_console1.mdl")
		ScavData.RegisterFiremode(tab,"models/props_silo/desk_console1a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_silo/desk_console1b.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/props_2fort/telephone001.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/control_room_console01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/control_room_console03.mdl")
		--Portal
		ScavData.RegisterFiremode(tab,"models/props_bts/phone_body.mdl")
		ScavData.RegisterFiremode(tab,"models/props_bts/phone_reciever.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_interiors/phone.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/phone_p1.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/phone_p2.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/phone_motel.mdl")
		ScavData.RegisterFiremode(tab,"models/props_equipment/phone_booth.mdl")
		ScavData.RegisterFiremode(tab,"models/props_equipment/phone_booth_indoor.mdl")
		ScavData.RegisterFiremode(tab,"models/props_unique/airport/phone_booth_airport.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_cellphone01a.mdl")


--[[==============================================================================================
	--Grappling Beam
==============================================================================================]]--
 

		local tab = {}
			tab.Name = "#scav.scavcan.grapple"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 3
			tab.chargeanim = ACT_VM_FIDGET
			tab.RemoveOnCharge = false
			tab.Cooldown = 0.1
			if SERVER then
				hook.Add("PlayerDeath","scv_cleargrapple",function(pl) if pl.GrappleAssist and IsValid(pl.GrappleAssist) then pl.GrappleAssist:Remove() end end)
				tab.ChargeAttack = function(self,item)
					local tab = ScavData.models["models/props_wasteland/cranemagnet01a.mdl"]
					if self.grapplenohit then
						self.grapplenohit = nil
						if IsValid(self.ef_grapplebeam) then
							self.ef_grapplebeam:Kill()
						end
						self:SetChargeAttack()
						tab.chargeanim = ACT_VM_IDLE
						return 0.5
					end
					if not self.Owner:KeyDown(IN_ATTACK) or not IsValid(self.GrappleAssist) then --let go
						--local eyeang = self.Owner:EyeAngles()
						--eyeang.r = 0
						self:SetChargeAttack()
						tab.chargeanim = ACT_VM_PRIMARYATTACK
						if IsValid(self.ef_grapplebeam) then
							self.ef_grapplebeam:Kill()
						end
						self.Owner:SetMoveType(MOVETYPE_WALK)
						if IsValid(self.GrappleAssist) then
							local vel = self.GrappleAssist:GetVelocity()
							--vel.x = vel.x*16
							--vel.y = vel.y*16
							if vel.z < 0 then
								vel.z = 0
							end
							local length = math.max(vel:Length(),200)
							self.Owner:SetVelocity(vel:GetNormalized()*length)
							self.GrappleAssist:Remove()
							self:SetNWFiremodeEnt(NULL)
						--else
						
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
						
						if self.GrappleAssistConstraint and IsValid(self.GrappleAssistConstraint) then
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
					self:SetChargeAttack(ScavData.models["models/props_wasteland/cranemagnet01a.mdl"].ChargeAttack,item)
					if tr.Hit and ((tr.MatType == MAT_METAL) or (tr.MatType == MAT_GRATE)) then
						if not IsValid(tr.Entity) then
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
							--self.GrappleAssist:SetAngles(self.Owner:GetAngles())
							self.GrappleAssist:Spawn()
							self:SetNWFiremodeEnt(self.GrappleAssist)
							self.GrappleAssist:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
							self.GrappleAssist:GetPhysicsObject():SetDamping(0,9000)
							self.GrappleAssist:GetPhysicsObject():SetMaterial("gmod_silent")
							self.GrappleAssist:SetNoDraw(true)
							self.GrappleAssist:DrawShadow(false)
							self.GrappleAssist.NoScav = true
							self.GrappleAssist.AvgVel = {}
							--self.GrappleAssist:GetPhysicsObject():SetDragCoefficient(10) --keep it from going too fast
							self.GrappleAssist:GetPhysicsObject():SetMass(85) --keep it from being wobbly
						self.Owner:SetMoveType(MOVETYPE_VPHYSICS)
						self.Owner:SetParent(self.GrappleAssist)
						self.Owner:SetLocalPos(vector_origin)
						self.Owner:SetLocalAngles(Angle(0,0,0))
						local constr,rope = constraint.Elastic(self.GrappleAssist,tr.Entity,0,0,Vector(0,0,72),tr.HitPos-tr.Entity:GetPos(),99999,50,0,"cable/physbeam",0,false)
						--self.GrappleTargetLength = math.min((self.GrappleAssist:GetPos()+Vector(0,0,72)):Distance(tr.HitPos),150)
						self.GrappleTargetLength = 200
						self.GrappleAssistConstraint = constr
						--self.Owner:SnapEyeAngles(eyeang)
						--print(constr:GetClass())
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
			ScavData.CollectFuncs["models/infected/smoker.mdl"] = ScavData.CollectFuncs["models/props_wasteland/cranemagnet01a.mdl"]
			ScavData.CollectFuncs["models/infected/smoker_tongue_attach.mdl"] = ScavData.CollectFuncs["models/infected/smoker.mdl"]
			else
				tab.ChargeAttack = function(self,item)
				local tab = ScavData.models["models/props_wasteland/cranemagnet01a.mdl"]
					local par = self:GetNWFiremodeEnt()
					if not self.Owner:KeyDown(IN_ATTACK) then
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self:SetChargeAttack()
						--self.WeaponCharge = 0
						tab.chargeanim = ACT_VM_PRIMARYATTACK
						if IsValid(par) then
							self:SetViewLerp(EyeAngles(),0.3)
							local ang = self:GetAimVector():Angle()
							ang.r = 0
							self.Owner:SetEyeAngles(ang)
						end
						return 0.25
					elseif IsValid(par) then
						--self.WeaponCharge = self.WeaponCharge+0.2
						tab.chargeanim = ACT_VM_FIDGET
					else
						tab.chargeanim = nil
					end
					return 0.01
				end
				tab.FireFunc = function(self,item)
					self:SetChargeAttack(ScavData.models["models/props_wasteland/cranemagnet01a.mdl"].ChargeAttack,item)
					return false
				end
			end
			
			concommand.Add("+sgrapdown",function(pl,cmd,args) pl.scavGoDown = true end)
			concommand.Add("-sgrapdown",function(pl,cmd,args) pl.scavGoDown = false end)
			
			if CLIENT then
				hook.Add("PlayerBindPress","scavgrap",function(pl,bind,pressed)
					local ent = pl:GetParent()
					if (bind == "+duck") and IsValid(ent) and (ent:GetClass() == "scav_grappleassist") then
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
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/infected/smoker.mdl")
		ScavData.RegisterFiremode(tab,"models/infected/smoker_tongue_attach.mdl")
		


--[[==============================================================================================
	--Supersonic Shockwave
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.sonicblast"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self,item)
					local proj = self:CreateEnt("scav_projectile_shockwave")
					proj.Owner = self.Owner
					proj:SetPos(self:GetProjectileShootPos())
					--proj:SetPos(self.Owner:GetShootPos()-self:GetAimVector()*15+self:GetAimVector():Angle():Right()*6-self:GetAimVector():Angle():Up()*8)
					proj:SetAngles(self:GetAimVector():Angle())
					proj.vel = self:GetAimVector()*2500
					proj:SetOwner(self.Owner)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
					if item.ammo == "models/props/food_can/food_can.mdl" or  --this one's just for you, Anya
						item.ammo == "models/props_junk/garbage_beancan01a.mdl" or
						item.ammo == "models/props_junk/garbage_beancan01a_fullsheet.mdl" then
						local drop = self:GetProjectileShootPos()
						drop.z = drop.z - 12
						proj:SetPos(drop)
						proj.vel = self:GetAimVector()*-250
						self.Owner:EmitSound("ambient/explosions/explode_9.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("ambient/explosions/explode_9.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("npc/antlion_guard/shove1.wav",75,100,0.5,CHAN_WEAPONS,SND_NOFLAGS,0)
					elseif item.ammo == "models/props/de_inferno/bell_large.mdl" or
							item.ammo == "models/props/de_inferno/bell_largeb.mdl" or
							item.ammo == "models/props/de_inferno/bell_small.mdl" or
							item.ammo == "models/props/de_inferno/bell_smallb.mdl" then
						self.Owner:EmitSound("ambient/explosions/explode_9.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("ambient/misc/brass_bell_c.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
					elseif item.ammo == "models/props_italian/anzio_bell.mdl" then
						self.Owner:EmitSound("ambient/explosions/explode_9.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("physics/bigbell.wav",75,100,0.66,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
					elseif item.ammo == "models/monastery/bell_large.mdl" then
						self.Owner:EmitSound("ambient/explosions/explode_9.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("monastery/bell.wav",75,100,0.66,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
					else
						self.Owner:EmitSound("ambient/explosions/explode_9.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("ambient/explosions/explode_9.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
						self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav",75,100,0.33,CHAN_WEAPONS,SND_NOFLAGS,0)
					end
					proj:Spawn()
					return self:TakeSubammo(item,1)
				end
				ScavData.CollectFuncs["models/props_phx/misc/fender.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_lab/citizenradio.mdl"] = ScavData.CollectFuncs["models/props_phx/misc/fender.mdl"]
				ScavData.CollectFuncs["models/props_c17/canister01a.mdl"] = ScavData.CollectFuncs["models/props_lab/citizenradio.mdl"]
				ScavData.CollectFuncs["models/props_c17/canister02a.mdl"] = ScavData.CollectFuncs["models/props_lab/citizenradio.mdl"]
				ScavData.CollectFuncs["models/props_wasteland/speakercluster01a.mdl"] = ScavData.CollectFuncs["models/props_lab/citizenradio.mdl"]
				--CSS
				ScavData.CollectFuncs["models/props/cs_office/radio.mdl"] = ScavData.CollectFuncs["models/props_lab/citizenradio.mdl"]
				ScavData.CollectFuncs["models/props/cs_office/radio_p1.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/props/de_inferno/bell_large.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/props/de_inferno/bell_largeb.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/bell_large.mdl"]
				ScavData.CollectFuncs["models/props/de_inferno/bell_small.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/bell_large.mdl"]
				ScavData.CollectFuncs["models/props/de_inferno/bell_smallb.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/bell_small.mdl"]
				--DoD:S
				ScavData.CollectFuncs["models/props_italian/anzio_bell.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/bell_large.mdl"]
				ScavData.CollectFuncs["models/props_italian/gramophone.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				--FoF
				ScavData.CollectFuncs["models/monastery/bell_large.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/bell_large.mdl"]
				--Portal
				ScavData.CollectFuncs["models/props/radio_reference.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/props/food_can/food_can.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,0) end
				--TF2
				ScavData.CollectFuncs["models/props_2fort/propane_tank_tall01.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/props_spytech/fire_bell01.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/props_spytech/fire_bell02.mdl"] = ScavData.CollectFuncs["models/props_spytech/fire_bell01.mdl"]
				ScavData.CollectFuncs["models/props_spytech/siren001.mdl"] = ScavData.CollectFuncs["models/props_spytech/fire_bell01.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bugle/c_bugle.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_bugle/c_bugle.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_shogun_warhorn/c_shogun_warhorn.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_bugle/c_bugle.mdl"]
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_shogun_warhorn/c_shogun_warhorn.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_shogun_warhorn/c_shogun_warhorn.mdl"]
				--L4D2
				ScavData.CollectFuncs["models/props_fairgrounds/amp_plexi.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
				ScavData.CollectFuncs["models/props_fairgrounds/amp_stack.mdl"] = ScavData.CollectFuncs["models/props_fairgrounds/amp_plexi.mdl"]
				ScavData.CollectFuncs["models/props_fairgrounds/amp_stack_small.mdl"] = ScavData.CollectFuncs["models/props_fairgrounds/amp_plexi.mdl"]
				ScavData.CollectFuncs["models/props_fairgrounds/front_speaker.mdl"] = ScavData.CollectFuncs["models/props_fairgrounds/amp_plexi.mdl"]
				ScavData.CollectFuncs["models/props_fairgrounds/monitor_speaker.mdl"] = ScavData.CollectFuncs["models/props_fairgrounds/amp_plexi.mdl"]
				ScavData.CollectFuncs["models/props_fairgrounds/bass_amp.mdl"] = ScavData.CollectFuncs["models/props_fairgrounds/amp_plexi.mdl"]
				ScavData.CollectFuncs["models/props_unique/jukebox01_body.mdl"] = ScavData.CollectFuncs["models/props_fairgrounds/amp_plexi.mdl"]
				ScavData.CollectFuncs["models/weapons/melee/w_electric_guitar.mdl"] = ScavData.CollectFuncs["models/props_fairgrounds/amp_plexi.mdl"]
				ScavData.CollectFuncs["models/props_fairgrounds/strongmangame_bell.mdl"] = ScavData.CollectFuncs["models/props_spytech/fire_bell01.mdl"]
				ScavData.CollectFuncs["models/props_junk/garbage_beancan01a.mdl"] = ScavData.CollectFuncs["models/props/food_can/food_can.mdl"]
				ScavData.CollectFuncs["models/props_junk/garbage_beancan01a_fullsheet.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_beancan01a.mdl"]
				--HL:S
				ScavData.CollectFuncs["models/houndeye.mdl"] = ScavData.CollectFuncs["models/props/cs_office/radio.mdl"]
			end
			tab.Cooldown = 0.75
			
		ScavData.RegisterFiremode(tab,"models/props_phx/misc/fender.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/canister01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/canister02a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/citizenradio.mdl")
		ScavData.RegisterFiremode(tab,"models/props_wasteland/speakercluster01a.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_office/radio.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_office/radio_p1.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_inferno/bell_large.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_inferno/bell_largeb.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_inferno/bell_small.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_inferno/bell_smallb.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/props_italian/anzio_bell.mdl")
		ScavData.RegisterFiremode(tab,"models/props_italian/gramophone.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/monastery/bell_large.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/amp_plexi.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/amp_stack.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/amp_stack_small.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/bass_amp.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/front_speaker.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/monitor_speaker.mdl")
		ScavData.RegisterFiremode(tab,"models/props_unique/jukebox01_body.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/melee/w_electric_guitar.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/strongmangame_bell.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_beancan01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_beancan01a_fullsheet.mdl")
		--Portal
		ScavData.RegisterFiremode(tab,"models/props/radio_reference.mdl")
		ScavData.RegisterFiremode(tab,"models/props/food_can/food_can.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/props_2fort/propane_tank_tall01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/fire_bell01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/fire_bell02.mdl")
		ScavData.RegisterFiremode(tab,"models/props_spytech/siren001.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_bugle/c_bugle.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_shogun_warhorn/c_shogun_warhorn.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_shogun_warhorn/c_shogun_warhorn.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab,"models/houndeye.mdl")

--[[==============================================================================================
	--Disease Shot
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.disease"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self,item)
					local proj = self:CreateEnt("scav_projectile_bio")
						proj.Owner = self.Owner
						proj:SetPos(self:GetProjectileShootPos())
						--proj:SetPos(self.Owner:GetShootPos()-self:GetAimVector()*15+self:GetAimVector():Angle():Right()*6-self:GetAimVector():Angle():Up()*8)
						proj:SetAngles(self:GetAimVector():Angle())
						proj.vel = self:GetAimVector()*2500
						proj.SpeedScale = self:GetForceScale()
						proj:SetOwner(self.Owner)
						proj:Spawn()
					--TODO: Eh, figure this out later
					--if item.ammo == "models/weapons/c_models/urinejar.mdl" or item.ammo = "models/weapons/c_models/c_xms_urinejar.mdl" then
					--	proj:SetMaterial("models/shiny")
					--	proj:SetColor(240,220,50,255)
					--end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4,-3),math.Rand(-0.1,0.1),0))
					return self:TakeSubammo(item,1)
				end
				ScavData.CollectFuncs["models/zombie/poison.mdl"] = function(self,ent)
					self:AddItem("models/headcrabblack.mdl",ent:GetBodygroup(1)+ent:GetBodygroup(2)+ent:GetBodygroup(3)+ent:GetBodygroup(4),0)
					self:AddItem("models/zombie/poison.mdl",1,0,1)
				end
				ScavData.CollectFuncs["models/player/corpse1.mdl"] = function(self,ent) self:AddItem("models/humans/corpse1.mdl",1,0,1) end --playermodel conversion
				--CSS
				ScavData.CollectFuncs["models/props/de_train/biohazardtank.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props/cs_militia/toilet.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props/cs_militia/urine_trough.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),2,ent:GetSkin()) end
				--TF2
				ScavData.CollectFuncs["models/props_badlands/barrel01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),2,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_hydro/water_barrel_cluster2.mdl"] = function(self,ent) self:AddItem("models/props_badlands/barrel01.mdl",2,0,8) end --eight barrels from the clusters
				ScavData.CollectFuncs["models/props_hydro/water_barrel_cluster3.mdl"] = function(self,ent) self:AddItem("models/props_badlands/barrel01.mdl",2,0,8) end --eight barrels from the clusters
				ScavData.CollectFuncs["models/weapons/c_models/urinejar.mdl"] = function(self,ent)
					if self.christmas then
						self:AddItem("models/weapons/c_models/c_xms_urinejar.mdl",1,math.floor(math.Rand(0,2)),1)
					else
						self:AddItem("models/weapons/c_models/urinejar.mdl",1,0,1)
					end
				end
				--L4D/2
				ScavData.CollectFuncs["models/infected/boomer.mdl"] = function(self,ent)
					if IsMounted(550) then --L4D2
						self:AddItem("models/w_models/weapons/w_eq_bile_flask.mdl",1,0,3) --three boomer biles from a boomer/boomette
					else
						self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,0,3)
					end
				end
				ScavData.CollectFuncs["models/props_debris/dead_cow_smallpile.mdl"] = function(self,ent) self:AddItem("models/props_debris/dead_cow.mdl",1,ent:GetSkin(),4) end
				ScavData.CollectFuncs["models/infected/boomer_l4d1.mdl"] = ScavData.CollectFuncs["models/infected/boomer.mdl"]
				ScavData.CollectFuncs["models/infected/boomette.mdl"] = ScavData.CollectFuncs["models/infected/boomer.mdl"]
				ScavData.CollectFuncs["models/props_urban/outhouse001.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),3,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_urban/outhouse002.mdl"] = ScavData.CollectFuncs["models/props_urban/outhouse001.mdl"]
			end
			tab.Cooldown = 1
			
		ScavData.RegisterFiremode(tab,"models/headcrabblack.mdl")
		ScavData.RegisterFiremode(tab,"models/humans/corpse1.mdl") --reference to a Dark RP Hobo job I saw years ago
		ScavData.RegisterFiremode(tab,"models/props_lab/jar01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/jar01b.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/de_train/biohazardtank.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_militia/toilet.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_militia/urine_trough.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/props_badlands/barrel01.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/urinejar.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_xms_urinejar.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_breadmonster/c_breadmonster.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_breadmonster/c_breadmonster_milk.mdl")
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_plague.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/infected/boomer.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_eq_bile_flask.mdl")
		ScavData.RegisterFiremode(tab,"models/props_debris/dead_cow.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/pooh_bucket_01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/toilet_c.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/toilet_d.mdl")
		ScavData.RegisterFiremode(tab,"models/props_urban/outhouse001.mdl")
		ScavData.RegisterFiremode(tab,"models/props_urban/outhouse002.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/elpaso/horse_poo.mdl")
		
--[[==============================================================================================
	--sniper rifle
==============================================================================================]]--

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
			tab.Name = "#scav.scavcan.sniper"
			tab.anim = ACT_VM_IDLE
			tab.Level = 6
			tab.MaxAmmo = 25
			tab.Cooldown = 0.01
			tab.fov = 5
			function tab.ChargeAttack(self,item)
				if CurTime()-self.sniperzoomstart > 0.5 then
					self:SetZoomed(true)
					hook.Add("AdjustMouseSensitivity","ScavZoomedIn", function()
						return ScavData.models[self:GetCurrentItem().ammo].fov / GetConVar("fov_desired"):GetFloat()
					end)
					if CLIENT then
						hook.Add( "RenderScreenspaceEffects","ScavScope", function()
							DrawMaterialOverlay( "effects/combine_binocoverlay", 0.02 )
						end )
					end
					if self.Owner:KeyDown(IN_ATTACK2) then --let the player cancel the scope with Mouse2
						self:SetZoomed(false)
						hook.Remove("AdjustMouseSensitivity","ScavZoomedIn")
						if CLIENT then
							hook.Remove("RenderScreenspaceEffects","ScavScope")
						end
						return 0.05
					end
				end
				if not self.Owner:KeyDown(IN_ATTACK) then
					if CurTime()-self.sniperzoomstart <= 0.5 or not self.Owner:KeyDown(IN_ATTACK2) then
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
							self.Owner:FireBullets(bullet)
						end
						timer.Simple(.45,function()
							if IsValid(self) then
								local ef = EffectData()
								local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
								if attach then
									ef:SetOrigin(attach.Pos)
									ef:SetAngles(attach.Ang)
									ef:SetEntity(self)
									if item.ammo == "models/weapons/rifleshell.mdl" or
										item.ammo == "models/weapons/w_combine_sniper.mdl" then
										if SERVER then
											self:EmitSound("weapons/smg1/switch_burst.wav",75,100,1)
										else
											util.Effect("RifleShellEject",ef)
										end
									else
										if SERVER then
											self:EmitSound("weapons/sniper_bolt_back.wav",75,100,1)
											timer.Simple(.25,function() self.Owner:EmitSound("weapons/sniper_bolt_forward.wav") end)
										else
											tf2shelleject(self,"sniperrifle")
										end
									end
								end
							end
						end)
						if SERVER then
							self:TakeSubammo(item,1)
							if item.ammo == "models/weapons/rifleshell.mdl" or
											"models/weapons/w_combine_sniper.mdl" then
								self.Owner:EmitSound("NPC_Sniper.FireBullet")
							elseif SERVER then
								if self.Owner:GetStatusEffect("DamageX") then
									self.Owner:EmitSound("weapons/sniper_shoot_crit.wav") --crit sound
								else
									self.Owner:EmitSound("weapons/sniper_shoot.wav")
								end
							end
						end
						self:SetChargeAttack()
					end
					if SERVER then
						if IsValid(self.ef_lsight) then
							self.ef_lsight:Kill()
						end
						if (item.subammo <= 0) then
							self:RemoveItemValue(item)
						end
					end
					self:SetZoomed(false)
					hook.Remove("AdjustMouseSensitivity","ScavZoomedIn")
					if CLIENT then
						hook.Remove("RenderScreenspaceEffects","ScavScope")
					end
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
				ScavData.CollectFuncs["models/weapons/shells/shell_sniperrifle.mdl"] = function(self,ent) self:AddItem("models/weapons/rifleshell.mdl",1,0,1) end
				--Ep2
				ScavData.CollectFuncs["models/weapons/w_combine_sniper.mdl"] = function(self,ent) self:AddItem("models/weapons/w_combine_sniper.mdl",5,0,1) end
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bazaar_sniper/c_bazaar_sniper.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_bazaar_sniper/c_bazaar_sniper.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_invasion_sniperrifle/c_invasion_sniperrifle.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sniperrifle.mdl"]
			end
			ScavData.RegisterFiremode(tab,"models/weapons/rifleshell.mdl")
			--Ep2
			ScavData.RegisterFiremode(tab,"models/weapons/w_combine_sniper.mdl")
			--TF2
			ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_sniperrifle.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_bazaar_sniper/c_bazaar_sniper.mdl")
			ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_bazaar_sniper/c_bazaar_sniper.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl")
			ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl")
			ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl")
			ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_invasion_sniperrifle/c_invasion_sniperrifle.mdl")
		end
		

--[[==============================================================================================
	-- Combine Binoculars
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.binoculars"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.fov = 2
			local zoomhook = function()
				hook.Add("AdjustMouseSensitivity","ScavZoomedIn", function()
					return tab.fov / GetConVar("fov_desired"):GetFloat()
				end)
			end
			tab.FireFunc = function(self,item)
				if not self:GetZoomed() then
					tab.fov = 10
					self:SetZoomed(true)
					zoomhook()
				elseif tab.fov == 10 then
					tab.fov = 5
					zoomhook()
				elseif tab.fov == 5 then
					tab.fov = 2
					zoomhook()
				elseif tab.fov == 2 then
					tab.fov = 1
					zoomhook()
				elseif tab.fov == 1 then
					tab.fov = 10
					self:SetZoomed(false)
					hook.Remove("AdjustMouseSensitivity","ScavZoomedIn")
				end
				self.Owner:EmitSound("buttons/lightswitch2.wav")
			end
			tab.PostRemove = function(self,item)
				if CLIENT then
					tab.fov = GetConVar("fov_desired"):GetFloat()
				else
					tab.fov = 90
				end
				self:SetZoomed(false)
				hook.Remove("AdjustMouseSensitivity","ScavZoomedIn")
			end
			tab.Cooldown = 0.25
			if SERVER then
				ScavData.CollectFuncs["models/props_combine/combine_binocular01.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/props_c17/light_magnifyinglamp02.mdl"] = ScavData.GiveOneOfItemInf
			end
			ScavData.RegisterFiremode(tab,"models/props_combine/combine_binocular01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_c17/light_magnifyinglamp02.mdl")
		
--[[==============================================================================================
	-- Medkits
==============================================================================================]]--
	
		medkit = {
			["models/healthvial.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+10))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2
			end,
			["models/items/medkit_small.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+healent:GetMaxHealth()*0.205)) --20.5%
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2
			end,
			["models/items/medkit_small_bday.mdl"] = function(healent) return medkit["models/items/medkit_small.mdl"](healent) end,
			["models/props_halloween/halloween_medkit_small.mdl"] = function(healent) return medkit["models/items/medkit_small.mdl"](healent) end,
			["models/items/medkit_medium.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+healent:GetMaxHealth()*0.5))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2
			end,
			["models/items/medkit_medium_bday.mdl"] = function(healent) return medkit["models/items/medkit_medium.mdl"](healent) end,
			["models/props_halloween/halloween_medkit_medium.mdl"] = function(healent) return medkit["models/items/medkit_medium.mdl"](healent) end,
			["models/items/medkit_large.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(healent:GetMaxHealth())
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2
			end,
			["models/items/medkit_large_bday.mdl"] = function(healent) return medkit["models/items/medkit_large.mdl"](healent) end,
			["models/props_halloween/halloween_medkit_large.mdl"] = function(healent) return medkit["models/items/medkit_large.mdl"](healent) end,
			["models/w_models/weapons/w_eq_medkit.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+math.max(1,math.floor((healent:GetMaxHealth()-healent:Health())*0.8)))) --heal 80% of our current damage (or at least 1 health)
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2
			end,
			["models/w_models/weapons/w_eq_defibrillator.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+50)) --TODO: Make this revive?
					healent:EmitSound("weapons/defibrillator/defibrillator_use.wav")
				end
				return 2
			end,
			["models/grub_nugget_large.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+6))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return .5
			end,
			["models/grub_nugget_medium.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+4))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return .5
			end,
			["models/grub_nugget_small.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+1))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return .5
			end,
			["models/items/personalmedkit/personalmedkit.mdl"] = function(healent)
				if SERVER and IsValid(healent) then
					healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+50))
					healent:InflictStatusEffect("Disease",-5,1)
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2
			end,
		}

		local tab = {}
			tab.Name = "#weapon_medkit"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.MaxAmmo = 4
			tab.vmin = Vector(-12,-12,-12)
			tab.vmax = Vector(12,12,12)
			tab.FireFunc = function(self,item)
				local healent = self.Owner
				--local tab = ScavData.models[self.inv.items[1].ammo]
				local tracep = {}
				tracep.start = self.Owner:GetShootPos()
				tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*100
				tracep.filter = self.Owner
				tracep.mask = MASK_SHOT
				tracep.mins = tab.vmin
				tracep.maxs = tab.vmax
				local tr = util.TraceHull(tracep)
				if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) and tr.Entity.Health and tr.Entity.GetMaxHealth and tr.Entity.SetHealth and tr.Entity:GetMaxHealth() > 0 and (tr.Entity:Health() < tr.Entity:GetMaxHealth()) then
					healent = tr.Entity
				end
				if healent:Health() >= healent:GetMaxHealth() then
					if SERVER then
						healent:EmitSound("buttons/button11.wav")
					end
					tab.Cooldown = 0.2
					return false
				end
				local starthealth = healent:Health()

				if medkit[item.ammo] == nil then
					if SERVER then
						healent:SetHealth(math.min(healent:GetMaxHealth(),healent:Health()+25))
						healent:EmitSound("items/smallmedkit1.wav")
					end
					tab.Cooldown = 2
				else
					tab.Cooldown = medkit[item.ammo](healent)
				end
				local ef = EffectData()
				ef:SetRadius(math.max(2,healent:Health()-starthealth))
				ef:SetOrigin(self.Owner:GetPos())
				ef:SetScale(self.Owner:EntIndex())
				ef:SetEntity(healent)
				util.Effect("ef_scav_heal",ef,nil,true)
				if SERVER then
					return self:TakeSubammo(item,1)
				end
			end
			if SERVER then
				--Ep2
				ScavData.CollectFuncs["models/antlion_grub_squashed.mdl"] = function(self,ent)
					local healthratio = self.Owner:Health() / self.Owner:GetMaxHealth()
					if healthratio > .9 then
						self:AddItem("models/grub_nugget_small.mdl",1,0,1)
					elseif healthratio > .7 then
						self:AddItem("models/grub_nugget_medium.mdl",1,0,1)
					else
						self:AddItem("models/grub_nugget_large.mdl",1,0,1)
					end
					self.Owner:EmitSound("npc/antlion_grub/agrub_idle6.wav")
					self.Owner:EmitSound("npc/antlion_grub/agrub_squish2.wav")
				end
				--TF2
				ScavData.CollectFuncs["models/items/medkit_small.mdl"] = function(self,ent)
					if self.halloween then
						self:AddItem("models/props_halloween/halloween_medkit_small.mdl",1,0,1)
					else
						self:AddItem("models/items/medkit_small.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/items/medkit_medium.mdl"] = function(self,ent)
					if self.halloween then
						self:AddItem("models/props_halloween/halloween_medkit_medium.mdl",1,0,1)
					else
						self:AddItem("models/items/medkit_medium.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/items/medkit_large.mdl"] = function(self,ent)
					if self.halloween then
						self:AddItem("models/props_halloween/halloween_medkit_large.mdl",1,0,1)
					else
						self:AddItem("models/items/medkit_large.mdl",1,0,1)
					end
				end
				--L4D/2
				ScavData.CollectFuncs["models/w_models/weapons/w_eq_defibrillator_no_paddles.mdl"] = function(self,ent) self:AddItem("models/w_models/weapons/w_eq_defibrillator.mdl",1,0,1) end
				--HLS
				ScavData.CollectFuncs["models/scientist.mdl"] = function(self,ent) self:AddItem("models/w_medkit.mdl",1,0,1) end
			end
		ScavData.RegisterFiremode(tab,"models/items/healthkit.mdl")
		ScavData.RegisterFiremode(tab,"models/healthvial.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/items/medkit_small.mdl")
		ScavData.RegisterFiremode(tab,"models/items/medkit_small_bday.mdl")
		ScavData.RegisterFiremode(tab,"models/props_halloween/halloween_medkit_small.mdl")
		ScavData.RegisterFiremode(tab,"models/items/medkit_medium.mdl")
		ScavData.RegisterFiremode(tab,"models/items/medkit_medium_bday.mdl")
		ScavData.RegisterFiremode(tab,"models/props_halloween/halloween_medkit_medium.mdl")
		ScavData.RegisterFiremode(tab,"models/items/medkit_large.mdl")
		ScavData.RegisterFiremode(tab,"models/items/medkit_large_bday.mdl")
		ScavData.RegisterFiremode(tab,"models/props_halloween/halloween_medkit_large.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_eq_medkit.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_eq_defibrillator.mdl")
		--Ep2
		ScavData.RegisterFiremode(tab,"models/grub_nugget_large.mdl")
		ScavData.RegisterFiremode(tab,"models/grub_nugget_medium.mdl")
		ScavData.RegisterFiremode(tab,"models/grub_nugget_small.mdl")
		--HLS
		ScavData.RegisterFiremode(tab,"models/w_medkit.mdl")
		--ASW
		ScavData.RegisterFiremode(tab,"models/items/personalmedkit/personalmedkit.mdl")

--[[==============================================================================================
	-- Pain Pills (temporary health)
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.pills"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.MaxAmmo = 3
			tab.vmin = Vector(-12,-12,-12)
			tab.vmax = Vector(12,12,12)
			tab.FireFunc = function(self,item)
				local healent = self.Owner
				--local tab = ScavData.models[self.inv.items[1].ammo]
				local tracep = {}
				tracep.start = self.Owner:GetShootPos()
				tracep.endpos = self.Owner:GetShootPos()+self:GetAimVector()*100
				tracep.filter = self.Owner
				tracep.mask = MASK_SHOT
				tracep.mins = tab.vmin
				tracep.maxs = tab.vmax
				local tr = util.TraceHull(tracep)
				if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) and tr.Entity.Health and tr.Entity.GetMaxHealth and tr.Entity.SetHealth and tr.Entity:GetMaxHealth() > 0 and (tr.Entity:Health() < tr.Entity:GetMaxHealth()) then
					healent = tr.Entity
				end
				if healent:Health() >= healent:GetMaxHealth() then
					if SERVER then
						healent:EmitSound("buttons/button11.wav")
					end
					tab.Cooldown = 0.2
					return false
				end
				local starthealth = healent:Health()

				if healent:GetStatusEffect("TemporaryHealth") then
					if SERVER then
						healent:EmitSound("buttons/button11.wav")
					end
					tab.Cooldown = 0.2
					return false
				elseif SERVER then
					healent:InflictStatusEffect("TemporaryHealth",50,1)
				end
				if SERVER then
					if IsMounted(550) or IsMounted(500) then --L4D2 or L4D
						healent:EmitSound("player/items/pain_pills/pills_deploy_1.wav")
					else
						healent:EmitSound("weapons/smg1/switch_burst.wav",75,180,1)
					end
				end
				
				local ef = EffectData()
				ef:SetRadius(math.max(2,healent:Health()-starthealth))
				ef:SetOrigin(self.Owner:GetPos())
				ef:SetScale(self.Owner:EntIndex())
				ef:SetEntity(healent)
				util.Effect("ef_scav_heal",ef,nil,true)
				tab.Cooldown = 1
				if SERVER then
					return self:TakeSubammo(item,1)
				end
			end
			if SERVER then
				--L4D/2
				ScavData.CollectFuncs["models/survivors/survivor_manager.mdl"] = function(self,ent)
					self:AddItem("models/w_models/weapons/w_eq_painpills.mdl",1,0,3)
					self.Owner:EmitSound("player/survivor/voice/manager/takepills02.wav",75,100,1,CHAN_VOICE)
				end --3 pills from Louis (ahehe)
			end
		ScavData.RegisterFiremode(tab,"models/scav/pill_bottle.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_eq_painpills.mdl")

--[[==============================================================================================
	-- Blast Shower
==============================================================================================]]--

		local tab = {}
			tab.Name = "#scav.scavcan.shower"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.MaxAmmo = 30

			local toFloat = function(a_bool) return a_bool and 1 or 0 end
			PrecacheParticleSystem("water_splash_01_droplets")
				tab.ChargeAttack = function(self,item)
					local totalStatuses =	toFloat(self.Owner:GetStatusEffect("Slow")) +
											toFloat(self.Owner:GetStatusEffect("Frozen")) +
											toFloat(self.Owner:GetStatusEffect("Disease")) +
											toFloat(self.Owner:GetStatusEffect("Burning")) +
											toFloat(self.Owner:GetStatusEffect("Acid Burning")) +
											toFloat(self.Owner:GetStatusEffect("Shock")) +
											toFloat(self.Owner:GetStatusEffect("Radiation")) +
											toFloat(self.Owner:GetStatusEffect("Numb")) +
											toFloat(self.Owner:GetStatusEffect("Deaf")) +
											toFloat(self.Owner:GetStatusEffect("Drunk"))
					--Currently it'll reduce more status effects than total ammo left if the player has more active statuses than ammo. Do we care?
					if SERVER then
						self.Owner:InflictStatusEffect("Slow",-1,1)
						self.Owner:InflictStatusEffect("Frozen",-3,1) --can the player even use this if they're currently frozen?
						self.Owner:InflictStatusEffect("Disease",-2,1)
						self.Owner:InflictStatusEffect("Burning",-2,1)
						self.Owner:InflictStatusEffect("Acid Burning",-2,1)
						self.Owner:InflictStatusEffect("Shock",-1,1)
						self.Owner:InflictStatusEffect("Radiation",-1,1)
						self.Owner:InflictStatusEffect("Numb",-1,1)
						self.Owner:InflictStatusEffect("Deaf",-1,1)
						self.Owner:InflictStatusEffect("Drunk",-1,1)
						self:TakeSubammo(item,totalStatuses)
					end
					local att = self:LookupAttachment("muzzle")
					local posang = self:GetAttachment(att)
					
					local ef = EffectData()
						ef:SetEntity(self)
						ef:SetOrigin(posang.Pos)
						ef:SetNormal(posang.Ang:Forward())
						ef:SetStart(posang.Pos)
						ef:SetScale(1)
						ef:SetAttachment(att)
					util.Effect("ef_scav_muzzlesplash",ef)
					if totalStatuses > 0 then
						self:EmitSound("ambient/water/rain_drip"..math.floor(math.Rand(1,5))..".wav",75,140,0.25)
					end
					local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
					if not continuefiring then
						if SERVER then
							self.soundloops.showerrun:Stop()
							self.Owner:EmitSound("ambient/water/rain_drip"..math.floor(math.Rand(1,5))..".wav",75,100,0.5)
							self:SetChargeAttack()
							self:SetBarrelRestSpeed(0)
						else
							hook.Remove( "RenderScreenspaceEffects", "ScavDrips")
						end
						return 2
					else
						if SERVER then self.soundloops.showerrun:Play() end
						return 0.1
					end
				end
				tab.FireFunc = function(self,item)
					self:SetChargeAttack(ScavData.models["models/props_wasteland/shower_system001a.mdl"].ChargeAttack,item)
					if SERVER then
						self.Owner:EmitSound("buttons/lever2.wav")
						self.soundloops.showerrun = CreateSound(self.Owner,"ambient/water/water_run1.wav")
						self:SetBarrelRestSpeed(400)
					else
						timer.Simple(1,function()
							if self:ProcessLinking(item) and self:StopChargeOnRelease() then --make sure the player didn't cancel the charge before we even got to it
								hook.Add( "RenderScreenspaceEffects", "ScavDrips", function()
									DrawMaterialOverlay( "models/shadertest/shader3", -0.01 )
								end )
							end
						end)
					end
					return false
				end
			if SERVER then
				ScavData.CollectFuncs["models/props_interiors/sinkkitchen01a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_c17/furnituresink001a.mdl"] = ScavData.CollectFuncs["models/props_interiors/sinkkitchen01a.mdl"]
				ScavData.CollectFuncs["models/props_junk/metalbucket01a.mdl"] = ScavData.CollectFuncs["models/props_interiors/sinkkitchen01a.mdl"]
				ScavData.CollectFuncs["models/props_junk/metalbucket02a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_c17/furniturebathtub001a.mdl"] = ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"]
				ScavData.CollectFuncs["models/props_c17/furniturewashingmachine001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),25,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_wasteland/laundry_dryer001.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),30,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_wasteland/laundry_dryer002.mdl"] = ScavData.CollectFuncs["models/props_wasteland/laundry_dryer001.mdl"]
				ScavData.CollectFuncs["models/props_wasteland/laundry_washer001a.mdl"] = ScavData.CollectFuncs["models/props_wasteland/laundry_dryer001.mdl"]
				ScavData.CollectFuncs["models/props_wasteland/laundry_washer003.mdl"] = ScavData.CollectFuncs["models/props_wasteland/laundry_dryer001.mdl"]
				ScavData.CollectFuncs["models/props_wasteland/shower_system001a.mdl"] = ScavData.CollectFuncs["models/props_wasteland/laundry_dryer001.mdl"]
				--CSS
				ScavData.CollectFuncs["models/props/cs_militia/showers.mdl"] = ScavData.CollectFuncs["models/props_wasteland/laundry_dryer001.mdl"]
				ScavData.CollectFuncs["models/props/cs_militia/toothbrushset01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),5,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props/cs_militia/dryer.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturewashingmachine001a.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/firehydrant.mdl"] = ScavData.CollectFuncs["models/props_wasteland/laundry_dryer001.mdl"]
				--TF2
				ScavData.CollectFuncs["models/props_2fort/sink001.mdl"] = ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"]
				ScavData.CollectFuncs["models/props_2fort/hose001.mdl"] = ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"]
				--DoD:S
				ScavData.CollectFuncs["models/props_furniture/sink1.mdl"] = ScavData.CollectFuncs["models/props_interiors/sinkkitchen01a.mdl"]
				ScavData.CollectFuncs["models/props_furniture/bathtub1.mdl"] = ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"]
				--L4D/2
				ScavData.CollectFuncs["models/props_interiors/bathroomsink01.mdl"] = ScavData.CollectFuncs["models/props_interiors/sinkkitchen01a.mdl"]
				ScavData.CollectFuncs["models/props_interiors/bathtub01.mdl"] = ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"]
				ScavData.CollectFuncs["models/props_interiors/sink_industrial01.mdl"] = ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"]
				ScavData.CollectFuncs["models/props_interiors/sink_kitchen.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),20,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_interiors/pedestal_sink.mdl"] = ScavData.CollectFuncs["models/props_interiors/sinkkitchen01a.mdl"]
				ScavData.CollectFuncs["models/props_docks/marina_firehosebox.mdl"] = ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"]
				ScavData.CollectFuncs["models/props_equipment/firehosebox01.mdl"] = ScavData.CollectFuncs["models/props_interiors/bathtub01a.mdl"]
				ScavData.CollectFuncs["models/props_interiors/soap_dispenser.mdl"] = ScavData.CollectFuncs["models/props/cs_militia/toothbrushset01.mdl"]
				ScavData.CollectFuncs["models/props_interiors/soap_dispenser_static.mdl"] = ScavData.CollectFuncs["models/props_interiors/soap_dispenser.mdl"]
				ScavData.CollectFuncs["models/props_interiors/soapdispenser01.mdl"] = ScavData.CollectFuncs["models/props_interiors/sinkkitchen01a.mdl"]
				ScavData.CollectFuncs["models/props_interiors/dryer.mdl"] = ScavData.CollectFuncs["models/props/cs_militia/dryer.mdl"]
				ScavData.CollectFuncs["models/props_junk/metalbucket01a_static.mdl"] = ScavData.CollectFuncs["models/props_junk/metalbucket01a.mdl"]
				ScavData.CollectFuncs["models/props_junk/metalbucket02a_static.mdl"] = ScavData.CollectFuncs["models/props_junk/metalbucket02a.mdl"]
				ScavData.CollectFuncs["models/props_street/firehydrant.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/firehydrant.mdl"]
				ScavData.CollectFuncs["models/props_urban/fire_hydrant001.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/firehydrant.mdl"]
				--ASW
				ScavData.CollectFuncs["models/props/furniture/misc/bathroomsink.mdl"] = ScavData.CollectFuncs["models/props_interiors/sink_kitchen.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/props_interiors/sinkkitchen01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/furnituresink001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/metalbucket01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/metalbucket02a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/bathtub01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/furniturebathtub001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_c17/furniturewashingmachine001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_wasteland/laundry_dryer001.mdl")
		ScavData.RegisterFiremode(tab,"models/props_wasteland/laundry_dryer002.mdl")
		ScavData.RegisterFiremode(tab,"models/props_wasteland/laundry_washer001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_wasteland/laundry_washer003.mdl")
		ScavData.RegisterFiremode(tab,"models/props_wasteland/shower_system001a.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_militia/showers.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_militia/toothbrushset01.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_militia/dryer.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_assault/firehydrant.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/props_2fort/sink001.mdl")
		ScavData.RegisterFiremode(tab,"models/props_2fort/hose001.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab,"models/props_furniture/sink1.mdl")
		ScavData.RegisterFiremode(tab,"models/props_furniture/bathtub1.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_interiors/bathroomsink01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/bathtub01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/sink_industrial01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/sink_kitchen.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/pedestal_sink.mdl")
		ScavData.RegisterFiremode(tab,"models/props_docks/marina_firehosebox.mdl")
		ScavData.RegisterFiremode(tab,"models/props_equipment/firehosebox01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/soap_dispenser.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/soap_dispenser_static.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/soapdispenser01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_interiors/dryer.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/metalbucket01a_static.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/metalbucket02a_static.mdl")
		ScavData.RegisterFiremode(tab,"models/props_street/firehydrant.mdl")
		ScavData.RegisterFiremode(tab,"models/props_urban/fire_hydrant001.mdl")
		--ASW
		ScavData.RegisterFiremode(tab,"models/props/furniture/misc/bathroomsink.mdl")

--[[==============================================================================================
	-- Sandwich
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.sandvich"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.MaxAmmo = 3
			if SERVER then
				tab.FireFunc = function(self,item)
					if self.Owner:Health() >= self.Owner:GetMaxHealth() then
						if IsMounted(440) then --TF2
							self.Owner:EmitSound("vo/heavy_no02.mp3")
						else
							self.Owner:EmitSound("phx/eggcrack.wav")
						end
						return false
					else
						self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(),self.Owner:Health()+50))
						if IsMounted(440) then --TF2
							self.Owner:EmitSound("vo/SandwichEat09.mp3")
						else
							self.Owner:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.floor(math.Rand(1,5))..".wav")
						end
					end
					return self:TakeSubammo(item,1)
				end
				--CSS
				ScavData.CollectFuncs["models/props/cs_italy/bananna_bunch.mdl"] = function(self,ent) self:AddItem("models/props/cs_italy/bananna.mdl",1,0,5) end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_sandwich/c_sandwich.mdl"] = function(self,ent) --Christmas check
						if self.christmas then
							self:AddItem("models/weapons/c_models/c_sandwich/c_sandwich_xmas.mdl",1,math.floor(math.Rand(0,2)),1)
						else
							self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,0,1)
						end
					end
				ScavData.CollectFuncs["models/items/plate.mdl"] = function(self,ent) --Christmas check
						if self.christmas then
							self:AddItem("models/items/plate_sandwich_xmas.mdl",1,math.floor(math.Rand(0,2)),1)
						else
							self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,0,1)
						end
					end
			end
			tab.Cooldown = 2
		ScavData.RegisterFiremode(tab,"models/food/burger.mdl")
		ScavData.RegisterFiremode(tab,"models/food/hotdog.mdl")
		ScavData.RegisterFiremode(tab,"models/noesis/donut.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/misc/egg.mdl")
		ScavData.RegisterFiremode(tab,"models/props_phx/misc/potato.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_bag001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_milkcarton001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_milkcarton002a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_takeoutcarton001a.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_italy/bananna.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_sandwich/c_sandwich.mdl")
		ScavData.RegisterFiremode(tab,"models/items/plate.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_banana/c_banana.mdl")
		ScavData.RegisterFiremode(tab,"models/items/banana/banana.mdl")
		ScavData.RegisterFiremode(tab,"models/items/banana/plate_banana.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_chocolate/c_chocolate.mdl") --todo: temporary extra max health
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_chocolate/c_chocolate.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_chocolate/plate_chocolate.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_fishcake/c_fishcake.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_fishcake/c_fishcake.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_fishcake/plate_fishcake.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_sandwich/c_robo_sandwich.mdl")
		ScavData.RegisterFiremode(tab,"models/items/plate_robo_sandwich.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_sandwich/c_sandwich_xmas.mdl")
		ScavData.RegisterFiremode(tab,"models/items/plate_sandwich_xmas.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_takeoutbox01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_cerealbox01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_cerealbox01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_cerealbox02a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_cerealbox02a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_pizzabox01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_pizzabox01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/garbage_pizza_box.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_milkcarton002a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_smallbox01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_smallbox01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_tunacan01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_fastfoodcontainer01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_frenchfrycup01a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_frenchfrycup01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/petfoodbag01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/garbage_hamburger_container.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/garbage_popcorn_box.mdl")
		ScavData.RegisterFiremode(tab,"models/props_fairgrounds/garbage_popcorn_tub.mdl")

--[[==============================================================================================
	-- Crit Boost
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.crit"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			if SERVER then
				tab.FireFunc = function(self,item)
					if item.ammo == "models/props_island/steroid_drum.mdl" then
						self.Owner:InflictStatusEffect("DamageX",15,1.5)
					else
						self.Owner:InflictStatusEffect("DamageX",7,1.5)
					end
					return true
				end
				--TF2
				ScavData.CollectFuncs["models/props_island/steroid_drum_cluster.mdl"] = function(self,ent) self:AddItem("models/props_island/steroid_drum.mdl",1,0,8) end
				ScavData.CollectFuncs["models/weapons/c_models/c_buffpack/c_buffpack.mdl"] = function(self,ent) --Christmas check
					if self.christmas then
						self:AddItem("models/weapons/c_models/c_buffpack/c_buffpack_xmas.mdl",1,math.floor(math.Rand(0,2)),1)
					else
						self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,0,1)
					end
				end
			end
			tab.Cooldown = 2
		ScavData.RegisterFiremode(tab,"models/weapons/w_package.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_metalcan001a.mdl") --Me spinich!
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_metalcan002a.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/props_halloween/pumpkin_loot.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_buffalo_steak/c_buffalo_steak.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_buffalo_steak/c_buffalo_steak.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_buffalo_steak/plate_buffalo_steak.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_buffpack/c_buffpack.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_buffpack/c_buffpack_xmas.mdl")
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_crit.mdl")
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_strength.mdl")
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_strength_arm.mdl")
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_knockout.mdl")
		ScavData.RegisterFiremode(tab,"models/props_gameplay/pill_bottle01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_island/steroid_drum.mdl")

--[[==============================================================================================
	-- Invulnerability
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.invuln"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			if SERVER then
				tab.FireFunc = function(self,item)
					if item.ammo == "models/pickups/pickup_powerup_uber.mdl" then
						self.Owner:InflictStatusEffect("Invuln",15,1)
					else
						self.Owner:InflictStatusEffect("Invuln",10,1)
					end
					return true
				end
			end
			tab.Cooldown = 5
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/de_tides/vending_turtle.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/pickups/pickup_powerup_uber.mdl")

--[[==============================================================================================
	-- Whiskey
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.whiskey"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.MaxAmmo = 6
			tab.FireFunc = function(self,item)
				if IsValid(self.Owner) and (self.Owner:Health() >= self.Owner:GetMaxHealth() and not self.Owner:GetStatusEffect("Radiation")) then
					if SERVER then
						if item.ammo == "models/weapons/w_whiskey.mdl" or
							item.ammo == "models/weapons/w_whiskey2.mdl" or
							item.ammo == "models/items_fof/whiskey_world.mdl" then
							self.Owner:EmitSound("player/burp.wav")
						else
							self.Owner:EmitSound("ambient/levels/canals/drip1.wav")
						end
					end
					tab.Cooldown = .5
					return false
				elseif SERVER then
					self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(),self.Owner:Health()+25))
					self.Owner:InflictStatusEffect("Radiation",-5,-1,self.Owner)
					if item.ammo == "models/weapons/w_whiskey.mdl" or
						item.ammo == "models/weapons/w_whiskey2.mdl" or
						item.ammo == "models/items_fof/whiskey_world.mdl" then
						local rand = math.floor(math.Rand(1,5))
						self.Owner:EmitSound("player/whiskey_glug" .. rand .. ".wav")
					else
						self.Owner:EmitSound("ambient/levels/canals/toxic_slime_gurgle4.wav")
					end
					self.Owner:InflictStatusEffect("Drunk",10,.25)
					return self:TakeSubammo(item,1)
				end
			end
			if SERVER then
				--L4D/2
				ScavData.CollectFuncs["models/props_junk/garbage_sixpackbox01a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/props_junk/glassbottle01a.mdl"),1,math.Round(math.Rand(0,1)),6) end --6-pack
				ScavData.CollectFuncs["models/props_junk/garbage_sixpackbox01a_fullsheet.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_sixpackbox01a.mdl"]
				--FoF
				ScavData.CollectFuncs["models/weapons/w_whiskey.mdl"] = function(self,ent)
					self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,0,1)
					local voice = {"voice","voice2","voice4"}
					local rand = math.floor(math.Rand(1,3))
					self.Owner:EmitSound("player/" .. voice[math.floor(math.Rand(1,4))] .. "/whiskey_passwhiskey".. rand .. ".wav",75,100,1,CHAN_VOICE)
				end
				ScavData.CollectFuncs["models/weapons/w_whiskey2.mdl"] = ScavData.CollectFuncs["models/weapons/w_whiskey.mdl"]
				ScavData.CollectFuncs["models/items_fof/whiskey_world.mdl"] = ScavData.CollectFuncs["models/weapons/w_whiskey.mdl"]
				ScavData.CollectFuncs["models/elpaso/barrel2.mdl"] = function(self,ent)
					for i=1,5,1 do
						if math.random() < .5 then
							self:AddItem(ScavData.FormatModelname("models/weapons/w_whiskey.mdl"),1,0,1)
						else
							self:AddItem(ScavData.FormatModelname("models/weapons/w_whiskey2.mdl"),1,0,1)
						end
					end
					local voice = {"voice","voice2","voice4"}
					local rand = math.floor(math.Rand(1,3))
					self.Owner:EmitSound("player/" .. voice[math.floor(math.Rand(1,4))] .. "/howl_yeehaw".. rand .. ".wav",75,100,1,CHAN_VOICE)
				end
				ScavData.CollectFuncs["models/elpaso/barrel2_small.mdl"] = ScavData.CollectFuncs["models/elpaso/barrel2.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/props_junk/glassjug01.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_glassbottle001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_glassbottle002a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/garbage_glassbottle003a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_junk/glassbottle01a.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_bottle.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_bottle/c_bottle.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_scotland_shard/c_scotland_shard.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/weapons/w_whiskey.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/w_whiskey2.mdl")
		ScavData.RegisterFiremode(tab,"models/items_fof/whiskey_world.mdl")

--[[==============================================================================================
	--plasmagun
==============================================================================================]]--

PrecacheParticleSystem("scav_plasma_1")
PrecacheParticleSystem("scav_exp_plasma")

		local tab = {}
			tab.Name = "#scav.scavcan.plasmagun"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 4
			tab.MaxAmmo = 300
			if SERVER then
				tab.Callback = function(self,tr)	
					if IsValid(tr.Entity) then
						local dmg = DamageInfo()
						dmg:SetDamage(15)
						dmg:SetDamageForce(vector_origin)
						dmg:SetDamagePosition(tr.HitPos)
						if IsValid(self:GetOwner()) then
							dmg:SetAttacker(self:GetOwner())
						end
						if IsValid(self:GetInflictor()) then
							dmg:SetInflictor(self:GetInflictor())
						end
						dmg:SetDamageType(DMG_PLASMA)
						tr.Entity:TakeDamageInfo(dmg)
						--tr.Entity:TakeDamage(15,self.Owner,self.Owner)
					end 
				end
				tab.proj = GProjectile()
				tab.proj:SetCallback(tab.Callback)
				tab.proj:SetBBox(Vector(-8,-8,-8),Vector(8,8,8))
				tab.proj:SetPiercing(false)
				tab.proj:SetGravity(vector_origin)
				tab.proj:SetMask(MASK_SHOT)
				tab.OnArmed = function(self,item,olditemname)
					if item.ammo ~= olditemname then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
			end
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local pos = self.Owner:GetShootPos()+self:GetAimVector()*24+self:GetAimVector():Angle():Right()*4-self:GetAimVector():Angle():Up()*4
					local vel = self:GetAimVector()*2000*self:GetForceScale()
					if SERVER then
						local proj = tab.proj
						--local proj = s_proj.AddProjectile(self.Owner,pos,self:GetAimVector()*2000,ScavData.models[self.inv.items[1].ammo].Callback,false,false,vector_origin,self.Owner,Vector(-8,-8,-8),Vector(8,8,8))
						proj:SetOwner(self.Owner)
						proj:SetInflictor(self)
						proj:SetPos(pos)
						proj:SetVelocity(vel)
						proj:SetFilter(self.Owner)
						proj:Fire()
						--self.Owner:EmitToAllButSelf("weapons/physcannon/energy_bounce2.wav",80,150)
						item.lastsound = item.lastsound or 0
						self.Owner:StopSound("weapons/physcannon/energy_disintegrate"..(4+item.lastsound)..".wav")
						item.lastsound = 1-(item.lastsound)
						self:AddBarrelSpin(200)
						self.Owner:EmitSound("weapons/physcannon/energy_disintegrate"..(4+item.lastsound)..".wav",80,255)
						self:TakeSubammo(item,1) 
					end
					local ef = EffectData()
						ef:SetOrigin(pos)
						ef:SetStart(vel)
						ef:SetEntity(self.Owner)
					util.Effect("ef_scav_plasma",ef)
					self:MuzzleFlash2(3)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
					end
				end
				return 0.1
			end
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(ScavData.models["models/items/car_battery01.mdl"].ChargeAttack,item)
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/items/car_battery01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,ent:GetSkin()) end
				--TF2
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),12,ent:GetSkin()) end
			end
			tab.Cooldown = 0
			ScavData.RegisterFiremode(tab,"models/items/car_battery01.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl")

--[[==============================================================================================
	--Frag 12 High-Explosive round
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.frag12"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 7
			tab.MaxAmmo = 40
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
			tab.FireFunc = function(self,item)
				local tab = ScavData.models[self.inv.items[1].ammo]
				tab.bullet.Src = self.Owner:GetShootPos()
				tab.bullet.Dir = self:GetAimVector()
				if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
					self.Owner:FireBullets(tab.bullet)
				end
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("^weapons/ar2/fire1.wav")
				if SERVER then return self:TakeSubammo(item,1) end
			end
			if SERVER then
				--L4D2
				ScavData.CollectFuncs["models/w_models/weapons/w_eq_explosive_ammopack.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),40,ent:GetSkin(),1) end
			end
			tab.Cooldown = 0.2
			ScavData.RegisterFiremode(tab,"models/items/ammo/frag12round.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_eq_explosive_ammopack.mdl")

--[[==============================================================================================
	--Syringe Gun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.syringes"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 190 --150 + 40
			local callback = function(self,tr)
				if IsValid(tr.Entity) then
					if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
						tr.Entity:InflictStatusEffect("Disease",5,1)
					end
					local dmg = DamageInfo()
						dmg:SetDamage(1)
						dmg:SetDamageForce(vector_origin)
						dmg:SetDamagePosition(tr.HitPos)
						dmg:SetDamageType(DMG_BULLET)
					if IsValid(self:GetOwner()) then
						dmg:SetAttacker(self:GetOwner())
					end
					if IsValid(self:GetInflictor()) then
						dmg:SetInflictor(self:GetInflictor())
					end
					tr.Entity:TakeDamageInfo(dmg)
				end 
			end
			if SERVER then
				tab.proj = GProjectile()
					tab.proj:SetCallback(callback)
					tab.proj:SetBBox(Vector(-1,-1,-1),Vector(1,1,1))
					tab.proj:SetPiercing(false)
					tab.proj:SetGravity(Vector(0,0,-96))
					tab.proj:SetMask(MASK_SHOT)
			end
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then		
					local vel = (VectorRand()*0.01+self:GetAimVector()):GetNormalized()*1500*self:GetForceScale()
					local pos = self.Owner:GetShootPos()+self:GetAimVector()*24+self:GetAimVector():Angle():Right()*4-self:GetAimVector():Angle():Up()*4
					--local proj = s_proj.AddProjectile(self.Owner,self.Owner:GetShootPos()+(self:GetAimVector():Angle():Right()*2-self:GetAimVector():Angle():Up()*2)*1,vel,ScavData.models["models/weapons/w_models/w_syringegun.mdl"].Callback,false,false,Vector(0,0,-96))
					if SERVER then
						local proj = tab.proj
						proj:SetOwner(self.Owner)
						proj:SetInflictor(self)
						proj:SetPos(pos)
						proj:SetVelocity(vel)
						proj:SetFilter(self.Owner)
						proj:Fire()
						self:TakeSubammo(item,1)
						if item.subammo == 0 then
							self.Owner:EmitSound("weapons/syringegun_reload_air1.wav")
							timer.Simple(0.25,function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/syringegun_reload_air2.wav") end end)
						end
					else
						local ef = EffectData()
							ef:SetOrigin(pos)
							ef:SetStart(vel)
							ef:SetEntity(self.Owner)
							ef:SetScale(item.data)
						util.Effect("ef_scav_syringe",ef)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self:SetChargeAttack()
					end
					return 0.25
				end
				return 0.1
			end
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(ScavData.models["models/weapons/w_models/w_syringegun.mdl"].ChargeAttack,item)
				return false
			end
			if SERVER then
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_syringegun.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),40,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/weapons/c_models/c_syringegun/c_syringegun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_syringegun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_leechgun/c_leechgun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_syringegun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_proto_syringegun/c_proto_syringegun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_syringegun.mdl"]
			end
			tab.Cooldown = 0
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_syringegun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_syringegun/c_syringegun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_leechgun/c_leechgun.mdl")		
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_proto_syringegun/c_proto_syringegun.mdl")		

		
--[[==============================================================================================
	--Physics Super Shotgun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.physshotsuper"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 6
			if SERVER then
				tab.FireFunc = function(self,item)
					local chunks = {}
					local mdl = ""
					local ang = self.Owner:GetAngles()
					local randvec = Vector(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),math.Rand(-0.1,0.1))
					local pos = self.Owner:GetShootPos()+self:GetAimVector()*30+(randvec)
					local mass = 10
					local drag = true
					if item.ammo == "models/props_combine/breenbust.mdl" then
						chunks = {"1","2","3","4","5","6","7"}
						mdl = "models/props_combine/breenbust_Chunk0"
						mass = 15
					elseif item.ammo == "models/props_debris/concrete_spawnplug001a.mdl" then
						chunks = {"a","b","c","d","e","f","g","h","i","j","k"}
						mdl = "models/props_debris/concrete_spawnchunk001"
						mass = 25
						drag = false
						ang:Add(Angle(90,0,0))
					elseif item.ammo == "models/props/cs_office/plant01.mdl" then
						chunks = {"1","2","3","4","5","6","7"}
						mdl = "models/props/cs_office/plant01_p"
					elseif item.ammo == "models/props/de_inferno/flower_barrel.mdl" then
						chunks = {"1","2","3","4","5","6","7","8","9","10","11"}
						mdl = "models/props/de_inferno/flower_barrel_p"
					elseif item.ammo == "models/props/de_inferno/fountain_bowl.mdl" then
						chunks = {"2","3","4","5","6","7","8","9","10"}
						mdl = "models/props/de_inferno/fountain_bowl_p"
					elseif item.ammo == "models/props/cs_militia/skylight_glass.mdl" then
						chunks = {"2","3","4","5","6","7","8","9","10","11","12","13","14"}
						mdl = "models/props/cs_militia/skylight_glass_p"
						ang:Add(Angle(90,0,0))
					elseif item.ammo == "models/props_unique/airport/atlas.mdl" then
						chunks = {"1","2","3","4","5","6","7","8","9"}
						mdl = "models/props_unique/airport/atlas_break0"
						pos:Add(Vector(0,0,-32))
						mass = 25
						drag = false
					elseif item.ammo == "models/props_debris/concrete_column001a_core.mdl" then
						chunks = {"1","2","3","4","5","6","7","8","9"}
						mdl = "models/props_debris/concrete_column001a_chunk0"
						ang:Add(Angle(0,0,90)) --horizontal spread
						mass = 25
					end
					for i=1,#chunks,1 do
						local proj = self:CreateEnt("prop_physics")
						proj:SetModel(mdl .. chunks[i] .. ".mdl")
						proj:SetPos(pos)
						proj:SetAngles(ang)
						proj:SetPhysicsAttacker(self.Owner)
						proj:SetCollisionGroup(13)
						proj:Spawn()
						proj:SetOwner(self.Owner)
						proj:GetPhysicsObject():SetMass(mass)
						proj:GetPhysicsObject():AddGameFlag(bit.bor(FVPHYSICS_PENETRATING,FVPHYSICS_WAS_THROWN))
						proj:GetPhysicsObject():SetVelocity((self:GetAimVector()+randvec)*2500+self.Owner:GetVelocity())
						proj:GetPhysicsObject():SetBuoyancyRatio(0)
						proj:GetPhysicsObject():EnableDrag(drag)
						proj:Fire("kill",1,"3")
						--gamemode.Call("ScavFired",self.Owner,proj)
					end
					self.Owner:GetPhysicsObject(wake)
					self.Owner:SetVelocity(self.Owner:GetVelocity()-self:GetAimVector()*200)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-1,0)-8,math.Rand(-0.1,0.1),0))
					self.Owner:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav")
					timer.Simple(0.5, function() if IsValid(self) then self:SendWeaponAnim(ACT_VM_HOLSTER) end end)
					timer.Simple(0.75, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun/shotgun_reload3.wav",100,65) end end)
					timer.Simple(1.75, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav",100,120) end end)
					return self:TakeSubammo(item,1)
				end
			end
			tab.Cooldown = 2
		ScavData.RegisterFiremode(tab,"models/props_combine/breenbust.mdl")
		ScavData.RegisterFiremode(tab,"models/props_debris/concrete_spawnplug001a.mdl")
		ScavData.RegisterFiremode(tab,"models/props_debris/concrete_column001a_core.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/cs_office/plant01.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_inferno/flower_barrel.mdl")
		ScavData.RegisterFiremode(tab,"models/props/de_inferno/fountain_bowl.mdl")
		ScavData.RegisterFiremode(tab,"models/props/cs_militia/skylight_glass.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/props_unique/airport/atlas.mdl")
	
	
	
--[[==============================================================================================
	--Physics Shotgun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.physshot"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self,item)
					local chunks = {}
					local mdl = ""
					local ang = self.Owner:GetAngles()
					if item.ammo == "models/props_interiors/toilet.mdl" or
						item.ammo == "models/props_interiors/toilet_b.mdl" or
						item.ammo == "models/props_interiors/toilet_b_breakable01.mdl" or
						item.ammo == "models/props_interiors/toilet_elongated.mdl" then
						chunks = {"01","02","03","04","05","06","08","09","10","11","12","13","14"}
						mdl = "models/props_interiors/toilet_b_breakable01_part"
					elseif item.ammo == "models/props_junk/watermelon01.mdl" then
						chunks = {"01a","01b","01c","02a","02b","02c","02a"}
						mdl = "models/props_junk/watermelon01_chunk"
					elseif item.ammo == "models/props_junk/vent001.mdl" then
						chunks = {"1","2","3","4","5","6","7","8"}
						mdl = "models/props_junk/vent001_chunk"
					elseif item.ammo == "models/props_wasteland/prison_sink001a.mdl" or
						item.ammo == "models/props_wasteland/prison_sink001b.mdl" then
						chunks = {"b","c","d","e","f","g","h"}
						mdl = "models/props_wasteland/prison_sinkchunk001"
					elseif item.ammo == "models/props/de_inferno/wine_barrel.mdl" then
						chunks = {"1","2","3","4","5","6","7","8","9","10","11"}
						mdl = "models/props/de_inferno/wine_barrel_p"
					elseif item.ammo == "models/props/de_inferno/claypot01.mdl" or
						item.ammo == "models/props/de_inferno/claypot02.mdl" then
						chunks = {"1","2","3","4"}
						mdl = string.sub(item.ammo,1,-5) .. "_damage_0"
					elseif item.ammo == "models/props/de_inferno/claypot03.mdl" then
						chunks = {"1","2","3","4","5","6"}
						mdl = "models/props/de_inferno/claypot03_damage_0"
					elseif item.ammo == "models/props/cs_office/projector.mdl" then
						chunks = {"gib1","gib2","gib3","p1a","p1b","p2a","p2b","p3a","p3b","p4a","p4b","p5","p6a","p6b","p7a","p7b"}
						mdl = "models/props/cs_office/projector_"
						ang:Add(Angle(90,0,0))
					else
						chunks = {"a","b","c","d","e","f","g","h","i","j","k","l","m"}
						mdl = "models/props_wasteland/prison_toiletchunk01"
					end
					for i=1,#chunks,1 do
						math.randomseed(CurTime()+i)
						local proj = self:CreateEnt("prop_physics")
						proj:SetModel(mdl..chunks[i]..".mdl")
						local randvec = Vector(math.sin(i),math.cos(i),math.sin(i)*math.cos(i))*0.05
						--local randvec = Vector(math.Rand(-0.05,0.05),math.Rand(-0.05,0.05),math.Rand(-0.05,0.05))
						--local randvec = Vector((i+math.random(-7,7))*0.01*(math.floor(CurTime())-CurTime()),(i+math.random(-6,6))*0.01*(math.floor(CurTime())-CurTime()),(i+math.random(-5,5))*0.01*(math.floor(CurTime())-CurTime()))
						proj:SetPos(self.Owner:GetShootPos()+self:GetAimVector()*30+(randvec))
						proj:SetAngles(ang)
						proj:SetPhysicsAttacker(self.Owner)
						proj:SetCollisionGroup(13)
						proj:SetGravity(0)
						proj:Spawn()
						proj:SetOwner(self.Owner)
						proj:GetPhysicsObject():SetMass(7)
						proj:GetPhysicsObject():AddGameFlag(FVPHYSICS_WAS_THROWN)
						proj:GetPhysicsObject():SetVelocity((self:GetAimVector()+randvec)*2500)
						proj:GetPhysicsObject():SetBuoyancyRatio(0)
						proj:Fire("kill",1,"2")
						--gamemode.Call("ScavFired",self.Owner,proj)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
					end
			
					self.Owner:ViewPunch(Angle(math.Rand(-1,0)-8,math.Rand(-0.1,0.1),0))
					self.Owner:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav")
					timer.Simple(0.25, function() if IsValid(self) then self:SendWeaponAnim(ACT_VM_HOLSTER) end end)
					timer.Simple(0.5, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun/shotgun_reload3.wav",100,65) end end)
					timer.Simple(1, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav",100,120) end end)
					return self:TakeSubammo(item,1)
				end
			end
			tab.Cooldown = 1.25
			ScavData.RegisterFiremode(tab,"models/props_wasteland/prison_toilet01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_c17/furnituretoilet001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/watermelon01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_wasteland/prison_sink001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_wasteland/prison_sink001b.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/vent001.mdl")
			--CSS
			ScavData.RegisterFiremode(tab,"models/props/de_inferno/wine_barrel.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_inferno/claypot01.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_inferno/claypot02.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_inferno/claypot03.mdl")
			ScavData.RegisterFiremode(tab,"models/props/cs_office/projector.mdl")
			--L4D/2
			ScavData.RegisterFiremode(tab,"models/props_interiors/urinal01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/toilet.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/toilet_b.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/toilet_b_breakable01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/toilet_elongated.mdl")
			--Portal
			ScavData.RegisterFiremode(tab,"models/props/toilet_body_reference.mdl")
			--ASW
			ScavData.RegisterFiremode(tab,"models/props/furniture/misc/toilet.mdl")
	
--[[==============================================================================================
	--Flamethrower
==============================================================================================]]--
		
		local creditfix = {
			--["grenade_helicopter"] = true, --TODO: credit is given to #scav_gun (or the grenade itself when not on this list), not the player, when the explosion kills. When the prop slap kills, player gets credit.
			["prop_ragdoll"] = true,
			--["scav_projectile_mag"] = true, --TODO: credit is given to #scav_gun (or the magnusson itself when not on this list), not the player, when the prop slap kills. The explosion is properly credited.
			["npc_tripmine"] = true,
			["scav_projectile_flare2"] = true
			}
		
		local firecredit = function(ent,dmginfo)
			local inflictor = dmginfo:GetInflictor()
			local attacker = dmginfo:GetAttacker()
			local amount = dmginfo:GetDamage()
			if IsValid(attacker) and (attacker == inflictor) then
				if ((attacker:GetClass() == "entityflame") and IsValid(ent.ignitedby)) then
					dmginfo:SetInflictor(attacker)
					dmginfo:SetAttacker(ent.ignitedby)
				end
				if creditfix[attacker:GetClass()] and IsValid(attacker.thrownby) then
					dmginfo:SetInflictor(attacker)
					dmginfo:SetAttacker(attacker.thrownby)
				end
			end
		end
		hook.Add("EntityTakeDamage","GiveFireCredit",firecredit)
		

		local tab = {}
			tab.Name = "#scav.scavcan.flamethrower"
			tab.anim = ACT_VM_IDLE
			tab.Level = 4
			tab.MaxAmmo = 1000
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
						proj:SetLifetime(self:GetForceScale())
						proj:Fire()
					if self.Owner:GetGroundEntity() == NULL then
						self.Owner:SetVelocity(self:GetAimVector()*-45)
					end
					self:AddBarrelSpin(400)
					self:TakeSubammo(item,1)
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if IsValid(self.ef_fthrow) then
						self.ef_fthrow:Kill()
					end
					self:SetChargeAttack()
					return 0.25
				end
				return 0.1
			end
			function tab.FireFunc(self,item)
				if SERVER then
					self.ef_fthrow = self:CreateToggleEffect("scav_stream_fthrow")
				end
				self:SetChargeAttack(tab.ChargeAttack,item)
				--tab.ChargeAttack(self,item)
				return false
			end
			if SERVER then
				local proj = GProjectile()
				local function callback(self,tr)
					local ent = tr.Entity
					if IsValid(ent) and (not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage",ent,self.Owner)) then
						ent:Ignite(5,0)
						ent.ignitedby = self.Owner
						local dmg = DamageInfo()
						dmg:SetDamage((self.deathtime-CurTime())*7)
						dmg:SetDamageForce(tr.Normal*30)
						dmg:SetDamagePosition(tr.HitPos)
						if IsValid(self:GetOwner()) then
							dmg:SetAttacker(self:GetOwner())
						end
						if IsValid(self:GetInflictor()) then
							dmg:SetInflictor(self:GetInflictor())
						end
						dmg:SetDamageType(DMG_DIRECT)
						ent:TakeDamageInfo(dmg)
					end
					if not (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) then
						self:SetPiercing(false)
					end
					return
				end
				proj:SetCallback(callback)
				proj:SetBBox(Vector(-7,-7,-7),Vector(7,7,7))
				proj:SetPiercing(true)
				proj:SetGravity(vector_origin)
				proj:SetMask(bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME))
				proj:SetLifetime(1)
				tab.proj = proj

				ScavData.CollectFuncs["models/props_junk/propanecanister001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/props_junk/propane_tank001a.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),50,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),200,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_wasteland/gaspump001a.mdl"] = ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"]
				ScavData.CollectFuncs["models/props_citizen_tech/firetrap_propanecanister01a.mdl"] = ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"]
				ScavData.CollectFuncs["models/props_citizen_tech/firetrap_propanecanister01b.mdl"] = ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"]
				ScavData.CollectFuncs["models/props_junk/metalgascan.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),25,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_junk/gascan001a.mdl"] = ScavData.CollectFuncs["models/props_junk/metalgascan.mdl"]
				--Ep2
				ScavData.CollectFuncs["models/props_mining/oiltank01.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),400,ent:GetSkin()) end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_flamethrower.mdl"] = ScavData.CollectFuncs["models/props_c17/canister_propane01a.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_degreaser/c_degreaser.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_flamethrower.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_degreaser/c_degreaser.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_degreaser/c_degreaser.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_backburner.mdl"] = function(self,ent) --Christmas check
					if self.christmas then
						self:AddItem("models/weapons/c_models/c_flamethrower/c_backburner_xmas.mdl",200,ent:GetSkin(),1)
					else
						self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,ent:GetSkin(),1)
					end
				end
				ScavData.CollectFuncs["models/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_flamethrower.mdl"] --TODO: phlog effect
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_backburner_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_backburner.mdl"]
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_flamethrower.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_rainblower/c_rainblower.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_flamethrower.mdl"] --TODO: Rainbow fire effect
				ScavData.CollectFuncs["models/props_farm/oilcan01.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),75,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_farm/oilcan01b.mdl"] = function(self,ent) self:AddItem(ent:GetModel(),50,ent:GetSkin()) end
				ScavData.CollectFuncs["models/props_farm/oilcan02.mdl"] = ScavData.CollectFuncs["models/props_junk/metalgascan.mdl"]
				ScavData.CollectFuncs["models/props_farm/gibs/shelf_props01_gib_oilcan01.mdl"] = ScavData.CollectFuncs["models/props_farm/oilcan02.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_gascan/c_gascan.mdl"] = ScavData.CollectFuncs["models/props_farm/oilcan02.mdl"]
				--L4D/2
				ScavData.CollectFuncs["models/props_equipment/gas_pump.mdl"] = ScavData.CollectFuncs["models/props_wasteland/gaspump001a.mdl"]
				ScavData.CollectFuncs["models/props_equipment/gas_pump_nodebris.mdl"] = ScavData.CollectFuncs["models/props_equipment/gas_pump.mdl"]
			end
			ScavData.RegisterFiremode(tab,"models/props_junk/propanecanister001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/propane_tank001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_c17/canister_propane01a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_wasteland/gaspump001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_citizen_tech/firetrap_propanecanister01a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_citizen_tech/firetrap_propanecanister01b.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/metalgascan.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/gascan001a.mdl")
			--Ep2
			ScavData.RegisterFiremode(tab,"models/props_mining/oiltank01.mdl")
			--TF2
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_flamethrower/c_flamethrower.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_degreaser/c_degreaser.mdl")
			ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_degreaser/c_degreaser.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl")
			ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_flamethrower/c_backburner.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_flamethrower/c_backburner_xmas.mdl")
			ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_rainblower/c_rainblower.mdl")
			ScavData.RegisterFiremode(tab,"models/props_farm/oilcan01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_farm/oilcan01b.mdl")
			ScavData.RegisterFiremode(tab,"models/props_farm/oilcan02.mdl")
			ScavData.RegisterFiremode(tab,"models/props_farm/gibs/shelf_props01_gib_oilcan01.mdl")
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_gascan/c_gascan.mdl")
			--L4D/2
			ScavData.RegisterFiremode(tab,"models/props_equipment/gas_pump.mdl")
			ScavData.RegisterFiremode(tab,"models/props_equipment/gas_pump_nodebris.mdl")
				
--[[==============================================================================================
	--Fireball
==============================================================================================]]--

		local tab = {}
			tab.Name = "#scav.scavcan.flameball"
			tab.anim = ACT_VM_IDLE
			tab.Level = 4
			tab.MaxAmmo = 40
			tab.Cooldown = 0.8
			tab.CooldownScale = 1
			if IsMounted(440) then --TF2
				PrecacheParticleSystem("projectile_fireball")
			else
				PrecacheParticleSystem("scav_projectile_fireball")
			end
			
			if SERVER then
				tab.Callback = function(self,tr)
					local ent = tr.Entity
					if IsValid(ent) then
						if not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage",ent,self.Owner) then
							local dmg = DamageInfo()
								local multiplier = 1
								if ent:IsOnFire() then multiplier = 3 end --TODO: triple damage should only count on center of projectile
								if ent:IsNPC() then multiplier = multiplier * .5 end --nerf damage against NPCs
								dmg:SetDamage((15 + (self.deathtime-CurTime())*5)*multiplier) -- 15-20 damage per shot, tripled if the target is on fire
								dmg:SetDamageForce(tr.Normal*30)
								dmg:SetDamagePosition(tr.HitPos)
								if IsValid(self:GetOwner()) then
									dmg:SetAttacker(self:GetOwner())
								end
								if IsValid(self:GetInflictor()) then
									dmg:SetInflictor(self:GetInflictor())
								end
							local reduced = self.Owner:GetWeapon("scav_gun").nextfire - tab.Cooldown / 3
							if self.hits == 0 then
								self.Owner:GetWeapon("scav_gun").nextfire = reduced
								if IsMounted(440) then --TF2
									sound.Play("weapons/dragons_fury_impact_hit.wav",tr.HitPos,75,100,.75)
								else
									sound.Play("player/pl_burnpain2.wav",tr.HitPos,75,120,1)
								end
								self.hits = self.hits + 1
							end
							net.Start("scv_s_time")
								net.WriteEntity(self.Owner:GetWeapon("scav_gun"))
								net.WriteInt(math.floor(reduced),32)
								net.WriteFloat(reduced - math.floor(reduced))
							net.Send(self.Owner)
							dmg:SetDamageType(bit.bor(DMG_DIRECT,DMG_BURN))
							ent:TakeDamageInfo(dmg)
							ent:Ignite(3,0)
							ent.ignitedby = self.Owner
						end
						if not (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
							if IsMounted(440) then --TF2
								sound.Play("weapons/dragons_fury_impact.wav",tr.HitPos,75,100,.75)
							else
								sound.Play("player/pl_burnpain2.wav",tr.HitPos,75,80,1)
							end
							if ent:IsWorld() then
								self:SetPiercing(false)
								return
							end
						end
					end
					return
				end
				tab.proj = GProjectile()
				tab.proj:SetCallback(tab.Callback)
				tab.proj:SetBBox(Vector(-16,-16,-16),Vector(16,16,16))
				tab.proj:SetPiercing(true)
				tab.proj:SetGravity(vector_origin)
				tab.proj:SetMask(bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME))
				tab.proj:SetLifetime(0.17533333)
				tab.proj.hits = 0
				--local proj = tab.proj

				function tab.FireFunc(self,item)
					local tab = ScavData.models[self.inv.items[1].ammo]
					local proj = tab.proj
					local extpos = self.Owner:GetShootPos()+self:GetAimVector()*75
					for k,v in ipairs(ents.FindByClass("env_fire")) do
						if v:GetPos():Distance(extpos) < 75 then
							v:Fire("StartFire",1,0)
						end
					end
					local tab = ScavData.models[item.ammo]
					proj:SetOwner(self.Owner)
					proj:SetInflictor(self)
					proj:SetFilter(self.Owner)
					proj:SetPos(self.Owner:GetShootPos())
					proj:SetVelocity(self:GetAimVector()*3000*self:GetForceScale())
					proj:SetLifetime(0.17533333*self:GetForceScale())
					proj:Fire()

					local pos = self.Owner:GetShootPos()+self:GetAimVector()*24+self:GetAimVector():Angle():Right()*4-self:GetAimVector():Angle():Up()*4
					local ef = EffectData()
						ef:SetOrigin(pos)
						ef:SetStart(self:GetAimVector()*3000*self:GetForceScale())
						ef:SetEntity(self.Owner)
					if IsMounted(440) then --TF2
						self.Owner:EmitSound("weapons/dragons_fury_shoot.wav",75,100,.5)
					else
						self.Owner:EmitSound("ambient/fire/mtov_flame2.wav",75,150,1)
					end
					util.Effect("ef_scav_fireball",ef,nil,true)
					if self.Owner:GetGroundEntity() == NULL then
						self.Owner:SetVelocity(self:GetAimVector()*-45)
					end
					self:AddBarrelSpin(500)
					return self:TakeSubammo(item,1)
				end
				ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),40,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/props_c17/furniturestove001a.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				ScavData.CollectFuncs["models/props_wasteland/kitchen_stove001a.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				ScavData.CollectFuncs["models/props_wasteland/kitchen_stove002a.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				--Ep2
				ScavData.CollectFuncs["models/props_forest/stove01.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				--CSS
				ScavData.CollectFuncs["models/props/cs_militia/stove01.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_flameball/c_flameball.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				ScavData.CollectFuncs["models/props_forest/kitchen_stove.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				--DoD:S
				ScavData.CollectFuncs["models/props_furniture/kitchen_oven1.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				--L4D/2
				ScavData.CollectFuncs["models/props_interiors/makeshift_stove_battery.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/props_junk/torchoven_01.mdl"] = ScavData.CollectFuncs["models/props_interiors/makeshift_stove_battery.mdl"]
				ScavData.CollectFuncs["models/props_interiors/stove02.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				ScavData.CollectFuncs["models/props_interiors/stove03_industrial.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				ScavData.CollectFuncs["models/props_interiors/stove04_industrial.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
				--FoF
				ScavData.CollectFuncs["models/props/forest/furnace_2.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefireplace001a.mdl"]
			end
			ScavData.RegisterFiremode(tab,"models/props_c17/furniturefireplace001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_c17/furniturestove001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_wasteland/kitchen_stove001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_wasteland/kitchen_stove002a.mdl")
			--Ep2
			ScavData.RegisterFiremode(tab,"models/props_forest/stove01.mdl")
			--CSS
			ScavData.RegisterFiremode(tab,"models/props/cs_militia/stove01.mdl")
			--TF2
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_flameball/c_flameball.mdl")
			ScavData.RegisterFiremode(tab,"models/props_forest/kitchen_stove.mdl")
			--DoD:S
			ScavData.RegisterFiremode(tab,"models/props_furniture/kitchen_oven1.mdl")
			--L4D/2
			ScavData.RegisterFiremode(tab,"models/props_interiors/makeshift_stove_battery.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/torchoven_01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/stove02.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/stove03_industrial.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/stove04_industrial.mdl")
			--FoF
			ScavData.RegisterFiremode(tab,"models/props/forest/furnace_2.mdl")

--[[==============================================================================================
	--Fire Extinguisher
==============================================================================================]]--
		
		do
			local tab = {}
				tab.Name = "#scav.scavcan.extinguisher"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.MaxAmmo = 250
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
									if vFireInstalled and ent.SoftExtinguish then ent:SoftExtinguish(10) end
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
										if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
											ent:SetVelocity((ent:GetPos()-self:GetPos()):GetNormalized()*1000)
										end
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
							proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*100*math.Rand(1,6)*self:GetForceScale()+self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector()*-54)
						end
						self:AddBarrelSpin(100)
						self:TakeSubammo(item,1)
					end
					local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
					if not continuefiring then
						if IsValid(self.ef_exting) then
							self.ef_exting:Kill()
						end
						self:SetChargeAttack()
						return 0.25
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
					--TODO: Default prop
					--CSS
					ScavData.CollectFuncs["models/props/cs_office/fire_extinguisher.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,0,1) end
					--TF2
					ScavData.CollectFuncs["models/props_2fort/fire_extinguisher.mdl"] = ScavData.CollectFuncs["models/props/cs_office/fire_extinguisher.mdl"]
				end
			--CSS
			ScavData.RegisterFiremode(tab,"models/props/cs_office/fire_extinguisher.mdl")
			--TF2
			ScavData.RegisterFiremode(tab,"models/props_2fort/fire_extinguisher.mdl")
		end
		
--[[==============================================================================================
	--Acid Sprayer
==============================================================================================]]--
		
		do
			local tab = {}
				tab.Name = "#scav.scavcan.acidspray"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.MaxAmmo = 1000
				tab.Cooldown = 0.1
				function tab.ChargeAttack(self,item)
					if SERVER then --SERVER
						local proj = tab.proj
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*100*math.Rand(1,6)*self:GetForceScale()+self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector()*-35)
						end
						self:AddBarrelSpin(100)
						self:TakeSubammo(item,1)
					end
					local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
					if not continuefiring then
						if IsValid(self.ef_aspray) then
							self.ef_aspray:Kill()
						end
						self:SetChargeAttack()
						return 0.25
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
						if IsValid(ent) and (not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage",ent,self.Owner)) then
							ent:InflictStatusEffect("Acid",100,(self.deathtime-CurTime())/2,self:GetOwner())
							ent:EmitSound("ambient/levels/canals/toxic_slime_sizzle"..math.random(2,4)..".wav")
						end
						if not (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) then
							self:SetPiercing(false)
						end
						return
					end
					proj:SetCallback(callback)
					proj:SetBBox(Vector(-8,-8,-8),Vector(8,8,8))
					proj:SetPiercing(true)
					proj:SetGravity(Vector(0,0,-96))
					proj:SetMask(bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME))
					proj:SetLifetime(1)
					tab.proj = proj
					ScavData.CollectFuncs["models/props_junk/plasticbucket001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,ent:GetSkin()) end
					ScavData.CollectFuncs["models/props_lab/crematorcase.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),1000,ent:GetSkin()) end
					ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,ent:GetSkin()) end
					ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle002a.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle001a.mdl"]
					--CSS
					ScavData.CollectFuncs["models/props/cs_italy/orange.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,0) end
					ScavData.CollectFuncs["models/props/de_inferno/crate_fruit_break_gib2.mdl"] = function(self,ent) self:AddItem("models/props/cs_italy/orange.mdl",1,0) end
					ScavData.CollectFuncs["models/props/de_inferno/crate_fruit_break.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/crate_fruit_break.mdl",400,0) end
					ScavData.CollectFuncs["models/props/de_inferno/crate_fruit_break_p1.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/crate_fruit_break_pl.mdl"]
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit1.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/crate_fruit_break.mdl",400,0,18) end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit1_p1.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/crate_fruit_break.mdl",400,0,15) end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/crate_fruit_break.mdl",400,0,13) end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2_p1.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2.mdl"]
					--L4D/2
					ScavData.CollectFuncs["models/props_equipment/fountain_drinks.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),300,ent:GetSkin()) end
					ScavData.CollectFuncs["models/infected/spitter.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),1000,0) end
					ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle001a_clientside.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle001a.mdl"]
					ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle001a_fullsheet.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle001a.mdl"]
					ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle001a_static.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle001a.mdl"]
					ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle002a_fullsheet.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle002a.mdl"]
					ScavData.CollectFuncs["models/props_junk/garbage_cleanercan01a.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_plasticbottle002a.mdl"]
					ScavData.CollectFuncs["models/props_junk/garbage_cleanercan01a_fullsheet.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_cleanercan01a.mdl"]
				end
			ScavData.RegisterFiremode(tab,"models/props_junk/plasticbucket001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_lab/crematorcase.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/garbage_plasticbottle001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/garbage_plasticbottle002a.mdl")
			--CSS
			ScavData.RegisterFiremode(tab,"models/props/cs_italy/orange.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_inferno/crate_fruit_break.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_inferno/crate_fruit_break_p1.mdl")
			--L4D/2
			ScavData.RegisterFiremode(tab,"models/props_equipment/fountain_drinks.mdl")
			ScavData.RegisterFiremode(tab,"models/infected/spitter.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/garbage_plasticbottle001a_clientside.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/garbage_plasticbottle001a_fullsheet.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/garbage_plasticbottle001a_static.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/garbage_plasticbottle002a_fullsheet.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/garbage_cleanercan01a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_junk/garbage_cleanercan01a_fullsheet.mdl")
		end

--[[==============================================================================================
	--Freezing Gas
==============================================================================================]]--
		
		do
			local tab = {}
				tab.Name = "#scav.scavcan.freezinggas"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.MaxAmmo = 200
				tab.Cooldown = 0.1
				function tab.ChargeAttack(self,item)
					if SERVER then --SERVER
						local proj = tab.proj
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector()+VectorRand()*0.1):GetNormalized()*100*math.Rand(1,6)*self:GetForceScale()+self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector()*-35)
						end
						self:AddBarrelSpin(100)
						self:TakeSubammo(item,1)
					end
					local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
					if not continuefiring then
						if IsValid(self.ef_frzgas) then
							self.ef_frzgas:Kill()
						end
						self:SetChargeAttack()
						return 0.25
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
						if IsValid(ent) and (not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage",ent,self:GetOwner())) then
							local dmg = DamageInfo()
							dmg:SetAttacker(self:GetOwner())
							if IsValid(self:GetOwner()) then
								dmg:SetAttacker(self:GetOwner())
							end
							if IsValid(self:GetInflictor()) then
								dmg:SetInflictor(self:GetInflictor())
							end
							dmg:SetDamage(1)
							dmg:SetDamageForce(vector_origin)
							dmg:SetDamagePosition(tr.HitPos)
							dmg:SetDamageType(DMG_FREEZE)
							tr.Entity:TakeDamageInfo(dmg)
							local slowfactor = 0.8
							local slowstatus = ent:GetStatusEffect("Slow")
							if slowstatus then
								slowfactor = slowstatus.Value*0.8
							end
							ent:InflictStatusEffect("Slow",0.1,slowfactor,self:GetOwner())
							local slow = ent:GetStatusEffect("Slow")
							if slow then
								if ent:IsPlayer() and (slow.Value < 0.3) then
									ent:InflictStatusEffect("Frozen",0.1,0,self:GetOwner())
								elseif not ent:IsPlayer() and ((ent:IsNPC() and ((ent:Health() < 10) or (slow.EndTime > CurTime()+10))) or not ent:IsNPC()) then
									ent:InflictStatusEffect("Frozen",0.2,0,self:GetOwner())
								end
							end
						end
						if tr.MatType == MAT_SLOSH then
							local pos = tr.HitPos*1
							local ice = NULL
							local model = "models/scav/iceplatform.mdl"
							for k,v in ipairs(ents.FindInSphere(pos,10)) do
								if v:GetModel() and (model == string.lower(v:GetModel())) then
									ice = v
									break
								end
							end
							if not IsValid(ice) then
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
						if not (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) then
							self:SetPiercing(false)
						end
						return
					end
					proj:SetCallback(callback)
					proj:SetBBox(Vector(-8,-8,-8),Vector(8,8,8))
					proj:SetPiercing(true)
					proj:SetGravity(vector_origin)
					proj:SetMask(bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME))
					proj:SetLifetime(1)
					tab.proj = proj
					ScavData.CollectFuncs["models/props_c17/furniturefridge001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,0) end
					ScavData.CollectFuncs["models/props_interiors/refrigerator01a.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefridge001a.mdl"]
					ScavData.CollectFuncs["models/props_wasteland/kitchen_fridge001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),150,0) end
					ScavData.CollectFuncs["models/props_c17/display_cooler01a.mdl"] = ScavData.CollectFuncs["models/props_wasteland/kitchen_fridge001a.mdl"]
					--Ep2
					ScavData.CollectFuncs["models/props_silo/acunit01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,ent:GetSkin()) end
					ScavData.CollectFuncs["models/props_silo/acunit02.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefridge001a.mdl"]
					ScavData.CollectFuncs["models/props_forest/refrigerator01.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/acunit01.mdl"]
					--CSS
					ScavData.CollectFuncs["models/props/cs_assault/acunit01.mdl"] = ScavData.CollectFuncs["models/props_silo/acunit01.mdl"]
					ScavData.CollectFuncs["models/props/cs_assault/acunit02.mdl"] = ScavData.CollectFuncs["models/props_silo/acunit02.mdl"]
					ScavData.CollectFuncs["models/props/de_train/acunit1.mdl"] = ScavData.CollectFuncs["models/props_wasteland/kitchen_fridge001a.mdl"]
					ScavData.CollectFuncs["models/props/de_train/acunit2.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefridge001a.mdl"]
					ScavData.CollectFuncs["models/props/cs_militia/refrigerator01.mdl"] = ScavData.CollectFuncs["models/props_forest/refrigerator01.mdl"]
					--L4D/2
					ScavData.CollectFuncs["models/props_equipment/cooler.mdl"] = ScavData.CollectFuncs["models/props/de_train/acunit1.mdl"]
					ScavData.CollectFuncs["models/props_downtown/mini_fridge.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0) end
					ScavData.CollectFuncs["models/props_interiors/fridge_mini.mdl"] = ScavData.CollectFuncs["models/props_downtown/mini_fridge.mdl"]
					ScavData.CollectFuncs["models/props_rooftop/acunit01.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/acunit01.mdl"]
					ScavData.CollectFuncs["models/props_rooftop/acunit2.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/acunit01.mdl"]
					ScavData.CollectFuncs["models/props_urban/air_conditioner001.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/acunit01.mdl"]
					ScavData.CollectFuncs["models/props_interiors/refrigerator02_main.mdl"] = ScavData.CollectFuncs["models/props_wasteland/kitchen_fridge001a.mdl"]
					ScavData.CollectFuncs["models/props_interiors/refrigerator03.mdl"] = ScavData.CollectFuncs["models/props_interiors/refrigerator02_main.mdl"]
					ScavData.CollectFuncs["models/props_interiors/refrigerator03_damaged_01.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,0) end
					--ASW
					ScavData.CollectFuncs["models/props/furniture/misc/fridge.mdl"] = ScavData.CollectFuncs["models/props_c17/furniturefridge001a.mdl"]
				end
			ScavData.RegisterFiremode(tab,"models/props_c17/furniturefridge001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/refrigerator01a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_wasteland/kitchen_fridge001a.mdl")
			ScavData.RegisterFiremode(tab,"models/props_c17/display_cooler01a.mdl")
			--Ep2
			ScavData.RegisterFiremode(tab,"models/props_silo/acunit01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_silo/acunit02.mdl")
			ScavData.RegisterFiremode(tab,"models/props_forest/refrigerator01.mdl")
			--CSS
			ScavData.RegisterFiremode(tab,"models/props/cs_assault/acunit01.mdl")
			ScavData.RegisterFiremode(tab,"models/props/cs_assault/acunit02.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_train/acunit1.mdl")
			ScavData.RegisterFiremode(tab,"models/props/de_train/acunit2.mdl")
			ScavData.RegisterFiremode(tab,"models/props/cs_militia/refrigerator01.mdl")
			--L4D/2
			ScavData.RegisterFiremode(tab,"models/props_equipment/cooler.mdl")
			ScavData.RegisterFiremode(tab,"models/props_downtown/mini_fridge.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/fridge_mini.mdl")
			ScavData.RegisterFiremode(tab,"models/props_rooftop/acunit01.mdl")
			ScavData.RegisterFiremode(tab,"models/props_rooftop/acunit2.mdl")
			ScavData.RegisterFiremode(tab,"models/props_urban/air_conditioner001.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/refrigerator02_main.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/refrigerator03.mdl")
			ScavData.RegisterFiremode(tab,"models/props_interiors/refrigerator03_damaged_01.mdl")
			--ASW
			ScavData.RegisterFiremode(tab,"models/props/furniture/misc/fridge.mdl")
		end

--[[==============================================================================================
	--Plasma Blade
==============================================================================================]]--

		do
			local tab = {}
				tab.Name = "#scav.scavcan.plasmablade"
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
							--self.Owner:EmitSound("ambient/energy/NewSpark08.wav")
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
					--TF2
					ScavData.CollectFuncs["models/workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl"] = ScavData.GiveOneOfItemInf
				end
				ScavData.RegisterFiremode(tab,"models/props_phx2/garbage_metalcan001a.mdl")
				--TF2
				ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl")
		end
		
--[[==============================================================================================
	--Buzzsaw
==============================================================================================]]--

		util.PrecacheModel("models/gibs/humans/eye_gib.mdl") --thanks Black Mesa mod version!
		PrecacheParticleSystem("scav_exp_disease_1")

		do
			local tab = {}
				tab.Name = "#scav.scavcan.buzzsaw"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.MaxAmmo = 1000
				tab.Cooldown = 0.025
				local tracep = {}
				tracep.mins = Vector(-12,-12,-12)
				tracep.maxs = Vector(12,12,12)
				function tab.ChargeAttack(self,item)
					if IsValid(self.ef_pblade) then
						if self.Owner:WaterLevel() > 1 then
							self.ef_pblade:SetSkin(0) --Clear the bloodied skin from the model
						end
					end
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = tracep.start+self.Owner:GetAimVector()*60
					tracep.filter = self.Owner
					local tr = util.TraceHull(tracep)
					if IsValid(tr.Entity) then
						--Okay, if I... if I chop you up in a meat grinder, and the only thing that comes out that's left of you is your eyeball, YOU'RE PROBABLY DEAD
						if tr.Entity:Health() <= 4 then
							if item.ammo == "models/props_c17/grinderclamp01a.mdl" and math.Rand(0,10) < 1 then
								if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
									if (tr.Entity:GetBloodColor() == BLOOD_COLOR_RED or tr.Entity:GetBloodColor() == BLOOD_COLOR_ZOMBIE or tr.Entity:GetBloodColor() == BLOOD_COLOR_GREEN) then
										tr.Entity:SetShouldServerRagdoll(false)
										if tr.Entity:IsNPC() then
											hook.Add("CreateClientsideRagdoll",tr.Entity,function(self,npc,ragdoll) 
												ragdoll:Remove()
											end)
											--TODO: I dunno what to even do here
										-- else
										-- 	if SERVER then
										-- 		hook.Add("PlayerDeath","ScavMeatGrinder",function(us,victim,inflictor,attacker)
										-- 			if SERVER then
										-- 				--if us ~= victim then return end
										-- 				if inflictor:GetClass() == "scav_gun" and ScavData.models[inflictor.inv.items[1]].ammo == "models/props_c17/grinderclamp01a.mdl" then
										-- 					print(ScavData.models[inflictor.inv.items[1]].ammo)
										-- 					print("AAA")
										-- 					victim:GetRagdollEntity():SetPos(Vector(-16384,-16384,-16384))
										-- 				end
										-- 			end
										-- 		end)
										-- 	end
										end
										if CLIENT then
											local attach = tr.Entity:GetPos()+tr.Entity:OBBCenter()
											if attach then
												ParticleEffect("scav_exp_disease_1",attach,Angle(0,0,0),game.GetWorld())
												local brass = ents.CreateClientProp("models/gibs/humans/eye_gib.mdl")
												if IsValid(brass) then
													brass:SetPos(attach)
													brass:SetAngles(Angle(0,0,0))
													brass:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
													brass:Spawn()
													brass:DrawShadow(false)
													local angShellAngles = self.Owner:EyeAngles()
													--angShellAngles:RotateAroundAxis(Vector(0,0,1),90)
													local vecShellVelocity = self.Owner:GetAbsVelocity()
													vecShellVelocity = vecShellVelocity + angShellAngles:Right() * math.Rand( 50, 70 );
													vecShellVelocity = vecShellVelocity + angShellAngles:Up() * math.Rand( 300, 350 );
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
									end
								end
							end
						end
						--if tr.Entity:IsNPC() then
						--	tr.Entity:SetSchedule(SCHED_BIG_FLINCH)
						--end
						local dmg = DamageInfo()
						dmg:SetDamageType(DMG_SLASH)
						dmg:SetDamage(4)
						dmg:SetDamagePosition(tr.HitPos)
						dmg:SetAttacker(self.Owner)
						dmg:SetInflictor(self)
						if SERVER then
							tr.Entity:TakeDamageInfo(dmg)
							
							if item.ammo == "models/props_forest/saw_blade.mdl" or 
								item.ammo == "models/props_forest/saw_blade_large.mdl" or
								item.ammo == "models/props_forest/sawblade_moving.mdl" or
								item.ammo == "models/props_swamp/chainsaw.mdl" then
								if IsValid(self.ef_pblade) then
									if (tr.Entity:GetMaterialType() == MAT_FLESH or tr.Entity:GetMaterialType() == MAT_BLOODYFLESH) or --ragdolls, props
										(tr.Entity:GetBloodColor() == BLOOD_COLOR_RED or tr.Entity:GetBloodColor() == BLOOD_COLOR_ZOMBIE or tr.Entity:GetBloodColor() == BLOOD_COLOR_GREEN) then --NPCs
										self.ef_pblade:SetSkin(1) --Set the bloodied skin on the model
									end
								end
							end
						end
					end
					if tr.Hit then
						local edata = EffectData()
						edata:SetOrigin(tr.HitPos)
						edata:SetNormal(tr.HitNormal)
						edata:SetEntity(tr.Entity)
						if tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ALIENFLESH or tr.MatType == MAT_ANTLION then
							if item.ammo == "models/props_forest/saw_blade.mdl" or 
								item.ammo == "models/props_forest/saw_blade_large.mdl" or
								item.ammo == "models/props_forest/sawblade_moving.mdl" or
								item.ammo == "models/props_swamp/chainsaw.mdl" then
									sound.Play("ambient/sawblade_impact"..math.floor(math.Rand(1,3))..".wav",tr.HitPos,75,100,0.25)
							else
								sound.Play("npc/manhack/grind_flesh"..math.random(1,3)..".wav",tr.HitPos)
							end
							--self.Owner:ViewPunch(Angle(math.Rand(-1,-3),0,0))
							--if tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH then
								util.Effect("BloodImpact",edata,true,true)
							--else
							--	util.Effect("BloodImpactButYellow",edata,true,true) --TODO: yellow blood
							--end
						else
							sound.Play("npc/manhack/grind"..math.random(1,5)..".wav",tr.HitPos)
							--self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2),0,0))
							util.Effect("ManhackSparks",edata,true,true)
						end
					end
					if SERVER then
						self:AddBarrelSpin(100)
						self:TakeSubammo(item,1)
					end
					local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
					if not continuefiring then
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
						if item.ammo == "models/props_forest/saw_blade.mdl" or 
							item.ammo == "models/props_forest/saw_blade_large.mdl" or
							item.ammo == "models/props_swamp/chainsaw.mdl" or
							item.ammo == "models/props_forest/sawblade_moving.mdl" then
							self.ef_pblade = self:CreateToggleEffect("scav_stream_saw_tf2")
						else
							self.ef_pblade = self:CreateToggleEffect("scav_stream_saw")
						end
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,ent:GetSkin(),1) end
					ScavData.CollectFuncs["models/props_c17/grinderclamp01a.mdl"] = ScavData.GiveOneOfItemInf -- I'M GONNA PUT SOMEBODY IN A MEAT GRINDER -Jerma 2022
					ScavData.CollectFuncs["models/manhack.mdl"] = ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"]
					ScavData.CollectFuncs["models/police.mdl"] = function(self,ent)
						self:AddItem("models/police.mdl",1,0,1)
						if tobool(ent:GetBodygroup(ent:FindBodygroupByName("manhack"))) then
							self:AddItem("models/manhack.mdl",250,0,1)
						end
					end
					--Ep2
					ScavData.CollectFuncs["models/props_forest/circularsaw01.mdl"] = ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"]
					--CSS
					ScavData.CollectFuncs["models/props/cs_militia/circularsaw01.mdl"] = ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"]
					--TF2
					ScavData.CollectFuncs["models/props_forest/saw_blade.mdl"] = ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"]
					ScavData.CollectFuncs["models/props_forest/saw_blade_large.mdl"] = ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"]
					ScavData.CollectFuncs["models/props_forest/sawblade_moving.mdl"] = ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"]
					ScavData.CollectFuncs["models/props_swamp/chainsaw.mdl"] = ScavData.CollectFuncs["models/props_junk/sawblade001a.mdl"]
					--L4D2
					ScavData.CollectFuncs["models/weapons/melee/w_chainsaw.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),1000,ent:GetSkin(),1) end
				end
				ScavData.RegisterFiremode(tab,"models/props_junk/sawblade001a.mdl")
				ScavData.RegisterFiremode(tab,"models/props_c17/grinderclamp01a.mdl")
				ScavData.RegisterFiremode(tab,"models/manhack.mdl")
				--Ep2
				ScavData.RegisterFiremode(tab,"models/props_forest/circularsaw01.mdl")
				--CSS
				ScavData.RegisterFiremode(tab,"models/props/cs_militia/circularsaw01.mdl")
				--TF2
				ScavData.RegisterFiremode(tab,"models/props_forest/saw_blade.mdl")
				ScavData.RegisterFiremode(tab,"models/props_forest/saw_blade_large.mdl")
				ScavData.RegisterFiremode(tab,"models/props_forest/sawblade_moving.mdl")
				ScavData.RegisterFiremode(tab,"models/props_swamp/chainsaw.mdl")
				--L4D2
				ScavData.RegisterFiremode(tab,"models/weapons/melee/w_chainsaw.mdl")
		end

--[[==============================================================================================
	--Personal Shield
==============================================================================================]]--

		do
			local tab = {}
				tab.Name = "Personal Shield"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.Cooldown = 0.025
				tab.Health = 40
				local tracep = {}
				tracep.mins = Vector(-12,-12,-12)
				tracep.maxs = Vector(12,12,12)
				function tab.ChargeAttack(self,item)
					if SERVER then
						self:AddBarrelSpin(25)
					end
					local continuefiring = self:StopChargeOnRelease()
					if not continuefiring then
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
						self.ef_pblade = self:CreateToggleEffect("scav_stream_shield")
						self.ef_pblade:SetCollisionGroup(COLLISION_GROUP_BREAKABLE_GLASS)
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				-- function tab.Think(self,item) --I have no idea what I'm doing
				-- 	if IsValid(self.ef_pblade) then
				-- 		tab.mins, tab.maxs = self.ef_pblade:GetCollisionBounds()
				-- 	end
				-- end
				function tab.Break(self,item)
					if IsValid(self.ef_pblade) then
						local tr = self.Owner:GetEyeTrace()
						self.ef_pblade:GibBreakClient( tr.HitNormal * -100)
						timer.Simple(0,function() self.ef_pblade:Kill() end)
					end
					return true
				end
				ScavData.RegisterFiremode(tab,"models/props_italian/ava_stained_glass.mdl")
		end

--[[==============================================================================================
	--Laser Beam
==============================================================================================]]--

		do
			local tab = {}
				tab.Name = "#scav.scavcan.laser"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				tab.MaxAmmo = 300
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
							if not game.SinglePlayer() and SERVER then
								if IsValid(tr.Entity) and tr.Entity.Health then
									if not (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) and tr.Entity:Health() ~= 0 and tr.Entity:Health() <= 5 then
										if tr.Entity:GetClass() ~= "func_breakable_surf" then
											tr.Entity:Fire("break","",0,self.Owner,self)
										else
											tr.Entity:Fire("shatter","(0.5,0.5,0)",0,self.Owner,self)
										end
									else
										tr.Entity:TakeDamageInfo(dmg)
									end
								end
							else
								tr.Entity:TakeDamageInfo(dmg)
							end
						end
						self:AddBarrelSpin(200)
						self:TakeSubammo(item,1)
					end
					local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
					if not continuefiring then
						if IsValid(self.ef_beam) then
							self.ef_beam:Kill()
						end
						self:SetChargeAttack()
						return 0.25
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
					ScavData.CollectFuncs["models/roller.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,ent:GetSkin(),1) end
					ScavData.CollectFuncs["models/roller_spikes.mdl"] = ScavData.CollectFuncs["models/roller.mdl"]
					ScavData.CollectFuncs["models/roller_vehicledriver.mdl"] = ScavData.CollectFuncs["models/roller.mdl"]
					ScavData.CollectFuncs["models/stalker.mdl"]	= ScavData.CollectFuncs["models/roller.mdl"]
				end
				ScavData.RegisterFiremode(tab,"models/roller.mdl")
				ScavData.RegisterFiremode(tab,"models/roller_spikes.mdl")
				ScavData.RegisterFiremode(tab,"models/roller_vehicledriver.mdl")
				ScavData.RegisterFiremode(tab,"models/stalker.mdl")
		end
		
--[[==============================================================================================
	--Arc Beam
==============================================================================================]]--

		do
			local tab = {}
				tab.Name = "#scav.scavcan.arcbeam"
				tab.chargeanim = ACT_VM_FIDGET
				tab.Level = 6
				tab.MaxAmmo = 300
				tab.Cooldown = 0.01
				function tab.ChargeAttack(self,item)
					if SERVER then
						self:SetPanelPoseInstant(0.4,6)
						self:SetBlockPoseInstant(1,1)
						self:TakeSubammo(item,1)
					end
					local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
					if not continuefiring then
						if IsValid(self.ef_parc) then
							self.ef_parc:Kill()
						end
						self:SetChargeAttack()
						--tab.anim = ACT_VM_IDLE
						return 0.25
					end
					--tab.anim = ACT_VM_FIDGET
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
					ScavData.CollectFuncs["models/props_lab/tpplug.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),100,ent:GetSkin(),1) end
					ScavData.CollectFuncs["models/props_lab/tpplugholder.mdl"] = function(self,ent) self:AddItem("models/props_lab/tpplug.mdl",100,0,2) end
					ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,0,1) end
					ScavData.CollectFuncs["models/props_c17/utilityconnecter006c.mdl"] = ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"]
					ScavData.CollectFuncs["models/props_c17/substation_circuitbreaker01a.mdl"] = ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"]
					ScavData.CollectFuncs["models/props_c17/substation_stripebox01a.mdl"] = ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"]
					--Ep2
					ScavData.CollectFuncs["models/props_lab/incubatorplug.mdl"] = ScavData.CollectFuncs["models/props_lab/tpplug.mdl"]
					ScavData.CollectFuncs["models/props_lab/power_cable001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/props_lab/tpplug.mdl"),100,0,2) end
					ScavData.CollectFuncs["models/props_lab/power_cable002a.mdl"] = ScavData.CollectFuncs["models/props_lab/power_cable001a.mdl"]
					--TF2
					ScavData.CollectFuncs["models/props_hydro/substation_transformer01.mdl"] = ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"]
					ScavData.CollectFuncs["models/props_swamp/bug_zapper.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),50,0,1) end
					ScavData.CollectFuncs["models/weapons/c_models/c_dex_arm/c_dex_arm.mdl"] = ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"]
					ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_dex_arm/c_dex_arm.mdl"]
					--L4D/2
					ScavData.CollectFuncs["models/props_shacks/bug_lamp01.mdl"] = ScavData.CollectFuncs["models/props_swamp/bug_zapper.mdl"]
					ScavData.CollectFuncs["models/props_c17/substation_circuitbreaker03.mdl"] = ScavData.CollectFuncs["models/props_c17/substation_circuitbreaker01a.mdl"]
					--ASW
					ScavData.CollectFuncs["models/items/teslacoil/teslacoil.mdl"] = ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"]
					ScavData.CollectFuncs["models/weapons/mininglaser/mininglaser.mdl"] = ScavData.CollectFuncs["models/props_c17/utilityconnecter006.mdl"]
				end
				ScavData.RegisterFiremode(tab,"models/props_lab/tpplug.mdl")
				ScavData.RegisterFiremode(tab,"models/props_c17/utilityconnecter006.mdl")
				ScavData.RegisterFiremode(tab,"models/props_c17/utilityconnecter006c.mdl")
				ScavData.RegisterFiremode(tab,"models/props_c17/substation_circuitbreaker01a.mdl")
				ScavData.RegisterFiremode(tab,"models/props_c17/substation_stripebox01a.mdl")
				--Ep2
				ScavData.RegisterFiremode(tab,"models/props_lab/incubatorplug.mdl")
				--TF2
				ScavData.RegisterFiremode(tab,"models/props_hydro/substation_transformer01.mdl")
				ScavData.RegisterFiremode(tab,"models/props_swamp/bug_zapper.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_dex_arm/c_dex_arm.mdl")
				ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl")
				--L4D/2
				ScavData.RegisterFiremode(tab,"models/props_shacks/bug_lamp01.mdl")
				ScavData.RegisterFiremode(tab,"models/props_c17/substation_circuitbreaker03.mdl")
				--ASW
				ScavData.RegisterFiremode(tab,"models/items/teslacoil/teslacoil.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/mininglaser/mininglaser.mdl")
		end

--[[==============================================================================================
	--TF2 Medigun
==============================================================================================]]--

		do
			local tab = {}
				tab.Name = "#scav.scavcan.medigun"
				tab.chargeanim = ACT_VM_FIDGET
				tab.Level = 6
				tab.Cooldown = 0.01
				function tab.ChargeAttack(self,item)
					if SERVER then
						self:SetBlockPoseInstant(1,1)
					end
					local continuefiring = self:StopChargeOnRelease()
					if not continuefiring then
						if IsValid(self.ef_medigun) then
							self.ef_medigun:Kill()
						end
						self:SetChargeAttack()
						--tab.anim = ACT_VM_IDLE
						return 0.05
					end
					--tab.anim = ACT_VM_FIDGET
					return 0.05
				end
				function tab.FireFunc(self,item)
					if SERVER then
						self.ef_medigun = self:CreateToggleEffect("scav_stream_medigun")
						self.ef_medigun:Setblue((item.data == 1))
					end
					self:SetChargeAttack(tab.ChargeAttack,item)
					return false
				end
				if SERVER then
					--TF2
					ScavData.CollectFuncs["models/weapons/c_models/c_medigun/c_medigun.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/weapons/w_models/w_medigun.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/weapons/c_models/c_proto_backpack/c_proto_backpack.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/weapons/c_models/c_medigun_defense/c_medigun_defense.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/weapons/c_models/c_medigun_defense/c_medigun_defensepack.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/workshop/weapons/c_models/c_medigun_defense/c_medigun_defense.mdl"] =	ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/workshop/weapons/c_models/c_medigun_defense/c_medigun_defensepack.mdl"] =	ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/buildables/dispenser_light.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/buildables/dispenser.mdl"] = function(self,ent) self:AddItem("models/buildables/dispenser_light.mdl",SCAV_SHORT_MAX,ent:GetSkin(),1) end
					ScavData.CollectFuncs["models/buildables/dispenser_lvl2_light.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/buildables/dispenser_lvl2.mdl"] = function(self,ent) self:AddItem("models/buildables/dispenser_lvl2_light.mdl",SCAV_SHORT_MAX,ent:GetSkin(),1) end
					ScavData.CollectFuncs["models/buildables/dispenser_lvl3_light.mdl"] = ScavData.GiveOneOfItemInf
					ScavData.CollectFuncs["models/buildables/dispenser_lvl3.mdl"] = function(self,ent) self:AddItem("models/buildables/dispenser_lvl3_light.mdl",SCAV_SHORT_MAX,ent:GetSkin(),1) end
					--ASW
					ScavData.CollectFuncs["models/weapons/healgun/healgun.mdl"] =	ScavData.GiveOneOfItemInf
				end
				--TF2
				ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_medigun/c_medigun.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_medigun.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_proto_backpack/c_proto_backpack.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_medigun_defense/c_medigun_defense.mdl")
				ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_medigun_defense/c_medigun_defensepack.mdl")
				ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_medigun_defense/c_medigun_defense.mdl")
				ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_medigun_defense/c_medigun_defensepack.mdl")
				ScavData.RegisterFiremode(tab,"models/buildables/dispenser_light.mdl")
				ScavData.RegisterFiremode(tab,"models/buildables/dispenser_lvl2_light.mdl")
				ScavData.RegisterFiremode(tab,"models/buildables/dispenser_lvl3_light.mdl")
				--ASW
				ScavData.RegisterFiremode(tab,"models/weapons/healgun/healgun.mdl")
		end

--[[==============================================================================================
	--GammaBeam
==============================================================================================]]--
		
		PrecacheParticleSystem("scav_exp_rad")
		
		local tab = {}
			tab.Name = "#scav.scavcan.gammaray"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 7
			tab.MaxAmmo = 10
			tab.vmin = Vector(-4,-4,-4)
			tab.vmax = Vector(4,4,4)
			tab.dmginfo = DamageInfo()
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
				local isspot = false
				if SERVER then
					for i=1,32 do
						tr = util.TraceHull(tracep)
						local ent = tr.Entity
						--prevent a bunch of radioactive spots from being spammed on top of one another
						if not isspot then
							local nearby = ents.FindInSphere(tr.HitPos,300)
							for k,v in ipairs(nearby) do
								if v:GetName() == "ScavGun_GammaRay_WorldSpot" then
									isspot = true
									break
								end
							end
						end
						--make a spot on the world for us to make radioactive
						if not isspot and (not IsValid(ent) or ent:IsWorld()) then
							ent = ents.Create("prop_physics")
							if IsValid(ent) then
								isspot = true
								ent:SetModel("models/props_junk/popcan01a.mdl")
								ent:SetPos(tr.HitPos)
								ent:SetRenderMode(RENDERMODE_NONE)
								ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
								ent:Spawn()
								ent:PhysicsDestroy()
								ent:SetName("ScavGun_GammaRay_WorldSpot")
								ent:Fire("kill",nil,5)
							end
						end
						if IsValid(ent) and not ent:IsWorld() then
							if not ent:IsFriendlyToPlayer(self.Owner) then
								ent:InflictStatusEffect("Radiation",10,3,self.Owner)
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
				else
					while (true) do
						tr = util.TraceHull(tracep)
						local ent = tr.Entity
						if IsValid(ent) and not ent:IsWorld() then
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
				end
				local efdata = EffectData()
				efdata:SetEntity(self)
				efdata:SetOrigin(self:GetPos())
				efdata:SetStart(tr.HitPos)
				util.Effect("ef_scav_radbeam",efdata)
				self:MuzzleFlash2(4)
				self.nextfireearly = CurTime()+0.1
				--self.Owner:ScavViewPunch(Angle(math.Rand(-3,-4),math.Rand(-2,2),0),0.25)
				if SERVER then
					self:AddBarrelSpin(1000)
					self.Owner:EmitSound("npc/scanner/scanner_electric2.wav")
					return self:TakeSubammo(item,1)
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/scav/rad_hl2.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin(),1) end
				ScavData.CollectFuncs["models/props_lab/crystalbulk.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin(),1) end
				--Ep2
				ScavData.CollectFuncs["models/props_silo/silo_workspace1.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname("models/scav/rad_hl2.mdl"),10,0,3) end -- 3 cases from workstation
				--CSS
				ScavData.CollectFuncs["models/props/de_nuke/nuclearcontainerboxclosed.mdl"] = ScavData.CollectFuncs["models/props_lab/crystalbulk.mdl"]
				ScavData.CollectFuncs["models/props_badlands/barrel03.mdl"] = ScavData.CollectFuncs["models/props/de_nuke/nuclearcontainerboxclosed.mdl"]
				--TF2
				ScavData.CollectFuncs["models/props_badlands/barrel_flatbed01.mdl"] = function(self,ent) self:AddItem("models/props_badlands/barrel03.mdl",10,ent:GetSkin(),3) end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab,"models/scav/rad_hl2.mdl")
		ScavData.RegisterFiremode(tab,"models/props_lab/crystalbulk.mdl")
		--CSS
		ScavData.RegisterFiremode(tab,"models/props/de_nuke/nuclearcontainerboxclosed.mdl")
		--TF2
		ScavData.RegisterFiremode(tab,"models/props_badlands/barrel03.mdl")

--[[==============================================================================================
	--Phazon Beam
==============================================================================================]]--
		PrecacheParticleSystem("scav_exp_phazon_1")
		PrecacheParticleSystem("scav_vm_phazon")
		local tab = {}
			tab.Name = "#scav.scavcan.phazon"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.chargeanim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
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
					if IsValid(tr.Entity) then
						dmg:SetAttacker(self.Owner)
						dmg:SetInflictor(self)
						dmg:SetDamagePosition(tr.HitPos)
						if string.find(tr.Entity:GetClass(),"npc_antlion") then
							dmg:SetDamageType(bit.bor(DMG_BUCKSHOT,DMG_ALWAYSGIB)) --TODO: figure out what god damn combination of damage types make all the different types of antlions die how they're supposed to
						else
							dmg:SetDamageType(bit.bor(DMG_ENERGYBEAM,DMG_RADIATION,DMG_BLAST,DMG_GENERIC,DMG_ALWAYSGIB,DMG_DISSOLVE))
						end
						dmg:SetDamage(4)
						dmg:SetDamageForce(tr.Normal*24000)
						if tr.Entity:IsNPC() and SERVER then
							--tr.Entity:SetSchedule(SCHED_BIG_FLINCH)
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
						if SERVER then tr.Entity:TakeDamageInfo(dmg) end
					end
				end
				
					local edata = EffectData()
					edata:SetOrigin(self.Owner:GetShootPos())
					edata:SetEntity(self.Owner)
					edata:SetNormal(self:GetAimVector())
					util.Effect("ef_scav_phazon",edata)
					util.Effect("ef_scav_phazon",edata)
					if SERVER then
						self.Owner:EmitSound("weapons/physcannon/energy_sing_flyby"..math.random(1,2)..".wav",100,255)
						self:TakeSubammo(item,1)
					else
						local vmdl = self.Owner:GetViewModel()
						if IsValid(vmdl) then
							ParticleEffectAttach("scav_vm_phazon",PATTACH_POINT_FOLLOW,vmdl,vmdl:LookupAttachment("muzzle"))
						end
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:ProcessLinking(item)
					self:StopChargeOnRelease()
					return 0.025		
				end
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(ScavData.models["models/dav0r/hoverball.mdl"].ChargeAttack,item)
				self.Owner:EmitSound("ambient/fire/gascan_ignite1.wav",100,90)
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/dav0r/hoverball.mdl"] = ScavData.GiveOneOfItemInf
				--ScavData.CollectFuncs["models/props_trainstation/payphone001a.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),80,ent:GetSkin(),1) end
			end
			tab.Cooldown = 0.025 --40/sec

			ScavData.RegisterFiremode(tab,"models/dav0r/hoverball.mdl")
			--ScavData.RegisterFiremode(tab,"models/props_trainstation/payphone001a.mdl")

--[[==============================================================================================
	--Minigun
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.minigun"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 5
			tab.MaxAmmo = 200
			tab.BarrelRestSpeed = 1000
			tab.ChargeAttack = function(self,item)
				if self.Owner:KeyDown(IN_ATTACK) then
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
					if not game.SinglePlayer() or (game.SinglePlayer() and SERVER) then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					if CLIENT and game.SinglePlayer() then
						if not self.Owner:Crouching() or not (IsValid(self.Owner:GetGroundEntity()) or self.Owner:GetGroundEntity():IsWorld()) then
							self.Owner:SetEyeAngles((VectorRand()*0.1+self:GetAimVector()):Angle()) --BUG TODO: Very choppy
						else
							self.Owner:SetEyeAngles((VectorRand()*0.02+self:GetAimVector()):Angle())
						end
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					timer.Simple(.025,function()
						if not self.Owner:GetViewModel() then return end
						local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
						if attach then
							if item.ammo == "models/w_models/weapons/50cal.mdl"
							or item.ammo == "models/w_models/weapons/w_minigun.mdl"
							or item.ammo == "models/weapons/gatling_top.mdl" then
								if SERVER then
									local ef = EffectData()
										ef:SetOrigin(attach.Pos)
										ef:SetAngles(attach.Ang)
										ef:SetEntity(self)
									util.Effect("RifleShellEject",ef)
								end
							else --TF2
								if CLIENT then
									tf2shelleject(self,"minigun")
								end
							end
						end
					end)
					if SERVER then 
						self:TakeSubammo(item,1)
					end
				end
				local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
				if not continuefiring then
					if SERVER then
						self.soundloops.minigunfire:Stop()
						self.soundloops.minigunspin:Stop()
						self.Owner:EmitSound("weapons/minigun_wind_down.wav")
						self:SetChargeAttack()
						self:SetBarrelRestSpeed(0)
					end
					return 2
				else
					if SERVER then
						self.soundloops.minigunfire:Play()
						self.soundloops.minigunspin:Play()
					end
					return 0.05
				end
			end
			tab.FireFunc = function(self,item)
				self:SetChargeAttack(ScavData.models["models/weapons/w_models/w_minigun.mdl"].ChargeAttack,item)
				if SERVER then
					self.Owner:EmitSound("weapons/minigun_wind_up.wav")
					self.soundloops.minigunspin = CreateSound(self.Owner,"weapons/minigun_spin.wav")
					self.soundloops.minigunfire = CreateSound(self.Owner,"weapons/minigun_shoot.wav")
					self:SetBarrelRestSpeed(900)
				end								
				return false
			end
			if SERVER then
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"] = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()),200,ent:GetSkin()) end
				ScavData.CollectFuncs["models/weapons/c_models/c_canton/c_canton.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_canton/c_canton.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_canton/c_canton.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_tomislav/c_tomislav.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_tomislav/c_tomislav.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_tomislav/c_tomislav.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_minigun/c_minigun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_minigun/c_minigun_natascha.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				--L4D/2
				ScavData.CollectFuncs["models/w_models/weapons/50cal.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				ScavData.CollectFuncs["models/w_models/weapons/w_minigun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				ScavData.CollectFuncs["models/w_models/weapons/50_cal_broken.mdl"] = function(self,ent) self:AddItem("models/w_models/weapons/50cal.mdl",200,0) end
				--ASW
				ScavData.CollectFuncs["models/weapons/autogun/autogun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				ScavData.CollectFuncs["models/weapons/minigun/minigun.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
				--FoF
				ScavData.CollectFuncs["models/weapons/gatling_top.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_minigun.mdl"]
			end
			tab.Cooldown = 1
			
		--TF2
		ScavData.RegisterFiremode(tab,"models/weapons/w_models/w_minigun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_canton/c_canton.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop_partner/weapons/c_models/c_canton/c_canton.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_tomislav/c_tomislav.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_tomislav/c_tomislav.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl")
		ScavData.RegisterFiremode(tab,"models/workshop/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_minigun/c_minigun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_minigun/c_minigun_natascha.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/50cal.mdl")
		ScavData.RegisterFiremode(tab,"models/w_models/weapons/w_minigun.mdl")
		--ASW
		ScavData.RegisterFiremode(tab,"models/weapons/autogun/autogun.mdl")
		ScavData.RegisterFiremode(tab,"models/weapons/minigun/minigun.mdl")
		--FoF
		ScavData.RegisterFiremode(tab,"models/weapons/gatling_top.mdl")

		
--[[==============================================================================================
	--Misc Goodies Giving
==============================================================================================]]--

	--Radioactive/Biohazard Barrels
		local tab = {}
			function tab.GetName(self,item)
				if (item:GetData() > 1) and (item:GetData() < 7) then
					return "#scav.scavcan.disease"
				else
					return "#scav.scavcan.gammaray"
				end
			end
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			tab.FireFunc = function(self,item)
				local tab = ScavData.models["models/props/de_train/barrel.mdl"]
				if (item.data > 1) and (item.data < 7) then
					tab.Cooldown = ScavData.models["models/props/de_train/biohazardtank.mdl"].Cooldown
					tab.anim = ScavData.models["models/props/de_train/biohazardtank.mdl"].anim
					if SERVER then --no clientside firefunction here
						return ScavData.models["models/props/de_train/biohazardtank.mdl"].FireFunc(self,item)
					else
						return true
					end
				else
					tab.Cooldown = ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].Cooldown
					tab.anim = ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].anim
					return ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].FireFunc(self,item)
				end
			end
			if SERVER then
				tab.OnArmed = function(self,item,olditemname)
					if (item.ammo ~= olditemname) and ((item.data < 2) or (item.data > 6)) then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
				ScavData.CollectFuncs["models/props/de_train/barrel.mdl"] = function(self,ent) if (ent:GetSkin() > 1) and (ent:GetSkin() < 7) then self:AddItem(ScavData.FormatModelname(ent:GetModel()),1,ent:GetSkin()) else self:AddItem(ScavData.FormatModelname(ent:GetModel()),10,ent:GetSkin()) end end
				ScavData.CollectFuncs["models/props/de_train/pallet_barrels.mdl"] = function(self,ent) self:AddItem("models/props/de_train/barrel.mdl",1,2) self:AddItem("models/props/de_train/barrel.mdl",1,3) self:AddItem("models/props/de_train/barrel.mdl",1,4) self:AddItem("models/props/de_train/barrel.mdl",1,5) end
			end
			tab.Cooldown = 0.1
			ScavData.RegisterFiremode(tab,"models/props/de_train/barrel.mdl")

	--Bonk/Crit-A-Cola
		local tab = {}
			function tab.GetName(self,item)
				if item:GetData() > 1 then
					return "#scav.scavcan.crit"
				else
					return "#scav.scavcan.stim"
				end
			end
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.FireFunc = function(self,item)
				local tab = ScavData.models["models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"]
				if item.data > 1 then
					tab.Cooldown = ScavData.models["models/weapons/w_package.mdl"].Cooldown
					tab.anim = ScavData.models["models/weapons/w_package.mdl"].anim
					if SERVER then return ScavData.models["models/weapons/w_package.mdl"].FireFunc(self,item) end
				else
					tab.Cooldown = ScavData.models["models/items/powerup_speed.mdl"].Cooldown
					tab.anim = ScavData.models["models/items/powerup_speed.mdl"].anim
					if SERVER then return ScavData.models["models/items/powerup_speed.mdl"].FireFunc(self,item) end
				end
			end
			if SERVER then
				tab.OnArmed = function(self,item,olditemname)
						self.Owner:EmitSound("player/pl_scout_dodge_can_open.wav")
				end
			end
			tab.Cooldown = 0.1
			ScavData.RegisterFiremode(tab,"models/weapons/c_models/c_energy_drink/c_energy_drink.mdl")

		local tab = {}
			if SERVER then
				ScavData.CollectFuncs["models/items/ammopack_small.mdl"] = function(self,ent)
					self:AddItem("models/weapons/shells/shell_shotgun.mdl",1,0,2)
					self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0,1)
				end
				ScavData.CollectFuncs["models/items/ammopack_small_bday.mdl"] = ScavData.CollectFuncs["models/items/ammopack_small.mdl"]
				ScavData.CollectFuncs["models/items/ammopack_medium.mdl"] = function(self,ent)
					self:AddItem("models/weapons/shells/shell_shotgun.mdl",1,0,4)
					self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0,2)
				end
				ScavData.CollectFuncs["models/items/ammopack_medium_bday.mdl"] = ScavData.CollectFuncs["models/items/ammopack_medium.mdl"]
				ScavData.CollectFuncs["models/items/ammopack_large.mdl"] = function(self,ent)
					self:AddItem("models/weapons/w_models/w_rocket.mdl",1,0,2)
					self:AddItem("models/weapons/w_models/w_minigun.mdl",50,0)
				end
				ScavData.CollectFuncs["models/items/ammopack_large_bday.mdl"] = ScavData.CollectFuncs["models/items/ammopack_large.mdl"]
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
				--Ep2
				ScavData.CollectFuncs["models/vehicle.mdl"] = function(self,ent)
					self:AddItem("models/vehicle/vehicle_engine_block.mdl",1,0)
					self:AddItem("models/props_vehicles/carparts_tire01a.mdl",1,0)
					self:AddItem("models/props_vehicles/carparts_axel01a.mdl",1,0)
					self:AddItem("models/props_vehicles/carparts_muffler01a.mdl",1,0)
					self:AddItem("models/props_vehicles/carparts_wheel01a.mdl",1,0)
					self:AddItem("models/props_vehicles/carparts_wheel01a.mdl",1,0)
					self:AddItem("models/props_vehicles/carparts_tire01a.mdl",1,0)
					self:AddItem("models/props_vehicles/carparts_axel01a.mdl",1,0)
					self:AddItem("models/items/car_battery01.mdl",20,0)
				end
				--Breaking up big cluster props into smaller ones
				ScavData.CollectFuncs["models/zombie/classic.mdl"] = function(self,ent)
					self:AddItem("models/zombie/classic_legs.mdl",1,0,1)
					self:AddItem("models/zombie/classic_torso.mdl",1,0,1)
					--main reason for these zombie pickups is that we can't get the bodygroup in the gun, so we'll separate the headcrab if it's present
					if tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
						self:AddItem("models/headcrabclassic.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/zombie/classic_torso.mdl"] = function(self,ent)
					self:AddItem("models/zombie/classic_torso.mdl",1,0,1)
					if tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
						self:AddItem("models/headcrabclassic.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/zombie/fast.mdl"] = function(self,ent)
					self:AddItem("models/gibs/fast_zombie_legs.mdl",1,0,1)
					self:AddItem("models/gibs/fast_zombie_torso.mdl",1,0,1)
					if tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
						self:AddItem("models/headcrab.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/zombie/fast_torso.mdl"] = function(self,ent)
					self:AddItem("models/Gibs/fast_zombie_torso.mdl",1,0,1)
					if tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
						self:AddItem("models/headcrab.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/props_junk/garbage128_composite001a.mdl"] = function(self,ent)
					self:AddItem("models/props_junk/garbage_plasticbottle001a.mdl",50,0,1)
					self:AddItem("models/props_junk/garbage_milkcarton002a.mdl",1,0,1)
					if IsMounted(550) or IsMounted(500) then --L4D/L4D2
						self:AddItem("models/props_junk/garbage_coffeecup01a.mdl",1,0,1)
						self:AddItem("models/props_junk/garbage_spraypaintcan01a.mdl",30,0,1)
						self:AddItem("models/props_junk/garbage_fastfoodcontainer01a.mdl",1,0,1)
					end
					self:AddItem("models/props_junk/garbage_metalcan001a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_syringeneedle001a.mdl",1,0,3)
				end
				ScavData.CollectFuncs["models/props_junk/garbage128_composite001b.mdl"] = function(self,ent)
					self:AddItem("models/props_junk/garbage_metalcan002a.mdl",1,0,1)
					self:AddItem("models/props_canal/mattpipe.mdl",1,0,2)
					self:AddItem("models/props_junk/garbage_glassbottle003a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_glassbottle002a.mdl",1,0,1)
					if IsMounted(550) or IsMounted(500) then --L4D/L4D2
						self:AddItem("models/props_junk/garbage_fastfoodcontainer01a.mdl",1,0,1)
					end
					self:AddItem("models/props_junk/garbage_metalcan001a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_syringeneedle001a.mdl",1,0,1)
				end
				ScavData.CollectFuncs["models/props_junk/garbage128_composite001c.mdl"] = function(self,ent)
					self:AddItem("models/props_junk/garbage_plasticbottle001a.mdl",50,0,1)
					self:AddItem("models/props_junk/garbage_plasticbottle002a.mdl",50,0,2)
					self:AddItem("models/props_junk/garbage_milkcarton001a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_energydrinkcan001a.mdl",1,0,3)
					if IsMounted(550) or IsMounted(500) then --L4D/L4D2
						self:AddItem("models/props_junk/garbage_coffeecup01a.mdl",1,0,2)
					end
					self:AddItem("models/props_junk/garbage_plasticbottle003a.mdl",1,0,3)
					self:AddItem("models/props_junk/garbage_metalcan002a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_metalcan001a.mdl",1,0,2)
					self:AddItem("models/props_junk/garbage_glassbottle003a.mdl",1,0,1)
				end
				ScavData.CollectFuncs["models/props_junk/garbage128_composite001d.mdl"] = function(self,ent)
					self:AddItem("models/props_junk/garbage_plasticbottle001a.mdl",50,0,2)
					self:AddItem("models/props_junk/garbage_plasticbottle002a.mdl",50,0,1)
					self:AddItem("models/props_junk/garbage_milkcarton001a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_energydrinkcan001a.mdl",1,0,3)
					if IsMounted(550) or IsMounted(500) then --L4D/L4D2
						self:AddItem("models/props_junk/garbage_coffeecup01a.mdl",1,0,1)
						self:AddItem("models/props_junk/garbage_spraypaintcan01a.mdl",30,0,2)
					end
					self:AddItem("models/props_junk/garbage_plasticbottle003a.mdl",1,0,2)
				end
				ScavData.CollectFuncs["models/props_junk/garbage256_composite001a.mdl"] = function(self,ent)
					self:AddItem("models/props_junk/garbage_metalcan002a.mdl",1,0,3)
					self:AddItem("models/props_junk/garbage_glassbottle003a.mdl",1,0,2)
					self:AddItem("models/props_vehicles/carparts_muffler01a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_syringeneedle001a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_energydrinkcan001a.mdl",1,0,1)
					if IsMounted(550) or IsMounted(500) then --L4D/L4D2
						self:AddItem("models/props_junk/garbage_spraypaintcan01a.mdl",30,0,1)
					end
					self:AddItem("models/props_junk/garbage_glassbottle002a.mdl",1,0,1)
				end
				ScavData.CollectFuncs["models/props_junk/garbage256_composite001b.mdl"] = function(self,ent)
					self:AddItem("models/props_junk/garbage_metalcan002a.mdl",1,0,3)
					self:AddItem("models/props_junk/garbage_plasticbottle002a.mdl",50,0,1)
					self:AddItem("models/props_junk/garbage_glassbottle003a.mdl",1,0,2)
					self:AddItem("models/props_junk/garbage_takeoutcarton001a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_syringeneedle001a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_plasticbottle003a.mdl",1,0,1)
					if IsMounted(550) or IsMounted(500) then --L4D/L4D2
						self:AddItem("models/props_junk/garbage_coffeecup01a.mdl",1,0,1)
						self:AddItem("models/props_junk/garbage_fastfoodcontainer01a.mdl",1,0,2)
						self:AddItem("models/props_junk/garbage_frenchfrycup01a.mdl",1,0,1)
					end
					self:AddItem("models/props_junk/garbage_glassbottle002a.mdl",1,0,1)
					self:AddItem("models/props_junk/garbage_milkcarton002a.mdl",1,0,1)
				end
				ScavData.CollectFuncs["models/props_junk/garbage256_composite002a.mdl"] = function(self,ent)
					for i=1,4 do
						self:AddItem("models/props_junk/garbage_carboard00" .. tostring(math.Round(math.random(2))) .. "a.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/props_junk/garbage256_composite002b.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage256_composite002a.mdl"]
				ScavData.CollectFuncs["models/props_junk/ibeam01a_cluster01.mdl"] = function(self,ent) self:AddItem("models/props_junk/ibeam01a.mdl",1,0,4) end
				ScavData.CollectFuncs["models/props_lab/securitybank.mdl"] = function(self,ent)
					self:AddItem(ScavData.FormatModelname("models/props_c17/consolebox05a.mdl"),8,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/powerbox02a.mdl"),8,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_lab/citizenradio.mdl"),10,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor01b.mdl"),1,0,4)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor02.mdl"),1,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/clipboard.mdl"),1,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_c17/computer01_keyboard.mdl"),1,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_lab/harddrive02.mdl"),SCAV_SHORT_MAX,0,1) -- only need one, they're infinite
					self:AddItem(ScavData.FormatModelname("models/props_wasteland/controlroom_desk001a.mdl"),1,0,1)
				end
				ScavData.CollectFuncs["models/props_lab/servers.mdl"] = function(self,ent)
					self:AddItem(ScavData.FormatModelname("models/props_c17/consolebox05a.mdl"),8,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/citizenradio.mdl"),10,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor02.mdl"),1,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor01b.mdl"),1,0,4)
					self:AddItem(ScavData.FormatModelname("models/props_lab/clipboard.mdl"),1,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_lab/harddrive02.mdl"),SCAV_SHORT_MAX,0,1) -- only need one, they're infinite
					self:AddItem(ScavData.FormatModelname("models/alyx_emptool_prop.mdl"),SCAV_SHORT_MAX,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_wasteland/kitchen_shelf001a.mdl"),1,0,1)
				end
				ScavData.CollectFuncs["models/props_lab/workspace001.mdl"] = function(self,ent)
					self:AddItem(ScavData.FormatModelname("models/scav/rad_hl2.mdl"),10,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_c17/consolebox05a.mdl"),8,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor02.mdl"),1,0,3)
					self:AddItem(ScavData.FormatModelname("models/props_junk/plasticcrate01a.mdl"),1,2,1)
					self:AddItem(ScavData.FormatModelname("models/props_lab/harddrive02.mdl"),SCAV_SHORT_MAX,0,1) -- only need one, they're infinite
					self:AddItem(ScavData.FormatModelname("models/alyx_emptool_prop.mdl"),SCAV_SHORT_MAX,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_wasteland/cafeteria_table001a.mdl"),1,0,1)
				end
				ScavData.CollectFuncs["models/props_lab/workspace002.mdl"] = function(self,ent)
					self:AddItem(ScavData.FormatModelname("models/props_c17/consolebox05a.mdl"),8,0,3)
					self:AddItem(ScavData.FormatModelname("models/props_lab/citizenradio.mdl"),10,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor02.mdl"),1,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor01b.mdl"),1,0,2)
					self:AddItem(ScavData.FormatModelname("models/props_lab/powerbox02b.mdl"),8,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_lab/harddrive02.mdl"),SCAV_SHORT_MAX,0,1) -- only need one, they're infinite
					self:AddItem(ScavData.FormatModelname("models/props_wasteland/cafeteria_table001a.mdl"),1,0,1)
				end
				ScavData.CollectFuncs["models/props_lab/workspace003.mdl"] = function(self,ent)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor02.mdl"),1,0,4)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor01b.mdl"),1,0,3)
					self:AddItem(ScavData.FormatModelname("models/props_lab/harddrive02.mdl"),SCAV_SHORT_MAX,0,1) -- only need one, they're infinite
					self:AddItem(ScavData.FormatModelname("models/props_wasteland/kitchen_shelf001a.mdl"),1,0,2)
				end
				ScavData.CollectFuncs["models/props_lab/workspace004.mdl"] = function(self,ent)
					self:AddItem(ScavData.FormatModelname("models/scav/rad_hl2.mdl"),10,0,3)
					self:AddItem(ScavData.FormatModelname("models/props_lab/monitor02.mdl"),1,0,4)
					self:AddItem(ScavData.FormatModelname("models/props_junk/plasticcrate01a.mdl"),1,2,1)
					self:AddItem(ScavData.FormatModelname("models/props_c17/computer01_keyboard.mdl"),1,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_lab/harddrive02.mdl"),SCAV_SHORT_MAX,0,1) -- only need one, they're infinite
					self:AddItem(ScavData.FormatModelname("models/alyx_emptool_prop.mdl"),SCAV_SHORT_MAX,0,1)
					self:AddItem(ScavData.FormatModelname("models/props_wasteland/cafeteria_table001a.mdl"),1,0,1)
				end
				--Ep2
				ScavData.CollectFuncs["models/props_silo/tirestack.mdl"] = function(self,ent)
					self:AddItem("models/props/de_prodigy/tire1.mdl",1,0,4)
					if IsMounted(240) then --CSS
						self:AddItem("models/props/de_prodigy/wood_pallet_01.mdl",1,0,1)
					else
						self:AddItem("models/props_junk/wood_pallet001a.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/props_silo/tirestack2.mdl"] = function(self,ent)
					self:AddItem("models/props_silo/tire2.mdl",1,0,1)
					self:AddItem("models/props_silo/tire1.mdl",1,0,3)
					if IsMounted(240) then --CSS
						self:AddItem("models/props/de_prodigy/wood_pallet_01.mdl",1,0,1)
					else
						self:AddItem("models/props_junk/wood_pallet001a.mdl",1,0,1)
					end
				end
				ScavData.CollectFuncs["models/props_silo/tirestack3.mdl"] = function(self,ent)
					self:AddItem("models/props_silo/tire1.mdl",1,0,2)
					if IsMounted(240) then --CSS
						self:AddItem("models/props/de_prodigy/wood_pallet_01.mdl",1,0,1)
					else
						self:AddItem("models/props_junk/wood_pallet001a.mdl",1,0,1)
					end
				end
				--CSS
				ScavData.CollectFuncs["models/props/de_nuke/cinderblock_stack.mdl"] = function(self,ent) self:AddItem("models/props_junk/CinderBlock01a.mdl",1,0,11) end
				ScavData.CollectFuncs["models/props/de_inferno/hay_bail_stack.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/hay_bails.mdl",1,0,15) end
				ScavData.CollectFuncs["models/props/cs_militia/haybale_target.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/hay_bails.mdl",1,0,5) end
				ScavData.CollectFuncs["models/props/cs_militia/haybale_target_02.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/hay_bails.mdl",1,0,4) end
				ScavData.CollectFuncs["models/props/cs_militia/haybale_target_03.mdl"] = function(self,ent) self:AddItem("models/props/de_inferno/hay_bails.mdl",1,0,3) end
				ScavData.CollectFuncs["models/props/de_prodigy/tirestack.mdl"] = function(self,ent)
					self:AddItem("models/props/de_prodigy/tire1.mdl",1,0,4)
					self:AddItem("models/props/de_prodigy/wood_pallet_01.mdl",1,0,1)
				end
				ScavData.CollectFuncs["models/props/de_prodigy/tirestack2.mdl"] = function(self,ent)
					self:AddItem("models/props/de_prodigy/tire2.mdl",1,0,1)
					self:AddItem("models/props/de_prodigy/tire1.mdl",1,0,3)
					self:AddItem("models/props/de_prodigy/wood_pallet_01.mdl",1,0,1)
				end
				ScavData.CollectFuncs["models/props/de_prodigy/tirestack3.mdl"] = function(self,ent)
					self:AddItem("models/props/de_prodigy/tire1.mdl",1,0,2)
					self:AddItem("models/props/de_prodigy/wood_pallet_01.mdl",1,0,1)
				end
				ScavData.CollectFuncs["models/props/cs_assault/box_stack1.mdl"] = function(self,ent)
					self:AddItem("models/props/cs_assault/dryer_box.mdl",1,0,5)
					self:AddItem("models/props/cs_assault/washer_box2.mdl",1,0,7)
				end
				ScavData.CollectFuncs["models/props/cs_assault/box_stack2.mdl"] = function(self,ent)
					self:AddItem("models/props/cs_assault/dryer_box.mdl",1,0,3)
					self:AddItem("models/props/cs_assault/washer_box.mdl",1,0,1)
					self:AddItem("models/props/cs_assault/dryer_box2.mdl",1,0,1)
					self:AddItem("models/props/cs_assault/washer_box2.mdl",1,0,4)
				end
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet_washerdryer.mdl"] = function(self,ent)
					self:AddItem("models/props/cs_assault/dryer_box.mdl",1,0,1)
					self:AddItem("models/props/cs_assault/washer_box2.mdl",1,0,2)
					self:AddItem("models/props/cs_militia/dryer.mdl",25,0,2)
					self:AddItem("models/props/cs_assault/money.mdl",1,0,5)
				end
				--TF2
				ScavData.CollectFuncs["models/props_2fort/tire002.mdl"] = function(self,ent) self:AddItem("models/props_2fort/tire001.mdl",1,0,5) end
				ScavData.CollectFuncs["models/props_2fort/tire003.mdl"] = function(self,ent) self:AddItem("models/props_2fort/tire001.mdl",1,0,3) end
				ScavData.CollectFuncs["models/props_2fort/trainwheel002.mdl"] = function(self,ent) self:AddItem("models/props_2fort/trainwheel001.mdl",1,0,5) end
				ScavData.CollectFuncs["models/props_2fort/trainwheel003.mdl"] = function(self,ent) self:AddItem("models/props_2fort/trainwheel001.mdl",1,0,8) end
				--L4D/2
				ScavData.CollectFuncs["models/props_unique/haybails_farmhouse.mdl"] = function(self,ent) self:AddItem("models/props_unique/haybails_single.mdl",1,0,20) end
				ScavData.CollectFuncs["models/props_interiors/medicalcabinet02.mdl"] = function(self,ent) 
					local choice = math.Rand(0,2)
					local num = math.Rand(1,2)
					if choice < 1 then
						self:AddItem("models/w_models/weapons/w_eq_medkit.mdl",math.Round(num),0,1)
					else
						self:AddItem("models/w_models/weapons/w_eq_painpills.mdl",math.Round(num),0,1)
					end
				end
				--CRATES
				ScavData.CollectFuncs["models/items/item_item_crate.mdl"] = function(self,ent) --some random HL2 supplies
					local supplies = {
						function() self:AddItem("models/healthvial.mdl",1,0) end,
						function() self:AddItem("models/items/battery.mdl",1,0) end,
						function() self:AddItem("models/scav/nail.mdl",15,0) end,
						function() self:AddItem("models/props_junk/metalgascan.mdl",25,0) end,
						function() self:AddItem("models/props_junk/popcan01a.mdl",1,0) end,
						function() self:AddItem("models/props_junk/shoe001a.mdl",1,0) end,
						function() self:AddItem("models/props_junk/watermelon01.mdl",1,0) end,
						function() self:AddItem("models/props_junk/glassjug01.mdl",1,0) end,
						function() self:AddItem("models/props_junk/plasticbucket001a.mdl",200,0) end,
						function() self:AddItem("models/props_lab/jar01a.mdl",1,0) end,
						function() self:AddItem("models/props_lab/huladoll.mdl",1,0) end,
						function() self:AddItem("models/props_combine/breenbust.mdl",1,0) end,
						function() self:AddItem("models/props_c17/doll01.mdl",1,0) end,
						function() self:AddItem("models/props_lab/tpplug.mdl",100,0) end,
						function() self:AddItem("models/props_junk/metalbucket01a.mdl",10,0) end,
						function() self:AddItem("models/scav/rad_hl2.mdl",10,0) end,
						function() self:AddItem("models/props_junk/metal_paintcan001b.mdl",30,0) end,
						function() self:AddItem("models/items/car_battery01.mdl",25,0) end,
						function() self:AddItem("models/props_junk/garbage_coffeemug001a.mdl",1,0) end,
						function() self:AddItem("models/weapons/w_stunbaton.mdl",8,0) end,
						function() self:AddItem("models/weapons/w_pistol.mdl",18,0) end,
						function() self:AddItem("models/weapons/w_357.mdl",6,0) end,
						function() self:AddItem("models/weapons/w_smg1.mdl",45,0) end,
						function() self:AddItem("models/weapons/ar2_grenade.mdl",1,0) end,
						function() self:AddItem("models/weapons/w_irifle.mdl",30,0) end,
						function() self:AddItem("models/items/combine_rifle_ammo01.mdl",1,0) end,
						function() self:AddItem("models/weapons/shotgun_shell.mdl",6,0) end,
						function() self:AddItem("models/props_trainstation/payphone_reciever001a.mdl",6,0) end,
						function() self:AddItem("models/crossbow_bolt.mdl",1,0) end,
						function() self:AddItem("models/weapons/w_grenade.mdl",1,0) end,
						function() self:AddItem("models/weapons/rifleshell.mdl",5,0) end,
					}
					if ScavData.FormatModelname(ent:GetModel()) == "models/items/item_item_crate.mdl" then
						if self.Owner:Health() * 2 <= self.Owner:GetMaxHealth() then
							self:AddItem("models/items/healthkit.mdl",1,0)
						end
						if self.Owner:Armor() * 3 <= self.Owner:GetMaxArmor() then
							self:AddItem("models/items/battery.mdl",1,0)
						end
						for i=0,math.floor(math.Rand(0,3)) do
							supplies[math.floor(math.Rand(1,#supplies+1))]()
						end
						self.Owner:EmitSound("physics/wood/wood_box_break1.wav",75,math.Rand(90,120),.5)
					else --Pot of Greed allows you to draw two cards
						for i=1,2 do
							supplies[math.floor(math.Rand(1,#supplies+1))]()
						end
						self.Owner:EmitSound("weapons/scav_gun/drawtwocards.wav",75)
					end
				end
				ScavData.CollectFuncs["models/props_c17/pottery01a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery02a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery03a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery04a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery05a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery06a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery07a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery08a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery09a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				ScavData.CollectFuncs["models/props_c17/pottery_large01a.mdl"] = ScavData.CollectFuncs["models/items/item_item_crate.mdl"]
				--Ep2
				ScavData.CollectFuncs["models/items/item_beacon_crate.mdl"] = function(self,ent) --some random Episodic supplies
					local supplies = {
						--function() self:AddItem("models/healthvial.mdl",1,0) end,
						function() self:AddItem("models/items/battery.mdl",1,0) end,
						function() self:AddItem("models/scav/nail.mdl",15,0) end,
						function() self:AddItem("models/props_junk/metalgascan.mdl",25,0) end,
						--function() self:AddItem("models/props_junk/popcan01a.mdl",1,0) end,
						function() self:AddItem("models/props_junk/shoe001a.mdl",1,0) end,
						function() self:AddItem("models/props_junk/watermelon01.mdl",1,0) end,
						function() self:AddItem("models/props_junk/glassjug01.mdl",1,0) end,
						function() self:AddItem("models/props_junk/plasticbucket001a.mdl",200,0) end,
						--function() self:AddItem("models/props_lab/jar01a.mdl",1,0) end,
						--function() self:AddItem("models/props_lab/huladoll.mdl",1,0) end,
						function() self:AddItem("models/props_combine/breenbust.mdl",1,0) end,
						--function() self:AddItem("models/props_c17/doll01.mdl",1,0) end,
						function() self:AddItem("models/props_lab/tpplug.mdl",100,0) end,
						function() self:AddItem("models/props_junk/metalbucket01a.mdl",10,0) end,
						function() self:AddItem("models/scav/rad_hl2.mdl",10,0) end,
						function() self:AddItem("models/props_junk/metal_paintcan001b.mdl",30,0) end,
						--function() self:AddItem("models/items/car_battery01.mdl",25,0) end,
						function() self:AddItem("models/props_junk/garbage_coffeemug001a.mdl",1,0) end,
						--function() self:AddItem("models/weapons/w_stunbaton.mdl",8,0) end,
						function() self:AddItem("models/weapons/w_pistol.mdl",18,0) end,
						function() self:AddItem("models/weapons/w_357.mdl",6,0) end,
						function() self:AddItem("models/weapons/w_smg1.mdl",45,0) end,
						function() self:AddItem("models/weapons/ar2_grenade.mdl",1,0) end,
						function() self:AddItem("models/weapons/w_irifle.mdl",30,0) end,
						function() self:AddItem("models/items/combine_rifle_ammo01.mdl",1,0) end,
						function() self:AddItem("models/weapons/shotgun_shell.mdl",6,0) end,
						function() self:AddItem("models/props_trainstation/payphone_reciever001a.mdl",6,0) end,
						function() self:AddItem("models/crossbow_bolt.mdl",1,0) end,
						function() self:AddItem("models/weapons/w_grenade.mdl",1,0) end,
						function() self:AddItem("models/weapons/w_combine_sniper.mdl",5,0) end,
						--Ep2 stuff
						function() self:AddItem("models/magnusson_device.mdl",1,0) end,
						function() self:AddItem("models/props_junk/flare.mdl",1,0) end,
						function() self:AddItem("models/props_mining/railroad_spike01.mdl",1,0) end,
						function() self:AddItem("models/weapons/hunter_flechette.mdl",25,0) end,
						function() self:AddItem("models/props_silo/acunit02.mdl",50,0) end,
						function() self:AddItem("models/grub_nugget_large.mdl",1,0) end,
						function() self:AddItem("models/props_forest/stove01.mdl",20,0) end,
					}
					if self.Owner:Health() * 2 <= self.Owner:GetMaxHealth() then
						self:AddItem("models/items/healthkit.mdl",1,0)
					end
					if self.Owner:Armor() * 3 <= self.Owner:GetMaxArmor() then
						self:AddItem("models/items/battery.mdl",1,0)
					end
					for i=0,math.floor(math.Rand(0,3)) do
						supplies[math.floor(math.Rand(1,#supplies+1))]()
					end
					self.Owner:EmitSound("vehicles/junker/radar_ping_friendly1.wav",75,100,.5)
				end
				ScavData.CollectFuncs["models/props_halloween/halloween_gift.mdl"] = function(self,ent) --some random TF2 supplies
					local supplies = {
						function() self:AddItem("models/items/medkit_small.mdl",1,0) end,
						function() self:AddItem("models/weapons/c_models/c_sandwich/c_sandwich.mdl",1,0) end,
						function() self:AddItem("models/scav/nail.mdl",25,0) end,
						function() self:AddItem("models/props_farm/oilcan01.mdl",25,0) end,
						function() self:AddItem("models/weapons/w_models/w_grenade_grenadelauncher.mdl",4,math.Round(math.random())) end,
						function() self:AddItem("models/weapons/w_models/w_flaregun_shell.mdl",3,math.Round(math.random())) end,
						function() self:AddItem("models/props_gameplay/pill_bottle01.mdl",1,0) end,
						function() self:AddItem("models/weapons/c_models/c_flameball/c_flameball.mdl",20,math.Round(math.random())) end,
						function() self:AddItem("models/weapons/w_models/w_rocket.mdl",4,0) end,
						function() self:AddItem("models/weapons/c_models/urinejar.mdl",1,0) end,
						function() self:AddItem("models/weapons/w_models/w_repair_claw.mdl",4,0) end,
						function() self:AddItem("models/buildables/sentry1.mdl",100,math.Round(math.random())) end,
						function() self:AddItem("models/weapons/w_models/w_stickybomb.mdl",3,math.Round(math.random())) end,
						function() self:AddItem("models/props_2fort/fire_extinguisher.mdl",100,0) end,
						function() self:AddItem("models/props_2fort/sink001.mdl",25,0) end,
						function() self:AddItem("models/props_badlands/barrel03.mdl",10,0) end,
						function() self:AddItem("models/weapons/c_models/c_spy_watch.mdl",30,0) end,
						function() self:AddItem("models/flag/briefcase.mdl",1,math.Round(math.random())) end,
						function() self:AddItem("models/weapons/c_models/c_energy_drink/c_energy_drink.mdl",1,math.Round(math.random())) end,
						function() self:AddItem("models/weapons/c_models/c_sapper/c_sapper.mdl",8,0) end,
						function() self:AddItem("models/weapons/c_models/c_pistol/c_pistol.mdl",12,0) end,
						function() self:AddItem("models/weapons/w_357.mdl",6,0) end, --TODO: Gotta switch to spy's revolvers when they have their own unique models registered
						function() self:AddItem("models/weapons/c_models/c_smg/c_smg.mdl",25,0) end,
						function() self:AddItem("models/weapons/c_models/c_claymore/c_claymore.mdl",1,0) end,
						function() self:AddItem("models/weapons/c_models/c_minigun/c_minigun.mdl",200,0) end,
						function() self:AddItem("models/props_trainyard/cart_bomb_separate.mdl",1,0) end,
						function() self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0) end,
						function() self:AddItem("models/props_2fort/telephone001.mdl",6,0) end,
						function() self:AddItem("models/weapons/w_models/w_arrow.mdl",3,0) end,
						function() self:AddItem("models/weapons/c_models/c_flamethrower/c_flamethrower.mdl",200,math.Round(math.random())) end,
						function() self:AddItem("models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl",25,0) end,
					}
					if ScavData.FormatModelname(ent:GetModel()) ~= "models/props_manor/vase_01.mdl" then
						if self.Owner:Health() * 2 <= self.Owner:GetMaxHealth() then
							self:AddItem("models/items/medkit_medium.mdl",1,0)
						end
						if self.Owner:Armor() * 3 <= self.Owner:GetMaxArmor() then
							self:AddItem("models/pickups/pickup_powerup_defense.mdl",1,0)
						end
						for i=0,math.floor(math.Rand(0,3)) do
							supplies[math.floor(math.Rand(1,#supplies+1))]()
						end
						if ent:GetModel() == "models/props_halloween/halloween_gift.mdl" or
							ent:GetModel() == "models/items/tf_gift.mdl" then
							self.Owner:EmitSound("items/gift_drop.wav",75,100,.5)
						else
							self.Owner:EmitSound("items/regenerate.wav",75,100,.5)
						end
					else
						for i=1,2 do
							supplies[math.floor(math.Rand(1,#supplies+1))]()
						end
						self.Owner:EmitSound("weapons/scav_gun/drawtwocards.wav",75)
					end
						
				end
				ScavData.CollectFuncs["models/props_gameplay/resupply_locker.mdl"] = ScavData.CollectFuncs["models/props_halloween/halloween_gift.mdl"]
				ScavData.CollectFuncs["models/items/tf_gift.mdl"] = ScavData.CollectFuncs["models/props_halloween/halloween_gift.mdl"]
				ScavData.CollectFuncs["models/props_manor/vase_01.mdl"] = ScavData.CollectFuncs["models/props_halloween/halloween_gift.mdl"]
				--L4D2 Gift
				--Portal Cake (isn't solid :c)
				--CSS Laundry Box maybe?
				--Make HL2 Oil Drums sometimes provide Radioactive/BioHazard Barrel Firemodes?
				
				--Give a random TF2 barrel from barrel crates
				ScavData.CollectFuncs["models/props_mvm/barrel_crate.mdl"] = function(self,ent)
					local choice = math.floor(math.Rand(0,10))
					if choice == 0 then
						self:AddItem("models/props_badlands/barrel01.mdl",2,0,1)
					elseif choice == 1 then
						self:AddItem("models/props_badlands/barrel03.mdl",10,math.floor(math.Rand(0,2)),1)
					else
						self:AddItem("models/props_hydro/water_barrel.mdl",1,0,1)
					end
				end
				
				--Uniform Locker (give us three random classes' stuff)
				ScavData.CollectFuncs["models/props_gameplay/uniform_locker.mdl"] = function(self,ent)
					local classpick = {
						[0] = function()
							self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
							self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0)
							self:AddItem("models/weapons/c_models/c_energy_drink/c_energy_drink.mdl",1,math.fmod(ent:GetSkin(),2)) end,
						[1] = function()
							self:AddItem("models/weapons/w_models/w_rocket.mdl",4,0)
							self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
							self:AddItem("models/weapons/c_models/c_bugle/c_bugle.mdl",10,0) end,
						[2] = function()
							self:AddItem("models/weapons/c_models/c_flamethrower/c_flamethrower.mdl",200,math.fmod(ent:GetSkin(),2))
							self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
							self:AddItem("models/weapons/w_models/w_flaregun_shell.mdl",5,math.fmod(ent:GetSkin(),2)) end,
						[3] = function()
							self:AddItem("models/weapons/w_models/w_grenade_grenadelauncher.mdl",4,math.fmod(ent:GetSkin(),2))
							self:AddItem("models/weapons/w_models/w_stickybomb.mdl",6,math.fmod(ent:GetSkin(),2))
							self:AddItem("models/weapons/c_models/c_claymore/c_claymore.mdl",1,0) end,
						[4] = function()
							self:AddItem("models/weapons/w_models/w_minigun.mdl",200,0)
							self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
							self:AddItem("models/weapons/c_models/c_sandwich/c_sandwich.mdl",1,0) end,
						[5] = function()
							self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
							self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0)
							self:AddItem("models/weapons/w_models/w_wrangler.mdl", SCAV_SHORT_MAX, math.fmod(ent:GetSkin(),2)) end,
						[6] = function()
							self:AddItem("models/weapons/w_models/w_syringegun.mdl",40,ent:GetSkin())
							self:AddItem("models/weapons/c_models/c_medigun/c_medigun.mdl", SCAV_SHORT_MAX, math.fmod(ent:GetSkin(),2))
							self:AddItem("models/items/medkit_medium.mdl",1,0) end,
						[7] = function()
							local pickone = math.Rand(0,2)
							if pickone < 1 then
								self:AddItem("models/weapons/w_models/w_sniperrifle.mdl",25,0)
							else
								self:AddItem("models/weapons/w_models/w_arrow.mdl",3,0)
							end
							pickone = math.Rand(0,2)
							if pickone < 1 then
								self:AddItem("models/weapons/w_models/w_smg.mdl",25,0)
							else
								self:AddItem("models/weapons/c_models/urinejar.mdl",1,0)
							end
							self:AddItem("models/weapons/c_models/c_machete/c_machete.mdl",1,0) end,
						[8] = function()
							self:AddItem("models/weapons/w_357.mdl",6,0)
							self:AddItem("models/weapons/w_models/w_sapper.mdl",8,0)
							self:AddItem("models/weapons/w_models/w_knife.mdl",1,0)
							self:AddItem("models/weapons/c_models/c_spy_watch.mdl",30,0) end 
					}
					for i=1,3 do
						classpick[math.floor(math.Rand(0,9))]()
					end
				end
				
				--Poopy Joe's Locker
				ScavData.CollectFuncs["models/props_gameplay/uniform_locker_pj.mdl"] = function(self,ent)
							self:AddItem("models/weapons/c_models/c_bugle/c_bugle.mdl",10,0)
							self:AddItem("models/weapons/c_models/c_claymore/c_claymore.mdl",1,0)
							self:AddItem("models/weapons/c_models/c_pickaxe/c_pickaxe.mdl",1,0)
							if IsMounted(265630) then --FoF
								self:AddItem("models/elpaso/horse_poo.mdl",1,0)
							else
								self:AddItem("models/weapons/c_models/urinejar.mdl",1,0)
							end
				end

				--precache helps with the hiccup of initially sucking the mercs/locker up
				if IsMounted(440) then --TF2
					util.PrecacheModel("models/weapons/shells/shell_shotgun.mdl")
					util.PrecacheModel("models/weapons/w_models/w_pistol.mdl")
					util.PrecacheModel("models/weapons/c_models/c_energy_drink/c_energy_drink.mdl")
					util.PrecacheModel("models/weapons/w_models/w_rocket.mdl")
					util.PrecacheModel("models/weapons/c_models/c_bugle/c_bugle.mdl")
					util.PrecacheModel("models/weapons/c_models/c_flamethrower/c_flamethrower.mdl")
					util.PrecacheModel("models/weapons/w_models/w_flaregun_shell.mdl")
					util.PrecacheModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl")
					util.PrecacheModel("models/weapons/w_models/w_stickybomb.mdl")
					util.PrecacheModel("models/weapons/c_models/c_claymore/c_claymore.mdl")
					util.PrecacheModel("models/weapons/w_models/w_minigun.mdl")
					util.PrecacheModel("models/weapons/c_models/c_sandwich/c_sandwich.mdl")
					util.PrecacheModel("models/weapons/w_models/w_wrangler.mdl")
					util.PrecacheModel("models/weapons/w_models/w_syringegun.mdl")
					util.PrecacheModel("models/weapons/c_models/c_medigun/c_medigun.mdl")
					util.PrecacheModel("models/items/medkit_medium.mdl")
					util.PrecacheModel("models/weapons/w_models/w_sniperrifle.mdl")
					util.PrecacheModel("models/weapons/w_models/w_arrow.mdl")
					util.PrecacheModel("models/weapons/w_models/w_smg.mdl")
					util.PrecacheModel("models/weapons/c_models/urinejar.mdl")
					util.PrecacheModel("models/weapons/c_models/c_machete/c_machete.mdl")
					util.PrecacheModel("models/weapons/w_357.mdl")
					util.PrecacheModel("models/weapons/w_models/w_sapper.mdl")
					util.PrecacheModel("models/weapons/w_models/w_knife.mdl")
					util.PrecacheModel("models/weapons/c_models/c_spy_watch.mdl")
				end

				--Scout
				ScavData.CollectFuncs["models/player/scout.mdl"] = function(self,ent)
					self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
					self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0)
					self:AddItem("models/weapons/c_models/c_energy_drink/c_energy_drink.mdl",1,math.fmod(ent:GetSkin(),2))
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/scout/bot_scout.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/scout_mvm_battlecry0".. math.floor(math.Rand(1,6)) ..".mp3",75,100,1,CHAN_VOICE)
					elseif ScavData.FormatModelname(ent:GetModel()) == "models/bots/scout_boss/bot_scout_boss.mdl" then
						self.Owner:EmitSound("vo/mvm/mght/scout_mvm_m_battlecry0".. math.floor(math.Rand(1,6)) ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/scout_battlecry0".. math.floor(math.Rand(1,6)) ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/scout.mdl"] = ScavData.CollectFuncs["models/player/scout.mdl"]
				ScavData.CollectFuncs["models/bots/scout/bot_scout.mdl"] = ScavData.CollectFuncs["models/player/scout.mdl"]
				ScavData.CollectFuncs["models/bots/scout_boss/bot_scout_boss.mdl"] = ScavData.CollectFuncs["models/player/scout.mdl"]
				
				--Soldier
				ScavData.CollectFuncs["models/player/soldier.mdl"] = function(self,ent)
					self:AddItem("models/weapons/w_models/w_rocket.mdl",4,0)
					self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
					self:AddItem("models/weapons/c_models/c_bugle/c_bugle.mdl",10,0)
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/soldier/bot_soldier.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/soldier_mvm_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					elseif ScavData.FormatModelname(ent:GetModel()) == "models/bots/soldier_boss/bot_soldier_boss.mdl" then
						self.Owner:EmitSound("vo/mvm/mght/soldier_mvm_m_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/soldier_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/soldier.mdl"] = ScavData.CollectFuncs["models/player/soldier.mdl"]
				ScavData.CollectFuncs["models/bots/soldier/bot_soldier.mdl"] = ScavData.CollectFuncs["models/player/soldier.mdl"]
				ScavData.CollectFuncs["models/bots/soldier_boss/bot_soldier_boss.mdl"] = ScavData.CollectFuncs["models/player/soldier.mdl"]
				
				--Pyro
				ScavData.CollectFuncs["models/player/pyro.mdl"] = function(self,ent)
					local pickone = math.Rand(0,2)
					if pickone < 1 then
						self:AddItem("models/weapons/c_models/c_flamethrower/c_flamethrower.mdl",200,math.fmod(ent:GetSkin(),2))
					else
						self:AddItem("models/weapons/c_models/c_flameball/c_flameball.mdl",40,math.fmod(ent:GetSkin(),2))
					end
					self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
					self:AddItem("models/weapons/w_models/w_flaregun_shell.mdl",5,math.fmod(ent:GetSkin(),2))
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/pyro/bot_pyro.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/pyro_mvm_battlecry0".. math.floor(math.Rand(1,3)) ..".mp3",75,100,1,CHAN_VOICE)
					elseif ScavData.FormatModelname(ent:GetModel()) == "models/bots/pyro_boss/bot_pyro_boss.mdl" then
						self.Owner:EmitSound("vo/mvm/mght/pyro_mvm_m_battlecry0".. math.floor(math.Rand(1,3)) ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/pyro_battlecry0".. math.floor(math.Rand(1,3)) ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/pyro.mdl"] = ScavData.CollectFuncs["models/player/pyro.mdl"]
				ScavData.CollectFuncs["models/bots/pyro/bot_pyro.mdl"] = ScavData.CollectFuncs["models/player/pyro.mdl"]
				ScavData.CollectFuncs["models/bots/pyro_boss/bot_pyro_boss.mdl"] = ScavData.CollectFuncs["models/player/pyro.mdl"]
				
				--Demoman
				ScavData.CollectFuncs["models/player/demo.mdl"] = function(self,ent)
					self:AddItem("models/weapons/w_models/w_grenade_grenadelauncher.mdl",4,math.fmod(ent:GetSkin(),2))
					self:AddItem("models/weapons/w_models/w_stickybomb.mdl",6,math.fmod(ent:GetSkin(),2))
					local pickone = math.Rand(0,2)
					if pickone < 1 then
						self:AddItem("models/weapons/c_models/c_bottle/c_bottle.mdl",1,0)
					else
						self:AddItem("models/weapons/c_models/c_claymore/c_claymore.mdl",1,0)
					end
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/demo/bot_demo.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/demoman_mvm_battlecry0".. math.floor(math.Rand(1,8)) ..".mp3",75,100,1,CHAN_VOICE)
					elseif ScavData.FormatModelname(ent:GetModel()) == "models/bots/demo_boss/bot_demo_boss.mdl" then
						self.Owner:EmitSound("vo/mvm/mght/demoman_mvm_m_battlecry0".. math.floor(math.Rand(1,8)) ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/demoman_battlecry0".. math.floor(math.Rand(1,8)) ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/demo.mdl"] = ScavData.CollectFuncs["models/player/demo.mdl"]
				ScavData.CollectFuncs["models/bots/demo/bot_demo.mdl"] = ScavData.CollectFuncs["models/player/demo.mdl"]
				ScavData.CollectFuncs["models/bots/demo_boss/bot_demo_boss.mdl"] = ScavData.CollectFuncs["models/player/demo.mdl"]
				
				--Heavy
				ScavData.CollectFuncs["models/player/heavy.mdl"] = function(self,ent)
					self:AddItem("models/weapons/w_models/w_minigun.mdl",200,0)
					self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
					self:AddItem("models/weapons/c_models/c_sandwich/c_sandwich.mdl",1,0)
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/heavy/bot_heavy.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/heavy_mvm_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					elseif ScavData.FormatModelname(ent:GetModel()) == "models/bots/heavy_boss/bot_heavy_boss.mdl" then
						self.Owner:EmitSound("vo/mvm/mght/heavy_mvm_m_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/heavy_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/heavy.mdl"] = ScavData.CollectFuncs["models/player/heavy.mdl"]
				ScavData.CollectFuncs["models/bots/heavy/bot_heavy.mdl"] = ScavData.CollectFuncs["models/player/heavy.mdl"]
				ScavData.CollectFuncs["models/bots/heavy_boss/bot_heavy_boss.mdl"] = ScavData.CollectFuncs["models/player/heavy.mdl"]
				
				--Engineer
				ScavData.CollectFuncs["models/player/engineer.mdl"] = function(self,ent)
					self:AddItem("models/weapons/shells/shell_shotgun.mdl",6,0)
					self:AddItem("models/weapons/w_models/w_pistol.mdl",12,0)
					self:AddItem("models/weapons/w_models/w_wrangler.mdl", SCAV_SHORT_MAX, math.fmod(ent:GetSkin(),2))
					local voiceclipnum = math.floor(math.Rand(1,7))
					if voiceclipnum > 1 then voiceclipnum = voiceclipnum + 1 end --no engineer_battlecry02.mp3
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/engineer/bot_engineer.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/engineer_mvm_battlecry0".. voiceclipnum ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/engineer_battlecry0".. voiceclipnum ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/engineer.mdl"] = ScavData.CollectFuncs["models/player/engineer.mdl"]
				ScavData.CollectFuncs["models/bots/engineer/bot_engineer.mdl"] = ScavData.CollectFuncs["models/player/engineer.mdl"]
				
				--Medic
				ScavData.CollectFuncs["models/player/medic.mdl"] = function(self,ent)
					self:AddItem("models/weapons/w_models/w_syringegun.mdl",40,ent:GetSkin())
					self:AddItem("models/weapons/c_models/c_medigun/c_medigun.mdl", SCAV_SHORT_MAX, math.fmod(ent:GetSkin(),2))
					self:AddItem("models/items/medkit_medium.mdl",1,0)
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/medic/bot_medic.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/medic_mvm_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/medic_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/medic.mdl"] = ScavData.CollectFuncs["models/player/medic.mdl"]
				ScavData.CollectFuncs["models/bots/medic/bot_medic.mdl"] = ScavData.CollectFuncs["models/player/medic.mdl"]
				
				--Sniper
				ScavData.CollectFuncs["models/player/sniper.mdl"] = function(self,ent)
					local pickone = math.Rand(0,2)
					if pickone < 1 then
						self:AddItem("models/weapons/w_models/w_sniperrifle.mdl",25,0)
					else
						self:AddItem("models/weapons/w_models/w_arrow.mdl",3,0)
					end
					pickone = math.Rand(0,2)
					if pickone < 1 then
						self:AddItem("models/weapons/w_models/w_smg.mdl",25,0)
					else
						self:AddItem("models/weapons/c_models/urinejar.mdl",1,0)
					end
					self:AddItem("models/weapons/c_models/c_machete/c_machete.mdl",1,0)
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/sniper/bot_sniper.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/sniper_mvm_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/sniper_battlecry0".. math.floor(math.Rand(1,7)) ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/sniper.mdl"] = ScavData.CollectFuncs["models/player/sniper.mdl"]
				ScavData.CollectFuncs["models/bots/sniper/bot_sniper.mdl"] = ScavData.CollectFuncs["models/player/sniper.mdl"]
				
				--Spy
				ScavData.CollectFuncs["models/player/spy.mdl"] = function(self,ent)
					self:AddItem("models/weapons/w_357.mdl",6,0)
					self:AddItem("models/weapons/w_models/w_sapper.mdl",8,0)
					self:AddItem("models/weapons/w_models/w_knife.mdl",1,0)
					self:AddItem("models/weapons/c_models/c_spy_watch.mdl",30,0)
					if ScavData.FormatModelname(ent:GetModel()) == "models/bots/spy/bot_spy.mdl" then
						self.Owner:EmitSound("vo/mvm/norm/spy_mvm_battlecry0".. math.floor(math.Rand(1,5)) ..".mp3",75,100,1,CHAN_VOICE)
					else
						self.Owner:EmitSound("vo/spy_battlecry0".. math.floor(math.Rand(1,5)) ..".mp3",75,100,1,CHAN_VOICE)
					end
				end
				ScavData.CollectFuncs["models/player/hwm/spy.mdl"] = ScavData.CollectFuncs["models/player/spy.mdl"]
				ScavData.CollectFuncs["models/bots/spy/bot_spy.mdl"] = ScavData.CollectFuncs["models/player/spy.mdl"]
				
				--Human Grunt
				ScavData.CollectFuncs["models/hgrunt.mdl"] = function(self,ent)
					if ent:GetBodygroup(2) == 0 then
						self:AddItem("models/w_9mmar.mdl",25,0,1)
					elseif ent:GetBodygroup(2) == 1 then
						self:AddItem("models/shotgunshell.mdl",8,0,1)
					end
					self.Owner:EmitSound("hgrunt/bastard!.wav",75,100,.125,CHAN_VOICE)
				end

			end
--splitting up into smaller files				
include("firemodes_hl2.lua")
include("firemodes_css.lua")
include("firemodes_dods.lua")
