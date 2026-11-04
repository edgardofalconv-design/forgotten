-- Portable authored mesh surfaces: native spheres/cylinders and triangular wedges.
-- This fallback needs no uploaded MeshIds, HTTP or EditableMesh permission.
local Geometry={}
local function vec(t)return Vector3.new(t[1],t[2],t[3])end
local function finish(part,parent,anchor,name,color,material,localFrame,visibility)
 part.Name=name;part.Color=Color3.fromRGB(color[1],color[2],color[3]);part.Material=Enum.Material[material or "SmoothPlastic"]
 part.CFrame=anchor.CFrame*localFrame;part.Anchored=false;part.Massless=true
 part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
 part.CastShadow=part.Size.X*part.Size.Y*part.Size.Z>.12
 part.TopSurface=Enum.SurfaceType.Smooth;part.BottomSurface=Enum.SurfaceType.Smooth
 if visibility then part:SetAttribute("VisibilityAction",visibility);part.Transparency=1 end
 part.Parent=parent
 local weld=Instance.new("WeldConstraint");weld.Part0=anchor;weld.Part1=part;weld.Parent=part
 return part
end
local function triangle(a,b,c,parent,anchor,spec)
 local ab,ac,bc=b-a,c-a,c-b
 if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c
 elseif ac:Dot(ac)>bc:Dot(bc) and ac:Dot(ac)>ab:Dot(ab) then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b
 local normal=ab:Cross(ac)
 if normal.Magnitude<.00001 or bc.Magnitude<.00001 then return end
 local right=normal.Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
 local height=math.abs(ab:Dot(up))
 local function wedge(length,position,r,u,z)
  if length<.0001 or height<.0001 then return end
  local part=Instance.new("WedgePart");part.Size=Vector3.new(.012,height,length)
  finish(part,parent,anchor,spec.name,spec.color,spec.material,CFrame.fromMatrix(position,r,u,z),spec.visibility)
 end
 wedge(math.abs(ab:Dot(back)),(a+b)/2,right,up,back)
 wedge(math.abs(ac:Dot(back)),(a+c)/2,-right,up,-back)
end
function Geometry.build(parent,anchor,spec)
 local folder=Instance.new("Folder");folder.Name=spec.name;folder.Parent=parent
 if spec.kind=="RoundedBlock" then
  local size=vec(spec.size);local r=math.min(spec.radius or .08,size.X/3,size.Y/3,size.Z/3)
  local center=vec(spec.position)
  local function piece(shape,dimensions,position,rotation)
   local part=Instance.new("Part");part.Size=dimensions;part.Shape=shape
   finish(part,folder,anchor,spec.name,spec.color,spec.material,CFrame.new(center+position)*(rotation or CFrame.new()),spec.visibility)
  end
  piece(Enum.PartType.Block,Vector3.new(size.X-2*r,size.Y-2*r,size.Z),Vector3.new())
  piece(Enum.PartType.Block,Vector3.new(size.X-2*r,size.Y,size.Z-2*r),Vector3.new())
  piece(Enum.PartType.Block,Vector3.new(size.X,size.Y-2*r,size.Z-2*r),Vector3.new())
  local x,y,z=size.X/2-r,size.Y/2-r,size.Z/2-r
  for _,a in ipairs({-1,1}) do for _,b in ipairs({-1,1}) do
   piece(Enum.PartType.Cylinder,Vector3.new(size.X-2*r,2*r,2*r),Vector3.new(0,a*y,b*z))
   piece(Enum.PartType.Cylinder,Vector3.new(size.Y-2*r,2*r,2*r),Vector3.new(a*x,0,b*z),CFrame.Angles(0,0,math.pi/2))
   piece(Enum.PartType.Cylinder,Vector3.new(size.Z-2*r,2*r,2*r),Vector3.new(a*x,b*y,0),CFrame.Angles(0,math.pi/2,0))
   for _,c in ipairs({-1,1}) do piece(Enum.PartType.Ball,Vector3.new(2*r,2*r,2*r),Vector3.new(a*x,b*y,c*z)) end
  end end
 elseif spec.kind=="Mesh" then
  for _,face in ipairs(spec.faces) do triangle(vec(spec.vertices[face[1]+1]),vec(spec.vertices[face[2]+1]),vec(spec.vertices[face[3]+1]),folder,anchor,spec) end
 else
  local part=Instance.new(spec.kind=="Wedge" and "WedgePart" or "Part")
  local cf
  if spec.kind=="Segment" then
   local a,b=vec(spec.start),vec(spec["end"]);local delta=b-a
   part.Shape=Enum.PartType.Cylinder;part.Size=Vector3.new(delta.Magnitude,spec.radius*2,spec.radius*2)
   cf=CFrame.lookAt((a+b)/2,b)*CFrame.Angles(0,math.pi/2,0)
  else
   local size=vec(spec.size);part.Size=size
   if spec.kind=="Sphere" then part.Shape=Enum.PartType.Ball
   elseif spec.kind=="Cylinder" then part.Shape=Enum.PartType.Cylinder;part.Size=Vector3.new(size.Y,size.X,size.Z) end
   local angles=spec.rotation or {0,0,0}
   cf=CFrame.new(vec(spec.position))*CFrame.Angles(math.rad(angles[1]),math.rad(angles[2]),math.rad(angles[3]))
  end
  finish(part,folder,anchor,spec.name,spec.color,spec.material,cf,spec.visibility)
  if spec.label then
   local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(512,256);gui.Parent=part
   local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold
   text.Text=spec.label;text.TextColor3=Color3.fromRGB(229,229,220);text.TextScaled=true;text.Parent=gui
  end
 end
 return folder
end
return Geometry
