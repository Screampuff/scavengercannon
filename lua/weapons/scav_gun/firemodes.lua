AddCSLuaFile("firemodes_hl2.lua")
AddCSLuaFile("firemodes_css.lua")
AddCSLuaFile("firemodes_dods.lua")
AddCSLuaFile("firemodes_fof.lua")
AddCSLuaFile("firemodes_utility.lua")
AddCSLuaFile("firemodes_piles.lua")

local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")
local SWEP = SWEP
local ScavData = ScavData

--damage fix
DMG_FREEZE = 16
DMG_CHEMICAL = 1048576

ScavDataCollectCopy = function(copy, original)
	ScavData.CollectFuncs[copy] = ScavData.CollectFuncs[original]
	ScavData.CollectFX[copy] = ScavData.CollectFX[original]
end

puterscreen = function(self, item)
	if not IsValid(self) or not item then return end

	local tab = item.GetFiremodeTable and item:GetFiremodeTable() or nil

	if not tab then return end

	--draw cooldown for rockets
	if tab.Seeking ~= nil and self:ScreenCooldown(0) then
		self:DrawCooldown()
		return
	end
	--if we're a rocket, make sure our targetting is on
	if tab.On == nil and not tab.Seeking then
		self:DrawIdle()
		return
	end

	local on = tab.On and tab.On or tab.Seeking
	
	DrawScreenBKG(on and greenscr or redscr)
	local vpos = 12
	local fontsize = "ScavScreenFontSm"
	if #language.GetPhrase("scav.scavcan.autotarget") > 14 then
		fontsize = "ScavScreenFontSmX"
		vpos = vpos + 8
	end
	local _, blinkTime = math.modf(CurTime())
	local col = color_black
	if not on and blinkTime < .5 then
		col = color_white
	end
	draw.DrawText(language.GetPhrase("scav.scavcan.autotarget"), fontsize, 128, vpos, col, TEXT_ALIGN_CENTER)
	draw.DrawText(language.GetPhrase(on and "scav.scavcan.on" or "scav.scavcan.off"), "ScavScreenFont", 128, 20 + vpos, col, TEXT_ALIGN_CENTER)
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
			tab.tracep.mins = Vector(-16, -16, -16)
			tab.tracep.maxs = Vector(16, 16, 16)
			local identify = {
				--[HL2/Default] = 0,
				--[[TF2]]["models/weapons/w_models/w_rocket.mdl"] = SCAV_ROCKET_TF2,
				["models/props_halloween/eyeball_projectile.mdl"] = SCAV_ROCKET_TF2,
				--[[TF2 Sentry]]["models/buildables/sentry3_rockets.mdl"] = SCAV_ROCKET_SENTRY,
				--[[TF2 Air Strike]]["models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl"] = SCAV_ROCKET_AIRSTRIKE,
				--[[DoD:S]]["models/weapons/w_bazooka_rocket.mdl"] = SCAV_ROCKET_DODS,
				["models/weapons/w_panzerschreck_rocket.mdl"] = SCAV_ROCKET_DODS,
				--[[HL1]]["models/rpgrocket.mdl"] = SCAV_ROCKET_HL1,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_ROCKET_DEFAULT end})
			tab.OnArmed = function(self, item, olditemname)
				--Look for seeking items
				tab.Seeking = false
				for _, v in pairs(self.inv.items) do
					if ScavData.models[v.ammo] and ScavData.models[v.ammo].Name == "#scav.scavcan.computer" then
						tab.Seeking = ScavData.models[v.ammo].On
						break
					end
				end
			end
			if CLIENT then
				tab.FireFunc = tab.OnArmed
				tab.Screen = puterscreen
			else
				tab.FireFunc = function(self, item)
					if IsValid(self.Owner) then
						local tab = ScavData.models[item.ammo]
						local proj = self:CreateEnt("scav_projectile_rocket")
						if not IsValid(proj) then return false end
						proj.Owner = self.Owner
						proj:SetModel(item.ammo)
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles(self:GetAimVector():Angle())
						proj:SetOwner(self.Owner)
						tab.OnArmed(self, item)
						if tab.Seeking then
							tab.tracep.start = self.Owner:GetShootPos()
							tab.tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 20000
							tab.tracep.filter = self.Owner
							local tr = util.TraceHull(tab.tracep)
							if IsValid(tr.Entity) then
								proj.target = tr.Entity
							end
						end
						proj:Spawn()
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						local soundtable = {
							[SCAV_ROCKET_DEFAULT] = "weapons/stinger_fire1.wav",
							[SCAV_ROCKET_TF2] = "weapons/rocket_shoot.wav",
							[SCAV_ROCKET_SENTRY] = "weapons/sentry_rocket.wav",
							[SCAV_ROCKET_AIRSTRIKE] = "weapons/airstrike_fire_01.wav",
							[SCAV_ROCKET_DODS] = "^weapons/rocket1.wav",
							[SCAV_ROCKET_HL1] = "weapons/rocket1.wav", --oh Valve
						}
						local soundtablecrit = {
							[SCAV_ROCKET_TF2] = "weapons/rocket_shoot_crit.wav",
							[SCAV_ROCKET_AIRSTRIKE] = "weapons/airstrike_fire_crit.wav",
						}
						table.Inherit(soundtablecrit, soundtable)

						self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and soundtablecrit[tab.Identify[item.ammo]] or soundtable[tab.Identify[item.ammo]])
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(false)
						proj:GetPhysicsObject():EnableGravity(false)
						proj.SpeedScale = self:GetForceScale()
						proj:GetPhysicsObject():SetVelocityInstantaneous((self:GetAimVector()) * 2000 * self:GetForceScale())
						proj:GetPhysicsObject():SetBuoyancyRatio(0)
						--self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("fire3"))
						--gamemode.Call("ScavFired", self.Owner, proj)
						self:AddBarrelSpin(575)
						self.Owner:ViewPunch(Angle(math.Rand(-1, 0), math.Rand(-0.1, 0.1), 0))
						return self:TakeSubammo(item, 1)
					end
				end
				ScavData.CollectFuncs["models/weapons/w_rocket_launcher.mdl"] = function(self, ent) return {{"models/weapons/w_missile.mdl", 3, 0}} end --3 rockets from HL2 launcher - add seeking?
				ScavData.CollectFuncs["models/items/ammocrate_rockets.mdl"] = ScavData.GiveOneOfItemInf
				ScavData.CollectFuncs["models/weapons/w_missile_launch.mdl"] = function(self, ent) return {{"models/weapons/w_missile.mdl", 1, 0}} end --converts the rocket into a usable one
				ScavData.CollectFuncs["models/weapons/w_missile_closed.mdl"] = ScavData.CollectFuncs["models/weapons/w_missile_launch.mdl"]
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_rocket.mdl", 4, 0}} end --4 rockets from TF2 launcher
				ScavData.CollectFuncs["models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_directhit/c_directhit.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl", 4, 0}} end
				ScavData.CollectFuncs["models/weapons/c_models/c_rocketjumper/c_rocketjumper.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"] --TODO: No damage?
				ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_rocket.mdl", 3, 0}} end --3 rockets from Black Box
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_blackbox/c_blackbox.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_blackbox/c_blackbox_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_blackbox/c_blackbox.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_rocket.mdl", 5, 0}} end --5 rockets from Libery Launcher
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl"]
				ScavData.CollectFuncs["models/buildables/sentry3.mdl"] = function(self, ent) --4 rockets, 1 sentry from TF2 sentry (level 3)
					return {{"models/buildables/sentry3_rockets.mdl", 4, 0},
							{"models/buildables/sentry2.mdl", 100, ent:GetSkin()}}
				end
				ScavData.CollectFuncs["models/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				ScavData.CollectFuncs["models/pickups/pickup_powerup_supernova.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_rocketlauncher.mdl"]
				--Portal
				ScavData.CollectFuncs["models/props_bts/rocket_sentry.mdl"] = function(self, ent) return {{"models/props_bts/rocket.mdl", 5, 0}} end --5 rockets from Portal rocket sentry
				ScavData.CollectFuncs["models/props/tripwire_turret.mdl"] = function(self, ent) return {{"models/props_bts/rocket.mdl", 5, 0}} end --5 rockets from Portal rocket sentry
				--DoD:S
				ScavData.CollectFuncs["models/weapons/w_bazooka.mdl"] = function(self, ent) return {{"models/weapons/w_bazooka_rocket.mdl", 1, 0}} end --1 rocket from Bazooka
				ScavData.CollectFuncs["models/weapons/w_pschreck.mdl"] = function(self, ent) return {{"models/weapons/w_panzerschreck_rocket.mdl", 1, 0}} end --1 rocket from Panzer
				--BMS
				ScavData.CollectFuncs["models/weapons/w_rpg.mdl"] = function(self, ent) return {{"models/weapons/w_rpg_projectile.mdl", 3, 0}} end
				ScavData.CollectFuncs["models/weapons/w_rpg_mp.mdl"] = ScavData.CollectFuncs["models/weapons/w_rpg.mdl"]
				ScavData.CollectFuncs["models/weapons/w_rpgammo.mdl"] = function(self, ent) return {{"models/weapons/w_rpg_projectile.mdl", 1, 0}} end
				ScavData.CollectFuncs["models/weapons/w_rpgammo_mp.mdl"] = ScavData.CollectFuncs["models/weapons/w_rpgammo.mdl"]
				ScavData.CollectFuncs["models/props_marines/tow_missile_system.mdl"] = ScavData.CollectFuncs["models/weapons/w_rpg.mdl"]
				ScavData.CollectFuncs["models/props_marines/tow_missile_system_mp.mdl"] = ScavData.CollectFuncs["models/weapons/w_rpg.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/weapons/w_missile.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_rocket.mdl")
		ScavData.RegisterFiremode(tab, "models/buildables/sentry3_rockets.mdl")
		ScavData.RegisterFiremode(tab, "models/props_halloween/eyeball_projectile.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl")
		--ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_drg_cowmangler/c_drg_cowmangler.mdl") --TODO: infinite rockets from Cowmanger (on its own entity, probably)
		--Portal
		ScavData.RegisterFiremode(tab, "models/props_bts/rocket.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/weapons/w_bazooka_rocket.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_panzerschreck_rocket.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab, "models/rpgrocket.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarm/minirocket/minirocket.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_rpg_projectile.mdl")

--[[==============================================================================================
	--Ice Beam
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.icebeam"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.tracep = {}
			tab.tracep.mask = MASK_SHOT
			tab.tracep.mins = Vector(-16, -16, -16)
			tab.tracep.maxs = Vector(16, 16, 16)
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("scav_projectile_ice")
					proj.Owner = self.Owner
					proj:SetModel(item.ammo)
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles(self:GetAimVector():Angle())
					proj:SetOwner(self.Owner)
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("physics/glass/glass_strain1.wav", 100, 100)
					self.Owner:EmitSound("weapons/ar2/npc_ar2_altfire.wav", 100, 100)
					proj:GetPhysicsObject():Wake()
					proj:GetPhysicsObject():EnableDrag(false)
					proj:GetPhysicsObject():EnableGravity(false)
					proj.SpeedScale = self:GetForceScale()
					proj:GetPhysicsObject():SetVelocity((self:GetAimVector()) * 2000 * self:GetForceScale())
					proj:GetPhysicsObject():SetBuoyancyRatio(0)
					self.Owner:ViewPunch(Angle(math.Rand(-1, 0), math.Rand(-0.1, 0.1), 0))
					return self:TakeSubammo(item, 1)
				end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl"] = function(self, ent) return {{self.christmas and "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder_festivizer.mdl" or ScavData.FormatModelname(ent:GetModel()), SCAV_SHORT_MAX, ent:GetSkin()}} end
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/maxofs2d/hover_classic.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/xqm/rails/gumball_1.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder_festivizer.mdl", SCAV_SHORT_MAX)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_office/snowman_body.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/snowman_face.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/snowman_head.mdl", SCAV_SHORT_MAX)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/props_urban/ice_machine001.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_urban/plastic_icechest001.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/props_urban/plastic_icechest001_static.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/props_urban/plastic_icechest002.mdl", 2)

--[[==============================================================================================
	--Flares
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.flare"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			tab.MaxAmmo = 16
			local identify = {
				--[HL2/Default] = 0,
				--[[TF2]]["models/weapons/w_models/w_flaregun_shell.mdl"] = 1,
				--[[ASW]]["models/swarm/flare/flareweapon.mdl"] = 2,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
						--local proj = self:CreateEnt("scav_projectile_flare")
						local proj = self:CreateEnt("scav_projectile_flare2")
						proj.Owner = self.Owner
						proj:SetModel(item.ammo)
						proj:SetPos(self.Owner:GetShootPos() - self:GetAimVector() * 15 + self:GetAimVector():Angle():Right() * 2 - self:GetAimVector():Angle():Up() * 2)
						proj:SetAngles(self:GetAimVector():Angle())
						proj:SetOwner(self.Owner)
						proj:SetPhysicsAttacker(self.Owner)
						--proj:SetSkin(item.data)
						proj:SetSkin(item.data)
						proj:Spawn()
						--"weapons/flaregun/burn"
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						if not IsValid(proj:GetPhysicsObject()) then
							local mins, maxs = proj:GetModelBounds()
							proj:PhysicsInitBox(mins, maxs, "item")
						end
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():EnableDrag(false)
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector() * 4000)
						proj:GetPhysicsObject():SetBuoyancyRatio(0)
						proj:SetPhysicsAttacker(self.Owner)
						self.Owner:ViewPunch(Angle(math.Rand(-1, 0), math.Rand(-0.1, 0.1), 0))
						return self:TakeSubammo(item, 1)
					end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_flaregun_shell.mdl", 5, ent:GetSkin()}} end --5 flares from the TF2 flaregun
				ScavData.CollectFuncs["models/weapons/c_models/c_scorch_shot/c_scorch_shot.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_scorch_shot/c_scorch_shot.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_scorch_shot/c_scorch_shot.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_xms_flaregun/c_xms_flaregun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_detonator/c_detonator.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_detonator/c_detonator.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_detonator/c_detonator.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_drg_manmelter/c_drg_manmelter.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"] --TODO: infinite slower flares from manmelter
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_drg_manmelter/c_drg_manmelter.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_drg_manmelter/c_drg_manmelter.mdl"]
				--L4D2
				ScavData.CollectFuncs["models/props_fairgrounds/pyrotechnics_launcher.mdl"]	= function(self, ent) return {{"models/items/flare.mdl", 3, ent:GetSkin()}} end --3 flares from the L4D2 Pyrotechnics
				ScavData.CollectFuncs["models/props_fairgrounds/mortar_rack.mdl"] = function(self, ent) return {{"models/items/flare.mdl", 7, ent:GetSkin()}} end --7 flares from the L4D2 Pyrotechnics Mortar
				---ASW
				ScavData.CollectFuncs["models/swarm/flare/flarebox.mdl"] = function(self, ent) return {{"models/swarm/flare/flareweapon.mdl", 5, ent:GetSkin()}} end --5 flares from the TF2 flaregun
			else
				tab.fov = 10
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/items/flare.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/flare.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_flaregun_shell.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarm/flare/flareweapon.mdl")
		ScavData.RegisterFiremode(tab, "models/swarmprops/miscdeco/greenflare.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_flare.mdl")

--[[==============================================================================================
	--Arrows and Bolts (Impaler)
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.impaler"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 8
			tab.MaxAmmo = 6
			if SERVER then
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("scav_projectile_impaler")
					proj.Owner = self.Owner
					proj:SetModel(item.ammo)
					proj:SetPos(self.Owner:GetShootPos() - self:GetAimVector() * 15 + self:GetAimVector():Angle():Right() * 2 - self:GetAimVector():Angle():Up() * 2)
					proj.angoffset = ScavData.GetEntityFiringAngleOffset(proj)
					proj:SetAngles(self:GetAimVector():Angle() + proj.angoffset)
					proj:SetOwner(self.Owner)
					proj:SetSkin(item.data)
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)

					if item.ammo == "models/props_mining/railroad_spike01.mdl" then --yes this is in recognition of the railway rifle from Fallout 3
						self.Owner:EmitSound("ambient/machines/train_horn_1.wav")
					

					elseif item.ammo == "models/props_c17/trappropeller_blade.mdl" then
						proj.Trail = util.SpriteTrail(proj, 0, Color(255, 255, 255, 255), true, 2, 0, 0.3, 0.25, "trails/smoke.vmt")
						proj.DmgAmt = 100
						proj.NoPin = true
						proj.Drop = vector_origin
						proj:SetAngles(self.Owner:EyeAngles())
						self.Owner:EmitSound("ambient/machines/catapult_throw.wav")
					

					elseif item.ammo == "models/props_junk/harpoon002a.mdl" or item.ammo == "models/lostcoast/fisherman/harpoon.mdl" then
						self.Owner:EmitSound("ambient/machines/catapult_throw.wav")
						proj.DmgAmt = 100
					end

					self.Owner:EmitSound(self.shootsound)
					self.Owner:ViewPunch(Angle(math.Rand(-1, 0), math.Rand(-0.1, 0.1), 0))
					return self:TakeSubammo(item, 1)
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
				hook.Add("PlayerSpawn", "ResetArrowRagdoll", function(pl) pl.ArrowRagdoll = NULL end)
				hook.Add("PlayerDeath", "NoArrowRagdoll", function(pl) if IsValid(pl.ArrowRagdoll) and pl:GetRagdollEntityOld() then pl:GetRagdollEntityOld():Remove() end end)
				hook.Add("CreateEntityRagdoll", "NoArrowRagdoll2", function(ent, rag) if IsValid(ent.ArrowRagdoll) then rag:Remove() end end)
				--]]
				function tab.OnArmed(self, item, olditemname)
					if item.ammo == "models/crossbow_bolt.mdl" then
						self.Owner:EmitSound("weapons/crossbow/reload1.wav")
					end
				end

				ScavData.CollectFuncs["models/items/crossbowrounds.mdl"] = function(self, ent) return {{"models/crossbow_bolt.mdl", 6, ent:GetSkin()}} end --6 crossbow bolts from a bundle of bolts
				ScavData.CollectFuncs["models/weapons/w_crossbow.mdl"] = function(self, ent) return {{"models/crossbow_bolt.mdl", 1, ent:GetSkin()}} end --1 bolt from the crossbow
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_arrow.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/w_models/w_arrow_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, 0}} end
				ScavData.CollectFuncs["models/weapons/c_models/c_claymore/c_claymore.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, math.fmod(ent:GetSkin(), 2)}} end
				ScavData.CollectFuncs["models/weapons/c_models/c_dartgun.mdl"] = function(self, ent) return {{"models/weapons/c_models/c_dart.mdl", 5, ent:GetSkin()}} end --5 darts from Sydney Sleeper
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_sydney_sleeper/c_sydney_sleeper.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_dartgun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/w_models/w_arrow_xmas.mdl" or "models/weapons/w_models/w_arrow.mdl", 3, 0}} end --3 arrows from Huntsman
				ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_bow_thief/c_bow_thief.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/w_models/w_arrow_xmas.mdl" or "models/weapons/w_models/w_arrow.mdl", 1, 0}} end --1 arrow from Crusader's Crossbow TODO: syringe
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow_xmas.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_arrow_xmas.mdl", 3, ent:GetSkin()}} end --3 festive arrows from festive Huntsman
				ScavData.CollectFuncs["models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow_xmas.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_arrow_xmas.mdl", 1, ent:GetSkin()}} end --1 arrows from Crusader's Crossbow TODO: candy cane
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow_xmas.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_tele_shotgun/c_tele_shotgun.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_repair_claw.mdl", 4, ent:GetSkin()}} end --4 claws from Rescue Ranger
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_tele_shotgun/c_tele_shotgun.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_tele_shotgun/c_tele_shotgun.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow_thief.mdl"] = ScavData.CollectFuncs["models/workshop_partner/weapons/c_models/c_bow_thief/c_bow_thief.mdl"]
				ScavData.CollectFuncs["models/pickups/pickup_powerup_precision.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_bow/c_bow.mdl"]
				--FoF
				ScavData.CollectFuncs["models/weapons/w_bow.mdl"] = function(self, ent) return {{"models/weapons/bowarrow_bolt.mdl", 1, 0}} end --1 arrow from bows
				ScavData.CollectFuncs["models/weapons/w_bow_black.mdl"] = ScavData.CollectFuncs["models/weapons/w_bow.mdl"]
				ScavData.CollectFuncs["models/weapons/w_xbow.mdl"] = ScavData.CollectFuncs["models/weapons/w_bow.mdl"]
				ScavData.CollectFuncs["models/weapons/w_axe_proj.mdl"] = function(self, ent) return {{"models/weapons/w_axe.mdl", 1, 0}} end --1 unscuffed axe model
				--BMS
				ScavData.CollectFuncs["models/weapons/w_crossbow_mp.mdl"] = function(self, ent) return {{"models/weapons/crossbow_bolt.mdl", 1, 0}} end
				ScavData.CollectFuncs["models/weapons/w_crossbow_clip.mdl"] = function(self, ent) return {{"models/weapons/crossbow_bolt.mdl", 5, 0}} end
				ScavData.CollectFuncs["models/weapons/w_crossbow_clip_mp.mdl"] = ScavData.CollectFuncs["models/weapons/w_crossbow_clip.mdl"]
			else
				tab.fov = 10
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/crossbow_bolt.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/harpoon002a.mdl")
		ScavData.RegisterFiremode(tab, "models/mixerman3d/other/arrow.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/trappropeller_blade.mdl") --TODO: make its own entity? needs to spiIiIiIin. Also, on occassion when fired in tight quarters, doesn't render?
		ScavData.RegisterFiremode(tab, "models/props_mining/railroad_spike01.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/weapons/w_knife_ct.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_knife_t.mdl")
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_knife_t.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_knife/c_knife.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_arrow.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_arrow_xmas.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_claymore/c_claymore.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_scout_sword/c_scout_sword.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_scout_sword/c_scout_sword.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_demo_sultan_sword/c_demo_sultan_sword.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_demo_sultan_sword/c_demo_sultan_sword.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_machete/c_machete.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_croc_knife/c_croc_knife.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_scimitar/c_scimitar.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_scimitar/c_scimitar.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_wood_machete/c_wood_machete.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_wood_machete/c_wood_machete.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_prinny_knife/c_prinny_knife.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_dart.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_sydney_sleeper/c_sydney_sleeper_dart.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_repair_claw.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_knife.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_ava_roseknife/c_ava_roseknife_v.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_switchblade/c_switchblade.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_switchblade/c_switchblade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab, "models/weapons/melee/w_machete.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/melee/w_katana.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/melee/w_pitchfork.mdl")
		--Lost Coast
		ScavData.RegisterFiremode(tab, "models/lostcoast/fisherman/harpoon.mdl")
		--FoF
		ScavData.RegisterFiremode(tab, "models/weapons/bowarrow_bolt.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_axe.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_knife.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_machete.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/crossbow_bolt.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/bayonet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/pen.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/scissors.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canteen/spork.mdl")

--[[==============================================================================================
	--Scav Grenade
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.nadelauncher"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.MaxAmmo = 20
			local identify = {
				--[Pop Can] = 0,
				--[[TF2]]["models/weapons/w_models/w_grenade_grenadelauncher.mdl"] = 1,
				--[[Iron Bomber]]["models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl"] = 2,
				--[[Caber]]["models/weapons/c_models/c_caber/c_caber.mdl"] = 3,
				["models/workshop/weapons/c_models/c_caber/c_caber.mdl"] = 3,
				--[[CSS Grenade]]["models/weapons/w_eq_fraggrenade.mdl"] = 4,
				["models/weapons/w_eq_fraggrenade_thrown.mdl"] = 4,
				["models/swarm/grenades/handgrenadeprojectile.mdl"] = 4,
				--[[Water Bottle]]["models/props/cs_office/water_bottle.mdl"] = 5,
				--[[FoF]]["models/weapons/w_dynamite.mdl"] = 6,
				["models/weapons/w_dynamite_black.mdl"] = 6,
				["models/weapons/w_dynamite_yellow.mdl"] = 6,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.OnArmed = function(self, item, olditemname)
					local tab = ScavData.models[item.ammo]
					if tab.Identify[item.ammo] == 0 then
						self.Owner:EmitSound("player/pl_scout_dodge_can_open.wav")
				    end
				end
				tab.FireFunc = function(self, item)
					self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
					local proj = self:CreateEnt("scav_projectile_grenade")
					proj:SetModel(item.ammo)
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles((self:GetAimVector():Angle():Up() * -1):Angle())
					proj:Spawn()
					proj:SetSkin(item.data)
					proj:GetPhysicsObject():Wake()
					proj:GetPhysicsObject():SetMass(1)
					proj:GetPhysicsObject():EnableDrag(true)
					proj:GetPhysicsObject():EnableGravity(true)
					proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector()) * 2300, Vector(0, 0, 3)) --self:GetAimVector():Angle():Up() * 0.1
					timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(0, 10000, 0)) end)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound(self.shootsound)
					--gamemode.Call("ScavFired", self.Owner, proj)
					return self:TakeSubammo(item, 1)
				end
				ScavData.CollectFuncs["models/props_interiors/vendingmachinesoda01a.mdl"] = function(self, ent) --nine grenades + door from vending machine
					return {{"models/props_junk/popcan01a.mdl", 9, math.random(0, 2)},
							{"models/props_interiors/VendingMachineSoda01a_door.mdl", 1, 0}}
				end
				--CSS
				ScavData.CollectFuncs["models/props/cs_office/vending_machine.mdl"] = function(self, ent) return {{"models/props/cs_office/water_bottle.mdl", 9, 0}} end --nine grenades from vending machine
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_grenadelauncher.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_grenade_grenadelauncher.mdl", 4, math.fmod(ent:GetSkin(), 2)}} end --4 grenades from TF2 grenade launcher
				ScavData.CollectFuncs["models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_grenadelauncher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_grenadelauncher/c_grenadelauncher_xmas.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_grenadelauncher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_lochnload/c_lochnload.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_grenade_grenadelauncher.mdl", 2, math.fmod(ent:GetSkin(), 2)}} end --2 grenades from TF2 Loch N Load
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_lochnload/c_lochnload.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_lochnload/c_lochnload.mdl"]
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_quadball/c_quadball.mdl"] = function(self, ent) return {{"models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl", 4, math.fmod(ent:GetSkin(), 2)}} end --4 round grenades from Iron Bomber
				--L4D/2
				ScavData.CollectFuncs["models/props_office/vending_machine01.mdl"] = function(self, ent) return {{"models/props_junk/garbage_sodacan01a.mdl", 9, 0}} end --nine grenades from vending machine
				--FoF
				ScavData.CollectFuncs["models/weapons/w_dynamite.mdl"] = function(self, ent) return {{ScavData.FormatModelname(ent:GetModel()), 2, 0}} end --2 dynamite from red
				ScavData.CollectFuncs["models/weapons/w_dynamite_black.mdl"] = function(self, ent) return {{ScavData.FormatModelname(ent:GetModel()), 4, 0}} end --4 dynamite from black
				ScavData.CollectFuncs["models/weapons/w_dynamite_yellow.mdl"] = ScavData.GiveOneOfItemInf --inf dynamite from yellow
				--ASW
				ScavData.CollectFuncs["models/swarm/grenades/grenadebox.mdl"] = function(self, ent) return {{"models/swarm/grenades/handgrenadeprojectile.mdl", 5, 0}} end
				ScavData.CollectFuncs["models/weapons/grenadelauncher/grenadelauncher.mdl"] = function(self, ent) return {{"models/swarm/grenades/handgrenadeprojectile.mdl", 6, 0}} end
				--BMS
				ScavData.CollectFuncs["models/props_canteen/soda_machine.mdl"] = function(self, ent) return {{"models/props_junk/drinkcan01.mdl", 9, math.random(0, 8)}} end
			end
			tab.Cooldown = 0.75
		ScavData.RegisterFiremode(tab, "models/props_junk/popcan01a.mdl")	
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_grenade_grenadelauncher.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_caber/c_caber.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_caber/c_caber.mdl")
		ScavData.RegisterFiremode(tab, "models/props_gameplay/can_crushed001.mdl")
		ScavData.RegisterFiremode(tab, "models/props_gameplay/can_crushed002.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/weapons/w_eq_fraggrenade.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_eq_fraggrenade_thrown.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/water_bottle.mdl")
		--FoF
		ScavData.RegisterFiremode(tab, "models/weapons/w_dynamite.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_dynamite_black.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_dynamite_yellow.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_sodacan01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_sodacan01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_sodacan01a_crushed.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_sodacan01a_crushed_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_beercan01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_beercan01a_crushed.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_beercan01a_fullsheet.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarm/grenades/handgrenadeprojectile.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_junk/drinkcan01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/popcan_wormjuice.mdl")

