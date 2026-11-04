-- Original procedural clips, sampled identically for every observer from server time.
-- Rotation values are radians; translation is in studs. No external AnimationIds required.
local Motion={}
function Motion.jointKey(name)
 local key=name:gsub(" ","")
 return key=="Root" and "RootJoint" or key
end
Motion.profiles={
 pelotocino={stride=.67,pace=1,lean=.06,bob=.045,arms=1},
 yellowguy={stride=.62,pace=.93,lean=.025,bob=.035,arms=.85},
 junkbot={stride=.48,pace=.82,lean=.1,bob=.025,arms=.65},
 deathspeaker={stride=.22,pace=.75,lean=.035,bob=.08,arms=.4},
 guest666={stride=.72,pace=.85,lean=.13,bob=.025,arms=.75},
 tubers93={stride=.7,pace=.91,lean=.1,bob=.035,arms=.65}}
Motion.durations={baconThrow=1.05,pan=.65,cane=.65,caneThrow=1.25,caneRecover=.6,punch=.5,lastFighter=1.6,
 detector=.9,luckyBacon=.9,overdrive=1.1,rocketSlam=1.25,selfRepair=2,plasma=1,shield=1.2,phantom=.7,connection=1.2,
 claw=.6,behind=1.15,sense=1.1,sixthHour=1.5,pounce=1.2,scythe=.75,admin=1.05,hellfire=1.2,whip=.85,spin=.8,inferno=1.3,
 caneGuard=.8,grabbed=1.1,pinned=2,escape=.65}
local function smooth(x)x=math.clamp(x,0,1);return x*x*(3-2*x)end
local function rot(x,y,z,tx,ty,tz)return {x or 0,y or 0,z or 0,tx or 0,ty or 0,tz or 0}end
local function mix(a,b,t)
 local r={};for i=1,6 do r[i]=(a[i] or 0)+((b[i] or 0)-(a[i] or 0))*t end;return r
end
local function bodyAxes(pose)
 -- Clips describe arm flexion as negative; Roblox's downward limbs need +X
 -- to reach toward -Z (forward). Hips/root already use body-space axes.
 for _,name in ipairs({"LeftShoulder","RightShoulder","LeftElbow","RightElbow"}) do
  if pose[name] then pose[name][1]=-pose[name][1] end
 end
 return pose
end
function Motion.toTransform(joint,v)
 -- Native Roblox R6/R15 joints use different C0 axes. Convert body-space poses
 -- to each joint's frame instead of assuming every shoulder/neck is unrotated.
 local basis=joint.C0.Rotation
 return basis:Inverse()*CFrame.new(v[4] or 0,v[5] or 0,v[6] or 0)*CFrame.Angles(v[1],v[2],v[3])*basis
