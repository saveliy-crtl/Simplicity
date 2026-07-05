--[=[
	Roblox UI Library Bundle
	Generated at: 2026-07-05 22:24:33
	Simple, Beautiful, Proper
]=]

local modules = {}
local function require(name)
    local module = modules[name]
    if not module then
        error("Module '" .. tostring(name) .. "' not found in bundle.")
    end
    if type(module) == "function" then
        modules[name] = module()
        return modules[name]
    end
    return module
end

-- MODULE: theme
modules["theme"] = function()local FontRegular = Font.fromEnum(Enum.Font.Gotham)
local FontMedium = Font.fromEnum(Enum.Font.GothamMedium)
local FontSemibold = Font.fromEnum(Enum.Font.GothamBold)

pcall(function()
    FontRegular = Font.new("rbxasset://fonts/families/WorkSans.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    FontMedium = Font.new("rbxasset://fonts/families/WorkSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    FontSemibold = Font.new("rbxasset://fonts/families/WorkSans.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
end)

local Theme = {
    
    -- Core colors (iOS Dark Mode palette)
    Background = Color3.fromRGB(0, 0, 0),          -- System Background (Black)
    Sidebar = Color3.fromRGB(28, 28, 30),          -- Secondary Background
    Header = Color3.fromRGB(28, 28, 30),           -- Secondary Background
    Card = Color3.fromRGB(44, 44, 46),             -- Tertiary Background (Elements)
    CardHover = Color3.fromRGB(58, 58, 60),        -- Highlighted Elements (System Gray 4)
    
    -- Accent colors (Apple iOS System Blue & Light Blue gradient)
    Accent = Color3.fromRGB(10, 132, 255),         -- iOS System Blue
    AccentGradientStart = Color3.fromRGB(10, 132, 255),
    AccentGradientEnd = Color3.fromRGB(48, 176, 255), -- iOS System Light Blue
    
    -- Borders and strokes
    Border = Color3.fromRGB(44, 44, 46),           -- Tertiary System Gray (Border)
    BorderActive = Color3.fromRGB(10, 132, 255),   -- iOS System Blue Active
    BorderMuted = Color3.fromRGB(28, 28, 30),       -- Secondary System Gray Border
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),   -- White
    TextSecondary = Color3.fromRGB(142, 142, 147), -- iOS System Gray
    TextMuted = Color3.fromRGB(99, 99, 102),       -- iOS System Gray 2
    
    -- Status colors
    Success = Color3.fromRGB(48, 209, 88),         -- iOS System Green
    Failure = Color3.fromRGB(255, 69, 58),         -- iOS System Red
    
    -- Typography
    FontSemibold = FontSemibold,
    FontMedium = FontMedium,
    FontRegular = FontRegular,
    
    -- Sizing & Layouts
    CornerRadius = UDim.new(0, 12),
    CornerRadiusSmall = UDim.new(0, 6),
    
    -- Tweens
    TweenSpeed = 0.25,
    TweenEasing = Enum.EasingStyle.Quad,
    TweenDirection = Enum.EasingDirection.Out
}

return Theme
end

-- MODULE: utility
modules["utility"] = function()local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Utility = {}

-- Safely get CoreGui or fallback to PlayerGui
function Utility.GetCoreGui()
    local success, coreGui = pcall(function()
        return CoreGui
    end)
    if success and coreGui then
        return coreGui
    end
    
    local player = Players.LocalPlayer
    if player then
        return player:WaitForChild("PlayerGui")
    end
    
    error("Could not locate CoreGui or PlayerGui")
end

-- Smooth Tween Helper
function Utility.Tween(instance, properties, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local info = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

-- Declarative Instance Creator
function Utility.Create(className, properties, children)
    local instance = Instance.new(className)
    
    for key, value in pairs(properties or {}) do
        if key ~= "Parent" then
            if key == "Font" and typeof(value) == "Font" then
                instance.FontFace = value
            else
                instance[key] = value
            end
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    
    -- Assign Parent last for performance optimization
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

-- Make GUI Draggable (Smooth and responsive)
function Utility.MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart
    local startPosition

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

-- Safe Filesystem Helpers (for executors)
Utility.IsExecutor = (writefile and readfile and isfile) and true or false

function Utility.WriteConfig(folder, name, data)
    if not Utility.IsExecutor then
        warn("Not running in exploit executor environment. Cannot save config to disk.")
        return false
    end
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if not success then
        warn("Failed to encode config data: " .. tostring(encoded))
        return false
    end
    
    -- Ensure folder exists
    pcall(function()
        if isfolder and not isfolder(folder) then
            makefolder(folder)
        end
    end)
    
    local path = folder .. "/" .. name .. ".json"
    local writeSuccess, err = pcall(function()
        writefile(path, encoded)
    end)
    
    if not writeSuccess then
        warn("Failed to write config file: " .. tostring(err))
        return false
    end
    
    return true
end

function Utility.ReadConfig(folder, name)
    if not Utility.IsExecutor then
        warn("Not running in exploit executor environment. Cannot read config from disk.")
        return nil
    end
    
    local path = folder .. "/" .. name .. ".json"
    
    local fileExists = false
    pcall(function()
        fileExists = isfile(path)
    end)
    
    if not fileExists then
        return nil
    end
    
    local success, content = pcall(function()
        return readfile(path)
    end)
    
    if not success then
        warn("Failed to read config file: " .. tostring(content))
        return nil
    end
    
    local decodeSuccess, decoded = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    
    if not decodeSuccess then
        warn("Failed to decode config: " .. tostring(decoded))
        return nil
    end
    
    return decoded
end

function Utility.ListConfigs(folder)
    if not Utility.IsExecutor or not listfiles then
        return {}
    end
    
    pcall(function()
        if isfolder and not isfolder(folder) then
            makefolder(folder)
        end
    end)
    
    local configs = {}
    local success, files = pcall(function()
        return listfiles(folder)
    end)
    
    if success and type(files) == "table" then
        for _, file in ipairs(files) do
            -- Extract file name without directory and extension
            -- example: "usefulhub_configs/combat.json" -> "combat"
            local cleanName = file:match("([^/\\]+)%.json$")
            if cleanName then
                table.insert(configs, cleanName)
            end
        end
    end
    
    return configs
end

return Utility
end

-- MODULE: components/Button
modules["components/Button"] = function()local Theme = require("theme")
local Utility = require("utility")

local Button = {}
Button.__index = Button

function Button.new(text, parent, callback)
    local self = setmetatable({}, Button)
    
    self.Text = text or "Button"
    self.Callback = callback or function() end
    
    -- Main Button Frame
    self.Frame = Utility.Create("TextButton", {
        Name = "Button_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        Text = "",
        AutoButtonColor = false
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Button Text
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    
    -- Interaction animations
    self.Frame.MouseEnter:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
        Utility.Tween(stroke, { Color = Theme.BorderActive }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
        Utility.Tween(stroke, { Color = Theme.Border }, 0.15)
    end)
    
    self.Frame.MouseButton1Down:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Accent }, 0.05)
    end)
    
    self.Frame.MouseButton1Up:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.1)
        
        -- Run callback safely in new thread
        task.spawn(function()
            local success, err = pcall(self.Callback)
            if not success then
                warn("Error in button callback: " .. tostring(err))
            end
        end)
    end)
    
    return self
