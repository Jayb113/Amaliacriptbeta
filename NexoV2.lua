-- Criar GUI principal
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ★ VARIÁVEIS GLOBAIS DE CONTROLE ★
_G.autoFarm = false 
_G.autoSizeActive = false 
_G.teleportActive = false 
_G.AutoWeight = false 
_G.AutoPunchActive = false 

local selectrock = nil 
local positionLockConnection = nil
local isPositionLocked = false 
local PUNCH_DELAY = 0.2 

-- Variável para rastrear o estado dos toggles da Aba 2
local Aba2_Toggles = {
	[1] = false, [2] = false, [3] = false, [4] = false,
	[5] = false, [6] = false, [7] = false, [8] = false,
}


local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MeuGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false 


-- Frame principal
local frame = Instance.new("Frame")
frame.Name = "MeuFrame"
frame.Size = UDim2.new(0, 567, 0, 402)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 32, 58)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Barra lateral
local sideBar = Instance.new("Frame")
sideBar.Name = "SideBar"
sideBar.Size = UDim2.new(0, 120, 1, 0)
sideBar.Position = UDim2.new(0, 0, 0, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(25, 27, 50)
sideBar.BorderSizePixel = 0
sideBar.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = sideBar
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Função auxiliar para o comportamento visual do toggle
local function animateToggle(toggleContainer, slider, isEnabled)
	local targetPos = isEnabled and UDim2.new(1, -20, 0.5, -10) or UDim2.new(0, 0, 0.5, -10)
	local targetColor = isEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 82, 110)

	local tweenPos = TweenService:Create(slider, TweenInfo.new(0.2), {Position = targetPos})
	local tweenColor = TweenService:Create(toggleContainer, TweenInfo.new(0.2), {BackgroundColor3 = targetColor})

	tweenPos:Play()
	tweenColor:Play()
end

-- ★ NOVA FUNÇÃO: Define CanCollide para todas as rochas relevantes ★
local function setRockCollision(enabled)
	local targetValue = not enabled -- Se ativarmos o farm (enabled=true), CanCollide deve ser false

	local machinesFolder = game:GetService("Workspace"):FindFirstChild("machinesFolder")
	if machinesFolder then
		for _, machine in pairs(machinesFolder:GetChildren()) do
			local rock = machine:FindFirstChild("Rock") -- Assumindo que a rocha tem o nome "Rock"
			if rock and rock:IsA("BasePart") then
				rock.CanCollide = targetValue
			end
		end
		print("CanCollide das rochas definido como: " .. tostring(targetValue))
	end
end

-- ★ FUNÇÃO DE AUTO ROCK CENTRALIZADA (PARA ABA 2) ★
local function autoRockCore(neededDurability, rockName)
	while _G.autoFarm and selectrock == rockName do
		task.wait()
		if not _G.autoFarm or selectrock ~= rockName then break end

		if LocalPlayer.Durability.Value >= neededDurability then
			for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
				if v.Name == "neededDurability" and v.Value == neededDurability and LocalPlayer.Character:FindFirstChild("LeftHand") and LocalPlayer.Character:FindFirstChild("RightHand") then
					firetouchinterest(v.Parent.Rock, LocalPlayer.Character.RightHand, 0)
					firetouchinterest(v.Parent.Rock, LocalPlayer.Character.RightHand, 1)
					firetouchinterest(v.Parent.Rock, LocalPlayer.Character.LeftHand, 0)
					firetouchinterest(v.Parent.Rock, LocalPlayer.Character.LeftHand, 1)
				end
			end
		end
	end
	print("Loop Auto Rock para " .. rockName .. " encerrado.")
end


-- FUNÇÕES DE TOGGLE ESPECÍFICAS PARA CADA ROCK NA ABA 2
local autoRockFunctions = {
	-- 1: Starter Rock
	function(isEnabled)
		if isEnabled then
			selectrock = "Starter Island Rock"
			task.spawn(function() autoRockCore(100, "Starter Island Rock") end)
		else
			selectrock = nil
		end
	end,
	-- 2: Legend Beach Rock
	function(isEnabled)
		if isEnabled then
			selectrock = "Legend Beach Rock"
			task.spawn(function() autoRockCore(5000, "Legend Beach Rock") end)
		else
			selectrock = nil
		end
	end,
	-- 3: Frozen Rock
	function(isEnabled)
		if isEnabled then
			selectrock = "Frost Gym Rock"
			task.spawn(function() autoRockCore(150000, "Frost Gym Rock") end)
		else
			selectrock = nil
		end
	end,
	-- 4: Mythical Rock
	function(isEnabled)
		if isEnabled then
			selectrock = "Mythical Gym Rock"
			task.spawn(function() autoRockCore(400000, "Mythical Gym Rock") end)
		else
			selectrock = nil
		end
	end,
	-- 5: Eternal Rock
	function(isEnabled)
		if isEnabled then
			selectrock = "Eternal Gym Rock"
			task.spawn(function() autoRockCore(750000, "Eternal Gym Rock") end)
		else
			selectrock = nil
		end
	end,
	-- 6: Legend Rock
	function(isEnabled)
		if isEnabled then
			selectrock = "Legend Gym Rock"
			task.spawn(function() autoRockCore(1000000, "Legend Gym Rock") end)
		else
			selectrock = nil
		end
	end,
	-- 7: Muscle King Rock
	function(isEnabled)
		if isEnabled then
			selectrock = "Muscle King Gym Rock"
			task.spawn(function() autoRockCore(5000000, "Muscle King Gym Rock") end)
		else
			selectrock = nil
		end
	end,
	-- 8: Jungle Rock
	function(isEnabled)
		if isEnabled then
			selectrock = "Ancient Jungle Rock"
			task.spawn(function() autoRockCore(10000000, "Ancient Jungle Rock") end)
		else
			selectrock = nil
		end
	end,
}

-- Função para garantir que apenas um Auto Rock esteja ativo
local function toggleAutoRockFeature(toggleIndex, toggleContainer, slider)
	local isCurrentlyEnabled = Aba2_Toggles[toggleIndex]

	if not isCurrentlyEnabled then
		-- Desliga todos os outros toggles se um novo for ativado
		for i = 1, 8 do
			if Aba2_Toggles[i] then
				local oldToggle = toggleContainer.Parent.Parent:FindFirstChild("Container" .. i)
				if oldToggle then
					local oldToggleContainer = oldToggle:FindFirstChild("ToggleBotao" .. i).ToggleContainer
					local oldSlider = oldToggleContainer.Slider

					animateToggle(oldToggleContainer, oldSlider, false)

					Aba2_Toggles[i] = false
					autoRockFunctions[i](false)
				end
			end
		end
	end

	Aba2_Toggles[toggleIndex] = not isCurrentlyEnabled
	_G.autoFarm = Aba2_Toggles[toggleIndex] 

	local isEnabled = Aba2_Toggles[toggleIndex]

	-- ★ Chamada da nova função aqui
	setRockCollision(isEnabled)

	animateToggle(toggleContainer, slider, isEnabled)

	autoRockFunctions[toggleIndex](isEnabled)

	if isEnabled then
		print("✔ Auto Farm para " .. selectrock .. " ATIVADO! CanCollide = FALSE")
	else
		print("✖ Auto Farm DESATIVADO! CanCollide = TRUE")
	end
