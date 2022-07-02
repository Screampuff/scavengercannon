include('shared.lua')
local mat = Material("trails/electric")
local mat2 = Material("effects/scav_elec1")


function ENT:Draw()
	if not self.points then
		return
	end
	render.SetMaterial(mat)
	render.StartBeam(#self.points)
	for i=1,#self.points do
		render.AddBeam(self.points[i],10-i,((i-1)/10),color_white)
	end
	render.EndBeam()
	render.SetMaterial(mat2)
	if self.points[1] then
		render.DrawSprite(self.points[1],32,32,color_white)
	end
end