end

return Button
end

-- MODULE: components/Colorpicker
modules["components/Colorpicker"] = function()local Theme = require("theme")
local Utility = require("utility")
local UserInputService = game:GetService("UserInputService")

local Colorpicker = {}
Colorpicker.__index = Colorpicker

function Colorpicker.new(text, parent, options, callback, window)
    local self = setmetatable({}, Colorpicker)
    
    options = options or {}
    self.Text = text or "Colorpicker"
    self.Default = options.default or options.Default or Color3.fromRGB(99, 102, 241) -- Default Accent (Indigo)
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    
    self.Opened = false
    self.Value = self.Default
    
    -- Deconstruct initial Color3 to HSV
    local h, s, v = Color3.toHSV(self.Default)
    self.H = h
    self.S = s
    self.V = v
    
    self.DraggingHue = false
    self.DraggingSat = false
    self.DraggingVal = false
    
    -- Main Container Frame
    self.Frame = Utility.Create("Frame", {
        Name = "Colorpicker_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        ClipsDescendants = true,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Trigger / Preview Header
        Utility.Create("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundTransparency = 1
        }, {
            -- Label
            Utility.Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = self.Text,
                TextColor3 = Theme.TextSecondary,
                TextSize = 14,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            -- Color Preview Box Button
            Utility.Create("TextButton", {
                Name = "Preview",
                Size = UDim2.new(0, 36, 0, 20),
                Position = UDim2.new(1, -51, 0.5, -10),
                BackgroundColor3 = self.Default,
                Text = "",
                AutoButtonColor = false
            }, {
                Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
                Utility.Create("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1
                })
            })
        }),
        
        -- Expanded Pane Container
        Utility.Create("Frame", {
            Name = "Pane",
            Size = UDim2.new(1, 0, 0, 110),
            Position = UDim2.new(0, 0, 0, 38),
            BackgroundTransparency = 1,
            Visible = false
        }, {
            -- HUE ROW
            Utility.Create("TextLabel", {
                Name = "HueLabel",
                Size = UDim2.new(0, 80, 0, 20),
                Position = UDim2.new(0, 15, 0, 10),
                BackgroundTransparency = 1,
                Text = "Hue",
                TextColor3 = Theme.TextSecondary,
                TextSize = 12,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Utility.Create("Frame", {
                Name = "HueTrack",
                Size = UDim2.new(1, -110, 0, 8),
                Position = UDim2.new(0, 95, 0, 16),
                BorderSizePixel = 0
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Utility.Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 0))
                    })
                }),
                Utility.Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(self.H, -7, 0.5, -7),
                    BackgroundColor3 = Theme.TextPrimary,
                    BorderSizePixel = 0
                }, {
                    Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Utility.Create("UIStroke", { Color = Theme.Background, Thickness = 1.5 })
                })
            }),
            
            -- SATURATION ROW
            Utility.Create("TextLabel", {
                Name = "SatLabel",
                Size = UDim2.new(0, 80, 0, 20),
                Position = UDim2.new(0, 15, 0, 42),
                BackgroundTransparency = 1,
                Text = "Saturation",
                TextColor3 = Theme.TextSecondary,
                TextSize = 12,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Utility.Create("Frame", {
                Name = "SatTrack",
                Size = UDim2.new(1, -110, 0, 8),
                Position = UDim2.new(0, 95, 0, 48),
                BorderSizePixel = 0
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Utility.Create("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromHSV(self.H, 1, 1))
                }),
                Utility.Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(self.S, -7, 0.5, -7),
                    BackgroundColor3 = Theme.TextPrimary,
                    BorderSizePixel = 0
                }, {
                    Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Utility.Create("UIStroke", { Color = Theme.Background, Thickness = 1.5 })
                })
            }),
            
            -- VALUE (BRIGHTNESS) ROW
            Utility.Create("TextLabel", {
                Name = "ValLabel",
                Size = UDim2.new(0, 80, 0, 20),
                Position = UDim2.new(0, 15, 0, 74),
                BackgroundTransparency = 1,
                Text = "Brightness",
                TextColor3 = Theme.TextSecondary,
                TextSize = 12,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Utility.Create("Frame", {
                Name = "ValTrack",
                Size = UDim2.new(1, -110, 0, 8),
                Position = UDim2.new(0, 95, 0, 80),
                BorderSizePixel = 0
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Utility.Create("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(self.H, self.S, 1))
                }),
                Utility.Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(self.V, -7, 0.5, -7),
                    BackgroundColor3 = Theme.TextPrimary,
                    BorderSizePixel = 0
                }, {
                    Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Utility.Create("UIStroke", { Color = Theme.Background, Thickness = 1.5 })
                })
            })
        })
    })
    
    self.HeaderFrame = self.Frame:FindFirstChild("Header")
    self.Label = self.HeaderFrame:FindFirstChild("Label")
    self.PreviewBtn = self.HeaderFrame:FindFirstChild("Preview")
    self.PreviewStroke = self.PreviewBtn:FindFirstChildOfClass("UIStroke")
    self.Stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    
    self.Pane = self.Frame:FindFirstChild("Pane")
    self.HueTrack = self.Pane:FindFirstChild("HueTrack")
    self.HueKnob = self.HueTrack:FindFirstChild("Knob")
    
    self.SatTrack = self.Pane:FindFirstChild("SatTrack")
    self.SatGradient = self.SatTrack:FindFirstChildOfClass("UIGradient")
    self.SatKnob = self.SatTrack:FindFirstChild("Knob")
    
    self.ValTrack = self.Pane:FindFirstChild("ValTrack")
    self.ValGradient = self.ValTrack:FindFirstChildOfClass("UIGradient")
    self.ValKnob = self.ValTrack:FindFirstChild("Knob")
    
    -- Click to Open Colorpicker Panel
    self.PreviewBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hover effect
    self.HeaderFrame.MouseEnter:Connect(function()
        Utility.Tween(self.Stroke, { Color = Theme.BorderActive }, 0.15)
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.HeaderFrame.MouseLeave:Connect(function()
        Utility.Tween(self.Stroke, { Color = self.Opened and Theme.BorderActive or Theme.Border }, 0.15)
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Sliders Dragging logic
    local function updateHue(input)
        local relativeX = math.clamp(input.Position.X - self.HueTrack.AbsolutePosition.X, 0, self.HueTrack.AbsoluteSize.X)
        local percentage = relativeX / self.HueTrack.AbsoluteSize.X
        self.H = percentage
        self.HueKnob.Position = UDim2.new(percentage, -7, 0.5, -7)
        self:UpdateHSV()
    end
    
    local function updateSat(input)
        local relativeX = math.clamp(input.Position.X - self.SatTrack.AbsolutePosition.X, 0, self.SatTrack.AbsoluteSize.X)
        local percentage = relativeX / self.SatTrack.AbsoluteSize.X
        self.S = percentage
        self.SatKnob.Position = UDim2.new(percentage, -7, 0.5, -7)
        self:UpdateHSV()
    end
    
    local function updateVal(input)
        local relativeX = math.clamp(input.Position.X - self.ValTrack.AbsolutePosition.X, 0, self.ValTrack.AbsoluteSize.X)
        local percentage = relativeX / self.ValTrack.AbsoluteSize.X
        self.V = percentage
        self.ValKnob.Position = UDim2.new(percentage, -7, 0.5, -7)
        self:UpdateHSV()
    end
    
    -- Hue Inputs
    self.HueTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingHue = true
            updateHue(input)
        end
    end)
    -- Sat Inputs
    self.SatTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingSat = true
            updateSat(input)
        end
    end)
    -- Val Inputs
    self.ValTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingVal = true
            updateVal(input)
        end
    end)
    
    -- Global Input Changed
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if self.DraggingHue then
                updateHue(input)
            elseif self.DraggingSat then
                updateSat(input)
            elseif self.DraggingVal then
                updateVal(input)
            end
        end
    end)
    
    -- Global Input Ended
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.DraggingHue = false
            self.DraggingSat = false
            self.DraggingVal = false
        end
    end)
    
    -- Register Flag (Store as RGB array to allow JSON serialization)
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = {self.Default.R, self.Default.G, self.Default.B}
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Apply Default Color
    self:Set(self.Default, true)
    
    return self
