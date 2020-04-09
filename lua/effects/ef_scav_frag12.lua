AddCSLuaFile()

function EFFECT:Init(data)
	self.Created = CurTime()
	self.vel = data:GetStart()
	self.Owner = data:GetEntity()
	self:SetPos(self.Owner:GetShootPos()+(self.Owner:GetAimVector():Angle():Right()*2-self.Owner:GetAimVector():Angle():Up()*2)*1)
	self.time = CurTime()+0.4
	self:SetModel("models/items/ammo/frag12round.mdl")
	self.lasttrace = CurTime()
	self.Gravity = Vector(0,0,-96)
	self:SetSkin(1)
	self.didhit = false
	self.Owner:EmitSound("weapons/ar2/fire1.wav")
end

function EFFECT:Think()
		self.vel = self.vel+self.Gravity*(CurTime()-self.lasttrace)
		self:SetAngles(self.vel:Angle())
		self:SetLocalAngles(self:GetLocalAngles()+Angle(0,20,0))
		local vel = self.vel*(CurTime()-self.lasttrace)
		local tracep = {}
		tracep.start = self:GetPos()
		tracep.filter = self.Owner
		tracep.endpos = self:GetPos()+vel
		tracep.mask = MASK_SHOT
		tr = util.TraceLine(tracep)
		if tr.Hit then
			util.Decal("fadingscorch",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
			//sound.Play("DOOM/DSFIRXPL.wav",tr.HitPos,150,100)
			local edata = EffectData()
			edata:SetOrigin(self:GetPos())
			util.Effect("ef_scav_expsmall",edata)
			return false
		else
			self:SetPos(self:GetPos()+vel)
		end
		self.lasttrace = CurTime()
		if self.Created+10 < CurTime() then
			return false
		end

		return true
end

function EFFECT:Render()
	if self.Created+0.01 > CurTime() then
		return
	end
	self:DrawModel()
end