--[[==============================================================================================
	--Payload Gun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.payload"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			if SERVER then
				tab.FireFunc = function(self, item)
					self.Owner:ViewPunch(Angle(-20, math.Rand(-0.1, 0.1), 0))
					local proj = self:CreateEnt("scav_projectile_payload")
					proj:SetPhysicsAttacker(self.Owner)
					proj:SetModel(item.ammo)
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetPos(self.Owner:GetShootPos())
					--proj:SetAngles((self:GetAimVector():Angle():Up() * -1):Angle())
					proj:Spawn()
					proj:SetSkin(item.data)
					proj:GetPhysicsObject():Wake()
					proj:GetPhysicsObject():EnableDrag(true)
					proj:GetPhysicsObject():SetDragCoefficient(-10000)
					proj:GetPhysicsObject():EnableGravity(true)
					proj:GetPhysicsObject():SetVelocity(self:GetAimVector() * 2500)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound(self.shootsound)
					--gamemode.Call("ScavFired", self.Owner, proj)
					return true
				end
				ScavData.CollectFuncs["models/xqm/jetbody3.mdl"] = function(self, ent) return {{"models/props_phx/amraam.mdl", 1, 0, 4}} end
				ScavData.CollectFuncs["models/xqm/jetbody3_s2.mdl"] = ScavData.CollectFuncs["models/xqm/jetbody3.mdl"]
				ScavData.CollectFuncs["models/xqm/jetbody3_s3.mdl"] = ScavData.CollectFuncs["models/xqm/jetbody3.mdl"]
				ScavData.CollectFuncs["models/xqm/jetbody3_s4.mdl"] = ScavData.CollectFuncs["models/xqm/jetbody3.mdl"]
				ScavData.CollectFuncs["models/xqm/jetbody3_s5.mdl"] = ScavData.CollectFuncs["models/xqm/jetbody3.mdl"]
				--TF2
				ScavData.CollectFuncs["models/props_trainyard/bomb_cart.mdl"] = function(self, ent) return {{"models/props_trainyard/cart_bomb_separate.mdl", 1, 0}} end
				ScavData.CollectFuncs["models/props_trainyard/bomb_cart_red.mdl"] = ScavData.CollectFuncs["models/props_trainyard/bomb_cart.mdl"]
				ScavData.CollectFuncs["models/custom/dirty_bomb_cart.mdl"] = ScavData.CollectFuncs["models/props_trainyard/bomb_cart.mdl"]
			end
			tab.Cooldown = 5
		ScavData.RegisterFiremode(tab, "models/props_phx/misc/flakshell_big.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/mk-82.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/torpedo.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/ww2bomb.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/amraam.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/laundry_cart001.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/laundry_cart002.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_trainyard/cart_bomb_separate.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarmprops/techdeco/rocketmesh/rocketmesh_new.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_am/crystal_cart.mdl")
		ScavData.RegisterFiremode(tab, "models/props_xen/xen_cart_w.mdl")
		ScavData.RegisterFiremode(tab, "models/props_xen/xen_cart_w_nohandle.mdl")

--[[==============================================================================================
	--Proximity Mine
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.proxmine"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 5
			tab.MaxAmmo = 6
			local identify = {
				--[sticky] = 0,
				--[[non-sticky]]["models/weapons/w_models/w_stickybomb2.mdl"] = 1,
				["models/props_c17/doll01.mdl"] = 1,
				["models/props_unique/doll01.mdl"] = 1,
				["models/props_buildables/mine_02.mdl"] = 1,
			}
			--Still want them unique when collected, so use different table
			tab.Identify2 = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
						self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
						local proj = self:CreateEnt("scav_proximity_mine")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						proj:SetPos(self.Owner:GetShootPos())
						proj:SetAngles((self:GetAimVector():Angle():Up() * -1):Angle())
						proj:Spawn()
						if tab.Identify2[item.ammo] == 1 then
							proj:SetSticky(false)
						end
						proj:SetSkin(item.data)				
						proj:GetPhysicsObject():Wake()
						proj:GetPhysicsObject():SetMass(1)
						proj:GetPhysicsObject():EnableDrag(true)
						proj:GetPhysicsObject():EnableGravity(true)
						--proj:GetPhysicsObject():ApplyForceOffset((self:GetAimVector() + Vector(0, 0, 0.1)) * 5000, Vector(0, 0, 3)) --self:GetAimVector():Angle():Up() * 0.1
						proj:GetPhysicsObject():SetVelocity(self:GetAimVector() * 17000) --self:GetAimVector():Angle():Up() * 0.1
						timer.Simple(0, function() proj:GetPhysicsObject():AddAngleVelocity(Vector(0, 10000, 0)) end)
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self.Owner:EmitSound(self.shootsound)
						self.Owner:AddScavExplosive(proj)
						--gamemode.Call("ScavFired", self.Owner, proj)
						return self:TakeSubammo(item, 1)
					end
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_stickybomb_launcher.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_stickybomb.mdl", 6, math.fmod(ent:GetSkin(), 2)}} end --6 prox mines from the TF2 stickybomb launcher
				ScavData.CollectFuncs["models/weapons/c_models/c_stickybomb_launcher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_stickybomb_launcher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_stickybomb_launcher/c_stickybomb_launcher.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_stickybomb_launcher.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_scottish_resistance.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_stickybomb_d.mdl", 6, math.fmod(ent:GetSkin(), 2)}} end --6 prox mines from the Scottish Resistance
				ScavData.CollectFuncs["models/weapons/c_models/c_scottish_resistance/c_scottish_resistance.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_scottish_resistance.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/c_sticky_jumper/c_sticky_jumper.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_stickybomb2.mdl", 2, math.fmod(ent:GetSkin(), 2)}} end --2 prox mines from the Sticky Jumper TODO: no damage, self/teammates trigger too?
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_kingmaker_sticky/c_kingmaker_sticky.mdl"] = function(self, ent) return {{"models/workshop/weapons/c_models/c_kingmaker_sticky/w_kingmaker_stickybomb.mdl", 4, math.fmod(ent:GetSkin(), 2)}} end --4 prox mines from the Quickie TODO: faster arm time, limit to 4?
				--L4D/2
				ScavData.CollectFuncs["models/props_unique/doll01.mdl"] = function(self, ent) return {{"models/props_c17/doll01.mdl", 1, 0}} end --stack into regular babydoll
				ScavData.CollectFuncs["models/props_junk/garbage_hubcap01a.mdl"] = function(self, ent) return {{"models/props_buildables/mine.mdl", 1, 0}} end --stack into mine (same visual model)
				ScavData.CollectFuncs["models/props_placeable/mine_trophy.mdl"] = function(self, ent) return {{"models/props_buildables/mine.mdl", SCAV_SHORT_MAX, 0}} end
			else
				tab.FireFunc = function(self, item)
					return false
				end
			end
			tab.Cooldown = 0.75
		ScavData.RegisterFiremode(tab, "models/scav/proxmine.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/doll01.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_stickybomb.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_stickybomb3.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_stickybomb_d.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_stickybomb2.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_kingmaker_sticky/w_kingmaker_stickybomb.mdl")
		--ScavData.RegisterFiremode(tab, "models/props_halloween/pumpkin_explode.mdl") --TODO: make it its own entity
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_buildables/mine.mdl")
		ScavData.RegisterFiremode(tab, "models/props_buildables/mine_02.mdl")
		--ASW
		--ScavData.RegisterFiremode(tab, "models/items/mine/mine.mdl") -- physics are screwy

--[[==============================================================================================
	--Tripmines
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.tripmine"
			tab.anim = ACT_VM_MISSCENTER
			tab.Level = 6
			tab.MaxAmmo = 10
			if SERVER then
				local defaultOrientation = {	
					["models/w_tripmine.mdl"] = true,
					["models/weapons/w_tripmine.mdl"] = true,
					["models/weapons/w_tripmine_mp.mdl"] = true,
					["models/props_marines/triplaser.mdl"] = true,
				}
				tab.FireFunc = function(self, item)
					local tr = self.Owner:GetEyeTraceNoCursor()
						if ((tr.HitPos - tr.StartPos):Length() > 64) or tr.Entity:GetClass() == "scav_tripmine" or (not tr.HitWorld and IsValid(tr.Entity) and (tr.Entity:GetMoveType() ~= MOVETYPE_VPHYSICS and tr.Entity:GetMoveType() ~= MOVETYPE_NONE and tr.Entity:GetMoveType() ~= MOVETYPE_PUSH)) then
							self.Owner:EmitSound("buttons/button11.wav")
							return false
						end	
						local proj = self:CreateEnt("scav_tripmine")
						proj:SetModel(item.ammo)
						proj.Owner = self.Owner
						proj:SetOwner(self.Owner)
						if item.ammo == "models/weapons/w_slam.mdl" then
							proj:SetPos(tr.HitPos + tr.HitNormal * 2)
						else
							proj:SetPos(tr.HitPos)
						end
						proj:SetAngles(tr.HitNormal:Angle() + Angle(90, 0, 0))
						proj:Spawn()
						proj:SetMoveType(MOVETYPE_NONE)
						if not tr.HitWorld then
							proj:SetParent(tr.Entity)
						end
						proj:SetSkin(item.data)
						if defaultOrientation[item.ammo] then
							if item.ammo == "models/w_tripmine.mdl" then
								local mins, maxs = proj:GetModelBounds()
								proj:PhysicsInitBox(mins, maxs, "weapon")
								proj:SetPos(tr.HitPos + tr.HitNormal * 8)
							end
							proj:SetAngles(tr.HitNormal:Angle())
						end
						self.Owner:EmitSound("npc/roller/blade_cut.wav")
						self.Owner:AddScavExplosive(proj)
						return self:TakeSubammo(item, 1)
					end
				tab.OnArmed = function(self, item, olditemname)
					if item.ammo == "models/weapons/w_slam.mdl" then
						self.Owner:EmitSound("weapons/slam/mine_mode.wav")
					end
				end
			end
			tab.Cooldown = 0.75
		ScavData.RegisterFiremode(tab, "models/props_lab/huladoll.mdl")
		--HL2:DM
		ScavData.RegisterFiremode(tab, "models/weapons/w_slam.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_tripmine.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_tripmine.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_tripmine_mp.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/triplaser.mdl")

--[[==============================================================================================
	--Proximity, Tripmine, and Hopper screen adjust
==============================================================================================]]--

if CLIENT then

	local minemodes = {
		["#scav.scavcan.proxmine"] = true,
		["#scav.scavcan.tripmine"] = true,
		["#scav.scavcan.hopper"] = true,
	} 

	hook.Add("ScavScreenDrawOverrideIdle", "ScavScreenProxTripMine", function(self)

		if self:GetCurrentItem() == nil or 
			self:GetCurrentItem():GetFiremodeInfo() == nil or 
			not minemodes[self:GetCurrentItem():GetFiremodeInfo().Name] then return end
		
		self:DrawIdle()
		draw.NoTexture()
		--draw empty slots
		for i = 1, 6 do
			surface.DrawCircle(16 + 32 * i, 80, 13, color_black)
			surface.DrawCircle(16 + 32 * i, 80, 12, color_black)
			surface.DrawCircle(16 + 32 * i, 80, 11, color_black)
		end
		--draw filled
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		local splodes = 0
		--scav_tripmine, scav_proximity_mine, scav_bounding_mine
		for _, v in ipairs(ents.FindByClass("scav_*mine")) do
			if not IsValid(v) then continue end
			if v.Owner == owner then splodes = splodes + 1 end
		end
			local rad = 8
		for i = 1, splodes do draw.RoundedBox(rad, 16 + 32 * i - rad, 80 - rad, rad * 2, rad * 2, color_black) end
		return true
	end)
end

--[[==============================================================================================
	--Nailgun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.nailgun"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 150
			local identify = {} --all nails are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("scav_projectile_impaler")
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetPos(self:GetProjectileShootPos())
					local ang = self.Owner:EyeAngles()
					ang:RotateAroundAxis(self.Owner:GetAimVector(), 90)
					proj:SetAngles(ang)
					proj:SetModel(item.ammo)
					proj:SetSkin(item.data)
					proj.DmgAmt = 12
					proj.NoPin = true
					proj.Drop = vector_origin
					proj.Trail = util.SpriteTrail(proj, 0, Color(255, 255, 255, 255), true, 1, 0, 0.1, 0.25, "trails/smoke.vmt")
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("physics/metal/weapon_impact_hard3.wav", 75, 70, 1)
					return self:TakeSubammo(item, 1)
				end
				ScavData.CollectFuncs["models/weapons/w_nailgun.mdl"] = function(self, ent) return {{"models/scav/nailsmall.mdl", 50, 0}} end
				ScavData.CollectFuncs["models/props_lab/cactus.mdl"] = function(self, ent) return {{"models/scav/nail.mdl", 15, 1}} end
				--TF2
				ScavData.CollectFuncs["models/props_2fort/nail001.mdl"] = function(self, ent) return {{"models/scav/nail.mdl", 1, 1}} end
				ScavData.CollectFuncs["models/props_2fort/nail002.mdl"] = ScavData.CollectFuncs["models/props_2fort/nail001.mdl"]
				ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"] = function(self, ent) return {{"models/scav/nail.mdl", 30, 1}} end
				ScavData.CollectFuncs["models/weapons/w_models/w_nailgun.mdl"] = function(self, ent) return {{"models/scav/nail.mdl", 50, 0}} end
				ScavData.CollectFuncs["models/weapons/w_models/w_grenade_nail.mdl"] = function(self, ent) return {{"models/scav/nailsmall.mdl", 30, 0}} end
				ScavData.CollectFuncs["models/weapons/c_models/c_boston_basher/c_boston_basher.mdl"] = function(self, ent) return {{"models/scav/nail.mdl", 21, 0}} end
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_boston_basher/c_boston_basher.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_boston_basher/c_boston_basher.mdl"]
				--FoF
				ScavData.CollectFuncs["models/elpaso/cactus1.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
				ScavData.CollectFuncs["models/elpaso/cactus2.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
				ScavData.CollectFuncs["models/elpaso/cactus3.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
				--BMS
				ScavData.CollectFuncs["models/props_desert/desert_cactus01.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
				ScavData.CollectFuncs["models/props_desert/desert_cactus01_large.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
				ScavData.CollectFuncs["models/props_desert/desert_cactus01_small.mdl"] = ScavData.CollectFuncs["models/props_foliage/cactus01.mdl"]
			end
			tab.Cooldown = 0.075
		ScavData.RegisterFiremode(tab, "models/scav/nail.mdl")
		ScavData.RegisterFiremode(tab, "models/scav/nailsmall.mdl")

--[[==============================================================================================
	--Shurikens
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.shuriken"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			tab.MaxAmmo = 20
			local identify = {} --all shurikens are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
					--self.Owner:ViewPunch(Angle(-5, math.Rand(-0.1, 0.1), 0))
					local proj = self:CreateEnt("scav_projectile_impaler")
					proj:SetModel(item.ammo)
					proj.Owner = self.Owner
					proj:SetOwner(self.Owner)
					proj:SetSkin(item.data)
					proj:SetPos(self:GetProjectileShootPos())
					local ang = self.Owner:EyeAngles()
					ang:RotateAroundAxis(self.Owner:GetAimVector(), 90)
					proj.Trail = util.SpriteTrail(proj, 0, color_white, true, 2, 0, 0.3, 0.25, "trails/smoke.vmt")
					proj.DmgAmt = 8
					self.Owner:EmitSound("weapons/ar2/fire1.wav")
					proj:SetAngles(ang)
					proj.NoPin = true
					proj.Drop = vector_origin
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					return self:TakeSubammo(item, 1)
				end
				--L4D/2
				ScavData.CollectFuncs["models/props_unique/jukebox01.mdl"] = function(self, ent) return {{"models/scav/shuriken.mdl", SCAV_SHORT_MAX, 0}} end --TODO: record model
				--Portal 2
				ScavData.CollectFuncs["models/props_gameplay/laser_disc_player.mdl"] = function(self, ent) return {{"models/props_gameplay/laser_disc.mdl", SCAV_SHORT_MAX, 0}} end
				--BMS
				ScavData.CollectFuncs["models/props_junk/cd_drive.mdl"] = function(self, ent) return {{"models/props_office/cd_music.mdl", SCAV_SHORT_MAX, 0}} end
			end
			tab.Cooldown = 0.2
		ScavData.RegisterFiremode(tab, "models/scav/shuriken.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/scav/shuriken.mdl")
		--Portal 2
		ScavData.RegisterFiremode(tab, "models/props_gameplay/laser_disc.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_office/cd_music.mdl")

--[[==============================================================================================
	--Tank shell
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.tankshell"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			tab.MaxAmmo = 4
			local identify = {} --all tank shells are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			PrecacheParticleSystem("scav_exp_fireball3_a")
			if SERVER then
				for i=3, 7 do
					util.PrecacheModel("models/props_combine/breenbust_Chunk0" .. i .. ".mdl")
				end
				tab.FireFunc = function(self, item)
					local tr = self.Owner:GetEyeTraceNoCursor()
					local ef = EffectData()
						ef:SetStart(self:GetPos())
						ef:SetOrigin(tr.HitPos)
						ef:SetEntity(self)
						ef:SetScale(4)
						util.Effect("ef_scav_tr2", ef, nil, true)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:EmitSound("ambient/explosions/explode_1.wav")
					self.Owner:ViewPunch(Angle(-50, math.Rand(-0.1, 0.1), 0))
					if tr.HitSky then
						return self:TakeSubammo(item, 1)
					end
					local ef = EffectData()
						ef:SetOrigin(tr.HitPos)
						ef:SetNormal(tr.HitNormal)
						util.Effect("ef_scav_exp3", ef, nil, true)
					util.Decal("Scorch", tr.HitPos + tr.HitNormal * 8, tr.HitPos - tr.HitNormal * 8)
					
					util.ScreenShake(self:GetPos(), 500, 10, 4, 4000)
					util.BlastDamage(self, self.Owner, tr.HitPos, 512, 250)
					sound.Play("ambient/explosions/explode_3.wav", self:GetPos(), 100, 100)
					--gamemode.Call("ScavFired", self.Owner, proj)
					return self:TakeSubammo(item, 1)
				end
				--CSS
				ScavData.CollectFuncs["models/props/de_prodigy/ammo_can_01.mdl"] = function(self, ent) return {{"models/weapons/w_bullet.mdl", 4, 0, 2}} end
				ScavData.CollectFuncs["models/props/de_prodigy/ammo_can_02.mdl"] = function(self, ent) return {{"models/weapons/w_bullet.mdl", 4, 0, 1}} end --4 tank shells from an ammo box
				ScavData.CollectFuncs["models/props/de_prodigy/ammo_can_03.mdl"] = function(self, ent) return {{"models/weapons/w_bullet.mdl", 4, 0, 3}} end
			end
			tab.Cooldown = 5
		ScavData.RegisterFiremode(tab, "models/weapons/w_bullet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/gibs/flakgib1.mdl")
		ScavData.RegisterFiremode(tab, "models/scav/tankshell.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_fortifications/flak38.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/halftrackgun_us1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/sherman_tank.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/sherman_tank_snow.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/tiger_tank.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/tiger_tank_navyb.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/tiger_tank_tan.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/tiger_tank_snow.mdl")
		ScavData.RegisterFiremode(tab, "models/props_debris/shellcasing_single1.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_signs/burgersign.mdl")
		ScavData.RegisterFiremode(tab, "models/props_signs/burgersign_beacon.mdl")
		ScavData.RegisterFiremode(tab, "models/props_signs/raisedbillboard.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarm/shotgun/shotgunpellet.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_vehicles/abrams.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/abrams_phys.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/m1a1_abrams_gibs/m1_gib_turret.mdl")

--[[==============================================================================================
	--Electricity beam
==============================================================================================]]--

		local tab = {}
			tab.Name = "#scav.scavcan.shockbeam"
			tab.anim = ACT_VM_RECOIL2
			tab.Level = 4
			tab.MaxAmmo = 500
			local identify = {} --all electricity beams are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.OnArmed = function(self, item, olditemname)
					if item.ammo ~= olditemname then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
				tab.FireFunc = function(self, item)
					if self.Owner:WaterLevel() > 1 then
						ScavData.Electrocute(self, self.Owner, self.Owner:GetPos(), 500, 500, true)
					else
						local proj = self:CreateEnt("scav_projectile_elec")
						proj.Owner = self.Owner
						proj:SetPos(self:GetProjectileShootPos())
						proj:SetAngles(self:GetAimVector():Angle())
						proj.vel = self:GetAimVector() * 1500
						proj:SetOwner(self.Owner)
						proj.SpeedScale = self:GetForceScale()
						proj:Spawn()
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4, -3), math.Rand(-0.1, 0.1), 0))
					--self.Owner:EmitSound("ambient/energy/NewSpark1" .. math.random(0, 1) .. ".wav")
					--self.Owner:EmitSound("weapons/physcannon/superphys_small_zap4.wav")
					self.Owner:EmitSound("npc/scanner/scanner_electric1.wav")
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 0.5
			
		ScavData.RegisterFiremode(tab, "models/props_c17/substation_transformer01b.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_c17/substation_transformer01c.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_c17/substation_transformer01d.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/weapons/w_stunbaton.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_c17/consolebox01a.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_c17/consolebox03a.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_c17/consolebox05a.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_c17/utilityconducter001.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_lab/powerbox01a.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_lab/powerbox02a.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_lab/powerbox02b.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_lab/powerbox02c.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_lab/powerbox02d.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/props_lab/powerbox03a.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_canal/generator01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_canal/generator02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_c17/substation_transformer01a.mdl", SCAV_SHORT_MAX)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/de_prodigy/transformer.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl", 4) --TODO: put pomson on its own firemode. Don't forget cloak drain!
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_drg_righteousbison/c_drg_righteousbison.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_drg_righteousbison/c_drg_righteousbison.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_dex_arm/c_dex_arm.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl", 8)
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_sd_neonsign/c_sd_neonsign.mdl", 8)
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarmprops/machinery/generator1mesh.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/machinery/generators/generator01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/machinery/generators/generator02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/machinery/generators/generator03.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/machinery/generators/generator04.mdl", SCAV_SHORT_MAX)
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_industrial/gasworks_transformer.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_industrial/transformer_single.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_powerup/power_up_transformer_base.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_powerup/power_up_transformer_base_flip.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_powerup/power_up_transformer_bushing_hv.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_powerup/power_up_transformer_bushing_lv.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_powerup/power_up_transformer_bushing_tower.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_powerup/power_up_transformer_bushing_tower_short.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_powerup/power_up_transformer_relay_box.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_industrial/powerbox_large_01.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_industrial/service_terminal.mdl", 15)

--[[==============================================================================================
	--Hyper beam
==============================================================================================]]--

		local tab = {}
			tab.Name = "#scav.scavcan.hyperbeam"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 9
			if SERVER then
				tab.OnArmed = function(self, item, olditemname)
					if item.ammo ~= olditemname then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("scav_projectile_hyper")
					self.Owner:EmitSound("ambient/explosions/explode_7.wav", 100, 190, 0.65)
					proj.Owner = self.Owner
					proj:SetPos(self:GetProjectileShootPos())
					proj:SetAngles(self:GetAimVector():Angle())
					proj.vel = self:GetAimVector() * 2000
					proj:SetOwner(self.Owner)
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4, -3), math.Rand(-0.1, 0.1), 0))
					return self:TakeSubammo(item, 1)
				end
			else
				tab.FireFunc = function(self, item)
					return false
				end
			end
			tab.Cooldown = 0.3
			
		ScavData.RegisterFiremode(tab, "models/metroid.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_combine/introomarea.mdl", SCAV_SHORT_MAX)

--[[==============================================================================================
	--I just couldn't resist: The BFG9000
==============================================================================================]]--

		local tab = {}
			tab.Name = "#scav.scavcan.bfg9000"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = nil
			tab.RemoveOnCharge = false
			tab.Level = 9
			tab.MaxAmmo = 4
			local identify = {} --all bfgs are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.OnArmed = function(self, item, olditemname)
					if item.ammo ~= olditemname then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
			end
			tab.ChargeAttack = function(self, item)
				local tab = ScavData.models[item.ammo]
				if SERVER then
					self.soundloops.bfgcharge:PlayEx(100, 60 + math.min(self.WeaponCharge, 4) * 40)
					self.soundloops.bfgcharge2:PlayEx(100, 60 + math.min(self.WeaponCharge, 4) * 40)
				end
				if not self.Owner:KeyDown(IN_ATTACK) and (self.WeaponCharge >= 1) then
					if SERVER then
						local proj = self:CreateEnt("scav_projectile_bigshot")
							proj.Charge = math.floor(math.min(self.WeaponCharge, 4))
							proj.Owner = self.Owner
							proj:SetPos(self:GetProjectileShootPos())
							proj:SetAngles(self:GetAimVector():Angle())
							proj:SetOwner(self.Owner)
							proj.SpeedScale = self:GetForceScale()
							proj:Spawn()
						if proj:GetPhysicsObject():IsValid() then
							proj:GetPhysicsObject():SetVelocity(self:GetAimVector() * 500)
						end
						self.Owner:ViewPunch(Angle(math.Rand(-4, -3), math.Rand(-0.1, 0.1), 0))
						net.Start("scv_falloffsound")
							local rf = RecipientFilter()
							rf:AddAllPlayers()
							net.WriteVector(self:GetPos())
							net.WriteString("weapons/physgun_off.wav")
						net.Send(rf)
						self.soundloops.bfgcharge:Stop()
						self.soundloops.bfgcharge2:Stop()
						self:TakeSubammo(item, proj.Charge)
						self:KillEffect()
						if item.subammo <= 0 then
							self:RemoveItemValue(item)
						end
						self:SetPanelPose(0, 2)
						self:SetBlockPose(0, 2)
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
					self.WeaponCharge = self.WeaponCharge + 0.05
					if self.WeaponCharge >= 6 and IsValid(self.Owner) then
						if SERVER then
							local proj = self:CreateEnt("scav_projectile_bigshot")
								proj.Charge = math.floor(math.min(self.WeaponCharge, 4))
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
							ParticleEffect("scav_exp_bigshot", self.Owner:GetPos(), Angle(0, 0, 0), Entity(0))
						end
						self.WeaponCharge = 0
						self:SetChargeAttack()
						return 3
					end
				end
				return 0.025
			end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				if SERVER then
					self.Owner:EmitSound("HL1/ambience/particle_suck1.wav", 100, 200)
					if not self.soundloops.bfgcharge then
						self.soundloops.bfgcharge = CreateSound(self.Owner, "ambient/machines/combine_shield_loop3.wav")
						self.soundloops.bfgcharge2 = CreateSound(self.Owner, "npc/attack_helicopter/aheli_crash_alert2.wav")
					end
					self.ef_plasmacharge = self:CreateToggleEffect("scav_stream_plasmacharge")
					self:SetPanelPose(0.5, 0.25)
					self:SetBlockPose(0.5, 0.25)
				end
				return false
			end
			tab.Cooldown = 0.1
			
		ScavData.RegisterFiremode(tab, "models/props_vehicles/generatortrailer01.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/props_mining/diesel_generator.mdl", 4)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_mvm/construction_light02.mdl", 4)
		--L4D
		ScavData.RegisterFiremode(tab, "models/props_vehicles/floodlight_generator_nolight.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/props_vehicles/floodlight_generator_nolight_static.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/props_vehicles/floodlight_generator_pose01_static.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/props_vehicles/floodlight_generator_pose02_static.mdl", 4)
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_vehicles/generator.mdl", 4)

--[[==============================================================================================
	--..Or this..
==============================================================================================]]--
		local tab = {}
			tab.Name = "#scav.scavcan.cannon"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_FIDGET
			tab.RemoveOnCharge = false
			tab.Level = 7
			tab.ChargeAttack = function(self, item)
				local tab = ScavData.models[item.ammo]
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
							proj:SetPos(self.Owner:GetShootPos() - proj:OBBCenter())
							proj:GetPhysicsObject():SetVelocity(self:GetAimVector() * ((self.WeaponCharge * 3000) + 500))
							proj:SetPhysicsAttacker(self.Owner)
							proj:GetPhysicsObject():SetDragCoefficient(-10000)
						self:TakeSubammo(item, proj.Charge)
						self:KillEffect()
						self:RemoveItemValue(item)
						self.soundloops.cannon:Stop()
						self.Owner:EmitSound(self.shootsound)
						--self.Owner:ViewPunch(Angle(math.Rand(-4, -3), math.Rand(-0.1, 0.1), 0))
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:SetChargeAttack()
					self.WeaponCharge = 0
					tab.chargeanim = ACT_VM_SECONDARYATTACK
					return 1
				else
					tab.chargeanim = ACT_VM_FIDGET
					self.WeaponCharge = self.WeaponCharge + 0.05
				end
				return 0.1
			end
			tab.FireFunc = function(self, item)
				if SERVER then
					if not self.soundloops.cannon then
						self.soundloops.cannon = CreateSound(self.Owner, "weapons/stickybomblauncher_charge_up.wav")
						self.soundloops.cannon:ChangePitch(160)
					end
					self.soundloops.cannon:Play()
				end
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_phx/cannon.mdl"] = function(self, ent) return {{"models/props_phx/cannonball.mdl", 1, 0}} end --1 cannonball from cannon
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl"] = function(self, ent) return {{"models/weapons/w_models/w_cannonball.mdl", 1, math.fmod(ent:GetSkin(), 2)}} end --1 cannonball from TF2 Loose cannon
				ScavData.CollectFuncs["models/workshop/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl"] = ScavData.CollectFuncs["models/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl"]
				--CSS
				ScavData.CollectFuncs["models/props/de_inferno/cannon_gun.mdl"] = function(self, ent) return {{"models/props_phx/misc/smallcannonball.mdl", 1, 0}} end --1 cannonball from de_inferno cannon
				--L4D/2
				ScavData.CollectFuncs["models/props_unique/airport/atlas.mdl"] = function(self, ent) --1 world from Atlas
					return {{"models/props_unique/airport/atlas.mdl", 1, 0},
							{"models/props_unique/airport/atlas_break_ball.mdl", 1, 0}}
				end
				--FoF
				ScavData.CollectFuncs["models/weapons/cannon_top.mdl"] = function(self, ent) return {{"models/weapons/cannon_ball.mdl", 1, 0}} end --1 cannonball from cannon
			end
			tab.Cooldown = 0.1
			
		ScavData.RegisterFiremode(tab, "models/props_phx/cannonball.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/misc/smallcannonball.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/cannonball_solid.mdl")
		ScavData.RegisterFiremode(tab, "models/dynamite/dynamite.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_cannonball.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lakeside_event/bomb_temp.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lakeside_event/bomb_temp_hat.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/atlas_break_ball.mdl")
		--FoF
		ScavData.RegisterFiremode(tab, "models/weapons/cannon_ball.mdl")

--[[==============================================================================================
	--Conference Call (Crossfire Shotgun)
==============================================================================================]]--
		
		local tab = {}
		tab.Name = "#scav.scavcan.crossfire"
		--tab.anim = ACT_VM_RECOIL3
		tab.anim = ACT_VM_SECONDARYATTACK
		tab.Level = 4
		local identify = {
			--[HL2/Default] = 0,
			--[[TF2]]["models/props_2fort/telephone001.mdl"] = 1,
			["models/props_spytech/control_room_console01.mdl"] = 1,
			["models/props_spytech/control_room_console03.mdl"] = 1,
		}
		tab.Identify = setmetatable(identify, {__index = function() return 0 end})
		tab.MaxAmmo = 125
		local bullet = {}
			bullet.Num = 5
			bullet.Spread = Vector(0.0625, 0.0625, 0)
			bullet.Tracer = 1
			bullet.Force = 4
			bullet.Damage = 5
			bullet.Distance = 56756
			bullet.TracerName = "Tracer" --ef_scav_tr_b throws errors if we use it with penetration
		tab.Callback = function(attacker, tr, dmginfo)
			--bullet penetration
			if IsValid(tr.Entity) and not tr.Entity:IsWorld() then --our bullets don't penetrate the world
				local newbullet = table.Copy(bullet)
					newbullet.Num = 1
					newbullet.IgnoreEntity = tr.Entity
					newbullet.Spread = Vector(0, 0, 0)
					newbullet.Src = tr.StartPos + tr.Normal * (bullet.Distance * tr.Fraction)
					newbullet.Dir = tr.Normal
					bullet.TracerName = "Tracer" --ef_scav_tr_b throws errors if we use it with penetration
					newbullet.Attacker = attacker
					newbullet.Callback = tab.Callback --strips the splintering code from subsequent bullets
				if SERVER then
					timer.Simple(0.0025, function()
						local startpos = ents.Create("info_null")
						if IsValid(startpos) then
							startpos:SetPos(newbullet.Src)
							startpos:Spawn() --info_null removes itself, so no need for cleanup
							if SERVER or not game.SinglePlayer() then
								startpos:FireBullets(newbullet)
							end
						end
					end)
				end
			end
		end
		if SERVER then
			tab.OnArmed = function(self, item, olditemname)
				if olditemname ~= "" and ScavData.models[olditemname] and ScavData.models[item.ammo].Name == ScavData.models[olditemname].Name then return end
				local tab = ScavData.models[item.ammo]
				if tab.Identify[item.ammo] == 1 then --TF2
					self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
					timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
				else --HL2
					self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
				end
			end
		end
		tab.FireFunc = function(self, item)
			self.Owner:ScavViewPunch(Angle(-10, math.Rand(-0.1, 0.1), 0), 0.3)
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self:GetAimVector()
			bullet.Callback = function(attacker, tr, dmginfo)
				tab.Callback(attacker, tr, dmginfo)
				if SERVER then
					--splintering
					local tracep = util.QuickTrace(tr.StartPos, tr.Normal * bullet.Distance, function(ent) return (ent:IsWorld()) end)
					local dist = Vector(tracep.StartPos - tracep.HitPos):LengthSqr()
					local start, interval, max = 160, 32, 4 --distance to travel before starting splintering, interval between splinters, splinter this many times
					if dist >= start then
						for i=0, math.min(max - 1, math.floor((dist - start) / interval)) do
							local bullet1 = {}
								bullet1.Num = 1
								bullet1.Attacker = attacker
								bullet1.Spread = Vector(0, 0, 0)
								bullet1.Tracer = 1
								bullet.TracerName = "Tracer" --ef_scav_tr_b throws errors if we use it with penetration
								bullet1.Force = bullet.Force
								bullet1.Damage = bullet.Damage / 2
								bullet1.Src = tracep.StartPos + tracep.Normal * (start + interval * i + math.random(-1, 1))
								bullet1.Dir = tracep.Normal:Angle():Right()
							local bullet2 = table.Copy(bullet1)
								bullet2.Dir = -tracep.Normal:Angle():Right()
							timer.Simple(i / 100, function() --gotta offset these calls slightly so they can all go through
								if CLIENT and game.SinglePlayer() then return end
								local ent = ents.Create("info_null") --this is really gross but if we just use the attacker the tracer draws from the muzzle of the gun instead of its spawn pos
								if not IsValid(ent) then return end
								ent:SetPos(bullet1.Src)
								ent:Spawn() --info_null removes itself, so no need for cleanup
								ent:FireBullets(bullet1)
							end)
							timer.Simple((i + .5) / 100, function()
								local ent = ents.Create("info_null")
								if IsValid(ent) then
									ent:SetPos(bullet2.Src)
									ent:Spawn()
									if SERVER or not game.SinglePlayer() then
										ent:FireBullets(bullet2)
									end
								end
							end)
						end
					end
				end
			end
			if SERVER or not game.SinglePlayer() then
				self.Owner:FireBullets(bullet)
			end
			self:MuzzleFlash2()
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			local tab = ScavData.models[item.ammo]
			if tab.Identify[item.ammo] == 1 then --TF2
				if SERVER then
					self.Owner:EmitSound("weapons/shotgun_shoot.wav")
				end
				timer.Simple(0.4, function()
					if SERVER then
						self.Owner:EmitSound("weapons/shotgun_cock_back.wav")
						timer.Simple(0.25, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun_cock_forward.wav") end end)
					end
					self:EjectShellTF2("shotgun")
				end)
			else --HL2
				if SERVER then
					self.Owner:EmitSound("weapons/shotgun/shotgun_fire6.wav")
				end
				timer.Simple(0.4, function()
					if not IsValid(self) then return end
					self:EjectShell("ShotgunShellEject", false)
					if CLIENT or not IsValid(self.Owner) then return end
					self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav")
				end)
			end
			if SERVER then return self:TakeSubammo(item, 1) end
		end
		tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/props_trainstation/payphone001a.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_trainstation/payphone_reciever001a.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/props_silo/desk_console1.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_silo/desk_console1a.mdl", 14)
		ScavData.RegisterFiremode(tab, "models/props_silo/desk_console1b.mdl", 6)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_office/phone.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/phone_p1.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/phone_p2.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/oldphone01.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props/de_prodigy/desk_console1.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props/de_prodigy/desk_console1a.mdl", 14)
		ScavData.RegisterFiremode(tab, "models/props/de_prodigy/desk_console1b.mdl", 6)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_2fort/telephone001.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_spytech/control_room_console01.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_spytech/control_room_console03.mdl", 20)
		--Portal
		ScavData.RegisterFiremode(tab, "models/props_bts/phone_body.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/props_bts/phone_reciever.mdl", 6)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_interiors/phone.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_interiors/phone_p1.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/props_interiors/phone_p2.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/props_interiors/phone_motel.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_equipment/phone_booth.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_equipment/phone_booth_indoor.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/phone_booth_airport.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_cellphone01a.mdl", 6)
		--Portal 2
		ScavData.RegisterFiremode(tab, "models/props_office/office_phone.mdl", 10)
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_generic/phone01_base.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/props_generic/phone01_headset.mdl", 4)
		ScavData.RegisterFiremode(tab, "models/props_industrial/desk_console1.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_industrial/desk_console1a.mdl", 6)

--[[==============================================================================================
	--Supersonic Shockwave
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.sonicblast"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[Default] = 0,
				--[[Beans]]["models/props/food_can/food_can.mdl"] = 1, --this one's just for you, Anya
				["models/props_junk/garbage_beancan01a.mdl"] = 1,
				["models/props_junk/garbage_beancan01a_fullsheet.mdl"] = 1,
				--[[CSS Bell]]["models/props/de_inferno/bell_large.mdl"] = 2,
				["models/props/de_inferno/bell_largeb.mdl"] = 2,
				["models/props/de_inferno/bell_small.mdl"] = 2,
				["models/props/de_inferno/bell_smallb.mdl"] = 2,
				--[[DoD:S Bell]]["models/props_italian/anzio_bell.mdl"] = 3,
				--[[FoF Bell]]["models/monastery/bell_large.mdl"] = 4,
				--TODO: More unique sounds for these. Guitar, piano, klaxon, Houndeye, radio, gramophone, etc. etc.
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self, item)
					local tab = ScavData.models[item.ammo]
					local proj = self:CreateEnt("scav_projectile_shockwave")
					proj.Owner = self.Owner
					proj:SetPos(self:GetProjectileShootPos())
					--proj:SetPos(self.Owner:GetShootPos() - self:GetAimVector() * 15 + self:GetAimVector():Angle():Right() * 6 - self:GetAimVector():Angle():Up() * 8)
					proj:SetAngles(self:GetAimVector():Angle())
					proj.vel = self:GetAimVector() * 2500
					proj:SetOwner(self.Owner)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4, -3), math.Rand(-0.1, 0.1), 0))
					local soundfx = {
						[0] = function(self, proj)
							self.Owner:EmitSound("ambient/explosions/explode_9.wav", 75, 100, 0.66, CHAN_WEAPONS, SND_NOFLAGS, 0)
							self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav", 75, 100, 0.33, CHAN_WEAPONS, SND_NOFLAGS, 0)
						end,
						[1] = function(self, proj)
							local drop = self:GetProjectileShootPos()
							drop.z = drop.z - 12
							proj:SetPos(drop)
							proj.vel = self:GetAimVector() * -250
							self.Owner:EmitSound("ambient/explosions/explode_9.wav", 75, 100, 0.66, CHAN_WEAPONS, SND_NOFLAGS, 0)
							self.Owner:EmitSound("npc/antlion_guard/shove1.wav", 75, 100, 0.5, CHAN_WEAPONS, SND_NOFLAGS, 0)
						end,
						[2] = function(self, proj)
							self.Owner:EmitSound("ambient/explosions/explode_9.wav", 75, 100, 0.33, CHAN_WEAPONS, SND_NOFLAGS, 0)
							self.Owner:EmitSound("ambient/misc/brass_bell_c.wav", 75, 100, 0.33, CHAN_WEAPONS, SND_NOFLAGS, 0)
							self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav", 75, 100, 0.33, CHAN_WEAPONS, SND_NOFLAGS, 0)
						end,
						[3] = function(self, proj)
							self.Owner:EmitSound("ambient/explosions/explode_9.wav", 75, 100, 0.33, CHAN_WEAPONS, SND_NOFLAGS, 0)
							self.Owner:EmitSound("physics/bigbell.wav", 75, 100, 0.66, CHAN_WEAPONS, SND_NOFLAGS, 0)
							self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav", 75, 100, 0.33, CHAN_WEAPONS, SND_NOFLAGS, 0)
						end,
						[4] = function(self, proj)
							self.Owner:EmitSound("ambient/explosions/explode_9.wav", 75, 100, 0.33, CHAN_WEAPONS, SND_NOFLAGS, 0)
							self.Owner:EmitSound("monastery/bell.wav", 75, 100, 0.66, CHAN_WEAPONS, SND_NOFLAGS, 0)
							self.Owner:EmitSound("npc/env_headcrabcanister/launch.wav", 75, 100, 0.33, CHAN_WEAPONS, SND_NOFLAGS, 0)
						end
					}
					soundfx[tab.Identify[item.ammo]](self, proj)
					proj:Spawn()
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 0.75
			
		ScavData.RegisterFiremode(tab, "models/props_phx/misc/fender.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_lab/citizenradio.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_wasteland/speakercluster01a.mdl", 10)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_office/radio.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/radio_p1.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props/de_inferno/bell_large.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props/de_inferno/bell_largeb.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props/de_inferno/bell_small.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props/de_inferno/bell_smallb.mdl", 10)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_spytech/fire_bell01.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_spytech/fire_bell02.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_spytech/siren001.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bugle/c_bugle.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_battalion_bugle/c_battalion_bugle.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_shogun_warhorn/c_shogun_warhorn.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_shogun_warhorn/c_shogun_warhorn.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_spytech/intercom.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_sunshine/bell001.mdl", 10)
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_italian/anzio_bell.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_italian/gramophone.mdl", 10)
		--L4D2
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/amp_plexi.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/amp_stack.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/amp_stack_small.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/bass_amp.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/front_speaker.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/monitor_speaker.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_unique/jukebox01_body.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/melee/w_electric_guitar.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_rooftop/foghorn01.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/strongmangame_bell.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_equipment/intercom.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_beancan01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_beancan01a_fullsheet.mdl")
		--Portal
		ScavData.RegisterFiremode(tab, "models/props/radio_reference.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props/food_can/food_can.mdl")
		--HL:S
		ScavData.RegisterFiremode(tab, "models/houndeye.mdl", 10)
		--Portal 2
		ScavData.RegisterFiremode(tab, "models/props_underground/intercom_panel.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_underground/old_speaker.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_underground/old_speaker_big.mdl", 10)
		--FoF
		ScavData.RegisterFiremode(tab, "models/monastery/bell_large.mdl", 10)
		--BMS
		ScavData.RegisterFiremode(tab, "models/xenians/houndeye.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/xenians/houndeye_knockback.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_generic/loudspeaker.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_generic/loudspeaker001.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_underground/old_speaker.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_underground/old_speaker_big.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/firealarm_light.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_generic/alarmbell001.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_generic/alarmpull1.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/fireescape_sign.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_marines/army_radio.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_generic/bm_batteryradio01.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_generic/bm_citizenradio01.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_office/stereosystem.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/gibs/props_office/stereosystem_p1.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/gibs/props_office/stereosystem_p2.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/gibs/props_office/stereosystem_p3.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/props_generic/hand_dryer.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_industrial/aircompressor.mdl", 10)

--[[==============================================================================================
	--Gas Canister 
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.canister"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			--local identify = {
				--[Default] = 0,
			--	--[[Beans]]["models/props/food_can/food_can.mdl"] = 1,
			--}
			--tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 3
			if SERVER then
				tab.FireFunc = function(self, item)
					local tab = ScavData.models[item.ammo]
					local proj = self:CreateEnt("scav_projectile_canister")
						proj.Owner = self.Owner
						local pos = self:GetProjectileShootPos()
						pos:Add(self.Owner:GetAimVector() * 72)
						proj:SetPos(pos)
						proj:SetModel(item.ammo)
						proj:SetSkin(item.data)
						proj:SetPhysicsAttacker(self.Owner)
						--proj:SetPos(self.Owner:GetShootPos() - self:GetAimVector() * 15 + self:GetAimVector():Angle():Right() * 6 - self:GetAimVector():Angle():Up() * 8)
						local ang = self:GetAimVector():Angle()
						ang:Add(Angle(-90, 0, 0))
						proj:SetAngles(ang)
						proj:SetOwner(self.Owner)
					proj:Spawn()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4, -3), math.Rand(-0.1, 0.1), 0))
					self.Owner:EmitSound("physics/metal/metal_canister_impact_hard" .. math.random(3) .. ".wav")
					return self:TakeSubammo(item, 1)
				end
				ScavData.CollectFuncs["models/props_industrial/cylinder_store.mdl"] = function(self, ent) return {{"models/props_c17/canister01a.mdl", 3, 0, 2}} end
			end
			tab.Cooldown = 1.5
			
		ScavData.RegisterFiremode(tab, "models/props_c17/canister01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/canister02a.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_2fort/propane_tank_tall01.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_equipment/oxygentank01.mdl")
		--Portal 2
		ScavData.RegisterFiremode(tab, "models/br_debris/deb_gas_canister.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_industrial/chloride_tank01.mdl")

--[[==============================================================================================
	--Disease Shot
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.disease"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[Default] = 0,
				--[[Jarate]]["models/weapons/c_models/urinejar.mdl"] = 1,
				["models/weapons/c_models/c_xms_urinejar.mdl"] = 1,
				["models/weapons/c_models/c_breadmonster/c_breadmonster.mdl"] = 1,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self, item)
					local proj = self:CreateEnt("scav_projectile_bio")
						proj.Owner = self.Owner
						proj:SetPos(self:GetProjectileShootPos())
						--proj:SetPos(self.Owner:GetShootPos() - self:GetAimVector() * 15 + self:GetAimVector():Angle():Right() * 6 - self:GetAimVector():Angle():Up() * 8)
						proj:SetAngles(self:GetAimVector():Angle())
						proj.vel = self:GetAimVector() * 2500
						proj.SpeedScale = self:GetForceScale()
						proj:SetOwner(self.Owner)
						proj:Spawn()
					--TODO: Eh, figure this out later
					--if item.ammo == "models/weapons/c_models/urinejar.mdl" or item.ammo = "models/weapons/c_models/c_xms_urinejar.mdl" then
					--	proj:SetMaterial("models/shiny")
					--	proj:SetColor(240, 220, 50, 255)
					--end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-4, -3), math.Rand(-0.1, 0.1), 0))
					return self:TakeSubammo(item, 1)
				end
				ScavData.CollectFuncs["models/zombie/poison.mdl"] = function(self, ent)
					local items = {{"models/zombie/poison.mdl", 1, ent:GetSkin()}}
					local hccount = ent:GetBodygroup(1) + ent:GetBodygroup(2) + ent:GetBodygroup(3) + ent:GetBodygroup(4)
					if hccount > 0 then table.insert(items, 1, {"models/headcrabblack.mdl", hccount, 0}) end
					return items
				end
				ScavData.CollectFuncs["models/player/corpse1.mdl"] = function(self, ent) return {{"models/humans/corpse1.mdl", 1, 0}} end --playermodel conversion
				--TF2
				ScavData.CollectFuncs["models/props_hydro/water_barrel_cluster2.mdl"] = function(self, ent)
					return {{"models/props_badlands/barrel01.mdl", 8, 0},
							{"models/props_mvm/sack_stack_pallet.mdl", 1, 0},
							{"models/props_badlands/barrel01.mdl", 8, 0},
							{"models/props_mvm/sack_stack_pallet.mdl", 1, 0}}
				end --eight barrels (x2 ea) from clusters
				ScavData.CollectFuncs["models/props_hydro/water_barrel_cluster3.mdl"] = ScavData.CollectFuncs["models/props_hydro/water_barrel_cluster2.mdl"]
				ScavData.CollectFuncs["models/weapons/c_models/urinejar.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_xms_urinejar.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, math.random(0, 1)}} end
				--L4D/2
				ScavData.CollectFuncs["models/infected/boomer.mdl"] = function(self, ent) return {{L4D2 and "models/w_models/weapons/w_eq_bile_flask.mdl" or ScavData.FormatModelname(ent:GetModel()), 3, 0}} end --three boomer biles from a boomer/boomette
				ScavData.CollectFuncs["models/props_debris/dead_cow_smallpile.mdl"] = function(self, ent) return {{"models/props_debris/dead_cow.mdl", 4, ent:GetSkin()}} end
				ScavData.CollectFuncs["models/infected/boomer_l4d1.mdl"] = ScavData.CollectFuncs["models/infected/boomer.mdl"]
				ScavData.CollectFuncs["models/infected/boomette.mdl"] = ScavData.CollectFuncs["models/infected/boomer.mdl"]
			end
			tab.Cooldown = 1
			
		ScavData.RegisterFiremode(tab, "models/headcrabblack.mdl")
		ScavData.RegisterFiremode(tab, "models/humans/corpse1.mdl") --reference to a Dark RP Hobo job I saw years ago
		ScavData.RegisterFiremode(tab, "models/props_lab/jar01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lab/jar01b.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/de_train/biohazardtank.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/toilet.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/urine_trough.mdl", 2)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_badlands/barrel01.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/urinejar.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_xms_urinejar.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_breadmonster/c_breadmonster.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_breadmonster/c_breadmonster_milk.mdl")
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_plague.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/infected/boomer.mdl")
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_eq_bile_flask.mdl")
		ScavData.RegisterFiremode(tab, "models/props_debris/dead_cow.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/pooh_bucket_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/toilet_c.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/toilet_d.mdl")
		ScavData.RegisterFiremode(tab, "models/props_urban/outhouse001.mdl", 3)
		ScavData.RegisterFiremode(tab, "models/props_urban/outhouse002.mdl", 3)
		--FoF
		ScavData.RegisterFiremode(tab, "models/elpaso/horse_poo.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_generic/toilet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lab/chemjar01.mdl")

--[[==============================================================================================
	--sniper rifle
==============================================================================================]]--

		do
			local tab = {}
			local dmgmodifier = function(attacker, tr, dmg)
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
			local identify = {
				--[[Default]]["models/weapons/rifleshell.mdl"] = 0,
				["models/weapons/w_combine_sniper.mdl"] = 0,
				["models/swarm/railgun/railgun.mdl"] = 0,
				["models/weapons/marksmanrifle/marksmanrifle.mdl"] = 0,
				["models/weapons/railgun/railgun.mdl"] = 0,
				--[TF2] = 1
			}
			tab.Identify = setmetatable(identify, {__index = function() return 1 end})
			tab.MaxAmmo = 25
			tab.Cooldown = 0.01
			tab.fov = 5
			function tab.ChargeAttack(self, item)
				if CurTime() - self.sniperzoomstart > 0.5 then
					self:SetZoomed(true)
					hook.Add("AdjustMouseSensitivity", "ScavZoomedIn", function()
						return ScavData.models[item.ammo].fov / GetConVar("fov_desired"):GetFloat()
					end)
					if CLIENT then
						hook.Add( "RenderScreenspaceEffects", "ScavScope", function()
							DrawMaterialOverlay( "effects/combine_binocoverlay", 0.02 )
						end )
					end
					if self.Owner:KeyDown(IN_ATTACK2) then --let the player cancel the scope with Mouse2
						self:SetZoomed(false)
						hook.Remove("AdjustMouseSensitivity", "ScavZoomedIn")
						if CLIENT then
							hook.Remove("RenderScreenspaceEffects", "ScavScope")
						end
						return 0.05
					end
				end
				if not self.Owner:KeyDown(IN_ATTACK) then
					if CurTime() - self.sniperzoomstart <= 0.5 or not self.Owner:KeyDown(IN_ATTACK2) then
						local tab = ScavData.models[item.ammo]
						local ident = tab.Identify[item.ammo]
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						if SERVER or not game.SinglePlayer() then
							self.Owner:FireBullets(bullet)
						end
						local brass = {
							[0] = function(self)
								self:EjectShell("RifleShellEject", false)
								if CLIENT or not IsValid(self.Owner) then return end
								self.Owner:EmitSound("weapons/smg1/switch_burst.wav", 75, 100, 1)
							end;
							[1] = function(self)
								if SERVER then
									self:EmitSound("weapons/sniper_bolt_back.wav", 75, 100, 1)
									timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/sniper_bolt_forward.wav") end end)
								end
								self:EjectShellTF2("sniperrifle")
							end
						}
						timer.Simple(0.45, function()
							if not IsValid(self) then return end
							brass[ident](self)
						end)
						if SERVER then
							self:TakeSubammo(item, 1)
							local soundfx = {
								[0] = function(self)
									self.Owner:EmitSound("NPC_Sniper.FireBullet")
								end,
								[1] = function(self)
									self.Owner:EmitSound(self.Owner:GetStatusEffect("DamageX") and "weapons/sniper_shoot_crit.wav" or "weapons/sniper_shoot.wav")
								end
							}
							if IsValid(self.Owner) then soundfx[ident](self) end
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
					hook.Remove("AdjustMouseSensitivity", "ScavZoomedIn")
					if CLIENT then
						hook.Remove("RenderScreenspaceEffects", "ScavScope")
					end
					tab.chargeanim = ACT_VM_SECONDARYATTACK
					return 1
				end
				tab.chargeanim = ACT_VM_IDLE
				return 0.05
			end
			function tab.FireFunc(self, item)
				if SERVER then
					self.ef_lsight = self:CreateToggleEffect("scav_stream_sniper")
				end
				self:SetChargeAttack(tab.ChargeAttack, item)
				self.sniperzoomstart = CurTime()
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/items/boxsniperrounds.mdl"] = function(self, ent) return {{"models/weapons/rifleshell.mdl", 5, 0}} end
			end
			ScavData.RegisterFiremode(tab, "models/weapons/rifleshell.mdl")
			ScavData.RegisterFiremode(tab, "models/weapons/w_combine_sniper.mdl", 5)
			--TF2
			ScavData.RegisterFiremode(tab, "models/weapons/shells/shell_sniperrifle.mdl")
			ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_sniperrifle.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bazaar_sniper/c_bazaar_sniper.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_bazaar_sniper/c_bazaar_sniper.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_invasion_sniperrifle/c_invasion_sniperrifle.mdl", 25)
			--ASW
			ScavData.RegisterFiremode(tab, "models/swarm/railgun/railgun.mdl", 5)
			ScavData.RegisterFiremode(tab, "models/weapons/marksmanrifle/marksmanrifle.mdl", 5)
			ScavData.RegisterFiremode(tab, "models/weapons/railgun/railgun.mdl", 5)
		end

--[[==============================================================================================
	--plasmagun
==============================================================================================]]--

PrecacheParticleSystem("scav_plasma_1")
PrecacheParticleSystem("scav_exp_plasma")

		local tab = {}
			tab.Name = "#scav.scavcan.plasmagun"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 4
			tab.Identify = {} --all plasma guns are the same
			local identify2 = {
				["models/props_equipment/portablebattery01.mdl"] = SCAV_PLASMA_XEN
			}
			tab.Identify2 = setmetatable(identify2, {__index = function() return SCAV_PLASMA_DEFAULT end})
			tab.MaxAmmo = 500
			if SERVER then
				tab.Callback = function(self, tr)	
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
						--tr.Entity:TakeDamage(15, self.Owner, self.Owner)
					end 
				end
				tab.proj = GProjectile()
				tab.proj:SetCallback(tab.Callback)
				tab.proj:SetBBox(Vector(-8, -8, -8), Vector(8, 8, 8))
				tab.proj:SetPiercing(false)
				tab.proj:SetGravity(vector_origin)
				tab.proj:SetMask(MASK_SHOT)
				tab.OnArmed = function(self, item, olditemname)
					if item.ammo ~= olditemname then
						self.Owner:EmitSound(tab.Identify2[item.ammo] ~= SCAV_PLASMA_XEN and "weapons/scav_gun/chargeup.wav" or "xen/portablebattery_poweron.wav")
					end
				end
			end
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local pos = self.Owner:GetShootPos() + self:GetAimVector() * 24 + self:GetAimVector():Angle():Right() * 4 - self:GetAimVector():Angle():Up() * 4
					local vel = self:GetAimVector() * 2000 * self:GetForceScale()
					if SERVER then
						local proj = tab.proj
						--local proj = s_proj.AddProjectile(self.Owner, pos, self:GetAimVector() * 2000, ScavData.models[item.ammo].Callback, false, false, vector_origin, self.Owner, Vector(-8, -8, -8), Vector(8, 8, 8))
						proj:SetOwner(self.Owner)
						proj:SetInflictor(self)
						proj:SetPos(pos)
						proj:SetVelocity(vel)
						proj:SetFilter(self.Owner)
						proj:Fire()
						--self.Owner:EmitToAllButSelf("weapons/physcannon/energy_bounce2.wav", 80, 150)
						item.lastsound = item.lastsound or 0
						self.Owner:StopSound("weapons/physcannon/energy_disintegrate" .. (4 + item.lastsound) .. ".wav")
						item.lastsound = 1 - item.lastsound
						self:AddBarrelSpin(200)
						self.Owner:EmitSound("weapons/physcannon/energy_disintegrate" .. (4 + item.lastsound) .. ".wav", 80, 255)
						self:TakeSubammo(item, 1) 
					end
					local ef = EffectData()
						ef:SetOrigin(pos)
						ef:SetStart(vel)
						ef:SetEntity(self.Owner)
					util.Effect("ef_scav_plasma", ef)
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
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_xen/xen_cart.mdl"] = function(self, ent) return {{"models/items/car_battery01.mdl", 50, 0}} end
			end
			tab.Cooldown = 0
		ScavData.RegisterFiremode(tab, "models/items/car_battery01.mdl", 50)
		--TF2
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_invasion_pistol/c_invasion_pistol.mdl", 12)
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_junk/junk_6vbattery.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_junk/battery.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_junk/capacitor.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_equipment/portablebattery01.mdl", 100)

--[[==============================================================================================
	--Frag 12 High-Explosive round
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.frag12"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 7
			local identify = {} -- all frag 12 rounds are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 40
			tab.bullet = {}
			tab.bullet.Num = 1
			tab.bullet.Spread = Vector(0.03, 0.03, 0)
			tab.bullet.Tracer = 1
			tab.bullet.Force = 0
			tab.bullet.Damage = 5
			tab.bullet.TracerName = "ef_scav_tr_b"
			tab.bullet.Callback = function(attacker, tr, dmginfo)
				if tr.HitSky then
					return true
				end
				local ef = EffectData()
					ef:SetOrigin(tr.HitPos)
					util.Effect("ef_scav_expsmall", ef)
				if SERVER then
					util.Decal("fadingscorch", tr.HitPos + tr.HitNormal * 8, tr.HitPos - tr.HitNormal * 8)
					util.BlastDamage(attacker:GetActiveWeapon(), attacker, tr.HitPos, 128, 50)
				end
			end
			tab.FireFunc = function(self, item)
				local tab = ScavData.models[item.ammo]
				tab.bullet.Src = self.Owner:GetShootPos()
				tab.bullet.Dir = self:GetAimVector()
				if SERVER or not game.SinglePlayer() then
					self.Owner:FireBullets(tab.bullet)
				end
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self.Owner:EmitSound("^weapons/ar2/fire1.wav")
				if SERVER then return self:TakeSubammo(item, 1) end
			end
			tab.Cooldown = 0.2
		ScavData.RegisterFiremode(tab, "models/items/ammo/frag12round.mdl")
		--L4D2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_eq_explosive_ammopack.mdl", 40)

--[[==============================================================================================
	--Syringe Gun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.syringes"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 4
			local identify = {
				["models/weapons/c_models/c_leechgun/c_leechgun.mdl"] = SCAV_SYRINGE_LEECH,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_SYRINGE_DEFAULT end})
			tab.MaxAmmo = 190 --150 + 40
			local callback = function(self, tr)
				if IsValid(tr.Entity) then
					if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
						tr.Entity:InflictStatusEffect("Disease", 5, 1)
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
			local callback_leech = function(self, tr)
				callback(self, tr)
				if not (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) then return end
				if not IsValid(self.Owner) or self.Owner:Health() >= self.Owner:GetMaxHealth() then return end

				self.Owner:SetHealth(math.min(self.Owner:Health() + 1, self.Owner:GetMaxHealth()))
			end
			if SERVER then
				tab.proj = GProjectile()
					tab.proj:SetCallback(callback)
					tab.proj:SetBBox(Vector(-1, -1, -1), Vector(1, 1, 1))
					tab.proj:SetPiercing(false)
					tab.proj:SetGravity(Vector(0, 0, -96))
					tab.proj:SetMask(MASK_SHOT)
			end
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local ident = tab.Identify[item.ammo]
					local vel = (VectorRand(-0.01, 0.01) + self:GetAimVector()):GetNormalized() * 1500 * self:GetForceScale()
					local pos = self.Owner:GetShootPos() + self:GetAimVector() * 24 + self:GetAimVector():Angle():Right() * 4 - self:GetAimVector():Angle():Up() * 4
					--local proj = s_proj.AddProjectile(self.Owner, self.Owner:GetShootPos() + (self:GetAimVector():Angle():Right() * 2 - self:GetAimVector():Angle():Up() * 2) * 1, vel, ScavData.models["models/weapons/w_models/w_syringegun.mdl"].Callback, false, false, Vector(0, 0, -96))
					if SERVER then
						local proj = tab.proj
						if ident == SCAV_SYRINGE_LEECH then proj:SetCallback(callback_leech) end
						proj:SetOwner(self.Owner)
						proj:SetInflictor(self)
						proj:SetPos(pos)
						proj:SetVelocity(vel)
						proj:SetFilter(self.Owner)
						proj:Fire()
						self:TakeSubammo(item, 1)
						if item.subammo == 0 then
							self.Owner:EmitSound("weapons/syringegun_reload_air1.wav")
							timer.Simple(0.25, function() if IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound("weapons/syringegun_reload_air2.wav") end end)
						end
					end
					if not game.SinglePlayer() or SERVER then
						local ef = EffectData()
							ef:SetOrigin(pos)
							ef:SetStart(vel)
							ef:SetEntity(self.Owner)
							ef:SetScale(item.data % 2)
							ef:SetColor(ident)
						util.Effect("ef_scav_syringe", ef)
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
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				return false
			end
			tab.Cooldown = 0
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_syringegun.mdl", 40)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_syringegun/c_syringegun.mdl", 40)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_leechgun/c_leechgun.mdl", 40)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_proto_syringegun/c_proto_syringegun.mdl", 40)

--[[==============================================================================================
	--Physics Super Shotgun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.physshotsuper"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[[Breen Bust]]["models/props_combine/breenbust.mdl"] = SCAV_PHYSSHOTSUPER_BUST,
				--[[Antlion Spawn Plug]]["models/props_debris/concrete_spawnplug001a.mdl"] = SCAV_PHYSSHOTSUPER_ANTLIONPLUG,
				--[[Office Plant]]["models/props/cs_office/plant01.mdl"] = SCAV_PHYSSHOTSUPER_OFFICEPLANT,
				["models/elpaso/plant01.mdl"] = SCAV_PHYSSHOTSUPER_OFFICEPLANT,
				["models/props_generic/plant_office.mdl"] = SCAV_PHYSSHOTSUPER_OFFICEPLANT,
				--[[Flower Barrel]]["models/props/de_inferno/flower_barrel.mdl"] = SCAV_PHYSSHOTSUPER_FLOWERBARREL,
				--[[Fountain Bowl]]["models/props/de_inferno/fountain_bowl.mdl"] = SCAV_PHYSSHOTSUPER_FOUNTAINBOWL,
				--[[Skylight]]["models/props/cs_militia/skylight_glass.mdl"] = SCAV_PHYSSHOTSUPER_SKYLIGHT,
				--[[Atlas]]["models/props_unique/airport/atlas.mdl"] = SCAV_PHYSSHOTSUPER_ATLAS,
				--[[NP Column]]["models/props_debris/concrete_column001a_core.mdl"] = SCAV_PHYSSHOTSUPER_COLUMN,
				--[[Defective Turret]]["models/npcs/turret/turret_skeleton.mdl"] = SCAV_PHYSSHOTSUPER_DEFECTIVE,
				["models/npcs/turret/turret_backwards.mdl"] = SCAV_PHYSSHOTSUPER_DEFECTIVE,
				["models/npcs/monsters/monster_a.mdl"] = SCAV_PHYSSHOTSUPER_DEFECTIVE,
				["models/npcs/monsters/monster_a_box.mdl"] = SCAV_PHYSSHOTSUPER_DEFECTIVE,
				["models/npcs/monsters/monster_a_head.mdl"] = SCAV_PHYSSHOTSUPER_DEFECTIVE,
				--[[Barricade]]["models/props_wasteland/barricade002a.mdl"] = SCAV_PHYSSHOTSUPER_BARRICADE,
				--[[Boat]]--[[["models/props_canal/boat001a.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_canal/boat001b.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_canal/boat002b.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_fairgrounds/swan_boat.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_swamp/row_boat_ref.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_urban/boat002.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_vehicles/boat_covered.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_vehicles/boat_power.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_vehicles/boat_ski.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_vehicles/boat_smash.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/lostcoast/props_wasteland/boat_wooden01a.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/lostcoast/props_wasteland/boat_wooden02a.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/lostcoast/props_wasteland/boat_wooden01a_static.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/props_italian/boat_wooden03a.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,
				["models/leon/boat_normal.mdl"] = SCAV_PHYSSHOTSUPER_BOAT,]]
				--[[Partition]]["models/props_office/partition_36x48.mdl"] = SCAV_PHYSSHOTSUPER_PARTITION,
				--[[Partition]]["models/props_office/partition_36x60.mdl"] = SCAV_PHYSSHOTSUPER_PARTITION,
				--[[Partition]]["models/props_office/partition_48x48.mdl"] = SCAV_PHYSSHOTSUPER_PARTITION,
				--[[Partition]]["models/props_office/partition_48x60.mdl"] = SCAV_PHYSSHOTSUPER_PARTITION,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_PHYSSHOTSUPER_BOAT end})
			tab.MaxAmmo = 6
			if SERVER then
				tab.FireFunc = function(self, item)
					local data = {
						chunks = {},
						mdl = "",
						ang = self.Owner:GetAngles(),
						pos = self.Owner:GetShootPos(),
						mass = nil,
						drag = true,
					}
					local propdetails = {
						[SCAV_PHYSSHOTSUPER_BUST] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7"}
							data.mdl = "models/props_combine/breenbust_Chunk0"
							data.mass = 15
						end,
						[SCAV_PHYSSHOTSUPER_ANTLIONPLUG] = function(data)
							data.chunks = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"}
							data.mdl = "models/props_debris/concrete_spawnchunk001"
							data.mass = 25
							data.drag = false
							data.ang:Add(Angle(90, 0, 0))
						end,
						[SCAV_PHYSSHOTSUPER_OFFICEPLANT] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7"}
							data.mdl = "models/props/cs_office/plant01_p"
						end,
						[SCAV_PHYSSHOTSUPER_FLOWERBARREL] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"}
							data.mdl = "models/props/de_inferno/flower_barrel_p"
						end,
						[SCAV_PHYSSHOTSUPER_FOUNTAINBOWL] = function(data)
							data.chunks = {"2", "3", "4", "5", "6", "7", "8", "9", "10"}
							data.mdl = "models/props/de_inferno/fountain_bowl_p"
						end,
						[SCAV_PHYSSHOTSUPER_SKYLIGHT] = function(data)
							data.chunks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"}
							data.mdl = "models/props/cs_militia/skylight_glass_p"
							data.ang:Add(Angle(90, 0, 0))
						end,
						[SCAV_PHYSSHOTSUPER_ATLAS] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}
							data.mdl = "models/props_unique/airport/atlas_break0"
							data.pos:Add(Vector(0, 0, -32))
							data.mass = 25
							data.drag = false
						end,
						[SCAV_PHYSSHOTSUPER_COLUMN] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}
							data.mdl = "models/props_debris/concrete_column001a_chunk0"
							data.ang:Add(Angle(0, 0, 90)) --horizontal spread
							data.mass = 25
						end,
						[SCAV_PHYSSHOTSUPER_DEFECTIVE] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26"}
							data.mdl = "models/npcs/turret/turret_fx_break_gib"
							data.mass = 25
						end,
						[SCAV_PHYSSHOTSUPER_BARRICADE] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6"}
							data.mdl = "models/props_wasteland/barricade002a_chunk0"
							data.ang:Add(Angle(0, 90, 0))
							data.mass = 25
						end,
						[SCAV_PHYSSHOTSUPER_BOAT] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7", "8"}
							data.mdl = "models/props_canal/boat001b_chunk0"
							data.mass = 25
						end,
						[SCAV_PHYSSHOTSUPER_PARTITION] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7"}
							data.mdl = "models/props_office/partition_36x48_break0"
							data.mass = 25
						end,
					}
					local tab = ScavData.models[item.ammo]
					propdetails[tab.Identify[item.ammo]](data)
					local chunkspawn = table.Copy(data.chunks)
					while #chunkspawn > 7 do table.remove(chunkspawn, math.random(#chunkspawn)) end --only have a max of 7 chunks
					--chunk 1 of the Portal 2 turrets has some special effects on it that'd be nice to always have
					if tab.Identify[item.ammo] == 8 then chunkspawn[1] = "1" end
					for i= 1, #chunkspawn, 1 do
						local randvec = VectorRand(-0.1, 0.1)
						local proj = self:CreateEnt("prop_physics")
						proj:SetModel(data.mdl .. chunkspawn[i] .. ".mdl")
						proj:SetPos(data.pos + self:GetAimVector() * 30 + randvec)
						proj:SetAngles(data.ang)
						proj:SetPhysicsAttacker(self.Owner)
						proj:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
						proj:Spawn()
						if IsValid(proj) then
							proj:SetOwner(self.Owner)
							local physobj = proj:GetPhysicsObject()
							if IsValid(physobj) then
								if data.mass then physobj:SetMass(data.mass) end
								physobj:AddGameFlag(bit.bor(FVPHYSICS_PENETRATING, FVPHYSICS_WAS_THROWN))
								physobj:SetVelocity((self:GetAimVector() + randvec) * 2500 + self.Owner:GetVelocity())
								physobj:SetBuoyancyRatio(0)
								physobj:EnableDrag(data.drag)
							end
							proj:Fire("kill", 1, "3")
							--gamemode.Call("ScavFired", self.Owner, proj)
						end
					end
					self.Owner:GetPhysicsObject(wake)
					self.Owner:SetVelocity(self.Owner:GetVelocity() - self:GetAimVector() * 200)
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self.Owner:ViewPunch(Angle(math.Rand(-9, -8), math.Rand(-0.1, 0.1), 0))
					self.Owner:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav", 140, 90, 0.5)
					timer.Simple(0.5, function() if IsValid(self) then self:SendWeaponAnim(ACT_VM_HOLSTER) end end)
					timer.Simple(0.75, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun/shotgun_reload3.wav", 100, 65) end end)
					timer.Simple(1.75, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav", 100, 120) end end)
					return self:TakeSubammo(item, 1)
				end
				--Portal 2
				ScavData.CollectFuncs["models/npcs/turret/turret_skeleton.mdl"] = function(self, ent)
					local num = tostring(math.random(18))
					if #num == 1 then num = "0" .. num end
					self.Owner:EmitSound("vo/turret_defective/sp_sabotage_factory_defect_test" .. num .. ".wav", 100, 65)
					return {{ScavData.FormatModelname(ent:GetModel()), 1, 0}}
				end
				ScavData.CollectFuncs["models/npcs/turret/turret_backwards.mdl"] = ScavData.CollectFuncs["models/npcs/turret/turret_skeleton.mdl"]
				ScavData.CollectFuncs["models/npcs/turret/turret_debris_lrg.mdl"] = function(self, ent)
					local givetab = {{ScavData.FormatModelname(math.random(2) == 1 and "models/npcs/turret/turret_skeleton.mdl" or "models/npcs/turret/turret_backwards.mdl"), math.random(3, 10), 0}}
					if math.random(3) == 1 then table.insert(givetab, {ScavData.FormatModelname("models/npcs/turret/turret.mdl"), math.random(25, 75), 0}) end
					return givetab
				end
				ScavData.CollectFuncs["models/npcs/turret/turret_debris_med.mdl"] = function(self, ent)
					local givetab = {{ScavData.FormatModelname(math.random(2) == 1 and "models/npcs/turret/turret_skeleton.mdl" or "models/npcs/turret/turret_backwards.mdl"), math.random(2, 6), 0}}
					if math.random(4) == 1 then table.insert(givetab, {ScavData.FormatModelname("models/npcs/turret/turret.mdl"), math.random(25, 75), 0}) end
					return givetab
				end
				ScavData.CollectFuncs["models/npcs/turret/turret_debris_sml.mdl"] = function(self, ent) return {{ScavData.FormatModelname(math.random(2) == 1 and "models/npcs/turret/turret_skeleton.mdl" or "models/npcs/turret/turret_backwards.mdl"), math.random(1, 4), 0}} end
			end
			tab.Cooldown = 2
		ScavData.RegisterFiremode(tab, "models/props_combine/breenbust.mdl")
		ScavData.RegisterFiremode(tab, "models/props_debris/concrete_spawnplug001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_debris/concrete_column001a_core.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/barricade002a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canal/boat001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canal/boat001b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canal/boat002b.mdl")
		--Lost Coast
		ScavData.RegisterFiremode(tab, "models/lostcoast/props_wasteland/boat_wooden01a.mdl")
		ScavData.RegisterFiremode(tab, "models/lostcoast/props_wasteland/boat_wooden02a.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_office/plant01.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_inferno/flower_barrel.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_inferno/fountain_bowl.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/skylight_glass.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/atlas.mdl")
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/swan_boat.mdl")
		ScavData.RegisterFiremode(tab, "models/props_swamp/row_boat_ref.mdl")
		ScavData.RegisterFiremode(tab, "models/props_urban/boat002.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/boat_covered.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/boat_power.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/boat_ski.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/boat_smash.mdl")
		ScavData.RegisterFiremode(tab, "models/lostcoast/props_wasteland/boat_wooden01a_static.mdl")
		--Portal 2
		ScavData.RegisterFiremode(tab, "models/npcs/turret/turret_skeleton.mdl")
		ScavData.RegisterFiremode(tab, "models/npcs/turret/turret_backwards.mdl")
		ScavData.RegisterFiremode(tab, "models/npcs/monsters/monster_a.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/npcs/monsters/monster_a_box.mdl", 2)
		ScavData.RegisterFiremode(tab, "models/npcs/monsters/monster_a_head.mdl", 2)
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_italian/boat_wooden03a.mdl")
		--FoF
		ScavData.RegisterFiremode(tab, "models/leon/boat_normal.mdl")
		if CSS then --Chunks aren't in FoF/BMS, prop isn't breakable
			ScavData.RegisterFiremode(tab, "models/elpaso/plant01.mdl")
		--BMS
			ScavData.RegisterFiremode(tab, "models/props_generic/plant_office.mdl")
		end
		ScavData.RegisterFiremode(tab, "models/props_office/partition_36x48.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/partition_36x60.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/partition_48x48.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/partition_48x60.mdl")

--[[==============================================================================================
	--Physics Shotgun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.physshot"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 4
			local identify = {
				--[HL2 Toilet] = 0,
				--[[L4D Toilet]]["models/props_interiors/toilet.mdl"] = 1,
				["models/props_interiors/toilet_b.mdl"] = 1,
				["models/props_interiors/toilet_b_breakable01.mdl"] = 1,
				["models/props_interiors/toilet_elongated.mdl"] = 1,
				--[[Watermelon]]["models/props_junk/watermelon01.mdl"] = 2,
				--[[Vent]]["models/props_junk/vent001.mdl"] = 3,
				["models/props_blackmesa/bms_vent_01.mdl"] = 3,
				["models/props_blackmesa/bms_vent_44_01.mdl"] = 3,
				["models/props_blackmesa/bms_vent_44_break.mdl"] = 3,
				["models/props_blackmesa/bms_vent_48_01.mdl"] = 3,
				["models/props_blackmesa/bms_vent_48_break.mdl"] = 3,
				["models/props_blackmesa/bms_vent_64_01.mdl"] = 3,
				["models/props_blackmesa/bms_vent_64_break.mdl"] = 3,
				["models/props_blackmesa/bms_vent_break.mdl"] = 3,
				["models/props_industrial/vent4040.mdl"] = 3,
				["models/props_industrial/vent4040_2.mdl"] = 3,
				--[[Sink]]["models/props_wasteland/prison_sink001a.mdl"] = 4,
				["models/props_wasteland/prison_sink001b.mdl"] = 4,
				--[[Barrel]]["models/props/de_inferno/wine_barrel.mdl"] = 5,
				--[[Clay Pot]]["models/props/de_inferno/claypot01.mdl"] = 6,
				["models/props/de_inferno/claypot02.mdl"] = 6,
				--[[Clay Pot 3]]["models/props/de_inferno/claypot03.mdl"] = 7,
				--[[Projector]]["models/props/cs_office/projector.mdl"] = 8,
				["models/props_bts/projector.mdl"] = 8,
				--[[Pallet]]["models/props_junk/wood_pallet001a.mdl"] = 9,
				["models/props_farm/pallet001.mdl"] = 9,
				["models/props_mvm/sack_stack_pallet.mdl"] = 9,
				["models/props/miscdeco/pallet/pallet.mdl"] = 9,
				["models/props/miscdeco/pallet/palletsingle.mdl"] = 9,
				["models/props_junk/warehouse_pallet01.mdl"] = 9,
				["models/props_junk/warehouse_pallet01_static.mdl"] = 9,
				--[[CSS Pallet]]["models/props/de_prodigy/wood_pallet_01.mdl"] = 10,
				--basically the same as CSS, but do it separately in case they have L4D mounted and not CSS
				--[[L4D Pallet]]["models/props_industrial/pallet01.mdl"] = 11,
				--[[L4D bricks]]["models/props_industrial/brickpallets_break01.mdl"] = 12,
				--[[Barricade]]["models/props_wasteland/barricade001a.mdl"] = 13,
				["models/props_gameplay/sign_barricade001a.mdl"] = 13,
				["models/props_fortifications/traffic_barrier001.mdl"] = 13,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 10
			if SERVER then
				tab.FireFunc = function(self, item)
					local data = {
						chunks = {},
						mdl = "",
						ang = self.Owner:GetAngles(),
					}
					local propdetails = {
						[0] = function(data)
							data.chunks = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"}
							data.mdl = "models/props_wasteland/prison_toiletchunk01"
						end,
						[1] = function(data)
							data.chunks = {"01", "02", "03", "04", "05", "06", "08", "09", "10", "11", "12", "13", "14"}
							data.mdl = "models/props_interiors/toilet_b_breakable01_part"
						end,
						[2] = function(data)
							data.chunks = {"01a", "01b", "01c", "02a", "02b", "02c", "02a"}
							data.mdl = "models/props_junk/watermelon01_chunk"
						end,
						[3] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7", "8"}
							data.mdl = "models/props_junk/vent001_chunk"
						end,
						[4] = function(data)
							data.chunks = {"b", "c", "d", "e", "f", "g", "h"}
							data.mdl = "models/props_wasteland/prison_sinkchunk001"
						end,
						[5] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"}
							data.mdl = "models/props/de_inferno/wine_barrel_p"
						end,
						[6] = function(data)
							data.chunks = {"1", "2", "3", "4"}
							data.mdl = string.sub(item.ammo, 1, -5) .. "_damage_0"
						end,
						[7] = function(data)
							data.chunks = {"1", "2", "3", "4", "5", "6"}
							data.mdl = "models/props/de_inferno/claypot03_damage_0"
						end,
						[8] = function(data)
							data.chunks = {"gib1", "gib2", "gib3", "p1a", "p1b", "p2a", "p2b", "p3a", "p3b", "p4a", "p4b", "p5", "p6a", "p6b", "p7a", "p7b"}
							data.mdl = "models/props/cs_office/projector_"
							data.ang:Add(Angle(90, 0, 0))
						end,
						[9] = function(data)
							data.chunks = {"chunka", "chunka1", "chunka3", "chunkb2", "chunkb3", "shard01"}
							data.mdl = "models/props_junk/wood_pallet001a_"
							data.ang:Add(Angle(90, 0, 0))
						end,
						[10] = function(data)
							data.chunks = {"02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
							data.mdl = "models/props/de_prodigy/wood_pallet_debris_"
							data.ang:Add(Angle(90, 0, 0))
						end,
						[11] = function(data)
							data.chunks = {"02", "04", "06", "09", "10", "11", "12"}
							data.mdl = "models/props_industrial/pallet01_gib"
							data.ang:Add(Angle(90, 0, 0))
						end,
						[12] = function(data)
							data.chunks = {"09", "10", "11", "12", "13", "14"}
							data.mdl = "models/props_industrial/brickpallets_break"
							data.ang:Add(Angle(0, 90, 90))
						end,
						[13] = function(data)
							data.chunks = {"1", "2", "3", "4", "5"}
							data.mdl = "models/props_wasteland/barricade001a_chunk0"
							data.ang:Add(Angle(0, 90, 0))
						end,
					}
					local tab = ScavData.models[item.ammo]
					propdetails[tab.Identify[item.ammo]](data)
					for i=1, #data.chunks, 1 do
						math.randomseed(CurTime() + i)
						local proj = self:CreateEnt("prop_physics")
						proj:SetModel(data.mdl .. data.chunks[i] .. ".mdl")
						local randvec = Vector(math.sin(i) * 0.05, math.cos(i) * 0.05, math.sin(i) * math.cos(i) * 0.05)
						--local randvec = VectorRand(-0.05, 0.05)
						--local randvec = Vector((i + math.random(-7, 7)) * 0.01 * (math.floor(CurTime()) - CurTime()), (i + math.random(-6, 6)) * 0.01 * (math.floor(CurTime()) - CurTime()), (i + math.random(-5, 5)) * 0.01 * (math.floor(CurTime()) - CurTime()))
						proj:SetPos(self.Owner:GetShootPos() + self:GetAimVector() * 30 + (randvec))
						proj:SetAngles(data.ang)
						proj:SetPhysicsAttacker(self.Owner)
						proj:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
						proj:SetGravity(0)
						proj:Spawn()
						if IsValid(proj) then
							proj:SetOwner(self.Owner)
							local physobj = proj:GetPhysicsObject()
							if IsValid(physobj) then
								physobj:SetMass(7)
								physobj:AddGameFlag(FVPHYSICS_WAS_THROWN)
								physobj:SetVelocity((self:GetAimVector() + randvec) * 2500)
								physobj:SetBuoyancyRatio(0)
							end
							proj:Fire("kill", 1, "2")
							--gamemode.Call("ScavFired", self.Owner, proj)
						end
						self.Owner:SetAnimation(PLAYER_ATTACK1)
					end
			
					self.Owner:ViewPunch(Angle(math.Rand(-9, -8), math.Rand(-0.1, 0.1), 0))
					self.Owner:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav", 140, 120, 0.375)
					timer.Simple(0.25, function() if IsValid(self) then self:SendWeaponAnim(ACT_VM_HOLSTER) end end)
					timer.Simple(0.5, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun/shotgun_reload3.wav", 100, 65) end end)
					timer.Simple(1, function() if IsValid(self) then self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav", 100, 120) end end)
					return self:TakeSubammo(item, 1)
				end
			end
			if SERVER then
				--CSS
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"] = function(self, ent) return {
					{ScavData.FormatModelname("models/props/cs_assault/money.mdl"), 1, 0, 5},
					{ScavData.FormatModelname("models/props/de_prodigy/wood_pallet_01.mdl"), 1, 0}
				} end
				ScavData.CollectFuncs["models/props/cs_assault/moneypalleta.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypalletb.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypalletc.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypalletd.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet02.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet02a.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet02b.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet02c.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet02d.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet02e.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet03.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet03a.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet03b.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet03c.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet03d.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				ScavData.CollectFuncs["models/props/cs_assault/moneypallet03e.mdl"] = ScavData.CollectFuncs["models/props/cs_assault/moneypallet.mdl"]
				--L4D/2
				ScavData.CollectFuncs["models/props_industrial/pallet_stack01.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/props_industrial/pallet01.mdl"), 10, 0}} end
				ScavData.CollectFuncs["models/props_industrial/pallet_stack_docks.mdl"] = ScavData.CollectFuncs["models/props_industrial/pallet_stack01.mdl"]
				ScavData.CollectFuncs["models/props_industrial/pallet_barrels_water01.mdl"] = function(self, ent) return {
					{ScavData.FormatModelname("models/props_industrial/pallet_barrels_water01_single.mdl"), 1, 0, 4},
					{ScavData.FormatModelname("models/props_industrial/pallet01.mdl"), 1, 0}
				} end
				ScavData.CollectFuncs["models/props_industrial/pallet_barrels_water01_docks.mdl"] = ScavData.CollectFuncs["models/props_industrial/pallet_barrels_water01.mdl"]
				ScavData.CollectFuncs["models/props_industrial/brickpallets.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/props_industrial/brickpallets_break01.mdl"), 8, 0}} end
				ScavData.CollectFuncs["models/props_industrial/brickpallets_break02.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/props_industrial/brickpallets_break01.mdl"), 1, 0}} end
				ScavData.CollectFuncs["models/props_industrial/brickpallets_break03.mdl"] = ScavData.CollectFuncs["models/props_industrial/brickpallets_break02.mdl"]
				ScavData.CollectFuncs["models/props_industrial/brickpallets_break04.mdl"] = ScavData.CollectFuncs["models/props_industrial/brickpallets_break02.mdl"]
				ScavData.CollectFuncs["models/props_industrial/brickpallets_break05.mdl"] = ScavData.CollectFuncs["models/props_industrial/brickpallets_break02.mdl"]
				ScavData.CollectFuncs["models/props_industrial/brickpallets_break06.mdl"] = ScavData.CollectFuncs["models/props_industrial/brickpallets_break02.mdl"]
				ScavData.CollectFuncs["models/props_industrial/brickpallets_break07.mdl"] = ScavData.CollectFuncs["models/props_industrial/brickpallets_break02.mdl"]
				ScavData.CollectFuncs["models/props_industrial/brickpallets_break08.mdl"] = ScavData.CollectFuncs["models/props_industrial/brickpallets_break02.mdl"]
				--ASW
				ScavData.CollectFuncs["models/props/miscdeco/pallet/pallet.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/props/miscdeco/pallet/palletsingle.mdl"), 4, 0}} end
			end
			tab.Cooldown = 1.25
			ScavData.RegisterFiremode(tab, "models/props_wasteland/prison_toilet01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_c17/furnituretoilet001a.mdl")
			ScavData.RegisterFiremode(tab, "models/props_junk/watermelon01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_wasteland/prison_sink001a.mdl")
			ScavData.RegisterFiremode(tab, "models/props_wasteland/prison_sink001b.mdl")
			ScavData.RegisterFiremode(tab, "models/props_junk/vent001.mdl")
			ScavData.RegisterFiremode(tab, "models/props_junk/wood_pallet001a.mdl")
			ScavData.RegisterFiremode(tab, "models/props_wasteland/barricade001a.mdl")
			--CSS
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/wine_barrel.mdl")
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/claypot01.mdl")
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/claypot02.mdl")
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/claypot03.mdl")
			ScavData.RegisterFiremode(tab, "models/props/cs_office/projector.mdl")
			ScavData.RegisterFiremode(tab, "models/props/de_prodigy/wood_pallet_01.mdl")
			--TF2
			ScavData.RegisterFiremode(tab, "models/props_farm/pallet001.mdl")
			ScavData.RegisterFiremode(tab, "models/props_mvm/sack_stack_pallet.mdl")
			ScavData.RegisterFiremode(tab, "models/props_gameplay/sign_barricade001a.mdl")
			--L4D/2
			ScavData.RegisterFiremode(tab, "models/props_interiors/urinal01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_interiors/toilet.mdl")
			ScavData.RegisterFiremode(tab, "models/props_interiors/toilet_b.mdl")
			ScavData.RegisterFiremode(tab, "models/props_interiors/toilet_b_breakable01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_interiors/toilet_elongated.mdl")
			ScavData.RegisterFiremode(tab, "models/props_industrial/pallet01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_industrial/brickpallets_break01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_fortifications/traffic_barrier001.mdl")
			--DoD:S
			ScavData.RegisterFiremode(tab, "models/props_furniture/toilet1.mdl")
			--Portal
			ScavData.RegisterFiremode(tab, "models/props/toilet_body_reference.mdl")
			if CSS then --chunks aren't in Portal
				ScavData.RegisterFiremode(tab, "models/props_bts/projector.mdl")
			end
			--ASW
			ScavData.RegisterFiremode(tab, "models/props/furniture/misc/toilet.mdl")
			ScavData.RegisterFiremode(tab, "models/props/miscdeco/pallet/palletsingle.mdl")
			--BMS
			ScavData.RegisterFiremode(tab, "models/props_generic/urinal01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_junk/warehouse_pallet01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_junk/warehouse_pallet01_static.mdl")
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_vent_01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_vent_44_01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_vent_44_break.mdl")
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_vent_48_01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_vent_48_break.mdl")
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_vent_64_01.mdl")
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_vent_64_break.mdl")
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_vent_break.mdl")
			ScavData.RegisterFiremode(tab, "models/props_industrial/vent4040.mdl")
			ScavData.RegisterFiremode(tab, "models/props_industrial/vent4040_2.mdl")

--[[==============================================================================================
	--Flamethrower
==============================================================================================]]--
		
		local creditfix = {
			--["grenade_helicopter"] = true, --TODO: credit is given to #scav_gun (or the grenade itself when not on this list), not the player, when the explosion kills. When the prop slap kills, player gets credit.
			["prop_ragdoll"] = true,
			["npc_tripmine"] = true,
			["scav_projectile_flare2"] = true
			}
		 
		hook.Add("EntityTakeDamage", "ScavGiveFireCredit", function(ent, dmginfo)
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
		end)
		

		local tab = {}
			tab.Name = "#scav.scavcan.flamethrower"
			tab.anim = ACT_VM_IDLE
			tab.Level = 4
			local identify = {} --all flamethrowers are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 1000
			tab.Cooldown = 0.1
			function tab.ChargeAttack(self, item)
				if SERVER then --SERVER
					local tab = ScavData.models[item.ammo]
					local proj = tab.proj
					local extpos = self.Owner:GetShootPos() + self:GetAimVector() * 75
					for _, v in ipairs(ents.FindByClass("env_fire")) do
						if v:GetPos():Distance(extpos) < 75 then
							v:Fire("StartFire", 1, 0)
						end
					end
						proj:SetOwner(self.Owner)
						proj:SetInflictor(self)
						proj:SetFilter(self.Owner)
						proj:SetPos(self.Owner:GetShootPos())
						proj:SetVelocity((self:GetAimVector() + VectorRand(-0.1, 0.1)):GetNormalized() * 360) --was 460 -- + self.Owner:GetVelocity()
						proj:SetLifetime(self:GetForceScale())
						proj:Fire()
					if self.Owner:GetGroundEntity() == NULL then
						self.Owner:SetVelocity(self:GetAimVector() * -45)
					end
					self:AddBarrelSpin(400)
					self:TakeSubammo(item, 1)
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
			function tab.FireFunc(self, item)
				if SERVER then
					self.ef_fthrow = self:CreateToggleEffect("scav_stream_fthrow")
				end
				self:SetChargeAttack(tab.ChargeAttack, item)
				--tab.ChargeAttack(self, item)
				return false
			end
			if SERVER then
				local proj = GProjectile()
				local function callback(self, tr)
					local ent = tr.Entity
					if IsValid(ent) and (not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage", ent, self.Owner)) then
						ent:Ignite(5, 0)
						ent.ignitedby = self.Owner
						local dmg = DamageInfo()
						dmg:SetDamage((self.deathtime - CurTime()) * 7)
						dmg:SetDamageForce(tr.Normal * 30)
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
				proj:SetBBox(Vector(-7, -7, -7), Vector(7, 7, 7))
				proj:SetPiercing(true)
				proj:SetGravity(vector_origin)
				proj:SetMask(bit.bor(MASK_SHOT, CONTENTS_WATER, CONTENTS_SLIME))
				proj:SetLifetime(1)
				tab.proj = proj
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_flamethrower/c_backburner.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_flamethrower/c_backburner_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 200, ent:GetSkin()}} end
			end
			ScavData.RegisterFiremode(tab, "models/props_junk/propanecanister001a.mdl", 100)
			ScavData.RegisterFiremode(tab, "models/props_junk/propane_tank001a.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_c17/canister_propane01a.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_wasteland/gaspump001a.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_citizen_tech/firetrap_propanecanister01a.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_citizen_tech/firetrap_propanecanister01b.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_junk/metalgascan.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/props_junk/gascan001a.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/props_mining/oiltank01.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/props_explosive/explosive_butane_can.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_explosive/explosive_butane_can02.mdl", 50)
			--TF2
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_degreaser/c_degreaser.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_degreaser/c_degreaser.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_flamethrower/c_backburner.mdl")
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_flamethrower/c_backburner_xmas.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_rainblower/c_rainblower.mdl", 200) --TODO: Rainbow fire effect
			ScavData.RegisterFiremode(tab, "models/props_farm/oilcan01.mdl", 75)
			ScavData.RegisterFiremode(tab, "models/props_farm/oilcan01b.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_farm/oilcan02.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/props_farm/gibs/shelf_props01_gib_oilcan01.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_gascan/c_gascan.mdl", 25)
			--L4D/2
			ScavData.RegisterFiremode(tab, "models/props_equipment/gas_pump.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_equipment/gas_pump_nodebris.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_urban/gas_pump001.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_unique/wooden_barricade_gascans.mdl", 500)
			ScavData.RegisterFiremode(tab, "models/props_placeable/gascan_trophy.mdl", SCAV_SHORT_MAX)
			--ASW
			ScavData.RegisterFiremode(tab, "models/weapons/flamethrower/flamethrower.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/swarm/ammo/ammoflamer.mdl", 200)
			--BMS
			ScavData.RegisterFiremode(tab, "models/props_industrial/petrolcan.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/props_junk/oil_can.mdl", 25)
			ScavData.RegisterFiremode(tab, "models/props_industrial/gascanister01.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_industrial/gascanister02.mdl", 100)

--[[==============================================================================================
	--Fireball
==============================================================================================]]--

		local tab = {}
			tab.Name = "#scav.scavcan.flameball"
			tab.anim = ACT_VM_IDLE
			tab.Level = 4
			local identify = {} -- all fireballs are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 40
			tab.Cooldown = 0.8
			tab.CooldownScale = 1

			PrecacheParticleSystem(TF2 and "projectile_fireball" or "scav_projectile_fireball")
			
			if SERVER then
				tab.Callback = function(self, tr)
					local ent = tr.Entity
					if IsValid(ent) then
						if not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage", ent, self.Owner) then
							local dmg = DamageInfo()
								local multiplier = 1
								if ent:IsOnFire() then multiplier = 3 end --TODO: triple damage should only count on center of projectile
								if ent:IsNPC() then multiplier = multiplier * .5 end --nerf damage against NPCs
								dmg:SetDamage((15 + (self.deathtime - CurTime()) * 5) * multiplier) -- 15-20 damage per shot, tripled if the target is on fire
								dmg:SetDamageForce(tr.Normal * 30)
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
								if TF2 then
									sound.Play("weapons/dragons_fury_impact_hit.wav", tr.HitPos, 75, 100, 0.75)
								else
									sound.Play("player/pl_burnpain2.wav", tr.HitPos, 75, 120, 1)
								end
								self.hits = self.hits + 1
							end
							net.Start("scv_s_time")
								net.WriteEntity(self.Owner:GetWeapon("scav_gun"))
								net.WriteInt(math.floor(reduced), 32)
								net.WriteFloat(reduced - math.floor(reduced))
							net.Send(self.Owner)
							dmg:SetDamageType(bit.bor(DMG_DIRECT, DMG_BURN))
							ent:TakeDamageInfo(dmg)
							ent:Ignite(3, 0)
							ent.ignitedby = self.Owner
						end
						if not (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
							if TF2 then
								sound.Play("weapons/dragons_fury_impact.wav", tr.HitPos, 75, 100, 0.75)
							else
								sound.Play("player/pl_burnpain2.wav", tr.HitPos, 75, 80, 1)
							end
							if ent:IsWorld() then
								--TODO: add a smaller hull check here so shots that only just barely brush the world don't get eaten (probably consistent with the bonus damage check)
								self:SetPiercing(false)
								return
							end
						end
					end
					return
				end
				tab.proj = GProjectile()
				tab.proj:SetCallback(tab.Callback)
				tab.proj:SetBBox(Vector(-16, -16, -16), Vector(16, 16, 16))
				tab.proj:SetPiercing(true)
				tab.proj:SetGravity(vector_origin)
				tab.proj:SetMask(bit.bor(MASK_SHOT, CONTENTS_WATER, CONTENTS_SLIME))
				local lifetime = 0.17533333
				tab.proj:SetLifetime(lifetime)
				tab.proj.hits = 0
				--local proj = tab.proj

				function tab.FireFunc(self, item)
					local tab = ScavData.models[item.ammo]
					local proj = tab.proj
					local extpos = self.Owner:GetShootPos() + self:GetAimVector() * 75
					for k, v in ipairs(ents.FindByClass("env_fire")) do
						if v:GetPos():Distance(extpos) < 75 then
							v:Fire("StartFire", 1, 0)
						end
					end
					proj:SetOwner(self.Owner)
					proj:SetInflictor(self)
					proj:SetFilter(self.Owner)
					proj:SetPos(self.Owner:GetShootPos())
					local vel = self:GetAimVector() * 3000 * self:GetForceScale()
					proj:SetVelocity(vel)
					proj:SetLifetime(lifetime * self:GetForceScale())
					proj:Fire()

					local pos = self.Owner:GetShootPos() + self:GetAimVector() * 24 + self:GetAimVector():Angle():Right() * 4 - self:GetAimVector():Angle():Up() * 4
					local ef = EffectData()
						ef:SetOrigin(pos)
						ef:SetStart(vel)
						ef:SetEntity(self.Owner)
					if TF2 then
						self.Owner:EmitSound("weapons/dragons_fury_shoot.wav", 75, 100, 0.5)
					else
						self.Owner:EmitSound("ambient/fire/mtov_flame2.wav", 75, 150, 1)
					end
					util.Effect("ef_scav_fireball", ef, nil, true)
					if self.Owner:GetGroundEntity() == NULL then
						self.Owner:SetVelocity(self:GetAimVector() * -45)
					end
					self:AddBarrelSpin(500)
					return self:TakeSubammo(item, 1)
				end
			end
			ScavData.RegisterFiremode(tab, "models/props_c17/furniturefireplace001a.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_c17/furniturestove001a.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_wasteland/kitchen_stove001a.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_wasteland/kitchen_stove002a.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_forest/furnace01.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_forest/stove01.mdl", 40)
			--CSS
			ScavData.RegisterFiremode(tab, "models/props/cs_militia/furnace01.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props/cs_militia/stove01.mdl", 40)
			--TF2
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_flameball/c_flameball.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_forest/kitchen_stove.mdl", 40)
			--DoD:S
			ScavData.RegisterFiremode(tab, "models/props_furniture/kitchen_oven1.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_furniture/fireplace1.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_furniture/fireplace2.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_furniture/bakery_oven.mdl", SCAV_SHORT_MAX)
			--L4D/2
			ScavData.RegisterFiremode(tab, "models/props_interiors/makeshift_stove_battery.mdl", 10)
			ScavData.RegisterFiremode(tab, "models/props_junk/torchoven_01.mdl", 10)
			ScavData.RegisterFiremode(tab, "models/props_interiors/stove02.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_interiors/stove03_industrial.mdl", 40)
			ScavData.RegisterFiremode(tab, "models/props_interiors/stove04_industrial.mdl", 40)
			--FoF
			ScavData.RegisterFiremode(tab, "models/props/forest/furnace_2.mdl", 40)

--[[==============================================================================================
	--Acid Sprayer
==============================================================================================]]--
		
		do
			local tab = {}
				tab.Name = "#scav.scavcan.acidspray"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				local identify = {} --all acid sprayers are the same
				tab.Identify = setmetatable(identify, {__index = function() return 0 end})
				tab.MaxAmmo = 1000
				tab.Cooldown = 0.1
				function tab.ChargeAttack(self, item)
					if SERVER then --SERVER
						local proj = tab.proj
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector() + VectorRand(-0.1, 0.1)):GetNormalized() * math.Rand(100, 600) * self:GetForceScale() + self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector() * -35)
						end
						self:AddBarrelSpin(100)
						self:TakeSubammo(item, 1)
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
				function tab.FireFunc(self, item)
					if SERVER then
						self.ef_aspray = self:CreateToggleEffect("scav_stream_aspray")
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					return false
				end
				if SERVER then
					local proj = GProjectile()
					local function callback(self, tr)
						local ent = tr.Entity
						if IsValid(ent) and (not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage", ent, self.Owner)) then
							ent:InflictStatusEffect("Acid", 100, (self.deathtime - CurTime()) / 2, self:GetOwner())
							ent:EmitSound("ambient/levels/canals/toxic_slime_sizzle" .. math.random(2, 4) .. ".wav")
						end
						if not (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) then
							self:SetPiercing(false)
						end
						return
					end
					proj:SetCallback(callback)
					proj:SetBBox(Vector(-8, -8, -8), Vector(8, 8, 8))
					proj:SetPiercing(true)
					proj:SetGravity(Vector(0, 0, -96))
					proj:SetMask(bit.bor(MASK_SHOT, CONTENTS_WATER, CONTENTS_SLIME))
					proj:SetLifetime(1)
					tab.proj = proj
					--CSS
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit1.mdl"] = function(self, ent) return {{"models/props/de_inferno/crate_fruit_break.mdl", 1000, 0, 7}} end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit1_p1.mdl"] = function(self, ent) return {{"models/props/de_inferno/crate_fruit_break.mdl", 1000, 0, 6}} end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2.mdl"] = function(self, ent) return {{"models/props/de_inferno/crate_fruit_break.mdl", 1000, 0, 5}} end
					ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2_p1.mdl"] = ScavData.CollectFuncs["models/props/de_inferno/crates_fruit2.mdl"]
				end
			ScavData.RegisterFiremode(tab, "models/props_junk/plasticbucket001a.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_lab/crematorcase.mdl", 1000)
			ScavData.RegisterFiremode(tab, "models/props_junk/garbage_plasticbottle001a.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/garbage_plasticbottle002a.mdl", 50)
			--CSS
			ScavData.RegisterFiremode(tab, "models/props/cs_italy/orange.mdl")
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/crate_fruit_break_gib1.mdl")
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/crate_fruit_break_gib2.mdl")
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/crate_fruit_break_gib3.mdl")
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/crate_fruit_break.mdl", 400)
			ScavData.RegisterFiremode(tab, "models/props/de_inferno/crate_fruit_break_p1.mdl", 400)
			--L4D/2
			ScavData.RegisterFiremode(tab, "models/props_equipment/fountain_drinks.mdl", 300)
			ScavData.RegisterFiremode(tab, "models/infected/spitter.mdl", 1000)
			ScavData.RegisterFiremode(tab, "models/props_junk/garbage_plasticbottle001a_clientside.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/garbage_plasticbottle001a_fullsheet.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/garbage_plasticbottle001a_static.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/garbage_plasticbottle002a_fullsheet.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/garbage_cleanercan01a.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/garbage_cleanercan01a_fullsheet.mdl", 50)
			--BMS
			ScavData.RegisterFiremode(tab, "models/props_canteen/soda_fountain.mdl", 300)
			ScavData.RegisterFiremode(tab, "models/props_junk/cleanerbottle01.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/plasticcontainer01.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_junk/plasticcontainer02.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/plasticcontainer03.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_junk/plasticcontainer04.mdl", 50)
		end

--[[==============================================================================================
	--Freezing Gas
==============================================================================================]]--
		
		do
			local tab = {}
				tab.Name = "#scav.scavcan.freezinggas"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				local identify = {} --all freezing gases are the same
				tab.Identify = setmetatable(identify, {__index = function() return 0 end})
				tab.MaxAmmo = 200
				tab.Cooldown = 0.1
				function tab.ChargeAttack(self, item)
					if SERVER then --SERVER
						local proj = tab.proj
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector() + VectorRand(-0.1, 0.1)):GetNormalized() * math.Rand(100, 600) * self:GetForceScale() + self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector() * -35)
						end
						self:AddBarrelSpin(100)
						self:TakeSubammo(item, 1)
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
				function tab.FireFunc(self, item)
					if SERVER then
						self.ef_frzgas = self:CreateToggleEffect("scav_stream_freezegas")
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					return false
				end
				if SERVER then
					local proj = GProjectile()
					local function callback(self, tr)
						local ent = tr.Entity
						if IsValid(ent) and (not ent:IsPlayer() or gamemode.Call("PlayerShouldTakeDamage", ent, self:GetOwner())) then
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
							ent:TakeDamageInfo(dmg)
							local slowfactor = 0.8
							local slowstatus = ent:GetStatusEffect("Slow")
							if slowstatus then
								slowfactor = slowstatus.Value * 0.8
							end
							ent:InflictStatusEffect("Slow", 0.35, slowfactor, self:GetOwner())
							local slow = ent:GetStatusEffect("Slow")
							if slow then
								if ent:IsPlayer() and (slow.Value < 0.3) then
									ent:InflictStatusEffect("Frozen", 0.1, 0, self:GetOwner())
								elseif not ent:IsPlayer() and ((ent:IsNPC() and ((ent:Health() < 10) or (slow.EndTime > CurTime() + 3))) or not ent:IsNPC()) then
									ent:InflictStatusEffect("Frozen", 0.2, 0, self:GetOwner())
								end
							end
						end
						-- Create ice platforms on water
						if tr.MatType == MAT_SLOSH then
							local pos = tr.HitPos
							local ice = NULL
							local model = "models/scav/iceplatform.mdl"
							for _, v in ipairs(ents.FindInSphere(pos, 8)) do
								if v:GetClass() == "scav_iceplatform" then
									ice = v
									-- Refresh nearby ice platforms
									v:NextThink(CurTime() + v.LifeTime)
								end
							end
							if not IsValid(ice) then
								local ice = ents.Create("scav_iceplatform")
								if IsValid(ice) then
									ice:SetPos(pos)
									ice:Spawn()
								end
							end
						end
						if not (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) then
							self:SetPiercing(false)
						end
						-- Refresh hit ice platforms
						if IsValid(tr.Entity) and tr.Entity:GetClass() == "scav_iceplatform" then
							tr.Entity:NextThink(CurTime() + tr.Entity.LifeTime)
						end
						return
					end
					proj:SetCallback(callback)
					proj:SetBBox(Vector(-8, -8, -8), Vector(8, 8, 8))
					proj:SetPiercing(true)
					proj:SetGravity(vector_origin)
					proj:SetMask(bit.bor(MASK_SHOT, CONTENTS_WATER, CONTENTS_SLIME))
					proj:SetLifetime(1)
					tab.proj = proj
				end
			ScavData.RegisterFiremode(tab, "models/props_c17/furniturefridge001a.mdl", 100)
			ScavData.RegisterFiremode(tab, "models/props_interiors/refrigerator01a.mdl", 100)
			ScavData.RegisterFiremode(tab, "models/props_wasteland/kitchen_fridge001a.mdl", 150)
			ScavData.RegisterFiremode(tab, "models/props_c17/display_cooler01a.mdl", 150)
			ScavData.RegisterFiremode(tab, "models/props_silo/acunit01.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_silo/acunit02.mdl", 100)
			ScavData.RegisterFiremode(tab, "models/props_forest/refrigerator01.mdl", 200)
			--TF2
			ScavData.RegisterFiremode(tab, "models/props_soho/acunit001.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_soho/acunit001b.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_soho/acunit002.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_soho/acunit002b.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_soho/acunit003.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_soho/acunit003b.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_soho/acunit004.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_soho/acunit004b.mdl", 200)
			--CSS
			ScavData.RegisterFiremode(tab, "models/props/cs_assault/acunit01.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props/cs_assault/acunit02.mdl", 100)
			ScavData.RegisterFiremode(tab, "models/props/de_train/acunit1.mdl", 150)
			ScavData.RegisterFiremode(tab, "models/props/de_train/acunit2.mdl", 100)
			ScavData.RegisterFiremode(tab, "models/props/cs_militia/refrigerator01.mdl", 200)
			--L4D/2
			ScavData.RegisterFiremode(tab, "models/props_equipment/cooler.mdl", 150)
			ScavData.RegisterFiremode(tab, "models/props_downtown/mini_fridge.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_interiors/fridge_mini.mdl", 50)
			ScavData.RegisterFiremode(tab, "models/props_rooftop/acunit01.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_rooftop/acunit2.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_urban/air_conditioner001.mdl")
			ScavData.RegisterFiremode(tab, "models/props_interiors/refrigerator02_main.mdl", 150)
			ScavData.RegisterFiremode(tab, "models/props_interiors/refrigerator03.mdl", 150)
			ScavData.RegisterFiremode(tab, "models/props_interiors/refrigerator03_damaged_01.mdl", 10)
			ScavData.RegisterFiremode(tab, "models/props_urban/fridge001.mdl", 100)
			ScavData.RegisterFiremode(tab, "models/props_urban/fridge002.mdl", 100)
			--ASW
			ScavData.RegisterFiremode(tab, "models/props/furniture/misc/fridge.mdl", 100)
			ScavData.RegisterFiremode(tab, "models/props/techdeco/laboratory/freezerlaboratory.mdl", 200)
			--BMS
			ScavData.RegisterFiremode(tab, "models/props_generic/frig.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_industrial/cryotank_01.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/props_industrial/nitrogentank_xl.mdl", 200)
			ScavData.RegisterFiremode(tab, "models/props_industrial/nitrogentank_l.mdl", 175)
			ScavData.RegisterFiremode(tab, "models/props_industrial/nitrogentank_m.mdl", 125)
			ScavData.RegisterFiremode(tab, "models/props_industrial/nitrogentank_s.mdl", 100)
		end