end

function Colorpicker:Toggle()
    self.Opened = not self.Opened
    
    local targetFrameHeight = self.Opened and 148 or 38
    
    if self.Opened then
        self.Pane.Visible = true
        Utility.Tween(self.Stroke, { Color = Theme.BorderActive }, 0.15)
    else
        Utility.Tween(self.Stroke, { Color = Theme.Border }, 0.15)
    end
    
    local frameTween = Utility.Tween(self.Frame, { Size = UDim2.new(1, 0, 0, targetFrameHeight) }, 0.15)
    
    if not self.Opened then
        frameTween.Completed:Connect(function()
            if not self.Opened then
                self.Pane.Visible = false
            end
        end)
    end
end

function Colorpicker:UpdateHSV()
    local color = Color3.fromHSV(self.H, self.S, self.V)
    self.Value = color
    
    -- Update Preview Box Color
    self.PreviewBtn.BackgroundColor3 = color
    
    -- Update intermediate gradients
    self.SatGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromHSV(self.H, 1, 1))
    self.ValGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(self.H, self.S, 1))
    
    -- Update Flags array
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = {color.R, color.G, color.B}
    end
    
    -- Fire Callback
    task.spawn(function()
        local success, err = pcall(self.Callback, color)
        if not success then
            warn("Error in colorpicker callback: " .. tostring(err))
        end
    end)
end

function Colorpicker:Set(color, force)
    -- Handle loading RGB arrays from configurations
    if type(color) == "table" then
        color = Color3.new(color[1] or 1, color[2] or 1, color[3] or 1)
    end
    
    if self.Value == color and not force then return end
    
    self.Value = color
    
    -- Re-evaluate HSV values
    local h, s, v = Color3.toHSV(color)
    self.H = h
    self.S = s
    self.V = v
    
    -- Position Knobs
    self.HueKnob.Position = UDim2.new(h, -7, 0.5, -7)
    self.SatKnob.Position = UDim2.new(s, -7, 0.5, -7)
    self.ValKnob.Position = UDim2.new(v, -7, 0.5, -7)
    
    -- Render colors
    self.PreviewBtn.BackgroundColor3 = color
    self.SatGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromHSV(h, 1, 1))
    self.ValGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(h, s, 1))
    
    -- Update Flags
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = {color.R, color.G, color.B}
    end
    
    -- Fire Callback
    task.spawn(function()
        local success, err = pcall(self.Callback, color)
        if not success then
            warn("Error in colorpicker callback: " .. tostring(err))
        end
    end)
end

return Colorpicker
end

