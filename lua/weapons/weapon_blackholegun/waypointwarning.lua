local ENT = {}
ENT.Type = "anim"
ENT.Base = "base_anim"

PrecacheParticleSystem("scav_bhg_warning")

local playerspecificthink
if SERVER then
	function playerspecificthink(self)
		if self:GetParent():IsPlayer() && !self:GetParent():Alive() then
			self:Remove()
		end
	end
end

function ENT:Initialize()
	self:AddEffects(EF_NOSHADOW)
	if CLIENT then
		ParticleEffectAttach("scav_bhg_warning",PATTACH_ABSORIGIN_FOLLOW,self,0)
		local pl = LocalPlayer()
		local wep = pl:GetActiveWeapon()
		if (self:GetOwner() == pl) && IsValid(wep) && (wep:GetClass() == "weapon_bhg") then
			wep.waypointtime = CurTime()
		end
	else
		if IsValid(self:GetParent()) && self:GetParent():IsPlayer() then
			self.Think = playerspecificthink
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()
	self:DTVar("Entity",0,"waypointPrevious")
	self:DTVar("Entity",1,"waypointNext")
end

if SERVER then
	local SWEP = SWEP
	function ENT:DestroyPath()
		for current in SWEP.WaypointIterate(self) do
			SafeRemoveEntityDelayed(current,0)
		end
		SafeRemoveEntityDelayed(self,0)
	end
	
	function ENT:OnRemove()
		if IsValid(self.dt.waypointPrevious) && IsValid(self.dt.waypointNext) then
			self.dt.waypointPrevious.dt.waypointNext = self.dt.waypointNext
			self.dt.waypointNext.dt.waypointPrevious = self.dt.waypointPrevious
		end
		if IsValid(self.BHG) then
			self.BHG:RecalculateWaypointCount()
		end
		if IsValid(self.GravBall) && self.dt.waypointNext then
			self.GravBall:SetWaypoint(self.dt.waypointNext)
		end
	end
end

if CLIENT then
	local chargemat = Material("effects/scav_shine_HR")
	local glowcol = Color(255,128,128,255)
	//local lasercol = Color(255,0,0,255)
	local beammat = Material("trails/laser")
	
	function ENT:GetGlowScale()
		if self.Killed then
			return 0
		end
		local ctime = CurTime()
		local refvar = self.Created
		local scale = math.max(0,math.Round(64*(math.abs(math.sin(ctime*64))+1)))
		return scale
	end
	
	function ENT:Draw()
		local pos = self:GetPos()
		render.SetMaterial(chargemat)
		if IsValid(self.dt.waypointNext) then
			render.DrawBeam(pos,self.dt.waypointNext:GetPos(),3,0,1,glowcol)
		end
		local scale = 64
		render.DrawSprite(pos,scale,scale,glowcol)
	end
end

scripted_ents.Register(ENT,"scav_bhg_warning",true)