--[[==============================================================================================
	--Plasma Blade
==============================================================================================]]--

		do
			local tab = {}
				tab.Name = "#scav.scavcan.plasmablade"
				tab.anim = ACT_VM_SWINGMISS
				tab.Level = 4
				local identify = {} --all plasma blades are the same
				tab.Identify = setmetatable(identify, {__index = function() return 0 end})
				tab.Cooldown = 0.15
				local tracep = {}
				tracep.mins = Vector(-8, -8, -8)
				tracep.maxs = Vector(8, 8, 8)
				function tab.ChargeAttack(self, item)
					self.slicestage = self.slicestage + 1
					if self.slicestage == 1 then
						self.Owner:SetAnimation(PLAYER_ATTACK1)
					end
					if SERVER then
						
						local vm = self.Owner:GetViewModel()
						local att = vm:GetAttachment(vm:LookupAttachment("muzzle"))
						if self.slicestage == 1 then
							tracep.start = self.Owner:GetShootPos()
						else
							tracep.start = att.Pos
						end
						tracep.endpos = tracep.start + self.Owner:GetAimVector() * 50
						tracep.filter = self.Owner
						local tr = util.TraceHull(tracep)
						if tr.Hit then
							--self.Owner:EmitSound("ambient/energy/NewSpark08.wav")
							self.Owner:EmitSound("ambient/energy/weld1.wav")
						end
						if IsValid(tr.Entity) then
							local dmg = DamageInfo()
							dmg:SetDamageType(bit.bor(DMG_SLASH, DMG_PLASMA, DMG_ENERGYBEAM))
							dmg:SetDamage(30)
							dmg:SetDamagePosition(tr.HitPos)
							dmg:SetAttacker(self.Owner)
							dmg:SetInflictor(self)
							dmg:SetDamageForce(tr.Normal * 900)
							tr.Entity:TakeDamageInfo(dmg)
						end
						if tr.Hit then
							local edata = EffectData()
							edata:SetOrigin(tr.HitPos)
							edata:SetNormal(tr.HitNormal)
							edata:SetEntity(tr.Entity)
							util.Effect(tr.MatType == MAT_FLESH and "BloodImpact" or "StunstickImpact", edata, true, true)
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
				function tab.FireFunc(self, item)
					if SERVER then
						self.ef_pblade = self:CreateToggleEffect("scav_stream_pblade")
					end
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = tracep.start + self.Owner:GetAimVector() * 50
					tracep.filter = self.Owner
					local tr = util.TraceHull(tracep)
					if tr.Hit then
						tab.anim = ACT_VM_SWINGHIT
					else
						tab.anim = ACT_VM_SWINGMISS
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					self:SetHoldType("melee")
					self.slicestage = 0
					return false
				end
				ScavData.RegisterFiremode(tab, "models/props_phx2/garbage_metalcan001a.mdl", SCAV_SHORT_MAX)
				--TF2
				ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl", SCAV_SHORT_MAX)
		end

