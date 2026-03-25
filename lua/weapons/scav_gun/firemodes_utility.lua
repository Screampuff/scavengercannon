-- Non-weapon firemodes

--[[==============================================================================================
	--Auto-Targeting System
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.computer"
			tab.anim = ACT_VM_IDLE
			tab.Level = 5
			tab.On = true
			tab.FireFunc = function(self, item)
				tab.On = not tab.On
				if SERVER then
					self.Owner:EmitSound(tab.On and "buttons/button5.wav" or "buttons/button8.wav")
				end
				return false
			end
			if CLIENT then
				tab.Screen = puterscreen
				--Force screen to update seeking status on rockets
				local updaterockets = function(self, item)
					timer.Simple(0, function()
						if not IsValid(self) then return end
						for _, v in pairs(self.inv.items) do
							if ScavData.models[v.ammo] and ScavData.models[v.ammo].Name == "#scav.scavcan.rocket" then
								ScavData.models[v.ammo].OnArmed(self, ScavData.models[v.ammo], item)
							end
						end
					end)
				end
				tab.PostRemove = updaterockets
				tab.OnPickup = updaterockets
			end
			tab.Cooldown = .25
		ScavData.RegisterFiremode(tab, "models/props_lab/harddrive01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/harddrive02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/reciever01a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/reciever01b.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/reciever01c.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/reciever01d.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/reciever_cart.mdl", SCAV_SHORT_MAX)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_case.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_caseb.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_caseb_p2.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_caseb_p2a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_caseb_p3.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_caseb_p3a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_caseb_p4.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_caseb_p5.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_caseb_p6.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_spytech/control_room_console02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_spytech/control_room_console04.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_spytech/computer_wall.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_spytech/computer_wall02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_spytech/computer_wall03.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_spytech/computer_wall04.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_spytech/computer_wall05.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_spytech/computer_wall06.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_powerhouse/powerhouse_console01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_powerhouse/powerhouse_console02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_moonbase/moon_interior_computer01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_moonbase/moon_interior_computer02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_moonbase/moon_interior_computer03.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_moonbase/moon_interior_computer04.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_moonbase/moon_interior_computer05.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_moonbase/moon_interior_computer06.mdl", SCAV_SHORT_MAX)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_placeable/radio_box.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/terror/hamradio.mdl", SCAV_SHORT_MAX)
		--Portal
		ScavData.RegisterFiremode(tab, "models/props/pc_case02/pc_case02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/pc_case_open/pc_case_open.mdl", SCAV_SHORT_MAX)
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_misc/german_radio.mdl", SCAV_SHORT_MAX)
		--Portal 2
		ScavData.RegisterFiremode(tab, "models/props_office/computer_1980.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_1980_flatscreen.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/techdeco/computers/portablehddr01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/techdeco/computers/portablehddr02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_01_1970.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_02_1970.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_03_1970.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_04_1970.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_base01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_cabinet01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_cabinet02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_tall01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/pc_1970.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_underground/computer_1980.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_underground/interactive_console.mdl", SCAV_SHORT_MAX)
		--ASW
		ScavData.RegisterFiremode(tab, "models/env/ryberg/outside/detonator/detonator.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/swarmprops/techdeco/swarm_consolemesh.mdl", SCAV_SHORT_MAX)
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_office/closed_laptop.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/open_laptop.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/supercomputer01a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/supercomputer01a_break08.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/supercomputer01a_break09.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/supercomputer01b.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/supercomputer01b_break09.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/supercomputer01c.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/supercomputer01c_break01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_am/gadget01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_am/gadget02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_am/gadget03.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/wallcomputer.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_desktop01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_desktop02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_desktop03.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_marines/prc77_radio.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_industrial/control_console_001.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_industrial/desk_console2.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_industrial/desk_console2_wgh.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_industrial/desk_console3.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_industrial/wall_console1.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_industrial/wall_console2.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_industrial/wall_console_sm.mdl", SCAV_SHORT_MAX)
		
--[[==============================================================================================
	--Energy Drink/Stim Pack
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.stim"
			tab.anim = ACT_VM_RECOIL1
			tab.Level = 6
			tab.MaxAmmo = 6
			local identify = {
				--[Coffee] = 0,
				--[[Drink]]["models/props_junk/garbage_energydrinkcan001a.mdl"] = 1,
				["models/mechanics/various/211.mdl"] = 1,
				["models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"] = 1,
				["models/weapons/c_models/c_xms_energy_drink/c_xms_energy_drink.mdl"] = 1,
				["models/swarmprops/miscdeco/synupcan.mdl"] = 1,
				--[[Needle]]["models/props_junk/garbage_syringeneedle001a.mdl"] = 2,
				["models/w_models/weapons/w_eq_adrenaline.mdl"] = 2,
				["models/swarm/stim/stim.mdl"] = 2,
				["models/humans/props/scientist_syringe.mdl"] = 2,
				--[[Disciplinary Action]]["models/weapons/c_models/c_riding_crop/c_riding_crop.mdl"] = 3,
				["models/workshop/weapons/c_models/c_riding_crop/c_riding_crop.mdl"] = 3,
				--[[MannUp Agility]]["models/pickups/pickup_powerup_agility.mdl"] = 4,
				--[[MannUp Haste]]["models/pickups/pickup_powerup_haste.mdl"] = 5,
				--[[Boot]]["models/items/powerup_speed.mdl"] = 6,
				["models/props_junk/shoe001a.mdl"] = 6,
				["models/props_questionableethics/smoking_boots_left.mdl"] = 6,
				["models/props_questionableethics/smoking_boots_right.mdl"] = 6,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
					local tab = ScavData.models[item.ammo]
					local statfunction = {
						[0] = function(self)
							self.Owner:InflictStatusEffect("Shock", 30, 40)
							self.Owner:InflictStatusEffect("Speed", 20, 3)
							self.Owner:EmitSound("npc/scanner/scanner_nearmiss1.wav")
						end,
						[1] = function(self)
							self.Owner:InflictStatusEffect("Shock", 30, 40)
							self.Owner:InflictStatusEffect("Speed", 20, 3)
							if TF2 then
								self.Owner:EmitSound("player/pl_scout_dodge_can_open.wav")
								self.Owner:EmitSound("player/pl_scout_dodge_can_drink_fast.wav")
							else
								self.Owner:EmitSound("hl1/fvox/hiss.wav", 75, 150)
								self.Owner:EmitSound("ambient/levels/canals/toxic_slime_gurgle4.wav")
							end
						end,
						[2] = function(self)
							if self.Owner:GetStatusEffect("TemporaryHealth") then
								self.Owner:EmitSound("buttons/button11.wav")
								tab.Cooldown = 0.2
								return false
							else
								self.Owner:InflictStatusEffect("Shock", 30, 40)
								self.Owner:InflictStatusEffect("Speed", 20, 3)
								if L4D2 then
									self.Owner:EmitSound("weapons/adrenaline/adrenaline_cap_off.wav")
								else
									self.Owner:EmitSound("hl1/fvox/hiss.wav", 75, 180)
								end
								self.Owner:InflictStatusEffect("TemporaryHealth", 25, 1)
							end
						end,
						[3] = function(self)
							self.Owner:InflictStatusEffect("Shock", 2, 40)
							self.Owner:InflictStatusEffect("Speed", 5, 3)
							self.Owner:EmitSound("weapons/discipline_device_impact_01.wav")
							self.Owner:EmitSound("weapons/discipline_device_power_up.wav")
						end,
						[4] = function(self)
							self.Owner:InflictStatusEffect("Shock", 30, 40)
							self.Owner:InflictStatusEffect("Speed", 20, 3)
							self.Owner:EmitSound("items/powerup_pickup_agility.wav")
						end,
						[5] = function(self)
							self.Owner:InflictStatusEffect("Shock", 30, 40)
							self.Owner:InflictStatusEffect("Speed", 20, 3)
							self.Owner:EmitSound("items/powerup_pickup_haste.wav")
						end,
						[6] = function(self)
							self.Owner:InflictStatusEffect("Speed", 20, 3)
							self.Owner:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav")
						end
					}
					statfunction[tab.Identify[item.ammo]](self)
					return self:TakeSubammo(item, 1)
				end
				--CSS
				ScavData.CollectFuncs["models/props/cs_office/trash_can.mdl"] = function(self, ent)
					return {{"models/props/cs_office/trash_can_p7.mdl", 1, ent:GetSkin(), 1},
							{"models/props/cs_office/trash_can_p8.mdl", 1, ent:GetSkin(), 1},
							{"models/props/cs_office/trash_can_p.mdl", SCAV_SHORT_MAX, ent:GetSkin(), 1}}
				end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"] = function(self, ent) return {{(self.christmas and ent:GetSkin() < 2) and "models/weapons/c_models/c_xms_energy_drink/c_xms_energy_drink.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, ent:GetSkin()}} end
			end
			tab.Cooldown = 0.5
		ScavData.RegisterFiremode(tab, "models/items/powerup_speed.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_syringeneedle001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_energydrinkcan001a.mdl")
		ScavData.RegisterFiremode(tab, "models/mechanics/various/211.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_coffeemug001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_plasticbottle003a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/shoe001a.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_energy_drink/c_energy_drink.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_xms_energy_drink/c_xms_energy_drink.mdl")
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_eq_adrenaline.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_riding_crop/c_riding_crop.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_riding_crop/c_riding_crop.mdl")
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_agility.mdl")
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_haste.mdl")
		ScavData.RegisterFiremode(tab, "models/props_2fort/coffeemachine.mdl")
		ScavData.RegisterFiremode(tab, "models/props_2fort/coffeepot.mdl")
		ScavData.RegisterFiremode(tab, "models/props_2fort/thermos.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_office/trash_can_p7.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/trash_can_p8.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/coffee_mug.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/coffee_mug2.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/coffee_mug3.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_interiors/coffee_maker.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/coffeemachine01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_coffeecup01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_coffeecup01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_coffeemug001a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/coffeepot01.mdl")
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_cola.mdl")
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/garbage_drinks_container.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_sodacup01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_sodacup01a_fullsheet.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_misc/coffee_container-1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_misc/coffee_container-2.mdl")
		--Portal/2
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_coffeemug001a_forevergibs.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_04.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_05.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_06.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_07.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_08.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_09.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_10.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_11.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_12.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/coffee_mug_17.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/swarm/stim/stim.mdl")
		ScavData.RegisterFiremode(tab, "models/swarmprops/miscdeco/synupcan.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/humans/props/scientist_syringe.mdl")
		ScavData.RegisterFiremode(tab, "models/props_questionableethics/smoking_boots_left.mdl")
		ScavData.RegisterFiremode(tab, "models/props_questionableethics/smoking_boots_right.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/coffeemug01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/coffeemug01b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canteen/vacuumflask01b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canteen/vacuumflask01b_cup.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canteen/vacuumflask01b_phyicsversion.mdl")
		
--[[==============================================================================================
	--Cloaking Watch
==============================================================================================]]--
		
		local function cloakcheck(self)
			if self.Cloak and (self.Cloak.subammo > 0) then
				self.Cloak:SetSubammo(math.max(self.Cloak:GetSubammo() - 1, 0))
				timer.Simple(1, function() cloakcheck(self) end)
			else
				if SERVER and self.Cloak then
					self.Owner:InflictStatusEffect("Cloak", -self.Cloak.subammo, 1)
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
			local identify = {} --all cloaks are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
					if self.Cloak and (self.Cloak ~= item) then
						local leftover = item.subammo - self.Cloak.subammo
						self.Cloak = item
						self.Owner:InflictStatusEffect("Cloak", leftover, 1)
					elseif not self.Cloak then
						self.Owner:InflictStatusEffect("Cloak", item.subammo, 1)
						self.Cloak = item
						timer.Simple(1, function() cloakcheck(self) end)
					else
						self.Owner:InflictStatusEffect("Cloak", -self.Cloak.subammo, 1)
						self.Cloak = false
					end
				end
					
				function tab.PostRemove(self, item)
					if item == self.Cloak then
						self.Owner:InflictStatusEffect("Cloak", -self.Cloak.subammo, 1)
						self.Cloak = false
					end
				end
				--HL:S
				ScavData.CollectFuncs["models/hassassin.mdl"] = function(self, ent) --30 seconds of cloak + 2 silenced pistols from a HL1 Assassin
					return {{ScavData.FormatModelname(ent:GetModel()), 30, 0},
							{"models/w_silencer.mdl", 34, 0}}
				end
			else
				tab.FireFunc = function(self, item)
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
		ScavData.RegisterFiremode(tab, "models/maxofs2d/hover_basic.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/metal_paintcan001a.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/metal_paintcan001b.mdl", 30)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/paintbucket01.mdl", 30)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_spy_watch.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_farm/paint_can001.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_farm/paint_can002.mdl", 30)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_spraypaintcan01a.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_spraypaintcan01a_fullsheet.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/metal_paintcan001b_static.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_debris/paintbucket01.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_debris/paintbucket01_static.mdl", 30)
		--HL:S
		ScavData.RegisterFiremode(tab, "models/hassassin.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_junk/metalcontainer01.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/metalcontainer02.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/metalcontainer03.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/metalcontainer04.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/spraycan.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/humans/hassassin.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/player/hassassin.mdl", 30)
		
	

--[[==============================================================================================
	--Key
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.key"
			tab.anim = ACT_VM_IDLE
			tab.Level = 7
			tab.MaxAmmo = 6
			local identify = {} --all keys are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
					--local tr = self.Owner:GetEyeTraceNoCursor()
					local tracep = {}
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 48
						tracep.filter = self.Owner
						tracep.mask = MASK_SOLID --MASK_SOLID_BRUSHONLY
						local tr = util.TraceHull(tracep)
						--print(tr.Entity)
					if ((tr.HitPos - tr.StartPos):Length() > 48) or not IsValid(tr.Entity) or not (string.find(tr.Entity:GetClass(), "_door", 0, true)) then
						self.Owner:EmitSound("buttons/button11.wav")
						return false
					end
					if tr.Entity:GetInternalVariable("m_bLocked") or --door is locked
						(bit.band(tr.Entity:GetEFlags(), 256) == 0 and bit.band(tr.Entity:GetEFlags(), 1024) == 0 and string.find(tr.Entity:GetClass(), "func_door", 0)) or --neither Use nor Touch Opens (func_door/_rotating)
						(bit.band(tr.Entity:GetEFlags(), 32768) ~= 0 and tr.Entity:GetClass() == "prop_door_rotating") then --Use doesn't open (prop_door_rotating)
						tr.Entity:Fire("Unlock", 1, 0)
						if tr.Entity:GetClass() == "prop_door_rotating" and tr.Entity:GetInternalVariable("m_eDoorState") == 0 then --don't smack ourself in the face with the door if we can help it
							tr.Entity:Fire("OpenAwayFrom", "!activator", 0.01, self.Owner)
						else
							tr.Entity:Fire("Toggle", 1, 0.01)
						end
						return self:TakeSubammo(item, 1)
					else
						if tr.Entity:GetClass() == "prop_door_rotating" and tr.Entity:GetInternalVariable("m_eDoorState") == 0 then
							tr.Entity:Fire("OpenAwayFrom", "!activator", 0, self.Owner)
						else
							tr.Entity:Fire("Toggle", 1, 0)
						end
						return false
					end
				end
				-- ScavData.CollectFuncs["models/lostcoast/fisherman/fisherman.mdl"] = function(self, ent) --effect
				-- 	return {{ScavData.FormatModelname("models/lostcoast/fisherman/keys.mdl"), 1, 0},
				-- 			{ScavData.FormatModelname("models/lostcoast/fisherman/harpoon.mdl"), 1, 0)}}
				-- end
			end
			tab.Cooldown = 2
		ScavData.RegisterFiremode(tab, "models/props_lab/keypad.mdl")
		--Lost Coast
		ScavData.RegisterFiremode(tab, "models/lostcoast/fisherman/keys.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_downtown/keycard_reader.mdl")
		--Wiremod
		ScavData.RegisterFiremode(tab, "models/bull/buttons/key_switch.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/alarmbox.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/wallconsole.mdl")

--[[==============================================================================================
	--Remote
==============================================================================================]]--
		
if SERVER then
	util.AddNetworkString("scav_hackdone")

--Give player credit for any kills their hacking gets
	local hackkill = function(victim, attacker, inflictor)
		if IsValid(attacker.ScavHacker) then
			hook.Run("SendDeathNotice", attacker.ScavHacker, attacker, victim, 0)
			return false
		end
		--suicide
		if IsValid(victim.ScavHacker) and attacker:IsWorld() then
			--Some NPCs will be invalid by the time the death notice is called, grab the victim's name now
			local victimname = ""
			if not victim:IsPlayer() then
				local menuname = list.GetEntry("NPC", victim.NPCName)
				if not menuname or not menuname.Name then
					victimname = victim:GetClass()
				else
					victimname = menuname.Name
				end
			else
				victimname = victim:Nick()
			end
			hook.Run("SendDeathNotice", victim.ScavHacker, victim.ScavHacker:GetWeapon("scav_gun"), victimname, 0)
			return false
		end
	end
	hook.Add("OnNPCKilled", "ScavHackKill", hackkill)
	hook.Add("PlayerDeath", "ScavHackKill", hackkill)
end

--Multiplier for total time required to hack for Wheatley-based Universal Remotes
local wheatleytime = 2
--Cooldown time after a successful or failed hacking attempt
local hackcooldown = 1
--Hacking Think interval (cooldown while the gun is working on the hack)
local hackthinktime = 0.05
--How far we can reach when trying to hack something
local hackrange = 1000

local bars = Material("hud/scav_caution_tape.vmt")
local scavicon = Material("hud/hack/scav.vmt")
local signal = Material("hud/hack/signal.vmt")
local scavfirewall = Material("hud/hack/shield.vmt")

--Find Signal Strength (convert distance to frames on signal strength indicator texture)
local signalstrength = function(scavgun, target)
	if not IsValid(scavgun) or not IsValid(target) then return 4 end
	--[[Note: This range isn't 100% accurate. The gun uses the hitpos of its trace,
		so we should be up to the target's hullsize closer than we think we are here.
		That's a *probably* minor difference though, not worth the extra cost of drawing
		a trace on top of a distance check (every frame, mind you)
		But, it's why we don't let our check here naturally get to the "no connection" image (frame 4),
		as that's not our call to make]]
	local dist = scavgun.Owner:GetShootPos():Distance(target:GetPos()) / hackrange
	local frame = 0
	--having equidistant chunks feels bad, this makes it about 45% range for max bars, 70% for three, 83% for two, and 89% for one
	--(also makes this check being off less likely to be noticed, especially for larger entities)
	for i = 1, 3 do
		if dist + 0.05 < 1 - 2 ^ -i then break end
		frame = frame + 1
	end
	return frame
end

--Hacking attempt failed extremely loud incorrect buzzer
local hackfail = {
	[SCAV_HACK_KB] = {"hl1/fvox/fuzz.wav"},
}
if TF2 then
--Portal 2 lines are kinda weak picks compared to the TF2 ones specifically made for "hacking"
--(plus TF2's free to play, people are probably gonna have it mounted over Portal 2)
	hackfail[SCAV_HACK_WHEATLEY] = {
		"vo/items/wheatley_sapper/wheatley_sapper_putback01.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback02.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback08.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback12.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback17.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback26.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback27.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback44.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback47.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback48.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_putback49.mp3"
	}
elseif PORTAL2 then
	hackfail[SCAV_HACK_WHEATLEY] = {
		"vo/wheatley/bw_a4_2nd_first_test_solve05.wav",
		"vo/wheatley/bw_a4_finale01_killyou01.wav",
		"vo/wheatley/bw_a4_finale01_smash02.wav",
		"vo/wheatley/bw_a4_finale02_beamtrap_earlyexita01.wav",
		"vo/wheatley/bw_a4_finale02_beamtrap_escape01.wav",
		"vo/wheatley/bw_a4_paradox02.wav",
		"vo/wheatley/bw_finale04_through_portal01.wav",
		"vo/wheatley/bw_sp_a2_core_pitpunch03.wav",
		"vo/wheatley/bw_sp_a4_jump_polarity_intro01.wav",
		"vo/wheatley/bw_sp_a4_tb_wall_button_intro01.wav",
		"vo/wheatley/bw_sp_a4_tb_wall_button_not_solve01.wav",
		"vo/wheatley/bw_sp_a4_tb_wall_button_not_solve05.wav",
		"vo/wheatley/bw_sp_a4_tb_wall_button_solve06.wav",
		"vo/wheatley/bw_sp_a4_tb_wall_button_solve08.wav",
		"vo/wheatley/bw_sp_a4_tb_wall_button_solve09.wav",
		"vo/wheatley/demospherebreakerlift02.wav",
		"vo/wheatley/demospherebreakerlift19.wav",
		"vo/wheatley/demospherethud03.wav",
		"vo/wheatley/demospherethud04.wav",
		"vo/wheatley/fgb_plugin_nags05.wav",
		"vo/wheatley/fgb_plugin_nags06.wav",
		"vo/wheatley/fgb_plugin_nags07.wav",
		"vo/wheatley/fgb_plugin_nags08.wav",
		"vo/wheatley/fgb_plugin_nags09.wav",
		"vo/wheatley/fgb_plugin_nags11.wav",
	}
end
local hackfaildefault = {"buttons/combine_button_locked.wav"}
setmetatable(hackfail, {__index = function() return hackfaildefault end})

--Hacking attempt successful jingle
local hacksuccess = {
	[SCAV_HACK_KB] = {"ambient/machines/keyboard7_clicks_enter.wav"},
}
if TF2 then
	hacksuccess[SCAV_HACK_WHEATLEY] = {
		--thanks valve
		"vo/items/wheatley_sapper/wheatley_sapper_hacked01.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked02.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked03.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked04.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked05.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked06.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked07.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked08.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked09.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked10.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked11.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked13.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked14.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked15.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked16.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked17.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked18.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked19.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked20.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked21.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked22.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked23.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked24.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked25.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked26.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked27.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked28.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked29.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked32.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked33.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked34.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked35.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked37.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked38.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked40.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked41.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked42.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked43.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked44.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked47.mp3",
		"vo/items/wheatley_sapper/wheatley_sapper_hacked48.mp3"
	}
elseif PORTAL2 then
	hacksuccess[SCAV_HACK_WHEATLEY] = {
		"vo/wheatley/bw_a4_2nd_first_test_solve03.wav",
		"vo/wheatley/bw_a4_big_idea01.wav",
		"vo/wheatley/bw_a4_finale02_trapintro02.wav",
		"vo/wheatley/bw_a4_finale03_playerdies01.wav",
		"vo/wheatley/bw_a4_finale03_speech02.wav",
		"vo/wheatley/bw_a4_paradox05.wav",
		"vo/wheatley/bw_a4_paradox09.wav",
		"vo/wheatley/bw_a4_paradox11.wav",
		"vo/wheatley/bw_a4_test_solve_reacs_happy05.wav",
		"vo/wheatley/bw_fgb_heel_turn10.wav",
		"vo/wheatley/bw_finale4_hackworked01.wav",
		"vo/wheatley/bw_fire_lift02.wav",
		"vo/wheatley/bw_fire_lift03.wav",
		"vo/wheatley/bw_sp_a2_core_actually06.wav",
		"vo/wheatley/bw_sp_a2_core_heelturn06.wav",
		"vo/wheatley/bw_sp_a2_core_potato01.wav",
		"vo/wheatley/bw_sp_a2_core_potato04.wav",
		"vo/wheatley/bw_sp_a4_jump_polarity_intro04.wav",
		"vo/wheatley/bw_sp_a4_speed_tb_catch_intro04.wav",
		"vo/wheatley/bw_sp_a4_tb_wall_button_intro07.wav",
	}
end
local hacksuccessdefault = {"buttons/combine_button1.wav"}
setmetatable(hacksuccess, {__index = function() return hacksuccessdefault end})

	do
		local tab = {}
			tab.Name = "#scav.scavcan.remote"
			tab.anim = ACT_VM_IDLE
			tab.Level = 7
			tab.Cooldown = hackthinktime
			local identify = {
				--[Remote] = 0,
				--[[keyboard]]["models/props_c17/computer01_keyboard.mdl"] = 1,
				["models/props/cs_office/computer_keyboard.mdl"] = 1,
				["models/props/kb_mouse/keyboard.mdl"] = 1,
				["models/props_office/computer_keyboard01.mdl"] = 1,
				["models/props_office/computer_keyboard02.mdl"] = 1,
				--[[wheatley]]["models/weapons/c_models/c_p2rec/c_p2rec.mdl"] = 2,
				["models/npcs/personality_sphere/personality_sphere.mdl"] = 2,
				["models/npcs/personality_sphere/personality_sphere_skins.mdl"] = 2,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			local tracep = {}
			tracep.mins = Vector(-2, -2, -2)
			tracep.maxs = Vector(2, 2, 2)
			local interactions = {}
			local interactdefault = {
				["HackTime"] = 5,
				["Action"] = function(self, ent)
					ent:Fire("Use", nil, 0)
				end,
				["Icon"] = Material("hud/hack/unknown.vmt")
			}
			setmetatable(interactions, {
				__index = function() return interactdefault end,
				__newindex = function(t, k, v)
					if type(v) == "table" then
						table.Inherit(v, interactdefault)
					end
					rawset(t, k, v)
				end
			})

			interactions.gmod_hoverball = {
				["HackTime"] = 2,
				["Action"] = function(self, ent)
					if not ent.oldstrength then
						ent.oldstrength = ent.Strength
						ent:SetStrength(0)
					else
						ent:SetStrength(ent.oldstrength)
						ent.oldstrength = nil
					end
				end,
				["Icon"] = Material("hud/hack/hoverball.vmt")
				}
			interactions.scav_c4 = {
				["HackTime"] = 5,
				["Action"] = function(self, ent)
					ent:Disarm()
				end,
				["Icon"] = Material("hud/hack/c4.vmt")
				}
			interactions.scav_tripmine = {
				["HackTime"] = 5,
				["Action"] = function(self, ent)
					ent.Owner = self.Owner
					ent:SetArmed(not ent:IsArmed())
				end,
				["Icon"] = Material("hud/hack/tripmine.vmt")
				}
			interactions.gmod_thruster = {
				["HackTime"] = 6,
				["Action"] = function(self, ent)
					ent:Switch(not ent:IsOn())
				end,
				["Icon"] = Material("hud/hack/thruster.vmt")
				}
			interactions.gmod_turret = {
				["HackTime"] = 6,
				["Action"] = function(self, ent)
					ent:SetOn(not ent:GetOn())
				end,
				["Icon"] = Material("hud/hack/turret.vmt")
				}
			interactions.gmod_emitter = {
				["HackTime"] = 2,
				["Action"] = interactions.gmod_turret.Action,
				["Icon"] = Material("hud/hack/emitter.vmt")
				}
			interactions.gmod_light = {
				["HackTime"] = 2,
				["Action"] = interactions.gmod_turret.Action,
				["Icon"] = Material("hud/hack/light.vmt")
				}
			interactions.gmod_dynamite = {
				["HackTime"] = 7,
				["Action"] = function(self, ent)
					ent:Explode(0, self.Owner)
				end,
				["Icon"] = Material("hud/hack/dynamite.vmt")
				}
			interactions.gmod_wheel = {
				["HackTime"] = 3,
				["Action"] = function(self, ent)
					local Motor = ent:GetMotor()
					if IsValid(Motor) then
						Motor.direction = -Motor.direction
						Motor:Fire("Scale", Motor.direction * Motor.forcescale * ent.TorqueScale)
						ent:SetDirection(Motor.direction)
						ent:DoDirectionEffect()
					end
				end,
				["Icon"] = Material("hud/hack/wheel.vmt")
				}
			interactions.npc_rollermine = {
				["HackTime"] = 2,
				["Action"] = function(self, ent)
					local hacked = not ent:GetInternalVariable("m_bHackedByAlyx")
					ent:SetSquad()
					ent:SetSaveValue("m_bHackedByAlyx", hacked)
					ent:Fire("Skin", hacked and 1 or 0, 0) --for whatever reason GMod doesn't have a rollermine model with skins in it (and the hack status doesn't automatically apply it) but in case the player has a fixed model, make it appear correctly
					ent:Fire("InteractivePowerDown", nil, 15, self.Owner, self)
					ent.ScavHacker = self.Owner
				end,
				["Icon"] = Material("hud/hack/roller.vmt")
				}
			interactions.npc_turret_floor = {
				["HackTime"] = 2,
				["Action"] = function(self, ent)
					ent.ScavHacker = self.Owner
					ent:Fire("SelfDestruct", nil, 0)
				end,
				["Icon"] = Material("hud/hack/turret.vmt")
				}
			interactions.npc_manhack = {
				["HackTime"] = 1,
				["Action"] = function(self, ent)
					ent.ScavHacker = self.Owner
					ent:Fire("InteractivePowerDown", nil, 0)
				end,
				["Icon"] = Material("hud/hack/manhack.vmt")
				}
			interactions.prop_vehicle_jeep = {
				["HackTime"] = 2,
				["Action"] = function(self, ent)
					ent:Fire(ent.HackedOff and "TurnOn" or "TurnOff", nil, 0)
					ent.HackedOff = not ent.HackedOff
				end,
				["Icon"] = Material("hud/hack/jeep.vmt")
				}
			interactions.prop_vehicle_jeep_old = interactions["prop_vehicle_jeep"]
			interactions.prop_vehicle_airboat = interactions["prop_vehicle_jeep"]
			interactions.npc_cscanner = {
				["HackTime"] = 1,
				--attempt to initiate a divebomb onto one of our enemies
				--(no current way to force divebomb behavior, just gotta attempt to find the conditions for it)
				["Action"] = function(self, ent)
					--clear us as potential divebomb target
					ent:ClearEnemyMemory(self.Owner)
					ent:AddEntityRelationship(self.Owner, D_LI, 1000)
					
					ent:SetSquad()
					local target = nil
					local targetdist = 17179869184 -- 131072HU (a bit far away!)
					local entpos = ent:GetPos()
					--find a victim, if we can
					for _, v in ents.Iterator() do
						if not IsValid(v) or not (v:IsNPC() or v:IsPlayer() or v:IsNextBot()) or v == self.Owner then continue end
						--Make sure target isn't friendly
						if v.Disposition and v:Disposition(self.Owner) ~= D_HT then continue end
						if v.Team and v:Team() == self.Owner:Team() and v:Team() ~= TEAM_UNASSIGNED then continue end
						--Scanner won't divebomb if it's less than 120 units above or 360 units away
						local vpos = v:GetPos()
						if entpos.z - vpos.z <= 120 then continue end
						local dist = vpos:DistToSqr(entpos)
						if dist <= 129600 then continue end
						--Get closest enemy (who's still far enough away)
						if dist > targetdist then continue end
						--Should probably have a chance to actually hit them
						local tracep = {}
							tracep.start = entpos
							tracep.endpos = vpos + v:OBBCenter()
							tracep.filter = {ent}
							tracep.mask = MASK_SOLID
						local tr = util.TraceHull(tracep)
						if tr.HitWorld then continue end
						if tr.Entity ~= v then continue end
						target = v
						targetdist = dist
					end
					if IsValid(target) then
						ent:AddEntityRelationship(target, D_HT, 1000)
						ent:SetEnemy(target, true)
					end
					ent.ScavHacker = self.Owner
					timer.Simple(0.5, function()
						if not IsValid(ent) or not IsValid(self) then return end
						ent:SetHealth(0)
					end)
				end,
				["Icon"] = Material("hud/hack/scanner.vmt")
				}
			interactions.prop_door_rotating = {
				["HackTime"] = 1.5,
				["Action"] = function(self, ent)
					if ent:GetInternalVariable("m_angGoal") == ent:GetInternalVariable("m_angRotationOpenForward")  then
						ent:Fire("Close", nil, 0, self.Owner)
					else
						ent:Fire("OpenAwayFrom", self.Owner, 0, self.Owner)
					end
				end,
				["Icon"] = Material("hud/hack/door.vmt")
			}
			interactions.func_door_rotating = {
				["HackTime"] = 1.5,
				["Icon"] = Material("hud/hack/door.vmt")
			}
			interactions.func_door = interactions.func_door_rotating
			interactions.func_button = {
				["HackTime"] = 1.5,
				["Icon"] = Material("hud/hack/button.vmt")
			}
			--fixes buttons on the client
			interactions["class c_basetoggle"] = interactions.func_button
			interactions.gmod_button = {
				["HackTime"] = 1,
				["Action"] = function(self, ent)
					ent.LastUser = nil
					ent:Use(self.Owner, self, USE_ON)
				end,
				["Icon"] = Material("hud/hack/button.vmt")
			}
			interactions.npc_turret_ceiling = {
				["HackTime"] = 2,
				["Action"] = function(self, ent)
					ent:Fire("toggle", nil, 0)
				end,
				["Icon"] = Material("hud/hack/turret.vmt")
			}
			interactions.npc_combine_camera = interactions.npc_turret_ceiling
			interactions.monster_miniturret = {
				["HackTime"] = 2,
				["Icon"] = Material("hud/hack/turret.vmt")
			}
			interactions.monster_turret = interactions.monster_miniturret
			interactions.monster_sentry = {
				["HackTime"] = 2,
				["Action"] = function(self, ent)
					ent.ScavHacker = self.Owner
					ent:Fire("SetHealth", 0, 0)
				end,
				["Icon"] = Material("hud/hack/turret.vmt")
			}
			interactions.virus = 2
			--status codes
			local STATUS_NONE = 0
			local STATUS_INVALID = 1
			local STATUS_CANCELED = 2
			local STATUS_OUTOFRANGE = 3
			local STATUS_SUCCESS = 4
			local STATUS_FIREWALL = 5
			local STATUS_SIZE = 3 --total bits to send status codes
			function tab.ChargeAttack(self, item)
				local ident = tab.Identify[item.ammo]
				self.HackingProgress = (self.HackingProgress or 0) + hackthinktime
				self.BarrelRotation = self.BarrelRotation + math.random(-17, 17)
				if SERVER then
					--end the hack, with an optional status code (tell client why we beefed it)
					local endhack = function(status, success)
						local success = success or false
						local target = self:GetNWFiremodeEnt()
						self:SetChargeAttack()
						self:SetNWFiremodeEnt(NULL)
						self.HackingProgress = 0
						if IsValid(self.ef_radio) then
							self.ef_radio:Kill()
						end
						--if IsValid(self.ef_wires) then
						--	self.ef_wires:Kill()
						--end
						--Successful hacks eliminate Punish Prop Virus
						if success and IsValid(target) and target.ScavVirus then
							status = STATUS_FIREWALL
							target.ScavVirus = nil
							net.Start("scav_hackdone")
								net.WriteEntity(target)
							net.Broadcast()
						end
						net.Start("scav_hackdone")
							net.WriteEntity(self)
							net.WriteBool(success)
							net.WriteUInt(status or STATUS_NONE, STATUS_SIZE)
						net.Send(self.Owner)
						return hackcooldown * self:GetCooldownScale()
					end
					--Invalid Target
					if not IsValid(self:GetNWFiremodeEnt()) then
						self:EmitSound(hackfail[ident][math.random(#hackfail[ident])]) --todo: unique fail sounds too?
						return endhack(STATUS_INVALID)
					end
					--User Canceled
					if not self.Owner:KeyDown(IN_ATTACK) then
						self:EmitSound(hackfail[ident][math.random(#hackfail[ident])])
						return endhack(STATUS_CANCELED)
					end
					--Out of Range
					if self.Owner:GetShootPos():DistToSqr(self:GetNWFiremodeEnt():GetPos()) > hackrange^2 then
						self:EmitSound(hackfail[ident][math.random(#hackfail[ident])])
						return endhack(STATUS_OUTOFRANGE)
					end
					--Hack Successful
					local wheatleyslow = ident == SCAV_HACK_WHEATLEY and wheatleytime or 1
					if self.HackingProgress > self.HackTime * wheatleyslow then
						self:EmitSound(hacksuccess[ident][math.random(#hacksuccess[ident])])
						interactions[string.lower(self:GetNWFiremodeEnt():GetClass())].Action(self, self:GetNWFiremodeEnt())
						return endhack(STATUS_SUCCESS, true)
					end
				else
					net.Receive("scav_hackdone", function()
						local wep = net.ReadEntity()
						if not IsValid(wep) then return end
						--Not a Scav Cannon, we got a de-virus'd prop instead
						if IsValid(wep.ScavVirusParticle) then
							wep.ScavVirusParticle:StopEmission()
							wep.ScavVirusParticle = nil
							return
						end
						--if the particle system wasn't found, but we were *supposed* to find it, get out of here
						if wep:GetClass() ~= "scav_gun" then return end

						wep.HackSuccess = net.ReadBool()
						wep:SetChargeAttack()
						wep.HackingProgress = 0
						wep:EmitSound(wep.HackSuccess and (hacksuccess[ident][math.random(#hacksuccess[ident])]) or hackfail[ident][math.random(#hackfail[ident])])
						wep.nextfire = CurTime() + hackcooldown * wep:GetCooldownScale()
						wep.HackStatus = net.ReadUInt(STATUS_SIZE)
						timer.Simple(hackcooldown * wep:GetCooldownScale(), function()
							if not IsValid(wep) then return end
							wep.HackStatus = nil
						end)
					end)
				end
				return hackthinktime * self:GetCooldownScale()
			end
			function tab.FireFunc(self, item)
				local ident = tab.Identify[item.ammo]
				tracep.start = self.Owner:GetShootPos()
				tracep.endpos = tracep.start + self.Owner:GetAimVector() * hackrange
				tracep.filter = self.Owner
				local tr = util.TraceHull(tracep)
				if SERVER then
					self:SetNWFiremodeEnt(tr.Entity)
				else
					self.HackStatus = STATUS_INVALID
				end
				local target = self:GetNWFiremodeEnt()
				if IsValid(target) then
					local wheatleyslow = ident == SCAV_HACK_WHEATLEY and wheatleytime or 1
					self.HackTime = interactions[string.lower(target:GetClass())].HackTime * wheatleyslow
					--speed us up if we found something with a virus
					if target.ScavVirus or target.ScavVirusParticle then
						self.HackTime = math.min(interactions.virus * wheatleyslow, self.HackTime)
					end
					self:SendWeaponAnim(ACT_VM_FIDGET)
					tab.Cooldown = hackthinktime * self:GetCooldownScale()
				else
					self:EmitSound(hackfail[ident][math.random(#hackfail[ident])])
					tab.Cooldown = hackcooldown * self:GetCooldownScale()
					self.HackSuccess = nil
					timer.Simple(hackcooldown * self:GetCooldownScale(), function()
						if not IsValid(self) then return end
						self.HackStatus = nil
					end)
					return false
				end
				if SERVER then
					self.ef_radio = self:CreateToggleEffect("scav_stream_radio", ident)
					--self.ef_wires = self:CreateToggleEffect("scav_stream_cord")
					--if IsValid(self.ef_wires) and IsValid(tr.Entity) then
					--	self.ef_wires:Setendent(tr.Entity)
					--end
				end
				self:SetChargeAttack(tab.ChargeAttack, item)
				return false
			end
			if SERVER then
				ScavData.CollectFuncs["models/alyx.mdl"] = function(self, ent)
					return {{ScavData.FormatModelname("models/alyx_emptool_prop.mdl"), SCAV_SHORT_MAX, 0},
							{ScavData.FormatModelname("models/weapons/w_alyx_gun.mdl"), 30, 0}}
				end
				ScavData.CollectFuncs["models/alyx_interior.mdl"] = ScavData.CollectFuncs["models/alyx.mdl"]
				ScavData.CollectFuncs["models/alyx_ep2.mdl"] = ScavData.CollectFuncs["models/alyx.mdl"]
				ScavData.CollectFuncs["models/player/alyx.mdl"] = ScavData.CollectFuncs["models/alyx.mdl"]
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_wrangler.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_wrangler_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), SCAV_SHORT_MAX, ent:GetSkin(), 1}} end
				ScavData.CollectFuncs["models/weapons/c_models/c_wrangler.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_wrangler.mdl"]
			else
				local headertext = function(text) draw.DrawText(text, "ScavScreenFontSmX", 44, 6, color_black, TEXT_ALIGN_LEFT) end
				local signalstrengthicon = function(self, target)
					signal:SetInt("$frame", isnumber(target) and target or signalstrength(self, target))
					surface.SetDrawColor(color_black)
					surface.SetMaterial(signal)
					surface.DrawTexturedRect(196, 6, 16, 16)
					draw.NoTexture()
				end
				local resultsscreens = {
					[STATUS_INVALID] = function(self, item)
						DrawScreenBKG(yellowscr)
						--headertext("404")
						draw.DrawText(ScavLocalize("scav.scavcan.hacknotarget"), "ScavScreenFontSm", 128, 18, color_black, TEXT_ALIGN_CENTER)
					end,
					[STATUS_CANCELED] = function(self, item)
						DrawScreenBKG(yellowscr)
						draw.DrawText(ScavLocalize("scav.scavcan.hackcanceled"), "ScavScreenFontSm", 128, 18, color_black, TEXT_ALIGN_CENTER)
					end,
					[STATUS_OUTOFRANGE] = function(self, item)
						DrawScreenBKG(yellowscr)
						signalstrengthicon(self, 4)
						draw.DrawText(ScavLocalize("scav.scavcan.hackoutofrange"), "ScavScreenFontSm", 128, 18, color_black, TEXT_ALIGN_CENTER)
					end,
					[STATUS_SUCCESS] = function(self, item)
						DrawScreenBKG(greenscr)
						draw.DrawText(ScavLocalize("scav.scavcan.hacksuccess", "\0"), "ScavScreenFont", 128, 32, color_black, TEXT_ALIGN_CENTER)
					end,
					[STATUS_FIREWALL] = function(self, item)
						DrawScreenBKG(greenscr)
						draw.DrawText(ScavLocalize("scav.scavcan.firewall", "\0"), "ScavScreenFontSmX", 128, 72, color_black, TEXT_ALIGN_CENTER)
						surface.SetMaterial(scavfirewall)
						surface.SetDrawColor(color_black)
						surface.DrawTexturedRect(104, 12, 48, 48)
					end
				}
				setmetatable(resultsscreens, {__index = function() return function(self, item) self:DrawCooldown() end end})
					--DrawScreenBKG(yellowscr)
					--draw.DrawText(tostring(self.HackStatus), "ScavScreenFont", 128, 32, color_black, TEXT_ALIGN_CENTER)
				--end end})

				function tab.ScreenCooldown(self, item)
					resultsscreens[self.HackStatus](self, item)
				end
				function tab.ScreenFiring(self, item)
					DrawScreenBKG(yellowscr)
					local wheatleyslow = tab.Identify[item.ammo] == SCAV_HACK_WHEATLEY and wheatleytime or 1
					local _, use = math.modf(CurTime())
					local progressdots = math.floor(use * 4)
					--Hacking text
					headertext(ScavLocalize("scav.scavcan.hacking") .. ScavLocalize("scav.scavcan.progress" .. tostring(progressdots)))
					surface.SetDrawColor(color_black:Unpack())
					--Separator bars
					surface.DrawRect(42, 28, 172, 2)
					--Progress bar
					surface.SetMaterial(bars)
					local x, y, w, h, res = 82, 50, 108, 12, 512
					local barmove = math.floor(use * 10) / 10
					local progress = math.max(0, math.min(1, (self.HackingProgress or 0) / (self.HackTime * wheatleyslow)))
					surface.DrawTexturedRectUV(x, y, w * progress, h, x / res - barmove, y / res, (x + w * progress) / res  - barmove, (y + h * 3) / res)
					--Scav Icon
					surface.SetMaterial(scavicon)
					surface.DrawTexturedRect(32, 34, 48, 48)
					--Other Icon
					local target = self:GetNWFiremodeEnt()
					surface.SetMaterial(interactions[IsValid(target) and string.lower(target:GetClass()) or 0].Icon)
					surface.DrawTexturedRect(176, 34, 48, 48)
					--Signal Strength Indicator
					signalstrengthicon(self, target)
				end
			end
		ScavData.RegisterFiremode(tab, "models/props_c17/computer01_keyboard.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/alyx_emptool_prop.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_rooftop/roof_dish001.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_rooftop/satellitedish02.mdl", SCAV_SHORT_MAX)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_office/computer_keyboard.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/cs_office/projector_remote.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/weapons/w_defuser.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_wrangler.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_wrangler.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_wrangler_xmas.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_invasion_wrangler/c_invasion_wrangler.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_builder.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_pda_engineer.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_spytech/satellite_dish001.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_powerhouse/emergency_launch_button.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_p2rec/c_p2rec.mdl", SCAV_SHORT_MAX)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_remotecontrol01a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_rooftop/satellitedish_large01.mdl", SCAV_SHORT_MAX)
		--Portal/2
		ScavData.RegisterFiremode(tab, "models/props/kb_mouse/keyboard.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/npcs/personality_sphere/personality_sphere.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/npcs/personality_sphere/personality_sphere_skins.mdl", SCAV_SHORT_MAX)
		--ASW
		ScavData.RegisterFiremode(tab, "models/props/utilities/satellite_dish001a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props/utilities/satellite_dish002a.mdl", SCAV_SHORT_MAX)
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_desert/radardome01b.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_st/radar_dish.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_keyboard01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/computer_keyboard02.mdl", SCAV_SHORT_MAX)
	end
		
--[[==============================================================================================
	--Teleporter
==============================================================================================]]--

		PrecacheParticleSystem(PORTAL and "portal_1_projectile_stream" or "Rocket_Smoke")

		local tab = {}
			tab.Name = "#scav.scavcan.teleporter"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 6
			tab.vmin = Vector(-24, -24, 0)
			tab.vmax = Vector(24, 24, 0)
			local identify = {
				--[HL2-style] = SCAV_TELE_DEFAULT,
				--[[Combine]]["models/props_combine/combine_teleport_2.mdl"] = SCAV_TELE_COMBINE,
				--[[Portal]]["models/weapons/w_portalgun.mdl"] = SCAV_TELE_PORTAL,
				--[[TF2]]["models/buildables/teleporter_light.mdl"] = SCAV_TELE_TF2,
				["models/buildables/teleporter.mdl"] = SCAV_TELE_TF2,

			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
			
				util.AddNetworkString("scv_sfl")
				local firesound = {
					[SCAV_TELE_COMBINE] = "buttons/combine_button2.wav",
					[SCAV_TELE_PORTAL] = "weapons/portalgun/portalgun_shoot_blue1.wav",
					[SCAV_TELE_TF2] = "weapons/teleporter_ready.wav",
				}
				firesound = setmetatable(firesound, {__index = function() return "ambient/machines/catapult_throw.wav" end})
				local hitsound = {
					[SCAV_TELE_PORTAL] = "weapons/portalgun/portal_open3.wav",
					[SCAV_TELE_TF2] = "weapons/teleporter_send.wav",
				}
				hitsound = setmetatable(hitsound, {__index = function() return "ambient/machines/teleport1.wav" end})
				local invalidhitsound = PORTAL and "weapons/portalgun/portal_invalid_surface3.wav" or "physics/flesh/flesh_bloody_impact_hard1.wav"
				tab.Callback = function(self, tr)
					if not IsValid(self.Owner) or not self.Owner:Alive() then return end
					if tr.HitSky then return end

					local tracep = {}
						tracep.start = tr.HitPos + vector_up + tr.HitNormal * 32
						tracep.endpos = tracep.start + vector_up * (self.Owner:Crouching() and 36 or 72)
						tracep.filter = self.Owner
						tracep.mask = MASK_SHOT
						tracep.mins = Vector(-24, -24, 0)
						tracep.maxs = Vector(24, 24, 0)
					debugoverlay.SweptBox(tracep.start, tracep.endpos, tracep.mins, tracep.maxs, angle_zero, 15, Color(255, 0, 255, 255), true)
					local tr2 = util.TraceHull(tracep)
					if tr2.Hit then
						self.Owner:EmitSound(invalidhitsound)
						return
					end
					local offset = tr.HitNormal * 18
					debugoverlay.Line(tr.HitPos, tr.HitPos + offset, 15, Color(0, 255, 0, 255), true)
					if offset.z < 0 then
						self.Owner:EmitSound(invalidhitsound)
						return
					end
					offset.z = 1
					debugoverlay.Line(tr.HitPos, tr.HitPos + offset, 15, Color(255, 0, 0, 255), true)
					debugoverlay.SweptBox(tr.HitPos + offset, tr.HitPos + offset + vector_up * (self.Owner:Crouching() and 36 or 72), Vector(-16, -16, 0), Vector(16, 16, 0), angle_zero, 15, Color(255, 255, 0, 255), true)

					if tr.Hit then
						net.Start("scv_sfl")
							net.WriteEntity(self.Owner:GetWeapon("scav_gun"))
							net.WriteFloat(130)
							net.WriteFloat(1)
						net.Send(self.Owner)
						self.Owner:SetPos(tr.HitPos + offset)
						local item = self.Owner:GetActiveWeapon():GetCurrentItem()
						if not item then return end
						local tab = ScavData.models[item.ammo]
						self.Owner:EmitSound(hitsound[tab.Identify[item.ammo]])
					else
						self.Owner:EmitSound(invalidhitsound)
					end
				end
				tab.proj = GProjectile()
				tab.proj:SetCallback(tab.Callback)
				tab.proj:SetBBox(Vector(-3, -3, -3), Vector(3, 3, 3))
				tab.proj:SetPiercing(false)
				tab.proj:SetGravity(vector_origin)
				tab.proj:SetMask(MASK_SHOT)
				local proj = tab.proj
			
				tab.FireFunc = function(self, item)
					local pos = self.Owner:GetShootPos() + self:GetAimVector() * 24 + self:GetAimVector():Angle():Right() * 4 - self:GetAimVector():Angle():Up() * 4
					local tab = ScavData.models[item.ammo]
					local shootz = self.Owner:GetShootPos().z - self.Owner:GetPos().z
					--s_proj.AddProjectile(self.Owner, self.Owner:GetShootPos(), self:GetAimVector() * 5000, ScavData.models[item.ammo].Callback, false, false, vector_origin, self.Owner, Vector(-8, -8, -8), Vector(8, 8, 8))
					--					(Owner,     pos,                     velocity,                      callback,                                  ignoreworld, pierce, gravity, tablefilter, mins, maxs) --what the FUCK was I doing here?
					proj:SetOwner(self.Owner)
					proj:SetFilter(self.Owner)
					proj:SetPos(self.Owner:GetShootPos())
					local vel = self:GetAimVector() * 2000 * self:GetForceScale()
					proj:SetVelocity(vel)
					proj:Fire()
					local ef = EffectData()
					ef:SetOrigin(pos)
					ef:SetStart(vel)
					ef:SetEntity(self.Owner)
					self.Owner:EmitSound(firesound[tab.Identify[item.ammo]])
					util.Effect("ef_scav_portalbeam", ef, nil, true)
					return false
				end
			else
				tab.FireFunc = function(self, item)
					local tr = self.Owner:GetEyeTraceNoCursor()
					local tab = ScavData.models[item.ammo]
					return false
				end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/maxofs2d/hover_rings.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/buildables/teleporter_light.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/miniteleport.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/teleportbulk.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/teleportbulkeli.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_combine/combine_teleport_2.mdl", SCAV_SHORT_MAX)
		--Portal
		ScavData.RegisterFiremode(tab, "models/weapons/w_portalgun.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/buildables/teleporter_light.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/buildables/teleporter.mdl", SCAV_SHORT_MAX)
		
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
				hook.Add("PlayerDeath", "scv_cleargrapple", function(pl) if pl.GrappleAssist and IsValid(pl.GrappleAssist) then pl.GrappleAssist:Remove() end end)
				tab.ChargeAttack = function(self, item)
					local tab = ScavData.models[item.ammo]
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
							--vel.x = vel.x * 16
							--vel.y = vel.y * 16
							if vel.z < 0 then
								vel.z = 0
							end
							local length = math.max(vel:Length(), 200)
							self.Owner:SetVelocity(vel:GetNormalized() * length)
							self.GrappleAssist:Remove()
							self:SetNWFiremodeEnt(NULL)
						--else
						
						end
						return 0.25
					else --grappling
						tab.chargeanim = ACT_VM_FIDGET
						self.Owner:SetLocalPos(vector_origin)
						if self.Owner:KeyDown(IN_JUMP) then
							self.GrappleTargetLength = math.min(self.GrappleTargetLength + 3, 1024)
						end
						if self.Owner.scavGoDown then
							self.GrappleTargetLength = math.max(self.GrappleTargetLength - 3, 64)
						end
						if self.Owner:KeyDown(IN_MOVELEFT) then
							self.GrappleAssist:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAngles()):Right() * -200)
						end
						if self.Owner:KeyDown(IN_MOVERIGHT) then
							self.GrappleAssist:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAngles()):Right() * 200)
						end
						if self.Owner:KeyDown(IN_FORWARD) then
							self.GrappleAssist:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAngles()):Forward() * 200)
						end
						if self.Owner:KeyDown(IN_BACK) then
							self.GrappleAssist:GetPhysicsObject():ApplyForceCenter((self.Owner:GetAngles()):Forward() * -200)
						end
						
						if self.GrappleAssistConstraint and IsValid(self.GrappleAssistConstraint) then
							local length = math.Approach(self.GrappleAssistConstraint.length, self.GrappleTargetLength, 3)
							self.GrappleAssistConstraint.length = length
							self.GrappleAssistConstraint:Fire("SetSpringLength", length, 0)
							table.insert(self.GrappleAssist.AvgVel, 1, self.GrappleAssist:GetPhysicsObject():GetVelocity())
							if self.GrappleAssist.AvgVel[15] then
								table.remove(self.GrappleAssist.AvgVel, 15)
							end
						end
					end
					return 0.01
				end
				tab.FireFunc = function(self, item)
					local tracep = {}
						tracep.mask = MASK_SHOT
						tracep.mins = Vector(-8, -8, -8)
						tracep.maxs = Vector(8, 8, 8)
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 1024
						tracep.filter = self.Owner
						local tr = util.TraceHull(tracep)
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
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
							self.GrappleAssist:GetPhysicsObject():SetDamping(0, 9000)
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
						self.Owner:SetLocalAngles(Angle(0, 0, 0))
						local constr, rope = constraint.Elastic(self.GrappleAssist, tr.Entity, 0, 0, Vector(0, 0, 72), tr.HitPos - tr.Entity:GetPos(), 99999, 50, 0, "cable/physbeam", 0, false)
						--self.GrappleTargetLength = math.min((self.GrappleAssist:GetPos() + Vector(0, 0, 72)):Distance(tr.HitPos), 150)
						self.GrappleTargetLength = 200
						self.GrappleAssistConstraint = constr
						--self.Owner:SnapEyeAngles(eyeang)
						--print(constr:GetClass())
					elseif tr.Hit then
						self.grapplenohit = true
						tr.Entity:TakeDamage(10, self.Owner, self)
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
			else
				tab.ChargeAttack = function(self, item)
				local tab = ScavData.models[item.ammo]
					local par = self:GetNWFiremodeEnt()
					if not self.Owner:KeyDown(IN_ATTACK) then
						self.Owner:SetAnimation(PLAYER_ATTACK1)
						self:SetChargeAttack()
						--self.WeaponCharge = 0
						tab.chargeanim = ACT_VM_PRIMARYATTACK
						if IsValid(par) then
							self:SetViewLerp(EyeAngles(), 0.3)
							local ang = self:GetAimVector():Angle()
							ang.r = 0
							self.Owner:SetEyeAngles(ang)
						end
						return 0.25
					elseif IsValid(par) then
						--self.WeaponCharge = self.WeaponCharge + 0.2
						tab.chargeanim = ACT_VM_FIDGET
					else
						tab.chargeanim = nil
					end
					return 0.01
				end
				tab.FireFunc = function(self, item)
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
					return false
				end
			end
			
			concommand.Add("+sgrapdown", function(pl, cmd, args) pl.scavGoDown = true end)
			concommand.Add("-sgrapdown", function(pl, cmd, args) pl.scavGoDown = false end)
			
			if CLIENT then
				hook.Add("PlayerBindPress", "scavgrap", function(pl, bind, pressed)
					local ent = pl:GetParent()
					if (bind == "+duck") and IsValid(ent) and (ent:GetClass() == "scav_grappleassist") then
						RunConsoleCommand(pressed and "+sgrapdown" or "-sgrapdown")
						return true
					end
				end)
			end
			
		ScavData.RegisterFiremode(tab, "models/props_wasteland/cranemagnet01a.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_mining/cranehook001.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_trainyard/pulley_block001.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_forest/claw.mdl", SCAV_SHORT_MAX)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/infected/smoker.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/infected/smoker_l4d1.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/infected/smoker_tongue_attach.mdl", SCAV_SHORT_MAX)
		--Portal/2
		ScavData.RegisterFiremode(tab, "models/props/claw/claw.mdl", SCAV_SHORT_MAX)

--[[==============================================================================================
	-- Combine Binoculars
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.binoculars"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.fov = 2
			local zoomhook = function()
				hook.Add("AdjustMouseSensitivity", "ScavZoomedIn", function()
					return tab.fov / GetConVar("fov_desired"):GetFloat()
				end)
			end
			tab.FireFunc = function(self, item)
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
					hook.Remove("AdjustMouseSensitivity", "ScavZoomedIn")
				end
				self.Owner:EmitSound("buttons/lightswitch2.wav")
			end
			tab.PostRemove = function(self, item)
				if CLIENT then
					tab.fov = GetConVar("fov_desired"):GetFloat()
				else
					tab.fov = 90
				end
				self:SetZoomed(false)
				hook.Remove("AdjustMouseSensitivity", "ScavZoomedIn")
			end
			tab.Cooldown = 0.25
			ScavData.RegisterFiremode(tab, "models/props_combine/combine_binocular01.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/props_c17/light_magnifyinglamp02.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/gibs/gunship_gibs_eye.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/gibs/gunship_gibs_sensorarray.mdl", SCAV_SHORT_MAX)
		
--[[==============================================================================================
	-- Medkits
==============================================================================================]]--
	
		medkit = {
			[0] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + 25))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2, 25
			end,
			[1] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + 10))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 1, 10
			end,
			[2] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + healent:GetMaxHealth() * 0.205)) --20.5%
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 1, IsValid(healent) and (healent:GetMaxHealth() * 0.205) or 20.5
			end,
			[3] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + healent:GetMaxHealth() * 0.5))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2, IsValid(healent) and (healent:GetMaxHealth() * 0.5) or 50
			end,
			[4] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(healent:GetMaxHealth())
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 3, IsValid(healent) and healent:GetMaxHealth() or 100
			end,
			[5] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + math.max(1, math.floor((healent:GetMaxHealth() - healent:Health()) * 0.8)))) --heal 80% of our current damage (or at least 1 health)
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2, IsValid(healent) and (math.max(1, math.floor((healent:GetMaxHealth() - healent:Health()) * 0.8))) or 80
			end,
			[6] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + 50)) --TODO: Make this revive?
					healent:EmitSound("weapons/defibrillator/defibrillator_use.wav")
				end
				return 2, 50
			end,
			[7] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + 6))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return .5, 6
			end,
			[8] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + 4))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return .5, 4
			end,
			[9] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + 1))
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return .5, 1
			end,
			[10] = function(healent, noheal)
				if SERVER and IsValid(healent) and not noheal then
					healent:SetHealth(math.min(healent:GetMaxHealth(), healent:Health() + 50))
					healent:InflictStatusEffect("Disease", -5, 1)
					healent:EmitSound("items/smallmedkit1.wav")
				end
				return 2, 50
			end,
		}

		local tab = {}
			tab.Name = "#weapon_medkit"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {
				--[Default +25] = 0,
				--[[Vial +10]]["models/healthvial.mdl"] = 1,
				--[[TF2 Small +20.5%]]["models/items/medkit_small.mdl"] = 2,
				["models/items/medkit_small_bday.mdl"] = 2,
				["models/props_halloween/halloween_medkit_small.mdl"] = 2,
				--[[TF2 Medium +50%]]["models/items/medkit_medium.mdl"] = 3,
				["models/items/medkit_medium_bday.mdl"] = 3,
				["models/props_halloween/halloween_medkit_medium.mdl"] = 3,
				--[[TF2 Large +100%]]["models/items/medkit_large.mdl"] = 4,
				["models/items/medkit_large_bday.mdl"] = 4,
				["models/props_halloween/halloween_medkit_large.mdl"] = 4,
				--[[L4D/2 -80% Damage]]["models/w_models/weapons/w_eq_medkit.mdl"] = 5,
				--[[L4D/2 Defib +50]]["models/w_models/weapons/w_eq_defibrillator.mdl"] = 6,
				--[[Large Grub Nugget +6]]["models/grub_nugget_large.mdl"] = 7,
				--[[Medium Grub Nugget +4]]["models/grub_nugget_medium.mdl"] = 8,
				--[[Small Grub Nugget +1]]["models/grub_nugget_small.mdl"] = 9,
				--[[ASW +50, -5 Disease]]["models/items/personalmedkit/personalmedkit.mdl"] = 10,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 4
			tab.vmin = Vector(-12, -12, -12)
			tab.vmax = Vector(12, 12, 12)
			tab.FireFunc = function(self, item)
				local healent = self.Owner
				local tracep = {}
				tracep.start = self.Owner:GetShootPos()
				tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 100
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
				tab.Cooldown = medkit[ScavData.models[item.ammo].Identify[item.ammo]](healent)
				local ef = EffectData()
				ef:SetRadius(math.max(2, healent:Health() - starthealth))
				ef:SetOrigin(self.Owner:GetPos())
				ef:SetScale(self.Owner:EntIndex())
				ef:SetEntity(healent)
				util.Effect("ef_scav_heal", ef, nil, true)
				if SERVER then
					return self:TakeSubammo(item, 1)
				end
			end
			tab.ReturnHealth = function(self, item)
				if not IsValid(self.Owner) then return 0 end
				local _, heal = medkit[ScavData.models[item.ammo].Identify[item.ammo]](self.Owner, true)
				return heal
			end
			if SERVER then
				ScavData.CollectFuncs["models/antlion_grub_squashed.mdl"] = function(self, ent)
					local healthratio = self.Owner:Health() / self.Owner:GetMaxHealth()
					if healthratio > .9 then
						return {{"models/grub_nugget_small.mdl", 1, 0}}
					elseif healthratio > .7 then
						return {{"models/grub_nugget_medium.mdl", 1, 0}}
					else
						return {{"models/grub_nugget_large.mdl", 1, 0}}
					end
				end
				ScavData.CollectFX["models/antlion_grub_squashed.mdl"] = function(self, ent)
					self.Owner:EmitSound("npc/antlion_grub/agrub_idle6.wav")
					self.Owner:EmitSound("npc/antlion_grub/agrub_squish2.wav")
				end
				--TF2
				ScavData.CollectFuncs["models/items/medkit_small.mdl"] = function(self, ent) return {{self.halloween and "models/props_halloween/halloween_medkit_small.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, 0}} end
				ScavData.CollectFuncs["models/items/medkit_medium.mdl"] = function(self, ent) return {{self.halloween and "models/props_halloween/halloween_medkit_medium.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, 0}} end
				ScavData.CollectFuncs["models/items/medkit_large.mdl"] = function(self, ent) return {{self.halloween and "models/props_halloween/halloween_medkit_large.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, 0}} end
				--L4D/2
				ScavData.CollectFuncs["models/w_models/weapons/w_eq_defibrillator_no_paddles.mdl"] = function(self, ent) return {{"models/w_models/weapons/w_eq_defibrillator.mdl", 1, 0}} end
				--HLS
				ScavData.CollectFuncs["models/scientist.mdl"] = function(self, ent) return {{"models/w_medkit.mdl", 1, 0}} end
			end
		ScavData.RegisterFiremode(tab, "models/items/healthkit.mdl")
		ScavData.RegisterFiremode(tab, "models/healthvial.mdl")
		ScavData.RegisterFiremode(tab, "models/grub_nugget_large.mdl")
		ScavData.RegisterFiremode(tab, "models/grub_nugget_medium.mdl")
		ScavData.RegisterFiremode(tab, "models/grub_nugget_small.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/items/medkit_small.mdl")
		ScavData.RegisterFiremode(tab, "models/items/medkit_small_bday.mdl")
		ScavData.RegisterFiremode(tab, "models/props_halloween/halloween_medkit_small.mdl")
		ScavData.RegisterFiremode(tab, "models/items/medkit_medium.mdl")
		ScavData.RegisterFiremode(tab, "models/items/medkit_medium_bday.mdl")
		ScavData.RegisterFiremode(tab, "models/props_halloween/halloween_medkit_medium.mdl")
		ScavData.RegisterFiremode(tab, "models/items/medkit_large.mdl")
		ScavData.RegisterFiremode(tab, "models/items/medkit_large_bday.mdl")
		ScavData.RegisterFiremode(tab, "models/props_halloween/halloween_medkit_large.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_eq_medkit.mdl")
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_eq_defibrillator.mdl")
		--HLS
		ScavData.RegisterFiremode(tab, "models/w_medkit.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/items/personalmedkit/personalmedkit.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/weapons/w_medkit_classic.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_medkit_stiff.mdl")

--[[==============================================================================================
	-- Pain Pills (temporary health)
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.pills"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			tab.MaxAmmo = 3
			tab.vmin = Vector(-12, -12, -12)
			tab.vmax = Vector(12, 12, 12)
			tab.FireFunc = function(self, item)
				local healent = self.Owner
				local tracep = {}
				tracep.start = self.Owner:GetShootPos()
				tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 100
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
					healent:InflictStatusEffect("TemporaryHealth", 50, 1)
				end
				if SERVER then
					if L4D then
						healent:EmitSound("player/items/pain_pills/pills_deploy_1.wav")
					else
						healent:EmitSound("weapons/smg1/switch_burst.wav", 75, 180, 1)
					end
				end
				
				local ef = EffectData()
				ef:SetRadius(math.max(2, healent:Health() - starthealth))
				ef:SetOrigin(self.Owner:GetPos())
				ef:SetScale(self.Owner:EntIndex())
				ef:SetEntity(healent)
				util.Effect("ef_scav_heal", ef, nil, true)
				tab.Cooldown = 1
				if SERVER then
					return self:TakeSubammo(item, 1)
				end
			end
			if SERVER then
				--L4D/2
				ScavData.CollectFuncs["models/survivors/survivor_manager.mdl"] = function(self, ent) return {{"models/w_models/weapons/w_eq_painpills.mdl", 3, 0}} end --3 pills from Louis
				ScavData.CollectFX["models/survivors/survivor_manager.mdl"] = function(self, ent) self.Owner:EmitSound("player/survivor/voice/manager/takepills02.wav", 75, 100, 1, CHAN_VOICE)end
			end
		ScavData.RegisterFiremode(tab, "models/scav/pill_bottle.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/w_models/weapons/w_eq_painpills.mdl")

--[[==============================================================================================
	-- Blast Shower
==============================================================================================]]--

if SERVER then
	util.AddNetworkString("ScavStopTheRain")
	hook.Add("PostPlayerDeath", "ScavStopTheRain", function(ply)
		net.Start("ScavStopTheRain")
		net.Send(ply)
	end)
else
	net.Receive("ScavStopTheRain", function()
		hook.Remove( "RenderScreenspaceEffects", "ScavDrips")
	end)
end

		local tab = {}
			tab.Name = "#scav.scavcan.shower"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {} --all blast showers are the same
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.MaxAmmo = 30

			local toFloat = function(a_bool) return a_bool and 1 or 0 end
			PrecacheParticleSystem("water_splash_01_droplets")
				tab.ChargeAttack = function(self, item)
					local drunk = self.Owner:GetStatusEffect("Drunk")
					local totalStatuses =	toFloat(self.Owner:GetStatusEffect("Slow")) +
											toFloat(self.Owner:GetStatusEffect("Frozen")) +
											toFloat(self.Owner:GetStatusEffect("Disease")) +
											toFloat(self.Owner:GetStatusEffect("Burning")) +
											toFloat(self.Owner:GetStatusEffect("Acid Burning")) +
											toFloat(self.Owner:GetStatusEffect("Shock")) +
											toFloat(self.Owner:GetStatusEffect("Radiation")) +
											toFloat(self.Owner:GetStatusEffect("Numb")) +
											toFloat(self.Owner:GetStatusEffect("Deaf")) +
											toFloat(drunk and drunk.Value > 1)
					--Currently it'll reduce more status effects than total ammo left if the player has more active statuses than ammo. Do we care?
					if SERVER then
						self.Owner:InflictStatusEffect("Slow", -1, 1)
						self.Owner:InflictStatusEffect("Frozen", -3, 1) --can the player even use this if they're currently frozen?
						self.Owner:InflictStatusEffect("Disease", -2, 1)
						self.Owner:InflictStatusEffect("Burning", -2, 1)
						self.Owner:InflictStatusEffect("Acid Burning", -2, 1)
						self.Owner:InflictStatusEffect("Shock", -1, 1)
						self.Owner:InflictStatusEffect("Radiation", -1, 1)
						self.Owner:InflictStatusEffect("Numb", -1, 1)
						self.Owner:InflictStatusEffect("Deaf", -1, 1)
						if drunk and drunk.Value > 1 then
							self.Owner:InflictStatusEffect("Drunk", -1, -0.125)
						end
						self:TakeSubammo(item, totalStatuses)
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
					util.Effect("ef_scav_muzzlesplash", ef)
					if totalStatuses > 0 then
						self:EmitSound("ambient/water/rain_drip" .. math.random(1, 4) .. ".wav", 75, 140, 0.25)
					end
					local continuefiring = self:ProcessLinking(item) and self:StopChargeOnRelease()
					if not continuefiring then
						if SERVER then
							self.soundloops.showerrun:Stop()
							self.Owner:EmitSound("ambient/water/rain_drip" .. math.random(1, 4) .. ".wav", 75, 100, 0.5)
							self:SetChargeAttack()
							self:SetBarrelRestSpeed(0)
							net.Start("ScavStopTheRain")
							net.Send(self.Owner)
						end
						return 2
					else
						if SERVER then self.soundloops.showerrun:Play() end
						return 0.1
					end
				end
				tab.FireFunc = function(self, item)
					self:SetChargeAttack(ScavData.models[item.ammo].ChargeAttack, item)
					if SERVER then
						self.Owner:EmitSound("buttons/lever2.wav")
						self.soundloops.showerrun = CreateSound(self.Owner, "ambient/water/water_run1.wav")
						self:SetBarrelRestSpeed(400)
					else
						timer.Simple(1, function()
							if self:ProcessLinking(item) and self:StopChargeOnRelease() then --make sure the player didn't cancel the charge before we even got to it
								hook.Add("RenderScreenspaceEffects", "ScavDrips", function()
									DrawMaterialOverlay("models/shadertest/shader3", -0.01)
								end)
							end
						end)
					end
					return false
				end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/props_interiors/sinkkitchen01a.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_c17/furnituresink001a.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_junk/metalbucket01a.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_junk/metalbucket02a.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_interiors/bathtub01a.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_c17/furniturebathtub001a.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_c17/furniturewashingmachine001a.mdl", 25)
		ScavData.RegisterFiremode(tab, "models/props_wasteland/laundry_dryer001.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_wasteland/laundry_dryer002.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_wasteland/laundry_washer001a.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_wasteland/laundry_washer003.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_wasteland/shower_system001a.mdl", 30)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/showers.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/toothbrushset01.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/dryer.mdl", 25)
		ScavData.RegisterFiremode(tab, "models/props/cs_assault/firehydrant.mdl", 30)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_2fort/sink001.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_2fort/hose001.mdl", 20)
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_furniture/sink1.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_furniture/bathtub1.mdl", 20)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_interiors/bathroomsink01.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_interiors/bathtub01.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_interiors/sink_industrial01.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_interiors/sink_kitchen.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_interiors/pedestal_sink.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_docks/marina_firehosebox.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_equipment/firehosebox01.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_interiors/soap_dispenser.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_interiors/soap_dispenser_static.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_interiors/dish_soap.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_interiors/dish_soap_static.mdl", 5)
		ScavData.RegisterFiremode(tab, "models/props_interiors/soapdispenser01.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_interiors/dryer.mdl", 25)
		ScavData.RegisterFiremode(tab, "models/props_junk/metalbucket01a_static.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_junk/metalbucket02a_static.mdl", 10)
		ScavData.RegisterFiremode(tab, "models/props_street/firehydrant.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_urban/fire_hydrant001.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_waterfront/tattoo_autoclave.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_unique/mop01.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_unique/mopbucket01.mdl", 30)
		--ASW
		ScavData.RegisterFiremode(tab, "models/props/furniture/misc/bathroomsink.mdl", 20)
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/restroom_sink.mdl", 20)
		ScavData.RegisterFiremode(tab, "models/props_office/aircan.mdl", 15)
		ScavData.RegisterFiremode(tab, "models/props_generic/safetyshower.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_industrial/fire_buckets.mdl", 30)
		ScavData.RegisterFiremode(tab, "models/props_junk/mopbucket01.mdl", 30)

--[[==============================================================================================
	-- Sandwich
==============================================================================================]]--
		local sandwichheal = {
			[SCAV_SANDWICH_DEFAULT] = 50,
			[SCAV_SANDWICH_BANANA] = 25,
			[SCAV_SANDWICH_JUNK] = 10
		}
		local tab = {}
		
			tab.Name = "#scav.scavcan.sandvich"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {
				--[Sandvich] = 0,
				--[[Banana]]["models/weapons/c_models/c_banana/c_banana.mdl"] = SCAV_SANDWICH_BANANA,
				["models/items/banana/banana.mdl"] = SCAV_SANDWICH_BANANA,
				["models/items/banana/plate_banana.mdl"] = SCAV_SANDWICH_BANANA,
				["models/props/cs_italy/bananna.mdl"] = SCAV_SANDWICH_BANANA,
				--[[Junk Food]]["models/props_equipment/snack_machine.mdl"] = SCAV_SANDWICH_JUNK,
				["models/props_equipment/snack_machine2.mdl"] = SCAV_SANDWICH_JUNK,
				["models/props_canteen/donutbox.mdl"] = SCAV_SANDWICH_JUNK,
				["models/props_canteen/vendingmachine01.mdl"] = SCAV_SANDWICH_JUNK,
				["models/props_office/c1a2c_foodcrate_01.mdl"] = SCAV_SANDWICH_JUNK,
				["models/props_office/c1a2c_foodcrate_02.mdl"] = SCAV_SANDWICH_JUNK,
				["models/props_office/c1a2c_foodcrate_03.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vendingmachine01_p1a.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vendingmachine01_p1b.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vendingmachine01_p1c.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack01.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack02.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack03.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack04.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack05.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack06.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack07.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack08.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack09.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack10.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack11.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack12.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack13.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack14.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack15.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack16.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack17.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack18.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack19.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack20.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack21.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack22.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack23.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack24.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack25.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack26.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack27.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack28.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack29.mdl"] = SCAV_SANDWICH_JUNK,
				["models/gibs/props_canteen/vm_snack30.mdl"] = SCAV_SANDWICH_JUNK,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_SANDWICH_DEFAULT end})
			tab.MaxAmmo = 3
			tab.FireFunc = function(self, item)
				local drunk = self.Owner:GetStatusEffect("Drunk")
				if self.Owner:Health() >= self.Owner:GetMaxHealth() and not drunk then
					if SERVER then
						self.Owner:EmitSound(TF2 and "vo/heavy_no02.mp3" or "phx/eggcrack.wav", 75, 100, 1, CHAN_VOICE)
					end
					tab.Cooldown = 0.5
					return false
				else
					tab.Cooldown = ScavData.models[item.ammo].Identify[item.ammo] == SCAV_SANDWICH_BANANA and 1 or 2
					if SERVER then
						if drunk then
							self.Owner:InflictStatusEffect("Drunk", -(drunk.EndTime - CurTime()) * sandwichheal[ScavData.models[item.ammo].Identify[item.ammo]] / 100, -0.125 )
						end
						if ScavData.models[item.ammo].Identify[item.ammo] == SCAV_SANDWICH_BANANA then
							self.Owner:InflictStatusEffect("Radiation", 0.25, 0.01)
						end
						self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(), self.Owner:Health() + sandwichheal[ScavData.models[item.ammo].Identify[item.ammo]]))
						self.Owner:EmitSound(TF2 and "vo/SandwichEat09.mp3" or "physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", 75, 100, 1, CHAN_VOICE)
						return self:TakeSubammo(item, 1)
					end
				end
			end
			tab.ReturnHealth = function(self, item)
				return sandwichheal[ScavData.models[item.ammo].Identify[item.ammo]]
			end
			if SERVER then
				--CSS
				ScavData.CollectFuncs["models/props/cs_italy/bananna_bunch.mdl"] = function(self, ent) return {{"models/props/cs_italy/bananna.mdl", 5, 0}} end
				--TF2
				ScavData.CollectFuncs["models/weapons/c_models/c_sandwich/c_sandwich.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_sandwich/c_sandwich_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, math.random(0, 1)}} end
				ScavData.CollectFuncs["models/items/plate.mdl"] = function(self, ent) return {{self.christmas and "models/items/plate_sandwich_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, math.random(0, 1)}} end
			end
		ScavData.RegisterFiremode(tab, "models/food/burger.mdl")
		ScavData.RegisterFiremode(tab, "models/food/hotdog.mdl")
		ScavData.RegisterFiremode(tab, "models/noesis/donut.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/misc/egg.mdl")
		ScavData.RegisterFiremode(tab, "models/props_phx/misc/potato.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_bag001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_milkcarton001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_milkcarton002a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_takeoutcarton001a.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_italy/bananna.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_sandwich/c_sandwich.mdl")
		ScavData.RegisterFiremode(tab, "models/items/plate.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_banana/c_banana.mdl")
		ScavData.RegisterFiremode(tab, "models/items/banana/banana.mdl")
		ScavData.RegisterFiremode(tab, "models/items/banana/plate_banana.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_chocolate/c_chocolate.mdl") --todo: temporary extra max health
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_chocolate/c_chocolate.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_chocolate/plate_chocolate.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_fishcake/c_fishcake.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_fishcake/c_fishcake.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_fishcake/plate_fishcake.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_sandwich/c_robo_sandwich.mdl")
		ScavData.RegisterFiremode(tab, "models/items/plate_robo_sandwich.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_sandwich/c_sandwich_xmas.mdl")
		ScavData.RegisterFiremode(tab, "models/items/plate_sandwich_xmas.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_baguette.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_burnt.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_cinnamon.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_cornbread.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_crumpet.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_plainloaf.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_pretzel.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_ration.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bread/c_bread_russianblack.mdl")
		ScavData.RegisterFiremode(tab, "models/props_2fort/lunchbag.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_takeoutbox01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_cerealbox01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_cerealbox01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_cerealbox02a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_cerealbox02a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_pizzabox01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_pizzabox01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/garbage_pizza_box.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_milkcarton002a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_smallbox01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_smallbox01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_tunacan01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_fastfoodcontainer01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_frenchfrycup01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_frenchfrycup01a_fullsheet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/petfoodbag01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/garbage_hamburger_container.mdl")
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/garbage_popcorn_box.mdl")
		ScavData.RegisterFiremode(tab, "models/props_fairgrounds/garbage_popcorn_tub.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/snack_machine.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_equipment/snack_machine2.mdl")
		--Portal/2
		ScavData.RegisterFiremode(tab, "models/props/milk_carton/milk_carton.mdl")
		ScavData.RegisterFiremode(tab, "models/props/milk_carton/milk_carton_open.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_misc/ration_box01.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_canteen/donutbox.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canteen/pizza_box.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/interdimensional_pizza.mdl")
		ScavData.RegisterFiremode(tab, "models/props_canteen/taco.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/c1a2c_foodcrate_01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/c1a2c_foodcrate_02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/c1a2c_foodcrate_03.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_canteen/vendingmachine01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vendingmachine01_p1a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vendingmachine01_p1b.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vendingmachine01_p1c.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack01.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack02.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack03.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack04.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack05.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack06.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack07.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack08.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack09.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack10.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack11.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack12.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack13.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack14.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack15.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack16.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack17.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack18.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack19.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack20.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack21.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack22.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack23.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack24.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack25.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack26.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack27.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack28.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack29.mdl")
		ScavData.RegisterFiremode(tab, "models/gibs/props_canteen/vm_snack30.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/carcass_whole.mdl")

--[[==============================================================================================
	-- Crit Boost
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.crit"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {
				--[Default] = 0,
				--[Drink]] = 1,
				--[[Steroid Keg]]["models/props_island/steroid_drum.mdl"] = 2,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
					local tab = ScavData.models[item.ammo]
					local itemfx = { --TODO: add sounds, etc. for ones where appropriate
						[0] = function(self)
							self.Owner:InflictStatusEffect("DamageX", 7, 1.5)
							self.Owner:EmitSound(TF2 and "weapons/buffed_on.wav" or "beams/beamstart5.wav")
						end,
						[1] = function(self)
							self.Owner:InflictStatusEffect("DamageX", 7, 1.5)
							if TF2 then
								self.Owner:EmitSound("player/pl_scout_dodge_can_open.wav")
								self.Owner:EmitSound("player/pl_scout_dodge_can_drink_fast.wav")
							else
								self.Owner:EmitSound("hl1/fvox/hiss.wav", 75, 150)
								self.Owner:EmitSound("ambient/levels/canals/toxic_slime_gurgle4.wav")
							end
						end,
						[2] = function(self)
							self.Owner:InflictStatusEffect("DamageX", 15, 1.5)
							self.Owner:EmitSound("ambient/lair/yeti_statue_growl" .. math.random(1, 6) .. ".wav", 75, 100, 1, CHAN_VOICE)
						end,
					}
					if IsValid(self.Owner) then itemfx[tab.Identify[item.ammo]](self) end
					return true
				end
				--TF2
				ScavData.CollectFuncs["models/props_island/steroid_drum_cluster.mdl"] = function(self, ent) return {{"models/props_island/steroid_drum.mdl", 1, 0, 8}} end
				ScavData.CollectFuncs["models/weapons/c_models/c_buffpack/c_buffpack.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_buffpack/c_buffpack_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, math.random(0, 1)}} end
			end
			tab.Cooldown = 2
		ScavData.RegisterFiremode(tab, "models/weapons/w_package.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_metalcan001a.mdl") --Me spinich!
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_metalcan002a.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_halloween/pumpkin_loot.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_buffalo_steak/c_buffalo_steak.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_buffalo_steak/c_buffalo_steak.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_buffalo_steak/plate_buffalo_steak.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_buffpack/c_buffpack.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_buffpack/c_buffpack_xmas.mdl")
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_crit.mdl")
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_strength.mdl")
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_strength_arm.mdl")
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_knockout.mdl")
		ScavData.RegisterFiremode(tab, "models/props_gameplay/pill_bottle01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_island/steroid_drum.mdl")
		--Portal
		ScavData.RegisterFiremode(tab, "models/props/food_can/food_can_open.mdl")

--[[==============================================================================================
	-- Invulnerability
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.invuln"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {
				--[Default] = 0,
				--[[MannPower Uber]]["models/pickups/pickup_powerup_uber.mdl"] = 1,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
					if not IsValid(self.Owner) then return end
					local tab = ScavData.models[item.ammo]
					local itemfx = { --TODO: Sounds, etc. where appropriate
						[0] = function(self)
							self.Owner:InflictStatusEffect("Invuln", 10, 1)
						end,
						[1] = function(self)
							self.Owner:InflictStatusEffect("Invuln", 15, 1)
						end,
					}
					itemfx[tab.Identify[item.ammo]](self)
					return true
				end
			end
			tab.Cooldown = 5
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/de_tides/vending_turtle.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/pickups/pickup_powerup_uber.mdl")

--[[==============================================================================================
	--Fire Extinguisher
==============================================================================================]]--
		
		do
			local tab = {}
				tab.Name = "#scav.scavcan.extinguisher"
				tab.anim = ACT_VM_IDLE
				tab.Level = 4
				local identify = {} --all fire extinguishers are the same
				tab.Identify = setmetatable(identify, {__index = function() return 0 end})
				tab.MaxAmmo = 250
				tab.Cooldown = 0.1
				local tracep = {}

				local vmin = Vector(-12, -12, -12)
				local vmax = Vector(12, 12, 12)
				tracep.mins = vmin
				tracep.maxs = vmax
				tracep.mask = MASK_SHOT
				function tab.ChargeAttack(self, item)
					if SERVER then --SERVER
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = self.Owner:GetShootPos() + self:GetAimVector() * 150
						tracep.filter = self.Owner
						local tr = util.TraceHull(tracep)
						if tr.Hit and tr.HitPos then
							local extents = ents.FindInSphere(tr.HitPos, 80)
							for index, ent in pairs(extents) do
								if ent then
									ent:Extinguish()
									if vFireInstalled and ent.SoftExtinguish then ent:SoftExtinguish(10) end
									if ent:GetMoveType() ~= MOVETYPE_VPHYSICS and (not ent:IsPlayer() or ent ~= self.Owner) then
										if ent:IsPlayer() then
											ent:SendHUDOverlay(color_white, 2)
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
											ent:SetVelocity((ent:GetPos() - self:GetPos()):GetNormalized() * 1000)
										end
									elseif ent:GetPhysicsObject():IsValid() then
										ent:GetPhysicsObject():ApplyForceOffset((ent:GetPos() - self:GetPos()):GetNormalized() * 1000, tr.HitPos)
									end
								end
							end
						end
						local extpos = self.Owner:GetShootPos() + self:GetAimVector() * 75
						for k, v in ipairs(ents.FindByClass("env_fire")) do
							if v:GetPos():Distance(extpos) < 75 then
								v:Fire("ExtinguishTemporary", 0, 0)
							end
						end
						local proj = GProjectile()
							proj:SetOwner(self.Owner)
							proj:SetInflictor(self)
							proj:SetFilter(self.Owner)
							proj:SetPos(self.Owner:GetShootPos())
							proj:SetVelocity((self:GetAimVector() + VectorRand(-0.1, 0.1)):GetNormalized() * 100 * math.Rand(1, 6) * self:GetForceScale() + self.Owner:GetVelocity())
							proj:Fire()
						if self.Owner:GetGroundEntity() == NULL then
							self.Owner:SetVelocity(self:GetAimVector() * -54)
						end
						self:AddBarrelSpin(100)
						self:TakeSubammo(item, 1)
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
				function tab.FireFunc(self, item)
					if SERVER then
						self.ef_exting = self:CreateToggleEffect("scav_stream_extinguisher")
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					return false
				end
			--TODO: Default prop
			--CSS
			ScavData.RegisterFiremode(tab, "models/props/cs_office/fire_extinguisher.mdl", 100)
			--TF2
			ScavData.RegisterFiremode(tab, "models/props_2fort/fire_extinguisher.mdl", 100)
			--ASW
			ScavData.RegisterFiremode(tab, "models/swarm/fireext/fireextpickup.mdl", 100)
			--BMS
			ScavData.RegisterFiremode(tab, "models/props_blackmesa/fireextinguisher.mdl", 100)
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
				tracep.mins = Vector(-12, -12, -12)
				tracep.maxs = Vector(12, 12, 12)
				function tab.ChargeAttack(self, item)
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
				function tab.FireFunc(self, item)
					if SERVER then
						self.ef_pblade = self:CreateToggleEffect("scav_stream_shield")
						self.ef_pblade:SetCollisionGroup(COLLISION_GROUP_BREAKABLE_GLASS)
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					return false
				end
				-- function tab.Think(self, item) --I have no idea what I'm doing
				-- 	if IsValid(self.ef_pblade) then
				-- 		tab.mins, tab.maxs = self.ef_pblade:GetCollisionBounds()
				-- 	end
				-- end
				function tab.Break(self, item)
					if IsValid(self.ef_pblade) then
						local tr = self.Owner:GetEyeTrace()
						self.ef_pblade:GibBreakClient(tr.HitNormal * -100)
						timer.Simple(0, function() self.ef_pblade:Kill() end)
					end
					return true
				end
				ScavData.RegisterFiremode(tab, "models/props_italian/ava_stained_glass.mdl")
		end

--[[==============================================================================================
	--TF2 Medigun
==============================================================================================]]--

local green = table.Copy(greenscr)
local statusicons = {}

if SERVER then
	util.AddNetworkString("ScavFetchNPCName")

	--Get NPC menu names off the server
	net.Receive("ScavFetchNPCName", function(len, ply)
		local target = net.ReadEntity()
		if not IsValid(target) or not (target:IsNPC() or target:IsNextBot()) then return end

		local npcTable = list.GetEntry("NPC", target.NPCName)
		if not npcTable or not npcTable.Name then
			return
		end

		net.Start("ScavFetchNPCName")
			net.WriteEntity(target)
			net.WriteString(npcTable.Name)
		net.Send(ply)
	end)
else
	net.Receive("ScavFetchNPCName", function(len)
		local target = net.ReadEntity()
		if not IsValid(target) or not (target:IsNPC() or target:IsNextBot()) then return end
		target.NPCName = string.upper(language.GetPhrase(net.ReadString()))
	end)

	--bring screen green's alpha up to snuff
	green.a = 128

	--create screen-compatible versions of our status icons
	for k, _ in pairs(Status2.AllEffects) do
		statusicons[k] = CreateMaterial("ScavScreenStatus_" .. k, "UnlitGeneric", {
			["$basetexture"] = "hud/status/" .. k,
			--["$alphatest"] = 1,
			--["$alphatestreference"] = 0.4,
			["$translucent"] = 1,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1,
			["$ignorez"] = 1,
		})
	end
end

--Status screen for our patient. Continues working even if the beam is broken.
local medigunscreen = function(self, item)
	if not IsValid(self) or not item then return end

	local tab = item.GetFiremodeTable and item:GetFiremodeTable() or nil

	if not tab or self:ScreenCooldown() then
		self:DrawCooldown()
		return
	end

	local target = self:GetNWFiremodeEnt()
	local validtarget = IsValid(target)

	DrawScreenBKG(validtarget and greenscr or redscr)

	--Get patient's name
	if not tab.targetname or (validtarget and tab.targetent ~= target) then
		--Storing name/ent on the table lets us cache the results, both for not constantly pulling them and also for showing the dead screen for NPCs
		tab.targetname = language.GetPhrase("scav.scavcan.unknown")
		tab.targetent = target
		if validtarget then
			if target:IsPlayer() then
				tab.targetname = string.upper(target:Nick())
			else
				if target.NPCName == nil then
					net.Start("ScavFetchNPCName")
						net.WriteEntity(target)
					net.SendToServer()
				end
				tab.targetname = string.upper(language.GetPhrase(target:GetClass()))
			end
		end
		--try to get NPC name
		timer.Simple(0, function()
			if not IsValid(self) or not IsValid(target) or target:IsPlayer() then return end
			if target.NPCName == nil then return end
			tab.targetname = target.NPCName
		end)
	end

	local living = (validtarget and (not target:IsPlayer() or target:Alive()))

	--Determine flash
	local col = color_black
	local _, flashtime = math.modf(CurTime())
	if not living and flashtime < 0.5 then
		col = color_white
	end
	surface.SetDrawColor(col:Unpack())

	--Adjust size of name label
	local vpos = 12
	local fontsize = "ScavScreenFontSm"
	if #tab.targetname > 10 then
		fontsize = "ScavScreenFontSmX"
		vpos = vpos + 4
	end
	if #tab.targetname > 14 then
		fontsize = "ScavScreenFontSmXX"
		vpos = vpos + 2
	end

	--Draw patient name
	draw.DrawText(tab.targetname, fontsize, 128, vpos, col, TEXT_ALIGN_CENTER)

	--Draw info for a valid, living target
	if living then
		--Draw bar outline
		draw.DrawText(language.GetPhrase("scav.scavcan.health"), "ScavScreenFontSm", 46, 40, col, TEXT_ALIGN_CENTER)
		surface.DrawOutlinedRect(64, 44, 128, 24, 2)
		--Health bar
		local health = target:Health() / math.max(1, target:GetMaxHealth())
		local low = health < 0.2
		surface.DrawRect(68, 48, 120 * math.min(1, health), 16)
		--HP low warning
		if low and flashtime > 0.5 then
			surface.DrawRect(68, 48, 23, 16)
			draw.DrawText("!!!", "ScavScreenFontSmX", 69, 44, green, TEXT_ALIGN_LEFT)
		end
		--Armor (border)
		if target:IsPlayer() then
			local armor, maxarmor = target:Armor(), math.max(1, target:GetMaxArmor())
			local armorratio = math.min(1, armor / maxarmor)
			if armor > 0 then
				--near end
				surface.DrawRect(62, 42, 4, 28)
				--middle
				surface.DrawRect(62, 41, 132 * armorratio, 4)
				surface.DrawRect(62, 67, 132 * armorratio, 4)
				--full end
				if armor >= maxarmor then
					surface.DrawRect(190, 42, 4, 28)
				end
			end
		end
		--Max health
		local bigmax = target:GetMaxHealth() >= 100
		draw.DrawText(math.max(1, target:GetMaxHealth()), bigmax and "ScavScreenFontSmX" or "ScavScreenFontSm", 194, bigmax and 44 or 40, col, TEXT_ALIGN_LEFT)
		--Statuses (left black)
		if target.StatusTable then
			for k, v in ipairs(target.StatusTable) do
				surface.SetMaterial(statusicons[v.Name])
				surface.DrawTexturedRect(26 + 22 * k, 70, 20, 20)
			end
			draw.NoTexture()
		end
	--Inform that we sucked as a medic, or switched to no target (not exclusive or)
	else
		draw.DrawText(tab.targetname == language.GetPhrase("scav.scavcan.unknown") and language.GetPhrase("scav.scavcan.notarget") or language.GetPhrase("scav.scavcan.death"), "ScavScreenFont", 128, 20 + vpos, col, TEXT_ALIGN_CENTER)
	end
end

		do
			local tab = {}
				tab.Name = "#scav.scavcan.medigun"
				tab.chargeanim = ACT_VM_FIDGET
				tab.Level = 6
				local identify = {} --all mediguns are the same
				tab.Identify = setmetatable(identify, {__index = function() return 0 end})
				tab.Cooldown = 0.01
				function tab.ChargeAttack(self, item)
					if SERVER then
						self:SetBlockPoseInstant(1, 1)
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
				function tab.FireFunc(self, item)
					if SERVER then
						self.ef_medigun = self:CreateToggleEffect("scav_stream_medigun")
						self:SetNWFiremodeEnt(NULL)
					else
						tab.targetname = nil
						tab.targetent = nil
					end
					self:SetChargeAttack(tab.ChargeAttack, item)
					return false
				end
				if CLIENT then
					tab.Screen = medigunscreen
					tab.ScreenFiring = medigunscreen
				end
			--TF2
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_medigun/c_medigun.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_medigun.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_proto_backpack/c_proto_backpack.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_medigun_defense/c_medigun_defense.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_medigun_defense/c_medigun_defensepack.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_medigun_defense/c_medigun_defense.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_medigun_defense/c_medigun_defensepack.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/buildables/dispenser.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/buildables/dispenser_light.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/buildables/dispenser_lvl2.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/buildables/dispenser_lvl2_light.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/buildables/dispenser_lvl3.mdl", SCAV_SHORT_MAX)
			ScavData.RegisterFiremode(tab, "models/buildables/dispenser_lvl3_light.mdl", SCAV_SHORT_MAX)
			--ASW
			ScavData.RegisterFiremode(tab, "models/weapons/healgun/healgun.mdl", SCAV_SHORT_MAX)
		end

--[[==============================================================================================
	--Recycle Bin
==============================================================================================]]--

local recyclescreen = function(self, item)
	if not IsValid(self) or not item then return end

	local tab = item.GetFiremodeTable and item:GetFiremodeTable() or nil

	if not tab then return end

	local on = tab.On
	
	DrawScreenBKG(on and greenscr or redscr)

	local vpos = 12
	local fontsize = "ScavScreenFontSm"
	if #language.GetPhrase("scav.scavcan.recycling") > 14 then
		fontsize = "ScavScreenFontSmX"
		vpos = vpos + 8
	end
	local _, use = math.modf(CurTime())
	local col = color_black
	if not on and use < .5 then
		col = color_white
	end
	draw.DrawText(language.GetPhrase("scav.scavcan.recycling"), fontsize, 128, vpos, col, TEXT_ALIGN_CENTER)
	draw.DrawText(language.GetPhrase(on and "scav.scavcan.on" or "scav.scavcan.off"), "ScavScreenFont", 128, 20 + vpos, col, TEXT_ALIGN_CENTER)
end
	
		local tab = {}
			tab.Name = "#scav.scavcan.recyclebin"
			tab.anim = ACT_VM_IDLE
			tab.Level = 2
			tab.On = true
			if CLIENT then
				tab.Screen = recyclescreen
			end
			tab.FireFunc = function(self, item)
				tab.On = not tab.On
				if SERVER then
					self.Owner:EmitSound(tab.On and "buttons/button5.wav" or "buttons/button8.wav")
				end
				return false
			end
			tab.Cooldown = 0.25
		ScavData.RegisterFiremode(tab, "models/props_junk/trashbin01a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_trainstation/trashcan_indoor001a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_trainstation/trashcan_indoor001b.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_junk/trashcluster01a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_junk/trashdumpster01a.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_junk/trashdumpster02.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_lab/plotter.mdl", SCAV_SHORT_MAX)
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_office/trash_can_p.mdl", SCAV_SHORT_MAX)
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_2fort/wastebasket01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_soho/trashbag001.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_frontline/dumpster.mdl", SCAV_SHORT_MAX)
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_interiors/trashcan01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_interiors/trashcankitchen01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_junk/dumpster.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_junk/dumpster_2.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_junk/trashcluster01a_corner.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_street/garbage_can.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_street/garbage_can_static.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_street/trashbin01.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_unique/airport/trash_bin1.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_urban/garbage_can001.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_urban/garbage_can002.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_urban/dumpster001.mdl", SCAV_SHORT_MAX)
		--ASW
		ScavData.RegisterFiremode(tab, "models/props/furniture/misc/bathroombin.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/env/ryberg/outside/dumpster/dumpster.mdl", SCAV_SHORT_MAX)
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_generic/trashbin002.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_canteen/canteenbin.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_junk/refusebin.mdl", SCAV_SHORT_MAX)
		ScavData.RegisterFiremode(tab, "models/props_office/metalbin01.mdl", SCAV_SHORT_MAX)

--[[==============================================================================================
	-- Punish Prop Virus
==============================================================================================]]--
		if SERVER then
			util.AddNetworkString("ScavVirusEffect")
			PrecacheParticleSystem("scav_virus")
		else
			net.Receive("ScavVirusEffect", function()
				local owner = net.ReadPlayer()
				local ent = net.ReadEntity()
				if not IsValid(ent) then return end
				--Particle effect adjusts some based on prop's size
				local mins, maxs = ent:GetModelRenderBounds()
				local cpoint0 = {}
					cpoint0.entity = ent
					cpoint0.attachtype = PATTACH_ABSORIGIN_FOLLOW
					cpoint0.position = mins
				local cpoint1 = {}
					cpoint1.entity = ent
					cpoint1.attachtype = PATTACH_ABSORIGIN_FOLLOW
					cpoint1.position = maxs
				local part = ent:CreateParticleEffect("scav_virus", {cpoint0, cpoint1})
				if not IsValid(part) then return end
				part:SetControlPointEntity(0, ent)
				part:SetControlPointEntity(1, ent)
				ent.ScavVirusParticle = part
			end)
		end
		
		local tab = {}
			tab.Name = "#scav.scavcan.virus"
			tab.anim = ACT_VM_IDLE
			tab.Level = 7
			local identify = {
				--[Default] = 0,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			if SERVER then
				tab.FireFunc = function(self, item)
					local tab = ScavData.models[item.ammo]
					if not IsValid(self.Owner) then return false end
					local tracep = {}
						tracep.start = self.Owner:GetShootPos()
						tracep.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 128
						tracep.filter = self.Owner
						tracep.mask = bit.bor(MASK_SOLID, CONTENTS_DEBRIS) --MASK_SOLID_BRUSHONLY
					local tr = util.TraceLine(tracep)

					if not IsValid(tr.Entity) or not self.Owner:CanScavPickup(tr.Entity) or tr.Entity.ScavVirus == self.Owner then tab.Cooldown = 2 return false end

					tr.Entity.ScavVirus = self.Owner

					tab.Cooldown = 5
					--Send our longer cooldown to the client
					net.Start("scv_s_time")
						net.WriteEntity(self)
						local fulltime, decimaltime = math.modf(CurTime(), 1)
						net.WriteInt(fulltime + tab.Cooldown, 32)
						net.WriteFloat(decimaltime)
					net.Send(self.Owner)

					--Only show effect for us/allies
					net.Start("ScavVirusEffect")
						net.WritePlayer(self.Owner)
						net.WriteEntity(tr.Entity)
						local ownteam = self.Owner:Team()
					net.Send(ownteam ~= TEAM_UNASSIGNED and team.GetPlayers(ownteam) or self.Owner)

					return self:TakeSubammo(item, 1)
				end
				--TF2
				ScavData.CollectFuncs["models/weapons/w_models/w_sapper.mdl"] = function(self, ent) return {{self.christmas and "models/weapons/c_models/c_sapper/c_sapper_xmas.mdl" or ScavData.FormatModelname(ent:GetModel()), 1, self.christmas and math.random(0, 1) or 0}} end
				ScavData.CollectFuncs["models/weapons/c_models/c_sapper/c_sapper.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sapper.mdl"]
				ScavData.CollectFuncs["models/buildables/sapper_dispenser.mdl"] = ScavData.CollectFuncs["models/weapons/w_models/w_sapper.mdl"]
			end
			tab.Cooldown = 2
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_sapper.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_sd_sapper.mdl")
		ScavData.RegisterFiremode(tab, "models/buildables/sd_sapper_dispenser.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/weapons/c_models/c_sd_sapper/c_sd_sapper.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_sapper/c_sapper.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_sapper/c_sapper_xmas.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_breadmonster_sapper/c_breadmonster_sapper.mdl")
		ScavData.RegisterFiremode(tab, "models/buildables/gibs/sapper_gib001.mdl")
		ScavData.RegisterFiremode(tab, "models/buildables/gibs/sapper_gib002.mdl")
		ScavData.RegisterFiremode(tab, "models/buildables/gibs/sd_sapper_gib001.mdl")
		ScavData.RegisterFiremode(tab, "models/buildables/gibs/sd_sapper_gib002.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/buildables/gibs/sd_sapper_gib001.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop_partner/buildables/gibs/sd_sapper_gib002.mdl")
		ScavData.RegisterFiremode(tab, "models/buildables/sapper_dispenser.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_grenade_emp.mdl")

		--The Virus "item" (the scav gun is locked until these are removed)
		local tab = {}
			tab.Name = "#scav.scavcan.virus"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {
				--[Default] = 0,
			}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end})
			tab.FireFunc = function(self, item)
				return false
			end
			tab.Cooldown = 1
		if SERVER then
			util.AddNetworkString("ScavVirusScreen")

			tab.PostRemove = function(self, item)
				for _, v in ipairs(self.inv.items) do
					if v == item then continue end
					local info = v:GetFiremodeInfo()
					if not info or info.Name ~= "#scav.scavcan.virus" then continue end
					self.Owner:EmitSound("buttons/button18.wav")
					return
				end
				--All clear, unlock
				self.Owner:EmitSound("buttons/button24.wav")
				self:Lock(self.startlock, CurTime())
				net.Start("ScavVirusScreen")
					net.WriteBool(false)
				net.Send(self.Owner)
			end
			local giggle = "npc/moustachio/strengthattract09.wav"
			if not L4D2 then
				if TF2 then giggle = "items/halloween/gremlin03.wav"
				else giggle = "vo/citadel/br_laugh01.wav" end
			end
			ScavData.CollectFuncs["models/scav/virus.mdl"] = function(self, ent)
				net.Start("ScavVirusScreen")
					net.WriteBool(true)
				net.Send(self.Owner)
				if not IsValid(self) or not self.inv then return end
				local entmodel = "models/scav/virus.mdl"
				--replace any items with a firemode level above 3 with another copy of the virus
				for k, v in ipairs(self.inv.items) do
					local info = v:GetFiremodeInfo()
					if not info or info.Level <= 3 then continue end
					self:RemoveItemValue(v)
					self:AddItem(entmodel, 1, 0, 1, k)
				end
				self:AddItem(entmodel, 1, 0)
				--update inventory on client
				self.inv:AddOnClient(self.Owner)
				self.Owner:EmitSound(giggle)
				self:Lock(CurTime() + 0.1, math.huge)
				return {}
			end
		else
			local scavvirus = Material("hud/scav_virus.vmt")
			net.Receive("ScavVirusScreen", function()
				if net.ReadBool() then
					hook.Add("ScavScreenDrawOverridePost", "ScavVirus", function(self)
						surface.SetMaterial(scavvirus)
						surface.SetDrawColor(255, 255, 255)
						local timings = {}
						setmetatable(timings, {__index = function(t, k)
							if tonumber(k) == 0 then return CurTime() % 1 end
							return CurTime() % (tonumber(k) or 1) / (tonumber(k) or 1)
						end})
						--put some virus spores on the screen
						surface.DrawTexturedRectRotated(200, 12, 48, 48, 360 * timings[45] - 45)
						surface.DrawTexturedRectRotated(230, 124, 256, 256, 360 * timings[75] + 15)
						surface.DrawTexturedRectRotated(-32 + 372 * timings[5], 16 * (1 + timings[5]), 64 * (0.5 + timings[5]), 64 * (0.5 + timings[5]), 360 * timings[15] - 120)
						surface.DrawTexturedRectRotated(0, 32, 200, 200, 360 * timings[50] + 30)
						surface.DrawTexturedRectRotated(290 - 372 * timings[7], 16 + 72 * timings[7], 80 * (0.5 + timings[7]), 80 * (0.5 + timings[7]), 360 * timings[15])
					end)
				else
					hook.Remove("ScavScreenDrawOverridePost", "ScavVirus")
				end
			end)
		end
		ScavData.RegisterFiremode(tab, "models/scav/virus.mdl")

--[[==============================================================================================
	--Extra Storage
==============================================================================================]]--
	
		local tab = {}
			tab.Name = "#scav.scavcan.storage"
			tab.anim = ACT_VM_IDLE
			tab.Level = 2
			tab.MaxAmmo = 1
			if SERVER then
				tab.FireFunc = function(self, item)
					if self:GetCapacity() >= 255 then
						self.Owner:EmitSound("physics/concrete/concrete_break3.wav")
						return false
					end
					self:SetCapacity(self:GetCapacity() + 1)
					if SERVER then
						self.Owner:EmitSound("physics/plastic/plastic_barrel_break2.wav")
					end
					return self:TakeSubammo(item, 1)
				end
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/weapons/scav/c_scavgun7.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/plasticcrate01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box001a_gib01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box001b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box002a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box002a_gib01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box002b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box003a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box003a_gib01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box003b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box003b_gib01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box004a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboard_box004a_gib01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/wood_crate001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/wood_crate001a_damaged.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/wood_crate001a_damagedmax.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/wood_crate002a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lab/box01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lab/box01b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/controlroom_filecabinet001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/controlroom_filecabinet002a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/controlroom_storagecloset001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/controlroom_storagecloset001b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lab/filecabinet02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lab/partsbin01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/wheebarrow01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/controlroom_desk001b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/furniture_vanity01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/furniturecupboard001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/furnituredrawer001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/furnituredrawer002a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/furnituredrawer003a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/furnituredresser001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/furnitureshelf001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_c17/lockers001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_combine/breendesk.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/furniture_cabinetdrawer01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/furniture_cabinetdrawer02a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/furniture_desk01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/furniture_shelf01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_forest/furniture_shelf01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_forest/shelves.mdl")
		ScavData.RegisterFiremode(tab, "models/props_forest/shelves_wood.mdl")
		ScavData.RegisterFiremode(tab, "models/props_forest/footlocker01_closed.mdl")
		ScavData.RegisterFiremode(tab, "models/props_forest/footlocker01_open.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/cargo_container01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/cargo_container01b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/cargo_container01c.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/kitchen_shelf001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/kitchen_shelf002a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_wasteland/prison_shelf002a.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_assault/dryer_box.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_assault/dryer_box2.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_assault/washer_box.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_assault/washer_box2.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/bar01.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/boxes_frontroom.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/boxes_garage.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/boxes_garage_lower.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/crate_extralargemill.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/crate_extrasmallmill.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/crate_stackmill.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/footlocker01_closed.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/footlocker01_open.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/cardboard_box01.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/cardboard_box02.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/cardboard_box03.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/crates_indoor.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/crates_outdoor.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/file_box.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/file_box_p1.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/file_box_p2.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/file_cabinet1.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/file_cabinet1_group.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/file_cabinet2.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_office/file_cabinet3.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_dust/du_crate_128x128.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_dust/du_crate_64x64.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_dust/du_crate_64x80.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_dust/du_crate_96x96.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_inferno/furnituredrawer001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_nuke/crate_extralarge.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_nuke/crate_extrasmall.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_nuke/crate_large.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_nuke/crate_small.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_nuke/file_cabinet1_group.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_prodigy/prodcratesa.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_prodigy/prodcratesb.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_train/lockers001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props/de_train/lockers_long.mdl")
		ScavData.RegisterFiremode(tab, "models/props_industrial/warehouse_shelf001.mdl")
		ScavData.RegisterFiremode(tab, "models/props_industrial/warehouse_shelf002.mdl")
		ScavData.RegisterFiremode(tab, "models/props_industrial/warehouse_shelf003.mdl")
		ScavData.RegisterFiremode(tab, "models/props_industrial/warehouse_shelf004.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/props_2fort/miningcrate001.mdl")
		ScavData.RegisterFiremode(tab, "models/props_2fort/miningcrate002.mdl")
		ScavData.RegisterFiremode(tab, "models/props_2fort/gibs/miningcrate001_break01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_farm/box_cluster01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_farm/box_cluster02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_farm/box_cluster03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_farm/gibs/shelf_props01_gib_box01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_farm/gibs/shelf_props01_gib_box02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_farm/gibs/shelf_props01_gib_box03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_farm/gibs/shelf_props01_gib_box04.mdl")
		ScavData.RegisterFiremode(tab, "models/props_forest/milk_crate.mdl")
		ScavData.RegisterFiremode(tab, "models/props_hydro/barrel_crate.mdl")
		ScavData.RegisterFiremode(tab, "models/props_hydro/barrel_crate_half.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mvm/barrel_crate.mdl")
		ScavData.RegisterFiremode(tab, "models/props_2fort/locker001.mdl")
		ScavData.RegisterFiremode(tab, "models/props_farm/gibs/shelf_props01_gib_intact.mdl")
		ScavData.RegisterFiremode(tab, "models/props_island/mannco_case_large.mdl")
		ScavData.RegisterFiremode(tab, "models/props_island/mannco_case_small.mdl")
		ScavData.RegisterFiremode(tab, "models/props_island/op_cabinet01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_island/op_cabinet02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_island/small_yeti_container01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_lakeside/wood_crate_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_manor/cardboard_box_set_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_manor/cardboard_box_set_02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_soho/bottlecrate001.mdl")
		ScavData.RegisterFiremode(tab, "models/props_swamp/crate_ref.mdl")
		ScavData.RegisterFiremode(tab, "models/props_urban/urban_shipping_container01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_urban/urban_shipping_container02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/train_flatcar_container.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/train_flatcar_container_01b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/train_flatcar_container_01c.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/train_flatcar_container_01d.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_downtown/bar.mdl")
		ScavData.RegisterFiremode(tab, "models/props_downtown/bathroom_vanity01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_downtown/dresser.mdl")
		ScavData.RegisterFiremode(tab, "models/props_downtown/side_table.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/cargo_container01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/cargo_container01_fixed.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/cargo_container02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/cargo_container03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/cargo_container04.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/cart_utility_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/toolchest_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/tsabin_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/cafe_cabinet1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/bookcase_48_96.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/bookcase_64_96.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/bookcasehutch01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/clipboardwallpocket01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/desk_executive.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/desk_metal.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/desk_motel.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/dresser_short.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/dresser_tall.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/entertainment_unit.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/file_cabinet1_group.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/gun_cabinet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/magazinestand01_empty.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/paper_tray.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/shelvinggrocery01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/shelvingstore01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/table_bedside.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/table_console.mdl")
		ScavData.RegisterFiremode(tab, "models/props_interiors/tv_cabinet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/wheelbarrow01a_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/information_desk.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_counter_corner.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_counter_entrance.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_counter_long.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_counter_short.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_display_04.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_display_05.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_display_07.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_display_08.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_display_09.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_display_10.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_kiosk.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_kioskb.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_kioskc.mdl")
		ScavData.RegisterFiremode(tab, "models/props_mall/mall_register.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/desk_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/filecabinet01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/filecabinet01group.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/file_cabinet_03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/caboose01_drawer01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/guncabinet01_main.mdl")
		ScavData.RegisterFiremode(tab, "models/props_unique/spawn_apartment/boxes_rooftop.mdl")
		ScavData.RegisterFiremode(tab, "models/props_urban/plastic_bucket001.mdl")
		ScavData.RegisterFiremode(tab, "models/props_vehicles/airport_baggage_cart2.mdl")
		--Portal
		ScavData.RegisterFiremode(tab, "models/props/lab_desk01/lab_desk01.mdl")
		ScavData.RegisterFiremode(tab, "models/props/lab_desk05/lab_desk05.mdl")
		ScavData.RegisterFiremode(tab, "models/props/lab_shelf/lab_shelf.mdl")
		ScavData.RegisterFiremode(tab, "models/props/lab_shelf_small/lab_shelf_small.mdl")
		ScavData.RegisterFiremode(tab, "models/props/shelf128/shelf128.mdl")
		--Portal 2
		ScavData.RegisterFiremode(tab, "models/br_debris/deb_dave_crate.mdl")
		ScavData.RegisterFiremode(tab, "models/br_debris/deb_dave_crate_broken_body_01.mdl")
		ScavData.RegisterFiremode(tab, "models/br_debris/deb_handheld_crate.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/cabinet_small_door.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/cabinet_small_drawers.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/cardboardbox_a_1970.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/cardboardbox_b_1970.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/cardboardbox_c_1970.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/cubicle_desk_drawers.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/file_cabient_1970.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/filebox_1980.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/office_desk_1970.mdl")
		ScavData.RegisterFiremode(tab, "models/props_underground/filecabinet_lobby.mdl")
		--DoD:S
		ScavData.RegisterFiremode(tab, "models/props_crates/static_crate_40.mdl")
		ScavData.RegisterFiremode(tab, "models/props_crates/static_crate_48.mdl")
		ScavData.RegisterFiremode(tab, "models/props_crates/static_crate_64.mdl")
		ScavData.RegisterFiremode(tab, "models/props_crates/supply_crate01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_crates/supply_crate01_gib1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_crates/supply_crate02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_crates/supply_crate02_gib1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_crates/supply_crate03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/bakery_counter1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/bakery_counter2.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/bakery_counter3.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/cabinet_large.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/cupboard1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/desk1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/drawer1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/drawer1_gib1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/drawer1_gib2.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/drawer2.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/drawer3.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/drawer3_gib2.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/drawer4.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/dresser1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/inn_frontdesk1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/inn_mailbox1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/kitchen_cabinet1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/kitchen_countertop1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/kitchen_shelf1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/nightstand_large.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/nightstand_small.mdl")
		ScavData.RegisterFiremode(tab, "models/props_furniture/shelf1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_misc/basket-1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_misc/basket-1_gib1.mdl")
		--ASW
		ScavData.RegisterFiremode(tab, "models/props/crates/container01.mdl")
		ScavData.RegisterFiremode(tab, "models/swarmprops/barrelsandcrates/cardbox1.mdl")
		ScavData.RegisterFiremode(tab, "models/swarmprops/barrelsandcrates/cardbox1breakable.mdl")
		ScavData.RegisterFiremode(tab, "models/swarmprops/barrelsandcrates/metalcrate2mesh.mdl")
		--FoF
		ScavData.RegisterFiremode(tab, "models/props/barrel_self.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cargo1.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cargo2.mdl")
		ScavData.RegisterFiremode(tab, "models/props/crate_32.mdl")
		ScavData.RegisterFiremode(tab, "models/props/crate_32_iron.mdl")
		ScavData.RegisterFiremode(tab, "models/props/crate_64.mdl")
		ScavData.RegisterFiremode(tab, "models/props/crate_64_iron.mdl")
		ScavData.RegisterFiremode(tab, "models/monastery/crate1.mdl")
		ScavData.RegisterFiremode(tab, "models/monastery/crate2.mdl")
		ScavData.RegisterFiremode(tab, "models/monastery/crate3.mdl")
		--BMS
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/tarp_crate.mdl")
		ScavData.RegisterFiremode(tab, "models/props_generic/crate_128x36.mdl")
		ScavData.RegisterFiremode(tab, "models/props_generic/crate_144x60.mdl")
		ScavData.RegisterFiremode(tab, "models/props_generic/crate_36x36.mdl")
		ScavData.RegisterFiremode(tab, "models/props_generic/crate_48x48.mdl")
		ScavData.RegisterFiremode(tab, "models/props_generic/crate_64x96.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/file_box.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/file_box_bottom.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox01b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox04.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox05.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox06.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox07.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/cardboardbox08a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/warehouse_pallet02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/warehouse_pallet02_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/warehouse_pallet03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/warehouse_pallet03_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/warehouse_pallet04.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/warehouse_pallet04_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_questionableethics/qe_kitchen_bar.mdl")
		ScavData.RegisterFiremode(tab, "models/props_questionableethics/qe_kitchen_left.mdl")
		ScavData.RegisterFiremode(tab, "models/props_questionableethics/qe_kitchen_right.mdl")
		ScavData.RegisterFiremode(tab, "models/props_questionableethics/qe_lab_cab_angled.mdl")
		ScavData.RegisterFiremode(tab, "models/props_questionableethics/qe_lab_cab_island.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_breakroom_cab.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_lab1_cab_island.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_lab1_cab_l.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_lab1_cab_med1.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_lab1_cab_med2.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_lab2_cab_hood.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_lab2_cab_lg.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_lab2_cab_sm.mdl")
		ScavData.RegisterFiremode(tab, "models/props_am/am_lab3_cab_l.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_metalcrate_36x36.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_metalcrate_48x48.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_metalcrate_64x96.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/bms_metalcrate_tarp.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/metalcrate01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/metalcrate01_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/hardcase_01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/hardcase_01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/storagetrunk01a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_equipment/storagetrunk01b.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/paper_box.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/file_cabinet_03.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/file_cabinet_large.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/file_cabinet_large_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/filecabinet01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/filecabinet01group.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/officefilecabinet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_office/officefilecabinet_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_generic/storage_cabinet.mdl")
		ScavData.RegisterFiremode(tab, "models/props_generic/storage_cabinet_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/alicepack.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/ammobox01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/ammo_crate.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/ammo_crate02.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/ammo_crate02_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/ammocrate01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_marines/ammocrate01_static.mdl")
		ScavData.RegisterFiremode(tab, "models/props_blackmesa/shelves01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/vegbox01.mdl")
		