AddCSLuaFile()

function EFFECT:Init(data)
	self.em = ParticleEmitter(self:GetPos())
		local owner = Entity(data:GetScale())
		local healent = data:GetEntity()
		--sound.Play("ambient/energy/ion_cannon_shot3.wav",self:GetPos())
		if data:GetRadius() > 1 then --don't spam this effect if we're doing a stream of health 
			local part = self.em:Add("effects/scav_shine5",self:GetPos())
			if part then
				part:SetDieTime(1)
				part:SetStartSize(16)
				part:SetEndSize(12)
				part:SetStartAlpha(255)
				part:SetEndAlpha(128)
				part.Owner = data:GetEntity()
			end
		end
--		self.em:Finish()
		local basepos = healent:OBBCenter()
		for i=1,data:GetRadius() do
			local part = self.em:Add("particle/scav_health",self:GetPos())
			if part then
				local vel = owner:GetAimVector()*500+VectorRand()*100 
				local lifeoffset = math.Rand(0,1)+i/100
				part.vel = vel
				part:SetDieTime(lifeoffset+1)
				part.StartTime = CurTime()+lifeoffset
				part:SetStartSize(4)
				part:SetEndSize(2)
				part:SetStartAlpha(255)
				part:SetEndAlpha(20)
				part.endpos = basepos+VectorRand()*10
				part.life = CurTime()+lifeoffset+1
				part.Owner = owner
				part.ent = healent
				part:SetThinkFunction(scav_healpartmove)
				part:SetNextThink(CurTime()+0.1)
				part:SetRollDelta(6.28)
				if (GetViewEntity() ~= part.Owner) and (part.Owner:GetActiveWeapon():LookupAttachment("muzzle") ~= 0) then
					part:SetPos(LerpVector(math.sqrt(part.life-CurTime()),part.endpos+part.ent:GetPos(),part.Owner:GetActiveWeapon():GetAttachment(part.Owner:GetActiveWeapon():LookupAttachment("muzzle")).Pos+part.vel*(CurTime()-part.StartTime)))
				elseif IsValid(part.Owner:GetViewModel()) and part.Owner:GetViewModel():LookupAttachment("muzzle") ~= 0 then
					part:SetPos(LerpVector(math.sqrt(part.life-CurTime()),part.endpos+part.ent:GetPos(),part.Owner:GetViewModel():GetAttachment(part.Owner:GetViewModel():LookupAttachment("muzzle")).Pos+part.vel*(CurTime()-part.StartTime)))
				end
			end
--			self.em:Finish()
		end
end

function scav_healpartmove(part)
	part:SetNextThink(CurTime()+0.1)
	if not IsValid(part.Owner) or not IsValid(part.Owner:GetActiveWeapon()) or part.StartTime > CurTime() then
		return
	end
	if not part.firstthought then
		part.vel = part.Owner:GetAimVector()*500+VectorRand()*50
		part.firstthought = true
	end
	if (GetViewEntity() ~= part.Owner) and (part.Owner:GetActiveWeapon():LookupAttachment("muzzle") ~= 0) then
		part:SetPos(LerpVector(math.sqrt(part.life-CurTime()),part.endpos+part.ent:GetPos(),part.Owner:GetActiveWeapon():GetAttachment(part.Owner:GetActiveWeapon():LookupAttachment("muzzle")).Pos+part.vel*(CurTime()-part.StartTime)))
	elseif IsValid(part.Owner:GetViewModel()) and part.Owner:GetViewModel():LookupAttachment("muzzle") ~= 0 then
		part:SetPos(LerpVector(math.sqrt(part.life-CurTime()),part.endpos+part.ent:GetPos(),part.Owner:GetViewModel():GetAttachment(part.Owner:GetViewModel():LookupAttachment("muzzle")).Pos+part.vel*(CurTime()-part.StartTime)))
	end
	
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