-- MODULE: components/Dropdown
modules["components/Dropdown"] = function()local Theme = require("theme")
local Utility = require("utility")

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(text, parent, options, callback, window)
    local self = setmetatable({}, Dropdown)
    
    options = options or {}
    self.Text = text or "Dropdown"
    self.List = options.list or options.List or {}
    self.Default = options.default or options.Default
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    self.Opened = false
    self.Value = self.Default or (self.List[1] or "")
    
    -- Main Container Frame
    self.Frame = Utility.Create("Frame", {
        Name = "Dropdown_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        ClipsDescendants = true,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Trigger Button
        Utility.Create("TextButton", {
            Name = "Trigger",
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        }, {
            -- Text Label
            Utility.Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = self.Text .. ": " .. tostring(self.Value),
                TextColor3 = Theme.TextSecondary,
                TextSize = 14,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            -- Arrow Indicator
            Utility.Create("TextLabel", {
                Name = "Arrow",
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -35, 0, 0),
                BackgroundTransparency = 1,
                Text = "\226\150\188",
                TextColor3 = Theme.TextSecondary,
                TextSize = 10,
                Font = Theme.FontRegular,
                TextXAlignment = Enum.TextXAlignment.Center
            })
        }),
        -- Options Scrolling Container (Initially hidden / sized to 0)
        Utility.Create("ScrollingFrame", {
            Name = "OptionsContainer",
            Size = UDim2.new(1, -10, 0, 0),
            Position = UDim2.new(0, 5, 0, 38),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Border,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false
        }, {
            Utility.Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            Utility.Create("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })
        })
    })
    
    self.Trigger = self.Frame:FindFirstChild("Trigger")
    self.Label = self.Trigger:FindFirstChild("Label")
    self.Arrow = self.Trigger:FindFirstChild("Arrow")
    self.OptionsContainer = self.Frame:FindFirstChild("OptionsContainer")
    self.Stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    
    -- Populate options
    self:Refresh(self.List, false)
    
    -- Hover effect
    self.Trigger.MouseEnter:Connect(function()
        Utility.Tween(self.Stroke, { Color = Theme.BorderActive }, 0.15)
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Trigger.MouseLeave:Connect(function()
        Utility.Tween(self.Stroke, { Color = self.Opened and Theme.BorderActive or Theme.Border }, 0.15)
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Click toggle
    self.Trigger.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Register Flag
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = self.Value
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Initialize with default
    self:Set(self.Value, true)
    
    return self
end

function Dropdown:Toggle()
    self.Opened = not self.Opened
    
    local optionsCount = #self.List
    local maxDropdownHeight = 150
    local optionHeight = 30
    local calculatedOptionsHeight = math.min(maxDropdownHeight, optionsCount * optionHeight + 8)
    
    local targetFrameHeight = self.Opened and (38 + calculatedOptionsHeight) or 38
    local targetOptionsHeight = self.Opened and calculatedOptionsHeight or 0
    local targetArrowRotation = self.Opened and 180 or 0
    
    if self.Opened then
        self.OptionsContainer.Visible = true
        Utility.Tween(self.Stroke, { Color = Theme.BorderActive }, 0.15)
    else
        Utility.Tween(self.Stroke, { Color = Theme.Border }, 0.15)
    end
    
    Utility.Tween(self.Arrow, { Rotation = targetArrowRotation }, 0.15)
    Utility.Tween(self.OptionsContainer, { Size = UDim2.new(1, -10, 0, targetOptionsHeight) }, 0.15)
    
    local frameTween = Utility.Tween(self.Frame, { Size = UDim2.new(1, 0, 0, targetFrameHeight) }, 0.15)
    
    if not self.Opened then
        frameTween.Completed:Connect(function()
            if not self.Opened then
                self.OptionsContainer.Visible = false
            end
        end)
    end
end

function Dropdown:Set(val, force)
    if self.Value == val and not force then return end
    self.Value = val
    
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = val
    end
    
    self.Label.Text = self.Text .. ": " .. tostring(val)
    
    -- Highlight active option
    for _, child in ipairs(self.OptionsContainer:GetChildren()) do
        if child:IsA("TextButton") then
            local isSelected = child.Name == "Option_" .. tostring(val)
            Utility.Tween(child, {
                TextColor3 = isSelected and Theme.Accent or Theme.TextSecondary
            }, 0.1)
        end
    end
    
    task.spawn(function()
        local success, err = pcall(self.Callback, val)
        if not success then
            warn("Error in dropdown callback: " .. tostring(err))
        end
    end)
end

function Dropdown:Refresh(newList, selectFirst)
    self.List = newList or {}
    
    -- Clear current items
    for _, child in ipairs(self.OptionsContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Re-populate
    for index, option in ipairs(self.List) do
        local optionBtn = Utility.Create("TextButton", {
            Name = "Option_" .. tostring(option),
            Parent = self.OptionsContainer,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            Text = tostring(option),
            TextColor3 = (option == self.Value) and Theme.Accent or Theme.TextSecondary,
            TextSize = 13,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = index
        })
        
        optionBtn.MouseEnter:Connect(function()
            if self.Value ~= option then
                Utility.Tween(optionBtn, { TextColor3 = Theme.TextPrimary }, 0.1)
            end
        end)
        
        optionBtn.MouseLeave:Connect(function()
            if self.Value ~= option then
                Utility.Tween(optionBtn, { TextColor3 = Theme.TextSecondary }, 0.1)
            end
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            self:Set(option)
            self:Toggle() -- Close
        end)
    end
    
    -- Recalculate Scroll Canvas
    local uiListLayout = self.OptionsContainer:FindFirstChildOfClass("UIListLayout")
    self.OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 8)
    
    if selectFirst and #self.List > 0 then
        self:Set(self.List[1])
    elseif not table.find(self.List, self.Value) and #self.List > 0 then
        self:Set(self.List[1])
    else
        self:Set(self.Value, true)
    end
    
    -- If open, adjust heights
    if self.Opened then
        self.Opened = false
        self:Toggle()
    end
end

return Dropdown
end

-- MODULE: components/Keybind
modules["components/Keybind"] = function()local Theme = require("theme")
local Utility = require("utility")
local UserInputService = game:GetService("UserInputService")

local Keybind = {}
Keybind.__index = Keybind

local BlacklistedKeys = {
    [Enum.KeyCode.Unknown] = true,
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Slash] = true, -- Avoid binding chat
    [Enum.KeyCode.Backspace] = true,
    [Enum.KeyCode.Escape] = true
}

function Keybind.new(text, parent, options, callback, window)
    local self = setmetatable({}, Keybind)
    
    options = options or {}
    self.Text = text or "Keybind"
    self.Default = options.default or options.Default or Enum.KeyCode.RightShift
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    
    self.Value = self.Default
    self.Binding = false
    self.GlobalConnection = nil
    
    -- Main Container Frame
    self.Frame = Utility.Create("Frame", {
        Name = "Keybind_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Label (Left)
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -115, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Bind Button (Right)
        Utility.Create("TextButton", {
            Name = "BindButton",
            Size = UDim2.new(0, 80, 0, 26),
            Position = UDim2.new(1, -95, 0.5, -13),
            BackgroundColor3 = Theme.BorderMuted,
            Text = "",
            AutoButtonColor = false
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
            Utility.Create("UIStroke", {
                Color = Theme.Border,
                Thickness = 1
            }),
            -- Text inside Bind Button
            Utility.Create("TextLabel", {
                Name = "BindLabel",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = self.Default.Name,
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Center
            })
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    self.BindButton = self.Frame:FindFirstChild("BindButton")
    self.BindStroke = self.BindButton:FindFirstChildOfClass("UIStroke")
    self.BindLabel = self.BindButton:FindFirstChild("BindLabel")
    
    -- Hover effect
    self.Frame.MouseEnter:Connect(function()
        if not self.Binding then
            Utility.Tween(stroke, { Color = Theme.BorderActive }, 0.15)
        end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        if not self.Binding then
            Utility.Tween(stroke, { Color = Theme.Border }, 0.15)
        end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Binding Trigger Click
    self.BindButton.MouseButton1Click:Connect(function()
        self:StartBinding()
    end)
    
    -- Register Flag
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        -- Store as name for JSON serialization compatibility
        self.Window.Flags[self.Flag] = self.Default.Name
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Setup initial key action binding
    self:BindKey(self.Default)
    
    return self
end

function Keybind:StartBinding()
    if self.Binding then return end
    self.Binding = true
    
    self.BindLabel.Text = "..."
    Utility.Tween(self.BindStroke, { Color = Theme.Accent }, 0.15)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        local key = input.KeyCode
        
        -- Capture key press (ignore mouse movements, focus textboxes, etc.)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if not BlacklistedKeys[key] then
                connection:Disconnect()
                self.Binding = false
                self:Set(key)
            elseif key == Enum.KeyCode.Escape then
                connection:Disconnect()
                self.Binding = false
                -- Revert to original
                self:Set(self.Value)
            end
        end
    end)
end

function Keybind:Set(keyCode, force)
    -- Handle string representations (e.g. from JSON config loads)
    if type(keyCode) == "string" then
        local success, resolved = pcall(function()
            return Enum.KeyCode[keyCode]
        end)
        if success then
            keyCode = resolved
        else
            warn("Could not resolve KeyCode string: " .. tostring(keyCode))
            keyCode = self.Default
        end
    end
    
    if self.Value == keyCode and not force then return end
    
    self.Value = keyCode
    self.BindLabel.Text = keyCode.Name
    
    -- Reset Visual states
    Utility.Tween(self.BindStroke, { Color = Theme.Border }, 0.15)
    
    -- Update Config value (serialize Enum to Name string)
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = keyCode.Name
    end
    
    -- Setup new Key listener
    self:BindKey(keyCode)
    
    -- Fire Callback
    task.spawn(function()
        local success, err = pcall(self.Callback, keyCode)
        if not success then
            warn("Error in keybind callback: " .. tostring(err))
        end
    end)
end

function Keybind:BindKey(keyCode)
    -- Disconnect old connection
    if self.GlobalConnection then
        self.GlobalConnection:Disconnect()
        self.GlobalConnection = nil
    end
    
    -- Bind global event for this key
    self.GlobalConnection = UserInputService.InputBegan:Connect(function(input, processed)
        -- Ignore inputs typed in chat, textboxes, etc.
        if not processed and input.KeyCode == keyCode then
            task.spawn(function()
                local success, err = pcall(self.Callback, keyCode)
                if not success then
                    warn("Error running keybind callback: " .. tostring(err))
                end
            end)
        end
    end)
end

function Keybind:Destroy()
    if self.GlobalConnection then
        self.GlobalConnection:Disconnect()
    end
end

return Keybind
end

-- MODULE: components/Label
modules["components/Label"] = function()local Theme = require("theme")
local Utility = require("utility")

local Label = {}
Label.__index = Label

function Label.new(text, parent)
    local self = setmetatable({}, Label)
    
    self.Text = text or "Label"
    
    self.Frame = Utility.Create("Frame", {
        Name = "Label_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1
    }, {
        Utility.Create("TextLabel", {
            Name = "TextLabel",
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 13,
            Font = Theme.FontRegular,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    })
    
    self.TextLabel = self.Frame:FindFirstChild("TextLabel")
    
    return self
end

function Label.newSection(text, parent)
    local self = setmetatable({}, Label)
    
    self.Text = text or "Section"
    
    self.Frame = Utility.Create("Frame", {
        Name = "Section_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1
    }, {
        -- Small vertical accent indicator
        Utility.Create("Frame", {
            Name = "AccentBar",
            Size = UDim2.new(0, 3, 0, 14),
            Position = UDim2.new(0, 5, 0.5, -7),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall })
        }),
        -- Section Text
        Utility.Create("TextLabel", {
            Name = "TextLabel",
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = string.upper(self.Text),
            TextColor3 = Theme.TextPrimary,
            TextSize = 12,
            Font = Theme.FontSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    })
    
    self.TextLabel = self.Frame:FindFirstChild("TextLabel")
    
    return self
end

function Label:Set(text)
    self.Text = text
    self.TextLabel.Text = text
end

return Label
end

-- MODULE: components/Slider
modules["components/Slider"] = function()local Theme = require("theme")
local Utility = require("utility")
local UserInputService = game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

function Slider.new(text, parent, options, callback, window)
    local self = setmetatable({}, Slider)
    
    options = options or {}
    self.Text = text or "Slider"
    self.Min = options.min or options.Min or 0
    self.Max = options.max or options.Max or 100
    self.Default = options.default or options.Default or self.Min
    self.Step = options.step or options.Step or 1
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    self.Value = self.Default
    self.Dragging = false
    
    -- Main Container Frame
    self.Frame = Utility.Create("Frame", {
        Name = "Slider_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Label (Left-aligned, Top)
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(0.6, 0, 0, 25),
            Position = UDim2.new(0, 15, 0, 4),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Value Indicator (Right-aligned, Top)
        Utility.Create("TextLabel", {
            Name = "ValueLabel",
            Size = UDim2.new(0.35, 0, 0, 25),
            Position = UDim2.new(1, -15 - 100, 0, 4),
            BackgroundTransparency = 1,
            Text = tostring(self.Default),
            TextColor3 = Theme.TextPrimary,
            TextSize = 13,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Right
        }),
        -- Slider Track (Bottom area)
        Utility.Create("TextButton", {
            Name = "Track",
            Size = UDim2.new(1, -30, 0, 6),
            Position = UDim2.new(0, 15, 1, -14),
            BackgroundColor3 = Theme.BorderMuted,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            -- Slider Fill
            Utility.Create("Frame", {
                Name = "Fill",
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                -- Slider Knob
                Utility.Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -6, 0.5, -6),
                    BackgroundColor3 = Theme.TextPrimary,
                    BorderSizePixel = 0
                }, {
                    Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Utility.Create("UIStroke", {
                        Color = Theme.Accent,
                        Thickness = 1
                    })
                })
            })
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    self.Track = self.Frame:FindFirstChild("Track")
    self.Fill = self.Track:FindFirstChild("Fill")
    self.Knob = self.Fill:FindFirstChild("Knob")
    self.ValueLabel = self.Frame:FindFirstChild("ValueLabel")
    
    -- Hover effect
    self.Frame.MouseEnter:Connect(function()
        Utility.Tween(stroke, { Color = Theme.BorderActive }, 0.15)
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(stroke, { Color = Theme.Border }, 0.15)
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Dragging Logic
    local function updateValue(input)
        local absoluteWidth = self.Track.AbsoluteSize.X
        local relativeX = math.clamp(input.Position.X - self.Track.AbsolutePosition.X, 0, absoluteWidth)
        local percentage = relativeX / absoluteWidth
        
        local rawValue = self.Min + (self.Max - self.Min) * percentage
        -- Apply step snapping
        local steppedValue = math.round(rawValue / self.Step) * self.Step
        -- Clamping bounds in case of rounding floating issues
        steppedValue = math.clamp(steppedValue, self.Min, self.Max)
        
        self:Set(steppedValue)
    end
    
    self.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            updateValue(input)
            Utility.Tween(self.Knob, { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7) }, 0.1)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            self.Dragging = false
            Utility.Tween(self.Knob, { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6) }, 0.1)
        end
    end)
    
    -- Register Flag
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = self.Default
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Set Initial Value
    self:Set(self.Default)
    
    return self
end

function Slider:Set(val)
    -- Clamp and align to step
    val = math.clamp(math.round(val / self.Step) * self.Step, self.Min, self.Max)
    self.Value = val
    
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = val
    end
    
    -- Update visuals
    self.ValueLabel.Text = tostring(val)
    local percentage = (val - self.Min) / (self.Max - self.Min)
    -- Handle divide by zero edge case
    if self.Max == self.Min then percentage = 0 end
    
    Utility.Tween(self.Fill, { Size = UDim2.new(percentage, 0, 1, 0) }, 0.08)
    
    -- Callback trigger
    task.spawn(function()
        local success, err = pcall(self.Callback, val)
        if not success then
            warn("Error in slider callback: " .. tostring(err))
        end
    end)
end

return Slider
end

-- MODULE: components/Tab
modules["components/Tab"] = function()local Theme = require("theme")
local Utility = require("utility")

local Tab = {}
Tab.__index = Tab

function Tab.new(name, window)
    local self = setmetatable({}, Tab)
    
    self.Name = name
    self.Window = window
    self.Active = false
    
    -- 1. Tab Button in Sidebar
    local tabContainer = window.Sidebar:FindFirstChild("TabContainer")
    
    self.Button = Utility.Create("TextButton", {
        Name = "Tab_" .. name,
        Parent = tabContainer,
        Size = UDim2.new(0.9, 0, 0, 36),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.Card,
        Text = "",
        AutoButtonColor = false
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
        
        -- Text Label
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        
        -- Active Left Bar Indicator
        Utility.Create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall })
        })
    })
    
    -- 2. Content Page Frame
    self.Page = Utility.Create("ScrollingFrame", {
        Name = "Page_" .. name,
        Parent = window.ContentContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Border,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false
    }, {
        Utility.Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15)
        })
    })
    
    -- Auto-adjust CanvasSize
    local uiListLayout = self.Page:FindFirstChildOfClass("UIListLayout")
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Page.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 30)
    end)
    
    -- Button Logic
    self.Button.MouseEnter:Connect(function()
        if not self.Active then
            Utility.Tween(self.Button:FindFirstChild("Label"), { TextColor3 = Theme.TextPrimary }, 0.15)
            Utility.Tween(self.Button, { BackgroundTransparency = 0.85 }, 0.15)
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Active then
            Utility.Tween(self.Button:FindFirstChild("Label"), { TextColor3 = Theme.TextSecondary }, 0.15)
            Utility.Tween(self.Button, { BackgroundTransparency = 1 }, 0.15)
        end
    end)
    
    self.Button.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self.Name)
    end)
    
    return self
