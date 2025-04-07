-- Services
local SG: StarterGui = game:GetService("StarterGui");
local CG: CoreGui = game:GetService("CoreGui");
local Plrs: Players = game:GetService("Players");
local RunS: RunService = game:GetService("RunService");
local TS: TweenService = game:GetService("TweenService");
local LT = game:GetService("Lighting");
local UIS = game:GetService("UserInputService");

-- Player
local plr: Player = Plrs.LocalPlayer;
local mouse: Mouse = plr:GetMouse();
local char: Model = plr.Character or plr.CharacterAdded:Wait();
local hum: Humanoid = char:WaitForChild("Humanoid");
local root: BasePart = char:WaitForChild("HumanoidRootPart");
local huma: Animator = hum:WaitForChild("Animator");

local Tools: {() -> any?} = {};
local RealTools: {Tool} = {};

local function randomString(): string
	local str = "";
	for i = 1, math.random(10, 50) do
		str = str .. string.char(math.random(33, 126));
	end
	return str;
end

-- Repositório de strings do código
local modules = {
	Spring = [[
		local Spring = {} Spring.__index = Spring
		function Spring:Update(dt)
			local t, k, d, x0, v0 = self.t, self.k, self.d, self.x, self.v
			local a0 = k*(t - x0) + v0*d
			local v1 = v0 + a0*(dt/2)
			local a1 = k*(t - (x0 + v0*(dt/2))) + v1*d
			local v2 = v0 + a1*(dt/2)
			local a2 = k*(t - (x0 + v1*(dt/2))) + v2*d
			local v3 = v0 + a2*dt
			local x4 = x0 + (v0 + 2*(v1 + v2) + v3)*(dt/6)
			self.x, self.v = x4, v0 + (a0 + 2*(a1 + a2) + k*(t - (x0 + v2*dt)) + v3*d)*(dt/6)
			return x4
		end
		function Spring.new(stiffness, dampingCoeff, dampingRatio, initialPos)
			local self = setmetatable({}, Spring)
			dampingRatio = dampingRatio or 1
			local m = dampingCoeff*dampingCoeff/(4*stiffness*dampingRatio*dampingRatio)
			self.k = stiffness/m
			self.d = -dampingCoeff/m
			self.x = initialPos
			self.t = initialPos
			self.v = initialPos*0
			return self
		end
		return Spring
	]],
	Maid = [[
		local destructors = {
			['function'] = function(item) item() end;
			['RBXScriptConnection'] = function(item) item:Disconnect() end;
			['Instance'] = function(item) item:Destroy() end;
		}
		local Maid = {} Maid.__index = Maid
		function Maid:Mark(item)
			if destructors[typeof(item)] then
				self.trash[#self.trash + 1] = item
			else
				error(('Maid does not support type "%s"'):format(typeof(item)), 2)
			end
		end
		function Maid:Unmark(item)
			if item then
				local trash = self.trash
				for i = 1, #trash do
					if trash[i] == item then
						table.remove(trash, i)
						break
					end
				end
			else
				self.trash = {}
			end
		end
		function Maid:Sweep()
			local trash = self.trash
			for i = 1, #trash do
				local item = trash[i]
				destructors[typeof(item)](item)
			end
			self.trash = {}
		end
		function Maid.new()
			local self = setmetatable({}, Maid)
			self.trash = {}
			return self
		end
		return Maid.new()
	]]
}

-- Função para carregar o código de string como módulo
local function loadModule(name)
	local source = modules[name]
	if not source then
		error("Module '" .. name .. "' not found.")
	end
	local func = loadstring(source)
	return func()
end

-- Usa os módulos
local Spring = loadModule("Spring")
local Maid = loadModule("Maid")

local Accessory = Instance.new("Accessory") do
	Accessory.AccessoryType = Enum.AccessoryType.Hat
	Accessory.Name = randomString()

	local Handle = Instance.new("Part")
	Handle.FormFactor = Enum.FormFactor.Custom
	Handle.AssemblyAngularVelocity = Vector3.new(1, 1, 1)
	Handle.BottomSurface = Enum.SurfaceType.Smooth
	Handle.CFrame = CFrame.new(120.9, 16, 149, 1, -0, 0, 0, 1, -0, -0, 0, 1)
	Handle.CanQuery = false
	Handle.CanTouch = false
	Handle.Material = Enum.Material.DiamondPlate
	Handle.Position = Vector3.new(120.9, 16, 149)
	Handle.RotVelocity = Vector3.new(1, 1, 1)
	Handle.Size = Vector3.new(1.4, 0.6, 1.8)
	Handle.TopSurface = Enum.SurfaceType.Smooth
	Handle.Name = "Handle"

	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = "rbxassetid://3909331612"
	Mesh.TextureId = "rbxassetid://3932430383"
	Mesh.Offset = Vector3.new(0, 0.17, -0.27)

	local FaceCenterAttachment = Instance.new("Attachment")
	FaceCenterAttachment.CFrame = CFrame.new(0, -0.2, 0.05, 1, 0, -0, -0, 1, 0, 0, -0, 1)
	FaceCenterAttachment.Orientation = Vector3.new(-0, -0, -0)
	FaceCenterAttachment.Position = Vector3.new(0, -0.2, 0.05)
	FaceCenterAttachment.Rotation = Vector3.new(-0, -0, -0)
	FaceCenterAttachment.Name = "FaceCenterAttachment"

	local OriginalSize = Instance.new("Vector3Value")
	OriginalSize.Value = Vector3.new(1.4, 0.6, 1.8)
	OriginalSize.Name = "OriginalSize"

	Accessory.Parent = nil
	Handle.Parent = Accessory
	Mesh.Parent = Handle
	FaceCenterAttachment.Parent = Handle
	OriginalSize.Parent = Handle
end

local Config = {
	['TweenSpeed'] = 1;
	["CurrentTween"] = nil;
	["TweenSpeedInputConnection"] = nil;

	['GhostEnabled'] = false;
	['GhostModeConnection'] = nil;

	['DestroyBind'] = Instance.new("BindableFunction");
	['InstanceToDestroy'] = nil;
	['LastDestroyedInstance'] = nil;
	['OriginalParent'] = nil;
	['UndoMode'] = false;
	['ChangeUndoModeConnection'] = nil;

	['GogglesAcc'] = Accessory;
	['GogglesEnabled'] = false;
	['GogglesFilterEnabled'] = true;
	['GogglesFilterConnection'] = nil;
	['LightBrightness'] = 3;
	['LightBrightnessInputConnection'] = nil;

	['iceCubeEnabled'] = false;

	["CamConfig"] = {
		mobileHolding = {
			["DIRECTION_FORWARD"] = false,
			["DIRECTION_LEFT"] = false,
			["DIRECTION_BACKWARD"] = false,
			["DIRECTION_RIGHT"] = false,
			["DIRECTION_DOWN"] = false,
			["DIRECTION_UP"] = false,
		};

		KEY_MAPPINGS = {
			["DIRECTION_LEFT"] = {Enum.KeyCode.A, Enum.KeyCode.H},
			["DIRECTION_RIGHT"] = {Enum.KeyCode.D, Enum.KeyCode.K},
			["DIRECTION_FORWARD"] = {Enum.KeyCode.W, Enum.KeyCode.U},
			["DIRECTION_BACKWARD"] = {Enum.KeyCode.S, Enum.KeyCode.J},
			["DIRECTION_UP"] = {Enum.KeyCode.Q, Enum.KeyCode.I},
			["DIRECTION_DOWN"] = {Enum.KeyCode.E, Enum.KeyCode.Y},
		};

		['FreeCamEnabled'] = false;

		['DEF_FOV'] = 70;
		['NM_ZOOM'] = math.tan(70 * math.pi/360);
		['LVEL_GAIN'] = Vector3.new(1, 0.75, 1);
		['RVEL_GAIN'] = Vector2.new(0.85, 1)/128;
		['FVEL_GAIN'] = -330;
		['DEADZONE'] = 0.125;
		['FOCUS_OFFSET'] = CFrame.new(0, 0, -16);

		['DIRECTION_LEFT'] = 1;
		['DIRECTION_RIGHT'] = 2;
		['DIRECTION_FORWARD'] = 3;
		['DIRECTION_BACKWARD'] = 4;
		['DIRECTION_UP'] = 5;
		['DIRECTION_DOWN'] = 6;

		stateRot = Vector2.new();
		panDeltaGamepad = Vector2.new();
		panDeltaMouse = Vector2.new();

		velSpring = Spring.new(7/9, 1/3, 1, Vector3.new());
		rotSpring = Spring.new(7/9, 1/3, 1, Vector2.new());
		fovSpring = Spring.new(2,   1/3, 1, 0);

		gp_x  = 0;
		gp_z  = 0;
		gp_l1 = 0;
		gp_r1 = 0;
		rate_fov = 0;

		SpeedModifier = 1;
		screenGuis = {};
	};

	['KeybindsConnection'] = nil;

	['ToolsConfig'] = {
		['TpToolParticlesColor'] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 85, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 85, 255))});
		['TweenToolParticlesColor'] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 255, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 255, 0))});
		['GhostToolParticlesColor'] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))});
		['DestroyToolParticlesColor'] = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0))});
	},
}