--[[==============================================================================================
	--Buzzsaw
==============================================================================================]]--

		util.PrecacheModel("models/gibs/humans/eye_gib.mdl") --thanks Black Mesa mod version!
		PrecacheParticleSystem("scav_gib_burst_blood")

		if SERVER then util.AddNetworkString("ScavSendMeYourGoo") end

		--Okay, if I... if I chop you up in a meat grinder, and the only thing that comes out that's left of you is your eyeball, YOU'RE PROBABLY DEAD
		local function ScavJerma(self, tr, tab, item)
			if SERVER then
				if tr.Entity:Health() > 4 then return false end
				if tab.Identify[item.ammo] ~= SCAV_BUZZSAW_GRINDER or math.random(10) ~= 1 then return false end
				if not tr.Entity:IsNPC() then return false end
				if not (tr.Entity:GetBloodColor() == BLOOD_COLOR_RED or
						tr.Entity:GetBloodColor() == BLOOD_COLOR_ZOMBIE or 
						tr.Entity:GetBloodColor() == BLOOD_COLOR_GREEN) then return false end
				tr.Entity:SetShouldServerRagdoll(false)
				return true
			else
				local attach = tr.attach
				if attach then
					ParticleEffect("scav_gib_burst_blood", attach, Angle(0, 0, 0), game.GetWorld())
					sound.Play("physics/flesh/flesh_bloody_break.wav", attach)
					local brass = ents.CreateClientProp("models/gibs/humans/eye_gib.mdl")
					if IsValid(brass) then
						brass:SetPos(attach)
						brass:SetAngles(angle_zero)
						brass:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
						brass:Spawn()
						brass:DrawShadow(false)
						local angShellAngles = self.Owner:EyeAngles()
						--angShellAngles:RotateAroundAxis(Vector(0, 0, 1), 90)
						local vecShellVelocity = self.Owner:GetAbsVelocity()
						vecShellVelocity = vecShellVelocity + angShellAngles:Right() * math.Rand(50, 70);
						vecShellVelocity = vecShellVelocity + angShellAngles:Up() * math.Rand(300, 350);
						vecShellVelocity = vecShellVelocity + angShellAngles:Forward() * 25;
						local phys = brass:GetPhysicsObject()
						if IsValid(phys) then
							phys:SetVelocity(vecShellVelocity)
							phys:SetAngleVelocity(angShellAngles:Forward() * 1000)
						end
						timer.Simple(10, function() if IsValid(brass) then brass:Remove() end end)
					end
				end
			end
		end
		if CLIENT then
			net.Receive("ScavSendMeYourGoo", function()
				local self = net.ReadEntity()
				if not IsValid(self) then return end
				local tr = {}
				tr.attach = net.ReadVector()
				tr.Hit = true 
				tr.MatType = net.ReadUInt(7)
				tr.HitPos = net.ReadVector()
				tr.HitNormal = net.ReadVector()
				ScavJerma(self, tr)
			end)
		end

		--Transfer NPC blood color to ragdoll
		hook.Add("CreateEntityRagdoll", "ScavBuzzsawRagdollBloodColor", function(owner, ragdoll)
			if owner:GetBloodColor() and owner:GetBloodColor() >= 0 then
				ragdoll.ScavBloodColor = owner:GetBloodColor()
			end
		end)

		local materialblood = {
			[MAT_ALIENFLESH] = BLOOD_COLOR_YELLOW,
			[MAT_ANTLION] = BLOOD_COLOR_ANTLION,
			[MAT_BLOODYFLESH] = BLOOD_COLOR_RED,
			[MAT_COMPUTER] = BLOOD_COLOR_MECH,
			[MAT_FLESH] = BLOOD_COLOR_RED,
			[MAT_DIRT] = BLOOD_COLOR_ZOMBIE,
			[MAT_GRASS] = BLOOD_COLOR_GREEN,
			[MAT_GRATE] = BLOOD_COLOR_MECH,
			[MAT_METAL] = BLOOD_COLOR_MECH,
			[MAT_VENT] = BLOOD_COLOR_MECH
		}

		do
			local tab = {}
				tab.Name = "#scav.scavcan.buzzsaw"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				local identify = {
					--[Default] = SCAV_BUZZSAW_DEFAULT,
					--[[Meat Grinder]]["models/props_c17/grinderclamp01a.mdl"] = SCAV_BUZZSAW_GRINDER,
					["models/props_normandy/mill_grinder.mdl"] = SCAV_BUZZSAW_GRINDER,
					["models/props_mill/grinder_rollers01.mdl"] = SCAV_BUZZSAW_GRINDER,
					["models/props_mill/grinder_rollers02.mdl"] = SCAV_BUZZSAW_GRINDER,
					--[[TF2]]["models/props_forest/saw_blade.mdl"] = SCAV_BUZZSAW_TF2,
					["models/props_forest/saw_blade_large.mdl"] = SCAV_BUZZSAW_TF2,
					["models/props_forest/sawblade_moving.mdl"] = SCAV_BUZZSAW_TF2,
					["models/props_swamp/chainsaw.mdl"] = SCAV_BUZZSAW_TF2,
					--[[L4D2 Chainsaw]]["models/weapons/melee/w_chainsaw.mdl"] = SCAV_BUZZSAW_L4D,
					--[[ASW Chainsaw]]["models/weapons/chainsaw/chainsaw.mdl"] = SCAV_BUZZSAW_ASW,
				}
				tab.Identify = setmetatable(identify, {__index = function() return SCAV_BUZZSAW_DEFAULT end})
				tab.MaxAmmo = 1000
				tab.Cooldown = 0.025
				local tracep = {}
				tracep.mins = Vector(-12, -12, -12)
				tracep.maxs = Vector(12, 12, 12)
				function tab.ChargeAttack(self, item)
					local tab = ScavData.models[item.ammo]
					if IsValid(self.ef_pblade) then
						if self.Owner:WaterLevel() > 1 then
							self.ef_pblade:SetSkin(0) --Clear the bloodied skin from the model
						end
					end
					tracep.start = self.Owner:GetShootPos()
					tracep.endpos = tracep.start + self.Owner:GetAimVector() * 60
					tracep.filter = self.Owner
					local tr = util.TraceHull(tracep)
					--make sure the client gets us
					if IsValid(tr.Entity) then
						if SERVER and ScavJerma(self, tr, tab, item) then
							net.Start("ScavSendMeYourGoo")
								net.WriteEntity(self)
								net.WriteVector(tr.Entity:GetPos() + tr.Entity:OBBCenter())
								net.WriteUInt(tr.MatType, 7)
								net.WriteVector(tr.HitPos)
								net.WriteVector(tr.HitNormal)
							net.Send(player.GetHumans())
							if tr.Entity:IsNPC() then tr.Entity:Remove() end
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
						-- Break down doors
						if string.find(tr.Entity:GetClass(), "door") then
							dmg:SetDamage(10)
							-- Non L4D doors are rarely breakable, so track their "health" separately
							if SERVER and (not tr.Entity:GetInternalVariable("max_health") or tr.Entity:GetInternalVariable("max_health") == 1) then
								tr.Entity.ScavGrindHealth = (tr.Entity.ScavGrindHealth or 0) + 1
								if tr.Entity.ScavGrindHealth >= 100 then
									-- TODO: door breaking FX. Maybe look at how Valve did the breach effect from Ep1?
									tr.Entity:Fire("Break", "", 0)
								end
							end
						end
						if SERVER then
							tr.Entity:TakeDamageInfo(dmg)
							
							if tab.Identify[item.ammo] == SCAV_BUZZSAW_TF2 then
								if IsValid(self.ef_pblade) then
									if (tr.Entity:GetMaterialType() == MAT_FLESH or tr.Entity:GetMaterialType() == MAT_BLOODYFLESH) or --ragdolls, props
										(tr.Entity:GetBloodColor() and (tr.Entity:GetBloodColor() == BLOOD_COLOR_RED or tr.Entity:GetBloodColor() == BLOOD_COLOR_ZOMBIE or tr.Entity:GetBloodColor() == BLOOD_COLOR_GREEN)) then --NPCs
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
						if tr.Entity:GetBloodColor() and tr.Entity:GetBloodColor() >= 0 then
							edata:SetColor(tr.Entity:GetBloodColor())
						elseif tr.Entity.ScavBloodColor then
							edata:SetColor(tr.Entity.ScavBloodColor)
						elseif materialblood[tr.MatType] then
							edata:SetColor(materialblood[tr.MatType])
						end
						if tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ALIENFLESH or tr.MatType == MAT_ANTLION then
							if tab.Identify[item.ammo] == SCAV_BUZZSAW_TF2 then
								sound.Play("ambient/sawblade_impact" .. math.random(2) .. ".wav", tr.HitPos, 75, 100, 0.25)
							else
								sound.Play("npc/manhack/grind_flesh" .. math.random(3) .. ".wav", tr.HitPos)
							end
							--self.Owner:ViewPunch(Angle(math.Rand(-1, -3), 0, 0))
							util.Effect("BloodImpact", edata, true, true)
						else
							sound.Play("npc/manhack/grind" .. math.random(1, 5) .. ".wav", tr.HitPos)
							--self.Owner:ViewPunch(Angle(math.Rand(-0.5, -2), 0, 0))
							util.Effect("ManhackSparks", edata, true, true)
						end
					end
					if SERVER then
						self:AddBarrelSpin(100)
						self:TakeSubammo(item, 1)
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
				function tab.FireFunc(self, item)
					if SERVER then
						local tab = ScavData.models[item.ammo]
						self.ef_pblade = self:CreateToggleEffect("scav_stream_saw", tab.Identify[item.ammo])
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					return false
				end
				if SERVER then
					ScavData.CollectFuncs["models/police.mdl"] = function(self, ent)
						if tobool(ent:GetBodygroup(ent:FindBodygroupByName("manhack"))) then
							return {{"models/manhack.mdl", 200, 0},
									{"models/police.mdl", 1, 0}}
						else
							return {{"models/police.mdl", 1, 0}}
						end
					end
				end
				ScavData.RegisterFiremode(tab, "models/props_junk/sawblade001a.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/grinderclamp01a.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/manhack.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/gibs/manhack_gib01.mdl", 25)
				ScavData.RegisterFiremode(tab, "models/gibs/manhack_gib02.mdl", 25)
				ScavData.RegisterFiremode(tab, "models/gibs/manhack_gib03.mdl", 25)
				ScavData.RegisterFiremode(tab, "models/gibs/manhack_gib04.mdl", 25)
				ScavData.RegisterFiremode(tab, "models/gibs/manhack_gib05.mdl", 25)
				ScavData.RegisterFiremode(tab, "models/gibs/manhack_gib06.mdl", 25)
				ScavData.RegisterFiremode(tab, "models/props_forest/circularsaw01.mdl", 200)
				--CSS
				ScavData.RegisterFiremode(tab, "models/props/cs_militia/circularsaw01.mdl", 200)
				--TF2
				ScavData.RegisterFiremode(tab, "models/props_forest/saw_blade.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_forest/saw_blade_large.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_forest/sawblade_moving.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_swamp/chainsaw.mdl", 1000)
				--L4D2
				ScavData.RegisterFiremode(tab, "models/weapons/melee/w_chainsaw.mdl", 1000)
				ScavData.RegisterFiremode(tab, "models/props_mill/grinder_rollers01.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_mill/grinder_rollers02.mdl", SCAV_SHORT_MAX)
				--DoD:S
				ScavData.RegisterFiremode(tab, "models/props_normandy/mill_grinder.mdl", SCAV_SHORT_MAX)
				--ASW
				ScavData.RegisterFiremode(tab, "models/weapons/chainsaw/chainsaw.mdl", 1000)
				--BMS
				ScavData.RegisterFiremode(tab, "models/props_junk/drill.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_junk/junk_hacksaw.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_inbound/radial_saw.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_questionableethics/qe_necropsy_machine.mdl", SCAV_SHORT_MAX)
		end

