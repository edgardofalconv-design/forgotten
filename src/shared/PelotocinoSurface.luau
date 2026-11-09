-- Small authored weave/leather maps, generated locally. No external texture IDs.
local Assets=game:GetService("AssetService")
local Surface={};local cache={};local retained={}
local function sample(x,y,leather)
 local noise=math.sin(x*12.9898+y*78.233)*43758.5453;noise=noise-math.floor(noise)
 if leather then return math.floor(219+noise*29)end
 return math.floor(218+noise*12+((x+y)%4<2 and 20 or 0))
end
function Surface.apply(part,leather)
 local key=leather and "leather"or"weave"
 if cache[key]==false then return end
 if not cache[key]then
  local ok,result=pcall(function()
   local size=128
   local image=Assets:CreateEditableImage({Size=Vector2.new(size,size)});assert(image,"Imagen no disponible")
   local pixels=buffer.create(size*size*4)
   for y=0,size-1 do for x=0,size-1 do
    local i=(y*size+x)*4;local c=sample(x,y,leather)
    buffer.writeu8(pixels,i,c);buffer.writeu8(pixels,i+1,c);buffer.writeu8(pixels,i+2,c);buffer.writeu8(pixels,i+3,255)
   end end
   image:WritePixelsBuffer(Vector2.new(0,0),Vector2.new(size,size),pixels)
   local appearance=Assets:CreateSurfaceAppearanceAsync({ColorMap=Content.fromObject(image)})
   table.insert(retained,image);return appearance
  end)
  cache[key]=ok and result or false
 end
 if cache[key]then cache[key]:Clone().Parent=part end
end
function Surface.applyHair(part)
 if cache.hair==false then return end
 if not cache.hair then
  local ok,result=pcall(function()
   local image=Assets:CreateEditableImage({Size=Vector2.new(8,8)});assert(image)
   local pixels=buffer.create(8*8*4)
   for i=0,63 do buffer.writeu8(pixels,i*4,166);buffer.writeu8(pixels,i*4+1,166);buffer.writeu8(pixels,i*4+2,166);buffer.writeu8(pixels,i*4+3,255)end
   image:WritePixelsBuffer(Vector2.new(0,0),Vector2.new(8,8),pixels)
   local surface=Assets:CreateSurfaceAppearanceAsync({RoughnessMap=Content.fromObject(image)})
   table.insert(retained,image);return surface
  end)
  cache.hair=ok and result or false
 end
 if cache.hair then cache.hair:Clone().Parent=part end
end
return Surface
