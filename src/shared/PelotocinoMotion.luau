-- Original R15 motion. Positive arm X reaches forward (-Z); no copied clips.
local Motion={durations={pan=.72,baconThrow=1.15,detector=1.6}}
local function p(x,y,z,tx,ty,tz)return {x or 0,y or 0,z or 0,tx or 0,ty or 0,tz or 0}end
local function smooth(t)t=math.clamp(t,0,1);return t*t*(3-2*t)end
local clips={
 pan={
 {0,{RightShoulder=p(.1),RightElbow=p(.12)}},
 {.12,{RightShoulder=p(.25,-.8,.65),RightElbow=p(.65),Waist=p(0,-.32),LeftShoulder=p(.4,0,-.25)}},
 {.22,{RightShoulder=p(1.45,.2,-.1),RightElbow=p(.12),RightWrist=p(0,0,.12),Waist=p(-.08,.25)}},
 {.37,{RightShoulder=p(1.2,.65,-.5),RightElbow=p(.25),Waist=p(-.08,.4)}},
 {.72,{RightShoulder=p(.1),RightElbow=p(.12)}}},
 baconThrow={
 {0,{LeftShoulder=p(.1),RightShoulder=p(.1)}},
 {.12,{LeftShoulder=p(2.55,0,.55),LeftElbow=p(.75),Neck=p(.12,-.1),RightShoulder=p(.2,-.4,.45)}},
 {.24,{LeftShoulder=p(1.55,0,.40),LeftElbow=p(.25),LeftWrist=p(0,0,-.3),RightShoulder=p(.3,-.75,.65),RightElbow=p(.7),Waist=p(0,-.3)}},
 {.36,{LeftShoulder=p(1.2,.1,.35),LeftElbow=p(.12),RightShoulder=p(.75,-.55,.35),RightElbow=p(.45),Waist=p(-.05,-.15)}},
 {.45,{LeftShoulder=p(.8,0,-.7),LeftElbow=p(.4),RightShoulder=p(1.5,.18,-.12),RightElbow=p(.08),Waist=p(-.08,.28)}},
 {.62,{LeftShoulder=p(.4,0,-.3),RightShoulder=p(1.4,.7,-.45),RightElbow=p(.18),Waist=p(-.05,.38)}},
 {1.15,{LeftShoulder=p(.05),RightShoulder=p(.05),LeftElbow=p(.12),RightElbow=p(.12),Waist=p()}}},
 detector={
 {0,{LeftShoulder=p(.1)}},
 {.23,{LeftShoulder=p(.3,0,-.12),LeftElbow=p(.6),Neck=p(.12)}},
 {.5,{LeftShoulder=p(.85,0,-.15),LeftElbow=p(.85),LeftWrist=p(.1,0,.2),Neck=p(.25),RightShoulder=p(.7,0,.3),RightElbow=p(.9)}},
 {.8,{LeftShoulder=p(.85,0,-.15),LeftElbow=p(.85),Neck=p(.18),RightShoulder=p(.65,0,.3),RightElbow=p(.8)}},
 {1.15,{LeftShoulder=p(.85,0,-.15),LeftElbow=p(.85),Neck=p(.16,.14)}},
 {1.6,{LeftShoulder=p(.1),LeftElbow=p(.12),Neck=p()}}}}
