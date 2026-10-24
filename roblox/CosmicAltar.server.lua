-- Altar cósmico morado (portal en espiral, anillos orbitales, cristales flotantes)
-- USO: en Roblox Studio crea un Script en ServerScriptService, pega esto y dale a Play.
-- Se construye en (0, 0, -45); cambia ORIGIN para moverlo. Mira hacia +Z.

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local ORIGIN = Vector3.new(0, 0, -45)
local ROOT = CFrame.new(ORIGIN)

local DARK = Color3.fromRGB(22, 18, 38)
local DARK2 = Color3.fromRGB(38, 30, 62)
local PURPLE = Color3.fromRGB(150, 70, 255)
local VIOLET = Color3.fromRGB(190, 130, 255)
local WHITE = Color3.fromRGB(235, 225, 255)

local old = workspace:FindFirstChild("CosmicAltar")
if old then old:Destroy() end
local altar = Instance.new("Model")
altar.Name = "CosmicAltar"
altar.Parent = workspace

-- ───────── ambiente ─────────
Lighting.ClockTime = 0
Lighting.Ambient = Color3.fromRGB(70, 55, 120)
Lighting.OutdoorAmbient = Color3.fromRGB(70, 55, 120)
Lighting.Brightness = 1
local atm = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
atm.Color = Color3.fromRGB(110, 80, 200)
atm.Decay = Color3.fromRGB(70, 40, 140)
atm.Density = 0.3
local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect", Lighting)
bloom.Intensity = 1.2
bloom.Size = 30
bloom.Threshold = 1.4