local CoreGuiAccess: boolean, _ = pcall(function()
	return CG:GetChildren()
end)

local GetPlatformFuncAccess: boolean, result = pcall(function()
	return UIS:GetPlatform()
end)

local isPC: boolean = (GetPlatformFuncAccess and (result == Enum.Platform.Windows or result == Enum.Platform.Linux)) or UIS.KeyboardEnabled

local mainGui = Instance.new("ScreenGui") do
	mainGui.DisplayOrder = 999;
	mainGui.IgnoreGuiInset = true;
	mainGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
	mainGui.ResetOnSpawn = false;
	mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;

	mainGui.Parent = CoreGuiAccess and CG or plr:WaitForChild("PlayerGui")
end

local UndoModeButton = Instance.new("TextButton") do
	UndoModeButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	UndoModeButton.Text = "Toggle Undo";
	UndoModeButton.TextColor = BrickColor.new("Really black");
	UndoModeButton.TextColor3 = Color3.fromRGB(0, 0, 0);
	UndoModeButton.TextScaled = true;
	UndoModeButton.TextSize = 14;
	UndoModeButton.TextWrapped = true;
	UndoModeButton.AnchorPoint = Vector2.new(0.5, 0.5);
	UndoModeButton.BackgroundColor3 = Color3.fromRGB(0, 85, 255);
	UndoModeButton.BorderColor = BrickColor.new("Really black");
	UndoModeButton.BorderColor3 = Color3.fromRGB(0, 0, 0);
	UndoModeButton.BorderSizePixel = 0;
	UndoModeButton.Position = UDim2.new(0.75, 0, 0.11, 0);
	UndoModeButton.Size = UDim2.new(0.1, 0, 0.05, 0);

	UndoModeButton.Name = randomString()

	local UICorner = Instance.new("UICorner");
	UICorner.Name = randomString()

	UndoModeButton.Parent = mainGui;
	UICorner.Parent = UndoModeButton;
end

local FilterButton = Instance.new("TextButton") do
	FilterButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	FilterButton.Text = "Filter"
	FilterButton.TextColor = BrickColor.new("Really black")
	FilterButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	FilterButton.TextScaled = true
	FilterButton.TextSize = 14
	FilterButton.TextWrapped = true
	FilterButton.AnchorPoint = Vector2.new(0.5, 0.5)
	FilterButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	FilterButton.BorderColor = BrickColor.new("Really black")
	FilterButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FilterButton.BorderSizePixel = 0
	FilterButton.Position = UDim2.new(0.83, 0, 0.11, 0)
	FilterButton.Size = UDim2.new(0.07, 0, 0.05, 0)

	local UICorner = Instance.new("UICorner")

	FilterButton.Parent = mainGui
	UICorner.Parent = FilterButton
end

local LightInput = Instance.new("TextBox") do
	LightInput.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	LightInput.PlaceholderColor3 = Color3.fromRGB(125, 125, 125)
	LightInput.PlaceholderText = "Light Brightness"
	LightInput.Text = ""
	LightInput.TextColor = BrickColor.new("Really black")
	LightInput.TextColor3 = Color3.fromRGB(0, 0, 0)
	LightInput.TextScaled = true
	LightInput.TextSize = 14
	LightInput.TextWrapped = true
	LightInput.AnchorPoint = Vector2.new(0.5, 0.5)
	LightInput.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	LightInput.BorderColor = BrickColor.new("Really black")
	LightInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LightInput.BorderSizePixel = 0
	LightInput.Position = UDim2.new(0.745, 0, 0.159, 0)
	LightInput.Size = UDim2.new(0.091, 0, 0.05, 0)

	local UICorner = Instance.new("UICorner")

	LightInput.Parent = mainGui
	UICorner.Parent = LightInput
end

local TweenSpeedInput = Instance.new("TextBox") do
	TweenSpeedInput.CursorPosition = -1
	TweenSpeedInput.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	TweenSpeedInput.PlaceholderColor3 = Color3.fromRGB(225, 225, 225)
	TweenSpeedInput.PlaceholderText = "Tween Speed"
	TweenSpeedInput.Text = ""
	TweenSpeedInput.TextColor = BrickColor.new("Institutional white")
	TweenSpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	TweenSpeedInput.TextScaled = true
	TweenSpeedInput.TextSize = 14
	TweenSpeedInput.TextWrapped = true
	TweenSpeedInput.AnchorPoint = Vector2.new(0.5, 0.5)
	TweenSpeedInput.BackgroundColor3 = Color3.fromRGB(85, 170, 0)
	TweenSpeedInput.BorderColor = BrickColor.new("Really black")
	TweenSpeedInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TweenSpeedInput.BorderSizePixel = 0
	TweenSpeedInput.Position = UDim2.new(0.83, 0, 0.16, 0)
	TweenSpeedInput.Size = UDim2.new(0.08, 0, 0.05, 0)

	local UICorner = Instance.new("UICorner")

	TweenSpeedInput.Parent = mainGui
	UICorner.Parent = TweenSpeedInput
