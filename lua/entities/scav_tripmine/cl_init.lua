include('shared.lua')
local mat_beam = Material("trails/laser")
local mat_bloom = Material("effects/scav_shine_HR")
local color_beam = Color(255,0,0,50)

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:Draw()
end

usermessage.Hook("scv_mine_arm",function(um)
	local ent = um:ReadEntity()
	local state = um:ReadBool()
	if !IsValid(ent) then
		return
	end
	ent:SetArmed(state)
end)

hook.Add("PostDrawOpaqueRenderables","scvminedraw",function()
	for k,v in pairs(ents.FindByClass("scav_tripmine")) do
		if v:IsArmed() then
			local tr = v:GetBeamTrace()
			local posang = v:GetAttachment(v:LookupAttachment("beam_attach"))
			render.SetMaterial(mat_beam)
			render.DrawBeam(tr.StartPos,tr.HitPos,8,0,0,color_beam)
			render.SetMaterial(mat_bloom)
			render.DrawSprite(tr.HitPos,2,2,color_beam)
		end
	end
end)