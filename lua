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
if not PlayerGui then warn("Hindi mahanap ang PlayerGui!") return end

if PlayerGui:FindFirstChild("VisualItemResizer") then
	PlayerGui.VisualItemResizer:Destroy()
end

-- ===================== UI SETUP =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisualItemResizer"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- Main Panel (centered)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 300, 0, 160)
panel.Position = UDim2.new(0.5, -150, 0.5, -80)
panel.BackgroundColor3 = Color3.fromRGB(13, 15, 26)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(130, 80, 255)
panelStroke.Thickness = 1
panelStroke.Transparency = 0.65
panelStroke.Parent = panel

-- Header (drag bar)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 38)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(19, 21, 37)
header.BorderSizePixel = 0
header.Parent = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

-- Fix bottom corners of header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Color3.fromRGB(19, 21, 37)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
headerLine.BackgroundTransparency = 0.8
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙ PET CHANGER BUG SCRIPT"
titleLabel.TextColor3 = Color3.fromRGB(160, 130, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Body Layout
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -28, 0, 110)
body.Position = UDim2.new(0, 14, 0, 44)
body.BackgroundTransparency = 1
body.Parent = panel

local bodyLayout = Instance.new("UIListLayout")
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.Padding = UDim.new(0, 8)
bodyLayout.Parent = body

-- Item Row
local itemRow = Instance.new("Frame")
itemRow.Size = UDim2.new(1, 0, 0, 36)
itemRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
itemRow.BackgroundTransparency = 0.96
itemRow.LayoutOrder = 1
itemRow.Parent = body
Instance.new("UICorner", itemRow).CornerRadius = UDim.new(0, 10)

local itemStroke = Instance.new("UIStroke")
itemStroke.Color = Color3.fromRGB(255, 255, 255)
itemStroke.Thickness = 1
itemStroke.Transparency = 0.9
itemStroke.Parent = itemRow

local itemLabel = Instance.new("TextLabel")
itemLabel.Size = UDim2.new(1, -20, 1, 0)
itemLabel.Position = UDim2.new(0, 10, 0, 0)
itemLabel.BackgroundTransparency = 1
itemLabel.Text = "❌ No pet equipped"
itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
itemLabel.Font = Enum.Font.Gotham
itemLabel.TextSize = 12
itemLabel.TextXAlignment = Enum.TextXAlignment.Left
itemLabel.Parent = itemRow

-- Main Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 0, 42)
button.BackgroundColor3 = Color3.fromRGB(80, 40, 200)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.Text = "🎲 Random Size"
button.LayoutOrder = 2
button.Parent = body
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 11)

-- Footer
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, 20)
footer.BackgroundTransparency = 1
footer.LayoutOrder = 3
footer.Parent = body

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.new(1, 0, 1, 0)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = "Made by Mark L."
creditsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
creditsLabel.TextTransparency = 0.5
creditsLabel.Font = Enum.Font.GothamBold
creditsLabel.TextSize = 10
creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
creditsLabel.Parent = footer

-- ===================== DRAG LOGIC =====================
local dragging = false
local dragInput, dragStart, startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- ===================== RESIZER LOGIC =====================
local isScaled = false
local currentScale = 1
local originalTool = nil
local visualClone = nil
local renderConnection = nil
local partMap = {}

local allowedSizes = {
	{name = "NORMAL", mult = 1, color = Color3.fromRGB(160, 160, 180)},
	{name = "BIG", mult = 3, color = Color3.fromRGB(100, 220, 150)},
	{name = "MEGA", mult = 6, color = Color3.fromRGB(255, 180, 50)}
}

local function clearScale()
	if renderConnection then renderConnection:Disconnect() renderConnection = nil end
	if visualClone then visualClone:Destroy() visualClone = nil end
	if originalTool then
		-- Ibalik agad sa original na itsura/visibility ang tunay na tool
		for _, part in ipairs(originalTool:GetDescendants()) do
			if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
		end
	end
	partMap = {}
	originalTool = nil
	isScaled = false
	currentScale = 1
end