end

function Tab:Show()
    self.Active = true
    self.Page.Visible = true
    
    local label = self.Button:FindFirstChild("Label")
    local indicator = self.Button:FindFirstChild("Indicator")
    
    Utility.Tween(self.Button, { BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Card }, 0.15)
    Utility.Tween(label, { TextColor3 = Theme.TextPrimary }, 0.15)
    Utility.Tween(indicator, { BackgroundTransparency = 0 }, 0.15)
end

function Tab:Hide()
    self.Active = false
    self.Page.Visible = false
    
    local label = self.Button:FindFirstChild("Label")
    local indicator = self.Button:FindFirstChild("Indicator")
    
    Utility.Tween(self.Button, { BackgroundTransparency = 1 }, 0.15)
    Utility.Tween(label, { TextColor3 = Theme.TextSecondary }, 0.15)
    Utility.Tween(indicator, { BackgroundTransparency = 1 }, 0.15)
end

-- Component wrappers
function Tab:AddButton(text, callback)
    local Button = require("components/Button")
    return Button.new(text, self.Page, callback)
end

function Tab:AddToggle(text, options, callback)
    local Toggle = require("components/Toggle")
    return Toggle.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddSlider(text, options, callback)
    local Slider = require("components/Slider")
    return Slider.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddDropdown(text, options, callback)
    local Dropdown = require("components/Dropdown")
    return Dropdown.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddTextBox(text, placeholder, options, callback)
    local TextBox = require("components/TextBox")
    return TextBox.new(text, self.Page, placeholder, options, callback, self.Window)
