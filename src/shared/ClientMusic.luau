local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")
local Music=require(script.Parent.Music)
return function(label)
 local currentKey,currentSound="",nil
 local started=os.clock()
 local function switch(key,track,looped)
  if key==currentKey then return end
  currentKey=key
  if currentSound then local old=currentSound;TweenService:Create(old,TweenInfo.new(.6),{Volume=0}):Play();task.delay(.65,function()old:Destroy()end);currentSound=nil end
  if not track then label.Text="AMBIENTE EN SILENCIO";return end
  local available=type(track.soundId)=="string" and track.soundId:match("^rbxassetid://%d+$")
  label.Text=track.title..(available and "" or " · audio pendiente")
  if not available then return end
  local s=Instance.new("Sound");s.Name="ForgottenMusic";s.SoundId=track.soundId;s.Looped=looped;s.Volume=0;s.Parent=SoundService;currentSound=s
  s.Loaded:Connect(function()if looped and s.TimeLength>0 then s.TimePosition=(os.clock()-started)%s.TimeLength end end)
  s:Play();TweenService:Create(s,TweenInfo.new(.6),{Volume=.4}):Play()
  task.delay(8,function()if currentSound==s and not s.IsLoaded then label.Text=track.title.." · audio no disponible" end end)
 end
 return function(state)
  local player=Players.LocalPlayer;local c=player.Character;local root=c and c:FindFirstChild("HumanoidRootPart");local h=c and c:FindFirstChildOfClass("Humanoid")
  if state.phase=="Lobby" or (state.phase=="Ronda" and not player:GetAttribute("InRound") and h and h.Health>0) then switch("lobby",Music.lobby,true)
  elseif state.phase~="Ronda" or not root or not h or h.Health<=0 then switch("silent",nil,false)
  elseif state.mode=="LMS" then local key=state.musicKey~="" and state.musicKey or "lastHope";switch(key,Music[key] or Music.lastHope,false)
  elseif state.gateOpen then switch("exit",Music.exit,true)
  else
   local killer=Players:GetPlayerByUserId(state.killerUserId or 0)
   local killerId=killer and killer:GetAttribute("CharacterId")
   local track=killerId=="tubers93" and Music.shadowReaper or killerId=="guest666" and Music.guestChase
   local distance=math.huge
   if track then
    for _,other in ipairs(Players:GetPlayers()) do
     if (player==killer and other~=killer) or (player~=killer and other==killer) then
      local otherChar=other.Character;local otherRoot=otherChar and otherChar:FindFirstChild("HumanoidRootPart")
      if other:GetAttribute("InRound") and otherRoot then distance=math.min(distance,(root.Position-otherRoot.Position).Magnitude) end
     end
    end
   end
   local layer
   if track then for i,item in ipairs(track.layers) do if distance<=item.distance then layer=i end end end
   if layer then local item=track.layers[layer];switch(killerId..":"..layer,{title=track.title.." · "..item.title,soundId=item.soundId},true)
   else switch("silent",nil,false) end
  end
 end
end
