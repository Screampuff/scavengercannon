function EFFECT:Init(data)
	self.Created = UnPredictedCurTime()
	self.vel = data:GetStart()
	self.Owner = data:GetEntity()
	self:SetPos(self.Owner:GetShootPos()+(self.Owner:GetAimVector():Angle():Right()*2-self.Owner:GetAimVector():Angle():Up()*2)*1)
	self.time = UnPredictedCurTime()+0.4
	self:SetModel("models/weapons/w_models/w_syringe_proj.mdl")
	self.lasttrace = UnPredictedCurTime()
	self.Gravity = Vector(0,0,-96)
	self:SetSkin(1)
	self.didhit = false
	self.Owner:EmitSound("weapons/syringegun_shoot.wav")
end

function EFFECT:Think()
		if !self.didhit then
			self.vel = self.vel+self.Gravity*math.max(UnPredictedCurTime()-self.lasttrace,0)
			self:SetAngles(self.vel:Angle())
			local vel = self.vel*math.max(UnPredictedCurTime()-self.lasttrace,0)
			local tracep = {}
			tracep.start = self:GetPos()
			tracep.filter = self.Owner
			tracep.endpos = self:GetPos()+vel
			tracep.mask = MASK_SHOT
			tr = util.TraceLine(tracep)
			if tr.Hit then
				if tr.Entity && tr.Entity:IsValid() then
					local ef = EffectData()
					ef:SetStart(self.vel:GetNormalized()*-1)
					ef:SetOrigin(tr.HitPos)
					if (tr.MatType == MAT_BLOODYFLESH)||(tr.MatType == MAT_FLESH) then
						util.Effect("BloodImpact",ef)
						sound.Play("physics/flesh/flesh_impact_bullet"..math.random(1,5)..".wav",self:GetPos(),50)
					elseif (tr.MatType == MAT_CONCRETE) then
						util.Decal("impact.concrete",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
						sound.Play("physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav",self:GetPos(),50)
					elseif (tr.MatType == MAT_PLASTIC) then
						util.Decal("impact.concrete",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
						sound.Play("physics/plastic/plastic_box_impact_hard"..math.random(1,4)..".wav",self:GetPos(),50)
					elseif (tr.MatType == MAT_GLASS)||(tr.MatType == MAT_TILE) then
						util.Effect("GlassImpact",ef)
						util.Decal("impact.glass",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
						sound.Play("physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav",self:GetPos(),50)
					elseif (tr.MatType == MAT_METAL)||(tr.MatType == MAT_GRATE) then
						util.Effect("MetalSpark",ef)
						util.Decal("impact.metal",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
						sound.Play("physics/metal/metal_solid_impact_bullet"..math.random(1,4)..".wav",self:GetPos(),50)
					elseif (tr.MatType == MAT_WOOD) then
						util.Decal("impact.wood",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
						sound.Play("physics/wood/wood_solid_impact_bullet"..math.random(1,5)..".wav",self:GetPos(),50)
					elseif (tr.MatType == MAT_DIRT)||(tr.MatType == MAT_SAND) then
						util.Decal("impact.sand",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
						sound.Play("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav",self:GetPos(),50)
					end
					return false
				end
				if tr.HitWorld then
					self.Gravity = vector_origin
					self.vel = vector_origin
					self.didhit = true
					self:SetPos(tr.HitPos - self.vel:GetNormalized()*4)
				end
				//util.Decal("fadingscorch",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
				//sound.Play("DOOM/DSFIRXPL.wav",tr.HitPos,150,100)
				//local edata = EffectData()
				//edata:SetOrigin(self:GetPos())
				//util.Effect("sprite_pl_imp",edata)
				//return false
			else
				self:SetPos(self:GetPos()+vel)
			end
			self.lasttrace = UnPredictedCurTime()
		end
		if self.Created+10 < UnPredictedCurTime() then
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