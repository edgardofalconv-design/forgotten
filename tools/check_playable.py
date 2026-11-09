"""Behavior and export checks without claiming a Roblox Studio execution."""
from pathlib import Path
import ctypes
import re
import xml.etree.ElementTree as ET
from export_preview import MOCK
ROOT = Path(__file__).resolve().parents[1]


def run_lua(source, name, execute=True):
    lib = ctypes.CDLL('liblua5.4.so.0')
    lib.luaL_newstate.restype = ctypes.c_void_p
    lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
    lib.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
    lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
    lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
    lib.lua_tolstring.restype = ctypes.c_char_p
    lib.lua_close.argtypes = [ctypes.c_void_p]
    state = lib.luaL_newstate()
    lib.luaL_openlibs(state)
    try:
        code = lib.luaL_loadstring(state, source.encode())
        if not code and execute:
            code = lib.lua_pcallk(state, 0, 0, 0, 0, None)
        if code:
            raise AssertionError(name + ': ' + lib.lua_tolstring(state, -1, None).decode())
    finally:
        lib.lua_close(state)
    print('PASS:', name)


def module(name, variable):
    return '\nlocal ' + variable + '=(function()\n' + (ROOT/'src/shared'/name).read_text() + '\nend)()\n'


RULE_TESTS = r'''
local count=0
for _,entry in ipairs(roster) do
 assert(entry.id~="baller")
 count=count+1
end
assert(count==6 and roster[4].id=="yellowguy" and roster[5].id=="junkbot")
assert(roster[5].bundleId==589 and roster[4].bundleId==nil)
local r=Rules.new(false)
assert(r.remaining==240 and r.mode=="Normal" and not r.gateOpen)
assert(not r:completeGenerator(0) and not r:completeGenerator(5) and not r:completeGenerator(1.5))
assert(r:completeGenerator(1) and r.remaining==230)
assert(not r:completeGenerator(1) and r.remaining==230)
assert(r:completeGenerator(2))
assert(not r:collectCapsule(1))
for i=1,3 do assert(r:completePuzzle(i));assert(r:collectCapsule(i));assert(not r:collectCapsule(i)) end
assert(r.remaining==205 and not r.gateOpen and r.generatorCount==2 and r.capsuleCount==3)
r:tick(144);assert(r.remaining==61 and not r.gateOpen)
r:tick(1);assert(r.remaining==60 and r.gateOpen)
assert(not r:canEscape(true,false) and not r:canEscape(false,true) and r:canEscape(true,true))
r:tick(60);assert(r.expired and not r:canEscape(true,true))
-- No objective completion alone ends a round or opens the gate early.
r=Rules.new(false)
for i=1,4 do assert(r:completeGenerator(i));assert(r:completePuzzle(i));assert(r:collectCapsule(i)) end
assert(r.remaining==180 and not r.gateOpen and not r.expired)
-- Check BOTH requirements, including cases with the correct time but missing capsules.
for _,capsules in ipairs({0,1,2}) do
 r=Rules.new(false);r:completeGenerator(1);r:completeGenerator(2)
 for i=1,capsules do r:completePuzzle(i);r:collectCapsule(i) end
 r:tick(r.remaining-40);assert(not r.gateOpen)
end
r=Rules.new(false)
for i=1,3 do r:completePuzzle(i);r:collectCapsule(i) end
r:completeGenerator(1);r:tick(r.remaining-40);assert(not r.gateOpen)
-- LMS always starts at exactly 90; it may extend a low previous clock.
for _,oldTime in ipairs({240,60,12}) do
 r=Rules.new(false);r:tick(240-oldTime)
 assert(r:updateSurvivors(1) and r.mode=="LMS" and r.remaining==90 and not r.gateOpen)
 assert(not r:updateSurvivors(1) and r.remaining==90)
 r:completeGenerator(1);r:completePuzzle(1);assert(r.remaining==90)
 r:tick(89);assert(r.remaining==1 and not r.gateOpen)
 r:tick(1);assert(r.remaining==0 and r.gateOpen and not r.expired)
 r:tick(500);assert(not r.expired and r:canEscape(true,true))
 assert(not r:canEscape(true,false))
end
-- If only one remains after someone exits, the requested LMS rule still applies.
r=Rules.new(false)
for i=1,4 do r:completeGenerator(i);r:completePuzzle(i);r:collectCapsule(i) end
r:tick(140);assert(r.gateOpen)
assert(r:updateSurvivors(1) and not r.gateOpen and r.remaining==90)
-- Studio practice follows normal objective rules without automatically becoming LMS.
r=Rules.new(true);assert(not r:updateSurvivors(1) and r.remaining==240)
-- Assignment chooses exactly one killer, honors survivor choices and rotates ties.
local choices={{key=1,choice="yellowguy"},{key=2,choice="junkbot"},{key=3,choice="deathspeaker"}}
local plan,killer=Assignment.assign(choices,roster)
assert(killer==1 and plan[1].id=="guest666" and plan[2].id=="junkbot")
choices[1].lastKiller=1
plan,killer=Assignment.assign(choices,roster)
assert(killer==2 and plan[1].id=="yellowguy" and plan[3].id=="deathspeaker")
plan,killer=Assignment.assign({{key=1,choice="guest666",lastKiller=2},{key=2,choice="tubers93",lastKiller=1},{key=3,choice="junkbot"}},roster)
assert(killer==2 and plan[1].id=="pelotocino" and plan[2].id=="tubers93" and plan[3].id=="junkbot")
assert(not Assignment.assign({{key=1,choice="junkbot"}},roster))
-- Stamina drains on motion, stops on exhaustion, regenerates and stays in bounds.
local energy=Stamina.new();energy.requested=true
Stamina.step(energy,.5,false);assert(energy.value==100)
for i=1,10 do Stamina.step(energy,.5,true) end
assert(energy.value==0 and energy.exhausted and not energy.running)
Stamina.step(energy,.5,true);assert(energy.value==8 and not energy.running)
energy.requested=false
for i=1,30 do Stamina.step(energy,.5,false) end
assert(energy.value==100 and not energy.exhausted)
'''

