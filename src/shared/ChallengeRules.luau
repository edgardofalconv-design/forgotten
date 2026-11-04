-- Pure server-side challenge state. Caller supplies a trusted clock and RNG.
local Challenge={}
local mazes={
 {"1111111","1000001","1110101","1000101","1011101","1000001","1111111"},
 {"1111111","1000101","1010101","1010001","1011101","1000001","1111111"}}
function Challenge.new(kind,now,random)
 local s={kind=kind,step=1,deadline=now+60,last=-100,sequence={},started=now}
 if kind=="memory" or kind=="piano" or kind=="wires" then
  for i=1,kind=="wires" and 3 or 4 do s.sequence[i]=random(1,4) end
  s.readyAt=now+(kind=="memory" and 2.5 or 0)
 elseif kind=="switches" then
  s.current={false,false,false,false};s.target={true,false,true,true}
 elseif kind=="reflex" then s.readyAt=now+random(15,30)/10
 elseif kind=="rope" then s.readyAt=now+.5;s.pulls=0
 elseif kind=="maze" then s.grid=mazes[random(1,#mazes)];s.x=2;s.y=2;s.moves=0
 else return nil end
 return s
end
function Challenge.input(s,value,now)
 if now>s.deadline then return "expired" end
 if now-s.last<.12 then return "ignored" end
 s.last=now
 if s.kind=="memory" or s.kind=="piano" or s.kind=="wires" then
  if now<s.readyAt then return "ignored" end
  if type(value)~="number" or value~=s.sequence[s.step] then return "wrong" end
  s.step=s.step+1
  return s.step>#s.sequence and "complete" or "progress"
 elseif s.kind=="switches" then
  if type(value)~="number" or value%1~=0 or value<1 or value>4 then return "ignored" end
  s.current[value]=not s.current[value]
  for i=1,4 do if s.current[i]~=s.target[i] then return "progress" end end
  return "complete"
 elseif s.kind=="reflex" then
  if value~="hit" then return "ignored" end
  if now<s.readyAt or now>s.readyAt+1.2 then return "wrong" end
  return "complete"
 elseif s.kind=="rope" then
  if value~="pull" then return "ignored" end
  if now<s.readyAt then return "ignored" end
  local position=((now-s.readyAt)%1.8)/1.8
  if position<.3 or position>.7 then return "wrong" end
  s.pulls=s.pulls+1;s.readyAt=now+.4
  return s.pulls>=3 and "complete" or "progress"
 elseif s.kind=="maze" then
  local directions={up={0,-1},down={0,1},left={-1,0},right={1,0}}
  local d=type(value)=="string" and directions[value]
  if not d then return "ignored" end
  local x,y=s.x+d[1],s.y+d[2]
  if y<1 or y>7 or x<1 or x>7 or s.grid[y]:sub(x,x)=="1" then return "progress" end
  s.x=x;s.y=y;s.moves=s.moves+1
  if s.moves>100 then return "expired" end
  return x==6 and y==6 and "complete" or "progress"
 end
 return "ignored"
end
return Challenge
