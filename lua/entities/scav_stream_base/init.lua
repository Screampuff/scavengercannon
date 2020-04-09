AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.KillDelay = 0

function ENT:OnKill()
end

util.AddNetworkString("scv_killstream")

function ENT:Kill()
	self.dt.DeathTime = CurTime()
	net.Start("scv_killstream")
		local rf = RecipientFilter()
		rf:AddAllPlayers()
		net.WriteEntity(self)
	net.Send(rf)
	self:OnKill()
	self.Killed = true
	self:Fire("Kill",nil,self.KillDelay)
end

function ENT:OnRemove()
	if !self.Killed then
		self:OnKill()
	end
end