--[[==============================================================================================
	--Laser Beam
==============================================================================================]]--

		do
			local tab = {}
				tab.Name = "#scav.scavcan.laser"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				local identify = {} --all lasers are the same
				tab.Identify = setmetatable(identify, {__index = function() return 0 end})
				tab.MaxAmmo = 300
				tab.Cooldown = 0.01
				local tracep = {}
				tracep.mins = Vector(-2, -2, -2)
				tracep.maxs = Vector(2, 2, 2)
				function tab.ChargeAttack(self, item)
					if SERVER then
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = tracep.start + self.Owner:GetAimVector() * 10000
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
											tr.Entity:Fire("break", nil, 0, self.Owner, self)
										else
											tr.Entity:Fire("shatter", "(0.5, 0.5, 0)", 0, self.Owner, self)
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
						self:TakeSubammo(item, 1)
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
				function tab.FireFunc(self, item)
					if SERVER then
						self.ef_beam = self:CreateToggleEffect("scav_stream_laser")
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					return false
				end
				ScavData.RegisterFiremode(tab, "models/roller.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/roller_spikes.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/roller_vehicledriver.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/stalker.mdl", 200)
				--TF2
				ScavData.RegisterFiremode(tab, "models/props_farm/welding_machine01.mdl", 200)
				--ASW
				ScavData.RegisterFiremode(tab, "models/swarm/welder/welder.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/swarm/mininglaser/mininglaser.mdl", 200)
				--BMS
				ScavData.RegisterFiremode(tab, "models/props_lab/surgical_laser.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_industrial/welder.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_am/am_lasertube.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_questionableethics/qe_auxlaser.mdl", 300)
				ScavData.RegisterFiremode(tab, "models/props_questionableethics/qe_primarylaser.mdl", SCAV_SHORT_MAX)
		end