end

local CanvasGroup = Instance.new("CanvasGroup")
CanvasGroup.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CanvasGroup.BackgroundTransparency = 0.5
CanvasGroup.BorderColor = BrickColor.new("Really black")
CanvasGroup.BorderColor3 = Color3.fromRGB(0, 0, 0)
CanvasGroup.BorderSizePixel = 0
CanvasGroup.Position = UDim2.new(0.68, 0, 0.54, 0)
CanvasGroup.Size = UDim2.new(0.25, 0, 0.25, 0)
CanvasGroup.Transparency = 0.5

local s_B = Instance.new("TextButton")
s_B.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
s_B.Text = "S"
s_B.TextColor = BrickColor.new("Institutional white")
s_B.TextColor3 = Color3.fromRGB(255, 255, 255)
s_B.TextScaled = true
s_B.TextSize = 14
s_B.TextWrapped = true
s_B.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
s_B.BorderColor = BrickColor.new("Really black")
s_B.BorderColor3 = Color3.fromRGB(0, 0, 0)
s_B.BorderSizePixel = 0
s_B.Position = UDim2.new(0.35, 0, 0.55, 0)
s_B.Size = UDim2.new(0.28, 0, 0.45, 0)
s_B.Name = "s_B"

local a_B = Instance.new("TextButton")
a_B.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
a_B.Text = "A"
a_B.TextColor = BrickColor.new("Institutional white")
a_B.TextColor3 = Color3.fromRGB(255, 255, 255)
a_B.TextScaled = true
a_B.TextSize = 14
a_B.TextWrapped = true
a_B.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
a_B.BorderColor = BrickColor.new("Really black")
a_B.BorderColor3 = Color3.fromRGB(0, 0, 0)
a_B.BorderSizePixel = 0
a_B.Position = UDim2.new(0.08, 0, 0.55, 0)
a_B.Size = UDim2.new(0.28, 0, 0.45, 0)
a_B.Name = "a_B"

local w_B = Instance.new("TextButton")
w_B.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
w_B.Text = "W"
w_B.TextColor = BrickColor.new("Institutional white")
w_B.TextColor3 = Color3.fromRGB(255, 255, 255)
w_B.TextScaled = true
w_B.TextSize = 14
w_B.TextWrapped = true
w_B.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
w_B.BorderColor = BrickColor.new("Really black")
w_B.BorderColor3 = Color3.fromRGB(0, 0, 0)
w_B.BorderSizePixel = 0
w_B.Position = UDim2.new(0.35, 0, 0.1, 0)
w_B.Size = UDim2.new(0.28, 0, 0.45, 0)
w_B.Name = "w_B"

local d_B = Instance.new("TextButton")
d_B.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
d_B.Text = "D"
d_B.TextColor = BrickColor.new("Institutional white")
d_B.TextColor3 = Color3.fromRGB(255, 255, 255)
d_B.TextScaled = true
d_B.TextSize = 14
d_B.TextWrapped = true
d_B.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
d_B.BorderColor = BrickColor.new("Really black")
d_B.BorderColor3 = Color3.fromRGB(0, 0, 0)
d_B.BorderSizePixel = 0
d_B.Position = UDim2.new(0.62, 0, 0.55, 0)
d_B.Size = UDim2.new(0.28, 0, 0.45, 0)
d_B.Name = "d_B"

local e_B = Instance.new("TextButton")
e_B.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
e_B.Text = "E"
e_B.TextColor = BrickColor.new("Institutional white")
e_B.TextColor3 = Color3.fromRGB(255, 255, 255)
e_B.TextScaled = true
e_B.TextSize = 14
e_B.TextWrapped = true
e_B.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
e_B.BorderColor = BrickColor.new("Really black")
e_B.BorderColor3 = Color3.fromRGB(0, 0, 0)
e_B.BorderSizePixel = 0
e_B.Position = UDim2.new(0.62, 0, 0.1, 0)
e_B.Size = UDim2.new(0.28, 0, 0.45, 0)
e_B.Name = "e_B"

local q_B = Instance.new("TextButton")
q_B.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
q_B.Text = "Q"
q_B.TextColor = BrickColor.new("Institutional white")
q_B.TextColor3 = Color3.fromRGB(255, 255, 255)
q_B.TextScaled = true
q_B.TextSize = 14
q_B.TextWrapped = true
q_B.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
q_B.BorderColor = BrickColor.new("Really black")
q_B.BorderColor3 = Color3.fromRGB(0, 0, 0)
q_B.BorderSizePixel = 0
q_B.Position = UDim2.new(0.08, 0, 0.1, 0)
q_B.Size = UDim2.new(0.28, 0, 0.45, 0)
q_B.Name = "q_B"

CanvasGroup.Parent = mainGui
s_B.Parent = CanvasGroup
a_B.Parent = CanvasGroup
w_B.Parent = CanvasGroup
d_B.Parent = CanvasGroup
e_B.Parent = CanvasGroup
q_B.Parent = CanvasGroup

CanvasGroup.Visible = false

local light = Instance.new("SpotLight") do
	light.Brightness = 3;
	light.Range = 60;
	light.Angle = 180;
	light.Name = randomString()

	light.Parent = Accessory.Handle
end

local correnction = Instance.new("ColorCorrectionEffect") do
	correnction.TintColor = Color3.new(0, 1, 0)
	correnction.Brightness = 0
	correnction.Enabled = false
	correnction.Name = randomString()	

	correnction.Parent = LT
end

local iceCube = Instance.new("Part") do
	iceCube.BottomSurface = Enum.SurfaceType.Smooth
	iceCube.BrickColor = BrickColor.new("Light blue")
	iceCube.CanCollide = false
	iceCube.CanQuery = false
	iceCube.CanTouch = false
	iceCube.Color = Color3.fromRGB(180, 210, 228)
	iceCube.Position = Vector3.new(121, 18.45, 155.3)
	iceCube.Reflectance = 1
	iceCube.Size = Vector3.new(4, 1, 2)
	iceCube.TopSurface = Enum.SurfaceType.Smooth
	iceCube.Transparency = 0.3
	iceCube.Name = randomString()

	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = "rbxassetid://1504522132"
	Mesh.Scale = Vector3.new(1.7, 2.2, 1.4)

	Mesh.Parent = iceCube
end

local destroyHighlight: Highlight = Instance.new("Highlight") do
	destroyHighlight.FillTransparency = 1;
	destroyHighlight.OutlineColor = Color3.fromRGB(255, 170, 0);
	destroyHighlight.Parent = CoreGuiAccess and CG or plr:WaitForChild("PlayerGui");
	destroyHighlight.Name = randomString();