local function keyframes(frames,t)
 local a,b=frames[1],frames[#frames]
 for i=2,#frames do if t<=frames[i][1] then a,b=frames[i-1],frames[i];break end end
 local f=smooth((t-a[1])/math.max(.001,b[1]-a[1]));local result={}
 for _,frame in ipairs({a,b})do for key in pairs(frame[2])do
  if not result[key]then local x,y=a[2][key] or p(),b[2][key] or p();local out={}
   for i=1,6 do out[i]=x[i]+(y[i]-x[i])*f end;result[key]=out
  end
 end end
 return result
end
function Motion.sample(state,phase,speed,action,elapsed,context)
 context=context or {};local run=state=="run" or state=="sprint";local moving=run or state=="walk"
 local a=moving and (run and .80 or .48) or 0;local wave=math.sin(phase);local stride=wave*a
 local pose={RootJoint=p(run and -.14 or 0,0,moving and wave*.025 or math.sin(phase*.3)*.012,0,moving and math.abs(math.sin(phase))*.045 or math.sin(phase*.65)*.018),
 Waist=p(run and -.07 or 0,moving and wave*.055 or math.sin(phase*.2)*.025),Neck=p(run and .09 or math.sin(phase*.4)*.015,0),
 LeftShoulder=p(-stride,0,-.035),RightShoulder=p(stride,0,.035),LeftElbow=p(run and .85 or .18),RightElbow=p(run and .85 or .18),LeftWrist=p(),RightWrist=p(),
 LeftHip=p(stride),RightHip=p(-stride),LeftKnee=p(-math.max(0,-wave)*(run and .95 or .35)),RightKnee=p(-math.max(0,wave)*(run and .95 or .35)),LeftAnkle=p(-stride*.25),RightAnkle=p(stride*.25)}
 if not moving then pose.LeftShoulder[1]=math.sin(phase*.65)*.025;pose.RightShoulder[1]=-pose.LeftShoulder[1] end
 if state=="jump"then pose.LeftHip=p(.3);pose.RightHip=p(-.25);pose.LeftShoulder=p(.65,0,-.25);pose.RightShoulder=p(.65,0,.25);pose.LeftKnee=p(-.6);pose.RightKnee=p(-.3)
 elseif state=="fall"then pose.LeftShoulder=p(.2,0,-.7);pose.RightShoulder=p(.2,0,.7);pose.LeftKnee=p(-.3);pose.RightKnee=p(-.3)
 elseif state=="hit"then pose.RootJoint=p(.17,0,.08);pose.Waist=p(.15);pose.Neck=p(-.18);pose.LeftShoulder=p(.4,0,-.2);pose.RightShoulder=p(.35,0,.2)
 elseif state=="stun"then pose.RootJoint=p(-.24,0,math.sin(phase)*.04);pose.Neck=p(.23)
 elseif state=="land"then local f=1-smooth((context.stateTime or 0)/.28);pose.RootJoint=p(-.12*f,0,0,0,-.12*f);pose.LeftKnee=p(-.35*f);pose.RightKnee=p(-.35*f)
 elseif state=="death"then local f=smooth((context.stateTime or 0)/.9);pose.RootJoint=p(.1*f,0,-1.3*f,0,-.6*f);return pose
 elseif state=="repairGenerator"or state=="medkit"then pose.LeftShoulder=p(.75,0,-.25);pose.RightShoulder=p(.8+math.sin(phase*1.5)*.12,0,.2);pose.LeftElbow=p(.7);pose.RightElbow=p(.55);pose.Neck=p(.18)
 elseif state=="drink"then pose.RightShoulder=p(1.3);pose.RightElbow=p(1.2);pose.Neck=p(-.12) end
 local frames=clips[action];local duration=Motion.durations[action]
 if state~="hit"and state~="stun"and frames and elapsed>=0 and elapsed<duration then
  local weight=math.min(smooth(elapsed/.06),smooth((duration-elapsed)/.08))
  for key,value in pairs(keyframes(frames,elapsed))do
   local base=pose[key] or p();for i=1,6 do value[i]=base[i]+(value[i]-base[i])*weight end;pose[key]=value
  end
 elseif action=="luckyBacon"and elapsed>=0 and elapsed<.9 then pose.LeftShoulder=p(1.5);pose.LeftElbow=p(.8) end
 return pose
end
-- Render/equipment timing uses exactly the server's unchanged .45 s release.
function Motion.equipment(action,t)
 local throwing=action=="baconThrow"and t>=0 and t<1.15
 return {pan=(action=="pan"and t>=0 and t<.72)or throwing,
  tracker=action=="detector"and t>=0 and t<1.6,
  tuftRemoved=throwing and t>=.12 and t<1.02,tuftInHand=throwing and t>=.12 and t<.36,
  tuftTossed=throwing and t>=.36 and t<.45}
end
return Motion