end

-- (Funções da Aba 1 - Omitidas aqui por brevidade, mas estão no script completo)
local function lockPlayerPosition(position)
	if positionLockConnection then
		positionLockConnection:Disconnect()
	end

	positionLockConnection = RunService.Heartbeat:Connect(function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = position
		end
	end)
end

local function unlockPlayerPosition()
	if positionLockConnection then
		positionLockConnection:Disconnect()
		positionLockConnection = nil
	end
end

local function activateFpsBoost(button)
	if button.Active == false then return end
	local Lighting = game:GetService("Lighting")
	local Terrain = workspace.Terrain
	local Settings = UserSettings():GetService("UserGameSettings")
	Settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Brightness = 2
	local colorCorrection = Instance.new("ColorCorrectionEffect", Lighting)
	colorCorrection.Saturation = 0.3
	colorCorrection.Contrast = 0.2
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
			obj.Enabled = false
		end
	end
	button.Text = "ATIVADO ✔"
	button.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
	button.TextColor3 = Color3.new(1, 1, 1) 
	button.Active = false 
	button.TextTransparency = 0
	print("✔ FPS Boost ativado com segurança e botão desativado!")
end

local function toggleAutoSize(toggleContainer, slider)
	_G.autoSizeActive = not _G.autoSizeActive
	local isEnabled = _G.autoSizeActive
	animateToggle(toggleContainer, slider, isEnabled)
	if isEnabled then
		print("✔ Auto Size 1 ATIVADO!")
		task.spawn(function()
			while _G.autoSizeActive and task.wait() do
				ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)
			end
			print("Loop Auto Size 1 encerrado.")
		end)
	else
		print("✖ Auto Size 1 DESATIVADO!")
	end
end

local function toggleTeleport(toggleContainer, slider)
	_G.teleportActive = not _G.teleportActive
	local isEnabled = _G.teleportActive
	animateToggle(toggleContainer, slider, isEnabled)
	if isEnabled then
		print("✔ Teleport para Muscle King ATIVADO!")
		task.spawn(function()
			local TARGET_POS = Vector3.new(-8646, 17, -5738)
			local playerChar = LocalPlayer.Character
			while _G.teleportActive and task.wait(0.1) do
				if playerChar then
					playerChar:MoveTo(TARGET_POS)
				end
			end
			print("Loop Teleport encerrado.")
		end)
	else
		print("✖ Teleport DESATIVADO!")
	end
end

local function toggleAutoWeight(toggleContainer, slider)
	_G.AutoWeight = not _G.AutoWeight
	local isEnabled = _G.AutoWeight
	local character = LocalPlayer.Character
	animateToggle(toggleContainer, slider, isEnabled)
	if isEnabled then
		print("✔ Auto Weight ATIVADO: Levantando pesos automaticamente!")
		local weightTool = LocalPlayer.Backpack:FindFirstChild("Weight")
		if weightTool and character and character:FindFirstChildOfClass("Humanoid") then
			character.Humanoid:EquipTool(weightTool)
		end
		task.spawn(function()
			while _G.AutoWeight do
				if not LocalPlayer.muscleEvent then break end 
				LocalPlayer.muscleEvent:FireServer("rep")
				task.wait(0.1)
			end
			print("Loop Auto Weight encerrado.")
		end)
	else
		print("✖ Auto Weight DESATIVADO: Parando de levantar pesos.")
		if character then
			local equipped = character:FindFirstChild("Weight")
			if equipped then
				equipped.Parent = LocalPlayer.Backpack
			end
		end
	end
end

local function toggleAutoPunch(toggleContainer, slider)
	_G.AutoPunchActive = not _G.AutoPunchActive
	local isEnabled = _G.AutoPunchActive
	local character = LocalPlayer.Character
	animateToggle(toggleContainer, slider, isEnabled)
	if isEnabled then
		print("✔ Auto Punch ATIVADO: Dando socos automaticamente!")
		task.spawn(function()
			while _G.AutoPunchActive do
				local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
				if punch and character and character:FindFirstChildOfClass("Humanoid") then
					punch.Parent = character 
					local attackTime = punch:FindFirstChild("attackTime")
					if attackTime then
						attackTime.Value = 0
					end
				end
				task.wait(PUNCH_DELAY) 
			end
		end)
		task.spawn(function()
			while _G.AutoPunchActive do
				LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
				LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
				local punchTool = character:FindFirstChild("Punch")
				if punchTool then
					punchTool:Activate()
				end
				task.wait(PUNCH_DELAY) 
			end
			print("Loop Auto Punch encerrado.")
		end)
	else
		print("✖ Auto Punch DESATIVADO: Parando socos.")
		if character then
			local equipped = character:FindFirstChild("Punch")
			if equipped then
				equipped.Parent = LocalPlayer.Backpack
			end
		end
	end
end

local function toggleLockPosition(toggleContainer, slider)
	isPositionLocked = not isPositionLocked
	local isEnabled = isPositionLocked
	animateToggle(toggleContainer, slider, isEnabled)
	if isEnabled then
		print("✔ Lock Position ATIVADO!")
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local currentPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
			lockPlayerPosition(currentPosition)
		end
	else
		print("✖ Lock Position DESATIVADO!")
		unlockPlayerPosition()
	end
end

-- Criar abas
local abas = {}