end

local function SendCoreMessage(choose: boolean, title: string, content: string, duration: number?, icon: string?): nil
	if not choose then
		SG:SetCore("SendNotification", {
			Title = title;
			Text = content;
			Duration = duration or 5;
			Icon = icon;
		});
	else
		SG:SetCore("SendNotification", {
			Title = title;
			Text = content;
			Duration = duration or 5;
			Icon = icon;
			Button1 = "Yes";
			Button2 = "No";
			Callback = Config.DestroyBind;
		});
	end
end

local function CreateBaseParticles(parent: Instance, color: ColorSequence): nil
	local Wave: ParticleEmitter = Instance.new("ParticleEmitter") do
		Wave.Color = color;
		Wave.Lifetime = NumberRange.new(1);
		Wave.LockedToPart = true;
		Wave.Rate = 2;
		Wave.Rotation = NumberRange.new(90);
		Wave.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(0.06, 0.26, 0), NumberSequenceKeypoint.new(0.11, 0.52, 0), NumberSequenceKeypoint.new(0.17, 0.78, 0), NumberSequenceKeypoint.new(0.22, 1.03, 0), NumberSequenceKeypoint.new(0.28, 1.27, 0), NumberSequenceKeypoint.new(0.33, 1.5, 0), NumberSequenceKeypoint.new(0.39, 1.72, 0), NumberSequenceKeypoint.new(0.44, 1.93, 0), NumberSequenceKeypoint.new(0.5, 2.12, 0), NumberSequenceKeypoint.new(0.56, 2.3, 0), NumberSequenceKeypoint.new(0.61, 2.46, 0), NumberSequenceKeypoint.new(0.67, 2.6, 0), NumberSequenceKeypoint.new(0.72, 2.72, 0), NumberSequenceKeypoint.new(0.78, 2.82, 0), NumberSequenceKeypoint.new(0.83, 2.9, 0), NumberSequenceKeypoint.new(0.89, 2.95, 0), NumberSequenceKeypoint.new(0.94, 2.99, 0), NumberSequenceKeypoint.new(1, 3, 0), NumberSequenceKeypoint.new(1, 3, 0)});
		Wave.Speed = NumberRange.new(0);
		Wave.Texture = "rbxassetid://1084963972";
		Wave.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)});
		Wave.Name = "Wave";
	end

	local Core: ParticleEmitter = Instance.new("ParticleEmitter") do
		Core.Color = color;
		Core.Lifetime = NumberRange.new(1);
		Core.LightEmission = 1;
		Core.LockedToPart = true;
		Core.Rate = 3;
		Core.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.75, 0), NumberSequenceKeypoint.new(1, 0.75, 0)});
		Core.Speed = NumberRange.new(0);
		Core.Texture = "rbxassetid://1084962479";
		Core.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1, 0), NumberSequenceKeypoint.new(0.5, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)})
		Core.ZOffset = 0;
		Core.Name = "Core";
	end

	local Rays_Thick: ParticleEmitter = Instance.new("ParticleEmitter") do
		Rays_Thick.Color = color;
		Rays_Thick.Lifetime = NumberRange.new(1, 2);
		Rays_Thick.LightEmission = 1;
		Rays_Thick.LockedToPart = true;
		Rays_Thick.Rate = 2.5;
		Rays_Thick.RotSpeed = NumberRange.new(-75, 75);
		Rays_Thick.Rotation = NumberRange.new(-180, 180);
		Rays_Thick.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(0.06, 0.44, 0), NumberSequenceKeypoint.new(0.11, 0.87, 0), NumberSequenceKeypoint.new(0.17, 1.29, 0), NumberSequenceKeypoint.new(0.22, 1.71, 0), NumberSequenceKeypoint.new(0.28, 2.11, 0), NumberSequenceKeypoint.new(0.33, 2.5, 0), NumberSequenceKeypoint.new(0.39, 2.87, 0), NumberSequenceKeypoint.new(0.44, 3.21, 0), NumberSequenceKeypoint.new(0.5, 3.53, 0), NumberSequenceKeypoint.new(0.56, 3.83, 0), NumberSequenceKeypoint.new(0.61, 4.09, 0), NumberSequenceKeypoint.new(0.67, 4.33, 0), NumberSequenceKeypoint.new(0.72, 4.53, 0), NumberSequenceKeypoint.new(0.78, 4.7, 0), NumberSequenceKeypoint.new(0.83, 4.83, 0), NumberSequenceKeypoint.new(0.89, 4.92, 0), NumberSequenceKeypoint.new(0.94, 4.98, 0), NumberSequenceKeypoint.new(1, 5, 0), NumberSequenceKeypoint.new(1, 5, 0)});
		Rays_Thick.Speed = NumberRange.new(0);
		Rays_Thick.Texture = "rbxassetid://1053548563";
		Rays_Thick.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)});
		Rays_Thick.Name = "Rays_Thick";
	end

	local Rays_Thin: ParticleEmitter = Instance.new("ParticleEmitter") do
		Rays_Thin.Color = color;
		Rays_Thin.Lifetime = NumberRange.new(1, 2);
		Rays_Thin.LightEmission = 1;
		Rays_Thin.LockedToPart = true;
		Rays_Thin.Rate = 2.5;
		Rays_Thin.RotSpeed = NumberRange.new(-75, 75);
		Rays_Thin.Rotation = NumberRange.new(-180, 180);
		Rays_Thin.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(0.06, 0.44, 0), NumberSequenceKeypoint.new(0.11, 0.87, 0), NumberSequenceKeypoint.new(0.17, 1.29, 0), NumberSequenceKeypoint.new(0.22, 1.71, 0), NumberSequenceKeypoint.new(0.28, 2.11, 0), NumberSequenceKeypoint.new(0.33, 2.5, 0), NumberSequenceKeypoint.new(0.39, 2.87, 0), NumberSequenceKeypoint.new(0.44, 3.21, 0), NumberSequenceKeypoint.new(0.5, 3.53, 0), NumberSequenceKeypoint.new(0.56, 3.83, 0), NumberSequenceKeypoint.new(0.61, 4.09, 0), NumberSequenceKeypoint.new(0.67, 4.33, 0), NumberSequenceKeypoint.new(0.72, 4.53, 0), NumberSequenceKeypoint.new(0.78, 4.7, 0), NumberSequenceKeypoint.new(0.83, 4.83, 0), NumberSequenceKeypoint.new(0.89, 4.92, 0), NumberSequenceKeypoint.new(0.94, 4.98, 0), NumberSequenceKeypoint.new(1, 5, 0), NumberSequenceKeypoint.new(1, 5, 0)});
		Rays_Thin.Speed = NumberRange.new(0);
		Rays_Thin.Texture = "rbxassetid://1084961641";
		Rays_Thin.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)});
		Rays_Thin.Name = "Rays_Thin";
	end

	Wave.Parent = parent;
	Core.Parent = parent;
	Rays_Thick.Parent = parent;
	Rays_Thin.Parent = parent;
