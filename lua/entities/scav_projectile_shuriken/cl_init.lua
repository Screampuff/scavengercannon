include('shared.lua')
local sp = game.SinglePlayer()

function ENT:Think()
	return true
end

function ENT:Draw()
	
	if !sp && (CurTime()-self.Created) < GetConVar("cl_interp"):GetFloat() then
		return
	end
    local ent = self.dt.StickEntity
    if (ent != NULL) && !ent:IsWorld() && (ent != GetViewEntity()) then
        local bone = self.dt.StickBone
        local bonepos,boneang = ent:GetBonePosition(bone)
        if bonepos then
            local pos,ang = LocalToWorld(self.dt.StickPos,self.dt.StickAngle,bonepos,boneang)
            self:SetPos(pos)
            self:SetAngles(ang)
        end
    end
    if (ent != GetViewEntity()) then
        self:DrawModel()
    end
end