AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

PrecacheParticleSystem("scav_gib_burst_blood")
PrecacheParticleSystem("scav_gib_chunk_blood")
util.PrecacheModel("models/props_debris/concrete_chunk05g.mdl")
util.PrecacheModel("models/Gibs/HGIBS.mdl")
util.PrecacheModel("models/Gibs/HGIBS_spine.mdl")
util.PrecacheModel("models/Gibs/Antlion_gib_medium_1.mdl")
util.PrecacheModel("models/Gibs/wood_gib01e.mdl")

local bonetranslate = nil
local modeltranslate = nil

if CLIENT then

	bonetranslate = {
	["ValveBiped.Bip01_Spine1"] = 4,
	["ValveBiped.Bip01_Spine4"] = 4,
	["ValveBiped.Bip01_Spine2"] = 3,
	["ValveBiped.Bip01_Head1"] = 3,
	["ValveBiped.Bip01_R_Clavicle"] = 1,
	["ValveBiped.Bip01_L_Clavicle"] = 1,
	["ValveBiped.Bip01_R_UpperArm"] = 5,
	["ValveBiped.Bip01_L_UpperArm"] = 5,
	["ValveBiped.Bip01_R_UpperArm"] = 5,
	["ValveBiped.Bip01_L_UpperArm"] = 5,
	["ValveBiped.Bip01_R_Thigh"] = 5,
	["ValveBiped.Bip01_L_Thigh"] = 5,
	["ValveBiped.Bip01_R_Calf"] = 5,
	["ValveBiped.Bip01_L_Calf"] = 5,
	["ValveBiped.Bip01_R_Hand"] = 1,
	["ValveBiped.Bip01_L_Hand"] = 1,
	["ValveBiped.Bip01_R_Foot"] = 1,
	["ValveBiped.Bip01_L_Foot"] = 1,
	}
	
	modeltranslate = {
	[1] = "models/props_debris/concrete_chunk05g.mdl",
	[2] = "models/Gibs/HGIBS.mdl",
	[3] = "models/Gibs/HGIBS_spine.mdl",
	[4] = "models/Gibs/Antlion_gib_medium_1.mdl",
	[5] = "models/Gibs/wood_gib01e.mdl"
	}
	
end

function ENT:Initialize()

	local owner = self:GetOwner()
	
	if not IsValid(owner) then
		owner = self
	end
	
	self:SetModel(owner:GetModel())
	self:SetPos(owner:GetPos())
	self:SetAngles(owner:GetAngles())
	self:AddEffects(EF_NOSHADOW)
	
	if CLIENT then
	
		ParticleEffectAttach("scav_gib_burst_blood",PATTACH_ABSORIGIN_FOLLOW,owner,0)
		owner:EmitSound("physics/flesh/flesh_bloody_break.wav")
		local center = owner:GetPos() + owner:OBBCenter()
		local vel = owner:GetVelocity()
		local edata = EffectData()
		for k,v in pairs(bonetranslate) do
			local bonepos,boneang = owner:GetBonePosition(owner:LookupBone(k))
			if bonepos then
				edata:SetOrigin(bonepos)
				edata:SetAngles(boneang)
				edata:SetScale(v)
				edata:SetStart((bonepos - center):GetNormalized() * 600 + vel)
				edata:SetAttachment()
				util.Effect("ef_scav_gib",edata)
			end
		end
		
	else
		self:Fire("Kill",nil,1)
	end
	
end

function ENT:Draw()
end

if CLIENT then

	local EFFECT = {}

	function EFFECT:Init(edata)
		local modelindex = math.Round(edata:GetScale())
		self:SetModel(modeltranslate[modelindex])
		self.Created = CurTime()
		self:SetAngles(edata:GetAngles())
		self:SetPos(edata:GetOrigin())
		self:SetMaterial("models/flesh")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:GetPhysicsObject():SetVelocity(edata:GetStart())
		self:GetPhysicsObject():SetMaterial("watermelon")
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ParticleEffectAttach("scav_gib_chunk_blood",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end

	function EFFECT:Think()
		if self.Created + 15 < CurTime() then
			return false
		elseif self.Created + 13 < CurTime() then
			self:SetColor(Color(255,255,255,127 * (15 - (CurTime() - self.Created))))
			self:SetRenderMode(RENDERMODE_TRANSALPHA)
		end
		return true
	end

	function EFFECT:Render()
		self:DrawModel()
		return true
	end
	
	effects.Register(EFFECT,"ef_scav_gib",true)
	
end