FACTORY_MOCK = r'''
local baseIndex=omt.__index
omt.__index=function(self,key)
 if key=="IsA" then return function(o,class) return o.ClassName==class or class=="BasePart" and (o.ClassName=="Part" or o.ClassName=="MeshPart" or o.ClassName=="WedgePart") end end
 if key=="SetAttribute" then return function(o,k,v) o.props.attributes=o.props.attributes or {};o.props.attributes[k]=v end end
 if key=="GetAttribute" then return function(o,k) return o.props.attributes and o.props.attributes[k] end end
 if key=="GetDescendants" then return function(o)
  local result={}
  for _,node in ipairs(nodes) do
   local parent=node.Parent
   while parent do if parent==o then table.insert(result,node);break end;parent=parent.Parent end
  end
  return result
 end end
 if key=="FindFirstChildOfClass" then return function(o,class)
  for _,child in ipairs(o:GetChildren()) do if child.ClassName==class then return child end end
 end end
 local result=baseIndex(self,key)
 if result~=nil then return result end
 if key=="Parent" or key=="Name" then return nil end
 for _,node in ipairs(nodes) do if node.Parent==self and node.Name==key then return node end end
end
local services={ServerStorage={FindFirstChild=function()return nil end},CollectionService={AddTag=function()end}}
game={GetService=function(_,name)return assert(services[name],name)end}
warn=function()end
'''
FACTORY_TESTS = r'''
for _,entry in ipairs(roster) do
 nodes={}
 local m=Factory.create(entry)
 local valid,reason=Factory.validate(m,entry.id)
 assert(valid,entry.id..": "..tostring(reason))
 assert(m:GetAttribute("Placeholder")== (entry.id~="pelotocino") and m:GetAttribute("CharacterIdentity")==entry.id)
 assert(m.HumanoidRootPart.Transparency==1 and not m.HumanoidRootPart.CanCollide)
 local humanoid=m:FindFirstChildOfClass("Humanoid")
 assert(humanoid.RigType==(entry.id=="pelotocino" and "R15" or "R6") and humanoid.Health==100)
 local parts,marks,cane,pack,robot=0,0,false,false,false
 for _,obj in ipairs(m:GetDescendants()) do
  if obj:IsA("BasePart") then assert(not obj.Anchored) end
  if obj:IsA("BasePart") and obj.Name and obj.Name:find("CombatMark_") then marks=marks+1 end
  if obj.Name=="Baston" then cane=true end
  if obj.Name=="Mochila" then pack=true end
  if obj.Name=="Cresta dorsal" then robot=true end
  if obj:IsA("Motor6D") then parts=parts+1;assert(obj.Part0 and obj.Part1) end
 end
 assert(parts==(entry.id=="pelotocino" and 15 or 6))
 assert(marks==((entry.role=="Asesino" or entry.id=="pelotocino") and 0 or 4))
 if entry.id=="yellowguy" then assert(cane and not robot and not pack) end
 if entry.id=="junkbot" then assert(robot and not cane and not pack) end
 if entry.id=="pelotocino" then assert(m:GetAttribute("PelotocinoR15") and not cane and not robot) end
end
-- An official Junkbot may never be installed under Yellow Guy, even with a renamed root.
local wrong=Factory.create(roster[5]);wrong:SetAttribute("SourceBundleId",589);wrong:SetAttribute("CharacterIdentity","yellowguy")
assert(not Factory.validate(wrong,"yellowguy"))
local incomplete=Factory.create(roster[3]);incomplete:FindFirstChild("UpperTorso"):Destroy()
assert(not Factory.validate(incomplete,"pelotocino"))
local disconnected=Factory.create(roster[3])
disconnected.LowerTorso:FindFirstChild("LeftHip").Part1=disconnected.LowerTorso
assert(not Factory.validate(disconnected,"pelotocino"))
'''


