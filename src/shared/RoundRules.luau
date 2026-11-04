-- Engine-independent, authoritative rules. No remotes or geometry here.
local Rules = {}
Rules.__index = Rules
Rules.Duration = 240
Rules.LMSDuration = 90
Rules.GeneratorCount = 4
Rules.PuzzleCount = 4
Rules.RequiredGenerators = 2
Rules.RequiredCapsules = 3

function Rules.new(practice)
 return setmetatable({remaining=Rules.Duration, mode=practice and "Practica" or "Normal",
  generators={}, puzzles={}, collected={}, deposited={}, generatorCount=0, puzzleCount=0,
  capsuleCount=0, gateOpen=false, expired=false, lmsStarted=false}, Rules)
end

function Rules:refreshGate()
 if self.mode == "LMS" then
  self.gateOpen = self.remaining <= 0
 elseif self.remaining <= 60 and self.generatorCount >= Rules.RequiredGenerators
  and self.capsuleCount >= Rules.RequiredCapsules then
  self.gateOpen = true
 end
end

local function validId(id, count)
 return type(id)=="number" and id%1==0 and id>=1 and id<=count
end

function Rules:completeGenerator(id)
 if self.expired or not validId(id,4) or self.generators[id] then return false end
 self.generators[id]=true
 self.generatorCount=self.generatorCount+1
 if self.mode~="LMS" then self.remaining=math.max(0,self.remaining-10) end
 self:refreshGate()
 return true
end

function Rules:completePuzzle(id)
 if self.expired or not validId(id,4) or self.puzzles[id] then return false end
 self.puzzles[id]=true
 self.puzzleCount=self.puzzleCount+1
 if self.mode~="LMS" then self.remaining=math.max(0,self.remaining-5) end
 self:refreshGate()
 return true
end

function Rules:collectCapsule(id,carrier)
 if self.expired or self.mode=="LMS" or not self.puzzles[id] or self.collected[id] or self.deposited[id] or carrier==nil then return false end
 self.collected[id]=carrier
 return true
end

function Rules:depositCapsules(carrier)
 local deposited={}
 if self.expired or self.mode=="LMS" then return deposited end
 for id,owner in pairs(self.collected) do
  if owner==carrier and not self.deposited[id] then
   self.deposited[id]=true;self.capsuleCount=self.capsuleCount+1;table.insert(deposited,id)
  end
 end
 self:refreshGate()
 return deposited
end

function Rules:dropCapsules(carrier)
 local dropped={}
 for id,owner in pairs(self.collected) do
  if owner==carrier and not self.deposited[id] then self.collected[id]=nil;table.insert(dropped,id) end
 end
 return dropped
end

function Rules:carried(carrier)
 local count=0
 for id,owner in pairs(self.collected) do if owner==carrier and not self.deposited[id] then count=count+1 end end
 return count
end

function Rules:updateSurvivors(alive)
 -- Practice is an explicit Studio-only mode; it does not simulate an opponent.
 if self.mode=="Practica" or self.lmsStarted or alive~=1 then return false end
 self.lmsStarted=true
 self.mode="LMS"
 self.remaining=Rules.LMSDuration -- exactly 1:30, even if the previous clock was lower
 self.expired=false
 self:refreshGate()
 return true
end

function Rules:tick(dt)
 if self.expired then return end
 self.remaining=math.max(0,self.remaining-math.max(0,dt))
 self:refreshGate()
 -- LMS waits at 0:00 for a physical escape or elimination, never an automatic win.
 if self.mode~="LMS" and self.remaining<=0 then self.expired=true end
end

function Rules:canEscape(isActiveSurvivor, physicallyAcross)
 return isActiveSurvivor and physicallyAcross and self.gateOpen and not self.expired
end

return Rules