end

local function TeleportOrTween(tween: boolean): nil
	if not tween then
		root.CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 3, mouse.Hit.Z, select(4, root.CFrame:GetComponents()));
	else
		local Tinfo: TweenInfo = TweenInfo.new(Config.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut);

		if Config.CurrentTween then
			Config.CurrentTween:Cancel();
			Config.CurrentTween = nil;
		end

		local tween: Tween = TS:Create(root, Tinfo, {CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 3, mouse.Hit.Z, select(4, root.CFrame:GetComponents()))});
		tween:Play()
		Config.CurrentTween = tween
	end
end

local function GhostMode()
	Config.GhostEnabled = not Config.GhostEnabled;

	if not Config.GhostEnabled then
		if Config.GhostModeConnection then
			Config.GhostModeConnection:Disconnect();
			Config.GhostModeConnection = nil;
		end
	end

	if Config.GhostEnabled then
		for _, v: Instance in pairs(char:GetChildren()) do
			if v:IsA("BasePart") and v ~= root then
				v.Transparency = 0.5;
			elseif v:IsA("Accessory") then
				v.Handle.Transparency = 0.5;
			end
		end

		Config.GhostModeConnection = RunS.RenderStepped:Connect(function()
			if Config.GhostEnabled then
				for _, child in pairs(char:GetDescendants()) do
					if child:IsA("BasePart") and child.CanCollide == true then
						child.CanCollide = false;
					end
				end
			end
		end)
	else
		for _, v: Instance in pairs(char:GetChildren()) do
			if v:IsA("BasePart") and v ~= root then
				v.Transparency = 0;
			elseif v:IsA("Accessory") then
				v.Handle.Transparency = 0;
			end
		end
	end
end

local function DestroyFunc(undo: boolean): nil
	if not undo then
		if Config.InstanceToDestroy then return end

		local target: BasePart? = mouse.Target;

		if target and target ~= iceCube then
			Config.InstanceToDestroy = target
			SendCoreMessage(true, "Destroy Tool", "Are you sure of this?", math.huge, "rbxassetid://15889469852");
			destroyHighlight.Adornee = target;
			destroyHighlight.Parent = workspace;
		end
	else
		if Config.LastDestroyedInstance then
			if Config.OriginalParent and Config.OriginalParent.Parent then
				Config.LastDestroyedInstance.Parent = Config.OriginalParent;
				Config.LastDestroyedInstance = nil;
				Config.OriginalParent = nil;

				destroyHighlight.Adornee = nil;
				destroyHighlight.Parent = CoreGuiAccess and CG or plr:WaitForChild("PlayerGui");
			end
		end
	end
end

local function ngGoggles(): nil
	Config.GogglesEnabled = not Config.GogglesEnabled

	correnction.Enabled = Config.GogglesEnabled

	Accessory.Parent = Config.GogglesEnabled and char or nil
end

local function IceCube(): nil
	Config.iceCubeEnabled = not Config.iceCubeEnabled

	for _, v in char:GetChildren() do
		if v:IsA("BasePart") and v ~= iceCube then
			v.Anchored = Config.iceCubeEnabled
		end
	end

	iceCube.Parent = Config.iceCubeEnabled and char or nil
end