--[[==============================================================================================
	--Arc Beam
==============================================================================================]]--

		do
			local tab = {}
				tab.Name = "#scav.scavcan.arcbeam"
				tab.chargeanim = ACT_VM_FIDGET
				tab.Level = 6
				local identify = {} --all arc beams are the same
				tab.Identify = setmetatable(identify, {__index = function() return 0 end})
				tab.MaxAmmo = 300
				tab.Cooldown = 0.01
				function tab.ChargeAttack(self, item)
					if SERVER then
						self:SetPanelPoseInstant(0.4, 6)
						self:SetBlockPoseInstant(1, 1)
						self:TakeSubammo(item, 1)
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
				function tab.FireFunc(self, item)
					if SERVER then
						self.ef_parc = self:CreateToggleEffect("scav_stream_tesla")
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					return false
				end
				ScavData.RegisterFiremode(tab, "models/props_lab/tpplug.mdl", 100)
				ScavData.RegisterFiremode(tab, "models/props_lab/tpplugholder.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilityconnecter006.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilityconnecter006b.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilityconnecter006c.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilityconnecter006d.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilitypolemount01a.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/substation_circuitbreaker01a.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/substation_stripebox01a.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilitypole01a.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilitypole01b.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilitypole01d.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilitypole02b.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_c17/utilitypole03a.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_lab/incubatorplug.mdl", 100)
				ScavData.RegisterFiremode(tab, "models/props_lab/power_cable001a.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_lab/power_cable002a.mdl", 200)
				--TF2
				ScavData.RegisterFiremode(tab, "models/props_hydro/substation_transformer01.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_swamp/bug_zapper.mdl", 50)
				ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_dex_arm/c_dex_arm.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_dex_arm/c_dex_arm.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_2fort/telephonepole001.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_farm/powertower01.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_farm/powertower01_skybox.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_farm/powertower02.mdl", SCAV_SHORT_MAX)
				ScavData.RegisterFiremode(tab, "models/props_farm/powertower02_skybox.mdl", SCAV_SHORT_MAX)
				--L4D/2
				ScavData.RegisterFiremode(tab, "models/props_shacks/bug_lamp01.mdl", 50)
				ScavData.RegisterFiremode(tab, "models/props_c17/substation_circuitbreaker03.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_street/phonepole1_tall.mdl", SCAV_SHORT_MAX)
				--ASW
				ScavData.RegisterFiremode(tab, "models/items/teslacoil/teslacoil.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/weapons/mininglaser/mininglaser.mdl", 200)
				--BMS
				ScavData.RegisterFiremode(tab, "models/props_lab/labelecsocket01a.mdl", 50)
				ScavData.RegisterFiremode(tab, "models/props_lab/labelecsocket01b.mdl", 100)
				ScavData.RegisterFiremode(tab, "models/props_xen/power_box/xen_power_box.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_xen/power_box/xen_power_box_nocover.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_xen/power_box/xen_power_box_opendown.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_xen/power_box/xen_power_box_opentop.mdl", 200)
				ScavData.RegisterFiremode(tab, "models/props_equipment/powergenerator01.mdl", SCAV_SHORT_MAX)
		end