-- ───────── helpers ─────────
local function part(parent, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local function neon(parent, size, cf, color)
	return part(parent, size, cf, color or PURPLE, Enum.Material.Neon)
end

local function glow(p, color, range, brightness)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range
	l.Brightness = brightness
	l.Parent = p
end

-- modelo animable: pivote en un Part invisible, las piezas se construyen en espacio local
local function animModel(name)
	local m = Instance.new("Model")
	m.Name = name
	local pivot = part(m, Vector3.new(0.1, 0.1, 0.1), CFrame.new(), DARK)
	pivot.Transparency = 1
	pivot.CanCollide = false
	m.PrimaryPart = pivot
	m.Parent = altar
	return m
end

-- ───────── suelo ─────────
local ground = part(altar, Vector3.new(0.4, 110, 110), ROOT * CFrame.new(0, 0.2, 0) * CFrame.Angles(0, 0, math.pi / 2),
	Color3.fromRGB(78, 72, 112), Enum.Material.Slate, Enum.PartType.Cylinder)
ground.Name = "Ground"

-- ───────── base y rampa ─────────
part(altar, Vector3.new(16, 1, 24), ROOT * CFrame.new(0, 0.9, 0), DARK, Enum.Material.Slate)
part(altar, Vector3.new(12, 1, 20), ROOT * CFrame.new(0, 1.9, -0.5), DARK2, Enum.Material.Slate)

local rampCF = ROOT * CFrame.new(0, 4.2, 2) * CFrame.Angles(math.rad(14), 0, 0)
part(altar, Vector3.new(8, 1, 16), rampCF, DARK, Enum.Material.Slate)
for _, sx in ipairs({ -4.1, 4.1 }) do
	neon(altar, Vector3.new(0.35, 0.35, 16), rampCF * CFrame.new(sx, 0.5, 0))
end
neon(altar, Vector3.new(8.4, 0.35, 0.35), rampCF * CFrame.new(0, 0.5, 8))

-- creciente lunar en la rampa
for i = 0, 8 do
	local a = math.rad(-60 + i * 15)
	local r = 2
	neon(altar, Vector3.new(0.45, 0.2, 0.45), rampCF * CFrame.new(math.sin(a) * r, 0.55, 3 - math.cos(a) * r), VIOLET)
end
-- estrellas
local rng = Random.new(7)
for _ = 1, 22 do
	neon(altar, Vector3.new(0.22, 0.12, 0.22), rampCF * CFrame.new(rng:NextNumber(-3, 3), 0.53, rng:NextNumber(-7, -1)), WHITE)
end
-- flecha / chevrones
for i = 0, 2 do
	neon(altar, Vector3.new(2.2, 0.15, 0.3), rampCF * CFrame.new(0, 0.53, -5 + i * 1.1) , PURPLE)
end

-- ───────── panel trasero + pilares ─────────
local backCF = ROOT * CFrame.new(0, 9, -8)
part(altar, Vector3.new(8, 8, 1), backCF, DARK, Enum.Material.Slate)
local frame = {
	{ Vector3.new(8.4, 0.4, 0.4), Vector3.new(0, 4.1, 0.6) },
	{ Vector3.new(8.4, 0.4, 0.4), Vector3.new(0, -4.1, 0.6) },
	{ Vector3.new(0.4, 8.4, 0.4), Vector3.new(-4.1, 0, 0.6) },
	{ Vector3.new(0.4, 8.4, 0.4), Vector3.new(4.1, 0, 0.6) },
}
for _, f in ipairs(frame) do neon(altar, f[1], backCF * CFrame.new(f[2])) end
-- galaxia en el panel
local gal = neon(altar, Vector3.new(4.5, 1.4, 0.3), backCF * CFrame.new(0, 0, 0.6) * CFrame.Angles(0, 0, math.rad(-20)), PURPLE)
neon(altar, Vector3.new(2.5, 0.5, 0.3), backCF * CFrame.new(0.4, 0.2, 0.65) * CFrame.Angles(0, 0, math.rad(-20)), WHITE)
glow(gal, PURPLE, 18, 3)
for _ = 1, 14 do
	neon(altar, Vector3.new(0.18, 0.18, 0.2), backCF * CFrame.new(rng:NextNumber(-3.4, 3.4), rng:NextNumber(-3.4, 3.4), 0.6), WHITE)
end

for _, sx in ipairs({ -6, 6 }) do
	part(altar, Vector3.new(1.6, 11, 1.6), ROOT * CFrame.new(sx, 6.5, -8), DARK, Enum.Material.Slate)
	neon(altar, Vector3.new(0.3, 11, 0.3), ROOT * CFrame.new(sx * 0.9, 6.5, -7.1), PURPLE)
end

-- ───────── portal en espiral ─────────
local portalCF = ROOT * CFrame.new(0, 19, -8)
-- arco oscuro fijo
for i = 0, 23 do
	local a = i / 24 * math.pi * 2
	part(altar, Vector3.new(1.4, 1.4, 1.4), portalCF * CFrame.new(math.cos(a) * 5.8, math.sin(a) * 5.8, 0) * CFrame.Angles(0, 0, a), DARK2, Enum.Material.Slate)
end
for i = 0, 47 do
	local a = i / 48 * math.pi * 2
	neon(altar, Vector3.new(0.4, 0.4, 0.4), portalCF * CFrame.new(math.cos(a) * 4.9, math.sin(a) * 4.9, 0.2), VIOLET)
end

local spiral = animModel("Spiral")
for i = 0, 70 do
	local t = i / 70
	local a = t * math.pi * 2 * 3.2
	local r = 0.5 + t * 4
	local s = 0.45 + t * 0.35
	neon(spiral, Vector3.new(s, s, 0.6), CFrame.new(math.cos(a) * r, math.sin(a) * r, 0), t > 0.6 and VIOLET or PURPLE)
end
local core = neon(spiral, Vector3.new(1.4, 1.4, 1.4), CFrame.new(), WHITE)
core.Shape = Enum.PartType.Ball
glow(core, PURPLE, 40, 4)

local emitter = Instance.new("ParticleEmitter")
emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
emitter.Color = ColorSequence.new(VIOLET, WHITE)
emitter.LightEmission = 1
emitter.Rate = 25
emitter.Lifetime = NumberRange.new(2, 4)
emitter.Speed = NumberRange.new(2, 5)
emitter.SpreadAngle = Vector2.new(180, 180)
emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
emitter.Parent = core

-- ───────── anillos orbitales ─────────
local rings = {}
local ringDefs = {
	{ pos = Vector3.new(-8, 17, -4), r = 2.6, tilt = math.rad(30), speed = 1.2 },
	{ pos = Vector3.new(9, 19, -3), r = 2.2, tilt = math.rad(-40), speed = -1.5 },
	{ pos = Vector3.new(-5, 11, 4), r = 1.8, tilt = math.rad(60), speed = 1.8 },
}
for _, d in ipairs(ringDefs) do
	local m = animModel("Ring")
	for i = 0, 15 do
		local a = i / 16 * math.pi * 2
		neon(m, Vector3.new(0.5, 0.25, 0.9), CFrame.new(math.cos(a) * d.r, 0, math.sin(a) * d.r) * CFrame.Angles(0, -a, 0), PURPLE)
	end
	local planet = neon(m, Vector3.new(1.1, 1.1, 1.1), CFrame.new(), VIOLET)
	planet.Shape = Enum.PartType.Ball
	glow(planet, PURPLE, 10, 2)
	rings[#rings + 1] = { model = m, def = d }
end

-- ───────── cristales flotantes ─────────
local crystals = {}
for i = 1, 12 do
	local a = i / 12 * math.pi * 2
	local c = neon(altar, Vector3.new(0.7, 1.3, 0.7), CFrame.new(), WHITE)
	c.Name = "Crystal"
	glow(c, VIOLET, 8, 1.5)
	crystals[#crystals + 1] = {
		part = c,
		base = Vector3.new(math.cos(a) * rng:NextNumber(5, 10), rng:NextNumber(4, 18), math.sin(a) * rng:NextNumber(3, 9) - 2),
		phase = rng:NextNumber(0, 6.28),
	}
end

-- ───────── escombros ─────────
for _ = 1, 70 do
	local s = rng:NextNumber(0.4, 1.4)
	local x, z = rng:NextNumber(-10, 10), rng:NextNumber(-12, 10)
	if math.abs(x) > 4.5 or z < -6 then
		part(altar, Vector3.new(s, s, s), ROOT * CFrame.new(x, s / 2 + 0.2, z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0),
			rng:NextInteger(0, 1) == 0 and DARK or DARK2, Enum.Material.Slate)
		if rng:NextNumber() < 0.35 then
			neon(altar, Vector3.new(0.25, 0.25, 0.25), ROOT * CFrame.new(x + s / 2, s * 0.6 + 0.2, z + s / 2), PURPLE)
		end
	end
end

-- ───────── círculo rúnico en el suelo ─────────
for i = 0, 31 do
	local a = i / 32 * math.pi * 2
	neon(altar, Vector3.new(0.5, 0.1, 1.1), ROOT * CFrame.new(-20 + math.cos(a) * 5, 0.45, 10 + math.sin(a) * 5) * CFrame.Angles(0, -a, 0), PURPLE)
end

-- ───────── animación ─────────
local start = os.clock()
RunService.Heartbeat:Connect(function()
	local t = os.clock() - start
	spiral:PivotTo(portalCF * CFrame.new(0, 0, 0.3) * CFrame.Angles(0, 0, -t * 0.8))
	for _, r in ipairs(rings) do
		local d = r.def
		r.model:PivotTo(ROOT * CFrame.new(d.pos + Vector3.new(0, math.sin(t * 1.3 + d.r) * 0.6, 0)) * CFrame.Angles(d.tilt, t * d.speed, 0))
	end
	for _, c in ipairs(crystals) do
		local p = ROOT:PointToWorldSpace(c.base + Vector3.new(0, math.sin(t * 1.5 + c.phase) * 0.7, 0))
		c.part.CFrame = CFrame.new(p) * CFrame.Angles(math.rad(45), t + c.phase, math.rad(45))
	end
end)
