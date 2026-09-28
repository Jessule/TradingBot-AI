--[[
	TYCOON BÁSICO (Roblox / Luau)
	------------------------------------------------------------
	Todo el tycoon se construye con bloques desde este script:
	  - Base, cinta transportadora, recolector y zona para reclamar
	  - 2 droppers
	  - 5 mejoras

	CÓMO USARLO
	  1. Abre Roblox Studio (sirve la plantilla "Baseplate").
	  2. En el Explorer: ServerScriptService -> Insertar objeto -> Script.
	  3. Pega todo este código dentro del Script.
	  4. Pulsa Play. Toca la placa "Toca para reclamar" y compra con los botones.

	Los botones van apareciendo en orden: cuando compras uno, aparece el siguiente.
]]

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

------------------------------------------------------------
-- CONFIGURACIÓN
------------------------------------------------------------
local CONFIG = {
	Origin = Vector3.new(0, 0, 0), -- dónde se construye el tycoon
	OreValue = 5, -- dinero base por mineral
	DropInterval = 2, -- segundos entre minerales de cada dropper
	ConveyorSpeed = 8, -- velocidad de la cinta
	FastConveyorSpeed = 16, -- velocidad de la cinta con la mejora
	OreLifetime = 25, -- segundos antes de borrar un mineral perdido
}

-- Orden de compra: 2 droppers + 5 mejoras
local BUTTONS = {
	{ Id = "Dropper1", Name = "Dropper 1", Cost = 0 },
	{ Id = "Dropper2", Name = "Dropper 2", Cost = 50 },
	{ Id = "FastConveyor", Name = "Mejora: Cinta rápida", Cost = 100 },
	{ Id = "DoubleValue", Name = "Mejora: Minerales x2", Cost = 250 },
	{ Id = "FastDroppers", Name = "Mejora: Droppers rápidos", Cost = 500 },
	{ Id = "GoldCollector", Name = "Mejora: Recolector dorado", Cost = 1000 },
	{ Id = "Walls", Name = "Mejora: Paredes de la base", Cost = 2000 },
}

local COLORS = {
	Base = Color3.fromRGB(75, 151, 75),
	Conveyor = Color3.fromRGB(50, 50, 55),
	Rail = Color3.fromRGB(240, 200, 40),
	Collector = Color3.fromRGB(220, 50, 50),
	Gold = Color3.fromRGB(255, 200, 0),
	Button = Color3.fromRGB(40, 200, 80),
	ButtonNoMoney = Color3.fromRGB(220, 40, 40),
	Claim = Color3.fromRGB(60, 140, 255),
	Claimed = Color3.fromRGB(120, 120, 120),
	Dropper = Color3.fromRGB(90, 90, 110),
	Wall = Color3.fromRGB(200, 190, 170),
	Ore = Color3.fromRGB(170, 120, 80),
	OreRich = Color3.fromRGB(80, 220, 255),
}

------------------------------------------------------------
-- ESTADO
------------------------------------------------------------
local state = {
	Owner = nil :: Player?,
	Generation = 0, -- sube al reiniciar para parar los droppers viejos
	ValueMultiplier = 1,
	SpeedMultiplier = 1,
	CollectorMultiplier = 1,
}

------------------------------------------------------------
-- UTILIDADES
------------------------------------------------------------
local function at(x: number, y: number, z: number): Vector3
	return CONFIG.Origin + Vector3.new(x, y, z)
end