for i = 1, 6 do
	local nome = "Aba " .. i
	if i == 2 then nome = "Auto Rock" end

	local aba = Instance.new("Frame")
	aba.Name = nome
	aba.Size = UDim2.new(1, -120, 1, 0)
	aba.Position = UDim2.new(0, 120, 0, 0)
	aba.BackgroundColor3 = Color3.fromRGB(40, 42, 70)
	aba.BorderSizePixel = 0
	aba.Visible = false
	aba.BackgroundTransparency = 0
	aba.Parent = frame

	-- Título da aba
	local titulo = Instance.new("TextLabel")
	titulo.Size = UDim2.new(1, 0, 0, 50)
	titulo.Position = UDim2.new(0, 0, 0, 0)
	titulo.BackgroundTransparency = 1
	titulo.Text = nome
	titulo.TextColor3 = Color3.new(1, 1, 1)
	titulo.TextScaled = true
	titulo.Font = Enum.Font.GothamBold
	titulo.Parent = aba


	----------------------------------------------------------------------------
	-- ABA 1: Funcionalidades Diversas
	----------------------------------------------------------------------------
	if i == 1 then
		local funcoesDosBotoes = {
			activateFpsBoost, 
			function(button) 
				if button.Active == false then return end
				local gamepassFolder = game:GetService("ReplicatedStorage").gamepassIds
				local player = Players.LocalPlayer
				for _, gamepass in pairs(gamepassFolder:GetChildren()) do
					local value = Instance.new("IntValue")
					value.Name = gamepass.Name
					value.Value = gamepass.Value
					value.Parent = player:WaitForChild("ownedGamepasses")
				end
				button.Text = "ATIVADO ✔"
				button.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
				button.TextColor3 = Color3.new(1, 1, 1) 
				button.Active = false 
				button.TextTransparency = 0
				print("Gamepass AutoLift desbloqueada!")
			end,
			function(toggleContainer, slider) toggleAutoSize(toggleContainer, slider) end, 
			function(toggleContainer, slider) toggleTeleport(toggleContainer, slider) end, 
			function(toggleContainer, slider) toggleAutoWeight(toggleContainer, slider) end, 
			function(toggleContainer, slider) toggleAutoPunch(toggleContainer, slider) end, 
			function(toggleContainer, slider) toggleLockPosition(toggleContainer, slider) end,
		}

		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll"
		scroll.Size = UDim2.new(1, 0, 1, -50)
		scroll.Position = UDim2.new(0, 0, 0, 50)
		scroll.BackgroundColor3 = Color3.fromRGB(35, 37, 60)
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.Parent = aba

		local layout = Instance.new("UIListLayout")
		layout.Parent = scroll
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		local textos = {
			"FPS Boost",
			"Auto Lift (Gamepass)",
			"Auto Size 1 (Toggle)", 
			"Teleport Muscle King (Toggle)", 
			"Auto Weight (Toggle)", 
			"Auto Punch (Toggle)", 
			"Lock Position (Toggle)" 
		}

		for n = 1, 7 do
			local container = Instance.new("Frame")
			container.Name = "Container" .. n
			container.Size = UDim2.new(1, -20, 0, 40)
			container.Position = UDim2.new(0, 10, 0, 0)
			container.BackgroundTransparency = 1
			container.Parent = scroll

			local horizontalLayout = Instance.new("UIListLayout")
			horizontalLayout.Parent = container
			horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
			horizontalLayout.Padding = UDim.new(0, 10)
			horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			horizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local item = Instance.new("TextLabel")
			item.Name = "Item" .. n
			item.Size = UDim2.new(0.65, 0, 1, 0)
			item.BackgroundColor3 = Color3.fromRGB(60, 62, 90)
			item.BorderSizePixel = 0
			item.Text = textos[n]
			item.TextColor3 = Color3.new(1, 1, 1)
			item.TextScaled = true
			item.Font = Enum.Font.GothamSemibold
			item.Parent = container

			if n >= 3 and n <= 7 then 
				local toggleButton = Instance.new("TextButton")
				toggleButton.Name = "ToggleBotao" .. n
				toggleButton.Size = UDim2.new(0.35, 0, 1, 0)
				toggleButton.BackgroundTransparency = 1
				toggleButton.Text = "" 
				toggleButton.Parent = container

				local toggleContainer = Instance.new("Frame")
				toggleContainer.Name = "ToggleContainer"
				toggleContainer.Size = UDim2.new(0, 40, 0, 20) 
				toggleContainer.Position = UDim2.new(1, -40, 0.5, -10)
				toggleContainer.BackgroundColor3 = Color3.fromRGB(80, 82, 110) 
				toggleContainer.BorderSizePixel = 0
				toggleContainer.Parent = toggleButton

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0.5, 0) 
				corner.Parent = toggleContainer

				local slider = Instance.new("Frame")
				slider.Name = "Slider"
				slider.Size = UDim2.new(0, 20, 0, 20)
				slider.Position = UDim2.new(0, 0, 0.5, -10) 
				slider.BackgroundColor3 = Color3.new(1, 1, 1) 
				slider.BorderSizePixel = 0
				slider.Parent = toggleContainer

				local sliderCorner = Instance.new("UICorner")
				sliderCorner.CornerRadius = UDim.new(0.5, 0) 
				sliderCorner.Parent = slider

				toggleButton.MouseButton1Click:Connect(function()
					funcoesDosBotoes[n](toggleContainer, slider)
				end)


			else 
				local botao = Instance.new("TextButton")
				botao.Name = "BotaoItem" .. n
				botao.Size = UDim2.new(0.35, 0, 1, 0)
				botao.BackgroundColor3 = Color3.fromRGB(80, 82, 110)
				botao.BorderSizePixel = 0
				botao.Text = "Ativar" 

				if n == 1 or n == 2 then 
					botao.MouseButton1Click:Connect(function()
						funcoesDosBotoes[n](botao)
					end)
				end

				botao.TextColor3 = Color3.new(1, 1, 1)
				botao.TextScaled = true
				botao.Font = Enum.Font.GothamBold
				botao.Parent = container
			end
		end

		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		end)
	end
	----------------------------------------------------------------------------
	-- ABA 2: 8 Toggles de Auto Rock Farm
	----------------------------------------------------------------------------
	if i == 2 then
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll2"
		scroll.Size = UDim2.new(1, 0, 1, -50)
		scroll.Position = UDim2.new(0, 0, 0, 50)
		scroll.BackgroundColor3 = Color3.fromRGB(35, 37, 60)
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.Parent = aba

		local layout = Instance.new("UIListLayout")
		layout.Parent = scroll
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		local textosAba2 = {
			"Starter Rock (100)",
			"Legend Beach Rock (5K)",
			"Frozen Rock (150K)",
			"Mythical Rock (400K)",
			"Eternal Rock (750K)",
			"Legend Rock (1M)",
			"Muscle King Rock (5M)",
			"Jungle Rock (10M)",
		}

		for n = 1, 8 do
			local container = Instance.new("Frame")
			container.Name = "Container" .. n
			container.Size = UDim2.new(1, -20, 0, 40)
			container.Position = UDim2.new(0, 10, 0, 0)
			container.BackgroundTransparency = 1
			container.Parent = scroll

			local horizontalLayout = Instance.new("UIListLayout")
			horizontalLayout.Parent = container
			horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
			horizontalLayout.Padding = UDim.new(0, 10)
			horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			horizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local item = Instance.new("TextLabel")
			item.Name = "Item" .. n
			item.Size = UDim2.new(0.65, 0, 1, 0)
			item.BackgroundColor3 = Color3.fromRGB(60, 62, 90)
			item.BorderSizePixel = 0
			item.Text = textosAba2[n]
			item.TextColor3 = Color3.new(1, 1, 1)
			item.TextScaled = true
			item.Font = Enum.Font.GothamSemibold
			item.Parent = container

			local toggleButton = Instance.new("TextButton")
			toggleButton.Name = "ToggleBotao" .. n
			toggleButton.Size = UDim2.new(0.35, 0, 1, 0)
			toggleButton.BackgroundTransparency = 1
			toggleButton.Text = "" 
			toggleButton.Parent = container

			local toggleContainer = Instance.new("Frame")
			toggleContainer.Name = "ToggleContainer"
			toggleContainer.Size = UDim2.new(0, 40, 0, 20) 
			toggleContainer.Position = UDim2.new(1, -40, 0.5, -10)
			toggleContainer.BackgroundColor3 = Color3.fromRGB(80, 82, 110) 
			toggleContainer.BorderSizePixel = 0
			toggleContainer.Parent = toggleButton

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0.5, 0) 
			corner.Parent = toggleContainer

			local slider = Instance.new("Frame")
			slider.Name = "Slider"
			slider.Size = UDim2.new(0, 20, 0, 20)
			slider.Position = UDim2.new(0, 0, 0.5, -10) 
			slider.BackgroundColor3 = Color3.new(1, 1, 1) 
			slider.BorderSizePixel = 0
			slider.Parent = toggleContainer

			local sliderCorner = Instance.new("UICorner")
			sliderCorner.CornerRadius = UDim.new(0.5, 0) 
			sliderCorner.Parent = slider

			local toggleIndex = n
			toggleButton.MouseButton1Click:Connect(function()
				toggleAutoRockFeature(toggleIndex, toggleContainer, slider)
			end)
		end

		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		end)
	end

	----------------------------------------------------------------------------
	-- ABA 3: 9 Botões de Teleport (EDITADO)
	----------------------------------------------------------------------------
	if i == 3 then
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll3"
		scroll.Size = UDim2.new(1, 0, 1, -50)
		scroll.Position = UDim2.new(0, 0, 0, 50)
		scroll.BackgroundColor3 = Color3.fromRGB(35, 37, 60)
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.Parent = aba

		local layout = Instance.new("UIListLayout")
		layout.Parent = scroll
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		-- Defina suas coordenadas de teleport aqui
		local teleportCoordinates = {
			Vector3.new(0, 10, 0),       -- Exemplo para Teleport 1 (Substitua por suas coordenadas)
			Vector3.new(500, 100, 500),   -- Exemplo para Teleport 2
			Vector3.new(-2794.28906, 0.716248989, -340.267761, 1, 0, 0, 0, 1, 0, 0, 0, 1),   -- Exemplo para Teleport 3
			Vector3.new(2317.19336, 0.716249228, 1074.26489, 1, 0, 0, 0, 1, 0, 0, 0, 1),  -- Exemplo para Teleport 4
			Vector3.new(-6833.52344, 0.716263533, -1277.53552, 1, 0, 0, 0, 1, 0, 0, 0, 1),    -- Exemplo para Teleport 5
			Vector3.new(4196.82031, 988.535767, -3998.82739, 1, 0, 0, 0, 1, 0, 0, 0, 1),   -- Exemplo para Teleport 6
			Vector3.new(-8955.0127, 10.5662794, -6058.4834, 1, 0, 0, 0, 1, 0, 0, 0, 1),    -- Exemplo para Teleport 7
			Vector3.new(-7500.37842, 1.30290318, 3027.50513, 1, 0, 0, 0, 1, 0, 0, 0, 1),   -- Exemplo para Teleport 8
			Vector3.new(-200, 50, -200),  -- Exemplo para Teleport 9
		}

		local textosAba3 = {
			"Starter Island",
			"Dont Click!",
			"Frost Gym [1]",
			"Mythical Gym [5]",
			"Eternal Gym [15]",
			"Legend Gym [30]",
			"Muscle King Gym [5]",
			" Jungle Zone [60]",
			"Dont Click!",
		}

		for n = 1, 9 do
			local container = Instance.new("Frame")
			container.Name = "ContainerTeleport" .. n
			container.Size = UDim2.new(1, -20, 0, 40)
			container.Position = UDim2.new(0, 10, 0, 0)
			container.BackgroundTransparency = 1
			container.Parent = scroll

			-- Layout Horizontal para alinhar Item e Botão
			local horizontalLayout = Instance.new("UIListLayout")
			horizontalLayout.Parent = container
			horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
			horizontalLayout.Padding = UDim.new(0, 10)
			horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right -- Alinha o conteúdo à direita
			horizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local item = Instance.new("TextLabel")
			item.Name = "ItemTeleport" .. n
			-- Aumenta o tamanho para empurrar o botão e o texto para a direita
			item.Size = UDim2.new(0.7, 0, 1, 0) 
			item.BackgroundColor3 = Color3.fromRGB(60, 62, 90)
			item.BorderSizePixel = 0
			item.Text = textosAba3[n]
			item.TextColor3 = Color3.new(1, 1, 1)
			item.TextScaled = true
			item.TextXAlignment = Enum.TextXAlignment.Right -- Alinha o texto à direita
			item.Font = Enum.Font.GothamSemibold
			item.Parent = container

			local botao = Instance.new("TextButton")
			botao.Name = "BotaoTeleport" .. n
			-- Diminui o tamanho do botão
			botao.Size = UDim2.new(0.25, 0, 1, 0) 
			botao.BackgroundColor3 = Color3.fromRGB(80, 82, 110)
			botao.BorderSizePixel = 0
			botao.Text = "TP" -- Texto menor
			botao.TextColor3 = Color3.new(1, 1, 1)
			botao.TextScaled = true
			botao.Font = Enum.Font.GothamBold
			botao.Parent = container

			-- FUNÇÃO DE TELEPORT AGORA É CONFIGURÁVEL
			local targetPosition = teleportCoordinates[n]

			botao.MouseButton1Click:Connect(function()
				local playerChar = LocalPlayer.Character
				if playerChar and playerChar:FindFirstChild("HumanoidRootPart") and targetPosition then
					playerChar:SetPrimaryPartCFrame(CFrame.new(targetPosition))
					print("Teleport para " .. textosAba3[n] .. " realizado em: " .. tostring(targetPosition))
				elseif not targetPosition then
					print("Erro: Coordenada para " .. textosAba3[n] .. " não definida.")
				else
					print("Erro: Caractere do jogador não encontrado para teleport.")
				end
			end)
		end

		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		end)
	end

	----------------------------------------------------------------------------
	-- ABA 4: Teleporte por Jogador (Visual Aprimorado)
	----------------------------------------------------------------------------
	if i == 4 then
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll4"
		scroll.Size = UDim2.new(1, 0, 1, -50)
		scroll.Position = UDim2.new(0, 0, 0, 50)
		scroll.BackgroundColor3 = Color3.fromRGB(35, 37, 60)
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.Parent = aba

		local layout = Instance.new("UIListLayout")
		layout.Parent = scroll
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center -- Centraliza os itens

		-- CONTAINER PRINCIPAL PARA O FORMULÁRIO (OCUPA A LARGURA E DEFINE ESPAÇAMENTO INTERNO)
		local searchContainer = Instance.new("Frame")
		searchContainer.Name = "SearchContainer"
		searchContainer.Size = UDim2.new(1, -20, 0, 100) -- Altura maior para o conjunto de itens
		searchContainer.Position = UDim2.new(0, 10, 0, 10)
		searchContainer.BackgroundTransparency = 1
		searchContainer.Parent = scroll

		local verticalLayout = Instance.new("UIListLayout")
		verticalLayout.Parent = searchContainer
		verticalLayout.Padding = UDim.new(0, 5) -- Espaçamento vertical entre os elementos
		verticalLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- 1. Label/Título
		local label = Instance.new("TextLabel", searchContainer)
		label.Name = "TitleLabel"
		label.Size = UDim2.new(1, 0, 0, 20) 
		label.Text = "TELEPORTE PARA JOGADOR (Nick/Display)"
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.TextSize = 16
		label.TextXAlignment = Enum.TextXAlignment.Left

		-- CONTAINER DO CAMPO DE TEXTO + BOTÃO (PARA ALINHAMENTO HORIZONTAL)
		local inputContainer = Instance.new("Frame", searchContainer)
		inputContainer.Name = "InputContainer"
		inputContainer.Size = UDim2.new(1, 0, 0, 40) -- Altura fixa do input
		inputContainer.BackgroundTransparency = 1

		local horizontalLayout = Instance.new("UIListLayout")
		horizontalLayout.Parent = inputContainer
		horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
		horizontalLayout.Padding = UDim.new(0, 10)
		horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		horizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		-- 2. Campo de Texto (TextBox)
		local searchBox = Instance.new("TextBox")
		searchBox.Name = "SearchBox"
		searchBox.Size = UDim2.new(0.66, 0, 1, 0) -- Ocupa 2/3 da largura do inputContainer
		searchBox.PlaceholderText = "Display ou Nick"
		searchBox.Text = ""
		searchBox.Font = Enum.Font.SourceSans
		searchBox.TextSize = 18
		searchBox.TextXAlignment = Enum.TextXAlignment.Left
		searchBox.BackgroundTransparency = 0
		searchBox.BackgroundColor3 = Color3.fromRGB(50, 52, 80) -- Fundo mais escuro
		searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		searchBox.TextWrapped = true
		searchBox.BorderSizePixel = 0
		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)
		searchBox.Parent = inputContainer


		-- 3. Botão de Ação "TP"
		local tpButton = Instance.new("TextButton")
		tpButton.Name = "TPButton"
		tpButton.Size = UDim2.new(0.34, 0, 1, 0) -- Ocupa o restante 1/3 da largura (ajustado para caber o padding)
		tpButton.Text = "TELEPORTAR"
		tpButton.BackgroundColor3 = Color3.fromRGB(48, 209, 88) -- Verde Vibrante
		tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		tpButton.TextScaled = true
		tpButton.Font = Enum.Font.GothamBold
		tpButton.BorderSizePixel = 0
		Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0, 8)
		tpButton.Parent = inputContainer


		-- Variáveis Locais do Jogo
		local player = game.Players.LocalPlayer
		local Players = game:GetService("Players")

		-- Função de Teleporte por Jogador
		local function teleportToPlayer()
			local targetName = searchBox.Text:lower() 
			if targetName == "" then 
				print("Digite o nome ou nick do jogador.")
				return 
			end

			local targetPlayer = nil

			-- Tenta encontrar o jogador por NickName ou DisplayName (ou inicial)
			for _, p in pairs(Players:GetPlayers()) do
				local pName = p.Name:lower()
				local pDisplay = p.DisplayName:lower()

				-- Se o nome ou display name começar com o que foi digitado
				if pName:sub(1, #targetName) == targetName or pDisplay:sub(1, #targetName) == targetName then
					targetPlayer = p
					break
				end
			end

			if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local targetHRP = targetPlayer.Character.HumanoidRootPart
				local playerCharacter = player.Character or player.CharacterAdded:Wait()

				if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
					-- Teleporta o jogador para a posição do alvo + um pequeno deslocamento Y (para evitar colisão imediata)
					playerCharacter.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
					print("Teleportado com sucesso para: " .. targetPlayer.DisplayName)
				end
			else
				print("Erro: Jogador '" .. searchBox.Text .. "' não encontrado ou sem Character carregado.")
			end
		end

		-- Conectar o Botão de TP
		tpButton.MouseButton1Click:Connect(teleportToPlayer)

		-- Conectar a tecla Enter na TextBox
		searchBox.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Return then
				teleportToPlayer()
			end
		end)

		-- Ajusta o CanvasSize do scroll, caso mais itens sejam adicionados
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		end)
	end
	
	----------------------------------------------------------------------------
	-- ABA 5: Auto Rebirth com Objetivo
	----------------------------------------------------------------------------
	if i == 5 then
		-- Variável Global/Local para armazenar o valor do objetivo
		local targetRebirthValue = 10 -- Valor padrão
		local targetRebirthActive = false -- Flag de ativação do loop

		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll5"
		scroll.Size = UDim2.new(1, 0, 1, -50)
		scroll.Position = UDim2.new(0, 0, 0, 50)
		scroll.BackgroundColor3 = Color3.fromRGB(35, 37, 60)
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.Parent = aba

		local layout = Instance.new("UIListLayout")
		layout.Parent = scroll
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		-- CONTAINER PRINCIPAL PARA O FORMULÁRIO
		local mainContainer = Instance.new("Frame")
		mainContainer.Name = "RebirthContainer"
		mainContainer.Size = UDim2.new(1, -20, 0, 180) -- Altura suficiente para todos os elementos
		mainContainer.Position = UDim2.new(0, 10, 0, 10)
		mainContainer.BackgroundTransparency = 1
		mainContainer.Parent = scroll

		local verticalLayout = Instance.new("UIListLayout")
		verticalLayout.Parent = mainContainer
		verticalLayout.Padding = UDim.new(0, 8)
		verticalLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- 1. Título
		local label = Instance.new("TextLabel", mainContainer)
		label.Name = "TitleLabel"
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Text = "AUTO REBIRTH COM OBJETIVO"
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.TextSize = 16
		label.TextXAlignment = Enum.TextXAlignment.Left

		-- 2. Label de Status
		local statusLabel = Instance.new("TextLabel", mainContainer)
		statusLabel.Name = "StatusLabel"
		statusLabel.Size = UDim2.new(1, 0, 0, 20)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Font = Enum.Font.SourceSans
		statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		statusLabel.TextSize = 14
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left

		local function updateStatusLabel()
			if targetRebirthActive then
				statusLabel.Text = "Status: Ativo | Objetivo: " .. targetRebirthValue .. " Rebirths"
				statusLabel.TextColor3 = Color3.fromRGB(48, 209, 88) -- Verde
			else
				statusLabel.Text = "Status: Desativado | Objetivo Atual: " .. targetRebirthValue .. " Rebirths"
				statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Vermelho
			end
		end

		updateStatusLabel() -- Define o status inicial

		-- CONTAINER DO CAMPO DE TEXTO + BOTÃO (ALINHAMENTO HORIZONTAL)
		local inputContainer = Instance.new("Frame", mainContainer)
		inputContainer.Name = "InputContainer"
		inputContainer.Size = UDim2.new(1, 0, 0, 40)
		inputContainer.BackgroundTransparency = 1

		local horizontalLayout = Instance.new("UIListLayout")
		horizontalLayout.Parent = inputContainer
		horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
		horizontalLayout.Padding = UDim.new(0, 10)
		horizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		horizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		-- 3. Campo de Texto (TextBox)
		local targetBox = Instance.new("TextBox")
		targetBox.Name = "TargetBox"
		targetBox.Size = UDim2.new(0.66, 0, 1, 0)
		targetBox.PlaceholderText = "Número de Rebirths (ex: 100)"
		targetBox.Text = tostring(targetRebirthValue) -- Mostra o valor padrão
		targetBox.Font = Enum.Font.SourceSans
		targetBox.TextSize = 18
		targetBox.TextXAlignment = Enum.TextXAlignment.Left
		targetBox.BackgroundTransparency = 0
		targetBox.BackgroundColor3 = Color3.fromRGB(50, 52, 80)
		targetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		targetBox.BorderSizePixel = 0
		Instance.new("UICorner", targetBox).CornerRadius = UDim.new(0, 8)
		targetBox.Parent = inputContainer


		-- 4. Botão de Ação "Set/Start"
		local startButton = Instance.new("TextButton")
		startButton.Name = "StartButton"
		startButton.Size = UDim2.new(0.34, 0, 1, 0)
		startButton.Text = "DEFINIR / LIGAR"
		startButton.BackgroundColor3 = Color3.fromRGB(48, 209, 88) -- Verde
		startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		startButton.TextScaled = true
		startButton.Font = Enum.Font.GothamBold
		startButton.BorderSizePixel = 0
		Instance.new("UICorner", startButton).CornerRadius = UDim.new(0, 8)
		startButton.Parent = inputContainer

		-- Variáveis do Jogo
		local player = game.Players.LocalPlayer
		-- Assumindo que o RemoteEvent para Rebirth está em ReplicatedStorage.rEvents.rebirthRemote
		local rebirthRemote = game:GetService("ReplicatedStorage"):WaitForChild("rEvents", 10) and game:GetService("ReplicatedStorage").rEvents:FindFirstChild("rebirthRemote")

		-- Função Principal
		local function startAutoRebirth(newTarget)
			local newValue = tonumber(newTarget)

			-- 1. Validação e Definição do Objetivo
			if not newValue or newValue <= player.leaderstats.Rebirths.Value then
				local errorMessage = "Por favor, coloque um número válido maior que " .. player.leaderstats.Rebirths.Value
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Objetivo Inválido",
					Text = errorMessage,
					Duration = 5
				})
				return
			end

			-- Se o loop já estiver ativo, desativa para reiniciar com novo objetivo
			if targetRebirthActive then
				targetRebirthActive = false
				wait(0.1) -- Garante que o loop anterior pare
			end

			-- Atualiza o valor do objetivo
			targetRebirthValue = math.floor(newValue) -- Garante que seja um inteiro
			targetRebirthActive = true
			updateStatusLabel()

			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Auto Rebirth Ativado",
				Text = "Novo Objetivo: " .. tostring(targetRebirthValue) .. " renascimentos. Iniciando...",
				Duration = 3
			})


			-- 2. Loop de Auto Rebirth
			spawn(function()
				while targetRebirthActive and wait(0.1) do
					local currentRebirths = player.leaderstats.Rebirths.Value

					if currentRebirths >= targetRebirthValue then
						targetRebirthActive = false
						updateStatusLabel()

						game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = "Rebirth Alcançado!",
							Text = "Você alcançou " .. tostring(targetRebirthValue) .. " renascimentos",
							Duration = 5
						})

						break -- Sai do loop
					end

					-- Tenta invocar o evento de Rebirth, se ele existir
					if rebirthRemote then
						rebirthRemote:InvokeServer("rebirthRequest")
					else
						-- Se o evento não for encontrado, para o loop e notifica
						targetRebirthActive = false
						updateStatusLabel()
						game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = "Erro Crítico",
							Text = "Remote Event de Rebirth não encontrado (rEvents.rebirthRemote). Parando...",
							Duration = 5
						})
						break
					end
				end
			end)
		end

		-- Conectar o Botão de Ação
		startButton.MouseButton1Click:Connect(function()
			startAutoRebirth(targetBox.Text)
		end)

		-- Conectar a tecla Enter na TextBox
		targetBox.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Return then
				startAutoRebirth(targetBox.Text)
			end
		end)

		-- Adicionar um botão de parada (STOP)
		local stopButton = Instance.new("TextButton")
		stopButton.Name = "StopButton"
		stopButton.Size = UDim2.new(1, 0, 0, 40)
		stopButton.Text = "PARAR AUTO REBIRTH"
		stopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho
		stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		stopButton.TextScaled = true
		stopButton.Font = Enum.Font.GothamBold
		stopButton.BorderSizePixel = 0
		Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 8)
		stopButton.Parent = mainContainer

		stopButton.MouseButton1Click:Connect(function()
			if targetRebirthActive then
				targetRebirthActive = false
				updateStatusLabel()
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Parado",
					Text = "Auto Rebirth interrompido pelo usuário.",
					Duration = 3
				})
			else
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Status",
					Text = "O Auto Rebirth já estava desativado.",
					Duration = 3
				})
			end
		end)

		-- Ajusta o CanvasSize do scroll
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		end)
	end
	
	----------------------------------------------------------------------------
	-- ABA 6: Mini-Jogo do Quadrado Saltitante (Com Colisão e Game Over)
	----------------------------------------------------------------------------
	if i == 6 then
		local TweenService = game:GetService("TweenService")
		local Debris = game:GetService("Debris") 

		-- Variáveis de Jogo
		local isJumping = false
		local isGameActive = false
		local jumpHeight = 80        -- Altura do salto em pixels
		local jumpDuration = 0.5     -- Duração total do salto
		local obstacleSpeed = 1.5    -- Tempo que o obstáculo leva para atravessar (em segundos)
		local obstacleInterval = 1.5 -- Intervalo entre a criação de novos obstáculos (em segundos)

		local defaultDinoColor = Color3.fromRGB(48, 209, 88)
		local groundY = -50          -- Posição Y do Dino no chão (offset)

		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Scroll6"
		scroll.Size = UDim2.new(1, 0, 1, -50)
		scroll.Position = UDim2.new(0, 0, 0, 50)
		scroll.BackgroundColor3 = Color3.fromRGB(35, 37, 60)
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 6
		scroll.Parent = aba

		local layout = Instance.new("UIListLayout")
		layout.Parent = scroll
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		-- CONTAINER PRINCIPAL
		local mainContainer = Instance.new("Frame")
		mainContainer.Name = "DinoGameContainer"
		mainContainer.Size = UDim2.new(1, -20, 0, 390) -- Altura ajustada
		mainContainer.Position = UDim2.new(0, 10, 0, 10)
		mainContainer.BackgroundTransparency = 1
		mainContainer.Parent = scroll

		local verticalLayout = Instance.new("UIListLayout")
		verticalLayout.Parent = mainContainer
		verticalLayout.Padding = UDim.new(0, 8)
		verticalLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- 1. Título
		local label = Instance.new("TextLabel", mainContainer)
		label.Name = "TitleLabel"
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Text = "MINI-JOGO: QUADRADO SALTANTE"
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.TextSize = 16
		label.TextXAlignment = Enum.TextXAlignment.Left

		-- 2. CAMPO DE JOGO
		local gameArea = Instance.new("Frame", mainContainer)
		gameArea.Name = "GameArea"
		gameArea.Size = UDim2.new(1, 0, 0, 200)
		gameArea.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
		gameArea.BorderSizePixel = 0
		Instance.new("UICorner", gameArea).CornerRadius = UDim.new(0, 8)

		-- O CHÃO
		local ground = Instance.new("Frame", gameArea)
		ground.Name = "Ground"
		ground.Size = UDim2.new(1, 0, 0, 20)
		ground.Position = UDim2.new(0, 0, 1, -20)
		ground.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		ground.BorderSizePixel = 0

		-- O DINOSSAURO (O QUADRADO)
		local dino = Instance.new("Frame", gameArea)
		dino.Name = "Dino"
		dino.Size = UDim2.new(0, 30, 0, 30)
		dino.Position = UDim2.new(0, 10, 1, groundY)
		dino.BackgroundColor3 = defaultDinoColor
		dino.BorderSizePixel = 0
		Instance.new("UICorner", dino).CornerRadius = UDim.new(0, 5)

		-- Label de Status
		local statusLabel = Instance.new("TextLabel", mainContainer)
		statusLabel.Name = "StatusLabel"
		statusLabel.Size = UDim2.new(1, 0, 0, 20)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Font = Enum.Font.SourceSans
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		statusLabel.TextSize = 14
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.Text = "Status: Pronto para Iniciar"

		local startButton = Instance.new("TextButton") -- Forward declaration

		local function updateStatus(text, color, buttonText)
			statusLabel.Text = "Status: " .. text
			statusLabel.TextColor3 = color
			startButton.Text = buttonText or "INICIAR JOGO"
		end

		-- Funções do Jogo

		-- Função de Colisão e Game Over
		local function gameOver()
			if not isGameActive then return end
			isGameActive = false

			updateStatus("GAME OVER! Clique para Reiniciar.", Color3.fromRGB(255, 0, 0), "REINICIAR")

			-- 1. Animação de Morte (Piscar Vermelho)
			local deathTween = TweenService:Create(dino, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 3, true), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)})
			deathTween:Play()

			-- 2. Notificação
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "GAME OVER!",
				Text = "Você colidiu com um obstáculo.",
				Duration = 3
			})
		end

		-- Função de Verificação de Colisão
		local function checkCollision()
			if not isGameActive or isJumping then return end -- Não checa colisão se estiver pulando

			local dinoPos = dino.AbsolutePosition
			local dinoSize = dino.AbsoluteSize

			-- Simplificamos o Dino para uma área de 10px a 40px no eixo X (30px de largura + 10px de offset)
			local dinoXLeft = dinoPos.X
			local dinoXRight = dinoPos.X + dinoSize.X 

			for _, obj in gameArea:GetChildren() do
				if obj.Name == "Obstacle" and obj:IsA("Frame") then
					local obsPos = obj.AbsolutePosition
					local obsSize = obj.AbsoluteSize

					-- Colisão Horizontal
					local xOverlap = (dinoXLeft < obsPos.X + obsSize.X) and (dinoXRight > obsPos.X)

					-- Colisão Vertical (Só acontece se o Dino não pulou)
					-- Como todos os objetos estão na mesma linha de terra, basta verificar a sobreposição
					-- Se o Dino estiver em sua posição Y de chão, a colisão Y é garantida.
					local yOverlap = (dinoPos.Y + dinoSize.Y) > (obsPos.Y + 5) -- +5 para margem de segurança

					if xOverlap and yOverlap then
						gameOver()
						return
					end
				end
			end
		end

		-- Loop de Colisão (Roda 60 vezes por segundo)
		spawn(function()
			while wait(1/60) do
				if isGameActive then
					checkCollision()
				end
			end
		end)


		-- Função para fazer o quadrado pular
		local function jump()
			if isJumping or not isGameActive then return end
			isJumping = true

			local jumpPosition = UDim2.new(dino.Position.X.Scale, dino.Position.X.Offset, dino.Position.Y.Scale, groundY - jumpHeight)

			local jumpInfo = TweenInfo.new(jumpDuration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local fallInfo = TweenInfo.new(jumpDuration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

			local jumpTween = TweenService:Create(dino, jumpInfo, {Position = jumpPosition})
			local fallTween = TweenService:Create(dino, fallInfo, {Position = UDim2.new(dino.Position.X.Scale, dino.Position.X.Offset, dino.Position.Y.Scale, groundY)})

			jumpTween:Play()
			jumpTween.Completed:Wait()

			fallTween:Play()
			fallTween.Completed:Wait()

			isJumping = false
		end

		-- Função para criar e mover um obstáculo
		local function spawnObstacle()
			local obstacle = Instance.new("Frame", gameArea)
			obstacle.Name = "Obstacle"
			obstacle.Size = UDim2.new(0, 20, 0, 30)
			obstacle.Position = UDim2.new(1, -20, 1, groundY)
			obstacle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			obstacle.BorderSizePixel = 0
			Instance.new("UICorner", obstacle).CornerRadius = UDim.new(0, 3)

			local moveTarget = UDim2.new(0, -30, 1, groundY) 

			local moveInfo = TweenInfo.new(obstacleSpeed, Enum.EasingStyle.Linear)
			local moveTween = TweenService:Create(obstacle, moveInfo, {Position = moveTarget})

			moveTween:Play()

			Debris:AddItem(obstacle, obstacleSpeed + 0.1) 
		end

		-- Loop de Geração de Obstáculos
		local function startGame()
			if isGameActive then return end
			isGameActive = true
			updateStatus("Rodando (Pule com Espaço)", Color3.fromRGB(48, 209, 88), "PAUSAR")

			-- Reseta a cor do Dino para o padrão (caso tenha morrido)
			dino.BackgroundColor3 = defaultDinoColor

			-- Loop para geração
			spawn(function()
				while isGameActive do
					spawnObstacle()
					wait(obstacleInterval)
				end
			end)
		end

		local function stopGame()
			isGameActive = false
			updateStatus("Parado", Color3.fromRGB(255, 100, 100), "INICIAR JOGO")

			-- Limpa todos os obstáculos existentes
			for _, obj in gameArea:GetChildren() do
				if obj.Name == "Obstacle" then
					obj:Destroy()
				end
			end
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Jogo Parado",
				Text = "Geração de obstáculos interrompida.",
				Duration = 2
			})
		end

		-- Função principal para o botão de Ação
		local function handleGameToggle()
			if isGameActive then
				stopGame()
			else
				-- Limpa se houver obstáculos de um Game Over anterior
				for _, obj in gameArea:GetChildren() do
					if obj.Name == "Obstacle" then
						obj:Destroy()
					end
				end
				startGame()
			end
		end


		-- 3. Botões de Controle
		local controlContainer = Instance.new("Frame", mainContainer)
		controlContainer.Name = "ControlContainer"
		controlContainer.Size = UDim2.new(1, 0, 0, 40)
		controlContainer.BackgroundTransparency = 1

		local hLayout = Instance.new("UIListLayout")
		hLayout.Parent = controlContainer
		hLayout.FillDirection = Enum.FillDirection.Horizontal
		hLayout.Padding = UDim.new(0, 10)
		hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		-- Botão 1: INICIAR / PAUSAR / REINICIAR
		startButton.Name = "StartButton"
		startButton.Size = UDim2.new(0.5, -5, 1, 0)
		startButton.Text = "INICIAR JOGO"
		startButton.BackgroundColor3 = Color3.fromRGB(48, 209, 88)
		startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		startButton.TextScaled = true
		startButton.Font = Enum.Font.GothamBold
		Instance.new("UICorner", startButton).CornerRadius = UDim.new(0, 8)
		startButton.Parent = controlContainer

		startButton.MouseButton1Click:Connect(handleGameToggle)

		-- Botão 2: PULAR
		local jumpButton = Instance.new("TextButton")
		jumpButton.Name = "JumpButton"
		jumpButton.Size = UDim2.new(0.5, -5, 1, 0)
		jumpButton.Text = "PULAR (Espaço)"
		jumpButton.BackgroundColor3 = Color3.fromRGB(48, 100, 209)
		jumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		jumpButton.TextScaled = true
		jumpButton.Font = Enum.Font.GothamBold
		Instance.new("UICorner", jumpButton).CornerRadius = UDim.new(0, 8)
		jumpButton.Parent = controlContainer

		jumpButton.MouseButton1Click:Connect(jump)

		-- Conexão da Tecla ESPAÇO
		game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
				jump()
			end
		end)


		-- 4. Observação
		local noteLabel = Instance.new("TextLabel", mainContainer)
		noteLabel.Name = "NoteLabel"
		noteLabel.Size = UDim2.new(1, 0, 0, 40)
		noteLabel.Text = "FUNCIONALIDADE EXTRA: A colisão com obstáculos agora resulta em Game Over. O botão 'Reiniciar' limpa a área e inicia o jogo novamente."
		noteLabel.BackgroundTransparency = 1
		noteLabel.Font = Enum.Font.SourceSans
		noteLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		noteLabel.TextSize = 12
		noteLabel.TextWrapped = true

		-- Ajusta o CanvasSize do scroll
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		end)
	end
	

	
	




	table.insert(abas, aba)
end


-- Esconder todas
local function esconderAbas()
	for _, a in ipairs(abas) do
		a.Visible = false
	end
end

-- Função de animação
local function animarAba(aba)
	aba.Visible = true

	local tweenPos = TweenService:Create(aba, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 120, 0, 0)
	})

	local tweenFade = TweenService:Create(aba, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})

	tweenPos:Play()
	tweenFade:Play()
end

-- Botões
-- MODIFICADO: i agora vai até 6
for i = 1, 6 do 
	local botao = Instance.new("TextButton")
	botao.Name = "Botao" .. i
	botao.Size = UDim2.new(1, -20, 0, 40)
	botao.BackgroundColor3 = Color3.fromRGB(50, 52, 80)
	botao.BorderSizePixel = 0
	botao.Text = "Aba " .. i
	if i == 2 then botao.Text = "Aba 2 (Auto Rock)" end

	-- *** NOVO: Definir o nome da Aba 6 aqui ***
	if i == 6 then botao.Text = "Aba 6 (Exemplo)" end

	botao.TextColor3 = Color3.new(1, 1, 1)
	botao.Parent = sideBar

	botao.MouseButton1Click:Connect(function()
		esconderAbas()
		animarAba(abas[i])
	end)
end