-- Tools setup
do
	function Tools.setupTpTool(): nil
		local Tool: Tool = Instance.new("Tool") do
			Tool.TextureId = "rbxassetid://6723742952";
			Tool.ToolTip = "Alt + Z";
		end

		local Handle: Part = Instance.new("Part") do
			Handle.Name = "Handle";
			Handle.BottomSurface = Enum.SurfaceType.Smooth;
			Handle.CFrame = CFrame.new(120.2, 12.5, 178.4, 0, 1, 0, -1, 0, 0, 0, 0, 1);
			Handle.Orientation = Vector3.new(0, 0, -90);
			Handle.Position = Vector3.new(120.2, 12.5, 178.4);
			Handle.Rotation = Vector3.new(0, 0, -90);
			Handle.CanCollide = false;
			Handle.Size = Vector3.new(1, 1, 1);
			Handle.TopSurface = Enum.SurfaceType.Smooth;
			Handle.Transparency = 1;
		end

		local Attachment: Attachment = Instance.new("Attachment");

		CreateBaseParticles(Attachment, Config.ToolsConfig.TpToolParticlesColor);

		do
			Handle.Parent = Tool;
			Attachment.Parent = Handle;
		end

		Tool.Activated:Connect(function(): nil
			TeleportOrTween(false);
		end)

		table.insert(RealTools, Tool); 
		return Tool;
	end

	function Tools.setupTweenTool(): nil
		local Tool: Tool = Instance.new("Tool") do
			Tool.TextureId = "rbxassetid://10507122420";
			Tool.ToolTip = "Alt + X";
		end

		local Handle: Part = Instance.new("Part") do
			Handle.Name = "Handle";
			Handle.BottomSurface = Enum.SurfaceType.Smooth;
			Handle.CFrame = CFrame.new(120.2, 12.5, 178.4, 0, 1, 0, -1, 0, 0, 0, 0, 1);
			Handle.Orientation = Vector3.new(0, 0, -90);
			Handle.Position = Vector3.new(120.2, 12.5, 178.4);
			Handle.Rotation = Vector3.new(0, 0, -90);
			Handle.CanCollide = false;
			Handle.Size = Vector3.new(1, 1, 1);
			Handle.TopSurface = Enum.SurfaceType.Smooth;
			Handle.Transparency = 1;
		end

		local Attachment: Attachment = Instance.new("Attachment");

		CreateBaseParticles(Attachment, Config.ToolsConfig.TweenToolParticlesColor);

		do
			Handle.Parent = Tool;
			Attachment.Parent = Handle;
		end

		Tool.Activated:Connect(function(): nil
			TeleportOrTween(true);
		end)

		table.insert(RealTools, Tool);
		return Tool;
	end

	function Tools.setupGhostTool(): nil
		local Tool: Tool = Instance.new("Tool") do
			Tool.TextureId = "rbxassetid://14436167187";
			Tool.ToolTip = "Alt + C";
		end

		local Handle: Part = Instance.new("Part") do
			Handle.Name = "Handle";
			Handle.BottomSurface = Enum.SurfaceType.Smooth;
			Handle.CFrame = CFrame.new(120.2, 12.5, 178.4, 0, 1, 0, -1, 0, 0, 0, 0, 1);
			Handle.Orientation = Vector3.new(0, 0, -90);
			Handle.Position = Vector3.new(120.2, 12.5, 178.4);
			Handle.Rotation = Vector3.new(0, 0, -90);
			Handle.CanCollide = false;
			Handle.Size = Vector3.new(1, 1, 1);
			Handle.TopSurface = Enum.SurfaceType.Smooth;
			Handle.Transparency = 1;
		end

		local Attachment: Attachment = Instance.new("Attachment");

		CreateBaseParticles(Attachment, Config.ToolsConfig.GhostToolParticlesColor);

		local Ghosts = Instance.new("ParticleEmitter") do
			Ghosts.Acceleration = Vector3.new(0, 3, 0);
			Ghosts.Color = Config.ToolsConfig.GhostToolParticlesColor;
			Ghosts.Lifetime = NumberRange.new(2);
			Ghosts.LightEmission = 1;
			Ghosts.Rate = 10;
			Ghosts.RotSpeed = NumberRange.new(-30, 30);
			Ghosts.Rotation = NumberRange.new(-20);
			Ghosts.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(0.5, 1.06, 0), NumberSequenceKeypoint.new(1, 0, 0)});
			Ghosts.Speed = NumberRange.new(3);
			Ghosts.SpreadAngle = Vector2.new(360, 360);
			Ghosts.Texture = "http://www.roblox.com/asset/?id=314784167";
			Ghosts.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5, 0), NumberSequenceKeypoint.new(1, 0.5, 0)});
			Ghosts.VelocitySpread = 360;
			Ghosts.Name = "Ghosts";
		end

		do
			Handle.Parent = Tool
			Attachment.Parent = Handle
			Ghosts.Parent = Attachment
		end

		Tool.Activated:Connect(GhostMode)

		table.insert(RealTools, Tool); 
		return Tool;
	end

	function Tools.setupDestroyTool(): nil
		local Tool: Tool = Instance.new("Tool") do
			Tool.TextureId = "rbxassetid://15889469852";
			Tool.ToolTip = "Alt + V";
		end

		local Handle: Part = Instance.new("Part") do
			Handle.Name = "Handle";
			Handle.BottomSurface = Enum.SurfaceType.Smooth;
			Handle.CFrame = CFrame.new(120.2, 12.5, 178.4, 0, 1, 0, -1, 0, 0, 0, 0, 1);
			Handle.Orientation = Vector3.new(0, 0, -90);
			Handle.Position = Vector3.new(120.2, 12.5, 178.4);
			Handle.Rotation = Vector3.new(0, 0, -90);
			Handle.CanCollide = false;
			Handle.Size = Vector3.new(1, 1, 1);
			Handle.TopSurface = Enum.SurfaceType.Smooth;
			Handle.Transparency = 1;
		end

		local Attachment: Attachment = Instance.new("Attachment");

		CreateBaseParticles(Attachment, Config.ToolsConfig.DestroyToolParticlesColor);

		local Bricks = Instance.new("ParticleEmitter") do
			Bricks.Acceleration = Vector3.new(0, 3, 0)
			Bricks.Color = Config.ToolsConfig.DestroyToolParticlesColor
			Bricks.Lifetime = NumberRange.new(2)
			Bricks.LightEmission = 1
			Bricks.Rate = 10
			Bricks.RotSpeed = NumberRange.new(-30, 30)
			Bricks.Rotation = NumberRange.new(-20)
			Bricks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(0.5, 0.75, 0), NumberSequenceKeypoint.new(1, 0, 0)})
			Bricks.Speed = NumberRange.new(3)
			Bricks.SpreadAngle = Vector2.new(360, 360)
			Bricks.Texture = "rbxassetid://15889469852"
			Bricks.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5, 0), NumberSequenceKeypoint.new(1, 0.5, 0)})
			Bricks.VelocitySpread = 360
			Bricks.Name = "Bricks"
		end

		do
			Handle.Parent = Tool;
			Attachment.Parent = Handle;
			Bricks.Parent = Attachment;
		end

		Tool.Activated:Connect(function(): nil
			DestroyFunc(Config.UndoMode);
		end)

		table.insert(RealTools, Tool); 
		return Tool;
	end

	function Tools.setupNGTool(): nil
		local Tool = Instance.new("Tool") do
			Tool.TextureId = "rbxassetid://551406114";
			Tool.RequiresHandle = false;
			Tool.ToolTip = "Alt + G";
		end

		Tool.Activated:Connect(ngGoggles);

		table.insert(RealTools, Tool);
		return Tool
	end

	function Tools.setupIceTool(): nil
		local Tool = Instance.new("Tool") do
			Tool.TextureId = "rbxassetid://17832637918";
			Tool.RequiresHandle = false;
			Tool.ToolTip = "Alt + F";
		end

		Tool.Activated:Connect(IceCube);

		table.insert(RealTools, Tool);
		return Tool
	end

	function Tools.setupFreeCamTool(): nil
		local Tool = Instance.new("Tool") do
			Tool.TextureId = "rbxassetid://13287444653";
			Tool.RequiresHandle = false;
			Tool.ToolTip = "Shift + P";
		end

		local function SetupCam()
			local camera = workspace.CurrentCamera

			local WasGuiVisible = {}
			local function ToggleGui(on)
				if not on then
					WasGuiVisible["PointsNotificationsActive"] = SG:GetCore("PointsNotificationsActive")
					WasGuiVisible["BadgesNotificationsActive"] = SG:GetCore("BadgesNotificationsActive")
					WasGuiVisible["Health"] = SG:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
					WasGuiVisible["Backpack"] = SG:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
					WasGuiVisible["PlayerList"] = SG:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
					WasGuiVisible["Chat"] = SG:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
				end

				local function GuiOn(name)
					if on == false then
						return false
					end
					if WasGuiVisible[name] ~= nil then
						return WasGuiVisible[name]
					end
					return true
				end

				SG:SetCore("PointsNotificationsActive", GuiOn("PointsNotificationsActive"))
				SG:SetCore("BadgesNotificationsActive", GuiOn("BadgesNotificationsActive"))

				SG:SetCoreGuiEnabled(Enum.CoreGuiType.Health, GuiOn("Health"))
				SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, GuiOn("Backpack"))
				SG:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, GuiOn("PlayerList"))
				SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, GuiOn("Chat"))
			end

			------------------------------------------------

			------------------------------------------------

			------------------------------------------------

			local function Clamp(x, min, max)
				return x < min and min or x > max and max or x
			end

			local function GetChar()
				local character = plr.Character
				if character then
					return character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
				end
			end

			local function InputCurve(x)
				local s = math.abs(x)
				if s > Config.CamConfig.DEADZONE then
					s = 0.255000975*(2^(2.299113817*s) - 1)
					return x > 0 and (s > 1 and 1 or s) or (s > 1 and -1 or -s)
				end
				return 0
			end

			------------------------------------------------

			local function IsDirectionDown(direction)
				for i = 1, #Config.CamConfig.KEY_MAPPINGS[direction] do
					if UIS:IsKeyDown(Config.CamConfig.KEY_MAPPINGS[direction][i]) then
						return true
					end
				end

				for  _, v in Config.CamConfig.mobileHolding do
					if v == direction then
						return true
					end
				end
				return false
			end

			local UpdateFreecam do
				local dt = 1/60
				RunS.RenderStepped:Connect(function(_dt)
					dt = _dt
				end)

				function UpdateFreecam()
					local camCFrame = camera.CFrame

					local kx = (IsDirectionDown(Config.CamConfig.KEY_MAPPINGS.DIRECTION_RIGHT) and 1 or 0) - (IsDirectionDown(Config.CamConfig.KEY_MAPPINGS.DIRECTION_LEFT) and 1 or 0)
					local ky = (IsDirectionDown(Config.CamConfig.KEY_MAPPINGS.DIRECTION_UP) and 1 or 0) - (IsDirectionDown(Config.CamConfig.KEY_MAPPINGS.DIRECTION_DOWN) and 1 or 0)
					local kz = (IsDirectionDown(Config.CamConfig.KEY_MAPPINGS.DIRECTION_BACKWARD) and 1 or 0) - (IsDirectionDown(Config.CamConfig.KEY_MAPPINGS.DIRECTION_FORWARD) and 1 or 0)
					local km = (kx * kx) + (ky * ky) + (kz * kz)
					if km > 1e-15 then
						km = ((UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) and 1/4 or 1)/math.sqrt(km)
						kx = kx * km
						ky = ky * km
						kz = kz * km
					end

					local dx = kx + Config.CamConfig.gp_x
					local dy = ky + Config.CamConfig.gp_r1 - Config.CamConfig.gp_l1
					local dz = kz + Config.CamConfig.gp_z

					Config.CamConfig.velSpring.t = Vector3.new(dx, dy, dz) * Config.CamConfig.SpeedModifier
					Config.CamConfig.rotSpring.t = Config.CamConfig.panDeltaMouse + Config.CamConfig.panDeltaGamepad
					Config.CamConfig.fovSpring.t = Clamp(Config.CamConfig.fovSpring.t + dt * Config.CamConfig.rate_fov*Config.CamConfig.FVEL_GAIN, 5, 120)

					local fov  = Config.CamConfig.fovSpring:Update(dt)
					local dPos = Config.CamConfig.velSpring:Update(dt) * Config.CamConfig.LVEL_GAIN
					local dRot = Config.CamConfig.rotSpring:Update(dt) * (Config.CamConfig.RVEL_GAIN * math.tan(fov * math.pi/360) * Config.CamConfig.NM_ZOOM)

					Config.CamConfig.rate_fov = 0
					Config.CamConfig.panDeltaMouse = Vector2.new()

					Config.CamConfig.stateRot = Config.CamConfig.stateRot + dRot
					Config.CamConfig.stateRot = Vector2.new(Clamp(Config.CamConfig.stateRot.x, -3/2, 3/2), Config.CamConfig.stateRot.y)

					local c = CFrame.new(camCFrame.p) * CFrame.Angles(0, Config.CamConfig.stateRot.y, 0) * CFrame.Angles(Config.CamConfig.stateRot.x, 0, 0) * CFrame.new(dPos)

					camera.CFrame = c
					camera.Focus = c*Config.CamConfig.FOCUS_OFFSET
					camera.FieldOfView = fov
				end
			end

			------------------------------------------------

			local function Panned(input, processed)
				if not processed and input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Delta
					Config.CamConfig.panDeltaMouse = Vector2.new(-delta.y, -delta.x)
				end
			end

			------------------------------------------------

			local function EnterFreecam()
				ToggleGui(false)
				UIS.MouseIconEnabled = false
				Maid:Mark(UIS.InputBegan:Connect(function(input, processed)
					if input.UserInputType == Enum.UserInputType.MouseButton2 then
						UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
						local conn = UIS.InputChanged:Connect(Panned)
						repeat
							input = UIS.InputEnded:wait()
						until input.UserInputType == Enum.UserInputType.MouseButton2 or not Config.CamConfig.freeCamEnabled
						Config.CamConfig.panDeltaMouse = Vector2.new()
						Config.CamConfig.panDeltaGamepad = Vector2.new()
						conn:Disconnect()
						if Config.CamConfig.freeCamEnabled then
							UIS.MouseBehavior = Enum.MouseBehavior.Default
						end
					elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
						Config.CamConfig.SpeedModifier = 0.5
					end
				end))

				Maid:Mark(UIS.InputEnded:Connect(function(input, processed)
					if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
						Config.CamConfig.SpeedModifier = 1
					end
				end))

				camera.CameraType = Enum.CameraType.Scriptable

				local hum, hrp = GetChar()
				if hrp then
					hrp.Anchored = true
				end
				if hum then
					hum.WalkSpeed = 0
					Maid:Mark(hum.Jumping:Connect(function(active)
						if active then
							hum.Jumping = false
						end
					end))
				end

				Config.CamConfig.velSpring.t, Config.CamConfig.velSpring.v, Config.CamConfig.velSpring.x = Vector3.new(), Vector3.new(), Vector3.new()
				Config.CamConfig.rotSpring.t, Config.CamConfig.rotSpring.v, Config.CamConfig.rotSpring.x = Vector2.new(), Vector2.new(), Vector2.new()
				Config.CamConfig.fovSpring.t, Config.CamConfig.fovSpring.v, Config.CamConfig.fovSpring.x = camera.FieldOfView, 0, camera.FieldOfView

				local camCFrame = camera.CFrame
				local lookVector = camCFrame.lookVector.unit

				Config.CamConfig.stateRot = Vector2.new(
					math.asin(lookVector.y),
					math.atan2(-lookVector.z, lookVector.x) - math.pi/2
				)
				Config.CamConfig.panDeltaMouse = Vector2.new()

				local plrGui = plr:WaitForChild("PlayerGui")
				for _, obj in next, plrGui:GetChildren() do
					if obj:IsA("ScreenGui") and obj.Enabled then
						obj.Enabled = false
						Config.CamConfig.screenGuis[obj] = true
					end
				end
				RunS:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, UpdateFreecam)
				Config.CamConfig.freeCamEnabled = true
			end

			local function ExitFreecam()
				Config.CamConfig.freeCamEnabled = false
				UIS.MouseIconEnabled = true
				UIS.MouseBehavior = Enum.MouseBehavior.Default
				Maid:Sweep()
				RunS:UnbindFromRenderStep("Freecam")
				local hum, hrp = GetChar()
				if hum then
					hum.WalkSpeed = 16
				end
				if hrp then
					hrp.Anchored = false
				end
				camera.FieldOfView = Config.CamConfig.DEF_FOV
				camera.CameraType = Enum.CameraType.Custom
				for obj in next, Config.CamConfig.screenGuis do
					obj.Enabled = true
				end
				Config.CamConfig.screenGuis = {}
				ToggleGui(true)
			end

			------------------------------------------------

			for _, v in script.Parent:FindFirstChildWhichIsA("CanvasGroup"):GetChildren() do
				if v:IsA("TextButton") then
					v.MouseButton1Up:Connect(function()
						if v.Name == "w_B" then
							Config.CamConfig.mobileHolding.DIRECTION_FORWARD = true
						end
						if v.Name == "a_B" then
							Config.CamConfig.mobileHolding.DIRECTION_RIGHT = true
						end
						if v.Name == "s_B" then
							Config.CamConfig.mobileHolding.DIRECTION_BACKWARD = true
						end
						if v.Name == "d_B" then
							Config.CamConfig.mobileHolding.DIRECTION_LEFT = true
						end
						if v.Name == "q_B" then
							Config.CamConfig.mobileHolding.DIRECTION_UP = true
						end
						if v.Name == "e_B" then
							Config.CamConfig.mobileHolding.DIRECTION_DOWN = true
						end
					end)

					v.MouseButton1Down:Connect(function()
						if v.Name == "w_B" then
							Config.CamConfig.mobileHolding.DIRECTION_FORWARD = false
						end
						if v.Name == "a_B" then
							Config.CamConfig.mobileHolding.DIRECTION_RIGHT = false
						end
						if v.Name == "s_B" then
							Config.CamConfig.mobileHolding.DIRECTION_BACKWARD = false
						end
						if v.Name == "d_B" then
							Config.CamConfig.mobileHolding.DIRECTION_LEFT = false
						end
						if v.Name == "q_B" then
							Config.CamConfig.mobileHolding.DIRECTION_UP = false
						end
						if v.Name == "e_B" then
							Config.CamConfig.mobileHolding.DIRECTION_DOWN = false
						end
					end)
				end
			end

			UIS.InputBegan:Connect(function(input, processed)
				if not processed then
					if UIS:IsKeyDown(Enum.KeyCode.LeftShift)  then
						if UIS:IsKeyDown(Enum.KeyCode.P) then
							if Config.CamConfig.freeCamEnabled then
								ExitFreecam()
							else
								EnterFreecam()
							end
						end
					end
				end
			end)
		end

		SetupCam()

		Tool.Activated:Connect(function() end);

		table.insert(RealTools, Tool);
		return Tool
	end
