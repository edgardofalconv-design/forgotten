-- ONLY in a new empty Baseplate; place this Script in ServerScriptService.
-- Insert Pelotocino.rbxmx into Workspace before pressing Play.
local RunService = game:GetService("RunService")
assert(RunService:IsStudio(), "Test restricted to Studio")
local character = workspace:WaitForChild("Pelotocino", 15)
assert(character, "Insert Pelotocino into Workspace")
local humanoid = character:FindFirstChildOfClass("Humanoid")
assert(humanoid and humanoid.RigType == Enum.HumanoidRigType.R15, "Missing R15 Humanoid")
local root = character:FindFirstChild("HumanoidRootPart")
assert(root and character.PrimaryPart == root, "Invalid root")
local motors = 0
for _, object in character:GetDescendants() do
    if object:IsA("Motor6D") then
        motors += 1
        assert(object.Part0 and object.Part1, "Disconnected motor: " .. object.Name)
    elseif object:IsA("BasePart") then
        assert(not object.Anchored, "Anchored part: " .. object.Name)
    end
end
assert(motors == 15, "Expected 15 Motor6Ds")
print("Pelotocino: estructura R15 correcta. Iniciando prueba de movimiento.")
local origin = root.Position
for _, speed in ipairs({12, 22}) do
    humanoid.WalkSpeed = speed
    local destination = origin + Vector3.new(speed == 12 and 12 or -12, 0, 0)
    humanoid:MoveTo(destination)
    local finished = humanoid.MoveToFinished:Wait()
    print("Movimiento", speed, "destino alcanzado:", finished)
    assert(finished, "No llegó al destino; revisar suelo, colisiones y rig")
end
humanoid.Jump = true
task.wait(1)
print("Salto solicitado: revisar visualmente flexión, aterrizaje, cara, pelo y mochila.")
humanoid.WalkSpeed = 12