end
function Motion.sample(id,state,phase,speed,action,elapsed,context)
 local p=Motion.profiles[id] or Motion.profiles.pelotocino
 context=context or {};local t=phase*p.pace
 local moving=state=="walk" or state=="run" or state=="sprint"
 local strength=moving and (state=="sprint" and 1.22 or state=="run" and 1 or .73) or 0
 local wave=math.sin(t);local stride=wave*p.stride*strength
 local pose={LeftHip=rot(stride),RightHip=rot(-stride),LeftShoulder=rot(stride*p.arms),RightShoulder=rot(-stride*p.arms),
  Neck=rot(math.sin(t*.32)*.022),RootJoint=rot(-p.lean*strength,math.sin(t)*.025*strength,0,0,math.abs(math.sin(t))*p.bob*strength),
  Waist=rot(-p.lean*strength*.6),LeftElbow=rot(-.12),RightElbow=rot(-.12),LeftKnee=rot(-math.max(0,-stride)*.5),RightKnee=rot(-math.max(0,stride)*.5)}
 if not moving then
  pose.LeftShoulder=rot(math.sin(t)*.035,0,-.025);pose.RightShoulder=rot(-math.sin(t)*.035,0,.025)
  pose.RootJoint=rot(0,0,0,0,math.sin(t*.7)*p.bob*.5)
 end
 if id=="yellowguy" then pose.RightShoulder=rot(-stride*.25-.12,0,.08)
 elseif id=="junkbot" then pose.LeftElbow=rot(-.3);pose.RightElbow=rot(-.3);pose.Neck=rot(.035,math.sin(t*.17)*.06)
 elseif id=="deathspeaker" then pose.RootJoint[5]=.09+math.sin(t*.6)*.065;pose.LeftShoulder=rot(-.15,0,-.18);pose.RightShoulder=rot(-.15,0,.18)
 elseif id=="guest666" then pose.Neck=rot(.1,-.08+math.sin(t*.25)*.025);pose.LeftShoulder[3]=-.09;pose.RightShoulder[3]=.09
 elseif id=="tubers93" then pose.RightShoulder=rot(-.28-stride*.18,0,.16);pose.RightElbow=rot(-.3) end
 if state=="jump" then
  pose.LeftShoulder=rot(-.85,0,-.2);pose.RightShoulder=rot(-.75,0,.2);pose.LeftHip=rot(-.5);pose.RightHip=rot(.25);pose.RootJoint=rot(-.12)
 elseif state=="fall" then
  pose.LeftShoulder=rot(-.2,0,-.65);pose.RightShoulder=rot(-.2,0,.65);pose.LeftHip=rot(.15);pose.RightHip=rot(.15)
 elseif state=="land" then
  local f=1-smooth((context.stateTime or 0)/.28)
  pose.RootJoint=rot(-.23*f,0,0,0,-.18*f);pose.LeftHip=rot(.35*f);pose.RightHip=rot(.35*f)
 elseif state=="hit" then pose.RootJoint=rot(.2,0,-.08);pose.Neck=rot(-.25);pose.LeftShoulder=rot(-.4)
 elseif state=="stun" then pose.RootJoint=rot(-.3,0,math.sin(phase*1.5)*.045);pose.Neck=rot(.25);pose.LeftShoulder=rot(.2);pose.RightShoulder=rot(.2)
 elseif state=="death" then
  local f=smooth((context.stateTime or 0)/.9)
  pose.RootJoint=rot(.1*f,0,-1.3*f,0,-.6*f);pose.Neck=rot(-.2*f);pose.LeftHip=rot(.5*f);pose.RightHip=rot(-.15*f);pose.RightShoulder=rot(-.3*f)
  return bodyAxes(pose)
 elseif state=="repairGenerator" then
  local stage=context.repairStage or 1
  pose.RootJoint=rot(-.13);pose.Neck=rot(.23)
  pose.LeftShoulder=rot(-.8,0,-.2);pose.RightShoulder=rot(-.8,0,.2)
  if stage==1 then pose.RightShoulder[1]=-.8+math.sin(phase*1.7)*.1;pose.RightElbow=rot(-.5)
  elseif stage==2 then pose.RightShoulder=rot(-1.25+math.sin(phase)*.08,0,.1)
  else
   local pull=context.pullElapsed or 100
   pose.RightShoulder=rot(-.9+(pull<.4 and math.sin(pull/.4*math.pi)*1.1 or 0),0,.16)
  end
 elseif state=="medkit" then
  pose.LeftShoulder=rot(-.8,0,-.35);pose.RightShoulder=rot(-.75+math.sin(phase*2)*.15,0,.45);pose.Neck=rot(.28);pose.LeftElbow=rot(-.9);pose.RightElbow=rot(-.9)
 elseif state=="drink" then pose.RightShoulder=rot(-2.1,0,-.12);pose.RightElbow=rot(-1.1);pose.Neck=rot(-.1)
 end
 local duration=Motion.durations[action]
 if not duration or elapsed<0 or elapsed>duration then return bodyAxes(pose) end
 local fade=math.min(smooth(elapsed/.08),1-smooth((elapsed-duration+.15)/.15));local target={}
 local strike=math.sin(math.clamp(elapsed/.55,0,1)*math.pi)
 if action=="baconThrow" then
  if elapsed<.3 then target.RightShoulder=rot(-2.3,0,-.5);target.RightElbow=rot(-.8);target.Neck=rot(0,-.12)
  elseif elapsed<.45 then target.RightShoulder=rot(-2.5,.2,.18);target.RootJoint=rot(0,-.2)
  else target.RightShoulder=rot(-1.3+(elapsed-.45)*1.8,0,.05);target.RootJoint=rot(-.12,.12) end
 elseif action=="pan" or action=="cane" or action=="scythe" or action=="claw" or action=="punch" then
  local impact=action=="scythe" and .28 or .22
  local f=smooth(elapsed/impact)
  target.RightShoulder=rot(-1.25+f*.9,-.3+f*.8,-.65+f*1.3);target.RootJoint=rot(-.07,-.35+f*.7)
  if action=="claw" then target.LeftShoulder=rot(-.6,-.1,-.3) end
 elseif action=="caneThrow" then target.RightShoulder=rot(elapsed<.28 and -2.2 or -.9,0,.12);target.RootJoint=rot(-.1,elapsed<.28 and -.22 or .18)
 elseif action=="caneRecover" then target.RightShoulder=rot(-.7,0,.28);target.RightElbow=rot(-.8)
 elseif action=="detector" or action=="sense" then target.RightShoulder=rot(-1.8,0,.4);target.Neck=rot(0,math.sin(elapsed*5)*.35)
 elseif action=="selfRepair" then target.LeftShoulder=rot(-.8,0,-.35);target.RightShoulder=rot(-.7+math.sin(elapsed*18)*.08,0,.45);target.Neck=rot(.35)
 elseif action=="overdrive" then target.RootJoint=rot(-.35);target.LeftShoulder=rot(.5,0,-.1);target.RightShoulder=rot(-.75,0,.1);target.Neck=rot(.15)
 elseif action=="rocketSlam" or action=="pounce" then
  target.RootJoint=rot(elapsed<.5 and -.3 or .15);target.LeftShoulder=rot(elapsed<.5 and -2.1 or -.5,0,-.2);target.RightShoulder=rot(elapsed<.5 and -2.1 or -.5,0,.2)
  target.LeftHip=rot(elapsed<.5 and -.5 or .3);target.RightHip=rot(elapsed<.5 and -.5 or .3)
 elseif action=="plasma" or action=="inferno" then
  target.RightShoulder=rot(-1.55,0,.1);target.LeftShoulder=rot(-1.1,0,-.6);target.RootJoint=rot(elapsed<.45 and .12 or -.1);target.RightElbow=rot(elapsed<.45 and -.7 or -.05)
 elseif action=="shield" or action=="caneGuard" then target.LeftShoulder=rot(-1.15,0,-.55);target.RightShoulder=rot(-1.15,0,.55);target.RootJoint=rot(-.1)
 elseif action=="phantom" then target.RootJoint=rot(-.25,elapsed*1.8);target.LeftShoulder=rot(.35,0,-.22);target.RightShoulder=rot(.35,0,.22)
 elseif action=="behind" then target.RightShoulder=rot(elapsed<.5 and -1.5 or -.55,0,.2);target.LeftShoulder=rot(-1.2,0,-.15);target.RootJoint=rot(-.1,elapsed<.5 and -.18 or .2)
 elseif action=="whip" then target.RightShoulder=rot(-2.1+strike*1.2,0,-.2+strike*.7);target.RootJoint=rot(-.1,-.25+strike*.5)
 elseif action=="spin" then target.RootJoint=rot(0,elapsed/.8*math.pi*2);target.RightShoulder=rot(-.5,0,1.3);target.LeftShoulder=rot(-.2,0,-.6)
 elseif action=="lastFighter" or action=="sixthHour" or action=="hellfire" or action=="admin" or action=="connection" then
  target.LeftShoulder=rot(-.3,0,-.5-strike*.4);target.RightShoulder=rot(-.3,0,.5+strike*.4);target.Neck=rot(-.18);target.RootJoint=rot(.09)
 elseif action=="grabbed" or action=="pinned" then target.RootJoint=rot(-.55,0,.1);target.LeftShoulder=rot(-1.3,0,-.35);target.RightShoulder=rot(-1.3,0,.35)
 elseif action=="escape" then target.RootJoint=rot(-.25);target.LeftShoulder=rot(-1.3,0,-.6);target.RightShoulder=rot(.7,0,.6)
 elseif action=="luckyBacon" then target.RightShoulder=rot(-1.8,0,-.2) end
 for joint,value in pairs(target) do pose[joint]=mix(pose[joint] or rot(),value,fade) end
 return bodyAxes(pose)
end
function Motion.presentation(id,kind,time)
 local p=Motion.sample(id,"idle",time*2,0,"",100)
 if kind=="victory" and id=="guest666" then
  p.RootJoint=rot(-.12,math.sin(time*.5)*.12);p.Neck=rot(.18,math.sin(time*.8)*.15)
  p.LeftShoulder=rot(.65,0,-.27);p.RightShoulder=rot(.95-math.sin(time*2)*.1,0,.32)
 elseif kind=="victory" and id=="tubers93" then
  p.RightShoulder=rot(1.4,0,.45);p.RootJoint=rot(.02,math.sin(time*.7)*.14);p.LeftShoulder=rot(.3,0,-.18)
 elseif kind=="mvp" then p.RightShoulder=rot(2.15,0,.2);p.LeftShoulder=rot(.15,0,-.15);p.Neck=rot(-.08)
 else p.RightShoulder=rot(.3,0,.1) end
 return p
end
return Motion
