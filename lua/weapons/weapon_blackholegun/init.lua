AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("gravball.lua")
AddCSLuaFile("waypointwarning.lua")
AddCSLuaFile("pickup.lua")

include("shared.lua")
SWEP.FirstDeploy = true

function SWEP:OwnerChanged()
	self.FirstDeploy = true
end

function SWEP:AddWaypoint(ent,localpos,forcepoint)
	if ent == NULL then
		return
	end
	if not ent:IsWorld() then
		for k,v in pairs(self.WayPoints) do
			if v.Entity == ent then
				return
			end
		end
	end
	if not forcepoint and (self:GetWaypointCount() >= self:GetMaxWaypoints()) then
		self.Owner:EmitSound("buttons/button16.wav")
		return
	end
	
	local marker = ents.Create("scav_bhg_warning")
	if ent:IsWorld() then
		marker:SetPos(localpos)
	else
		marker:SetParent(ent)
		marker:SetLocalPos(localpos)
	end
	marker:SetOwner(self.Owner)
	marker.BHG = self
	marker:Spawn()
	local lastwaypoint = self:GetwaypointNext() --we'll start trying to find the last waypoint in our path from the very beginning, checking the references and advancing down the path until we hit NULL
	if IsValid(lastwaypoint) then
		for current in self:WaypointIterate() do
			lastwaypoint = current
		end
		--now that the iteration is over, we've found our last waypoint in the path, so fix up the references for that waypoint and the new one
		lastwaypoint:SetwaypointNext(marker)
		marker:SetwaypointPrevious(lastwaypoint)
	else
		self:SetwaypointNext(marker) --we have no waypoints at all, so we'll put the new one at the start
		marker:SetwaypointPrevious(self)
	end
	if IsValid(self.ChargeEffect) then
		self.ChargeEffect:SetLastWaypointSet(CurTime())
	end
	self:EmitSound("npc/scanner/scanner_nearmiss2.wav")
	if ent:IsWorld() then
		sound.Play("npc/scanner/scanner_nearmiss2.wav",localpos)
	else
		ent:EmitSound("npc/scanner/scanner_nearmiss2.wav")
	end
	self:RecalculateWaypointCount()
	self:CallOnClient("OnWaypointUpdate","")
end

function SWEP:RecalculateWaypointCount()
	local waypointcount = 0
	for current in self:WaypointIterate() do
		waypointcount = waypointcount+1
	end
	self:SetWaypointCount(waypointcount)
end

function SWEP:DestroyWaypoints()
	for current in self:WaypointIterate() do
		SafeRemoveEntityDelayed(current,0.1)
	end
end

function SWEP:DetachFromWaypointPath()
	for current in self:WaypointIterate() do
		current.BHG = NULL
	end
	self:SetwaypointNext(NULL)
	self:SetWaypointCount(0)
end

function SWEP:AddAmmo(amt)
	self:SetNWAmmo(math.min(self:GetNWAmmo()+amt,self:GetNWMaxAmmo()))
end

function SWEP:CheckCanScav(ent)
	if (self:GetNWAmmo() < self:GetNWMaxAmmo()) and self.Owner:CanScavPickup(ent) then
		return true
	end
	return false
end


function SWEP:Scavenge(ent)
	local modelname = ScavData.FormatModelname(ent:GetModel())
	ent.NoScav = true
	local ef = EffectData()
	ef:SetRadius(ent:OBBMaxs():Distance(ent:OBBMins())/2)
	ef:SetEntity(self.Owner)
	ef:SetOrigin(ent:GetPos())
	util.Effect("scav_pickup",ef,nil,true)
	local pickup = ents.Create("scav_bhg_pickup")
	pickup:SetModel(ent:GetModel())
	pickup:SetPos(ent:GetPos())
	pickup:SetAngles(ent:GetAngles())
	pickup:Spawn()
	self:AddAmmo(ent:GetPhysicsObject():GetMass())
	ent:Remove()
end
