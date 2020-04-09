EFFECT.mat = Material("vgui/white_additive")
ScavData.Overlays = {}

function EFFECT:Init(data)
	self.Created = CurTime()
	local normal = data:GetStart()
	local alpha = data:GetMagnitude()
	self.color = normal
	self.lifetime = data:GetScale()
	self:SetParent(LocalPlayer())
	self.alpha = alpha
	table.insert(ScavData.Overlays,self)
end

function EFFECT:Think()
	if CurTime() - self.Created > self.lifetime then
		for k,v in ipairs(ScavData.Overlays) do
			if v == self then
				table.remove(ScavData.Overlays,k)
				break
			end
		end
		return false
	end
	return true
end

function EFFECT:Render()
	return true
end

hook.Add("RenderScreenspaceEffects","scav_overlays",function()
	for _,self in ipairs(ScavData.Overlays) do
		render.SetMaterial(self.mat)
		self.mat:SetVector("$color", self.color)
		self.mat:SetFloat("$alpha", Lerp((CurTime() - self.Created) / self.lifetime, self.alpha, 0))
		cam.Start2D()
			render.DrawScreenQuad()
		cam.End2D()
	end
end)

net.Receive("scav_overlay",function()
	local efdata = EffectData()
	local col = net.ReadColor()
	if col then
		efdata:SetStart(Vector(col.r/255,col.g/255,col.b/255))
		efdata:SetMagnitude(col.a/255)
		efdata:SetScale(net.ReadFloat())
		efdata:SetOrigin(LocalPlayer():GetPos())
	util.Effect("ef_scav_overlay",efdata,nil,true)
	end
end)
	
local PLAYER = FindMetaTable("Player")

function PLAYER:SendHUDOverlay(color,duration)
	local efdata = EffectData()
	efdata:SetStart(Vector(color.r,color.g,color.b))
	efdata:SetMagnitude(color.a)
	efdata:SetScale(duration)
	efdata:SetOrigin(LocalPlayer():GetPos())
	util.Effect("ef_scav_overlay",efdata,nil,true)
end