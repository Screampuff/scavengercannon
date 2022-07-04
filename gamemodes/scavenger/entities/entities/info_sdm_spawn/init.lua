ENT.Type = "point"
ENT.Team = TEAM_UNASSIGNED
local vec_down = Vector(0,0,-128)
local vec_up = Vector(0,0,72)
local tracetab = {}
tracetab.mins = Vector(-16,-16,0)
tracetab.maxs = Vector(16,16,0)


function ENT:Initialize()
	tracetab.start = self:GetPos()
	tracetab.endpos = self:GetPos()+vec_down
	local tr = util.TraceHull(tracetab)
	if tr.Hit then
		self:SetPos(tr.HitPos)
	end
end

function ENT:KeyValue(key,value)
	key = string.lower(key)
	if key == "team" then
		value = team.ToTeamID(value)
		self.Team = tonumber(value)
	end
end

function ENT:CheckOccupied() --Checks for an entity occupying the spawn position, returns the hit entity, null if unoccupied
	tracetab.start = self:GetPos()
	tracetab.endpos = self:GetPos()+vec_up
	local tr = util.TraceHull(tracetab)
	return tr.Entity
end

function ENT:PlayerCanSpawn(pl)
	if (pl:Team() ~= self.Team) and (pl:Team() ~= TEAM_SPECTATOR) then
		return false
	end
	local ent = self:CheckOccupied()
	return ent == NULL
end

function ENT:SpawnFrag(attacker)
	local ent = self:CheckOccupied()
	if IsValid(ent) then
		if ent:IsPlayer() then
			ent:Kill()
		else
			local dmg = DamageInfo()
			dmg:SetDamagePosition(self:GetPos())
			dmg:SetAttacker(attacker or self)
			dmg:SetInflictor(self)
			dmg:SetDamageType(DMG_GENERIC)
			dmg:SetDamage(1000)
		end
	end
end
