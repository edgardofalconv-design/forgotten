"""Exercise loading failures and round avatar lifecycle with Lua API doubles.

These checks do not execute Roblox or verify real catalog assets/physics.
"""
from pathlib import Path
import ctypes

ROOT = Path(__file__).resolve().parents[1]
MOCK = r'''
Enum = {HumanoidRigType = {R6 = "R6", R15 = "R15"}}
workspace = {Name = "Workspace"}
local time, requests, outfits, creations, animations = 100, 0, 0, 0, 0
os.clock = function() return time end
warn = function() end
local failure, missingOutfit, badBody = false, false, false
local installed
local installedName="junkbot"
local Storage = {Name = "ServerStorage"}
Storage.FindFirstChild = function()
 if installed then return {FindFirstChild = function(_,name) if name==installedName then return installed end end} end
end
local function description()
 return {Head=1,Torso=2,LeftArm=3,RightArm=4,LeftLeg=5,RightLeg=badBody and 0 or 6}
end
local function makeModel(rig)
 local m = {Name="Avatar",Parent=workspace,attributes={},pivot="lobby",Archivable=true}
 local desc = description()
 local h = {RigType=rig or "R15",Health=80,MaxHealth=100,WalkSpeed=16}
 h.GetAppliedDescription = function() return desc end
 h.SetAttribute = function(self,key,value) self[key]=value end
 local root = {Anchored=true,Name="HumanoidRootPart",MeshId="original-root"}
 root.IsA = function(_, kind) return kind == "BasePart" end
 local head = {Name="Head",MeshId="original-head",TextureID="original-texture"}
 head.IsA = root.IsA
 m.h, m.root, m.head = h, root, head
 m.FindFirstChildOfClass = function(_, kind) return kind=="Humanoid" and h or nil end
 m.FindFirstChild = function(self, name)
  if name=="HumanoidRootPart" then return root elseif name=="Head" then return head
  elseif name=="Animate" then return self.animate end
 end
 m.GetDescendants = function() return {root,head} end
 m.GetPivot = function(self) return self.pivot end
 m.PivotTo = function(self,pivot) self.pivot=pivot end
 m.SetAttribute = function(self,key,value) self.attributes[key]=value end
 m.GetAttribute = function(self,key) return self.attributes[key] end
 m.Destroy = function(self) self.destroyed=true;self.Parent=nil end
 m.Clone = function(self)
  local c=makeModel(h.RigType)
  c.Parent=nil
  c.Name=self.Name
  for k,v in pairs(self.attributes) do c.attributes[k]=v end
  return c
 end
 return m
end
local AssetService = {GetBundleDetailsAsync = function(_,id)
 requests=requests+1
 assert(id==589, "Must use the supplied bundle, not a guessed body ID")
 if failure then error("network unavailable") end
 return {Name="Junkbot",Items=missingOutfit and {} or {{Type="Asset",Id=10},{Type="UserOutfit",Id=123456}}}
end}
local Players = {
 GetHumanoidDescriptionFromOutfitIdAsync=function(_,id)
  outfits=outfits+1;assert(id==123456);return description()
 end,
 CreateHumanoidModelFromDescriptionAsync=function(_,desc,rig)
  creations=creations+1;assert(rig=="R15" and desc.Torso==2);return makeModel(rig)
 end
}
game = {GetService=function(_,name)
 return assert(({Players=Players,AssetService=AssetService,ServerStorage=Storage})[name], name)
end}
local function player(rig)
 local p={Name="Tester",Character=makeModel(rig),attributes={}}
 p.SetAttribute=function(self,key,value) self.attributes[key]=value end
 p.Character.animate={Clone=function() animations=animations+1;return {} end}
 return p
end
'''
TESTS = r'''
-- Original catalog path, once per server; cloned bodies stay independent.
local catalog = loadCatalog()
assert(catalog.load() and catalog.ready())
assert(requests==1 and outfits==1 and creations==1)
local a,b=catalog.clone(),catalog.clone()
assert(a~=b and a.head~=b.head and a.head.MeshId=="original-head")
assert(a.head.TextureID=="original-texture" and a:GetAttribute("SourceBundleId")==589)
assert(a:GetAttribute("SourceOutfitId")==123456)
assert(a:GetAttribute("ExpectedCharacterId")=="junkbot")
assert(catalog.load() and requests==1)

-- A failed fetch stays unavailable, obeys retry cooldown and can recover.
catalog=loadCatalog();failure=true
assert(not catalog.load() and not catalog.ready() and not catalog.clone())
local before=requests
assert(not catalog.load() and requests==before)
time=time+21;failure=false
assert(catalog.load())

-- Bad responses must never silently produce the procedural fallback.
catalog=loadCatalog();missingOutfit=true
assert(not catalog.load() and not catalog.clone())
missingOutfit=false
catalog=loadCatalog();badBody=true
assert(not catalog.load() and not catalog.clone())
badBody=false

-- A locally saved original model avoids bundle/outfit requests.
installed=makeModel("R15");installed:SetAttribute("SourceBundleId",589)
catalog=loadCatalog();before=requests
assert(catalog.load() and requests==before)
installed.h.RigType="R6";catalog=loadCatalog();before=requests
assert(catalog.load() and requests==before+1)
installed.h.RigType="R15";installedName="yellowguy";installed:SetAttribute("ExpectedCharacterId","yellowguy")
catalog=loadCatalog();before=requests
assert(catalog.load() and requests==before)
assert(catalog.clone():GetAttribute("ExpectedCharacterId")=="junkbot")
installed=nil;installedName="junkbot"

-- Real round swap from either source rig preserves the complete native body.
for _,rig in ipairs({"R6","R15"}) do
 for _,roundRig in ipairs({"R6","R15"}) do
 local native=loadNative()
 local p=player(rig)
 local original=p.Character
 local round=makeModel(roundRig)
 local count=animations
 assert(native.equip(p,round,"junkbot"))
 assert(p.Character==round and original.Parent==Storage)
 assert(not round.root.Anchored and round.h.Health==100 and round.h.WalkSpeed==16)
 assert(round.head.MeshId=="original-head" and round.head.TextureID=="original-texture")
 assert(animations==count)
 assert(native.consumeSwap(p,round) and not native.consumeSwap(p,round))
 assert(not native.equip(p,makeModel("R15"),"junkbot"))
 assert(native.restore(p) and p.Character==original and original.Parent==workspace)
 assert(round.destroyed and p.attributes.CharacterId==nil)
 assert(native.consumeSwap(p,original) and native.isRestoredAvatar(original))
 -- A second round remains possible after restoring the original avatar.
 assert(native.equip(p,makeModel("R15"),"junkbot"))
 assert(native.restore(p) and p.Character==original)
end

end

-- Missing models or incomplete/dead avatars do not remove the lobby avatar.
local native=loadNative();local p=player("R6");local original=p.Character
assert(not native.equip(p,nil,"junkbot") and p.Character==original)
original.h.Health=0
assert(not native.equip(p,makeModel("R15"),"junkbot") and original.Parent==workspace)

-- A normal respawn keeps its new avatar and destroys the stale round snapshot.
p=player("R15");original=p.Character
local round=makeModel("R15")
assert(native.equip(p,round,"junkbot"));assert(native.consumeSwap(p,round))
local respawn=makeModel("R15");p.Character=respawn
assert(not native.consumeSwap(p,respawn))
native.discard(p)
assert(p.Character==respawn and original.destroyed and round.destroyed)
assert(not native.restore(p))

-- Leaving the server releases the stored avatar; another player is unaffected.
p=player("R15");original=p.Character
local other=player("R6");local otherOriginal=other.Character
assert(native.equip(p,makeModel("R15"),"junkbot"))
assert(native.equip(other,makeModel("R15"),"junkbot"))
native.discard(p)
assert(original.destroyed and not native.restore(p))
assert(native.restore(other) and other.Character==otherOriginal)
'''


def main():
    catalog = (ROOT / 'src/shared/CatalogCharacter.luau').read_text()
    native = (ROOT / 'src/shared/NativeRoundCharacter.luau').read_text()
    script = (MOCK + '\nlocal function loadCatalog()\n' + catalog + '\nend\n'
              + '\nlocal function loadNative()\n' + native + '\nend\n' + TESTS)
    lib = ctypes.CDLL('liblua5.4.so.0')
    lib.luaL_newstate.restype = ctypes.c_void_p
    lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
    lib.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
    lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                              ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
    lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
    lib.lua_tolstring.restype = ctypes.c_char_p
    lib.lua_close.argtypes = [ctypes.c_void_p]
    state = lib.luaL_newstate()
    lib.luaL_openlibs(state)
    try:
        status = lib.luaL_loadstring(state, script.encode())
        if not status:
            status = lib.lua_pcallk(state, 0, 0, 0, 0, None)
        if status:
            raise RuntimeError(lib.lua_tolstring(state, -1, None).decode())
    finally:
        lib.lua_close(state)
    print('Carga, caché, fallos, R6/R15, restauración, segunda ronda y limpieza: pasan con dobles Lua. Roblox pendiente.')


if __name__ == '__main__':
    main()