local function makePart(props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		if key ~= "Parent" then
			part[key] = value
		end
	end
	part.Parent = props.Parent
	return part
end

local function addLabel(part: BasePart, text: string, height: number?): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 60)
	gui.StudsOffset = Vector3.new(0, height or 3, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 80

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui

	gui.Parent = part
	return label
end

local function getCash(player: Player): IntValue?
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash") :: IntValue?
end

------------------------------------------------------------
-- LEADERSTATS (dinero)
------------------------------------------------------------
local function setupLeaderstats(player: Player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 0
	cash.Parent = stats
end

Players.PlayerAdded:Connect(setupLeaderstats)
for _, player in Players:GetPlayers() do
	setupLeaderstats(player)
end

------------------------------------------------------------
-- CONSTRUCCIÓN FIJA DEL TYCOON
------------------------------------------------------------
local model = Instance.new("Model")
model.Name = "TycoonBasico"
model.Parent = workspace

local purchasedFolder = Instance.new("Folder")
purchasedFolder.Name = "Comprado"
purchasedFolder.Parent = model

local oresFolder = Instance.new("Folder")
oresFolder.Name = "Minerales"
oresFolder.Parent = model

-- Suelo
makePart({
	Name = "Base",
	Size = Vector3.new(64, 1, 64),
	Position = at(0, 0.5, 0),
	Color = COLORS.Base,
	Material = Enum.Material.Grass,
	Parent = model,
})

-- Punto de aparición
local spawn = Instance.new("SpawnLocation")
spawn.Anchored = true
spawn.Size = Vector3.new(6, 1, 6)
spawn.Position = at(0, 1.5, 18)
spawn.Neutral = true
spawn.Parent = model

-- Cinta transportadora (una parte anclada con velocidad mueve lo que tiene encima)
local conveyor = makePart({
	Name = "Cinta",
	Size = Vector3.new(36, 1, 4),
	Position = at(-2, 1.5, -15),
	Color = COLORS.Conveyor,
	Material = Enum.Material.DiamondPlate,
	Parent = model,
})
conveyor.AssemblyLinearVelocity = Vector3.new(CONFIG.ConveyorSpeed, 0, 0)

-- Barandillas para que no se caigan los minerales
for _, z in { -17.25, -12.75 } do
	makePart({
		Name = "Barandilla",
		Size = Vector3.new(36, 2, 0.5),
		Position = at(-2, 2.5, z),
		Color = COLORS.Rail,
		Parent = model,
	})
end

-- Recolector: convierte minerales en dinero
local collector = makePart({
	Name = "Recolector",
	Size = Vector3.new(4, 1, 6),
	Position = at(18, 1.5, -15),
	Color = COLORS.Collector,
	Material = Enum.Material.Neon,
	Parent = model,
})
addLabel(collector, "Recolector", 3)

collector.Touched:Connect(function(hit)
	if hit.Name ~= "Ore" or hit.Parent ~= oresFolder then
		return
	end
	local value = hit:GetAttribute("Value")
	hit:Destroy() -- se borra primero para no cobrarlo dos veces
	if state.Owner and value then
		local cash = getCash(state.Owner)
		if cash then
			cash.Value += math.floor(value * state.CollectorMultiplier)
		end
	end
end)

-- Placa para reclamar el tycoon
local claimPad = makePart({
	Name = "Reclamar",
	Size = Vector3.new(8, 0.5, 4),
	Position = at(0, 1.25, 26),
	Color = COLORS.Claim,
	Material = Enum.Material.Neon,
	Parent = model,
})
local claimLabel = addLabel(claimPad, "Toca para reclamar", 4)

------------------------------------------------------------
-- MINERALES Y DROPPERS
------------------------------------------------------------
local function spawnOre(position: Vector3)
	local ore = Instance.new("Part")
	ore.Name = "Ore"
	ore.Size = Vector3.new(1, 1, 1)
	ore.Position = position
	ore.Color = if state.ValueMultiplier > 1 then COLORS.OreRich else COLORS.Ore
	ore.Material = Enum.Material.SmoothPlastic
	ore:SetAttribute("Value", CONFIG.OreValue * state.ValueMultiplier)
	ore.Parent = oresFolder
	ore:SetNetworkOwner(nil) -- el servidor controla la física (más estable)
	Debris:AddItem(ore, CONFIG.OreLifetime)
end

local function buildDropper(name: string, x: number)
	local dropper = Instance.new("Model")
	dropper.Name = name
	dropper.Parent = purchasedFolder

	makePart({ -- columna
		Size = Vector3.new(2, 9, 2),
		Position = at(x, 5.5, -19),
		Color = COLORS.Dropper,
		Material = Enum.Material.Metal,
		Parent = dropper,
	})
	makePart({ -- brazo
		Size = Vector3.new(2, 1, 4),
		Position = at(x, 9.5, -17),
		Color = COLORS.Dropper,
		Material = Enum.Material.Metal,
		Parent = dropper,
	})
	local head = makePart({ -- cabeza que suelta minerales
		Size = Vector3.new(3, 3, 3),
		Position = at(x, 8.5, -15),
		Color = COLORS.Rail,
		Material = Enum.Material.Neon,
		Parent = dropper,
	})
	addLabel(head, name, 3)

	-- Bucle que suelta minerales mientras el tycoon no se reinicie
	local generation = state.Generation
	task.spawn(function()
		while state.Generation == generation do
			task.wait(CONFIG.DropInterval / state.SpeedMultiplier)
			if state.Generation ~= generation then
				break
			end
			spawnOre(at(x, 6, -15))
		end
	end)
end

local function buildWalls()
	local walls = Instance.new("Model")
	walls.Name = "Paredes"
	walls.Parent = purchasedFolder

	local wallParts = {
		{ Size = Vector3.new(64, 10, 1), Position = at(0, 6, -32) }, -- fondo
		{ Size = Vector3.new(1, 10, 64), Position = at(-32, 6, 0) }, -- izquierda
		{ Size = Vector3.new(1, 10, 64), Position = at(32, 6, 0) }, -- derecha
		{ Size = Vector3.new(26, 10, 1), Position = at(-19, 6, 32) }, -- frente (con puerta)
		{ Size = Vector3.new(26, 10, 1), Position = at(19, 6, 32) },
	}
	for _, info in wallParts do
		makePart({
			Size = info.Size,
			Position = info.Position,
			Color = COLORS.Wall,
			Material = Enum.Material.Brick,
			Parent = walls,
		})
	end
end

------------------------------------------------------------
-- QUÉ HACE CADA COMPRA
------------------------------------------------------------
local PURCHASES = {
	Dropper1 = function()
		buildDropper("Dropper 1", -14)
	end,
	Dropper2 = function()
		buildDropper("Dropper 2", -4)
	end,
	FastConveyor = function()
		conveyor.AssemblyLinearVelocity = Vector3.new(CONFIG.FastConveyorSpeed, 0, 0)
	end,
	DoubleValue = function()
		state.ValueMultiplier = 2
	end,
	FastDroppers = function()
		state.SpeedMultiplier = 2
	end,
	GoldCollector = function()
		state.CollectorMultiplier = 1.5
		collector.Color = COLORS.Gold
	end,
	Walls = function()
		buildWalls()
	end,
}

------------------------------------------------------------
-- BOTONES
------------------------------------------------------------
local buttons = {}

local function setButtonVisible(button, visible: boolean)
	button.Part.Transparency = if visible then 0 else 1
	button.Part.CanCollide = visible
	button.Part.CanTouch = visible
	button.Label.Parent.Enabled = visible
end

local function tryBuy(index: number, hit: BasePart)
	local button = buttons[index]
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player or player ~= state.Owner or button.Bought or not button.Part.CanTouch then
		return
	end

	local cash = getCash(player)
	if not cash then
		return
	end

	if cash.Value < button.Info.Cost then
		-- Parpadea en rojo si no hay dinero suficiente
		if not button.Flashing then
			button.Flashing = true
			button.Part.Color = COLORS.ButtonNoMoney
			task.delay(0.5, function()
				button.Part.Color = COLORS.Button
				button.Flashing = false
			end)
		end
		return
	end

	cash.Value -= button.Info.Cost
	button.Bought = true
	setButtonVisible(button, false)
	PURCHASES[button.Info.Id]()

	local nextButton = buttons[index + 1]
	if nextButton then
		setButtonVisible(nextButton, true)
	end
end

for index, info in BUTTONS do
	local part = makePart({
		Name = "Boton_" .. info.Id,
		Size = Vector3.new(4, 0.5, 4),
		Position = at(-24 + (index - 1) * 8, 1.25, 8),
		Color = COLORS.Button,
		Material = Enum.Material.Neon,
		Parent = model,
	})
	local priceText = if info.Cost == 0 then "GRATIS" else "$" .. info.Cost
	local label = addLabel(part, info.Name .. "\n" .. priceText, 3)

	local button = { Info = info, Part = part, Label = label, Bought = false, Flashing = false }
	buttons[index] = button
	setButtonVisible(button, false)

	part.Touched:Connect(function(hit)
		tryBuy(index, hit)
	end)
end

------------------------------------------------------------
-- RECLAMAR Y REINICIAR
------------------------------------------------------------
claimPad.Touched:Connect(function(hit)
	if state.Owner then
		return
	end
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end

	state.Owner = player
	claimLabel.Text = "Tycoon de " .. player.Name
	claimPad.Color = COLORS.Claimed
	setButtonVisible(buttons[1], true)
end)

local function resetTycoon()
	state.Generation += 1
	state.Owner = nil
	state.ValueMultiplier = 1
	state.SpeedMultiplier = 1
	state.CollectorMultiplier = 1

	conveyor.AssemblyLinearVelocity = Vector3.new(CONFIG.ConveyorSpeed, 0, 0)
	collector.Color = COLORS.Collector
	purchasedFolder:ClearAllChildren()
	oresFolder:ClearAllChildren()

	for _, button in buttons do
		button.Bought = false
		setButtonVisible(button, false)
	end

	claimLabel.Text = "Toca para reclamar"
	claimPad.Color = COLORS.Claim
end

Players.PlayerRemoving:Connect(function(player)
	if player == state.Owner then
		resetTycoon()
	end
end)
