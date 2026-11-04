-- V1-approved values are retained where available. Additional V2 values are experimental.
-- Q/R/F/G/T/Y map to slots. M1 uses the first killer ability.
local function a(id,name,icon,kind,cooldown,range,amount,duration,cost)
 return {id=id,name=name,icon=icon,kind=kind,cooldown=cooldown,range=range or 0,amount=amount or 0,duration=duration or 0,cost=cost or 0,provisional=true}
end
return {
 keys={"Q","R","F","G","T","Y"},
 pelotocino={
  a("detector","Killer Detector","◎","reveal",24,100,0,6,10),
  a("baconThrow","Bacon Throw","↗","bacon",18,32,15,2,10),
  a("pan","Golpe de sartén","◒","stun",16,9,6,2.5,10),
  a("luckyBacon","Lucky Bacon","✚","heal",25,0,25,0,10)},
 yellowguy={
  a("cane","Golpe de bastón","╱","stun",18,12,6,3,10),
  a("caneGuard","Guardia del bastón","◇","shield",24,0,.5,4,15),
  a("lastFighter","Last Fighter","★","lastFighter",40,0,15,5,20),
  a("caneThrow","Lanzar bastón","↗","caneThrow",18,28,6,3,10)},
 junkbot={
  a("overdrive","Overdrive Rush","»","speed",18,0,28,4,15),
  a("rocketSlam","Rocket Slam","↓","slam",24,12,12,2,20),
  a("selfRepair","Self Repair","⚙","repair",25,0,25,2,10)},
 deathspeaker={
  a("plasma","Plasma Ray","━","ray",18,50,12,2,15),
  a("shield","Super Shield","⬡","teamShield",25,18,.45,5,20),
  a("phantom","Phantom Step","↝","step",20,14,0,.35,15),
  a("connection","Haunted Connection","∞","teamHeal",25,24,20,3,15)},
 guest666={
  a("claw","Cursed Claw","≋","melee",1.2,8,25,0,0),
  a("behind","Behind You","↶","behind",24,28,0,0,20),
  a("sense","Sixth Sense","◎","reveal",22,90,0,6,10),
  a("sixthHour","The Sixth Hour","Ⅵ","speed",14,0,28,4,15),
  a("pounce","Demonic Pounce","↟","pounce",22,12,20,.5,20)},
 tubers93={
  a("scythe","Guadaña","☽","melee",1.2,8,25,0,0),
  a("admin","Admin Abuse","!","areaSlow",22,20,6,3,20),
  a("hellfire","Hellfire","♨","fire",26,9,5,4,20),
  a("whip","Death Whip","⌁","pull",20,26,12,1.5,15),
  a("spin","Reaper's Spin","↻","areaDamage",18,24,20,0,20),
  a("inferno","Inferno Blast","✹","blast",32,55,18,0,25)}
}
