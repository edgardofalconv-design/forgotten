-- These views are produced by Roblox from the installed avatar, never renders.
local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "PelotocinoVisualReview"
gui.IgnoreGuiInset = false
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local background = Instance.new("Frame")
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(17, 22, 29)
background.Parent = gui

local function label(parent, text, pos, size)
	local item = Instance.new("TextLabel")
	item.Text = text
	item.Position = pos
	item.Size = size
	item.BackgroundTransparency = 1
	item.TextColor3 = Color3.fromRGB(230, 234, 242)
	item.Font = Enum.Font.Gotham
	item.TextSize = 17
	item.TextWrapped = true
	item.Parent = parent
	return item
end

label(background, "PELOTOCINO  /  REVISIÓN VISUAL R15", UDim2.fromScale(0.02, 0.01), UDim2.fromScale(0.96, 0.07))
local active = workspace:GetAttribute("PelotocinoVisualActive")
local stage = active and workspace:WaitForChild(active, 15)
if not stage or not stage:GetAttribute("ReadyForVisualReview") then
	label(background, "Falta montar el avatar nativo.\nDetén Play e instala el R15 y el FBX siguiendo LEEME.\nEste taller no contiene un cuerpo sustituto.", UDim2.fromScale(0.12, 0.22), UDim2.fromScale(0.76, 0.5))
	return
end
local original = stage:WaitForChild("Pelotocino_Visual", 15)
if not original then return end
label(background, "Avatar montado en Roblox · sin animaciones · apariencia pendiente de aprobación", UDim2.fromScale(0.02, 0.08), UDim2.fromScale(0.96, 0.05))
local views = {{"FRENTE", Vector3.new(0, 0, -1)}, {"LATERAL", Vector3.new(1, 0, 0)}, {"ESPALDA", Vector3.new(0, 0, 1)}}
for i, spec in ipairs(views) do
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = spec[1]
	viewport.Position = UDim2.fromScale(0.02 + (i - 1) * 0.325, 0.16)
	viewport.Size = UDim2.fromScale(0.31, 0.72)
	viewport.BackgroundColor3 = Color3.fromRGB(33, 39, 48)
	viewport.Ambient = Color3.fromRGB(200, 206, 216)
	viewport.LightColor = Color3.fromRGB(255, 238, 218)
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.Parent = background
	local world = Instance.new("WorldModel"); world.Parent = viewport
	local avatar = original:Clone(); avatar.Parent = world; avatar:PivotTo(CFrame.new())
	local camera = Instance.new("Camera"); camera.FieldOfView = 32; camera.Parent = viewport
	viewport.CurrentCamera = camera
	local cf, size = avatar:GetBoundingBox()
	local function fit()
		local aspect = viewport.AbsoluteSize.X / math.max(1, viewport.AbsoluteSize.Y)
		local half = math.max(size.Y / 2, math.max(size.X, size.Z) / (2 * aspect))
		local distance = half / math.tan(math.rad(camera.FieldOfView / 2)) + math.max(size.X, size.Z) / 2
		camera.CFrame = CFrame.lookAt(cf.Position + spec[2] * distance * 1.08, cf.Position)
	end
	viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()
	label(background, spec[1], UDim2.fromScale(0.02 + (i - 1) * 0.325, 0.89), UDim2.fromScale(0.31, 0.04))
end
label(background, "Captura estas tres vistas con Win + Mayús + S. Para revisar materiales PBR y el ajuste de la mochila, usa también el visor 3D de Studio.", UDim2.fromScale(0.02, 0.94), UDim2.fromScale(0.96, 0.05))
