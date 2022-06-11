function resource.AddDirectory(folder)
	for _,v in ipairs(file.Find(folder.."*","GAME"), true) do
		if !string.find(v,"svn") then
			resource.AddFile(folder..v)
		end
	end
end

resource.AddDirectory("models/scav/")
resource.AddDirectory("models/weapons/scav/")
resource.AddDirectory("materials/models/scav/")
resource.AddDirectory("materials/models/weapons/alchemygun/")
resource.AddDirectory("materials/models/weapons/backuppistol/")
resource.AddDirectory("materials/models/weapons/blackholegun/")
resource.AddDirectory("materials/models/weapons/scavenger/")
resource.AddDirectory("materials/hud/alchemy_gun/")
resource.AddDirectory("materials/hud/status/")
resource.AddDirectory("materials/vgui/sgskin/")

resource.AddSingleFile("resource/fonts/inconsolata.ttf")

resource.AddSingleFile("particles/scav_particles93.pcf")
resource.AddSingleFile("particles/scav_muzzleflashes.pcf")
resource.AddSingleFile("particles/scav_altguns4.pcf")

resource.AddSingleFile("sound/weapons/scav_gun/chargeup.wav")
resource.AddSingleFile("sound/weapons/scav_gun/explosion.wav")
resource.AddSingleFile("sound/weapons/scav_gun/pickup.wav")

resource.AddSingleFile("models/items/powerup_speed.dx80.vtx")
resource.AddSingleFile("models/items/powerup_speed.dx90.vtx")
resource.AddSingleFile("models/items/powerup_speed.mdl")
resource.AddSingleFile("models/items/powerup_speed.phy")
resource.AddSingleFile("models/items/powerup_speed.sw.vtx")
resource.AddSingleFile("models/items/powerup_speed.vvd")

resource.AddSingleFile("models/items/ammo/frag12round.dx80.vtx")
resource.AddSingleFile("models/items/ammo/frag12round.dx90.vtx")
resource.AddSingleFile("models/items/ammo/frag12round.mdl")
resource.AddSingleFile("models/items/ammo/frag12round.phy")
resource.AddSingleFile("models/items/ammo/frag12round.sw.vtx")
resource.AddSingleFile("models/items/ammo/frag12round.vvd")

resource.AddSingleFile("materials/hud/bhg_crosshair_corner.vtf")
resource.AddSingleFile("materials/hud/bhg_crosshair_corner.vmt")
resource.AddSingleFile("materials/hud/scav_crosshair_bg.vmt")
resource.AddSingleFile("materials/hud/scav_crosshair_brace.vtf")
resource.AddSingleFile("materials/hud/scav_crosshair_brace.vmt")
resource.AddSingleFile("materials/hud/scav_crosshair_corner.vtf")
resource.AddSingleFile("materials/hud/scav_crosshair_corner.vmt")
resource.AddSingleFile("materials/hud/weapons/scav_gun.vmt")
resource.AddSingleFile("materials/hud/weapons/scav_gun.vtf")
resource.AddSingleFile("materials/hud/weapons/weapon_alchemygun.vmt")
resource.AddSingleFile("materials/hud/weapons/weapon_alchemygun.vtf")
resource.AddSingleFile("materials/hud/weapons/weapon_backuppistol.vmt")
resource.AddSingleFile("materials/hud/weapons/weapon_backuppistol.vtf")
resource.AddSingleFile("materials/hud/weapons/weapon_blackholegun.vmt")
resource.AddSingleFile("materials/hud/weapons/weapon_blackholegun.vtf")

resource.AddSingleFile("materials/models/items/sdm/proxmine.vmt")
resource.AddSingleFile("materials/models/items/sdm/proxmine.vtf")
resource.AddSingleFile("materials/models/items/sdm/proxmine_normal.vtf")
resource.AddSingleFile("materials/models/items/sdm/tankshell.vmt")
resource.AddSingleFile("materials/models/items/sdm/tankshell.vtf")
resource.AddSingleFile("materials/models/items/ammo/frag12round.vmt")
resource.AddSingleFile("materials/models/items/ammo/frag12round.vtf")

resource.AddSingleFile("materials/models/scavplasma.vmt")

resource.AddSingleFile("materials/effects/blank.vmt")
resource.AddSingleFile("materials/effects/blank.vtf")
resource.AddSingleFile("materials/effects/bladetrail.vmt")
resource.AddSingleFile("materials/effects/scav_elec1.vmt")
resource.AddSingleFile("materials/effects/scav_elecarc.vtf")
resource.AddSingleFile("materials/effects/scav_elecarc1.vmt")
resource.AddSingleFile("materials/effects/scav_shine_hr.vmt")
resource.AddSingleFile("materials/effects/scav_shine_hr.vtf")
resource.AddSingleFile("materials/effects/scav_shine5.vmt")
resource.AddSingleFile("materials/effects/scav_shine5.vtf")
resource.AddSingleFile("materials/effects/scav_shine6.vmt")
resource.AddSingleFile("materials/effects/scav_shine6_noz.vmt")
resource.AddSingleFile("materials/effects/scav_strider1.vmt")
resource.AddSingleFile("materials/effects/scav_strider_bulge.vmt")
resource.AddSingleFile("materials/effects/scav_strider_pinch.vmt")
resource.AddSingleFile("materials/effects/scav_white.vtf")

resource.AddSingleFile("materials/particle/scav_health.vmt")
resource.AddSingleFile("materials/particle/scav_health.vtf")
resource.AddSingleFile("materials/particle/particle_ring_wave_noz.vmt")

resource.AddSingleFile("materials/sprites/bpist_tr1.vmt")
resource.AddSingleFile("materials/sprites/scav_strider1.vmt")
resource.AddSingleFile("materials/sprites/scav_tr_phys.vmt")

resource.AddSingleFile("materials/vgui/nomapicon.vmt")
resource.AddSingleFile("materials/vgui/nomapicon.vtf")
resource.AddSingleFile("materials/vgui/scavlogo1.vmt")
resource.AddSingleFile("materials/vgui/scavlogo1.vtf")