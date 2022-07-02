include('shared.lua')
local sp = game.SinglePlayer()

function ENT:Think()
	return true
end

function ENT:Draw()
	
	if not sp and (CurTime()-self.Created) < GetConVar("cl_interp"):GetFloat() then
		return
	end
    local ent = self:GetStickEntity()
    if (ent ~= NULL) and not ent:IsWorld() and (ent ~= GetViewEntity()) then
        local bone = self:GetStickBone()
        local bonepos,boneang = ent:GetBonePosition(bone)
        if bonepos then
            local pos,ang = LocalToWorld(self:GetStickPos(),self:GetStickAngle(),bonepos,boneang)
            self:SetPos(pos)
            self:SetAngles(ang)
        end
    end
    if (ent ~= GetViewEntity()) then
        self:DrawModel()
    end
end