end

local TpTool = Tools.setupTpTool();
local TweenTool = Tools.setupTweenTool();
local GhostTool = Tools.setupGhostTool();
local DestroyTool = Tools.setupDestroyTool();
local GogglesTool = Tools.setupNGTool();
local IceTool = Tools.setupIceTool();
local FreeCamTool = Tools.setupFreeCamTools

Config.DestroyBind.OnInvoke = function(selected: string)
	local confirmDestroy: boolean = selected == "Yes"

	if confirmDestroy then
		if Config.InstanceToDestroy then
			SendCoreMessage(false, "Destroy Tool", `Instance Destroyed: {Config.InstanceToDestroy:GetFullName()}`, 3, "rbxassetid://15889469852")
			Config.OriginalParent = Config.InstanceToDestroy.Parent
			Config.InstanceToDestroy.Parent = nil
			Config.LastDestroyedInstance = Config.InstanceToDestroy
			Config.InstanceToDestroy = nil
		end
	else
		destroyHighlight.Adornee = nil
		destroyHighlight.Parent = CoreGuiAccess and CG or plr:WaitForChild("PlayerGui")
	end
end

local function toggleUndoMode()
	Config.UndoMode = not Config.UndoMode;

	SendCoreMessage(false, "Destroy Tool", "Undo Mode Enabled:" .. tostring(Config.UndoMode), 1.5, "rbxassetid://15889469852")

	for _: number, v: Instance in DestroyTool:GetDescendants() do
		if v:IsA("ParticleEmitter") then
			v.Color = Config.UndoMode and Config.ToolsConfig.TpToolParticlesColor or Config.ToolsConfig.DestroyToolParticlesColor;
		end
	end
