-- Siguraduhing tapos mag-load ang laro bago patakbuhin ang script
if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then
	warn("Hindi mahanap ang PlayerGui!")
	return
end

-- BURAHIN ANG LUMANG UI
if PlayerGui:FindFirstChild("VisualItemResizer") then
	PlayerGui.VisualItemResizer:Destroy()
end

-- ===================== SIMPLE UI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisualItemResizer"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local button = Instance.new("TextButton")
button.Name = "SizeButton"
button.Size = UDim2.new(0, 280, 0, 65)
button.Position = UDim2.new(0.5, -140, 0.85, 0)
button.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Text = "🎲 Random Size"
button.Active = true
button.Selectable = true
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(130, 80, 255)
stroke.Thickness = 2.5
stroke.Transparency = 0.4
stroke.Parent = button

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(0, 280, 0, 22)
sizeLabel.Position = UDim2.new(0.5, -140, 0.85, 70)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "Size: Normal"
sizeLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
sizeLabel.Font = Enum.Font.Gotham
sizeLabel.TextSize = 12
sizeLabel.Parent = screenGui

local itemLabel = Instance.new("TextLabel")
itemLabel.Size = UDim2.new(0, 280, 0, 20)
itemLabel.Position = UDim2.new(0.5, -140, 0.85, 48)
itemLabel.BackgroundTransparency = 1
itemLabel.Text = "❌ Walang item"
itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
itemLabel.Font = Enum.Font.Gotham
itemLabel.TextSize = 12
itemLabel.Parent = screenGui

-- ===================== LIVE-ANIMATION TRACKING SYSTEM =====================
local isScaled = false
local currentScale = 1
local originalTool = nil
local visualClone = nil
local renderConnection = nil
local partMap = {} -- Dito natin ise-save ang pares ng Original Part at Clone Part