--[[==============================================================================================
	--GammaBeam
==============================================================================================]]--
		
		PrecacheParticleSystem("scav_exp_rad")
		local pierce = 32
		local tab = {}
			tab.Name = "#scav.scavcan.gammaray"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 7
			local identify = {} --all gamma ray beams are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 10
			tab.vmin = Vector(-4, -4, -4)
			tab.vmax = Vector(4, 4, 4)
			tab.dmginfo = DamageInfo()
			if SERVER then
				tab.OnArmed = function(self, item, olditemname)
					if item.ammo ~= olditemname then
						self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
					end
				end
			end
			tab.FireFunc = function(self, item)
				local tab = ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"]
				local startpos = self.Owner:GetShootPos()
				local filter = {self.Owner, Entity(0)}
				local tr
				local tracep = {}
				tracep.start = startpos
				tracep.endpos = self.Owner:GetShootPos() + (self:GetAimVector() + VectorRand(-0.02, 0.02)):GetNormalized() * 10000
				tracep.filter = filter
				tracep.mask = MASK_SHOT
				tracep.mins = tab.vmin
				tracep.maxs = tab.vmax
				local isspot = false
				if SERVER then
					for i= 1, pierce do
						tr = util.TraceHull(tracep)
						local ent = tr.Entity
						--prevent a bunch of radioactive spots from being spammed on top of one another
						if not isspot then
							local nearby = ents.FindInSphere(tr.HitPos, 300)
							for _, v in ipairs(nearby) do
								if v:GetName() == "ScavGun_GammaRay_WorldSpot" then
									--refresh a previous spot's duration
									ent:InflictStatusEffect("Radiation", 10, 3, self.Owner)
									isspot = true
									--break
								end
							end
						end
						--make a spot on the world for us to make radioactive
						if not isspot and (not IsValid(ent) or ent:IsWorld()) and i == 1 then
							ent = ents.Create("prop_physics")
							if IsValid(ent) then
								isspot = true
								ent:SetModel("models/props_junk/popcan01a.mdl")
								ent:SetPos(tr.HitPos)
								ent:SetRenderMode(RENDERMODE_NONE)
								ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
								ent:Spawn()
								ent:PhysicsDestroy()
								ent:DrawShadow(false)
								ent:SetName("ScavGun_GammaRay_WorldSpot")
								timer.Simple(0, function()
									if not IsValid(ent) then return end
									ent:InflictStatusEffect("Radiation", 5, 3, self.Owner)
									--prevent other statuses from affecting the spot
									hook.Add("OnStatusInflicted", ent, function(_, t)
										if t.ent ~= ent then return end
										if t.Name ~= "Radiation" then return true end
									end)
									--don't let it get moved by physgun
									hook.Add("PhysgunPickup", ent, function(_, ply, e)
										if ent == e then return false end
									end)
								end)
							end
						end
						--note that this explicitly could be our previously created world spot
						if IsValid(ent) and not ent:IsWorld() then
							if not ent:IsFriendlyToPlayer(self.Owner) then
								ent:InflictStatusEffect("Radiation", 10 / i, 3, self.Owner)
								local dmg = tab.dmginfo
								dmg:SetAttacker(self.Owner)
								dmg:SetInflictor(self)
								dmg:SetDamage(30)
								dmg:SetDamageForce(vector_origin)
								dmg:SetDamagePosition(tr.HitPos)
								dmg:SetDamageType(DMG_RADIATION)
								ent:TakeDamageInfo(dmg)
							end
							ParticleEffect("scav_exp_rad", tr.HitPos, angle_zero, Entity(0))
							table.insert(tracep.filter, ent)
							if not IsValid(tr.Entity) or (tr.Entity:GetClass() == "npc_strider") then
								break
							end
						else
							break
						end
						startpos = tr.HitPos
					end
				else
					for i = 1, pierce do
						tr = util.TraceHull(tracep)
						local ent = tr.Entity
						if IsValid(ent) and not ent:IsWorld() then
							ParticleEffect("scav_exp_rad", tr.HitPos, angle_zero, Entity(0))
							table.insert(tracep.filter, ent)
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
				util.Effect("ef_scav_radbeam", efdata)
				self:MuzzleFlash2(4)
				self.nextfireearly = CurTime() + 0.1
				--self.Owner:ScavViewPunch(Angle(math.Rand(-3, -4), math.Rand(-2, 2), 0), 0.25)
				if SERVER then
					self:AddBarrelSpin(1000)
					self.Owner:EmitSound("npc/scanner/scanner_electric2.wav")
					return self:TakeSubammo(item, 1)
				end
			end
			if SERVER then
				ScavData.CollectFuncs["models/props_silo/silo_workspace1.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/scav/rad_hl2.mdl"), 10, ent:GetSkin(), 3}} end -- 3 cases from workstation
				--TF2
				ScavData.CollectFuncs["models/props_badlands/barrel_flatbed01.mdl"] = function(self, ent) return {{"models/props_badlands/barrel03.mdl", 10, ent:GetSkin(), 3}} end
				--BMS
				ScavData.CollectFuncs["models/props_blackmesa/barrel01.mdl"] = function(self, ent)
					--only one skin is radioactive, the rest are regular barrels. Luckily, there's a mesh-identical duplicate of this prop
					--so we only register one of them, and give the other one on wrong skins
					if ent:GetSkin() == 4 then
						return {{"models/props_blackmesa/barrel01.mdl", 10, 4}}
					else
						return {{"models/props_blackmesa/barrel_buoyant.mdl", 1, ent:GetSkin()}}
					end
				end
				ScavData.CollectFuncs["models/props_blackmesa/barrel_buoyant.mdl"] = ScavData.CollectFuncs["models/props_blackmesa/barrel01.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/scav/rad_hl2.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_lab/crystalbulk.mdl", 10)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/de_nuke/nuclearcontainerboxclosed.mdl", 10)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_badlands/barrel03.mdl", 10)
		--HL:S
		ScavData.RegisterFiremode(tab, "models/w_gaussammo.mdl", 10)
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_industrial/radioactive_waste_processor.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/weapons/w_gauss.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/w_gauss_mp.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/w_gaussammo.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/w_gaussammo_mp.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/w_egon.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/w_egon_pickup.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/weapons/w_egon_pickup_mp.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/barrel01.mdl")

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
			tracep.mins = Vector(-2, -2, -2)
			tracep.maxs = Vector(2, 2, 2)
			tab.ChargeAttack = function(self, item)
				local shootpos = self.Owner:GetShootPos()
				tracep.start = shootpos
				tracep.filter = self.Owner
				for i=1, 2 do
					tracep.endpos = shootpos + (self:GetAimVector() + VectorRand(-0.075, 0.075)):GetNormalized() * 400
					local tr = util.TraceHull(tracep)
					if tr.Hit then
						ParticleEffect("scav_exp_phazon_1", tr.HitPos, angle_zero, Entity(0))
					end
					if IsValid(tr.Entity) then
						dmg:SetAttacker(self.Owner)
						dmg:SetInflictor(self)
						dmg:SetDamagePosition(tr.HitPos)
						if string.find(tr.Entity:GetClass(), "npc_antlion") then
							dmg:SetDamageType(bit.bor(DMG_BUCKSHOT, DMG_ALWAYSGIB)) --TODO: figure out what god damn combination of damage types make all the different types of antlions die how they're supposed to
						else
							dmg:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_RADIATION, DMG_BLAST, DMG_GENERIC, DMG_ALWAYSGIB, DMG_DISSOLVE))
						end
						dmg:SetDamage(4)
						dmg:SetDamageForce(tr.Normal * 24000)
						if tr.Entity:IsNPC() and SERVER then
							--tr.Entity:SetSchedule(SCHED_BIG_FLINCH)
							tr.Entity:SetSchedule(SCHED_FLINCH_PHYSICS)
						end
						if tr.Entity:GetClass() == "prop_ragdoll" then
							for i=0, tr.Entity:GetPhysicsObjectCount() - 1 do
								local phys = tr.Entity:GetPhysicsObjectNum(i)
								if phys then
									phys:SetVelocity(VectorRand() * math.random(3, 90))
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
					util.Effect("ef_scav_phazon", edata)
					util.Effect("ef_scav_phazon", edata)
					if SERVER then
						self.Owner:EmitSound("weapons/physcannon/energy_sing_flyby" .. math.random(1, 2) .. ".wav", 100, 255)
						self:TakeSubammo(item, 1)
					else
						local vmdl = self.Owner:GetViewModel()
						if IsValid(vmdl) then
							ParticleEffectAttach("scav_vm_phazon", PATTACH_POINT_FOLLOW, vmdl, vmdl:LookupAttachment("muzzle"))
						end
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					self:ProcessLinking(item)
					self:StopChargeOnRelease()
					return 0.025		
				end
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				self.Owner:EmitSound("ambient/fire/gascan_ignite1.wav", 100, 90)
				return false
			end
			tab.Cooldown = 0.025 --40/sec

			ScavData.RegisterFiremode(tab, "models/dav0r/hoverball.mdl", SCAV_SHORT_MAX)