local function scaleTool(tool, scaleMult)
	clearScale()
	local character = LocalPlayer.Character
	if not character then return end
	
	originalTool = tool
	currentScale = scaleMult
	
	-- Kung Normal (1x), hindi na kailangan ng giant clone overlay
	if scaleMult == 1 then
		isScaled = true
		return
	end
	
	visualClone = tool:Clone()
	visualClone.Name = "AnimatedVisual_" .. tool.Name
	visualClone:ScaleTo(scaleMult)
	
	for _, part in ipairs(visualClone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
			part.LocalTransparencyModifier = 0
		elseif part:IsA("Script") or part:IsA("LocalScript") or part:IsA("TouchTransmitter") then
			part:Destroy()
		end
	end
	
	partMap = {}
	for _, origPart in ipairs(tool:GetDescendants()) do
		if origPart:IsA("BasePart") then
			local clonePart = visualClone:FindFirstChild(origPart.Name, true)
			if clonePart and clonePart:IsA("BasePart") then
				partMap[origPart] = clonePart
			end
		end
	end
	
	visualClone.Parent = Workspace.CurrentCamera
	
	for _, part in ipairs(tool:GetDescendants()) do
		if part:IsA("BasePart") then part.LocalTransparencyModifier = 1 end
	end
	
	renderConnection = RunService.RenderStepped:Connect(function()
		-- INSTANT RESET: Kapag nawala ang tool sa character, clear agad!
		if not tool or not tool.Parent or tool.Parent ~= character or not visualClone then
			clearScale()
			return
		end
		for origPart, clonePart in pairs(partMap) do
			if origPart and origPart.Parent and clonePart and clonePart.Parent then
				clonePart.CanCollide = false
				clonePart.Anchored = true
				local relativeCFrame = tool:GetPivot():ToObjectSpace(origPart.CFrame)
				local scaledPosition = relativeCFrame.Position * scaleMult
				clonePart.CFrame = tool:GetPivot():ToWorldSpace(CFrame.new(scaledPosition) * CFrame.Angles(relativeCFrame:ToEulerAnglesXYZ()))
			end
		end
	end)
	isScaled = true
end

local function doRandomSize()
	local character = LocalPlayer.Character
	if not character then return end
	local tool = character:FindFirstChildOfClass("Tool")
	
	if tool then
		local selectedData = allowedSizes[math.random(1, #allowedSizes)]
		scaleTool(tool, selectedData.mult)
		
		panelStroke.Color = selectedData.color
		itemLabel.Text = "✅ " .. tool.Name
		itemLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
		
		TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 60, 220)}):Play()
		task.wait(0.1)
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 40, 200)}):Play()
	else
		itemLabel.Text = "❌ No pet equipped"
		itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		button.Text = "❗ Hold a pet first!"
		task.wait(1.2)
		button.Text = "🎲 Random Size"
	end
end

-- Button Listeners
button.MouseButton1Click:Connect(doRandomSize)

button.MouseEnter:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(100, 55, 220)}):Play()
end)
button.MouseLeave:Connect(function()
	TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 40, 200)}):Play()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.R then doRandomSize() end
end)

-- Mabilis na Continuous Checker Loop (Ginawang 0.05 para instant maramdaman)
task.spawn(function()
	while screenGui and screenGui.Parent do
		task.wait(0.05)
		local character = LocalPlayer.Character
		if character then
			local tool = character:FindFirstChildOfClass("Tool")
			if tool then
				itemLabel.Text = "✅ " .. tool.Name
				itemLabel.TextColor3 = Color3.fromRGB(100, 220, 150)
				-- Kung biglang nagpalit ng tool habang naka-scale
				if isScaled and originalTool ~= tool then
					scaleTool(tool, currentScale)
				end
			else
				-- INSTANT RETURN TO NORMAL SIZE KAPAG HINDI NA HAWAK
				if isScaled or visualClone or originalTool then 
					clearScale() 
				end
				itemLabel.Text = "❌ No pet equipped"
				itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
				panelStroke.Color = Color3.fromRGB(130, 80, 255)
			end
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	clearScale()
	itemLabel.Text = "❌ No pet equipped"
	itemLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	panelStroke.Color = Color3.fromRGB(130, 80, 255)
end)

print("✅ UI Fixed - Instant automatic back to normal size kapag binitawan ang pet!")
