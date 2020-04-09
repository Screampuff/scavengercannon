include("shared.lua")

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
end

function ENT:ViewDraw() --the weapon should call this function in viewmodeldrawn
	self:Draw()
end

function ENT:GetAimVector()
	if !IsValid(pl) then
		return Vector()
	end
	return self.Player:GetAimVector()
end

function ENT:OnViewMode()
end

function ENT:OnWorldMode()
end

function ENT:IsInViewMode()
	return self.ViewMode
end

function ENT:IsInWorldMode()
	return !self.ViewMode
end

hook.Add("PostDrawOpaqueRenderables","test",function()
	for k,v in pairs(ents.FindByClass("scav_stream_*")) do
		//cam.Start3D(EyePos(),EyeAngles())
		if v.Draw2 then
			pcall(v.Draw2,v)
		end
		//cam.End3D()
	end
end)

function ENT:OnKill()
end

function ENT:OnRemove()
	if !self.Killed then
		self:OnKill()
	end
end

net.Receive("scv_killstream",function()
	local ent = net.ReadEntity()
	if IsValid(ent) then
		if ent.OnKill then
			ent:OnKill()
			ent.Killed = true
		end
	end
end)