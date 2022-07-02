--Sniper Rifle/Tank Shell tracer
EFFECT.mat = Material("trails/smoke")
EFFECT.lifetime = 1

function EFFECT:Init(data)
	self.col = Color(255,255,255,255)
	self.scale = data:GetScale()
	self.Weapon = data:GetEntity()
	if self.Weapon:IsWeapon() then
		self.Owner = self.Weapon.Owner
	else
		self.Owner = self.Weapon
	end
	self.Created = CurTime()
	self.endpos = data:GetOrigin()
	self:SetPos(self:GetTracerShootPos2(data:GetStart(),self.Weapon,1))
	self:SetRenderBoundsWS(self:GetPos(),self.endpos)
	if self.scale == 0 then
		self.scale = 1
	end
end


function EFFECT:GetTracerShootPos2(start,wep)
	if not wep:IsValid() then
		return start
	end
	if (self.Owner == GetViewEntity()) and not (wep.zoomed) then
		--self:SetShouldDrawInViewMode(true)
		return (self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos)
	elseif not (self.Owner:GetActiveWeapon().zoomed) or (self.Owner ~= GetViewEntity()) and self.weapon  then
		--self:SetShouldDrawInViewMode(false)
		return (self.Weapon:GetAttachment(wep:LookupAttachment("muzzle")).Pos)
	else
		--self:SetShouldDrawInViewMode(true)
		return (self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos+self.Owner:GetAimVector():Angle():Right()*6-self.Owner:GetAimVector():Angle():Up()*5)
	end
end


function EFFECT:Think()
	if self.Created+self.lifetime < CurTime() then
		return false
	end
	return true
end

function EFFECT:Render()
	local dtime = CurTime()-self.Created
	if not self.startpos then
		self.startpos = self:GetTracerShootPos2(self:GetPos(),self.Weapon,1)
		self.dir = self.endpos-self.startpos
		--self.lifetime = self.endpos:Distance(self.startpos)/10000
	end
	self.col.a = Lerp(dtime,255,0)
	render.SetMaterial(self.mat)
	render.DrawBeam(self.startpos-vector_up*(dtime)*0,self.endpos-vector_up*(dtime)*0,Lerp((dtime)/self.lifetime,1,4)*self.scale,0,1,self.col)
end