def syntax_check():
    for path in sorted((ROOT/'src').rglob('*.luau')):
        source = path.read_text()
        source = re.sub(r'for ([\w, ]+) in (.+?) do', lambda m: m[0] if m[2].startswith(('ipairs(', 'pairs(')) else f'for {m[1]} in pairs({m[2]}) do', source)
        source = re.sub(r'(\b\w+(?:\.\w+)*)\s*([+\-*])=\s*([^;\n]+)', lambda m:f'{m[1]}={m[1]}{m[2]}{m[3]}', source)
        run_lua(source, 'sintaxis adaptada: '+str(path.relative_to(ROOT)), execute=False)


def check_export(target='Forgotten-V4.rbxlx'):
    tree=ET.parse(ROOT/'dist'/target)
    scripts={n.find("Properties/string[@name='Name']").text:n for n in tree.findall('.//Item') if n.attrib['class'] in ['Script','LocalScript','ModuleScript']}
    assert 'Game' in scripts and 'UI' in scripts
    for name in ['World','Objectives']:
        child=scripts['Game'].find("Item/Properties/string[@name='Name'][.='"+name+"']")
        assert child is not None, 'Módulo de servidor perdido: '+name
    for path in (ROOT/'src/shared').glob('*.luau'):
        assert scripts[path.stem].find('Properties/ProtectedString').text==path.read_text()
    for path in (ROOT/'src/server').glob('*.luau'):
        name='Game' if path.name=='init.server.luau' else path.stem
        assert scripts[name].find('Properties/ProtectedString').text==path.read_text()
    assert scripts['UI'].find('Properties/ProtectedString').text==(ROOT/'src/client/init.client.luau').read_text()
    assert len(scripts)==len(list((ROOT/'src').rglob('*.luau')))
    print('PASS: XML, jerarquía Rojo y todas las fuentes incrustadas')


def main():
    from check_v2 import rules_and_rigs
    rules_and_rigs()
    syntax_check()
    check_export()
    print('Validación local V2. Roblox Studio y servicios reales pendientes.')


if __name__=='__main__':
    main()