end

function Tab:AddKeybind(text, options, callback)
    local Keybind = require("components/Keybind")
    return Keybind.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddColorpicker(text, options, callback)
    local Colorpicker = require("components/Colorpicker")
    return Colorpicker.new(text, self.Page, options, callback, self.Window)
end

function Tab:AddLabel(text)
    local Label = require("components/Label")
    return Label.new(text, self.Page)
end

function Tab:AddSection(text)
    local Label = require("components/Label")
    return Label.newSection(text, self.Page)
end

return Tab
end

-- MODULE: components/TextBox
modules["components/TextBox"] = function()local Theme = require("theme")
local Utility = require("utility")

local TextBox = {}
TextBox.__index = TextBox

function TextBox.new(text, parent, placeholder, options, callback, window)
    local self = setmetatable({}, TextBox)
    
    options = options or {}
    self.Text = text or "TextBox"
    self.Placeholder = placeholder or options.placeholder or options.Placeholder or "Type here..."
    self.Default = options.default or options.Default or ""
    self.Flag = options.flag or options.Flag
    self.Callback = callback or function() end
    self.Window = window
    self.Value = self.Default
    
    -- Main Container Frame
    self.Frame = Utility.Create("Frame", {
        Name = "TextBox_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Label (Left)
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -170, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Input Holder Frame (Right)
        Utility.Create("Frame", {
            Name = "InputHolder",
            Size = UDim2.new(0, 140, 0, 26),
            Position = UDim2.new(1, -155, 0.5, -13),
            BackgroundColor3 = Theme.BorderMuted,
            BorderSizePixel = 0
        }, {
            Utility.Create("UICorner", { CornerRadius = Theme.CornerRadiusSmall }),
            Utility.Create("UIStroke", {
                Color = Theme.Border,
                Thickness = 1
            }),
            -- Actual TextBox
            Utility.Create("TextBox", {
                Name = "Input",
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = self.Default,
                PlaceholderText = self.Placeholder,
                PlaceholderColor3 = Theme.TextMuted,
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                Font = Theme.FontMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false
            })
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    self.InputHolder = self.Frame:FindFirstChild("InputHolder")
    self.InputStroke = self.InputHolder:FindFirstChildOfClass("UIStroke")
    self.Input = self.InputHolder:FindFirstChild("Input")
    
    -- Focus effects
    self.Input.Focused:Connect(function()
        Utility.Tween(self.InputStroke, { Color = Theme.Accent }, 0.15)
        Utility.Tween(stroke, { Color = Theme.BorderActive }, 0.15)
    end)
    
    self.Input.FocusLost:Connect(function(enterPressed)
        Utility.Tween(self.InputStroke, { Color = Theme.Border }, 0.15)
        Utility.Tween(stroke, { Color = Theme.Border }, 0.15)
        self:Set(self.Input.Text)
    end)
    
    -- Main frame hover effects
    self.Frame.MouseEnter:Connect(function()
        if not self.Input.Focused then
            Utility.Tween(stroke, { Color = Theme.BorderActive }, 0.15)
        end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        if not self.Input.Focused then
            Utility.Tween(stroke, { Color = Theme.Border }, 0.15)
        end
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Register Flag
    if self.Flag and self.Window then
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = self.Default
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Initialize
    self:Set(self.Default, true)
    
    return self
end

function TextBox:Set(val, force)
    if self.Value == val and not force then return end
    self.Value = val
    
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = val
    end
    
    if self.Input.Text ~= val then
        self.Input.Text = val
    end
    
    task.spawn(function()
        local success, err = pcall(self.Callback, val)
        if not success then
            warn("Error in textbox callback: " .. tostring(err))
        end
    end)
end

return TextBox
end

-- MODULE: components/Toggle
modules["components/Toggle"] = function()local Theme = require("theme")
local Utility = require("utility")

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(text, parent, options, callback, window)
    local self = setmetatable({}, Toggle)
    
    options = options or {}
    self.Text = text or "Toggle"
    self.Flag = options.flag or options.Flag
    self.Default = options.default or options.Default or false
    self.Callback = callback or function() end
    self.Window = window
    self.Value = false
    
    -- Main Frame
    self.Frame = Utility.Create("TextButton", {
        Name = "Toggle_" .. self.Text,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        Text = "",
        AutoButtonColor = false
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        -- Label
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -70, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        -- Switch Track
        Utility.Create("Frame", {
            Name = "Track",
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -55, 0.5, -10),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            -- Switch Knob
            Utility.Create("Frame", {
                Name = "Knob",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = Theme.TextPrimary,
                BorderSizePixel = 0
            }, {
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
        })
    })
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    self.Track = self.Frame:FindFirstChild("Track")
    self.Knob = self.Track:FindFirstChild("Knob")
    
    -- Hover effect
    self.Frame.MouseEnter:Connect(function()
        Utility.Tween(stroke, { Color = Theme.BorderActive }, 0.15)
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(stroke, { Color = Theme.Border }, 0.15)
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Click toggle
    self.Frame.MouseButton1Click:Connect(function()
        self:Set(not self.Value)
    end)
    
    -- Register Flag in Window (if flag option was provided)
    if self.Flag and self.Window then
        -- Add registration functions to the window if not already initialized
        self.Window.Flags = self.Window.Flags or {}
        self.Window.FlagElements = self.Window.FlagElements or {}
        
        self.Window.Flags[self.Flag] = self.Default
        self.Window.FlagElements[self.Flag] = self
    end
    
    -- Set Initial Value
    self:Set(self.Default)
    
    return self
end

function Toggle:Set(state)
    self.Value = state
    
    -- Update Config Value in Library
    if self.Flag and self.Window and self.Window.Flags then
        self.Window.Flags[self.Flag] = state
    end
    
    -- Visual update (tween knob and background track color)
    local targetPos = state and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    local targetColor = state and Theme.Success or Theme.Border
    
    Utility.Tween(self.Knob, { Position = targetPos }, 0.15)
    Utility.Tween(self.Track, { BackgroundColor3 = targetColor }, 0.15)
    Utility.Tween(self.Frame:FindFirstChild("Label"), { TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary }, 0.15)
    
    -- Safe Callback execution
    task.spawn(function()
        local success, err = pcall(self.Callback, state)
        if not success then
            warn("Error in toggle callback: " .. tostring(err))
        end
    end)
end

return Toggle
end

-- MODULE: components/Window
modules["components/Window"] = function()local Theme = require("theme")
local Utility = require("utility")
local UserInputService = game:GetService("UserInputService")

local Window = {}
Window.__index = Window

function Window.new(title, configFolder)
    local self = setmetatable({}, Window)
    
    self.Title = title or "Useless Hub"
    self.ConfigFolder = configFolder or "uselesshub_configs"
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    self.Closed = false
    self.Flags = {}
    self.FlagElements = {}
    
    -- Main ScreenGui
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = self.Title .. "_Gui",
        Parent = Utility.GetCoreGui(),
        ResetOnSpawn = false
    })
    
    -- Main Frame
    self.MainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 580, 0, 380),
        Position = UDim2.new(0.5, -290, 0.5, -190),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        BorderSizePixel = 0
    }, {
        Utility.Create("UICorner", { CornerRadius = Theme.CornerRadius }),
        Utility.Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })


    -- Header
    self.Header = Utility.Create("Frame", {
        Name = "Header",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ZIndex = 2
    }, {
        Utility.Create("UICorner", {
            TopLeftRadius = Theme.CornerRadius,
            TopRightRadius = Theme.CornerRadius,
            BottomLeftRadius = UDim.new(0, 0),
            BottomRightRadius = UDim.new(0, 0)
        }),
        
        -- Header title
        Utility.Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -100, 1, 0),
            Position = UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = self.Title,
            TextColor3 = Theme.TextPrimary,
            TextSize = 16,
            Font = Theme.FontSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        }),
        
        -- Window actions container
        Utility.Create("Frame", {
            Name = "Actions",
            Size = UDim2.new(0, 80, 1, 0),
            Position = UDim2.new(1, -80, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 2
        }),

        -- Bottom border divider line
        Utility.Create("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0,
            ZIndex = 3
        })
    })
    
    -- Close and Minimize Buttons
    local actionsContainer = self.Header:FindFirstChild("Actions")
    
    self.MinimizeButton = Utility.Create("TextButton", {
        Name = "Minimize",
        Parent = actionsContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 5, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "-",
        TextColor3 = Theme.TextSecondary,
        TextSize = 20,
        Font = Theme.FontMedium,
        ZIndex = 3
    })
    
    self.CloseButton = Utility.Create("TextButton", {
        Name = "Close",
        Parent = actionsContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 40, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "\195\151",
        TextColor3 = Theme.TextSecondary,
        TextSize = 24,
        Font = Theme.FontMedium,
        ZIndex = 3
    })
    
    -- Sidebar (Left)
    self.Sidebar = Utility.Create("Frame", {
        Name = "Sidebar",
        Parent = self.MainFrame,
        Size = UDim2.new(0, 150, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    }, {
        -- Rounded corners for Sidebar (Bottom-Left rounded, others square)
        Utility.Create("UICorner", {
            BottomLeftRadius = Theme.CornerRadius,
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomRightRadius = UDim.new(0, 0)
        }),

        -- Right border line
        Utility.Create("Frame", {
            Name = "Border",
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0
        }),
        -- Tab button container
        Utility.Create("ScrollingFrame", {
            Name = "TabContainer",
            Size = UDim2.new(1, -5, 1, -10),
            Position = UDim2.new(0, 0, 0, 5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Border,
            ScrollingDirection = Enum.ScrollingDirection.Y
        }, {
            Utility.Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
        })
    })
    
    -- Content Pages Container (Right)
    self.ContentContainer = Utility.Create("Frame", {
        Name = "ContentContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -150, 1, -45),
        Position = UDim2.new(0, 150, 0, 45),
        BackgroundTransparency = 1
    })
    
    -- Make window draggable via Header
    Utility.MakeDraggable(self.MainFrame, self.Header)
    
    -- Button Connections
    self.MinimizeButton.MouseEnter:Connect(function()
        Utility.Tween(self.MinimizeButton, { TextColor3 = Theme.Accent }, 0.15)
    end)
    self.MinimizeButton.MouseLeave:Connect(function()
        Utility.Tween(self.MinimizeButton, { TextColor3 = Theme.TextSecondary }, 0.15)
    end)
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.CloseButton.MouseEnter:Connect(function()
        Utility.Tween(self.CloseButton, { TextColor3 = Theme.Failure }, 0.15)
    end)
    self.CloseButton.MouseLeave:Connect(function()
        Utility.Tween(self.CloseButton, { TextColor3 = Theme.TextSecondary }, 0.15)
    end)
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Auto-adjust CanvasSize of Sidebar TabContainer
    local tabContainer = self.Sidebar:FindFirstChild("TabContainer")
    local uiListLayout = tabContainer:FindFirstChildOfClass("UIListLayout")
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Bind key to toggle UI visibility (default RightShift)
    self.ToggleKey = Enum.KeyCode.RightShift
    self.InputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.ToggleKey then
            self:ToggleVisibility()
        end
    end)

    return self
end

function Window:ToggleMinimize()
    if self.Closed then return end
    
    self.Minimized = not self.Minimized
    
    local targetHeight = self.Minimized and 45 or 380
    
    -- If minimizing, hide the body components immediately/smoothly
    if self.Minimized then
        self.Sidebar.Visible = false
        self.ContentContainer.Visible = false
    end
    
    local tween = Utility.Tween(self.MainFrame, { Size = UDim2.new(0, 580, 0, targetHeight) }, Theme.TweenSpeed, Theme.TweenEasing, Theme.TweenDirection)
    
    if not self.Minimized then
        tween.Completed:Connect(function()
            if not self.Minimized then
                self.Sidebar.Visible = true
                self.ContentContainer.Visible = true
            end
        end)
    end
end

function Window:ToggleVisibility()
    if self.Closed then return end
    self.MainFrame.Visible = not self.MainFrame.Visible
end

function Window:Close()
    if self.Closed then return end
    self.Closed = true
    
    if self.InputConnection then
        self.InputConnection:Disconnect()
    end
    
    -- Play closing scale and fade tween
    local currentPos = self.MainFrame.Position
    Utility.Tween(self.MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = currentPos + UDim2.new(0, 290, 0, 190)
    }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    task.wait(0.2)
    self.ScreenGui:Destroy()
end

function Window:AddTab(name)
    local Tab = require("components/Tab")
    local newTab = Tab.new(name, self)
    
    table.insert(self.Tabs, newTab)
    
    -- If this is the first tab, select it
    if #self.Tabs == 1 then
        self:SelectTab(name)
    end
    
    return newTab
end

function Window:SelectTab(name)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == name then
            self.CurrentTab = tab
            tab:Show()
        else
            tab:Hide()
        end
    end
end

-- Configuration System Methods
function Window:SaveConfig(name)
    return Utility.WriteConfig(self.ConfigFolder, name, self.Flags)
end

function Window:LoadConfig(name)
    local data = Utility.ReadConfig(self.ConfigFolder, name)
    if data then
        for flag, val in pairs(data) do
            if self.FlagElements[flag] then
                pcall(function()
                    self.FlagElements[flag]:Set(val)
                end)
            else
                self.Flags[flag] = val
            end
        end
        return true
    end
    return false
end

function Window:GetConfigs()
    return Utility.ListConfigs(self.ConfigFolder)
end

function Window:AddConfigTab()
    local configTab = self:AddTab("Settings")
    configTab:AddSection("Config Management")
    
    local configName = "default"
    
    local configInput = configTab:AddTextBox("Config Name", "default", {
        default = "default"
    }, function(val)
        configName = val
    end)
    
    local configDropdown
    local configList = {}
    
    local function refreshConfigs()
        configList = self:GetConfigs()
        if configDropdown then
            configDropdown:Refresh(configList, false)
        end
    end
    
    configDropdown = configTab:AddDropdown("Saved Configs", {
        list = configList,
        default = ""
    }, function(selected)
        if selected and selected ~= "" then
            configName = selected
            configInput:Set(selected)
        end
    end)
    
    configTab:AddButton("Save Config", function()
        if configName == "" then return end
        self:SaveConfig(configName)
        refreshConfigs()
    end)
    
    configTab:AddButton("Load Config", function()
        if configName == "" then return end
        self:LoadConfig(configName)
    end)
    
    configTab:AddButton("Refresh Config List", function()
        refreshConfigs()
    end)
    
    -- Load initial files list
    refreshConfigs()
    
    return configTab
end

return Window
end

-- MODULE: init (ENTRY POINT)
modules["init"] = function()local Theme = require("theme")
local Window = require("components/Window")

local Library = {}

-- Create a new library window instance
function Library:CreateWindow(title, configFolder)
    return Window.new(title, configFolder)
end

-- Save flag states to configuration file
function Library:SaveConfig(window, name)
    if not window then return false end
    return window:SaveConfig(name)
end

-- Load flag states from configuration file
function Library:LoadConfig(window, name)
    if not window then return false end
    return window:LoadConfig(name)
end

-- List all saved configs in the folder
function Library:GetConfigs(window)
    if not window then return {} end
    return window:GetConfigs()
end

-- Allows runtime customization of the theme parameters
function Library:SetTheme(themeTable)
    if type(themeTable) ~= "table" then return end
    
    for key, val in pairs(themeTable) do
        if Theme[key] ~= nil then
            Theme[key] = val
        end
    end
end

return Library
end

return require("init")