local function clearScale()
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
	
	if visualClone then
		visualClone:Destroy()
		visualClone = nil
	end
	
	if originalTool and originalTool.Parent then
		for _, part in ipairs(originalTool:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end
	
	partMap = {}
	originalTool = nil
	isScaled = false
	currentScale = 1
end

local function scaleTool(tool, scaleMult)
	clearScale() -- Linisin ang lumang clone
	
	local character = LocalPlayer.Character
	if not character then return end
	
	originalTool = tool
	currentScale = scaleMult
	
	-- Gumawa ng visual clone ng prutas o tool
	visualClone = tool:Clone()
	visualClone.Name = "AnimatedVisual_" .. tool.Name
	
	-- I-scale ang buong hugis gamit ang ScaleTo
	visualClone:ScaleTo(scaleMult)
	
	-- I-setup ang clone properties (Anti-Fly + Anti-Lag)
	for _, part in ipairs(visualClone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
			part.LocalTransparencyModifier = 0
		elseif part:IsA("Script") or part:IsA("LocalScript") or part:IsA("TouchTransmitter") then
			part:Destroy()
		end
	end
	
	-- I-map o ipares ang bawat orihinal na part sa kanyang katumbas na pinalaking clone part
	partMap = {}
	for _, origPart in ipairs(tool:GetDescendants()) do
		if origPart:IsA("BasePart") then
			-- Hanapin ang kaparehas na part sa clone gamit ang pangalan (at hierarchy kung kailangan)
			local clonePart = visualClone:FindFirstChild(origPart.Name, true)
			if clonePart and clonePart:IsA("BasePart") then
				partMap[origPart] = clonePart
			end
		end
	end
	
	-- Ilagay sa loob ng Camera para 100% iwas glitch sa lipad
	visualClone.Parent = Workspace.CurrentCamera
	
	-- Itago ang orihinal na maliit na tool sa kamay mo
	for _, part in ipairs(tool:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 1
		end
	end
	
	-- ADVANCED FRAME-BY-FRAME ANIMATION SYNC
	renderConnection = RunService.RenderStepped:Connect(function()
		if not tool or not tool.Parent or not character or not character.Parent or not visualClone then
			clearScale()
			return
		end
		
		-- Kunin ang sentro ng orihinal na tool bilang base reference para sa offset ng scaling
		local origCenter = tool:GetPivot().Position
		local cloneCenter = visualClone:GetPivot().Position
		
		-- I-sync ang GALAW at IKOT ng bawat part base sa animation ng laro
		for origPart, clonePart in pairs(partMap) do
			if origPart and origPart.Parent and clonePart and clonePart.Parent then
				-- Pwersahing patayin ang collision ng clone bawat frame para siguradong hindi ka lilipad
				clonePart.CanCollide = false
				clonePart.Anchored = true
				
				-- KUNIN ANG LIHIM NG GALAW: 
				-- Kalkulahin ang relative position (offset) ng orihinal na part mula sa center,
				-- i-multiply sa scale multiplier ang distansya, at i-add sa center ng kamay.
				local relativeCFrame = tool:GetPivot():ToObjectSpace(origPart.CFrame)
				local scaledPosition = relativeCFrame.Position * scaleMult
				
				-- Ilapat ang bagong kinalabasan kasama ang eksaktong Rotation/Ikot mula sa animation ng laro
				clonePart.CFrame = tool:GetPivot():ToWorldSpace(CFrame.new(scaledPosition) * CFrame.Angles(relativeCFrame:ToEulerAnglesXYZ()))
			end
		end
	end)
	
	isScaled = true
end

local function getRandomSize()
	local sizes = {3, 6, 10}
	return sizes[math.random(1, #sizes)]
end

local function doRandomSize()
	local character = LocalPlayer.Character
	if not character then return end
	
	local tool = character:FindFirstChildOfClass("Tool")
	
	if tool then
		local randomMult = getRandomSize()
		local sizeName = "Normal"
		if randomMult == 3 then sizeName = "BIG (3x)"
		elseif randomMult == 6 then sizeName = "MEGA (6x)"
		elseif randomMult == 10 then sizeName = "COLOSSAL (10x)"
		end
		
		scaleTool(tool, randomMult)
		
		-- Update UI
		sizeLabel.Text = "Size: " .. sizeName
		if randomMult == 3 then
			sizeLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
			stroke.Color = Color3.fromRGB(100, 220, 150)
		elseif randomMult == 6 then
			sizeLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
			stroke.Color = Color3.fromRGB(255, 180, 50)
		else
			sizeLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
			stroke.Color = Color3.fromRGB(255, 70, 70)
		end
		itemLabel.Text = "✅ " .. tool.Name
		itemLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
		
		TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 45, 80)}):Play()
		task.wait(0.1)
		TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 22, 35)}):Play()
	else
		itemLabel.Text = "❌ Walang item"
		itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		
		button.Text = "❗ Humawak muna ng item!"
		task.wait(1.2)
		button.Text = "🎲 Random Size"
	end
end

-- Button click at Keybind R
button.MouseButton1Click:Connect(doRandomSize)

button.MouseEnter:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 35, 55)}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
end)

button.MouseLeave:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 22, 35)}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.R then
		doRandomSize()
	end
end)

-- Auto-equipped item change handler
task.spawn(function()
	while screenGui and screenGui.Parent do
		task.wait(0.2)
		local character = LocalPlayer.Character
		if character then
			local tool = character:FindFirstChildOfClass("Tool")
			if tool then
				itemLabel.Text = "✅ " .. tool.Name
				itemLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
				
				if isScaled and originalTool ~= tool then
					scaleTool(tool, currentScale)
				end
			else
				if isScaled then
					clearScale()
				end
				itemLabel.Text = "❌ Walang item"
				itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
				sizeLabel.Text = "Size: Normal"
				sizeLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
				stroke.Color = Color3.fromRGB(130, 80, 255)
			end
		end
	end
end)

-- Cleanup on Death/Respawn
LocalPlayer.CharacterAdded:Connect(function()
	clearScale()
	sizeLabel.Text = "Size: Normal"
	sizeLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
	itemLabel.Text = "❌ Walang item"
	itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	stroke.Color = Color3.fromRGB(130, 80, 255)
end)

print("✅ ANIMATION SYNC FIX APPLIED - Sumasabay na ang galaw ng pinalaking prutas sa animation!")
