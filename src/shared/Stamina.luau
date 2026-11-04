local Stamina = {}
Stamina.Maximum=100
Stamina.Drain=20
Stamina.Regen=16
Stamina.Restart=25

function Stamina.new()
 return {value=100, requested=false, exhausted=false, running=false}
end

function Stamina.step(state,dt,moving,infinite)
 if infinite then state.value=100;state.exhausted=false;state.running=state.requested and moving;return state.value,state.running end
 dt=math.max(0,math.min(dt,0.5))
 state.running=state.requested and moving and not state.exhausted and state.value>0
 if state.running then state.value=math.max(0,state.value-Stamina.Drain*dt)
 else state.value=math.min(Stamina.Maximum,state.value+Stamina.Regen*dt) end
 if state.value<=0 then state.exhausted=true;state.running=false
 elseif state.value>=Stamina.Restart then state.exhausted=false end
 return state.value,state.running
end

return Stamina
