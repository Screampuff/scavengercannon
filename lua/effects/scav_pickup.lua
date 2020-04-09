AddCSLuaFile()

EFFECT.coltab = {["scav_gun"] = Color(200,200,255),["weapon_blackholegun"] = Color(128,0,0),["capture_device"] = Color(0,255,0),["weapon_alchemygun"] = Color(128,0,156)}
function EFFECT:Init(data)
	self.em = ParticleEmitter(self:GetPos())
		local owner = data:GetEntity()
		sound.Play("weapons/scav_gun/pickup.wav",self:GetPos())
		if !IsValid(owner) || !owner:GetActiveWeapon():IsValid() || !self.coltab[owner:GetActiveWeapon():GetClass()] then
			return
		end
		local col = owner:GetActiveWeapon():GetClass()
		local part = self.em:Add("effects/scav_shine5",self:GetPos())
		if part then
			part:SetColor(self.coltab[col].r,self.coltab[col].g,self.coltab[col].b)
			part:SetDieTime(1)
			part:SetStartSize(data:GetRadius()*2)
			part:SetEndSize(2)
			part:SetStartAlpha(255)
			part:SetEndAlpha(128)
			part.Owner = data:GetEntity()
		end
--		self.em:Finish()
		for i=1,30 do
			if self.em then
				local part = self.em:Add("effects/scav_shine5",self:GetPos()+data:GetRadius()*Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
				if part then
					part:SetColor(self.coltab[col].r,self.coltab[col].g,self.coltab[col].b)
					local vel = Vector(math.random(-32,32),math.random(-32,32),math.random(-32,32))
					local lifeoffset = math.Rand(0,1)
					part.vel = vel
					part:SetDieTime(lifeoffset+1)
					part.StartTime = CurTime()+lifeoffset
					part:SetStartSize(data:GetRadius()/2)
					part:SetEndSize(2)
					part:SetStartAlpha(255)
					part:SetEndAlpha(20)
					part.startpos = part:GetPos()
					part.life = CurTime()+lifeoffset+1
					part.Owner = data:GetEntity()
					part:SetThinkFunction(scav_partmove)
					part:SetNextThink(CurTime()+0.1)
				end
			end
--			self.em:Finish()
		end
end

function scav_partmove(part)
	part:SetNextThink(CurTime()+0.1)
	if !part.Owner || !part.Owner:IsValid() || !part.Owner:GetActiveWeapon() || !part.Owner:GetActiveWeapon():IsValid() || part.StartTime > CurTime() then
		return false
	end
	if (GetViewEntity() != part.Owner) && (part.Owner:GetActiveWeapon():LookupAttachment("muzzle") != 0) then
		part:SetPos(LerpVector(math.sqrt(part.life-CurTime()),part.Owner:GetActiveWeapon():GetAttachment(part.Owner:GetActiveWeapon():LookupAttachment("muzzle")).Pos,part.startpos+part.vel*(CurTime()-part.StartTime)))
	elseif part.Owner:GetViewModel():IsValid() && part.Owner:GetViewModel():LookupAttachment("muzzle") != 0 then
		part:SetPos(LerpVector(math.sqrt(part.life-CurTime()),part.Owner:GetViewModel():GetAttachment(part.Owner:GetViewModel():LookupAttachment("muzzle")).Pos,part.startpos+part.vel*(CurTime()-part.StartTime)))
	end
	
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end