--[[==============================================================================================
	--Minigun
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.minigun"
			tab.anim = ACT_VM_FIDGET
			tab.chargeanim = ACT_VM_RECOIL1
			tab.Level = 5
			local identify = {
				--[[Default]]["models/w_models/weapons/50cal.mdl"] = 0,
				["models/w_models/weapons/w_minigun.mdl"] = 0,
				["models/weapons/gatling_top.mdl"] = 0,
				--[TF2] = 1,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 1 end})
			tab.MaxAmmo = 200
			tab.BarrelRestSpeed = 1000
			tab.ChargeAttack = function(self, item)
				if self.Owner:KeyDown(IN_ATTACK) then
					local tab = ScavData.models[item.ammo]
					local bullet = {}
						bullet.Num = 2
						bullet.Src = self.Owner:GetShootPos()
						bullet.Dir = self:GetAimVector()
						bullet.Spread = Vector(0.05, 0.05, 0)
						bullet.Tracer = 3
						bullet.Force = 5
						bullet.Damage = 6
						bullet.TracerName = "ef_scav_tr_b"
						bullet.Callback = ScavData.models[self.chargeitem.ammo].Callback
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					if CLIENT and game.SinglePlayer() then
						if not self.Owner:Crouching() or not (IsValid(self.Owner:GetGroundEntity()) or self.Owner:GetGroundEntity():IsWorld()) then
							self.Owner:SetEyeAngles((VectorRand(-0.1, 0.1) + self:GetAimVector()):Angle()) --BUG TODO: Very choppy
						else
							self.Owner:SetEyeAngles((VectorRand(-0.02, 0.02) + self:GetAimVector()):Angle())
						end
					end
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					timer.Simple(0.025, function()
						if not IsValid(self) then return end
						local brass = {
							[0] = function(attach)
								self:EjectShell("RifleShellEject", false)
							end,
							[1] = function(attach)
								self:EjectShellTF2("minigun")
							end,
						}
						brass[tab.Identify[item.ammo]](attach)
					end)
					if SERVER then 
						self:TakeSubammo(item, 1)
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
			tab.FireFunc = function(self, item)
				self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
				if SERVER then
					self.Owner:EmitSound("weapons/minigun_wind_up.wav")
					self.soundloops.minigunspin = CreateSound(self.Owner, "weapons/minigun_spin.wav")
					self.soundloops.minigunfire = CreateSound(self.Owner, "weapons/minigun_shoot.wav")
					self:SetBarrelRestSpeed(900)
				end
				return false
			end
			tab.Cooldown = 1
			
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_minigun.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_canton/c_canton.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_canton/c_canton.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_tomislav/c_tomislav.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_tomislav/c_tomislav.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_minigun/c_minigun.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_minigun/c_minigun_natascha.mdl", 200)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/50cal.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/50_cal_broken.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_minigun.mdl", 200)
		--ASW
		ScavData.RegisterFiremode(tab, "models/weapons/autogun/autogun.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/weapons/minigun/minigun.mdl", 200)
		ScavData.RegisterFiremode(tab, "models/swarm/autogun/autogun.mdl", 200)
		--FoF
		ScavData.RegisterFiremode(tab, "models/weapons/gatling_top.mdl", 200)

--splitting up into smaller files				
include("firemodes_hl2.lua")
include("firemodes_css.lua")
include("firemodes_dods.lua")
include("firemodes_fof.lua")
include("firemodes_utility.lua")
include("firemodes_piles.lua")
