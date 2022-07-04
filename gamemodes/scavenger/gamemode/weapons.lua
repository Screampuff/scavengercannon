local weps = {
"weapon_backuppistol",
"weapon_blackholegun",
"weapon_alchemygun"
}

function GM:GetValidWeapons()
	return weps
end

if CLIENT then
	hook.Add("InitPostEntity","wepslots",function()
		for k,v in pairs(weps) do
			local SWEP = weapons.GetStored(v)
			SWEP.Slot = 1
			SWEP.SlotPos = 0
		end
	end)
else
	function GM:PlayerLoadout(pl)
		local wep = string.lower(pl:GetInfo("sdm_w2"))
		if table.HasValue(weps,wep) then
			pl:Give(wep)
		else
			pl:Give("weapon_backuppistol")
		end
		pl:Give("scav_gun")
		pl:SelectWeapon("scav_gun")
	end
end