end

local function toggleNGFilter()
	Config.GogglesFilterEnabled = not Config.GogglesFilterEnabled
end

local function handleInput(elementName, text, obj)
	local input = tonumber(text)

	obj.Text = ""

	if input then
		Config[elementName] = input
	end
end

Config.ChangeUndoModeConnection = UndoModeButton.Activated:Connect(toggleUndoMode)
Config.GogglesFilterConnection = FilterButton.Activated:Connect(toggleNGFilter)
Config.LightBrightnessInputConnection = LightInput.FocusLost:Connect(function(entered) if entered then handleInput("LightBrightness", LightInput.Text, LightInput) end end)
Config.LightBrightnessInputConnection = TweenSpeedInput.FocusLost:Connect(function(entered) if entered then handleInput("TweenSpeed", TweenSpeedInput.Text, TweenSpeedInput) end end)

RunS:BindToRenderStep("Things", Enum.RenderPriority.Character.Value, function()
	iceCube.CFrame = root.CFrame
	iceCube.Mesh.Scale = Vector3.new(1.7, 2.2, 1.4) * char:GetScale()
	light.Brightness = Config.LightBrightness

	correnction.TintColor = Config.GogglesFilterEnabled and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
	FilterButton.BackgroundColor3 = Config.GogglesFilterEnabled and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
	UndoModeButton.BackgroundColor3 = Config.UndoMode and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(0, 85, 255)

	CanvasGroup.Visible = (not isPC and Config.CamConfig.freeCamEnabled)
end)

local function DestroyAndDisconnectAll(): nil
	for i, v: Instance? in pairs(Config) do
		if string.find(i, "Connection") then
			v:Diconnect()
			v = nil
		end

		if typeof(v) == "boolean" then
			v = false
		end
	end

	GhostMode()
	ngGoggles()

	for _: number, v: Tool in RealTools do
		v:Destroy();
	end

	mainGui:Destroy()
	Accessory:Destroy()
	correnction:Destroy()
	destroyHighlight:Destroy()

	RunS:UnbindFromRenderStep("Things")
	RunS:UnbindFromRenderStep("Freecam")

	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.CameraSubject = hum

	table.clear(RealTools)
end

local Keybinds = {
	Z = function() TeleportOrTween(false) end,
	X = function() TeleportOrTween(true) end,
	C = function() GhostMode() end,
	V = function() DestroyFunc(Config.UndoMode) end,
	F = function() IceCube() end,
	G = function() ngGoggles() end,
	T = function() toggleNGFilter() end,
	Y = function() toggleUndoMode() end,
}

Config.KeybindsConnection = UIS.InputBegan:Connect(function(input: InputObject, isTyping: boolean)
	if isTyping then return end

	local keyFunc = Keybinds[input.KeyCode.Name];
	if (keyFunc and input.KeyCode.Name ~= "P") then
		if (UIS:IsKeyDown(Enum.KeyCode.LeftAlt) or UIS:IsKeyDown(Enum.KeyCode.RightAlt)) then
			keyFunc();
		end
	elseif keyFunc and input.KeyCode.Name == "P" then
		if (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) then
			keyFunc();
		end
	end
end)

for _: number, v: Tool in RealTools do
	v.Name = randomString();
	v.Parent = plr.Backpack;
end

for _, v in mainGui:GetDescendants() do
	if string.find(v.Name, "_B") then continue end

	v.Name = randomString();
end

hum.Died:Connect(DestroyAndDisconnectAll);
