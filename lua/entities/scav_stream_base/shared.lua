ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Player = NULL
ENT.ViewMode = false

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self.Weapon = self:GetOwner()
	self.Player = self:GetOwner():GetOwner()
	
	self:SetPos(self.Player:GetPos())
	self:SetParent(self:GetOwner())
	self:AddEffects(EF_NOSHADOW)
	self:OnInit()
	if CLIENT then
		if (self.Player == GetViewEntity()) then
			self:OnViewMode()
			self.ViewMode = true
		else
			self:OnWorldMode()
		end
	end
	self.Created = CurTime()
end

function ENT:SetupDataTables()
	self:DTVar("Float",3,"DeathTime")
	self:OnSetupDataTables()
end

function ENT:OnSetupDataTables()
end

function ENT:AngPos()
	return {["Pos"] = self:GetPos(), ["Ang"] = self:GetAngles()}
end

function ENT:GetMuzzlePosAng()
	local pl = self.Player
	if !IsValid(pl) || !IsValid(pl:GetActiveWeapon()) then
		return self:AngPos()
	end
	if CLIENT && (pl == GetViewEntity()) then
		local vm = pl:GetViewModel()
		local angpos = vm:GetAttachment(vm:LookupAttachment("muzzle"))||self:AngPos()
		if self.PosOffset then
			local right = angpos.Ang:Right()
			local up = angpos.Ang:Up()
			local forward = angpos.Ang:Forward()
			local offset = forward*self.PosOffset.x+right*self.PosOffset.y+up*self.PosOffset.z
			angpos.Pos = angpos.Pos+offset
		end
		if self.AngOffset then
			local right = angpos.Ang:Right()
			angpos.Ang:RotateAroundAxis(right,self.AngOffset.p)
			local up = angpos.Ang:Up()
			angpos.Ang:RotateAroundAxis(up,self.AngOffset.y)
			local forward = angpos.Ang:Forward()
			angpos.Ang:RotateAroundAxis(forward,self.AngOffset.r)
		end
		return angpos
	else
		local wep = pl:GetActiveWeapon()
		local angpos = wep:GetAttachment(wep:LookupAttachment("muzzle"))||self:AngPos()
		if self.PosOffset then
			local right = angpos.Ang:Right()
			local up = angpos.Ang:Up()
			local forward = angpos.Ang:Forward()
			local offset = forward*self.PosOffset.x+right*self.PosOffset.y+up*self.PosOffset.z
			angpos.Pos = angpos.Pos+offset
		end
		if self.AngOffset then
			local right = angpos.Ang:Right()
			local up = angpos.Ang:Up()
			local forward = angpos.Ang:Forward()
			angpos.Ang:RotateAroundAxis(right,self.AngOffset.p)
			angpos.Ang:RotateAroundAxis(up,self.AngOffset.y)
			angpos.Ang:RotateAroundAxis(forward,self.AngOffset.r)
		end
		return angpos
	end
	return self:AngPos()
end

function ENT:GetShootPos()
	if IsValid(self.Player) then
		return self.Player:GetShootPos()
	else
		return self:GetPos()
	end
end

function ENT:GetAimVector()
	if IsValid(self.Player) then
		return self.Player:GetAimVector()
	else
		return self:GetAngles():Forward()
	end
end

function ENT:GetViewModel(index)
	return self.Player:GetViewModel(index)
end

function ENT:GetPlayer()
	return self.Player
end

function ENT:OnInit()
end

function ENT:OnThink()
end

local tracep = {}
tracep.mask = MASK_SHOT

function ENT:GetTrace(length,filter,mins,maxs,mask)
	tracep.start = self.Player:GetShootPos()
	tracep.endpos = tracep.start+self.Player:GetAimVector()*length
	tracep.filter = filter||self.Player
	tracep.mins = mins
	tracep.maxs = maxs
	tracep.mask = mask||MASK_SHOT
	if mins then
		return util.TraceHull(tracep)
	else
		return util.TraceLine(tracep)
	end
end

function ENT:GetModelTrace(length,filter,mins,maxs,mask)
	tracep.start = self.Player:GetShootPos()
	tracep.endpos = tracep.start+self:GetAngles():Forward()*length
	tracep.filter = filter||self.Player
	tracep.mins = mins
	tracep.maxs = maxs
	tracep.mask = mask||MASK_SHOT
	if mins then
		return util.TraceHull(tracep)
	else
		return util.TraceLine(tracep)
	end
end

function ENT:Think()
	local pl = self:GetPlayer()
	if !pl:IsValid() then
		return
	end
	if SERVER then
		if !IsValid(self.Player) || (self.Weapon != self.Player:GetActiveWeapon()) then
			self:OnKill()
			self:Remove()
			return
		end
	else
		if (pl == GetViewEntity()) && !self.ViewMode then
			self:OnViewMode()
			self.ViewMode = true
		elseif (pl != GetViewEntity()) && self.ViewMode then
			self:OnWorldMode()
			self.ViewMode = false
		end
	end
	self:OnThink()
end


for k,v in pairs(file.Find("entities/scav_stream_base/effects/*.lua","LUA")) do
	if (v != ".") && (v != "..") then
		include("effects/"..v)
		AddCSLuaFile("effects/"..v)
	end
end