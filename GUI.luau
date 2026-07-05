--[=[
	Roblox UI Library Bundle
	Generated at: 2026-07-05 23:03:10
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
    FontRegular = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    FontMedium = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    FontSemibold = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
end)

local Theme = {
    
    -- Core colors (Deep Charcoal / Royal Purple Dark theme)
    Background = Color3.fromRGB(18, 18, 22),        -- Deep Charcoal Black
    Sidebar = Color3.fromRGB(13, 13, 16),          -- Sleek darker sidebar
    Header = Color3.fromRGB(24, 24, 28),           -- Elevated Header Panel
    Card = Color3.fromRGB(28, 28, 34),             -- Slate Card Surface
    CardHover = Color3.fromRGB(36, 36, 44),        -- Card Surface Hover
    
    -- Accent colors (Emerald Green & Teal gradient)
    Accent = Color3.fromRGB(16, 185, 129),         -- Emerald Green (Vibrant Accent)
    AccentGradientStart = Color3.fromRGB(16, 185, 129),
    AccentGradientEnd = Color3.fromRGB(52, 211, 153), -- Light Mint Green
    
    -- Borders and strokes
    Border = Color3.fromRGB(40, 40, 48),           -- Dark Gray Border
    BorderActive = Color3.fromRGB(16, 185, 129),   -- Active Green Border
    BorderMuted = Color3.fromRGB(24, 24, 28),       -- Muted Sidebar Border
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),   -- Pure White
    TextSecondary = Color3.fromRGB(161, 161, 170), -- Muted Gray (Zinc 400)
    TextMuted = Color3.fromRGB(113, 113, 122),     -- Dark Gray (Zinc 500)
    
    -- Status colors
    Success = Color3.fromRGB(16, 185, 129),        -- Emerald Green
    Failure = Color3.fromRGB(239, 68, 68),         -- Crimson Red
    
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

local spr = require("packages/spr")

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

-- Smooth Tween Helper (powered by spr spring physics, critically damped for smooth, non-springy motion)
function Utility.Tween(instance, properties, duration, style, direction)
    -- Critically damped (1.0 damping ratio) ensures smooth deceleration with zero bounce or spring overshoot
    spr.target(instance, 1.0, 5.0, properties)
    
    local completedBindable = Instance.new("BindableEvent")
    spr.completed(instance, function()
        completedBindable:Fire()
    end)
    
    return {
        Completed = completedBindable.Event,
        Cancel = function()
            spr.stop(instance)
        end
    }
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
            
            -- Adjust delta if a UIScale exists in the frame
            local scale = 1
            local uiScale = frame:FindFirstChildOfClass("UIScale")
            if uiScale then
                scale = uiScale.Scale
            end
            
            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + (delta.X / scale),
                startPosition.Y.Scale,
                startPosition.Y.Offset + (delta.Y / scale)
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

-- Add a tactile ripple circle effect on click/press
function Utility.AddClickEffect(button)
    button.ClipsDescendants = true
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- Get accumulated UIScale factor
            local scale = 1
            local curr = button
            while curr do
                local uiScale = curr:FindFirstChildOfClass("UIScale")
                if uiScale then
                    scale = scale * uiScale.Scale
                end
                curr = curr.Parent
            end
            
            -- Calculate click relative position
            local localX = (input.Position.X - button.AbsolutePosition.X) / scale
            local localY = (input.Position.Y - button.AbsolutePosition.Y) / scale
            
            -- Create ripple circle
            local ripple = Instance.new("Frame")
            ripple.Name = "Ripple"
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Position = UDim2.new(0, localX, 0, localY)
            ripple.Size = UDim2.new(0, 2, 0, 2)
            ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ripple.BackgroundTransparency = 0.92 -- Highly transparent/subtle
            ripple.BorderSizePixel = 0
            ripple.ZIndex = 10
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0) -- Pure circle
            corner.Parent = ripple
            
            ripple.Parent = button
            
            -- Target size (1.5x the largest size of the button to cover fully)
            local diameter = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
            
            -- Tween expand and fade (using TweenService directly with 0.7s duration to be slower and highly visible)
            local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(ripple, tweenInfo, {
                Size = UDim2.new(0, diameter, 0, diameter),
                BackgroundTransparency = 1
            })
            tween:Play()
            
            task.delay(0.7, function()
                ripple:Destroy()
            end)
        end
    end)
end

return Utility
end

-- MODULE: components/Button
modules["components/Button"] = function()local Theme = require("theme")
local Utility = require("utility")
local Lucide = require("packages/lucide-roblox")

local Button = {}
Button.__index = Button

function Button.new(text, parent, callback, icon)
    local self = setmetatable({}, Button)
    
    self.Text = text or "Button"
    self.Callback = callback or function() end
    
    local hasIcon = false
    local iconAsset
    if icon and icon ~= "" then
        pcall(function()
            iconAsset = Lucide.GetAsset(icon, 48)
            if iconAsset then
                hasIcon = true
            end
        end)
    end
    
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
        })
    })
    
    if hasIcon then
        Utility.Create("Frame", {
            Name = "Content",
            Parent = self.Frame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        }, {
            Utility.Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            }),
            Utility.Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Image = iconAsset.Url,
                ImageRectSize = iconAsset.ImageRectSize,
                ImageRectOffset = iconAsset.ImageRectOffset,
                ImageColor3 = Theme.TextPrimary,
                LayoutOrder = 1
            }),
            Utility.Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text = self.Text,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                Font = Theme.FontMedium,
                LayoutOrder = 2
            })
        })
    else
        Utility.Create("TextLabel", {
            Name = "Label",
            Parent = self.Frame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = self.Text,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        })
    end
    
    local stroke = self.Frame:FindFirstChildOfClass("UIStroke")
    
    -- Interaction animations
    self.Frame.MouseEnter:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
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
    
    Utility.AddClickEffect(self.Frame)
    
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
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.HeaderFrame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    Utility.AddClickEffect(self.PreviewBtn)
    
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
local Lucide = require("packages/lucide-roblox")

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
    
    local chevron = Lucide.GetAsset("chevron-down", 48)
    
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
            -- Arrow Indicator (Lucide Chevron)
            Utility.Create("ImageLabel", {
                Name = "Arrow",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -25, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = chevron.Url,
                ImageRectSize = chevron.ImageRectSize,
                ImageRectOffset = chevron.ImageRectOffset,
                ImageColor3 = Theme.TextSecondary,
                ZIndex = 2
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
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Trigger.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Click toggle
    self.Trigger.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    Utility.AddClickEffect(self.Frame)
    
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
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Binding Trigger Click
    self.BindButton.MouseButton1Click:Connect(function()
        self:StartBinding()
    end)
    
    Utility.AddClickEffect(self.BindButton)
    
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
        -- Section Text (No accent bar, aligned to margin)
        Utility.Create("TextLabel", {
            Name = "TextLabel",
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
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
local TweenService = game:GetService("TweenService")

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
            Size = UDim2.new(0.4, -15, 0, 25),
            Position = UDim2.new(0.6, 0, 0, 4),
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
                    Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) })
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
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
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
            TweenService:Create(self.Knob, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7) }):Play()
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
            TweenService:Create(self.Knob, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6) }):Play()
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
    
    if self.Dragging then
        self.Fill.Size = UDim2.new(percentage, 0, 1, 0)
    else
        TweenService:Create(self.Fill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(percentage, 0, 1, 0) }):Play()
    end
    
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
local Lucide = require("packages/lucide-roblox")

local Tab = {}
Tab.__index = Tab

function Tab.new(name, window, icon)
    local self = setmetatable({}, Tab)
    
    self.Name = name
    self.Window = window
    self.Active = false
    
    -- 1. Tab Button in Sidebar
    local tabContainer = window.Sidebar:FindFirstChild("TabContainer")
    
    local hasIcon = false
    local iconAsset
    if icon and icon ~= "" then
        pcall(function()
            iconAsset = Lucide.GetAsset(icon, 48)
            if iconAsset then
                hasIcon = true
            end
        end)
    end
    
    self.Button = Utility.Create("TextButton", {
        Name = "Tab_" .. name,
        Parent = tabContainer,
        Size = UDim2.new(0.9, 0, 0, 36),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.Card,
        Text = "",
        AutoButtonColor = false
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        
        -- Text Label
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = hasIcon and UDim2.new(1, -48, 1, 0) or UDim2.new(1, -20, 1, 0),
            Position = hasIcon and UDim2.new(0, 38, 0, 0) or UDim2.new(0, 15, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 14,
            Font = Theme.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    
    if hasIcon then
        self.Icon = Utility.Create("ImageLabel", {
            Name = "Icon",
            Parent = self.Button,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 14, 0.5, -8),
            BackgroundTransparency = 1,
            Image = iconAsset.Url,
            ImageRectSize = iconAsset.ImageRectSize,
            ImageRectOffset = iconAsset.ImageRectOffset,
            ImageColor3 = Theme.TextSecondary,
            ZIndex = 2
        })
    end
    
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
            if self.Icon then
                Utility.Tween(self.Icon, { ImageColor3 = Theme.TextPrimary }, 0.15)
            end
            Utility.Tween(self.Button, { BackgroundTransparency = 0.85 }, 0.15)
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Active then
            Utility.Tween(self.Button:FindFirstChild("Label"), { TextColor3 = Theme.TextSecondary }, 0.15)
            if self.Icon then
                Utility.Tween(self.Icon, { ImageColor3 = Theme.TextSecondary }, 0.15)
            end
            Utility.Tween(self.Button, { BackgroundTransparency = 1 }, 0.15)
        end
    end)
    
    self.Button.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self.Name)
    end)
    
    Utility.AddClickEffect(self.Button)
    
    return self
end

function Tab:Show()
    self.Active = true
    self.Page.Visible = true
    
    local label = self.Button:FindFirstChild("Label")
    
    Utility.Tween(self.Button, { BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Card }, 0.15)
    Utility.Tween(label, { TextColor3 = Theme.TextPrimary }, 0.15)
    if self.Icon then
        Utility.Tween(self.Icon, { ImageColor3 = Theme.TextPrimary }, 0.15)
    end
end

function Tab:Hide()
    self.Active = false
    self.Page.Visible = false
    
    local label = self.Button:FindFirstChild("Label")
    
    Utility.Tween(self.Button, { BackgroundTransparency = 1 }, 0.15)
    Utility.Tween(label, { TextColor3 = Theme.TextSecondary }, 0.15)
    if self.Icon then
        Utility.Tween(self.Icon, { ImageColor3 = Theme.TextSecondary }, 0.15)
    end
end

-- Component wrappers
function Tab:AddButton(text, callback, icon)
    local Button = require("components/Button")
    return Button.new(text, self.Page, callback, icon)
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
    end)
    
    self.Input.FocusLost:Connect(function(enterPressed)
        Utility.Tween(self.InputStroke, { Color = Theme.Border }, 0.15)
        self:Set(self.Input.Text)
    end)
    
    -- Main frame hover effects
    self.Frame.MouseEnter:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
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
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    -- Click toggle
    self.Frame.MouseButton1Click:Connect(function()
        self:Set(not self.Value)
    end)
    
    Utility.AddClickEffect(self.Frame)
    
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
local Lucide = require("packages/lucide-roblox")
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
    
    -- Responsive Container Frame
    self.Container = Utility.Create("Frame", {
        Name = "Container",
        Parent = self.ScreenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })
    
    -- Main Frame
    self.MainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        Parent = self.Container,
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

    -- Responsive UIScale Setup for Mobile / PC
    local uiScale = Utility.Create("UIScale", {
        Name = "UIScale",
        Parent = self.Container,
        Scale = 1
    })
    
    -- Appear Scale UIScale for Launch/Toggle Animations
    local appearScale = Utility.Create("UIScale", {
        Name = "AppearScale",
        Parent = self.MainFrame,
        Scale = 0.85
    })

    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewportSize = camera.ViewportSize
        local width = viewportSize.X
        local height = viewportSize.Y
        
        local scale = 1
        -- Only scale down on smaller mobile/tablet viewports (PC is kept at 1)
        if width < 1000 or height < 600 then
            local scaleX = width / 1000
            local scaleY = height / 600
            scale = math.min(scaleX, scaleY)
            -- Clamp scale so it doesn't get ridiculously small (min 0.65)
            scale = math.clamp(scale, 0.65, 1)
        end
        uiScale.Scale = scale
    end

    updateScale()
    self.ViewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)



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
    
    local minusAsset = Lucide.GetAsset("minus", 48)
    local xAsset = Lucide.GetAsset("x", 48)
    
    self.MinimizeButton = Utility.Create("TextButton", {
        Name = "Minimize",
        Parent = actionsContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 5, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3
    }, {
        Utility.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            BackgroundTransparency = 1,
            Image = minusAsset.Url,
            ImageRectSize = minusAsset.ImageRectSize,
            ImageRectOffset = minusAsset.ImageRectOffset,
            ImageColor3 = Theme.TextSecondary,
            ZIndex = 4
        })
    })
    
    self.CloseButton = Utility.Create("TextButton", {
        Name = "Close",
        Parent = actionsContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 40, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3
    }, {
        Utility.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.5, -8, 0.5, -8),
            BackgroundTransparency = 1,
            Image = xAsset.Url,
            ImageRectSize = xAsset.ImageRectSize,
            ImageRectOffset = xAsset.ImageRectOffset,
            ImageColor3 = Theme.TextSecondary,
            ZIndex = 4
        })
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
        -- Tab button container (aligned with page header content)
        Utility.Create("ScrollingFrame", {
            Name = "TabContainer",
            Size = UDim2.new(1, -5, 1, -15),
            Position = UDim2.new(0, 0, 0, 10),
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
        local icon = self.MinimizeButton:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, { ImageColor3 = Theme.Accent }, 0.15)
        end
    end)
    self.MinimizeButton.MouseLeave:Connect(function()
        local icon = self.MinimizeButton:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, { ImageColor3 = Theme.TextSecondary }, 0.15)
        end
    end)
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.CloseButton.MouseEnter:Connect(function()
        local icon = self.CloseButton:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, { ImageColor3 = Theme.Failure }, 0.15)
        end
    end)
    self.CloseButton.MouseLeave:Connect(function()
        local icon = self.CloseButton:FindFirstChild("Icon")
        if icon then
            Utility.Tween(icon, { ImageColor3 = Theme.TextSecondary }, 0.15)
        end
    end)
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    Utility.AddClickEffect(self.MinimizeButton)
    Utility.AddClickEffect(self.CloseButton)
    
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
    
    -- Animate Launch (Appear Scale)
    task.spawn(function()
        task.wait(0.02)
        Utility.Tween(appearScale, { Scale = 1.0 })
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
    
    local appearScale = self.MainFrame:FindFirstChild("AppearScale")
    if not appearScale then
        self.MainFrame.Visible = not self.MainFrame.Visible
        return
    end
    
    if self.MainFrame.Visible then
        local tween = Utility.Tween(appearScale, { Scale = 0.85 })
        self.ToggleConnection = tween.Completed:Connect(function()
            self.MainFrame.Visible = false
            if self.ToggleConnection then
                self.ToggleConnection:Disconnect()
                self.ToggleConnection = nil
            end
        end)
    else
        if self.ToggleConnection then
            self.ToggleConnection:Disconnect()
            self.ToggleConnection = nil
        end
        appearScale.Scale = 0.85
        self.MainFrame.Visible = true
        Utility.Tween(appearScale, { Scale = 1.0 })
    end
end

function Window:Close()
    if self.Closed then return end
    self.Closed = true
    
    if self.InputConnection then
        self.InputConnection:Disconnect()
    end
    if self.ViewportConnection then
        self.ViewportConnection:Disconnect()
    end
    
    local appearScale = self.MainFrame:FindFirstChild("AppearScale")
    if appearScale then
        local tween = Utility.Tween(appearScale, { Scale = 0.85 })
        tween.Completed:Wait()
    else
        task.wait(0.15)
    end
    
    self.ScreenGui:Destroy()
end

function Window:AddTab(name, icon)
    local Tab = require("components/Tab")
    local newTab = Tab.new(name, self, icon)
    
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

-- MODULE: packages/lucide-roblox
modules["packages/lucide-roblox"] = function()--!nolint
--!nocheck
--!optimize 2
--!native

--[[
    lucide-roblox - Library to Use the Lucide Icon Set (https://lucide.dev) in Roblox
    MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>

    Package Version: 0.1.3
    Lucide Version: 0.363.0
]]

local a local b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u={function()local b,c,d=a(1)local e return(function(...)export type
Asset={IconName:string,Id:number,Url:string,ImageRectSize:Vector2,ImageRectOffset:Vector2}local f,g,h=d(c.Icons),d(c.
VersionInfo),typeof or type local function i(j:string,k:{any},l:{[number]:{string}})for m,n in l do local o,p,q=n[1],n[2
],k[m]local r=h(q)if r~=p then error(j..': Argument '..m..' ('..o..'): expected type `'..p..'`, got `'..r..'`',3)end end
end local function j(k:string):string return string.match(string.lower(k),'^%s*(.*)%s*$')::string end local function k(l
:Instance,m:{[string]:any}):Instance if m then for n,o in m do if n~='Parent'then l[n]=o end end if m.Parent then l.
Parent=m.Parent end end return l end local l={PackageVersion=g.PackageVersion,LucideVersion=g.LucideVersion}do local m:{
string},n,o={},next(f)o=o or{}for p in o do table.insert(m,p)end table.sort(m)table.freeze(m)l.IconNames=m end function
l.GetAsset(m:string,n:number?):Asset local o=if n==nil then 256 else n i('Lucide.GetAsset',{m,o},{[1]={'iconName',
'string'},[2]={'iconSize','number'}})local p=j(m)if o<0 then o=-o end local q=if o<=48 then'48px'else'256px'local r=f[q]
if not r then error[[Lucide.GetAsset: Internal error: Failed to find icon index for specified size]]end local s=r[p]if
not s then error('Lucide.GetAsset: Failed to find icon by the name of "'..p..'" (@'..q..'), perhaps a spelling mistake?'
,2)end local t,u,v=s[1],s[2],s[3]if type(t)~='number'or type(u)~='table'or type(v)~='table'then error
[[Lucide.GetAsset: Internal error: Invalid auto-generated asset entry]]end local w,x,y='rbxassetid://'..t,Vector2 .new(u
[1],u[2]),Vector2 .new(v[1],v[2])local z:Asset={IconName=p,Id=t,Url=w,ImageRectSize=x,ImageRectOffset=y}return z end
function l.GetAllAssets(m:number?):{Asset}local n=if m==nil then 256 else m i('Lucide.GetAllAssets',{n},{[1]={
'inputSize','number'}})local o={}for p,q in l.IconNames do local r=l.GetAsset(q,n)if r then table.insert(o,r)end end
return o end function l.ImageLabel(m:string,n:number?,o:{[string]:any}?):ImageLabel local p,q=if n==nil then 256 else n,
if o==nil then{}else o i('Lucide.ImageLabel',{m,n,o},{[1]={'iconName','string'},[2]={'imageSize','number'},[3]={
'propertyOverrides','table'}})local r=l.GetAsset(m,p)local s=k(Instance.new'ImageLabel',{Name=r.IconName,Size=UDim2 .
fromOffset(p,p),BackgroundColor3=Color3 .new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Image=r.Url,ImageRectSize
=r.ImageRectSize,ImageRectOffset=r.ImageRectOffset,ImageColor3=Color3 .new(1,1,1),ScaleType=Enum.ScaleType.Fit})k(s,q)
return s end table.freeze(l)return l end)()end,function()local b,c,d=a(2)local e return(function(...)return{['48px']={
rewind={16898613699,{48,48},{563,967}},fuel={16898613353,{48,48},{196,967}},['square-arrow-out-up-right']={16898613777,{
48,48},{967,514}},['table-cells-split']={16898613777,{48,48},{771,955}},gavel={16898613353,{48,48},{967,808}},['dna-off'
]={16898613044,{48,48},{453,967}},['refresh-ccw-dot']={16898613699,{48,48},{869,404}},bean={16898612629,{48,48},{967,906
}},['arrow-up-right-from-circle']={16898612629,{48,48},{563,967}},['table-columns-split']={16898613777,{48,48},{967,808}
},bolt={16898612819,{48,48},{306,820}},['square-asterisk']={16898613777,{48,48},{710,771}},feather={16898613353,{48,48},
{771,98}},['align-horizontal-distribute-center']={16898612629,{48,48},{771,355}},['align-center']={16898612629,{48,48},{
0,869}},['grip-vertical']={16898613509,{48,48},{0,869}},['person-standing']={16898613699,{48,48},{563,771}},[
'badge-swiss-franc']={16898612629,{48,48},{771,857}},['between-horizontal-end']={16898612819,{48,48},{771,306}},[
'rotate-cw']={16898613699,{48,48},{869,453}},framer={16898613353,{48,48},{661,967}},['bus-front']={16898612819,{48,48},{
869,612}},['shield-ellipsis']={16898613777,{48,48},{771,306}},['file-lock-2']={16898613353,{48,48},{257,918}},[
'between-vertical-end']={16898612819,{48,48},{257,820}},['globe-lock']={16898613509,{48,48},{820,514}},['toggle-left']={
16898613869,{48,48},{869,49}},['concierge-bell']={16898613044,{48,48},{869,147}},video={16898613869,{48,48},{355,967}},[
'arrow-left-square']={16898612629,{48,48},{196,820}},['file-down']={16898613353,{48,48},{98,820}},['picture-in-picture']
={16898613699,{48,48},{257,869}},['messages-square']={16898613613,{48,48},{306,869}},grab={16898613509,{48,48},{514,820}
},['phone-call']={16898613699,{48,48},{514,820}},['chevron-up-circle']={16898612819,{48,48},{820,808}},['server-crash']=
{16898613699,{48,48},{918,955}},['heading-3']={16898613509,{48,48},{869,306}},squircle={16898613777,{48,48},{820,759}},[
'wifi-off']={16898613869,{48,48},{918,759}},['sun-medium']={16898613777,{48,48},{661,967}},ungroup={16898613869,{48,48},
{257,967}},['cloud-download']={16898613044,{48,48},{612,820}},['sigma-square']={16898613777,{48,48},{869,514}},[
'folder-plus']={16898613353,{48,48},{661,918}},['hard-drive-download']={16898613509,{48,48},{918,0}},['scatter-chart']={
16898613699,{48,48},{196,967}},pointer={16898613699,{48,48},{661,771}},ligature={16898613509,{48,48},{612,967}},[
'chevrons-up-down']={16898612819,{48,48},{918,759}},['iteration-cw']={16898613509,{48,48},{869,147}},['rail-symbol']={
16898613699,{48,48},{967,514}},['square-stack']={16898613777,{48,48},{453,869}},parentheses={16898613613,{48,48},{869,
906}},['book-up-2']={16898612819,{48,48},{306,869}},flame={16898613353,{48,48},{967,306}},['chevrons-up']={16898612819,{
48,48},{869,808}},['chevron-right-square']={16898612819,{48,48},{918,710}},['square-mouse-pointer']={16898613777,{48,48}
,{869,661}},superscript={16898613777,{48,48},{918,759}},signal={16898613777,{48,48},{918,0}},['file-warning']={
16898613353,{48,48},{967,514}},hexagon={16898613509,{48,48},{967,0}},['navigation-2-off']={16898613613,{48,48},{918,612}
},unlock={16898613869,{48,48},{771,710}},['arrows-up-from-line']={16898612629,{48,48},{918,404}},['square-gantt-chart']=
{16898613777,{48,48},{453,820}},['square-chevron-left']={16898613777,{48,48},{967,49}},scaling={16898613699,{48,48},{967
,661}},['inspection-panel']={16898613509,{48,48},{563,918}},['arrow-left-from-line']={16898612629,{48,48},{869,147}},
ship={16898613777,{48,48},{771,98}},['ticket-percent']={16898613869,{48,48},{257,869}},['arrow-right-square']={
16898612629,{48,48},{869,404}},['calendar-clock']={16898612819,{48,48},{918,98}},x={16898613869,{48,48},{869,906}},
voicemail={16898613869,{48,48},{869,710}},presentation={16898613699,{48,48},{771,196}},['tree-palm']={16898613869,{48,48
},{820,612}},popsicle={16898613699,{48,48},{563,869}},['captions-off']={16898612819,{48,48},{661,869}},[
'align-vertical-justify-center']={16898612629,{48,48},{49,869}},theater={16898613869,{48,48},{98,771}},tent={16898613869
,{48,48},{49,771}},['repeat-1']={16898613699,{48,48},{918,612}},stethoscope={16898613777,{48,48},{147,967}},[
'screen-share-off']={16898613699,{48,48},{771,906}},['arrow-big-up']={16898612629,{48,48},{918,306}},['volume-x']={
16898613869,{48,48},{710,869}},['mouse-pointer-click']={16898613613,{48,48},{771,710}},['square-m']={16898613777,{48,48}
,{306,967}},['hard-drive']={16898613509,{48,48},{820,98}},['package-minus']={16898613613,{48,48},{771,808}},cloud={
16898613044,{48,48},{918,306}},['mouse-pointer-square-dashed']={16898613613,{48,48},{710,771}},['flip-horizontal']={
16898613353,{48,48},{306,967}},['alert-circle']={16898612629,{48,48},{869,0}},unplug={16898613869,{48,48},{710,771}},[
'badge-cent']={16898612629,{48,48},{612,967}},['check-square-2']={16898612819,{48,48},{820,759}},['monitor-check']={
16898613613,{48,48},{196,771}},trello={16898613869,{48,48},{612,820}},['paintbrush-2']={16898613613,{48,48},{967,404}},[
'bar-chart-horizontal']={16898612629,{48,48},{710,967}},['book-plus']={16898612819,{48,48},{771,404}},torus={16898613869
,{48,48},{147,771}},['panel-right-close']={16898613613,{48,48},{453,967}},['heart-handshake']={16898613509,{48,48},{869,
563}},trees={16898613869,{48,48},{661,771}},ham={16898613509,{48,48},{355,771}},text={16898613869,{48,48},{771,98}},[
'nut-off']={16898613613,{48,48},{98,967}},['bean-off']={16898612629,{48,48},{869,955}},rat={16898613699,{48,48},{869,612
}},['separator-horizontal']={16898613699,{48,48},{918,906}},['square-arrow-up-right']={16898613777,{48,48},{820,661}},[
'signal-zero']={16898613777,{48,48},{514,869}},citrus={16898613044,{48,48},{306,820}},['phone-missed']={16898613699,{48,
48},{771,98}},['user-round-check']={16898613869,{48,48},{869,404}},['battery-medium']={16898612629,{48,48},{869,906}},[
'square-minus']={16898613777,{48,48},{918,612}},hotel={16898613509,{48,48},{98,869}},['folder-output']={16898613353,{48,
48},{771,808}},['ice-cream']={16898613509,{48,48},{869,355}},menu={16898613613,{48,48},{49,820}},['arrow-up-left-square'
]={16898612629,{48,48},{710,820}},lightbulb={16898613509,{48,48},{918,196}},['badge-help']={16898612629,{48,48},{147,967
}},angry={16898612629,{48,48},{257,918}},outdent={16898613613,{48,48},{918,661}},['circle-dot-dashed']={16898613044,{48,
48},{771,514}},speech={16898613777,{48,48},{820,147}},['cake-slice']={16898612819,{48,48},{661,820}},['git-graph']={
16898613509,{48,48},{0,771}},armchair={16898612629,{48,48},{820,147}},['qr-code']={16898613699,{48,48},{967,257}},copy={
16898613044,{48,48},{918,612}},goal={16898613509,{48,48},{563,771}},['trending-down']={16898613869,{48,48},{563,869}},
haze={16898613509,{48,48},{98,820}},nfc={16898613613,{48,48},{612,918}},['receipt-russian-ruble']={16898613699,{48,48},{
514,967}},disc={16898613044,{48,48},{661,967}},['notebook-tabs']={16898613613,{48,48},{967,98}},['panels-left-bottom']={
16898613613,{48,48},{820,906}},videotape={16898613869,{48,48},{967,612}},['sun-moon']={16898613777,{48,48},{967,196}},
calendar={16898612819,{48,48},{355,918}},['minus-circle']={16898613613,{48,48},{869,98}},sunset={16898613777,{48,48},{
967,710}},['navigation-2']={16898613613,{48,48},{869,661}},['message-square-heart']={16898613613,{48,48},{771,147}},[
'rectangle-ellipsis']={16898613699,{48,48},{820,196}},['badge-plus']={16898612629,{48,48},{918,710}},['indian-rupee']={
16898613509,{48,48},{710,771}},['monitor-dot']={16898613613,{48,48},{147,820}},delete={16898613044,{48,48},{661,918}},[
'clipboard-pen-line']={16898613044,{48,48},{918,0}},['folder-search']={16898613353,{48,48},{918,196}},[
'utensils-crossed']={16898613869,{48,48},{918,147}},dices={16898613044,{48,48},{918,710}},reply={16898613699,{48,48},{
612,918}},['flask-round']={16898613353,{48,48},{404,869}},pause={16898613699,{48,48},{0,771}},shrub={16898613777,{48,48}
,{306,820}},flag={16898613353,{48,48},{98,918}},underline={16898613869,{48,48},{820,404}},[
'align-horizontal-distribute-end']={16898612629,{48,48},{355,771}},newspaper={16898613613,{48,48},{661,869}},table={
16898613777,{48,48},{820,955}},['move-vertical']={16898613613,{48,48},{820,453}},['file-pen-line']={16898613353,{48,48},
{612,820}},['badge-russian-ruble']={16898612629,{48,48},{820,808}},radius={16898613699,{48,48},{257,967}},['loader-2']={
16898613509,{48,48},{820,857}},pilcrow={16898613699,{48,48},{612,771}},['scan-face']={16898613699,{48,48},{820,808}},
spade={16898613777,{48,48},{514,918}},['book-user']={16898612819,{48,48},{918,514}},['flip-vertical']={16898613353,{48,
48},{918,612}},['square-arrow-down']={16898613777,{48,48},{453,771}},['circle-plus']={16898613044,{48,48},{869,0}},view=
{16898613869,{48,48},{918,661}},cctv={16898612819,{48,48},{355,967}},['more-horizontal']={16898613613,{48,48},{257,967}}
,['file-key-2']={16898613353,{48,48},{404,771}},['pause-octagon']={16898613699,{48,48},{771,0}},[
'circle-arrow-out-down-left']={16898612819,{48,48},{771,955}},volume={16898613869,{48,48},{661,918}},facebook={
16898613353,{48,48},{563,771}},['octagon-alert']={16898613613,{48,48},{918,404}},['panel-bottom-dashed']={16898613613,{
48,48},{918,710}},['book-a']={16898612819,{48,48},{820,563}},['align-end-vertical']={16898612629,{48,48},{820,306}},[
'user-x-2']={16898613869,{48,48},{771,759}},chrome={16898612819,{48,48},{820,857}},['receipt-japanese-yen']={16898613699
,{48,48},{612,869}},rabbit={16898613699,{48,48},{869,355}},['scissors-square']={16898613699,{48,48},{869,808}},[
'check-square']={16898612819,{48,48},{771,808}},['train-front-tunnel']={16898613869,{48,48},{771,404}},[
'panel-left-dashed']={16898613613,{48,48},{661,967}},fish={16898613353,{48,48},{869,147}},slack={16898613777,{48,48},{0,
918}},sliders={16898613777,{48,48},{404,771}},['message-circle-warning']={16898613613,{48,48},{771,612}},map={
16898613613,{48,48},{306,771}},route={16898613699,{48,48},{404,918}},['arrow-up-left']={16898612629,{48,48},{661,869}},
award={16898612629,{48,48},{918,661}},['message-square-plus']={16898613613,{48,48},{49,869}},['unfold-horizontal']={
16898613869,{48,48},{355,869}},['area-chart']={16898612629,{48,48},{869,98}},['music-4']={16898613613,{48,48},{306,967}}
,['shield-x']={16898613777,{48,48},{514,820}},['plane-landing']={16898613699,{48,48},{771,147}},['disc-3']={16898613044,
{48,48},{771,857}},['columns-4']={16898613044,{48,48},{710,771}},['archive-x']={16898612629,{48,48},{967,0}},[
'square-dashed-kanban']={16898613777,{48,48},{98,918}},['users-2']={16898613869,{48,48},{612,918}},['shield-off']={
16898613777,{48,48},{820,514}},compass={16898613044,{48,48},{514,967}},vegan={16898613869,{48,48},{967,355}},[
'message-circle-plus']={16898613613,{48,48},{257,869}},['stop-circle']={16898613777,{48,48},{453,918}},nut={16898613613,
{48,48},{967,355}},search={16898613699,{48,48},{918,857}},files={16898613353,{48,48},{771,710}},['send-to-back']={
16898613699,{48,48},{820,955}},['alarm-clock']={16898612629,{48,48},{257,820}},['shopping-basket']={16898613777,{48,48},
{0,869}},send={16898613699,{48,48},{967,857}},['chevron-left-square']={16898612819,{48,48},{453,918}},['terminal-square'
]={16898613869,{48,48},{0,820}},wifi={16898613869,{48,48},{869,808}},['skip-back']={16898613777,{48,48},{147,771}},[
'wrap-text']={16898613869,{48,48},{869,857}},['file-scan']={16898613353,{48,48},{820,147}},['message-square-dashed']={
16898613613,{48,48},{918,0}},trophy={16898613869,{48,48},{820,147}},umbrella={16898613869,{48,48},{869,355}},touchpad={
16898613869,{48,48},{49,869}},['clipboard-copy']={16898613044,{48,48},{820,563}},pentagon={16898613699,{48,48},{771,306}
},['arrow-up-from-line']={16898612629,{48,48},{820,710}},['circle-chevron-up']={16898613044,{48,48},{771,0}},worm={
16898613869,{48,48},{918,808}},['lamp-desk']={16898613509,{48,48},{355,918}},['circle-arrow-up']={16898612819,{48,48},{
967,857}},zap={16898613869,{48,48},{918,906}},boxes={16898612819,{48,48},{196,771}},['swiss-franc']={16898613777,{48,48}
,{820,857}},['move-left']={16898613613,{48,48},{98,918}},['chevron-up']={16898612819,{48,48},{710,918}},instagram={
16898613509,{48,48},{514,967}},['pen-tool']={16898613699,{48,48},{820,0}},['pencil-ruler']={16898613699,{48,48},{0,820}}
,['grid-2x2']={16898613509,{48,48},{771,98}},['arrow-big-down-dash']={16898612629,{48,48},{771,196}},['clipboard-edit']=
{16898613044,{48,48},{771,612}},mic={16898613613,{48,48},{820,612}},['file-minus-2']={16898613353,{48,48},{869,563}},
gitlab={16898613509,{48,48},{820,257}},['rotate-3d']={16898613699,{48,48},{147,918}},['spell-check']={16898613777,{48,48
},{196,771}},popcorn={16898613699,{48,48},{612,820}},blocks={16898612819,{48,48},{49,820}},['washing-machine']={
16898613869,{48,48},{918,710}},siren={16898613777,{48,48},{771,147}},['cloud-sun']={16898613044,{48,48},{0,967}},circle=
{16898613044,{48,48},{771,355}},['shield-alert']={16898613777,{48,48},{49,771}},rainbow={16898613699,{48,48},{918,563}},
['separator-vertical']={16898613699,{48,48},{869,955}},ampersands={16898612629,{48,48},{355,820}},['user-search']={
16898613869,{48,48},{918,612}},fence={16898613353,{48,48},{98,771}},['square-user-round']={16898613777,{48,48},{355,967}
},sunrise={16898613777,{48,48},{453,967}},strikethrough={16898613777,{48,48},{869,759}},['calendar-days']={16898612819,{
48,48},{869,147}},['dollar-sign']={16898613044,{48,48},{820,857}},['message-square-quote']={16898613613,{48,48},{0,918}}
,['list-minus']={16898613509,{48,48},{820,808}},['cloud-hail']={16898613044,{48,48},{967,0}},upload={16898613869,{48,48}
,{612,869}},['app-window-mac']={16898612629,{48,48},{661,771}},ellipsis={16898613353,{48,48},{771,49}},['copy-check']={
16898613044,{48,48},{453,820}},history={16898613509,{48,48},{869,98}},satellite={16898613699,{48,48},{147,967}},[
'bookmark-plus']={16898612819,{48,48},{612,820}},['folder-key']={16898613353,{48,48},{355,967}},['lamp-ceiling']={
16898613509,{48,48},{404,869}},['circle-power']={16898613044,{48,48},{820,49}},hourglass={16898613509,{48,48},{49,918}},
keyboard={16898613509,{48,48},{453,820}},triangle={16898613869,{48,48},{869,98}},['layers-2']={16898613509,{48,48},{196,
869}},['battery-full']={16898612629,{48,48},{967,808}},['user-minus']={16898613869,{48,48},{49,967}},['x-octagon']={
16898613869,{48,48},{967,808}},['folder-tree']={16898613353,{48,48},{967,404}},command={16898613044,{48,48},{563,918}},[
'badge-dollar-sign']={16898612629,{48,48},{918,196}},['align-start-vertical']={16898612629,{48,48},{820,98}},[
'chevrons-down']={16898612819,{48,48},{967,196}},['bluetooth-off']={16898612819,{48,48},{869,257}},cannabis={16898612819
,{48,48},{710,820}},book={16898612819,{48,48},{820,612}},hammer={16898613509,{48,48},{306,820}},['circle-minus']={
16898613044,{48,48},{771,306}},['audio-waveform']={16898612629,{48,48},{967,612}},['moon-star']={16898613613,{48,48},{
355,869}},['arrow-right']={16898612629,{48,48},{453,820}},sparkle={16898613777,{48,48},{967,0}},wand={16898613869,{48,48
},{404,967}},['calendar-minus-2']={16898612819,{48,48},{147,869}},['copy-minus']={16898613044,{48,48},{404,869}},[
'folder-input']={16898613353,{48,48},{453,869}},['book-image']={16898612819,{48,48},{771,147}},shirt={16898613777,{48,48
},{98,771}},['server-off']={16898613699,{48,48},{967,955}},['move-up']={16898613613,{48,48},{869,404}},['plug-2']={
16898613699,{48,48},{869,306}},radio={16898613699,{48,48},{306,918}},brackets={16898612819,{48,48},{98,869}},[
'calendar-heart']={16898612819,{48,48},{196,820}},['list-ordered']={16898613509,{48,48},{710,918}},['mic-off']={
16898613613,{48,48},{918,514}},['arrow-big-left']={16898612629,{48,48},{98,869}},['square-split-horizontal']={
16898613777,{48,48},{918,404}},['tree-deciduous']={16898613869,{48,48},{869,563}},['sun-snow']={16898613777,{48,48},{196
,967}},['user-2']={16898613869,{48,48},{514,967}},['help-circle']={16898613509,{48,48},{563,869}},['clock-2']={
16898613044,{48,48},{771,404}},['calendar-fold']={16898612819,{48,48},{820,196}},['fish-off']={16898613353,{48,48},{967,
49}},baby={16898612629,{48,48},{771,808}},leaf={16898613509,{48,48},{918,661}},['fold-vertical']={16898613353,{48,48},{
661,869}},hop={16898613509,{48,48},{196,771}},paperclip={16898613613,{48,48},{918,857}},cigarette={16898612819,{48,48},{
967,759}},minus={16898613613,{48,48},{771,196}},['smile-plus']={16898613777,{48,48},{918,514}},['chevron-right-circle']=
{16898612819,{48,48},{967,661}},['star-off']={16898613777,{48,48},{612,967}},['git-pull-request-closed']={16898613509,{
48,48},{771,514}},['badge-check']={16898612629,{48,48},{967,147}},['test-tube-2']={16898613869,{48,48},{771,306}},[
'kanban-square']={16898613509,{48,48},{98,918}},['plug-zap']={16898613699,{48,48},{771,404}},['heading-4']={16898613509,
{48,48},{820,355}},['git-pull-request-create']={16898613509,{48,48},{820,0}},['replace-all']={16898613699,{48,48},{771,
759}},['receipt-swiss-franc']={16898613699,{48,48},{967,49}},['square-dashed-bottom-code']={16898613777,{48,48},{196,820
}},['clock-7']={16898613044,{48,48},{918,514}},['scan-text']={16898613699,{48,48},{661,967}},['shower-head']={
16898613777,{48,48},{771,355}},['equal-not']={16898613353,{48,48},{49,771}},['move-down']={16898613613,{48,48},{196,820}
},['ticket-slash']={16898613869,{48,48},{820,563}},ruler={16898613699,{48,48},{710,869}},['circle-user-round']={
16898613044,{48,48},{0,869}},subscript={16898613777,{48,48},{820,808}},['alarm-minus']={16898612629,{48,48},{820,514}},[
'layout-grid']={16898613509,{48,48},{918,404}},cog={16898613044,{48,48},{918,563}},dog={16898613044,{48,48},{869,808}},
swords={16898613777,{48,48},{967,759}},['panel-right-dashed']={16898613613,{48,48},{967,710}},['ship-wheel']={
16898613777,{48,48},{820,49}},bot={16898612819,{48,48},{869,98}},['trash-2']={16898613869,{48,48},{257,918}},[
'chevron-down-square']={16898612819,{48,48},{918,196}},dot={16898613044,{48,48},{918,808}},['file-symlink']={16898613353
,{48,48},{967,257}},['clipboard-paste']={16898613044,{48,48},{514,869}},plug={16898613699,{48,48},{404,771}},[
'book-heart']={16898612819,{48,48},{820,98}},['circle-parking']={16898613044,{48,48},{820,514}},['volume-1']={
16898613869,{48,48},{820,759}},['circle-chevron-right']={16898612819,{48,48},{967,955}},speaker={16898613777,{48,48},{
869,98}},timer={16898613869,{48,48},{918,0}},forward={16898613353,{48,48},{771,857}},['file-up']={16898613353,{48,48},{
453,771}},['between-vertical-start']={16898612819,{48,48},{820,514}},database={16898613044,{48,48},{710,869}},[
'panel-right']={16898613613,{48,48},{820,857}},['log-out']={16898613509,{48,48},{820,955}},['git-branch-plus']={
16898613353,{48,48},{967,857}},['clipboard-minus']={16898613044,{48,48},{563,820}},['file-text']={16898613353,{48,48},{
869,355}},['arrow-right-circle']={16898612629,{48,48},{49,967}},['table-rows-split']={16898613777,{48,48},{869,906}},
watch={16898613869,{48,48},{869,759}},['cloud-upload']={16898613044,{48,48},{967,257}},banknote={16898612629,{48,48},{
453,967}},['folder-up']={16898613353,{48,48},{918,453}},['list-checks']={16898613509,{48,48},{404,967}},bug={16898612819
,{48,48},{257,967}},['circle-chevron-left']={16898612819,{48,48},{918,955}},['arrow-down']={16898612629,{48,48},{967,49}
},['arrow-up-down']={16898612629,{48,48},{918,612}},['file-audio']={16898613353,{48,48},{771,355}},['whole-word']={
16898613869,{48,48},{967,710}},monitor={16898613613,{48,48},{404,820}},['flag-off']={16898613353,{48,48},{820,196}},[
'align-right']={16898612629,{48,48},{918,0}},['circle-stop']={16898613044,{48,48},{49,820}},infinity={16898613509,{48,48
},{661,820}},['arrow-big-down']={16898612629,{48,48},{196,771}},['circle-parking-off']={16898613044,{48,48},{257,820}},[
'calendar-x-2']={16898612819,{48,48},{453,820}},['user-plus']={16898613869,{48,48},{918,355}},['move-diagonal-2']={
16898613613,{48,48},{967,49}},['gallery-horizontal-end']={16898613353,{48,48},{967,710}},['panel-top-dashed']={
16898613613,{48,48},{710,967}},['tram-front']={16898613869,{48,48},{306,869}},podcast={16898613699,{48,48},{820,612}},[
'image-minus']={16898613509,{48,48},{771,453}},['flip-vertical-2']={16898613353,{48,48},{967,563}},github={16898613509,{
48,48},{0,820}},pocket={16898613699,{48,48},{869,563}},printer={16898613699,{48,48},{196,771}},['megaphone-off']={
16898613613,{48,48},{514,820}},['file-bar-chart-2']={16898613353,{48,48},{869,514}},['arrow-big-right']={16898612629,{48
,48},{0,967}},replace={16898613699,{48,48},{710,820}},['toy-brick']={16898613869,{48,48},{918,257}},[
'square-chevron-down']={16898613777,{48,48},{514,967}},['dice-1']={16898613044,{48,48},{147,967}},['scan-search']={
16898613699,{48,48},{710,918}},['sticky-note']={16898613777,{48,48},{918,453}},['shield-check']={16898613777,{48,48},{
820,257}},['hand-metal']={16898613509,{48,48},{771,612}},['x-circle']={16898613869,{48,48},{771,955}},['spell-check-2']=
{16898613777,{48,48},{771,196}},['minus-square']={16898613613,{48,48},{820,147}},['box-select']={16898612819,{48,48},{
820,147}},sprout={16898613777,{48,48},{918,306}},waypoints={16898613869,{48,48},{771,857}},['ice-cream-cone']={
16898613509,{48,48},{918,306}},['text-quote']={16898613869,{48,48},{514,820}},wind={16898613869,{48,48},{820,857}},[
'layout-panel-left']={16898613509,{48,48},{453,869}},['circle-percent']={16898613044,{48,48},{563,771}},[
'circle-arrow-out-down-right']={16898612819,{48,48},{967,808}},['square-x']={16898613777,{48,48},{918,661}},italic={
16898613509,{48,48},{967,49}},['step-forward']={16898613777,{48,48},{196,918}},['a-arrow-down']={16898612629,{48,48},{
771,0}},container={16898613044,{48,48},{967,306}},sticker={16898613777,{48,48},{967,404}},['parking-circle-off']={
16898613613,{48,48},{820,955}},import={16898613509,{48,48},{967,514}},vault={16898613869,{48,48},{98,967}},[
'square-terminal']={16898613777,{48,48},{404,918}},['file-music']={16898613353,{48,48},{771,661}},beef={16898612819,{48,
48},{0,771}},['route-off']={16898613699,{48,48},{453,869}},['timer-reset']={16898613869,{48,48},{514,869}},[
'monitor-stop']={16898613613,{48,48},{820,404}},smile={16898613777,{48,48},{869,563}},['signpost-big']={16898613777,{48,
48},{869,49}},['folder-lock']={16898613353,{48,48},{967,612}},['square-percent']={16898613777,{48,48},{661,869}},[
'navigation-off']={16898613613,{48,48},{820,710}},['arrow-left']={16898612629,{48,48},{98,918}},['car-taxi-front']={
16898612819,{48,48},{967,98}},laugh={16898613509,{48,48},{869,196}},['x-square']={16898613869,{48,48},{918,857}},[
'step-back']={16898613777,{48,48},{918,196}},equal={16898613353,{48,48},{0,820}},megaphone={16898613613,{48,48},{869,0}}
,['calendar-x']={16898612819,{48,48},{404,869}},egg={16898613353,{48,48},{514,771}},['video-off']={16898613869,{48,48},{
404,918}},['japanese-yen']={16898613509,{48,48},{820,196}},library={16898613509,{48,48},{710,869}},['file-terminal']={
16898613353,{48,48},{918,306}},quote={16898613699,{48,48},{918,306}},accessibility={16898612629,{48,48},{257,771}},[
'square-library']={16898613777,{48,48},{355,918}},salad={16898613699,{48,48},{967,147}},['tally-2']={16898613869,{48,48}
,{771,0}},sheet={16898613777,{48,48},{820,0}},['circle-check-big']={16898612819,{48,48},{918,906}},['map-pinned']={
16898613613,{48,48},{771,306}},['corner-down-left']={16898613044,{48,48},{771,759}},dribbble={16898613044,{48,48},{918,
857}},['pilcrow-square']={16898613699,{48,48},{771,612}},['lamp-wall-up']={16898613509,{48,48},{918,612}},['book-dashed'
]={16898612819,{48,48},{514,869}},['unfold-vertical']={16898613869,{48,48},{306,918}},['tree-pine']={16898613869,{48,48}
,{771,661}},['receipt-indian-rupee']={16898613699,{48,48},{661,820}},['check-circle-2']={16898612819,{48,48},{918,661}},
['flask-conical']={16898613353,{48,48},{453,820}},['package-search']={16898613613,{48,48},{612,967}},columns={
16898613044,{48,48},{661,820}},['folder-sync']={16898613353,{48,48},{147,967}},fingerprint={16898613353,{48,48},{563,918
}},['arrow-up-narrow-wide']={16898612629,{48,48},{612,918}},frame={16898613353,{48,48},{710,918}},['clock-12']={
16898613044,{48,48},{820,355}},images={16898613509,{48,48},{257,967}},lollipop={16898613509,{48,48},{967,857}},[
'folder-root']={16898613353,{48,48},{612,967}},['arrow-left-circle']={16898612629,{48,48},{918,98}},['lamp-floor']={
16898613509,{48,48},{306,967}},image={16898613509,{48,48},{306,918}},['baggage-claim']={16898612629,{48,48},{967,196}},
bike={16898612819,{48,48},{771,563}},option={16898613613,{48,48},{355,967}},['scroll-text']={16898613699,{48,48},{967,
759}},['toggle-right']={16898613869,{48,48},{820,98}},['ferris-wheel']={16898613353,{48,48},{49,820}},['camera-off']={
16898612819,{48,48},{306,967}},['function-square']={16898613353,{48,48},{453,967}},group={16898613509,{48,48},{820,306}}
,codesandbox={16898613044,{48,48},{257,967}},['message-circle-question']={16898613613,{48,48},{869,514}},['tent-tree']={
16898613869,{48,48},{771,49}},['rectangle-horizontal']={16898613699,{48,48},{196,820}},subtitles={16898613777,{48,48},{
771,857}},mail={16898613613,{48,48},{820,0}},['brain-cog']={16898612819,{48,48},{0,967}},['hand-platter']={16898613509,{
48,48},{612,771}},club={16898613044,{48,48},{771,453}},twitch={16898613869,{48,48},{49,918}},pipette={16898613699,{48,48
},{869,49}},user={16898613869,{48,48},{661,869}},['align-vertical-space-around']={16898612629,{48,48},{869,306}},[
'test-tubes']={16898613869,{48,48},{820,514}},wheat={16898613869,{48,48},{453,967}},['axis-3d']={16898612629,{48,48},{
820,759}},folders={16898613353,{48,48},{967,661}},diff={16898613044,{48,48},{869,759}},puzzle={16898613699,{48,48},{49,
918}},['package-2']={16898613613,{48,48},{869,710}},indent={16898613509,{48,48},{771,710}},tangent={16898613869,{48,48},
{771,514}},['power-circle']={16898613699,{48,48},{967,0}},['badge-pound-sterling']={16898612629,{48,48},{869,759}},[
'mail-minus']={16898613509,{48,48},{967,955}},['circle-slash']={16898613044,{48,48},{98,771}},['app-window']={
16898612629,{48,48},{612,820}},['move-down-right']={16898613613,{48,48},{820,196}},['parking-square-off']={16898613613,{
48,48},{869,955}},['clipboard-pen']={16898613044,{48,48},{869,49}},['notepad-text']={16898613613,{48,48},{147,918}},[
'signal-low']={16898613777,{48,48},{612,771}},home={16898613509,{48,48},{820,147}},list={16898613509,{48,48},{869,808}},
plus={16898613699,{48,48},{257,918}},['square-arrow-right']={16898613777,{48,48},{918,563}},[
'scissors-square-dashed-bottom']={16898613699,{48,48},{918,759}},['remove-formatting']={16898613699,{48,48},{967,563}},[
'bookmark-check']={16898612819,{48,48},{771,661}},['send-horizontal']={16898613699,{48,48},{869,906}},[
'chevrons-left-right']={16898612819,{48,48},{196,967}},['folder-kanban']={16898613353,{48,48},{404,918}},['a-arrow-up']=
{16898612629,{48,48},{0,771}},['list-restart']={16898613509,{48,48},{967,196}},['cloud-moon']={16898613044,{48,48},{820,
147}},['book-audio']={16898612819,{48,48},{771,612}},['vibrate-off']={16898613869,{48,48},{869,453}},['mail-check']={
16898613509,{48,48},{918,955}},['panel-top-inactive']={16898613613,{48,48},{967,759}},['file-type-2']={16898613353,{48,
48},{820,404}},['file-code']={16898613353,{48,48},{869,49}},donut={16898613044,{48,48},{771,906}},['list-todo']={
16898613509,{48,48},{967,453}},dna={16898613044,{48,48},{967,710}},['monitor-down']={16898613613,{48,48},{98,869}},[
'cassette-tape']={16898612819,{48,48},{918,404}},['battery-low']={16898612629,{48,48},{918,857}},flashlight={16898613353
,{48,48},{869,404}},wine={16898613869,{48,48},{710,967}},signpost={16898613777,{48,48},{820,98}},['creative-commons']={
16898613044,{48,48},{147,918}},['globe-2']={16898613509,{48,48},{257,820}},landmark={16898613509,{48,48},{771,759}},[
'map-pin']={16898613613,{48,48},{820,257}},['clipboard-x']={16898613044,{48,48},{98,820}},loader={16898613509,{48,48},{
710,967}},bold={16898612819,{48,48},{355,771}},['dice-2']={16898613044,{48,48},{967,404}},['file-type']={16898613353,{48
,48},{771,453}},utensils={16898613869,{48,48},{869,196}},beer={16898612819,{48,48},{257,771}},['file-video-2']={
16898613353,{48,48},{404,820}},['chef-hat']={16898612819,{48,48},{661,918}},rocket={16898613699,{48,48},{918,147}},bird=
{16898612819,{48,48},{869,0}},['file-x']={16898613353,{48,48},{869,612}},['move-diagonal']={16898613613,{48,48},{918,98}
},['folder-minus']={16898613353,{48,48},{918,661}},['door-closed']={16898613044,{48,48},{710,967}},[
'bluetooth-connected']={16898612819,{48,48},{0,869}},['layout-template']={16898613509,{48,48},{355,967}},['air-vent']={
16898612629,{48,48},{820,0}},['rows-2']={16898613699,{48,48},{967,612}},['pen-square']={16898613699,{48,48},{514,771}},[
'panel-bottom-close']={16898613613,{48,48},{967,661}},['hand-heart']={16898613509,{48,48},{869,514}},['file-code-2']={
16898613353,{48,48},{918,0}},['arrow-down-wide-narrow']={16898612629,{48,48},{563,918}},['clock-10']={16898613044,{48,48
},{918,257}},drumstick={16898613044,{48,48},{869,955}},['disc-2']={16898613044,{48,48},{820,808}},['skip-forward']={
16898613777,{48,48},{98,820}},skull={16898613777,{48,48},{49,869}},['chevron-left']={16898612819,{48,48},{404,967}},[
'split-square-vertical']={16898613777,{48,48},{49,918}},snowflake={16898613777,{48,48},{771,661}},key={16898613509,{48,
48},{869,404}},['clock-11']={16898613044,{48,48},{869,306}},['sliders-horizontal']={16898613777,{48,48},{820,355}},[
'ticket-plus']={16898613869,{48,48},{869,514}},['square-dashed-bottom']={16898613777,{48,48},{147,869}},['mic-vocal']={
16898613613,{48,48},{869,563}},['activity-square']={16898612629,{48,48},{771,514}},['monitor-pause']={16898613613,{48,48
},{0,967}},['book-open-check']={16898612819,{48,48},{918,257}},projector={16898613699,{48,48},{147,820}},['lasso-select'
]={16898613509,{48,48},{967,98}},['folder-open-dot']={16898613353,{48,48},{869,710}},['align-justify']={16898612629,{48,
48},{563,820}},['log-in']={16898613509,{48,48},{869,906}},tag={16898613777,{48,48},{967,906}},bus={16898612819,{48,48},{
820,661}},['locate-fixed']={16898613509,{48,48},{967,759}},['bed-single']={16898612629,{48,48},{967,955}},['dice-4']={
16898613044,{48,48},{453,918}},['file-spreadsheet']={16898613353,{48,48},{49,918}},['sun-dim']={16898613777,{48,48},{710
,918}},['clipboard-list']={16898613044,{48,48},{612,771}},gamepad={16898613353,{48,48},{967,759}},['contact-round']={
16898613044,{48,48},{98,918}},['align-horizontal-space-around']={16898612629,{48,48},{771,612}},['music-2']={16898613613
,{48,48},{404,869}},['hard-hat']={16898613509,{48,48},{771,147}},['file-badge']={16898613353,{48,48},{257,869}},[
'battery-warning']={16898612629,{48,48},{820,955}},rows={16898613699,{48,48},{820,759}},['arrow-down-from-line']={
16898612629,{48,48},{404,820}},['rows-4']={16898613699,{48,48},{869,710}},biohazard={16898612819,{48,48},{514,820}},[
'book-up']={16898612819,{48,48},{257,918}},['heading-6']={16898613509,{48,48},{404,771}},['scale-3d']={16898613699,{48,
48},{453,918}},['chevron-down-circle']={16898612819,{48,48},{967,147}},['mail-x']={16898613613,{48,48},{514,771}},[
'square-dashed-mouse-pointer']={16898613777,{48,48},{49,967}},['user-cog']={16898613869,{48,48},{147,869}},[
'satellite-dish']={16898613699,{48,48},{196,918}},['alarm-clock-minus']={16898612629,{48,48},{820,257}},pizza={
16898613699,{48,48},{820,98}},['pc-case']={16898613699,{48,48},{257,771}},['move-down-left']={16898613613,{48,48},{869,
147}},school={16898613699,{48,48},{453,967}},orbit={16898613613,{48,48},{967,612}},['file-minus']={16898613353,{48,48},{
820,612}},['rotate-ccw']={16898613699,{48,48},{967,355}},['align-horizontal-justify-center']={16898612629,{48,48},{257,
869}},['phone-incoming']={16898613699,{48,48},{820,49}},antenna={16898612629,{48,48},{869,563}},['memory-stick']={
16898613613,{48,48},{771,98}},['scan-eye']={16898613699,{48,48},{869,759}},['align-center-vertical']={16898612629,{48,48
},{49,820}},['square-check']={16898613777,{48,48},{563,918}},['align-end-horizontal']={16898612629,{48,48},{869,257}},[
'message-square-off']={16898613613,{48,48},{98,820}},['folder-open']={16898613353,{48,48},{820,759}},['contact-2']={
16898613044,{48,48},{147,869}},['parking-circle']={16898613613,{48,48},{967,857}},['menu-square']={16898613613,{48,48},{
98,771}},['hand-coins']={16898613509,{48,48},{257,869}},['message-circle-code']={16898613613,{48,48},{869,257}},[
'arrow-up-wide-narrow']={16898612629,{48,48},{147,918}},['copy-x']={16898613044,{48,48},{967,563}},clock={16898613044,{
48,48},{771,661}},['file-pen']={16898613353,{48,48},{563,869}},['git-compare-arrows']={16898613353,{48,48},{918,955}},[
'square-arrow-down-right']={16898613777,{48,48},{771,453}},joystick={16898613509,{48,48},{196,820}},[
'align-vertical-space-between']={16898612629,{48,48},{820,355}},['file-pie-chart']={16898613353,{48,48},{514,918}},gem={
16898613353,{48,48},{918,857}},['calendar-plus']={16898612819,{48,48},{918,355}},['bell-electric']={16898612819,{48,48},
{514,771}},['arrow-down-z-a']={16898612629,{48,48},{514,967}},bath={16898612629,{48,48},{820,906}},anvil={16898612629,{
48,48},{820,612}},['unlink-2']={16898613869,{48,48},{918,563}},['archive-restore']={16898612629,{48,48},{514,918}},
archive={16898612629,{48,48},{918,49}},['folder-check']={16898613353,{48,48},{563,967}},['arrow-big-left-dash']={
16898612629,{48,48},{147,820}},['book-key']={16898612819,{48,48},{147,771}},ribbon={16898613699,{48,48},{967,98}},[
'package-open']={16898613613,{48,48},{710,869}},['arrow-down-0-1']={16898612629,{48,48},{869,355}},['library-big']={
16898613509,{48,48},{820,759}},['file-json']={16898613353,{48,48},{771,404}},['arrow-down-a-z']={16898612629,{48,48},{
771,453}},['arrow-down-left']={16898612629,{48,48},{257,967}},['square-scissors']={16898613777,{48,48},{147,918}},[
'move-up-left']={16898613613,{48,48},{967,306}},['arrow-down-up']={16898612629,{48,48},{612,869}},['folder-heart']={
16898613353,{48,48},{869,453}},['gauge-circle']={16898613353,{48,48},{820,906}},percent={16898613699,{48,48},{771,563}},
['arrow-up-1-0']={16898612629,{48,48},{355,918}},['arrow-up-a-z']={16898612629,{48,48},{306,967}},['circle-arrow-right']
={16898612819,{48,48},{820,955}},['panel-bottom-inactive']={16898613613,{48,48},{869,759}},['arrow-up']={16898612629,{48
,48},{967,355}},asterisk={16898612629,{48,48},{869,453}},['gallery-vertical']={16898613353,{48,48},{771,906}},[
'swatch-book']={16898613777,{48,48},{869,808}},['receipt-cent']={16898613699,{48,48},{771,710}},['audio-lines']={
16898612629,{48,48},{355,967}},['folder-archive']={16898613353,{48,48},{612,918}},['folder-symlink']={16898613353,{48,48
},{196,918}},['columns-3']={16898613044,{48,48},{771,710}},ban={16898612629,{48,48},{196,967}},['message-square-x']={
16898613613,{48,48},{404,771}},['paint-roller']={16898613613,{48,48},{147,967}},['folder-search-2']={16898613353,{48,48}
,{967,147}},fan={16898613353,{48,48},{869,0}},['badge-euro']={16898612629,{48,48},{196,918}},['badge-info']={16898612629
,{48,48},{918,453}},['building-2']={16898612819,{48,48},{967,514}},square={16898613777,{48,48},{869,710}},medal={
16898613613,{48,48},{563,771}},cake={16898612819,{48,48},{612,869}},['cloud-rain']={16898613044,{48,48},{147,820}},[
'maximize-2']={16898613613,{48,48},{820,514}},shell={16898613777,{48,48},{771,49}},wrench={16898613869,{48,48},{820,906}
},badge={16898612629,{48,48},{661,967}},codepen={16898613044,{48,48},{306,918}},['corner-right-down']={16898613044,{48,
48},{563,967}},['flag-triangle-right']={16898613353,{48,48},{147,869}},network={16898613613,{48,48},{710,820}},[
'bar-chart-3']={16898612629,{48,48},{918,759}},bell={16898612819,{48,48},{820,257}},['bar-chart']={16898612629,{48,48},{
967,759}},ratio={16898613699,{48,48},{820,661}},['square-chevron-up']={16898613777,{48,48},{869,147}},['brick-wall']={
16898612819,{48,48},{918,306}},['user-check']={16898613869,{48,48},{918,98}},proportions={16898613699,{48,48},{98,869}},
['alert-octagon']={16898612629,{48,48},{820,49}},plane={16898613699,{48,48},{98,820}},['webhook-off']={16898613869,{48,
48},{661,967}},['thermometer-sun']={16898613869,{48,48},{0,869}},['square-arrow-left']={16898613777,{48,48},{404,820}},[
'mouse-pointer']={16898613613,{48,48},{612,869}},heart={16898613509,{48,48},{661,771}},['test-tube-diagonal']={
16898613869,{48,48},{306,771}},['briefcase-medical']={16898612819,{48,48},{820,404}},['align-vertical-distribute-start']
={16898612629,{48,48},{98,820}},mailbox={16898613613,{48,48},{771,49}},['bell-off']={16898612819,{48,48},{771,49}},
binary={16898612819,{48,48},{563,771}},['book-open-text']={16898612819,{48,48},{869,306}},split={16898613777,{48,48},{0,
967}},twitter={16898613869,{48,48},{0,967}},calculator={16898612819,{48,48},{563,918}},forklift={16898613353,{48,48},{
869,759}},bluetooth={16898612819,{48,48},{771,355}},folder={16898613353,{48,48},{404,967}},['square-kanban']={
16898613777,{48,48},{404,869}},['message-square-diff']={16898613613,{48,48},{869,49}},['square-sigma']={16898613777,{48,
48},{98,967}},['alarm-plus']={16898612629,{48,48},{771,563}},star={16898613777,{48,48},{967,147}},['rotate-ccw-square']=
{16898613699,{48,48},{98,967}},castle={16898612819,{48,48},{453,869}},['book-down']={16898612819,{48,48},{918,0}},[
'file-volume-2']={16898613353,{48,48},{306,918}},['book-headphones']={16898612819,{48,48},{869,49}},power={16898613699,{
48,48},{820,147}},album={16898612629,{48,48},{514,820}},['book-marked']={16898612819,{48,48},{49,869}},['book-open']={
16898612819,{48,48},{820,355}},['file-box']={16898613353,{48,48},{771,612}},['book-text']={16898612819,{48,48},{404,771}
},telescope={16898613869,{48,48},{820,0}},['glass-water']={16898613509,{48,48},{771,306}},filter={16898613353,{48,48},{
612,869}},glasses={16898613509,{48,48},{306,771}},['piggy-bank']={16898613699,{48,48},{820,563}},['book-type']={
16898612819,{48,48},{355,820}},cuboid={16898613044,{48,48},{355,967}},['cloud-off']={16898613044,{48,48},{771,196}},[
'check-check']={16898612819,{48,48},{967,612}},activity={16898612629,{48,48},{514,771}},axe={16898612629,{48,48},{869,
710}},['plane-takeoff']={16898613699,{48,48},{147,771}},['book-x']={16898612819,{48,48},{869,563}},['cloud-rain-wind']={
16898613044,{48,48},{196,771}},bookmark={16898612819,{48,48},{514,918}},['zoom-in']={16898613869,{48,48},{869,955}},[
'square-pilcrow']={16898613777,{48,48},{563,967}},['file-axis-3d']={16898613353,{48,48},{355,771}},['receipt-euro']={
16898613699,{48,48},{710,771}},['brain-circuit']={16898612819,{48,48},{49,918}},['briefcase-business']={16898612819,{48,
48},{869,355}},['bug-play']={16898612819,{48,48},{306,918}},['tally-3']={16898613869,{48,48},{0,771}},['clipboard-type']
={16898613044,{48,48},{147,771}},brush={16898612819,{48,48},{404,820}},['tally-5']={16898613869,{48,48},{257,771}},[
'cable-car']={16898612819,{48,48},{771,710}},cable={16898612819,{48,48},{710,771}},['calendar-check']={16898612819,{48,
48},{967,49}},['user-square-2']={16898613869,{48,48},{869,661}},['calendar-minus']={16898612819,{48,48},{98,918}},[
'calendar-plus-2']={16898612819,{48,48},{967,306}},linkedin={16898613509,{48,48},{453,918}},['life-buoy']={16898613509,{
48,48},{661,918}},['calendar-search']={16898612819,{48,48},{820,453}},['circle-chevron-down']={16898612819,{48,48},{967,
906}},['volume-2']={16898613869,{48,48},{771,808}},['battery-charging']={16898612629,{48,48},{771,955}},['russian-ruble'
]={16898613699,{48,48},{661,918}},['square-arrow-up-left']={16898613777,{48,48},{869,612}},['earth-lock']={16898613353,{
48,48},{771,0}},footprints={16898613353,{48,48},{918,710}},hash={16898613509,{48,48},{147,771}},building={16898612819,{
48,48},{918,563}},ear={16898613044,{48,48},{967,955}},caravan={16898612819,{48,48},{869,196}},carrot={16898612819,{48,48
},{196,869}},cherry={16898612819,{48,48},{612,967}},['user-check-2']={16898613869,{48,48},{967,49}},['shield-plus']={
16898613777,{48,48},{771,563}},moon={16898613613,{48,48},{306,918}},['bell-minus']={16898612819,{48,48},{820,0}},[
'image-up']={16898613509,{48,48},{355,869}},['case-sensitive']={16898612819,{48,48},{98,967}},drum={16898613044,{48,48},
{918,906}},['arrow-up-z-a']={16898612629,{48,48},{98,967}},sun={16898613777,{48,48},{967,453}},['gantt-chart-square']={
16898613353,{48,48},{918,808}},['align-horizontal-justify-start']={16898612629,{48,48},{820,563}},['file-key']={
16898613353,{48,48},{355,820}},['monitor-smartphone']={16898613613,{48,48},{918,306}},['move-3d']={16898613613,{48,48},{
514,967}},['scissors-line-dashed']={16898613699,{48,48},{967,710}},['text-select']={16898613869,{48,48},{820,49}},[
'case-lower']={16898612819,{48,48},{147,918}},['plus-circle']={16898613699,{48,48},{355,820}},['ticket-check']={
16898613869,{48,48},{355,771}},pyramid={16898613699,{48,48},{0,967}},['chevron-last']={16898612819,{48,48},{967,404}},[
'user-cog-2']={16898613869,{48,48},{196,820}},['refresh-cw-off']={16898613699,{48,48},{453,820}},piano={16898613699,{48,
48},{771,355}},['picture-in-picture-2']={16898613699,{48,48},{306,820}},['user-round']={16898613869,{48,48},{967,563}},[
'flower-2']={16898613353,{48,48},{869,661}},['chevron-up-square']={16898612819,{48,48},{771,857}},['chevrons-left']={
16898612819,{48,48},{967,453}},['chevrons-right-left']={16898612819,{48,48},{453,967}},car={16898612819,{48,48},{918,147
}},['keyboard-music']={16898613509,{48,48},{820,453}},['star-half']={16898613777,{48,48},{661,918}},mouse={16898613613,{
48,48},{563,918}},lock={16898613509,{48,48},{918,857}},['pencil-line']={16898613699,{48,48},{49,771}},mails={16898613613
,{48,48},{49,771}},film={16898613353,{48,48},{710,771}},tablet={16898613777,{48,48},{918,906}},['circle-arrow-left']={
16898612819,{48,48},{820,906}},pi={16898613699,{48,48},{820,306}},trash={16898613869,{48,48},{918,514}},dock={
16898613044,{48,48},{918,759}},['hdmi-port']={16898613509,{48,48},{49,869}},['circle-arrow-out-up-left']={16898612819,{
48,48},{918,857}},['case-upper']={16898612819,{48,48},{967,355}},['circle-arrow-out-up-right']={16898612819,{48,48},{869
,906}},tags={16898613777,{48,48},{918,955}},croissant={16898613044,{48,48},{967,355}},['circle-check']={16898612819,{48,
48},{869,955}},bomb={16898612819,{48,48},{257,869}},diameter={16898613044,{48,48},{967,147}},['circle-dashed']={
16898613044,{48,48},{0,771}},['bar-chart-big']={16898612629,{48,48},{820,857}},['upload-cloud']={16898613869,{48,48},{
661,820}},['code-xml']={16898613044,{48,48},{404,820}},divide={16898613044,{48,48},{967,453}},grape={16898613509,{48,48}
,{820,49}},['play-square']={16898613699,{48,48},{0,918}},['party-popper']={16898613613,{48,48},{918,955}},[
'circle-ellipsis']={16898613044,{48,48},{820,0}},file={16898613353,{48,48},{820,661}},['user-circle-2']={16898613869,{48
,48},{869,147}},truck={16898613869,{48,48},{771,196}},['cloud-sun-rain']={16898613044,{48,48},{49,918}},[
'calendar-range']={16898612819,{48,48},{869,404}},contact={16898613044,{48,48},{49,967}},['zap-off']={16898613869,{48,48
},{967,857}},['square-check-big']={16898613777,{48,48},{612,869}},['circle-user']={16898613044,{48,48},{869,257}},[
'layout-panel-top']={16898613509,{48,48},{404,918}},['roller-coaster']={16898613699,{48,48},{196,869}},['laptop-minimal'
]={16898613509,{48,48},{612,918}},['table-properties']={16898613777,{48,48},{918,857}},['clipboard-check']={16898613044,
{48,48},{869,514}},layout={16898613509,{48,48},{967,612}},['indent-decrease']={16898613509,{48,48},{869,612}},cookie={
16898613044,{48,48},{869,404}},['message-square-more']={16898613613,{48,48},{147,771}},clipboard={16898613044,{48,48},{
49,869}},euro={16898613353,{48,48},{771,306}},sparkles={16898613777,{48,48},{918,49}},['heart-off']={16898613509,{48,48}
,{820,612}},vibrate={16898613869,{48,48},{453,869}},['clock-3']={16898613044,{48,48},{404,771}},['move-horizontal']={
16898613613,{48,48},{147,869}},['file-sliders']={16898613353,{48,48},{98,869}},frown={16898613353,{48,48},{967,196}},[
'move-up-right']={16898613613,{48,48},{918,355}},['cup-soda']={16898613044,{48,48},{967,612}},['stretch-vertical']={
16898613777,{48,48},{918,710}},['refresh-cw']={16898613699,{48,48},{404,869}},sword={16898613777,{48,48},{710,967}},[
'cloud-drizzle']={16898613044,{48,48},{563,869}},['laptop-2']={16898613509,{48,48},{661,869}},earth={16898613353,{48,48}
,{0,771}},slice={16898613777,{48,48},{869,306}},['land-plot']={16898613509,{48,48},{820,710}},milk={16898613613,{48,48},
{514,918}},['git-pull-request-draft']={16898613509,{48,48},{771,49}},crown={16898613044,{48,48},{404,918}},['wallet-2']=
{16898613869,{48,48},{967,147}},settings={16898613777,{48,48},{771,257}},['rotate-cw-square']={16898613699,{48,48},{918,
404}},atom={16898612629,{48,48},{404,918}},['package-x']={16898613613,{48,48},{967,147}},['bed-double']={16898612629,{48
,48},{918,955}},['ice-cream-bowl']={16898613509,{48,48},{967,257}},['circle-dot']={16898613044,{48,48},{514,771}},[
'grip-horizontal']={16898613509,{48,48},{49,820}},cloudy={16898613044,{48,48},{869,355}},['text-cursor-input']={
16898613869,{48,48},{771,563}},['folder-git-2']={16898613353,{48,48},{967,355}},['message-square-code']={16898613613,{48
,48},{514,869}},clover={16898613044,{48,48},{820,404}},['arrow-down-narrow-wide']={16898612629,{48,48},{967,514}},code={
16898613044,{48,48},{355,869}},['user-x']={16898613869,{48,48},{710,820}},coins={16898613044,{48,48},{869,612}},dumbbell
={16898613044,{48,48},{967,906}},weight={16898613869,{48,48},{196,967}},['alert-triangle']={16898612629,{48,48},{771,98}
},expand={16898613353,{48,48},{306,771}},scale={16898613699,{48,48},{404,967}},component={16898613044,{48,48},{967,49}},
['flashlight-off']={16898613353,{48,48},{918,355}},['panel-top-open']={16898613613,{48,48},{918,808}},computer={
16898613044,{48,48},{918,98}},construction={16898613044,{48,48},{196,820}},notebook={16898613613,{48,48},{869,196}},[
'power-square']={16898613699,{48,48},{869,98}},['copy-slash']={16898613044,{48,48},{306,967}},['square-menu']={
16898613777,{48,48},{967,563}},['circle-play']={16898613044,{48,48},{514,820}},wallet={16898613869,{48,48},{147,967}},
laptop={16898613509,{48,48},{563,967}},['scan-line']={16898613699,{48,48},{771,857}},['clock-4']={16898613044,{48,48},{
355,820}},['square-arrow-up']={16898613777,{48,48},{771,710}},copyright={16898613044,{48,48},{820,710}},['chevron-down']
={16898612819,{48,48},{196,918}},['unlock-keyhole']={16898613869,{48,48},{820,661}},['clock-1']={16898613044,{48,48},{0,
918}},['align-horizontal-distribute-start']={16898612629,{48,48},{306,820}},['arrow-down-to-line']={16898612629,{48,48},
{661,820}},['mouse-pointer-2']={16898613613,{48,48},{820,661}},['refresh-ccw']={16898613699,{48,48},{820,453}},[
'venetian-mask']={16898613869,{48,48},{918,404}},['calendar-check-2']={16898612819,{48,48},{514,967}},[
'arrow-down-square']={16898612629,{48,48},{771,710}},spline={16898613777,{48,48},{147,820}},banana={16898612629,{48,48},
{967,453}},['git-pull-request-create-arrow']={16898613509,{48,48},{514,771}},crosshair={16898613044,{48,48},{453,869}},[
'list-video']={16898613509,{48,48},{967,710}},['arrow-right-left']={16898612629,{48,48},{918,355}},['bar-chart-4']={
16898612629,{48,48},{869,808}},['dice-3']={16898613044,{48,48},{918,453}},['dice-5']={16898613044,{48,48},{404,967}},[
'dice-6']={16898613044,{48,48},{967,661}},['square-plus']={16898613777,{48,48},{918,147}},['timer-off']={16898613869,{48
,48},{563,820}},['arrow-big-right-dash']={16898612629,{48,48},{49,918}},['radio-receiver']={16898613699,{48,48},{404,820
}},shield={16898613777,{48,48},{869,0}},['square-equal']={16898613777,{48,48},{869,404}},backpack={16898612629,{48,48},{
710,869}},download={16898613044,{48,48},{820,906}},['drafting-compass']={16898613044,{48,48},{771,955}},youtube={
16898613869,{48,48},{820,955}},['file-plus-2']={16898613353,{48,48},{967,0}},['message-circle-more']={16898613613,{48,48
},{355,771}},['arrow-down-right']={16898612629,{48,48},{820,661}},['loader-circle']={16898613509,{48,48},{771,906}},
receipt={16898613699,{48,48},{869,147}},['egg-off']={16898613353,{48,48},{771,514}},bitcoin={16898612819,{48,48},{820,49
}},['eye-off']={16898613353,{48,48},{820,514}},factory={16898613353,{48,48},{514,820}},['fast-forward']={16898613353,{48
,48},{820,49}},['image-off']={16898613509,{48,48},{453,771}},['file-audio-2']={16898613353,{48,48},{820,306}},braces={
16898612819,{48,48},{147,820}},cone={16898613044,{48,48},{820,196}},['wand-sparkles']={16898613869,{48,48},{453,918}},[
'square-chevron-right']={16898613777,{48,48},{918,98}},navigation={16898613613,{48,48},{771,759}},['file-check']={
16898613353,{48,48},{563,820}},['file-cog']={16898613353,{48,48},{820,98}},['file-diff']={16898613353,{48,48},{771,147}}
,['file-digit']={16898613353,{48,48},{147,771}},['power-off']={16898613699,{48,48},{918,49}},[
'align-vertical-distribute-center']={16898612629,{48,48},{771,147}},['tally-1']={16898613777,{48,48},{967,955}},
ampersand={16898612629,{48,48},{404,771}},['line-chart']={16898613509,{48,48},{196,918}},['shopping-cart']={16898613777,
{48,48},{869,257}},['align-vertical-justify-end']={16898612629,{48,48},{0,918}},eraser={16898613353,{48,48},{820,257}},[
'alarm-smoke']={16898612629,{48,48},{563,771}},['file-line-chart']={16898613353,{48,48},{306,869}},['file-input']={
16898613353,{48,48},{869,306}},['clock-8']={16898613044,{48,48},{869,563}},['server-cog']={16898613699,{48,48},{967,906}
},['cloud-cog']={16898613044,{48,48},{661,771}},blend={16898612819,{48,48},{771,98}},['search-x']={16898613699,{48,48},{
967,808}},['radio-tower']={16898613699,{48,48},{355,869}},['list-tree']={16898613509,{48,48},{453,967}},droplet={
16898613044,{48,48},{820,955}},heater={16898613509,{48,48},{612,820}},eye={16898613353,{48,48},{771,563}},battery={
16898612629,{48,48},{967,857}},lamp={16898613509,{48,48},{869,661}},['link-2-off']={16898613509,{48,48},{147,967}},[
'panel-top']={16898613613,{48,48},{869,857}},['file-volume']={16898613353,{48,48},{257,967}},['file-x-2']={16898613353,{
48,48},{918,563}},['circle-equal']={16898613044,{48,48},{771,49}},['flag-triangle-left']={16898613353,{48,48},{196,820}}
,flower={16898613353,{48,48},{820,710}},['fold-horizontal']={16898613353,{48,48},{710,820}},['folder-closed']={
16898613353,{48,48},{918,147}},['folder-dot']={16898613353,{48,48},{196,869}},['arrow-up-right']={16898612629,{48,48},{
918,147}},router={16898613699,{48,48},{355,967}},['leafy-green']={16898613509,{48,48},{869,710}},['message-square-dot']=
{16898613613,{48,48},{820,98}},focus={16898613353,{48,48},{771,759}},copyleft={16898613044,{48,48},{869,661}},[
'folder-x']={16898613353,{48,48},{453,918}},['form-input']={16898613353,{48,48},{820,808}},['minimize-2']={16898613613,{
48,48},{967,0}},regex={16898613699,{48,48},{306,967}},['gallery-horizontal']={16898613353,{48,48},{918,759}},university=
{16898613869,{48,48},{967,514}},['gallery-vertical-end']={16898613353,{48,48},{820,857}},['file-image']={16898613353,{48
,48},{918,257}},['at-sign']={16898612629,{48,48},{453,869}},palette={16898613613,{48,48},{453,918}},['user-plus-2']={
16898613869,{48,48},{967,306}},['gallery-thumbnails']={16898613353,{48,48},{869,808}},['arrow-down-right-from-circle']={
16898612629,{48,48},{918,563}},cpu={16898613044,{48,48},{196,869}},['split-square-horizontal']={16898613777,{48,48},{98,
869}},['thumbs-down']={16898613869,{48,48},{820,306}},merge={16898613613,{48,48},{0,869}},ghost={16898613353,{48,48},{
869,906}},['git-compare']={16898613353,{48,48},{967,955}},['git-fork']={16898613509,{48,48},{771,0}},hospital={
16898613509,{48,48},{147,820}},['git-merge']={16898613509,{48,48},{771,257}},['folder-edit']={16898613353,{48,48},{98,
967}},['thumbs-up']={16898613869,{48,48},{771,355}},globe={16898613509,{48,48},{771,563}},palmtree={16898613613,{48,48},
{404,967}},['bug-off']={16898612819,{48,48},{355,869}},kanban={16898613509,{48,48},{49,967}},['thermometer-snowflake']={
16898613869,{48,48},{49,820}},apple={16898612629,{48,48},{563,869}},['wine-off']={16898613869,{48,48},{771,906}},[
'graduation-cap']={16898613509,{48,48},{869,0}},['hand-helping']={16898613509,{48,48},{820,563}},hand={16898613509,{48,
48},{563,820}},['square-bottom-dashed-scissors']={16898613777,{48,48},{661,820}},stamp={16898613777,{48,48},{710,869}},[
'candy-off']={16898612819,{48,48},{820,710}},['plug-zap-2']={16898613699,{48,48},{820,355}},['heading-2']={16898613509,{
48,48},{918,257}},['square-activity']={16898613777,{48,48},{869,355}},['circle-gauge']={16898613044,{48,48},{0,820}},[
'cigarette-off']={16898612819,{48,48},{710,967}},['arrow-up-0-1']={16898612629,{48,48},{404,869}},['message-circle']={
16898613613,{48,48},{563,820}},['undo-2']={16898613869,{48,48},{771,453}},headset={16898613509,{48,48},{257,918}},[
'heart-crack']={16898613509,{48,48},{918,514}},['git-branch']={16898613353,{48,48},{918,906}},shovel={16898613777,{48,48
},{820,306}},share={16898613777,{48,48},{514,771}},['wallet-cards']={16898613869,{48,48},{918,196}},[
'square-arrow-out-down-right']={16898613777,{48,48},{306,918}},grip={16898613509,{48,48},{869,257}},['monitor-speaker']=
{16898613613,{48,48},{869,355}},save={16898613699,{48,48},{918,453}},['cloud-snow']={16898613044,{48,48},{98,869}},[
'file-question']={16898613353,{48,48},{869,98}},['arrow-big-up-dash']={16898612629,{48,48},{967,257}},coffee={
16898613044,{48,48},{967,514}},['image-down']={16898613509,{48,48},{820,404}},['beer-off']={16898612819,{48,48},{771,257
}},['file-bar-chart']={16898613353,{48,48},{820,563}},['bar-chart-2']={16898612629,{48,48},{967,710}},[
'lock-keyhole-open']={16898613509,{48,48},{820,906}},['chevrons-down-up']={16898612819,{48,48},{661,967}},[
'clipboard-plus']={16898613044,{48,48},{820,98}},['monitor-up']={16898613613,{48,48},{771,453}},['list-end']={
16898613509,{48,48},{918,710}},['square-radical']={16898613777,{48,48},{196,869}},play={16898613699,{48,48},{918,257}},[
'chevrons-right']={16898612819,{48,48},{967,710}},['file-badge-2']={16898613353,{48,48},{306,820}},[
'message-square-reply']={16898613613,{48,48},{918,257}},['corner-down-right']={16898613044,{48,48},{710,820}},phone={
16898613699,{48,48},{0,869}},['arrow-left-to-line']={16898612629,{48,48},{147,869}},['lamp-wall-down']={16898613509,{48,
48},{967,563}},['link-2']={16898613509,{48,48},{967,404}},['repeat']={16898613699,{48,48},{820,710}},[
'ellipsis-vertical']={16898613353,{48,48},{820,0}},snail={16898613777,{48,48},{820,612}},['paint-bucket']={16898613613,{
48,48},{196,918}},['square-parking']={16898613777,{48,48},{771,759}},['align-horizontal-justify-end']={16898612629,{48,
48},{869,514}},lasso={16898613509,{48,48},{918,147}},['align-vertical-distribute-end']={16898612629,{48,48},{147,771}},
soup={16898613777,{48,48},{612,820}},airplay={16898612629,{48,48},{771,49}},['layout-dashboard']={16898613509,{48,48},{
967,355}},['heading-1']={16898613509,{48,48},{0,918}},['circle-x']={16898613044,{48,48},{820,306}},['monitor-x']={
16898613613,{48,48},{453,771}},['octagon-pause']={16898613613,{48,48},{869,453}},['library-square']={16898613509,{48,48}
,{771,808}},['square-pen']={16898613777,{48,48},{710,820}},['heart-pulse']={16898613509,{48,48},{771,661}},[
'database-backup']={16898613044,{48,48},{820,759}},['gantt-chart']={16898613353,{48,48},{869,857}},octagon={16898613613,
{48,48},{404,918}},ticket={16898613869,{48,48},{612,771}},['message-square']={16898613613,{48,48},{355,820}},[
'list-filter']={16898613509,{48,48},{869,759}},['train-front']={16898613869,{48,48},{404,771}},['spray-can']={
16898613777,{48,48},{967,257}},['list-music']={16898613509,{48,48},{771,857}},['utility-pole']={16898613869,{48,48},{196
,869}},['list-plus']={16898613509,{48,48},{661,967}},['screen-share']={16898613699,{48,48},{710,967}},['file-clock']={
16898613353,{48,48},{514,869}},['list-collapse']={16898613509,{48,48},{967,661}},gauge={16898613353,{48,48},{771,955}},
store={16898613777,{48,48},{404,967}},['circle-arrow-down']={16898612819,{48,48},{869,857}},['notebook-pen']={
16898613613,{48,48},{563,967}},['egg-fried']={16898613353,{48,48},{257,771}},['calendar-off']={16898612819,{48,48},{49,
967}},['locate-off']={16898613509,{48,48},{918,808}},['corner-right-up']={16898613044,{48,48},{967,98}},locate={
16898613509,{48,48},{869,857}},['ticket-x']={16898613869,{48,48},{771,612}},['user-round-plus']={16898613869,{48,48},{
404,869}},['panel-left-close']={16898613613,{48,48},{710,918}},['lock-keyhole']={16898613509,{48,48},{771,955}},[
'lock-open']={16898613509,{48,48},{967,808}},['user-round-minus']={16898613869,{48,48},{453,820}},['m-square']={
16898613509,{48,48},{869,955}},magnet={16898613509,{48,48},{967,906}},['message-square-text']={16898613613,{48,48},{820,
355}},['mail-plus']={16898613613,{48,48},{0,771}},['mail-search']={16898613613,{48,48},{257,771}},move={16898613613,{48,
48},{453,820}},['play-circle']={16898613699,{48,48},{49,869}},['git-commit-vertical']={16898613353,{48,48},{967,906}},
slash={16898613777,{48,48},{918,257}},['map-pin-off']={16898613613,{48,48},{0,820}},aperture={16898612629,{48,48},{771,
661}},['image-plus']={16898613509,{48,48},{404,820}},['message-circle-heart']={16898613613,{48,48},{771,355}},syringe={
16898613777,{48,48},{918,808}},info={16898613509,{48,48},{612,869}},['rows-3']={16898613699,{48,48},{918,661}},check={
16898612819,{48,48},{710,869}},['text-search']={16898613869,{48,48},{869,0}},['square-slash']={16898613777,{48,48},{967,
355}},sandwich={16898613699,{48,48},{918,196}},['settings-2']={16898613777,{48,48},{0,771}},['file-stack']={16898613353,
{48,48},{0,967}},['external-link']={16898613353,{48,48},{257,820}},['ice-cream-2']={16898613509,{48,48},{0,967}},[
'file-archive']={16898613353,{48,48},{869,257}},['signal-high']={16898613777,{48,48},{771,612}},inbox={16898613509,{48,
48},{918,563}},['flip-horizontal-2']={16898613353,{48,48},{355,918}},['traffic-cone']={16898613869,{48,48},{820,355}},[
'file-signature']={16898613353,{48,48},{147,820}},['align-horizontal-space-between']={16898612629,{48,48},{612,771}},[
'message-circle-dashed']={16898613613,{48,48},{820,306}},maximize={16898613613,{48,48},{771,563}},['database-zap']={
16898613044,{48,48},{771,808}},droplets={16898613044,{48,48},{967,857}},['fish-symbol']={16898613353,{48,48},{918,98}},[
'message-circle-off']={16898613613,{48,48},{306,820}},['wheat-off']={16898613869,{48,48},{967,453}},['layout-list']={
16898613509,{48,48},{869,453}},['file-search']={16898613353,{48,48},{196,771}},['download-cloud']={16898613044,{48,48},{
869,857}},['alarm-clock-plus']={16898612629,{48,48},{306,771}},['circle-dollar-sign']={16898613044,{48,48},{257,771}},
usb={16898613869,{48,48},{563,918}},['arrow-up-square']={16898612629,{48,48},{869,196}},['receipt-pound-sterling']={
16898613699,{48,48},{563,918}},scan={16898613699,{48,48},{967,196}},['heading-5']={16898613509,{48,48},{771,404}},undo={
16898613869,{48,48},{404,820}},['file-search-2']={16898613353,{48,48},{771,196}},minimize={16898613613,{48,48},{918,49}}
,['redo-2']={16898613699,{48,48},{49,967}},thermometer={16898613869,{48,48},{869,257}},['filter-x']={16898613353,{48,48}
,{661,820}},['sliders-vertical']={16898613777,{48,48},{771,404}},['boom-box']={16898612819,{48,48},{967,0}},['table-2']=
{16898613777,{48,48},{869,857}},['touchpad-off']={16898613869,{48,48},{98,820}},['diamond-percent']={16898613044,{48,48}
,{918,196}},brain={16898612819,{48,48},{967,257}},microwave={16898613613,{48,48},{661,771}},['arrow-down-left-square']={
16898612629,{48,48},{306,918}},['user-round-cog']={16898613869,{48,48},{820,453}},['octagon-x']={16898613613,{48,48},{
453,869}},languages={16898613509,{48,48},{710,820}},['file-json-2']={16898613353,{48,48},{820,355}},['alarm-clock-check'
]={16898612629,{48,48},{0,820}},guitar={16898613509,{48,48},{771,355}},anchor={16898612629,{48,48},{306,869}},[
'text-cursor']={16898613869,{48,48},{563,771}},['search-code']={16898613699,{48,48},{820,906}},['square-parking-off']={
16898613777,{48,48},{820,710}},['notebook-text']={16898613613,{48,48},{918,147}},['arrow-right-to-line']={16898612629,{
48,48},{820,453}},['ticket-minus']={16898613869,{48,48},{306,820}},['tally-4']={16898613869,{48,48},{771,257}},heading={
16898613509,{48,48},{355,820}},wallpaper={16898613869,{48,48},{967,404}},['door-open']={16898613044,{48,48},{967,759}},[
'arrow-down-circle']={16898612629,{48,48},{453,771}},['monitor-play']={16898613613,{48,48},{967,257}},['key-square']={
16898613509,{48,48},{918,355}},['monitor-off']={16898613613,{48,48},{49,918}},['pocket-knife']={16898613699,{48,48},{918
,514}},['book-copy']={16898612819,{48,48},{563,820}},['panel-left-inactive']={16898613613,{48,48},{967,196}},[
'car-front']={16898612819,{48,48},{563,967}},['file-video']={16898613353,{48,48},{355,869}},['reply-all']={16898613699,{
48,48},{661,869}},['cloud-moon-rain']={16898613044,{48,48},{869,98}},['zoom-out']={16898613869,{48,48},{967,906}},[
'search-slash']={16898613699,{48,48},{771,955}},['notepad-text-dashed']={16898613613,{48,48},{196,869}},['circle-alert']
={16898612819,{48,48},{918,808}},briefcase={16898612819,{48,48},{771,453}},['list-start']={16898613509,{48,48},{196,967}
},['more-vertical']={16898613613,{48,48},{967,514}},['a-large-small']={16898612629,{48,48},{771,257}},tractor={
16898613869,{48,48},{869,306}},waves={16898613869,{48,48},{820,808}},['folder-cog']={16898613353,{48,48},{869,196}},[
'code-2']={16898613044,{48,48},{453,771}},['clock-5']={16898613044,{48,48},{306,869}},vote={16898613869,{48,48},{612,967
}},['shield-question']={16898613777,{48,48},{563,771}},['arrow-right-from-line']={16898612629,{48,48},{967,306}},[
'flame-kindling']={16898613353,{48,48},{49,967}},['square-power']={16898613777,{48,48},{869,196}},['circle-help']={
16898613044,{48,48},{820,257}},['bring-to-front']={16898612819,{48,48},{453,771}},['move-right']={16898613613,{48,48},{
49,967}},figma={16898613353,{48,48},{0,869}},['bell-plus']={16898612819,{48,48},{49,771}},sailboat={16898613699,{48,48},
{612,967}},['hard-drive-upload']={16898613509,{48,48},{869,49}},['pie-chart']={16898613699,{48,48},{869,514}},meh={
16898613613,{48,48},{820,49}},['mail-warning']={16898613613,{48,48},{771,514}},['music-3']={16898613613,{48,48},{355,918
}},['pause-circle']={16898613613,{48,48},{967,955}},['panels-right-bottom']={16898613613,{48,48},{771,955}},['file-edit'
]={16898613353,{48,48},{49,869}},redo={16898613699,{48,48},{918,355}},['file-lock']={16898613353,{48,48},{918,514}},[
'square-user']={16898613777,{48,48},{967,612}},['circle-fading-plus']={16898613044,{48,48},{49,771}},workflow={
16898613869,{48,48},{967,759}},['undo-dot']={16898613869,{48,48},{453,771}},target={16898613869,{48,48},{514,771}},
tablets={16898613777,{48,48},{869,955}},radar={16898613699,{48,48},{820,404}},drama={16898613044,{48,48},{967,808}},[
'signal-medium']={16898613777,{48,48},{563,820}},baseline={16898612629,{48,48},{869,857}},martini={16898613613,{48,48},{
257,820}},contrast={16898613044,{48,48},{918,355}},pickaxe={16898613699,{48,48},{355,771}},['square-divide']={
16898613777,{48,48},{967,306}},['chevron-left-circle']={16898612819,{48,48},{918,453}},['book-check']={16898612819,{48,
48},{612,771}},['scan-barcode']={16898613699,{48,48},{918,710}},['book-lock']={16898612819,{48,48},{98,820}},[
'panel-right-inactive']={16898613613,{48,48},{918,759}},refrigerator={16898613699,{48,48},{355,918}},['divide-circle']={
16898613044,{48,48},{967,196}},['package-plus']={16898613613,{48,48},{661,918}},['mic-2']={16898613613,{48,48},{257,918}
},['hop-off']={16898613509,{48,48},{771,196}},warehouse={16898613869,{48,48},{967,661}},['plus-square']={16898613699,{48
,48},{306,869}},['square-arrow-out-up-left']={16898613777,{48,48},{257,967}},['save-all']={16898613699,{48,48},{967,404}
},candy={16898612819,{48,48},{771,759}},['iteration-ccw']={16898613509,{48,48},{918,98}},['corner-left-down']={
16898613044,{48,48},{661,869}},paintbrush={16898613613,{48,48},{918,453}},['cloud-lightning']={16898613044,{48,48},{918,
49}},['circle-slash-2']={16898613044,{48,48},{771,98}},['layers-3']={16898613509,{48,48},{147,918}},['credit-card']={
16898613044,{48,48},{98,967}},['ear-off']={16898613044,{48,48},{918,955}},['git-commit-horizontal']={16898613353,{48,48}
,{869,955}},['panel-bottom']={16898613613,{48,48},{771,857}},['square-code']={16898613777,{48,48},{820,196}},[
'panel-bottom-open']={16898613613,{48,48},{820,808}},['kanban-square-dashed']={16898613509,{48,48},{147,869}},[
'circle-pause']={16898613044,{48,48},{771,563}},['panel-top-close']={16898613613,{48,48},{771,906}},ambulance={
16898612629,{48,48},{771,404}},['trending-up']={16898613869,{48,48},{514,918}},['bookmark-x']={16898612819,{48,48},{563,
869}},['clock-9']={16898613044,{48,48},{820,612}},pen={16898613699,{48,48},{771,49}},['smartphone-nfc']={16898613777,{48
,48},{306,869}},['candy-cane']={16898612819,{48,48},{869,661}},unlink={16898613869,{48,48},{869,612}},['parking-meter']=
{16898613613,{48,48},{918,906}},['gamepad-2']={16898613353,{48,48},{710,967}},['user-round-search']={16898613869,{48,48}
,{355,918}},['parking-square']={16898613613,{48,48},{967,906}},['paw-print']={16898613699,{48,48},{771,257}},[
'arrow-down-right-square']={16898612629,{48,48},{869,612}},['square-split-vertical']={16898613777,{48,48},{869,453}},[
'circle-off']={16898613044,{48,48},{306,771}},dessert={16898613044,{48,48},{612,967}},eclipse={16898613353,{48,48},{771,
257}},squirrel={16898613777,{48,48},{771,808}},['percent-circle']={16898613699,{48,48},{306,771}},cylinder={16898613044,
{48,48},{869,710}},['badge-japanese-yen']={16898612629,{48,48},{453,918}},['circle-divide']={16898613044,{48,48},{771,
257}},['receipt-text']={16898613699,{48,48},{918,98}},['square-pi']={16898613777,{48,48},{612,918}},[
'align-center-horizontal']={16898612629,{48,48},{98,771}},['phone-off']={16898613699,{48,48},{98,771}},['pi-square']={
16898613699,{48,48},{869,257}},['file-output']={16898613353,{48,48},{661,771}},['disc-album']={16898613044,{48,48},{710,
918}},['percent-square']={16898613699,{48,48},{820,514}},clapperboard={16898613044,{48,48},{257,869}},captions={
16898612819,{48,48},{612,918}},['wallet-minimal']={16898613869,{48,48},{196,918}},layers={16898613509,{48,48},{98,967}},
['umbrella-off']={16898613869,{48,48},{918,306}},['badge-alert']={16898612629,{48,48},{661,918}},[
'arrow-down-left-from-circle']={16898612629,{48,48},{355,869}},['folder-pen']={16898613353,{48,48},{710,869}},cross={
16898613044,{48,48},{869,453}},['alarm-check']={16898612629,{48,48},{49,771}},['chevron-right']={16898612819,{48,48},{
869,759}},pill={16898613699,{48,48},{563,820}},['square-arrow-down-left']={16898613777,{48,48},{820,404}},['share-2']={
16898613777,{48,48},{771,514}},['arrow-up-from-dot']={16898612629,{48,48},{869,661}},['pin-off']={16898613699,{48,48},{
514,869}},['align-vertical-justify-start']={16898612629,{48,48},{918,257}},combine={16898613044,{48,48},{612,869}},[
'tv-2']={16898613869,{48,48},{147,820}},mountain={16898613613,{48,48},{869,612}},cast={16898612819,{48,48},{869,453}},[
'indent-increase']={16898613509,{48,48},{820,661}},currency={16898613044,{48,48},{918,661}},['shield-ban']={16898613777,
{48,48},{0,820}},['message-circle-reply']={16898613613,{48,48},{820,563}},['corner-left-up']={16898613044,{48,48},{612,
918}},['triangle-right']={16898613869,{48,48},{918,49}},['folder-clock']={16898613353,{48,48},{967,98}},link={
16898613509,{48,48},{918,453}},['pound-sterling']={16898613699,{48,48},{514,918}},type={16898613869,{48,48},{967,257}},
webhook={16898613869,{48,48},{967,196}},barcode={16898612629,{48,48},{918,808}},['shopping-bag']={16898613777,{48,48},{
49,820}},bed={16898612819,{48,48},{771,0}},['panel-right-open']={16898613613,{48,48},{869,808}},['pointer-off']={
16898613699,{48,48},{771,661}},turtle={16898613869,{48,48},{196,771}},camera={16898612819,{48,48},{967,563}},scissors={
16898613699,{48,48},{820,857}},['user-minus-2']={16898613869,{48,48},{98,918}},['git-pull-request']={16898613509,{48,48}
,{49,771}},['bluetooth-searching']={16898612819,{48,48},{820,306}},['arrow-up-to-line']={16898612629,{48,48},{196,869}},
drill={16898613044,{48,48},{869,906}},['file-check-2']={16898613353,{48,48},{612,771}},['badge-percent']={16898612629,{
48,48},{967,661}},shuffle={16898613777,{48,48},{257,869}},radiation={16898613699,{48,48},{771,453}},radical={16898613699
,{48,48},{453,771}},microscope={16898613613,{48,48},{771,661}},['message-circle-x']={16898613613,{48,48},{612,771}},box=
{16898612819,{48,48},{771,196}},['align-left']={16898612629,{48,48},{514,869}},['switch-camera']={16898613777,{48,48},{
771,906}},['file-heart']={16898613353,{48,48},{0,918}},cat={16898612819,{48,48},{404,918}},space={16898613777,{48,48},{
563,869}},['rectangle-vertical']={16898613699,{48,48},{147,869}},['clipboard-signature']={16898613044,{48,48},{771,147}}
,['arrow-up-circle']={16898612629,{48,48},{967,563}},['corner-up-left']={16898613044,{48,48},{918,147}},['clock-6']={
16898613044,{48,48},{257,918}},['candlestick-chart']={16898612819,{48,48},{918,612}},['key-round']={16898613509,{48,48},
{967,306}},headphones={16898613509,{48,48},{306,869}},tv={16898613869,{48,48},{98,869}},['book-minus']={16898612819,{48,
48},{0,918}},['bar-chart-horizontal-big']={16898612629,{48,48},{771,906}},rss={16898613699,{48,48},{771,808}},[
'user-round-x']={16898613869,{48,48},{306,967}},highlighter={16898613509,{48,48},{918,49}},['rocking-chair']={
16898613699,{48,48},{869,196}},['square-arrow-out-down-left']={16898613777,{48,48},{355,869}},music={16898613613,{48,48}
,{967,563}},handshake={16898613509,{48,48},{514,869}},['check-circle']={16898612819,{48,48},{869,710}},tornado={
16898613869,{48,48},{771,147}},['copy-plus']={16898613044,{48,48},{355,918}},['folder-git']={16898613353,{48,48},{918,
404}},['triangle-alert']={16898613869,{48,48},{967,0}},shrink={16898613777,{48,48},{355,771}},sofa={16898613777,{48,48},
{661,771}},['school-2']={16898613699,{48,48},{967,453}},['search-check']={16898613699,{48,48},{869,857}},crop={
16898613044,{48,48},{918,404}},['columns-2']={16898613044,{48,48},{820,661}},['mouse-pointer-square']={16898613613,{48,
48},{661,820}},['flask-conical-off']={16898613353,{48,48},{820,453}},milestone={16898613613,{48,48},{612,820}},['wand-2'
]={16898613869,{48,48},{918,453}},['square-dot']={16898613777,{48,48},{918,355}},['badge-minus']={16898612629,{48,48},{
404,967}},['cloud-fog']={16898613044,{48,48},{514,918}},['milk-off']={16898613613,{48,48},{563,869}},bone={16898612819,{
48,48},{869,514}},['percent-diamond']={16898613699,{48,48},{257,820}},['package-check']={16898613613,{48,48},{820,759}},
['chevron-first']={16898612819,{48,48},{147,967}},pencil={16898613699,{48,48},{820,257}},['shield-minus']={16898613777,{
48,48},{257,820}},['list-x']={16898613509,{48,48},{918,759}},['stretch-horizontal']={16898613777,{48,48},{967,661}},[
'panel-left-open']={16898613613,{48,48},{196,967}},['corner-up-right']={16898613044,{48,48},{869,196}},['repeat-2']={
16898613699,{48,48},{869,661}},pin={16898613699,{48,48},{918,0}},['mail-question']={16898613613,{48,48},{771,257}},gift=
{16898613353,{48,48},{820,955}},['badge-indian-rupee']={16898612629,{48,48},{967,404}},smartphone={16898613777,{48,48},{
257,918}},['redo-dot']={16898613699,{48,48},{967,306}},['users-round']={16898613869,{48,48},{563,967}},[
'align-start-horizontal']={16898612629,{48,48},{869,49}},['message-square-warning']={16898613613,{48,48},{771,404}},[
'file-plus']={16898613353,{48,48},{918,49}},['git-pull-request-arrow']={16898613509,{48,48},{257,771}},webcam={
16898613869,{48,48},{710,918}},['arrow-down-to-dot']={16898612629,{48,48},{710,771}},['bell-dot']={16898612819,{48,48},{
771,514}},['folder-down']={16898613353,{48,48},{147,918}},church={16898612819,{48,48},{771,906}},['square-play']={
16898613777,{48,48},{967,98}},['badge-x']={16898612629,{48,48},{710,918}},server={16898613777,{48,48},{771,0}},[
'phone-forwarded']={16898613699,{48,48},{869,0}},diamond={16898613044,{48,48},{196,918}},blinds={16898612819,{48,48},{98
,771}},['user-square']={16898613869,{48,48},{820,710}},package={16898613613,{48,48},{918,196}},['alarm-clock-off']={
16898612629,{48,48},{771,306}},['table-cells-merge']={16898613777,{48,48},{820,906}},['helping-hand']={16898613509,{48,
48},{514,918}},recycle={16898613699,{48,48},{98,918}},['mountain-snow']={16898613613,{48,48},{918,563}},luggage={
16898613509,{48,48},{918,906}},['divide-square']={16898613044,{48,48},{196,967}},['bot-message-square']={16898612819,{48
,48},{918,49}},['phone-outgoing']={16898613699,{48,48},{49,820}},['smartphone-charging']={16898613777,{48,48},{355,820}}
,['panel-left']={16898613613,{48,48},{967,453}},['train-track']={16898613869,{48,48},{355,820}},['bookmark-minus']={
16898612819,{48,48},{661,771}},['tablet-smartphone']={16898613777,{48,48},{967,857}},['fire-extinguisher']={16898613353,
{48,48},{514,967}},sigma={16898613777,{48,48},{820,563}},['shield-half']={16898613777,{48,48},{306,771}},terminal={
16898613869,{48,48},{820,257}},shapes={16898613777,{48,48},{257,771}},['bell-ring']={16898612819,{48,48},{0,820}},[
'tower-control']={16898613869,{48,48},{0,918}},['arrow-down-1-0']={16898612629,{48,48},{820,404}},users={16898613869,{48
,48},{967,98}},scroll={16898613699,{48,48},{918,808}},['arrow-left-right']={16898612629,{48,48},{820,196}},[
'lightbulb-off']={16898613509,{48,48},{967,147}},['panels-top-left']={16898613613,{48,48},{967,808}},beaker={16898612629
,{48,48},{918,906}},['message-square-share']={16898613613,{48,48},{869,306}},annoyed={16898612629,{48,48},{918,514}},[
'test-tube']={16898613869,{48,48},{257,820}},['user-circle']={16898613869,{48,48},{820,196}},['cooking-pot']={
16898613044,{48,48},{820,453}},['between-horizontal-start']={16898612819,{48,48},{306,771}},fullscreen={16898613353,{48,
48},{967,453}},['circuit-board']={16898613044,{48,48},{355,771}},['grid-3x3']={16898613509,{48,48},{98,771}},[
'mail-open']={16898613613,{48,48},{771,0}},['square-function']={16898613777,{48,48},{820,453}},[
'arrow-up-left-from-circle']={16898612629,{48,48},{771,759}},variable={16898613869,{48,48},{147,918}},[
'arrow-up-right-square']={16898612629,{48,48},{967,98}},['pen-line']={16898613699,{48,48},{771,514}}},['256px']={[
'align-vertical-distribute-center']={16898613509,{256,256},{514,0}},['chevron-down']={16898617411,{256,256},{514,257}},[
'list-restart']={16898674572,{256,256},{257,257}},['table-cells-split']={16898787819,{256,256},{514,0}},gavel={
16898672166,{256,256},{514,257}},['dna-off']={16898669271,{256,256},{514,514}},['refresh-ccw-dot']={16898733036,{256,256
},{257,514}},bean={16898615374,{256,256},{257,0}},['arrow-up-right-from-circle']={16898614410,{256,256},{514,257}},[
'table-columns-split']={16898787819,{256,256},{257,257}},bolt={16898615799,{256,256},{0,514}},heater={16898673271,{256,
256},{257,0}},feather={16898669897,{256,256},{0,514}},['align-horizontal-distribute-center']={16898613044,{256,256},{514
,514}},['align-center']={16898613044,{256,256},{0,514}},['grip-vertical']={16898672700,{256,256},{514,0}},[
'person-standing']={16898731539,{256,256},{257,257}},['badge-swiss-franc']={16898615022,{256,256},{514,0}},[
'between-horizontal-end']={16898615428,{256,256},{514,257}},['rotate-cw']={16898733415,{256,256},{514,0}},framer={
16898671684,{256,256},{514,514}},['bus-front']={16898616879,{256,256},{0,514}},['shield-ellipsis']={16898734564,{256,256
},{514,0}},['file-lock-2']={16898670241,{256,256},{0,0}},['between-vertical-end']={16898615428,{256,256},{514,514}},[
'globe-lock']={16898672599,{256,256},{514,0}},tags={16898788033,{256,256},{514,0}},['concierge-bell']={16898619347,{256,
256},{257,0}},['user-square']={16898790047,{256,256},{514,257}},['arrow-left-square']={16898614166,{256,256},{257,257}},
['file-down']={16898670072,{256,256},{514,514}},['picture-in-picture']={16898731683,{256,256},{514,514}},[
'messages-square']={16898728402,{256,256},{257,514}},['touchpad-off']={16898788908,{256,256},{257,0}},['user-round-cog']
={16898789825,{256,256},{257,514}},['chevron-up-circle']={16898617509,{256,256},{514,257}},['server-crash']={16898734242
,{256,256},{514,514}},['heading-3']={16898672954,{256,256},{257,514}},squircle={16898736597,{256,256},{0,514}},[
'wifi-off']={16898790996,{256,256},{257,514}},['sun-medium']={16898736967,{256,256},{514,257}},['message-square']={
16898728402,{256,256},{514,257}},['cloud-download']={16898618763,{256,256},{0,257}},['sigma-square']={16898734792,{256,
256},{257,257}},['folder-plus']={16898671463,{256,256},{257,0}},['hard-drive-download']={16898672829,{256,256},{257,514}
},['scatter-chart']={16898733817,{256,256},{257,257}},pointer={16898732061,{256,256},{514,514}},['circle-alert']={
16898617705,{256,256},{514,0}},['chevrons-up-down']={16898617626,{256,256},{514,257}},['iteration-cw']={16898673616,{256
,256},{0,0}},['rail-symbol']={16898732665,{256,256},{0,514}},['message-circle-more']={16898675752,{256,256},{0,257}},
parentheses={16898731166,{256,256},{257,514}},['book-up-2']={16898616524,{256,256},{0,0}},flame={16898670919,{256,256},{
0,257}},['chevrons-up']={16898617626,{256,256},{257,514}},['chevron-right-square']={16898617509,{256,256},{257,257}},[
'square-mouse-pointer']={16898736237,{256,256},{257,0}},superscript={16898787671,{256,256},{514,0}},tag={16898788033,{
256,256},{0,257}},['file-warning']={16898670620,{256,256},{0,257}},hexagon={16898673271,{256,256},{257,257}},[
'navigation-2-off']={16898730065,{256,256},{257,0}},['eye-off']={16898669772,{256,256},{514,514}},['arrows-up-from-line'
]={16898614574,{256,256},{0,514}},['square-gantt-chart']={16898736072,{256,256},{257,257}},['square-chevron-left']={
16898735845,{256,256},{257,0}},scaling={16898733674,{256,256},{0,514}},['inspection-panel']={16898673523,{256,256},{0,
514}},['arrow-left-from-line']={16898614166,{256,256},{0,257}},['signal-medium']={16898734792,{256,256},{514,514}},[
'ticket-percent']={16898788660,{256,256},{257,514}},['arrow-right-square']={16898614275,{256,256},{257,0}},[
'calendar-clock']={16898616953,{256,256},{0,514}},x={16898791349,{256,256},{257,0}},voicemail={16898790439,{256,256},{
514,514}},presentation={16898732262,{256,256},{257,514}},['tree-palm']={16898789012,{256,256},{0,514}},badge={
16898615022,{256,256},{0,514}},['captions-off']={16898617146,{256,256},{514,514}},['align-vertical-justify-center']={
16898613509,{256,256},{514,257}},theater={16898788479,{256,256},{514,514}},tent={16898788248,{256,256},{257,257}},[
'repeat-1']={16898733146,{256,256},{0,514}},stethoscope={16898736776,{256,256},{257,257}},['screen-share-off']={
16898734065,{256,256},{0,257}},['arrow-big-up']={16898613777,{256,256},{514,514}},['volume-x']={16898790615,{256,256},{0
,257}},['mouse-pointer-click']={16898729337,{256,256},{0,514}},['square-m']={16898736072,{256,256},{257,514}},[
'hard-hat']={16898672954,{256,256},{257,0}},['package-minus']={16898730417,{256,256},{257,514}},['iteration-ccw']={
16898673523,{256,256},{514,514}},pipette={16898731819,{256,256},{257,514}},['flip-horizontal']={16898671019,{256,256},{0
,0}},['alert-circle']={16898613044,{256,256},{0,0}},unplug={16898789644,{256,256},{0,0}},['badge-cent']={16898614755,{
256,256},{514,514}},['check-square-2']={16898617325,{256,256},{514,514}},['monitor-check']={16898728878,{256,256},{257,
257}},trello={16898789012,{256,256},{514,514}},['paintbrush-2']={16898730641,{256,256},{514,257}},[
'bar-chart-horizontal']={16898615143,{256,256},{514,257}},['book-open-text']={16898616322,{256,256},{257,257}},[
'parking-meter']={16898731301,{256,256},{257,0}},cat={16898617325,{256,256},{514,0}},['heart-handshake']={16898673115,{
256,256},{514,257}},trees={16898789012,{256,256},{257,514}},ham={16898672700,{256,256},{257,514}},text={16898788479,{256
,256},{257,514}},['circle-pause']={16898617944,{256,256},{0,514}},['chevron-up-square']={16898617509,{256,256},{257,514}
},rat={16898732665,{256,256},{257,514}},['separator-horizontal']={16898734242,{256,256},{0,514}},ambulance={16898613613,
{256,256},{0,257}},['signal-zero']={16898734905,{256,256},{0,0}},citrus={16898618228,{256,256},{0,0}},['phone-missed']={
16898731539,{256,256},{514,514}},['calendar-off']={16898617053,{256,256},{0,257}},['battery-medium']={16898615240,{256,
256},{0,514}},['square-minus']={16898736237,{256,256},{0,0}},hotel={16898673358,{256,256},{0,257}},['folder-output']={
16898671263,{256,256},{514,514}},['ice-cream']={16898673358,{256,256},{257,514}},menu={16898675673,{256,256},{514,257}},
['arrow-up-left-square']={16898614410,{256,256},{514,0}},['image-down']={16898673358,{256,256},{514,514}},terminal={
16898788248,{256,256},{514,257}},angry={16898613613,{256,256},{514,257}},outdent={16898730417,{256,256},{257,257}},[
'circle-dot-dashed']={16898617884,{256,256},{514,0}},speech={16898735455,{256,256},{257,0}},['cake-slice']={16898616953,
{256,256},{0,0}},['git-graph']={16898672316,{256,256},{514,514}},armchair={16898613777,{256,256},{0,0}},['qr-code']={
16898732504,{256,256},{257,257}},copy={16898619423,{256,256},{257,514}},goal={16898672599,{256,256},{0,514}},[
'trending-down']={16898789153,{256,256},{0,0}},['creative-commons']={16898668482,{256,256},{257,0}},nfc={16898730065,{
256,256},{257,514}},pickaxe={16898731683,{256,256},{514,257}},car={16898617249,{256,256},{514,0}},['notebook-tabs']={
16898730298,{256,256},{0,0}},ear={16898669689,{256,256},{0,257}},videotape={16898790439,{256,256},{514,257}},['sun-moon'
]={16898736967,{256,256},{257,514}},calendar={16898617146,{256,256},{0,0}},['minus-circle']={16898728878,{256,256},{257,
0}},['arrow-down-left-from-circle']={16898613869,{256,256},{0,514}},gift={16898672316,{256,256},{0,0}},[
'message-square-heart']={16898675863,{256,256},{0,514}},['rectangle-ellipsis']={16898733036,{256,256},{0,0}},[
'badge-plus']={16898615022,{256,256},{0,0}},['indian-rupee']={16898673523,{256,256},{0,257}},['monitor-dot']={
16898728878,{256,256},{0,514}},delete={16898668755,{256,256},{514,257}},['clipboard-pen-line']={16898618228,{256,256},{
514,514}},['folder-search']={16898671463,{256,256},{257,257}},['utensils-crossed']={16898790259,{256,256},{257,257}},[
'arrow-up']={16898614574,{256,256},{257,257}},['arrow-up-from-dot']={16898614410,{256,256},{0,0}},['flask-round']={
16898670919,{256,256},{257,514}},pause={16898731301,{256,256},{257,514}},shrub={16898734792,{256,256},{0,257}},flag={
16898670919,{256,256},{0,0}},underline={16898789303,{256,256},{514,257}},['align-horizontal-distribute-end']={
16898613353,{256,256},{0,0}},newspaper={16898730065,{256,256},{514,257}},table={16898787819,{256,256},{257,514}},[
'move-vertical']={16898729752,{256,256},{257,257}},['file-pen-line']={16898670241,{256,256},{514,257}},[
'badge-russian-ruble']={16898615022,{256,256},{0,257}},radius={16898732665,{256,256},{257,257}},['loader-2']={
16898674684,{256,256},{0,257}},pilcrow={16898731819,{256,256},{514,0}},['corner-left-up']={16898668288,{256,256},{257,
257}},spade={16898735175,{256,256},{514,257}},['folder-cog']={16898671139,{256,256},{514,0}},['flip-vertical']={
16898671019,{256,256},{0,257}},['square-arrow-down']={16898735593,{256,256},{257,257}},['circle-plus']={16898617944,{256
,256},{514,514}},view={16898790439,{256,256},{257,514}},cctv={16898617325,{256,256},{257,257}},['more-horizontal']={
16898729337,{256,256},{0,0}},rows={16898733534,{256,256},{257,0}},['pause-octagon']={16898731301,{256,256},{514,257}},[
'circle-arrow-left']={16898617705,{256,256},{0,514}},volume={16898790615,{256,256},{514,0}},facebook={16898669897,{256,
256},{257,0}},['octagon-alert']={16898730298,{256,256},{257,514}},['panel-bottom-dashed']={16898730821,{256,256},{0,257}
},['book-a']={16898615799,{256,256},{514,514}},['align-end-vertical']={16898613044,{256,256},{257,514}},['user-x-2']={
16898790047,{256,256},{257,514}},chrome={16898617626,{256,256},{514,514}},['receipt-japanese-yen']={16898732855,{256,256
},{514,0}},rabbit={16898732504,{256,256},{514,257}},['scissors-square']={16898734065,{256,256},{0,0}},['check-square']={
16898617411,{256,256},{0,0}},['train-front-tunnel']={16898788908,{256,256},{257,514}},['panel-left-dashed']={16898730821
,{256,256},{257,514}},['dice-4']={16898669042,{256,256},{0,514}},['message-circle-x']={16898675752,{256,256},{514,514}},
['folder-x']={16898671684,{256,256},{0,0}},['message-circle-warning']={16898675752,{256,256},{257,514}},map={16898675359
,{256,256},{0,514}},move={16898729752,{256,256},{0,514}},['arrow-up-left']={16898614410,{256,256},{257,257}},award={
16898614755,{256,256},{0,257}},['arrow-down-wide-narrow']={16898614020,{256,256},{257,514}},['unfold-horizontal']={
16898789451,{256,256},{257,0}},['area-chart']={16898613699,{256,256},{514,514}},['music-4']={16898729752,{256,256},{514,
514}},['shield-x']={16898734664,{256,256},{0,0}},['plane-landing']={16898731919,{256,256},{0,0}},['disc-3']={16898669271
,{256,256},{0,257}},['columns-4']={16898619182,{256,256},{514,0}},['archive-x']={16898613699,{256,256},{514,257}},[
'square-dashed-kanban']={16898735845,{256,256},{257,514}},['mouse-pointer-2']={16898729337,{256,256},{257,257}},[
'shield-off']={16898734564,{256,256},{514,257}},compass={16898619182,{256,256},{257,514}},vegan={16898790439,{256,256},{
0,0}},['message-circle-plus']={16898675752,{256,256},{257,257}},['stop-circle']={16898736776,{256,256},{257,514}},nut={
16898730298,{256,256},{514,257}},search={16898734242,{256,256},{257,0}},files={16898670620,{256,256},{514,257}},[
'send-to-back']={16898734242,{256,256},{514,0}},['alarm-clock']={16898612819,{256,256},{257,257}},['shopping-basket']={
16898734664,{256,256},{514,257}},send={16898734242,{256,256},{257,257}},['chevron-left-square']={16898617509,{256,256},{
257,0}},['terminal-square']={16898788248,{256,256},{0,514}},['square-arrow-out-down-left']={16898735593,{256,256},{514,
257}},['skip-back']={16898734905,{256,256},{0,514}},['zoom-in']={16898791349,{256,256},{0,514}},['file-scan']={
16898670367,{256,256},{514,0}},['message-square-dashed']={16898675863,{256,256},{0,257}},trophy={16898789153,{256,256},{
0,514}},umbrella={16898789303,{256,256},{0,514}},touchpad={16898788908,{256,256},{0,257}},['clipboard-copy']={
16898618228,{256,256},{514,0}},['map-pin-off']={16898675359,{256,256},{0,257}},headset={16898673115,{256,256},{257,257}}
,['circle-chevron-up']={16898617803,{256,256},{514,514}},['align-vertical-space-between']={16898613613,{256,256},{257,0}
},['lamp-desk']={16898673794,{256,256},{514,0}},['circle-arrow-up']={16898617803,{256,256},{0,257}},zap={16898791349,{
256,256},{257,257}},['triangle-alert']={16898789153,{256,256},{0,257}},['swiss-franc']={16898787671,{256,256},{0,514}},[
'move-left']={16898729572,{256,256},{514,514}},['chevron-up']={16898617509,{256,256},{514,514}},instagram={16898673523,{
256,256},{514,257}},['pen-tool']={16898731419,{256,256},{514,0}},['pencil-ruler']={16898731419,{256,256},{514,257}},dna=
{16898669433,{256,256},{0,0}},['arrow-big-down-dash']={16898613777,{256,256},{257,0}},['clipboard-edit']={16898618228,{
256,256},{257,257}},mic={16898728659,{256,256},{0,257}},['folder-search-2']={16898671463,{256,256},{514,0}},gitlab={
16898672450,{256,256},{514,514}},['rotate-3d']={16898733317,{256,256},{514,514}},['spell-check']={16898735455,{256,256},
{514,0}},popcorn={16898732262,{256,256},{0,0}},blocks={16898615570,{256,256},{514,514}},['washing-machine']={16898790791
,{256,256},{0,514}},['badge-minus']={16898614945,{256,256},{257,514}},['cloud-sun']={16898618899,{256,256},{0,514}},
circle={16898618049,{256,256},{257,514}},['shield-alert']={16898734564,{256,256},{0,0}},rainbow={16898732665,{256,256},{
514,257}},['separator-vertical']={16898734242,{256,256},{514,257}},ampersands={16898613613,{256,256},{257,257}},[
'user-search']={16898790047,{256,256},{257,257}},fence={16898669897,{256,256},{514,257}},['square-user-round']={
16898736597,{256,256},{257,0}},sunrise={16898787671,{256,256},{257,0}},strikethrough={16898736967,{256,256},{0,257}},[
'calendar-days']={16898616953,{256,256},{514,257}},['dollar-sign']={16898669433,{256,256},{514,0}},puzzle={16898732504,{
256,256},{0,257}},['list-minus']={16898674572,{256,256},{0,0}},['sun-dim']={16898736967,{256,256},{0,514}},upload={
16898789644,{256,256},{0,257}},['app-window-mac']={16898613699,{256,256},{0,257}},ellipsis={16898669772,{256,256},{257,0
}},['copy-check']={16898619423,{256,256},{0,257}},history={16898673271,{256,256},{514,257}},satellite={16898733674,{256,
256},{0,0}},['bookmark-plus']={16898616524,{256,256},{257,514}},['folder-key']={16898671263,{256,256},{514,0}},[
'lamp-ceiling']={16898673794,{256,256},{0,257}},['circle-power']={16898618049,{256,256},{0,0}},hourglass={16898673358,{
256,256},{514,0}},['folder-git']={16898671139,{256,256},{514,514}},bomb={16898615799,{256,256},{514,257}},['layers-2']={
16898673999,{256,256},{514,514}},['battery-full']={16898615240,{256,256},{514,0}},['user-minus']={16898789825,{256,256},
{514,0}},['x-octagon']={16898791187,{256,256},{514,514}},['folder-tree']={16898671463,{256,256},{257,514}},command={
16898619182,{256,256},{514,257}},regex={16898733146,{256,256},{514,0}},hand={16898672829,{256,256},{0,514}},[
'chevrons-down']={16898617626,{256,256},{257,0}},['bluetooth-off']={16898615799,{256,256},{257,0}},['music-2']={
16898729752,{256,256},{514,257}},book={16898616524,{256,256},{257,257}},hammer={16898672700,{256,256},{514,514}},[
'circle-minus']={16898617944,{256,256},{257,0}},['audio-waveform']={16898614755,{256,256},{257,0}},['moon-star']={
16898729141,{256,256},{257,514}},['arrow-down-narrow-wide']={16898613869,{256,256},{514,514}},sparkle={16898735175,{256,
256},{257,514}},wand={16898790791,{256,256},{514,0}},['calendar-minus-2']={16898617053,{256,256},{0,0}},['copy-minus']={
16898619423,{256,256},{514,0}},['folder-input']={16898671263,{256,256},{257,0}},['book-image']={16898616080,{256,256},{
257,514}},shirt={16898734664,{256,256},{257,257}},['server-off']={16898734421,{256,256},{0,0}},['move-up']={16898729752,
{256,256},{514,0}},['plug-2']={16898731919,{256,256},{514,257}},radio={16898732665,{256,256},{514,0}},brackets={
16898616650,{256,256},{514,514}},['calendar-heart']={16898616953,{256,256},{514,514}},['list-ordered']={16898674572,{256
,256},{0,257}},['mic-off']={16898728659,{256,256},{0,0}},['arrow-big-left']={16898613777,{256,256},{257,257}},[
'square-split-horizontal']={16898736398,{256,256},{514,257}},clover={16898619015,{256,256},{0,0}},['sun-snow']={
16898736967,{256,256},{514,514}},['user-2']={16898789644,{256,256},{257,257}},['help-circle']={16898673271,{256,256},{0,
257}},['clock-2']={16898618583,{256,256},{257,0}},['calendar-fold']={16898616953,{256,256},{257,514}},['fish-off']={
16898670775,{256,256},{514,0}},baby={16898614755,{256,256},{0,514}},leaf={16898674337,{256,256},{0,0}},['fold-vertical']
={16898671019,{256,256},{257,514}},hop={16898673358,{256,256},{0,0}},['phone-incoming']={16898731539,{256,256},{257,514}
},cigarette={16898617705,{256,256},{0,257}},minus={16898728878,{256,256},{514,0}},['smile-plus']={16898735040,{256,256},
{514,514}},['folder-edit']={16898671139,{256,256},{514,257}},['star-off']={16898736776,{256,256},{0,0}},[
'git-pull-request-closed']={16898672450,{256,256},{0,257}},['badge-check']={16898614945,{256,256},{0,0}},['test-tube-2']
={16898788248,{256,256},{257,514}},['kanban-square']={16898673616,{256,256},{257,257}},['plug-zap']={16898731919,{256,
256},{514,514}},['heading-4']={16898672954,{256,256},{514,514}},['git-pull-request-create']={16898672450,{256,256},{257,
257}},['replace-all']={16898733146,{256,256},{514,514}},['receipt-swiss-franc']={16898732855,{256,256},{514,257}},[
'square-dashed-bottom-code']={16898735845,{256,256},{0,514}},['clock-7']={16898618583,{256,256},{514,257}},['scan-text']
={16898733817,{256,256},{0,257}},['shower-head']={16898734792,{256,256},{0,0}},['equal-not']={16898669772,{256,256},{0,
257}},['sliders-horizontal']={16898735040,{256,256},{0,257}},['ticket-slash']={16898788789,{256,256},{0,0}},ruler={
16898733534,{256,256},{514,0}},['circle-user-round']={16898618049,{256,256},{257,257}},['list-filter']={16898674482,{256
,256},{514,514}},['alarm-minus']={16898612819,{256,256},{0,514}},['egg-off']={16898669689,{256,256},{257,514}},cog={
16898619015,{256,256},{514,514}},dog={16898669433,{256,256},{0,257}},swords={16898787671,{256,256},{514,514}},[
'panel-right-dashed']={16898731024,{256,256},{514,0}},['ship-wheel']={16898734664,{256,256},{0,257}},bot={16898616650,{
256,256},{514,0}},['trash-2']={16898789012,{256,256},{0,257}},['chevron-down-square']={16898617411,{256,256},{0,514}},[
'panel-left-open']={16898731024,{256,256},{0,0}},['file-symlink']={16898670469,{256,256},{257,0}},['clipboard-paste']={
16898618228,{256,256},{257,514}},['chevron-last']={16898617411,{256,256},{514,514}},['book-heart']={16898616080,{256,256
},{514,257}},['circle-parking']={16898617944,{256,256},{257,257}},['panel-left']={16898731024,{256,256},{257,0}},[
'message-circle-off']={16898675752,{256,256},{514,0}},speaker={16898735455,{256,256},{0,0}},timer={16898788789,{256,256}
,{0,514}},forward={16898671684,{256,256},{514,257}},['file-up']={16898670469,{256,256},{514,257}},[
'between-vertical-start']={16898615570,{256,256},{0,0}},database={16898668755,{256,256},{0,514}},['panel-right']={
16898731024,{256,256},{514,257}},['log-out']={16898674825,{256,256},{257,257}},['git-branch-plus']={16898672316,{256,256
},{257,0}},['shield-half']={16898734564,{256,256},{257,257}},['square-dot']={16898736072,{256,256},{257,0}},[
'arrow-right-circle']={16898614166,{256,256},{257,514}},['table-rows-split']={16898787819,{256,256},{514,257}},watch={
16898790791,{256,256},{514,257}},['cloud-upload']={16898618899,{256,256},{514,257}},['screen-share']={16898734065,{256,
256},{514,0}},drumstick={16898669562,{256,256},{514,514}},['list-checks']={16898674482,{256,256},{0,514}},bug={
16898616879,{256,256},{0,257}},['circle-chevron-left']={16898617803,{256,256},{514,257}},['arrow-down']={16898614166,{
256,256},{0,0}},['arrow-up-down']={16898614275,{256,256},{514,514}},['folder-dot']={16898671139,{256,256},{257,257}},[
'whole-word']={16898790996,{256,256},{514,257}},monitor={16898729141,{256,256},{514,257}},['flag-off']={16898670775,{256
,256},{514,257}},['align-right']={16898613509,{256,256},{0,0}},['circle-stop']={16898618049,{256,256},{514,0}},infinity=
{16898673523,{256,256},{514,0}},['arrow-big-down']={16898613777,{256,256},{0,257}},['circle-parking-off']={16898617944,{
256,256},{514,0}},['calendar-x-2']={16898617053,{256,256},{257,514}},['user-plus']={16898789825,{256,256},{0,514}},[
'move-diagonal-2']={16898729572,{256,256},{0,257}},['gallery-horizontal-end']={16898672004,{256,256},{257,257}},[
'panel-top-dashed']={16898731024,{256,256},{514,514}},['tram-front']={16898789012,{256,256},{257,0}},podcast={
16898732061,{256,256},{514,257}},['audio-lines']={16898614755,{256,256},{0,0}},['flip-vertical-2']={16898671019,{256,256
},{257,0}},github={16898672450,{256,256},{257,514}},['rows-2']={16898733415,{256,256},{257,514}},printer={16898732262,{
256,256},{514,514}},['megaphone-off']={16898675673,{256,256},{257,0}},['file-bar-chart-2']={16898669984,{256,256},{514,
257}},['arrow-big-right']={16898613777,{256,256},{514,257}},['file-clock']={16898670072,{256,256},{0,257}},['toy-brick']
={16898788908,{256,256},{257,257}},['square-chevron-down']={16898735845,{256,256},{0,0}},smartphone={16898735040,{256,
256},{257,514}},drill={16898669562,{256,256},{257,257}},['app-window']={16898613699,{256,256},{514,0}},['shield-check']=
{16898734564,{256,256},{0,257}},['hand-metal']={16898672829,{256,256},{514,0}},['x-circle']={16898791187,{256,256},{257,
514}},['spell-check-2']={16898735455,{256,256},{0,257}},['minus-square']={16898728878,{256,256},{0,257}},['box-select']=
{16898616650,{256,256},{257,257}},['list-plus']={16898674572,{256,256},{514,0}},waypoints={16898790791,{256,256},{514,
514}},['ice-cream-cone']={16898673358,{256,256},{514,257}},['copy-slash']={16898619423,{256,256},{0,514}},wind={
16898791187,{256,256},{0,0}},['layout-panel-left']={16898674182,{256,256},{0,514}},pill={16898731819,{256,256},{257,257}
},grip={16898672700,{256,256},{257,257}},['square-x']={16898736597,{256,256},{514,0}},italic={16898673523,{256,256},{257
,514}},['step-forward']={16898736776,{256,256},{514,0}},['a-arrow-down']={16898612629,{256,256},{0,0}},container={
16898619347,{256,256},{257,514}},sticker={16898736776,{256,256},{0,514}},['parking-circle-off']={16898731166,{256,256},{
514,514}},import={16898673447,{256,256},{514,257}},bird={16898615570,{256,256},{257,257}},['square-terminal']={
16898736597,{256,256},{0,0}},gem={16898672166,{256,256},{257,514}},beef={16898615374,{256,256},{0,514}},['ticket-x']={
16898788789,{256,256},{257,0}},['timer-reset']={16898788789,{256,256},{257,257}},['monitor-stop']={16898729141,{256,256}
,{514,0}},smile={16898735175,{256,256},{0,0}},['signpost-big']={16898734905,{256,256},{0,257}},cloudy={16898618899,{256,
256},{514,514}},['square-percent']={16898736237,{256,256},{0,514}},['navigation-off']={16898730065,{256,256},{514,0}},[
'arrow-left']={16898614166,{256,256},{514,257}},['car-taxi-front']={16898617249,{256,256},{0,257}},laugh={16898673999,{
256,256},{257,514}},['x-square']={16898791349,{256,256},{0,0}},['step-back']={16898736776,{256,256},{0,257}},equal={
16898669772,{256,256},{514,0}},megaphone={16898675673,{256,256},{0,257}},['chevron-left']={16898617509,{256,256},{0,257}
},egg={16898669689,{256,256},{514,514}},['video-off']={16898790439,{256,256},{257,257}},['japanese-yen']={16898673616,{
256,256},{257,0}},library={16898674337,{256,256},{257,257}},['file-terminal']={16898670469,{256,256},{0,257}},[
'circle-chevron-down']={16898617803,{256,256},{0,514}},['bell-off']={16898615428,{256,256},{0,257}},['square-library']={
16898736072,{256,256},{514,257}},salad={16898733534,{256,256},{514,257}},['tally-2']={16898788033,{256,256},{0,514}},
sheet={16898734421,{256,256},{257,514}},['circle-check-big']={16898617803,{256,256},{514,0}},['map-pinned']={16898675359
,{256,256},{257,257}},['corner-down-left']={16898668288,{256,256},{257,0}},dribbble={16898669562,{256,256},{514,0}},[
'pilcrow-square']={16898731819,{256,256},{0,257}},['lamp-wall-up']={16898673794,{256,256},{514,257}},['book-dashed']={
16898616080,{256,256},{514,0}},bluetooth={16898615799,{256,256},{514,0}},['tree-pine']={16898789012,{256,256},{514,257}}
,['receipt-indian-rupee']={16898732855,{256,256},{0,257}},['check-circle-2']={16898617325,{256,256},{514,257}},[
'flask-conical']={16898670919,{256,256},{514,257}},['package-search']={16898730641,{256,256},{257,0}},columns={
16898619182,{256,256},{257,257}},['folder-sync']={16898671463,{256,256},{514,257}},fingerprint={16898670775,{256,256},{
257,0}},['arrow-up-narrow-wide']={16898614410,{256,256},{0,514}},frame={16898671684,{256,256},{257,514}},['clock-12']={
16898618583,{256,256},{0,0}},images={16898673447,{256,256},{0,514}},lollipop={16898674825,{256,256},{0,514}},[
'folder-root']={16898671463,{256,256},{0,257}},['arrow-left-circle']={16898614166,{256,256},{257,0}},['lamp-floor']={
16898673794,{256,256},{257,257}},image={16898673447,{256,256},{257,257}},['badge-euro']={16898614945,{256,256},{0,257}},
bike={16898615570,{256,256},{257,0}},option={16898730417,{256,256},{0,257}},['scroll-text']={16898734065,{256,256},{257,
257}},['toggle-right']={16898788789,{256,256},{257,514}},['ferris-wheel']={16898669897,{256,256},{257,514}},[
'camera-off']={16898617146,{256,256},{257,0}},['function-square']={16898672004,{256,256},{514,0}},group={16898672700,{
256,256},{0,514}},codesandbox={16898619015,{256,256},{514,257}},expand={16898669772,{256,256},{514,257}},['tent-tree']={
16898788248,{256,256},{514,0}},settings={16898734421,{256,256},{514,0}},bitcoin={16898615570,{256,256},{0,514}},[
'thumbs-up']={16898788660,{256,256},{257,257}},['calendar-search']={16898617053,{256,256},{514,257}},['hand-platter']={
16898672829,{256,256},{257,257}},['circle-x']={16898618049,{256,256},{514,257}},['file-diff']={16898670072,{256,256},{
514,257}},['archive-restore']={16898613699,{256,256},{0,514}},['clock-10']={16898618392,{256,256},{257,514}},['dice-1']=
{16898669042,{256,256},{0,257}},['copy-x']={16898619423,{256,256},{514,257}},['folder-open-dot']={16898671263,{256,256},
{514,257}},['axis-3d']={16898614755,{256,256},{257,257}},['arrow-down-1-0']={16898613869,{256,256},{257,0}},[
'clipboard-check']={16898618228,{256,256},{0,257}},['file-x']={16898670620,{256,256},{257,257}},diff={16898669271,{256,
256},{0,0}},dot={16898669433,{256,256},{257,514}},castle={16898617325,{256,256},{0,257}},['power-circle']={16898732262,{
256,256},{514,0}},['fast-forward']={16898669897,{256,256},{257,257}},['mail-minus']={16898675156,{256,256},{257,0}},[
'file-minus-2']={16898670241,{256,256},{0,257}},paintbrush={16898730641,{256,256},{257,514}},cast={16898617325,{256,256}
,{257,0}},['parking-square-off']={16898731301,{256,256},{0,257}},['clipboard-pen']={16898618392,{256,256},{0,0}},[
'settings-2']={16898734421,{256,256},{0,257}},['alarm-clock-off']={16898612819,{256,256},{0,257}},['ice-cream-2']={
16898673358,{256,256},{257,257}},list={16898674684,{256,256},{257,0}},['file-pie-chart']={16898670241,{256,256},{514,514
}},['square-arrow-right']={16898735664,{256,256},{257,0}},['scissors-square-dashed-bottom']={16898733817,{256,256},{514,
514}},['remove-formatting']={16898733146,{256,256},{257,257}},['bookmark-check']={16898616524,{256,256},{0,514}},
cannabis={16898617146,{256,256},{257,514}},['file-plus-2']={16898670367,{256,256},{0,0}},['bookmark-x']={16898616524,{
256,256},{514,514}},['a-arrow-up']={16898612629,{256,256},{257,0}},['chevron-right-circle']={16898617509,{256,256},{514,
0}},caravan={16898617249,{256,256},{257,257}},['file-text']={16898670469,{256,256},{514,0}},['vibrate-off']={16898790439
,{256,256},{0,257}},['mail-check']={16898675156,{256,256},{0,0}},['square-split-vertical']={16898736398,{256,256},{257,
514}},['file-type-2']={16898670469,{256,256},{257,257}},['file-code']={16898670072,{256,256},{257,257}},['file-volume']=
{16898670620,{256,256},{257,0}},['flag-triangle-left']={16898670775,{256,256},{257,514}},['square-equal']={16898736072,{
256,256},{0,257}},['scan-barcode']={16898733674,{256,256},{514,257}},['cassette-tape']={16898617325,{256,256},{0,0}},[
'battery-low']={16898615240,{256,256},{257,257}},['utility-pole']={16898790259,{256,256},{514,257}},folder={16898671684,
{256,256},{257,0}},signpost={16898734905,{256,256},{514,0}},['file-edit']={16898670171,{256,256},{0,0}},['globe-2']={
16898672599,{256,256},{0,257}},landmark={16898673999,{256,256},{0,0}},['fish-symbol']={16898670775,{256,256},{257,257}},
['form-input']={16898671684,{256,256},{0,514}},loader={16898674684,{256,256},{257,257}},bold={16898615799,{256,256},{257
,257}},['dice-2']={16898669042,{256,256},{514,0}},['file-type']={16898670469,{256,256},{0,514}},['book-user']={
16898616524,{256,256},{0,257}},beer={16898615374,{256,256},{257,514}},['gantt-chart-square']={16898672166,{256,256},{0,
257}},ghost={16898672166,{256,256},{514,514}},globe={16898672599,{256,256},{257,257}},['satellite-dish']={16898733534,{
256,256},{514,514}},binary={16898615570,{256,256},{0,257}},['move-diagonal']={16898729572,{256,256},{514,0}},[
'table-cells-merge']={16898787819,{256,256},{0,257}},['door-closed']={16898669433,{256,256},{0,514}},['image-minus']={
16898673447,{256,256},{0,0}},utensils={16898790259,{256,256},{0,514}},['paw-print']={16898731301,{256,256},{514,514}},[
'bar-chart-4']={16898615143,{256,256},{514,0}},['book-x']={16898616524,{256,256},{514,0}},['panel-bottom-close']={
16898730821,{256,256},{257,0}},['hand-heart']={16898672829,{256,256},{257,0}},['file-code-2']={16898670072,{256,256},{
514,0}},['move-down-left']={16898729572,{256,256},{257,257}},indent={16898673523,{256,256},{257,0}},joystick={
16898673616,{256,256},{0,257}},keyboard={16898673794,{256,256},{257,0}},['toggle-left']={16898788789,{256,256},{514,257}
},skull={16898734905,{256,256},{257,514}},['route-off']={16898733415,{256,256},{257,257}},['dice-6']={16898669042,{256,
256},{257,514}},lightbulb={16898674337,{256,256},{514,514}},key={16898673616,{256,256},{514,514}},['clock-11']={
16898618392,{256,256},{514,514}},['list-video']={16898674572,{256,256},{514,514}},['ticket-plus']={16898788660,{256,256}
,{514,514}},['square-dashed-bottom']={16898735845,{256,256},{514,257}},['layout-panel-top']={16898674182,{256,256},{514,
257}},['more-vertical']={16898729337,{256,256},{257,0}},['monitor-pause']={16898728878,{256,256},{514,514}},[
'book-open-check']={16898616322,{256,256},{514,0}},projector={16898732504,{256,256},{0,0}},['lasso-select']={16898673999
,{256,256},{0,514}},maximize={16898675359,{256,256},{514,514}},['text-quote']={16898788479,{256,256},{257,257}},[
'image-up']={16898673447,{256,256},{514,0}},['message-square-quote']={16898728402,{256,256},{0,0}},bus={16898616879,{256
,256},{514,257}},['square-arrow-down-right']={16898735593,{256,256},{514,0}},['bed-single']={16898615374,{256,256},{514,
0}},['list-music']={16898674572,{256,256},{257,0}},['file-spreadsheet']={16898670367,{256,256},{514,514}},['heart-pulse'
]={16898673115,{256,256},{514,514}},['clipboard-list']={16898618228,{256,256},{0,514}},video={16898790439,{256,256},{0,
514}},['contact-round']={16898619347,{256,256},{0,514}},battery={16898615240,{256,256},{257,514}},microscope={
16898728659,{256,256},{514,0}},['message-circle-question']={16898675752,{256,256},{0,514}},['file-badge']={16898669984,{
256,256},{0,514}},['battery-warning']={16898615240,{256,256},{514,257}},['git-pull-request']={16898672450,{256,256},{514
,257}},['arrow-down-from-line']={16898613869,{256,256},{257,257}},briefcase={16898616757,{256,256},{514,257}},biohazard=
{16898615570,{256,256},{514,0}},moon={16898729141,{256,256},{514,514}},['heading-6']={16898673115,{256,256},{257,0}},[
'scale-3d']={16898733674,{256,256},{514,0}},['chevron-down-circle']={16898617411,{256,256},{257,257}},['mail-x']={
16898675156,{256,256},{257,514}},['square-dashed-mouse-pointer']={16898735845,{256,256},{514,514}},['user-cog']={
16898789825,{256,256},{257,0}},['lock-open']={16898674825,{256,256},{257,0}},['mouse-pointer-square-dashed']={
16898729337,{256,256},{514,257}},pizza={16898731819,{256,256},{514,514}},['pc-case']={16898731419,{256,256},{0,0}},[
'arrow-up-wide-narrow']={16898614574,{256,256},{0,257}},['mouse-pointer']={16898729337,{256,256},{514,514}},['clock-5']=
{16898618583,{256,256},{257,257}},dices={16898669042,{256,256},{514,514}},['rotate-ccw']={16898733415,{256,256},{257,0}}
,['align-horizontal-justify-center']={16898613353,{256,256},{0,257}},mouse={16898729572,{256,256},{0,0}},antenna={
16898613613,{256,256},{514,514}},['memory-stick']={16898675673,{256,256},{257,257}},['scan-eye']={16898733674,{256,256},
{257,514}},['bean-off']={16898615374,{256,256},{0,0}},['square-check']={16898735664,{256,256},{514,514}},unlock={
16898789451,{256,256},{514,514}},highlighter={16898673271,{256,256},{0,514}},['loader-circle']={16898674684,{256,256},{
514,0}},['hard-drive-upload']={16898672829,{256,256},{514,514}},['gallery-vertical-end']={16898672004,{256,256},{257,514
}},['menu-square']={16898675673,{256,256},{0,514}},['hand-coins']={16898672829,{256,256},{0,0}},['notepad-text']={
16898730298,{256,256},{257,257}},orbit={16898730417,{256,256},{514,0}},['package-open']={16898730417,{256,256},{514,514}
},clock={16898618763,{256,256},{0,0}},['file-pen']={16898670241,{256,256},{257,514}},['git-compare-arrows']={16898672316
,{256,256},{0,514}},['cloud-sun-rain']={16898618899,{256,256},{257,257}},['align-horizontal-justify-start']={16898613353
,{256,256},{257,257}},['grid-2x2']={16898672700,{256,256},{0,0}},percent={16898731539,{256,256},{514,0}},vibrate={
16898790439,{256,256},{514,0}},['calendar-plus']={16898617053,{256,256},{257,257}},brain={16898616757,{256,256},{0,257}}
,['arrow-down-z-a']={16898614020,{256,256},{514,514}},bath={16898615240,{256,256},{257,0}},['panel-right-close']={
16898731024,{256,256},{0,257}},['unlink-2']={16898789451,{256,256},{0,514}},paperclip={16898731166,{256,256},{514,257}},
['parking-circle']={16898731301,{256,256},{0,0}},['folder-check']={16898671139,{256,256},{0,0}},['parking-square']={
16898731301,{256,256},{514,0}},['book-key']={16898616080,{256,256},{514,514}},ribbon={16898733317,{256,256},{257,257}},
microwave={16898728659,{256,256},{257,257}},['air-vent']={16898612629,{256,256},{514,257}},['library-big']={16898674337,
{256,256},{0,257}},['file-json']={16898670171,{256,256},{0,514}},['folder-open']={16898671263,{256,256},{257,514}},[
'monitor-off']={16898728878,{256,256},{257,514}},['square-scissors']={16898736398,{256,256},{514,0}},['move-up-left']={
16898729752,{256,256},{257,0}},brush={16898616757,{256,256},{514,514}},['folder-heart']={16898671263,{256,256},{0,0}},
hash={16898672954,{256,256},{0,257}},['arrow-up-1-0']={16898614275,{256,256},{0,514}},['arrow-right']={16898614275,{256,
256},{514,0}},['arrow-up-a-z']={16898614275,{256,256},{514,257}},['badge-x']={16898615022,{256,256},{257,257}},[
'panel-bottom-inactive']={16898730821,{256,256},{514,0}},['file-video-2']={16898670469,{256,256},{257,514}},[
'phone-call']={16898731539,{256,256},{0,514}},construction={16898619347,{256,256},{514,0}},['swatch-book']={16898787671,
{256,256},{257,257}},['receipt-cent']={16898732855,{256,256},{0,0}},['badge-pound-sterling']={16898615022,{256,256},{257
,0}},['folder-archive']={16898671019,{256,256},{514,514}},['folder-symlink']={16898671463,{256,256},{0,514}},[
'columns-3']={16898619182,{256,256},{0,257}},ban={16898615022,{256,256},{257,514}},['message-square-x']={16898728402,{
256,256},{0,514}},['paint-roller']={16898730641,{256,256},{0,514}},plug={16898732061,{256,256},{0,0}},gamepad={
16898672166,{256,256},{257,0}},['book-minus']={16898616322,{256,256},{0,257}},popsicle={16898732262,{256,256},{257,0}},[
'building-2']={16898616879,{256,256},{514,0}},['circle-slash-2']={16898618049,{256,256},{257,0}},['rectangle-horizontal'
]={16898733036,{256,256},{257,0}},cake={16898616953,{256,256},{257,0}},['cloud-rain']={16898618899,{256,256},{0,257}},[
'maximize-2']={16898675359,{256,256},{257,514}},['redo-2']={16898733036,{256,256},{257,257}},wrench={16898791187,{256,
256},{514,257}},['repeat-2']={16898733146,{256,256},{514,257}},codepen={16898619015,{256,256},{0,514}},reply={
16898733317,{256,256},{0,257}},['flag-triangle-right']={16898670775,{256,256},{514,514}},['rotate-ccw-square']={
16898733415,{256,256},{0,0}},['scan-search']={16898733817,{256,256},{257,0}},bell={16898615428,{256,256},{0,514}},[
'grid-3x3']={16898672700,{256,256},{257,0}},save={16898733674,{256,256},{0,257}},['music-3']={16898729752,{256,256},{257
,514}},focus={16898671019,{256,256},{0,514}},['user-check']={16898789644,{256,256},{514,257}},proportions={16898732504,{
256,256},{257,0}},['alert-octagon']={16898613044,{256,256},{257,0}},plane={16898731919,{256,256},{0,257}},['webhook-off'
]={16898790996,{256,256},{257,0}},carrot={16898617249,{256,256},{0,514}},['square-arrow-left']={16898735593,{256,256},{0
,514}},['file-cog']={16898670072,{256,256},{0,514}},heart={16898673271,{256,256},{0,0}},['scan-face']={16898733674,{256,
256},{514,514}},['folder-down']={16898671139,{256,256},{0,514}},['layout-template']={16898674182,{256,256},{257,514}},
mailbox={16898675359,{256,256},{0,0}},home={16898673271,{256,256},{257,514}},['traffic-cone']={16898788908,{256,256},{
514,257}},scissors={16898734065,{256,256},{257,0}},split={16898735455,{256,256},{257,514}},twitter={16898789303,{256,256
},{0,257}},['locate-off']={16898674684,{256,256},{514,257}},forklift={16898671684,{256,256},{257,257}},[
'square-arrow-out-up-left']={16898735593,{256,256},{514,514}},component={16898619182,{256,256},{514,514}},[
'panels-left-bottom']={16898731166,{256,256},{514,0}},['message-square-diff']={16898675863,{256,256},{514,0}},[
'book-marked']={16898616322,{256,256},{257,0}},['alarm-plus']={16898612819,{256,256},{514,257}},['bluetooth-connected']=
{16898615799,{256,256},{0,0}},unlink={16898789451,{256,256},{514,257}},signal={16898734905,{256,256},{257,0}},slack={
16898734905,{256,256},{514,514}},['file-volume-2']={16898670620,{256,256},{0,0}},['pound-sterling']={16898732262,{256,
256},{0,257}},power={16898732262,{256,256},{514,257}},['skip-forward']={16898734905,{256,256},{514,257}},['m-square']={
16898674825,{256,256},{257,514}},['git-merge']={16898672450,{256,256},{0,0}},['file-box']={16898669984,{256,256},{514,
514}},['align-justify']={16898613353,{256,256},{257,514}},['paint-bucket']={16898730641,{256,256},{257,257}},wallpaper={
16898790791,{256,256},{0,0}},filter={16898670775,{256,256},{0,0}},glasses={16898672599,{256,256},{257,0}},['piggy-bank']
={16898731819,{256,256},{257,0}},['square-play']={16898736237,{256,256},{514,514}},shell={16898734421,{256,256},{514,514
}},['cloud-off']={16898618899,{256,256},{0,0}},['check-check']={16898617325,{256,256},{0,514}},activity={16898612629,{
256,256},{0,514}},axe={16898614755,{256,256},{514,0}},['plane-takeoff']={16898731919,{256,256},{257,0}},snowflake={
16898735175,{256,256},{0,257}},['cloud-rain-wind']={16898618899,{256,256},{257,0}},['square-plus']={16898736398,{256,256
},{0,0}},['dice-5']={16898669042,{256,256},{514,257}},['search-slash']={16898734065,{256,256},{514,514}},['file-axis-3d'
]={16898669984,{256,256},{514,0}},['receipt-euro']={16898732855,{256,256},{257,0}},['square-radical']={16898736398,{256,
256},{0,257}},['cloud-drizzle']={16898618763,{256,256},{514,0}},['bug-play']={16898616879,{256,256},{257,0}},[
'align-vertical-distribute-start']={16898613509,{256,256},{0,514}},layout={16898674182,{256,256},{514,514}},[
'square-stack']={16898736398,{256,256},{514,514}},['tally-5']={16898788033,{256,256},{514,514}},squirrel={16898736597,{
256,256},{514,257}},['pen-square']={16898731419,{256,256},{0,257}},['folder-lock']={16898671263,{256,256},{257,257}},[
'circle-divide']={16898617884,{256,256},{257,0}},['case-sensitive']={16898617249,{256,256},{257,514}},sunset={
16898787671,{256,256},{0,257}},linkedin={16898674482,{256,256},{257,257}},['life-buoy']={16898674337,{256,256},{0,514}},
['circle-play']={16898617944,{256,256},{257,514}},['tally-4']={16898788033,{256,256},{257,514}},['volume-2']={
16898790615,{256,256},{257,0}},['battery-charging']={16898615240,{256,256},{0,257}},['russian-ruble']={16898733534,{256,
256},{257,257}},['wallet-minimal']={16898790615,{256,256},{257,514}},['earth-lock']={16898669689,{256,256},{514,0}},
footprints={16898671684,{256,256},{514,0}},['text-cursor-input']={16898788479,{256,256},{0,257}},building={16898616879,{
256,256},{257,257}},['lock-keyhole-open']={16898674684,{256,256},{514,514}},twitch={16898789303,{256,256},{257,0}},[
'thermometer-sun']={16898788660,{256,256},{257,0}},['switch-camera']={16898787671,{256,256},{514,257}},club={16898619015
,{256,256},{257,0}},['shield-plus']={16898734564,{256,256},{257,514}},['alarm-check']={16898612629,{256,256},{514,514}},
['bell-minus']={16898615428,{256,256},{257,0}},['log-in']={16898674825,{256,256},{514,0}},['bot-message-square']={
16898616650,{256,256},{0,257}},drum={16898669562,{256,256},{257,514}},['arrow-up-z-a']={16898614574,{256,256},{514,0}},
sun={16898787671,{256,256},{0,0}},['layers-3']={16898674182,{256,256},{0,0}},['zoom-out']={16898791349,{256,256},{514,
257}},['file-key']={16898670171,{256,256},{257,514}},tractor={16898788908,{256,256},{0,514}},['school-2']={16898733817,{
256,256},{0,514}},['scissors-line-dashed']={16898733817,{256,256},{257,514}},['text-select']={16898788479,{256,256},{514
,257}},['file-search']={16898670367,{256,256},{0,514}},['unfold-vertical']={16898789451,{256,256},{0,257}},[
'ticket-check']={16898788660,{256,256},{0,514}},pyramid={16898732504,{256,256},{514,0}},['hard-drive']={16898672954,{256
,256},{0,0}},['user-cog-2']={16898789825,{256,256},{0,0}},['refresh-cw-off']={16898733146,{256,256},{0,0}},[
'external-link']={16898669772,{256,256},{257,514}},['picture-in-picture-2']={16898731683,{256,256},{257,514}},[
'file-x-2']={16898670620,{256,256},{514,0}},['flower-2']={16898671019,{256,256},{514,0}},['calendar-x']={16898617053,{
256,256},{514,514}},['user-round-check']={16898789825,{256,256},{514,257}},['user-round']={16898790047,{256,256},{514,0}
},['link-2-off']={16898674482,{256,256},{257,0}},['keyboard-music']={16898673794,{256,256},{0,0}},['star-half']={
16898736597,{256,256},{514,514}},['user-x']={16898790047,{256,256},{514,514}},['code-xml']={16898619015,{256,256},{514,0
}},['trending-up']={16898789153,{256,256},{257,0}},mails={16898675359,{256,256},{257,0}},['brain-cog']={16898616757,{256
,256},{257,0}},tablet={16898788033,{256,256},{0,0}},['users-round']={16898790259,{256,256},{0,257}},pi={16898731683,{256
,256},{257,257}},trash={16898789012,{256,256},{514,0}},dock={16898669433,{256,256},{257,0}},['hdmi-port']={16898672954,{
256,256},{257,257}},braces={16898616650,{256,256},{257,514}},['case-upper']={16898617249,{256,256},{514,514}},['move-3d'
]={16898729572,{256,256},{257,0}},wallet={16898790615,{256,256},{514,514}},croissant={16898668482,{256,256},{514,0}},[
'monitor-speaker']={16898729141,{256,256},{0,257}},waves={16898790791,{256,256},{257,514}},barcode={16898615143,{256,256
},{514,514}},lock={16898674825,{256,256},{0,257}},['wheat-off']={16898790996,{256,256},{257,257}},bed={16898615374,{256,
256},{257,257}},quote={16898732504,{256,256},{0,514}},divide={16898669271,{256,256},{257,514}},grape={16898672599,{256,
256},{514,514}},['play-square']={16898731919,{256,256},{257,257}},['party-popper']={16898731301,{256,256},{257,257}},[
'file-video']={16898670469,{256,256},{514,514}},university={16898789451,{256,256},{257,257}},['user-circle-2']={
16898789644,{256,256},{257,514}},truck={16898789153,{256,256},{514,257}},box={16898616650,{256,256},{0,514}},[
'calendar-range']={16898617053,{256,256},{0,514}},subscript={16898736967,{256,256},{514,0}},['zap-off']={16898791349,{
256,256},{514,0}},['square-check-big']={16898735664,{256,256},{257,514}},['wand-sparkles']={16898790791,{256,256},{0,257
}},['square-chevron-up']={16898735845,{256,256},{514,0}},['circle-ellipsis']={16898617884,{256,256},{0,514}},[
'laptop-minimal']={16898673999,{256,256},{514,0}},['radio-receiver']={16898732665,{256,256},{257,0}},sofa={16898735175,{
256,256},{514,0}},['square-asterisk']={16898735664,{256,256},{0,514}},wine={16898791187,{256,256},{0,257}},cookie={
16898619423,{256,256},{0,0}},['message-square-more']={16898675863,{256,256},{514,257}},clapperboard={16898618228,{256,
256},{257,0}},euro={16898669772,{256,256},{0,514}},['dice-3']={16898669042,{256,256},{257,257}},['heart-off']={
16898673115,{256,256},{257,514}},['clipboard-minus']={16898618228,{256,256},{514,257}},info={16898673523,{256,256},{257,
257}},['move-horizontal']={16898729572,{256,256},{257,514}},['file-sliders']={16898670367,{256,256},{257,514}},frown={
16898672004,{256,256},{0,0}},['cloud-hail']={16898618763,{256,256},{0,514}},['cup-soda']={16898668755,{256,256},{0,0}},[
'cable-car']={16898616879,{256,256},{257,514}},['lock-keyhole']={16898674825,{256,256},{0,0}},sword={16898787671,{256,
256},{257,514}},play={16898731919,{256,256},{0,514}},['laptop-2']={16898673999,{256,256},{0,257}},earth={16898669689,{
256,256},{257,257}},slice={16898735040,{256,256},{257,0}},['land-plot']={16898673794,{256,256},{514,514}},milk={
16898728659,{256,256},{257,514}},['circle-user']={16898618049,{256,256},{0,514}},['align-left']={16898613353,{256,256},{
514,514}},['circle-slash']={16898618049,{256,256},{0,257}},contact={16898619347,{256,256},{514,257}},['rotate-cw-square'
]={16898733415,{256,256},{0,257}},atom={16898614574,{256,256},{514,514}},['package-x']={16898730641,{256,256},{0,257}},[
'bed-double']={16898615374,{256,256},{0,257}},anchor={16898613613,{256,256},{0,514}},['circle-dot']={16898617884,{256,
256},{257,257}},['git-commit-horizontal']={16898672316,{256,256},{514,0}},['git-commit-vertical']={16898672316,{256,256}
,{257,257}},['message-circle-code']={16898675673,{256,256},{514,514}},['folder-git-2']={16898671139,{256,256},{257,514}}
,['message-square-code']={16898675863,{256,256},{257,0}},['mail-plus']={16898675156,{256,256},{514,0}},[
'diamond-percent']={16898669042,{256,256},{0,0}},['message-circle-heart']={16898675752,{256,256},{257,0}},[
'arrow-big-left-dash']={16898613777,{256,256},{514,0}},['circle-arrow-out-down-left']={16898617705,{256,256},{514,257}},
dumbbell={16898669689,{256,256},{0,0}},['file-music']={16898670241,{256,256},{257,257}},['alert-triangle']={16898613044,
{256,256},{0,257}},['chevrons-right-left']={16898617626,{256,256},{257,257}},scale={16898733674,{256,256},{257,257}},
eraser={16898669772,{256,256},{257,257}},['flashlight-off']={16898670919,{256,256},{514,0}},['panel-top-open']={
16898731166,{256,256},{257,0}},['cloud-lightning']={16898618763,{256,256},{514,257}},ungroup={16898789451,{256,256},{514
,0}},notebook={16898730298,{256,256},{0,257}},['power-square']={16898732262,{256,256},{0,514}},sprout={16898735593,{256,
256},{0,0}},['square-menu']={16898736072,{256,256},{514,514}},['mic-vocal']={16898728659,{256,256},{257,0}},[
'monitor-smartphone']={16898729141,{256,256},{257,0}},laptop={16898673999,{256,256},{257,257}},['scan-line']={
16898733817,{256,256},{0,0}},['clock-4']={16898618583,{256,256},{514,0}},['square-arrow-up']={16898735664,{256,256},{257
,257}},copyright={16898668288,{256,256},{0,0}},['monitor-up']={16898729141,{256,256},{257,257}},['unlock-keyhole']={
16898789451,{256,256},{257,514}},usb={16898789644,{256,256},{514,0}},rocket={16898733317,{256,256},{0,514}},[
'arrow-down-to-line']={16898614020,{256,256},{0,514}},['book-plus']={16898616322,{256,256},{514,257}},['refresh-ccw']={
16898733036,{256,256},{514,514}},['venetian-mask']={16898790439,{256,256},{257,0}},['calendar-check-2']={16898616953,{
256,256},{514,0}},['arrow-down-square']={16898614020,{256,256},{514,0}},spline={16898735455,{256,256},{257,257}},mail={
16898675156,{256,256},{514,514}},['git-pull-request-create-arrow']={16898672450,{256,256},{514,0}},['library-square']={
16898674337,{256,256},{514,0}},['circle-check']={16898617803,{256,256},{257,257}},['square-arrow-up-right']={16898735664
,{256,256},{514,0}},['book-text']={16898616322,{256,256},{257,514}},user={16898790259,{256,256},{0,0}},['file-key-2']={
16898670171,{256,256},{514,257}},['gallery-horizontal']={16898672004,{256,256},{0,514}},['circle-chevron-right']={
16898617803,{256,256},{257,514}},['timer-off']={16898788789,{256,256},{514,0}},['arrow-big-right-dash']={16898613777,{
256,256},{0,514}},['wallet-2']={16898790615,{256,256},{0,514}},cloud={16898618899,{256,256},{257,514}},triangle={
16898789153,{256,256},{257,257}},backpack={16898614755,{256,256},{514,257}},lamp={16898673794,{256,256},{257,514}},
flower={16898671019,{256,256},{257,257}},youtube={16898791349,{256,256},{0,257}},['upload-cloud']={16898789644,{256,256}
,{257,0}},lasso={16898673999,{256,256},{514,257}},['arrow-down-right']={16898614020,{256,256},{0,257}},sailboat={
16898733534,{256,256},{0,514}},receipt={16898732855,{256,256},{514,514}},['bell-ring']={16898615428,{256,256},{257,257}}
,['heart-crack']={16898673115,{256,256},{0,514}},['tree-deciduous']={16898789012,{256,256},{257,257}},[
'fire-extinguisher']={16898670775,{256,256},{0,257}},['baggage-claim']={16898615022,{256,256},{514,257}},['image-off']={
16898673447,{256,256},{257,0}},['arrow-left-to-line']={16898614166,{256,256},{0,514}},['layout-grid']={16898674182,{256,
256},{514,0}},['pi-square']={16898731683,{256,256},{514,0}},['clock-3']={16898618583,{256,256},{0,257}},[
'square-chevron-right']={16898735845,{256,256},{0,257}},navigation={16898730065,{256,256},{257,257}},['filter-x']={
16898670620,{256,256},{514,514}},['bar-chart-3']={16898615143,{256,256},{0,257}},['map-pin']={16898675359,{256,256},{514
,0}},['arrow-down-right-from-circle']={16898614020,{256,256},{0,0}},['shopping-bag']={16898734664,{256,256},{0,514}},[
'chevron-right']={16898617509,{256,256},{0,514}},['tally-1']={16898788033,{256,256},{257,257}},ampersand={16898613613,{
256,256},{514,0}},['arrow-up-from-line']={16898614410,{256,256},{257,0}},['shopping-cart']={16898734664,{256,256},{257,
514}},['user-minus-2']={16898789825,{256,256},{0,257}},vote={16898790615,{256,256},{257,257}},['alarm-smoke']={
16898612819,{256,256},{257,514}},['file-line-chart']={16898670171,{256,256},{514,514}},['file-input']={16898670171,{256,
256},{514,0}},['clock-8']={16898618583,{256,256},{257,514}},['server-cog']={16898734242,{256,256},{257,514}},[
'cloud-cog']={16898618763,{256,256},{257,0}},blend={16898615570,{256,256},{514,257}},['search-x']={16898734242,{256,256}
,{0,0}},['radio-tower']={16898732665,{256,256},{0,257}},['list-tree']={16898674572,{256,256},{257,514}},droplet={
16898669562,{256,256},{0,514}},['panel-right-open']={16898731024,{256,256},{0,514}},eye={16898669897,{256,256},{0,0}},
siren={16898734905,{256,256},{257,257}},star={16898736776,{256,256},{257,0}},banana={16898615022,{256,256},{514,514}},[
'panel-top']={16898731166,{256,256},{0,257}},donut={16898669433,{256,256},{257,257}},telescope={16898788248,{256,256},{0
,257}},['circle-equal']={16898617884,{256,256},{514,257}},['arrow-up-right']={16898614410,{256,256},{514,514}},
calculator={16898616953,{256,256},{0,257}},magnet={16898674825,{256,256},{514,514}},crown={16898668482,{256,256},{257,
514}},subtitles={16898736967,{256,256},{257,257}},['brick-wall']={16898616757,{256,256},{514,0}},[
'message-circle-dashed']={16898675752,{256,256},{0,0}},['leafy-green']={16898674337,{256,256},{257,0}},[
'message-square-dot']={16898675863,{256,256},{257,257}},['arrow-down-a-z']={16898613869,{256,256},{0,257}},copyleft={
16898619423,{256,256},{514,514}},['monitor-play']={16898729141,{256,256},{0,0}},['text-cursor']={16898788479,{256,256},{
514,0}},['minimize-2']={16898728659,{256,256},{514,514}},disc={16898669271,{256,256},{257,257}},locate={16898674684,{256
,256},{257,514}},cone={16898619347,{256,256},{0,257}},['heading-1']={16898672954,{256,256},{0,514}},['file-image']={
16898670171,{256,256},{0,257}},sparkles={16898735175,{256,256},{514,514}},palette={16898730641,{256,256},{514,514}},[
'user-plus-2']={16898789825,{256,256},{257,257}},['gallery-thumbnails']={16898672004,{256,256},{514,257}},['book-up']={
16898616524,{256,256},{257,0}},cpu={16898668482,{256,256},{0,0}},['split-square-horizontal']={16898735455,{256,256},{0,
514}},['thumbs-down']={16898788660,{256,256},{514,0}},merge={16898675673,{256,256},{257,514}},['circle-dashed']={
16898617884,{256,256},{0,0}},['bar-chart-big']={16898615143,{256,256},{257,257}},['test-tubes']={16898788479,{256,256},{
257,0}},hospital={16898673358,{256,256},{257,0}},haze={16898672954,{256,256},{514,0}},plus={16898732061,{256,256},{514,0
}},['align-vertical-space-around']={16898613613,{256,256},{0,0}},['key-square']={16898673616,{256,256},{257,514}},
palmtree={16898730821,{256,256},{0,0}},['file-audio']={16898669984,{256,256},{0,257}},kanban={16898673616,{256,256},{0,
514}},['sliders-vertical']={16898735040,{256,256},{514,0}},apple={16898613699,{256,256},{257,257}},['wine-off']={
16898791187,{256,256},{257,0}},['check-circle']={16898617325,{256,256},{257,514}},cuboid={16898668482,{256,256},{514,514
}},['square-code']={16898735845,{256,256},{257,257}},['bug-off']={16898616879,{256,256},{0,0}},[
'circle-arrow-out-up-left']={16898617705,{256,256},{514,514}},['corner-right-down']={16898668288,{256,256},{0,514}},[
'plug-zap-2']={16898731919,{256,256},{257,514}},['heading-2']={16898672954,{256,256},{514,257}},['square-activity']={
16898735593,{256,256},{257,0}},['package-plus']={16898730641,{256,256},{0,0}},['cigarette-off']={16898617705,{256,256},{
257,0}},['align-vertical-justify-start']={16898613509,{256,256},{514,514}},['power-off']={16898732262,{256,256},{257,257
}},['undo-2']={16898789303,{256,256},{257,514}},router={16898733415,{256,256},{514,257}},['tower-control']={16898788908,
{256,256},{514,0}},['git-branch']={16898672316,{256,256},{0,257}},shovel={16898734664,{256,256},{514,514}},share={
16898734421,{256,256},{514,257}},['wallet-cards']={16898790615,{256,256},{514,257}},['square-arrow-out-down-right']={
16898735593,{256,256},{257,514}},['circuit-board']={16898618049,{256,256},{514,514}},shield={16898734664,{256,256},{257,
0}},['bar-chart-2']={16898615143,{256,256},{257,0}},['cloud-snow']={16898618899,{256,256},{514,0}},['file-question']={
16898670367,{256,256},{0,257}},['arrow-big-up-dash']={16898613777,{256,256},{257,514}},['folder-closed']={16898671139,{
256,256},{0,257}},['smartphone-nfc']={16898735040,{256,256},{514,257}},network={16898730065,{256,256},{0,514}},[
'file-bar-chart']={16898669984,{256,256},{257,514}},['user-round-x']={16898790047,{256,256},{0,257}},['signal-low']={
16898734792,{256,256},{257,514}},['mail-question']={16898675156,{256,256},{257,257}},['clipboard-plus']={16898618392,{
256,256},{257,0}},['file-minus']={16898670241,{256,256},{514,0}},['list-end']={16898674482,{256,256},{257,514}},torus={
16898788908,{256,256},{0,0}},['arrow-down-left']={16898613869,{256,256},{257,514}},['chevrons-right']={16898617626,{256,
256},{0,514}},['file-badge-2']={16898669984,{256,256},{257,257}},['message-square-reply']={16898728402,{256,256},{257,0}
},['corner-down-right']={16898668288,{256,256},{0,257}},['gauge-circle']={16898672166,{256,256},{257,257}},['users-2']={
16898790259,{256,256},{257,0}},['lamp-wall-down']={16898673794,{256,256},{0,514}},['square-bottom-dashed-scissors']={
16898735664,{256,256},{514,257}},['repeat']={16898733146,{256,256},{257,514}},['ellipsis-vertical']={16898669772,{256,
256},{0,0}},snail={16898735175,{256,256},{257,0}},check={16898617411,{256,256},{257,0}},['square-parking']={16898736237,
{256,256},{514,0}},['align-horizontal-justify-end']={16898613353,{256,256},{514,0}},['mail-search']={16898675156,{256,
256},{0,514}},['align-vertical-distribute-end']={16898613509,{256,256},{257,257}},soup={16898735175,{256,256},{257,257}}
,airplay={16898612629,{256,256},{257,514}},pentagon={16898731419,{256,256},{514,514}},['rocking-chair']={16898733317,{
256,256},{514,257}},['between-horizontal-start']={16898615428,{256,256},{257,514}},['monitor-x']={16898729141,{256,256},
{0,514}},['octagon-pause']={16898730298,{256,256},{514,514}},['square-kanban']={16898736072,{256,256},{0,514}},[
'square-pen']={16898736237,{256,256},{257,257}},['rectangle-vertical']={16898733036,{256,256},{0,257}},[
'panels-right-bottom']={16898731166,{256,256},{257,257}},['gantt-chart']={16898672166,{256,256},{514,0}},octagon={
16898730417,{256,256},{257,0}},ticket={16898788789,{256,256},{0,257}},pocket={16898732061,{256,256},{0,514}},['link-2']=
{16898674482,{256,256},{0,257}},['train-front']={16898788908,{256,256},{514,514}},['spray-can']={16898735455,{256,256},{
514,514}},['arrow-up-0-1']={16898614275,{256,256},{257,257}},album={16898612819,{256,256},{514,514}},replace={
16898733317,{256,256},{0,0}},['move-right']={16898729752,{256,256},{0,0}},['hand-helping']={16898672829,{256,256},{0,257
}},['list-collapse']={16898674482,{256,256},{514,257}},gauge={16898672166,{256,256},{0,514}},store={16898736776,{256,256
},{514,514}},['circle-arrow-down']={16898617705,{256,256},{257,257}},['notebook-pen']={16898730065,{256,256},{514,514}},
['egg-fried']={16898669689,{256,256},{514,257}},ligature={16898674337,{256,256},{514,257}},['sticky-note']={16898736776,
{256,256},{514,257}},['corner-right-up']={16898668288,{256,256},{514,257}},['badge-help']={16898614945,{256,256},{514,0}
},['panel-top-inactive']={16898731166,{256,256},{0,0}},['user-round-plus']={16898790047,{256,256},{0,0}},[
'panel-left-close']={16898730821,{256,256},{514,257}},rewind={16898733317,{256,256},{514,0}},fuel={16898672004,{256,256}
,{257,0}},['divide-circle']={16898669271,{256,256},{0,514}},['square-arrow-out-up-right']={16898735664,{256,256},{0,0}},
['chevrons-down-up']={16898617626,{256,256},{0,0}},['message-square-text']={16898728402,{256,256},{514,0}},[
'user-round-search']={16898790047,{256,256},{257,0}},scan={16898733817,{256,256},{514,0}},['monitor-down']={16898728878,
{256,256},{514,257}},['play-circle']={16898731919,{256,256},{514,0}},['file-digit']={16898670072,{256,256},{257,514}},
slash={16898735040,{256,256},{0,0}},['split-square-vertical']={16898735455,{256,256},{514,257}},aperture={16898613699,{
256,256},{257,0}},['arrow-right-left']={16898614275,{256,256},{0,0}},['helping-hand']={16898673271,{256,256},{514,0}},[
'flask-conical-off']={16898670919,{256,256},{0,514}},['circle-gauge']={16898617884,{256,256},{514,514}},crosshair={
16898668482,{256,256},{514,257}},['move-down-right']={16898729572,{256,256},{0,514}},['text-search']={16898788479,{256,
256},{0,514}},['square-slash']={16898736398,{256,256},{0,514}},sandwich={16898733534,{256,256},{257,514}},factory={
16898669897,{256,256},{0,257}},['chef-hat']={16898617411,{256,256},{0,257}},['arrow-down-to-dot']={16898614020,{256,256}
,{257,257}},['image-plus']={16898673447,{256,256},{0,257}},['file-archive']={16898669984,{256,256},{0,0}},['signal-high'
]={16898734792,{256,256},{514,257}},inbox={16898673447,{256,256},{257,514}},['flip-horizontal-2']={16898670919,{256,256}
,{514,514}},['book-type']={16898616322,{256,256},{514,514}},['file-signature']={16898670367,{256,256},{514,257}},[
'align-horizontal-space-between']={16898613353,{256,256},{514,257}},['bookmark-minus']={16898616524,{256,256},{514,257}}
,['calendar-check']={16898616953,{256,256},{257,257}},['database-zap']={16898668755,{256,256},{257,257}},droplets={
16898669562,{256,256},{514,257}},boxes={16898616650,{256,256},{514,257}},['bell-electric']={16898615428,{256,256},{0,0}}
,['bar-chart']={16898615143,{256,256},{257,514}},['layout-list']={16898674182,{256,256},{257,257}},link={16898674482,{
256,256},{514,0}},['download-cloud']={16898669433,{256,256},{514,514}},['alarm-clock-plus']={16898612819,{256,256},{514,
0}},['circle-dollar-sign']={16898617884,{256,256},{0,257}},['activity-square']={16898612629,{256,256},{257,257}},[
'arrow-up-square']={16898614574,{256,256},{0,0}},['receipt-pound-sterling']={16898732855,{256,256},{257,257}},grab={
16898672599,{256,256},{514,257}},['align-center-horizontal']={16898613044,{256,256},{514,0}},undo={16898789451,{256,256}
,{0,0}},ratio={16898732665,{256,256},{514,514}},minimize={16898728878,{256,256},{0,0}},['user-square-2']={16898790047,{
256,256},{0,514}},heading={16898673115,{256,256},{0,257}},['panel-top-close']={16898731024,{256,256},{257,514}},[
'grip-horizontal']={16898672700,{256,256},{0,257}},['boom-box']={16898616650,{256,256},{257,0}},package={16898730641,{
256,256},{514,0}},['user-round-minus']={16898789825,{256,256},{514,514}},['file-audio-2']={16898669984,{256,256},{257,0}
},['align-end-horizontal']={16898613044,{256,256},{514,257}},mountain={16898729337,{256,256},{514,0}},[
'arrow-down-left-square']={16898613869,{256,256},{514,257}},['folder-kanban']={16898671263,{256,256},{0,257}},[
'octagon-x']={16898730417,{256,256},{0,0}},languages={16898673999,{256,256},{257,0}},['file-json-2']={16898670171,{256,
256},{257,257}},['alarm-clock-check']={16898612819,{256,256},{0,0}},['refresh-cw']={16898733146,{256,256},{257,0}},medal
={16898675673,{256,256},{0,0}},['beer-off']={16898615374,{256,256},{514,257}},['search-code']={16898734065,{256,256},{
257,514}},['square-parking-off']={16898736237,{256,256},{0,257}},['notebook-text']={16898730298,{256,256},{257,0}},[
'arrow-right-to-line']={16898614275,{256,256},{0,257}},['ticket-minus']={16898788660,{256,256},{514,257}},[
'test-tube-diagonal']={16898788248,{256,256},{514,514}},['rows-4']={16898733534,{256,256},{0,0}},['pencil-line']={
16898731419,{256,256},{0,514}},['door-open']={16898669433,{256,256},{514,257}},['arrow-down-circle']={16898613869,{256,
256},{514,0}},['pen-line']={16898731419,{256,256},{257,0}},file={16898670620,{256,256},{0,514}},['git-compare']={
16898672316,{256,256},{514,257}},['pocket-knife']={16898732061,{256,256},{257,257}},['book-copy']={16898616080,{256,256}
,{0,257}},['panel-left-inactive']={16898730821,{256,256},{514,514}},['car-front']={16898617249,{256,256},{257,0}},[
'align-start-horizontal']={16898613509,{256,256},{257,0}},['reply-all']={16898733317,{256,256},{257,0}},[
'cloud-moon-rain']={16898618763,{256,256},{257,514}},['clipboard-type']={16898618392,{256,256},{514,0}},['contact-2']={
16898619347,{256,256},{257,257}},['list-todo']={16898674572,{256,256},{514,257}},tablets={16898788033,{256,256},{257,0}}
,['pie-chart']={16898731819,{256,256},{0,0}},['list-start']={16898674572,{256,256},{0,514}},milestone={16898728659,{256,
256},{0,514}},['a-large-small']={16898612629,{256,256},{0,257}},ship={16898734664,{256,256},{514,0}},['percent-circle']=
{16898731539,{256,256},{0,0}},radiation={16898732504,{256,256},{514,514}},['code-2']={16898619015,{256,256},{0,257}},[
'tablet-smartphone']={16898787819,{256,256},{514,514}},['phone-forwarded']={16898731539,{256,256},{514,257}},[
'gallery-vertical']={16898672004,{256,256},{514,514}},['arrow-right-from-line']={16898614166,{256,256},{514,514}},webcam
={16898790996,{256,256},{0,0}},['square-power']={16898736398,{256,256},{257,0}},['circle-help']={16898617944,{256,256},{
0,0}},['bring-to-front']={16898616757,{256,256},{257,514}},archive={16898613699,{256,256},{257,514}},figma={16898669897,
{256,256},{514,514}},school={16898733817,{256,256},{514,257}},download={16898669562,{256,256},{0,0}},piano={16898731683,
{256,256},{0,514}},['line-chart']={16898674482,{256,256},{0,0}},folders={16898671684,{256,256},{0,257}},['mail-warning']
={16898675156,{256,256},{514,257}},vault={16898790259,{256,256},{514,514}},['pause-circle']={16898731301,{256,256},{0,
514}},['mic-2']={16898728402,{256,256},{514,514}},['chevrons-left-right']={16898617626,{256,256},{0,257}},redo={
16898733036,{256,256},{514,257}},['file-lock']={16898670241,{256,256},{257,0}},radar={16898732504,{256,256},{257,514}},[
'circle-fading-plus']={16898617884,{256,256},{257,514}},workflow={16898791187,{256,256},{514,0}},['undo-dot']={
16898789303,{256,256},{514,514}},target={16898788248,{256,256},{257,0}},['corner-left-down']={16898668288,{256,256},{514
,0}},['indent-increase']={16898673523,{256,256},{0,0}},drama={16898669562,{256,256},{0,257}},['arrow-down-up']={
16898614020,{256,256},{514,257}},baseline={16898615240,{256,256},{0,0}},martini={16898675359,{256,256},{514,257}},
contrast={16898619347,{256,256},{514,514}},['shield-ban']={16898734564,{256,256},{257,0}},syringe={16898787819,{256,256}
,{0,0}},['chevron-left-circle']={16898617509,{256,256},{0,0}},['book-check']={16898616080,{256,256},{257,0}},['nut-off']
={16898730298,{256,256},{0,514}},['book-lock']={16898616322,{256,256},{0,0}},['panel-right-inactive']={16898731024,{256,
256},{257,257}},['briefcase-medical']={16898616757,{256,256},{0,514}},bookmark={16898616650,{256,256},{0,0}},[
'heading-5']={16898673115,{256,256},{0,0}},['align-vertical-justify-end']={16898613509,{256,256},{257,514}},['hop-off']=
{16898673271,{256,256},{514,514}},warehouse={16898790791,{256,256},{257,257}},['plus-square']={16898732061,{256,256},{0,
257}},['drafting-compass']={16898669562,{256,256},{257,0}},['save-all']={16898733674,{256,256},{257,0}},['plus-circle']=
{16898732061,{256,256},{257,0}},['square-sigma']={16898736398,{256,256},{257,257}},['clipboard-signature']={16898618392,
{256,256},{0,257}},['fold-horizontal']={16898671019,{256,256},{514,257}},['notepad-text-dashed']={16898730298,{256,256},
{514,0}},['glass-water']={16898672599,{256,256},{0,0}},['book-headphones']={16898616080,{256,256},{0,514}},[
'credit-card']={16898668482,{256,256},{0,257}},['message-circle']={16898675863,{256,256},{0,0}},['square-pilcrow']={
16898736237,{256,256},{257,514}},radical={16898732665,{256,256},{0,0}},['tally-3']={16898788033,{256,256},{514,257}},[
'panel-bottom-open']={16898730821,{256,256},{257,257}},['kanban-square-dashed']={16898673616,{256,256},{514,0}},[
'book-audio']={16898616080,{256,256},{0,0}},['file-search-2']={16898670367,{256,256},{257,257}},['receipt-russian-ruble'
]={16898732855,{256,256},{0,514}},['square-arrow-up-left']={16898735664,{256,256},{0,257}},['locate-fixed']={16898674684
,{256,256},{0,514}},['clock-9']={16898618583,{256,256},{514,514}},pen={16898731419,{256,256},{257,257}},['navigation-2']
={16898730065,{256,256},{0,257}},['candy-cane']={16898617146,{256,256},{257,257}},['book-open']={16898616322,{256,256},{
0,514}},['user-check-2']={16898789644,{256,256},{0,514}},['gamepad-2']={16898672166,{256,256},{0,0}},['badge-info']={
16898614945,{256,256},{0,514}},wheat={16898790996,{256,256},{0,514}},['roller-coaster']={16898733317,{256,256},{257,514}
},['arrow-down-right-square']={16898614020,{256,256},{257,0}},['shield-minus']={16898734564,{256,256},{0,514}},
thermometer={16898788660,{256,256},{0,257}},dessert={16898668755,{256,256},{257,514}},eclipse={16898669689,{256,256},{0,
514}},church={16898617705,{256,256},{0,0}},combine={16898619182,{256,256},{0,514}},cylinder={16898668755,{256,256},{0,
257}},['badge-japanese-yen']={16898614945,{256,256},{514,257}},['calendar-plus-2']={16898617053,{256,256},{514,0}},[
'receipt-text']={16898732855,{256,256},{257,514}},film={16898670620,{256,256},{257,514}},['book-down']={16898616080,{256
,256},{257,257}},asterisk={16898614574,{256,256},{514,257}},cable={16898616879,{256,256},{514,514}},['file-output']={
16898670241,{256,256},{0,514}},['disc-album']={16898669271,{256,256},{514,0}},['percent-square']={16898731539,{256,256},
{0,257}},['arrow-down-0-1']={16898613869,{256,256},{0,0}},captions={16898617249,{256,256},{0,0}},diameter={16898668755,{
256,256},{514,514}},bone={16898615799,{256,256},{257,514}},['umbrella-off']={16898789303,{256,256},{257,257}},[
'badge-alert']={16898614755,{256,256},{257,514}},flashlight={16898670919,{256,256},{257,257}},['folder-pen']={
16898671463,{256,256},{0,0}},cross={16898668482,{256,256},{0,514}},['badge-dollar-sign']={16898614945,{256,256},{257,0}}
,['ice-cream-bowl']={16898673358,{256,256},{0,514}},worm={16898791187,{256,256},{257,257}},['square-arrow-down-left']={
16898735593,{256,256},{0,257}},['share-2']={16898734421,{256,256},{0,514}},['circle-arrow-out-down-right']={16898617705,
{256,256},{257,514}},['ear-off']={16898669689,{256,256},{257,0}},wifi={16898790996,{256,256},{514,514}},[
'message-square-off']={16898675863,{256,256},{257,514}},['tv-2']={16898789153,{256,256},{514,514}},fish={16898670775,{
256,256},{0,514}},sliders={16898735040,{256,256},{257,257}},['stretch-horizontal']={16898736967,{256,256},{0,0}},
currency={16898668755,{256,256},{257,0}},coffee={16898619015,{256,256},{257,514}},['message-circle-reply']={16898675752,
{256,256},{514,257}},route={16898733415,{256,256},{0,514}},['triangle-right']={16898789153,{256,256},{514,0}},[
'folder-clock']={16898671139,{256,256},{257,0}},['circle-off']={16898617944,{256,256},{0,257}},['message-square-plus']={
16898675863,{256,256},{514,514}},type={16898789303,{256,256},{514,0}},webhook={16898790996,{256,256},{0,257}},[
'candlestick-chart']={16898617146,{256,256},{514,0}},phone={16898731683,{256,256},{0,257}},['package-2']={16898730417,{
256,256},{0,514}},['chevrons-left']={16898617626,{256,256},{514,0}},['pointer-off']={16898732061,{256,256},{257,514}},
turtle={16898789153,{256,256},{257,514}},camera={16898617146,{256,256},{0,257}},['thermometer-snowflake']={16898788660,{
256,256},{0,0}},clipboard={16898618392,{256,256},{0,514}},['send-horizontal']={16898734242,{256,256},{0,257}},[
'bluetooth-searching']={16898615799,{256,256},{0,257}},['arrow-up-to-line']={16898614574,{256,256},{257,0}},['wrap-text'
]={16898791187,{256,256},{0,514}},['file-check-2']={16898670072,{256,256},{0,0}},['badge-percent']={16898614945,{256,256
},{514,514}},shuffle={16898734792,{256,256},{514,0}},refrigerator={16898733146,{256,256},{0,257}},['rows-3']={
16898733415,{256,256},{514,514}},sigma={16898734792,{256,256},{0,514}},['milk-off']={16898728659,{256,256},{514,257}},[
'file-check']={16898670072,{256,256},{257,0}},['pin-off']={16898731819,{256,256},{0,514}},['clock-1']={16898618392,{256,
256},{514,257}},['file-heart']={16898670171,{256,256},{257,0}},beaker={16898615240,{256,256},{514,514}},space={
16898735175,{256,256},{0,514}},users={16898790259,{256,256},{514,0}},['shield-question']={16898734564,{256,256},{514,514
}},['arrow-up-circle']={16898614275,{256,256},{257,514}},['corner-up-left']={16898668288,{256,256},{257,514}},['clock-6'
]={16898618583,{256,256},{0,514}},['layout-dashboard']={16898674182,{256,256},{0,257}},['key-round']={16898673616,{256,
256},{514,257}},headphones={16898673115,{256,256},{514,0}},tv={16898789303,{256,256},{0,0}},['brain-circuit']={
16898616757,{256,256},{0,0}},['bar-chart-horizontal-big']={16898615143,{256,256},{0,514}},rss={16898733534,{256,256},{0,
257}},['file-stack']={16898670469,{256,256},{0,0}},['at-sign']={16898614574,{256,256},{257,514}},code={16898619015,{256,
256},{257,257}},['calendar-minus']={16898617053,{256,256},{257,0}},music={16898730065,{256,256},{0,0}},handshake={
16898672829,{256,256},{514,257}},['graduation-cap']={16898672599,{256,256},{257,514}},tornado={16898788789,{256,256},{
514,514}},['copy-plus']={16898619423,{256,256},{257,257}},stamp={16898736597,{256,256},{257,514}},cherry={16898617411,{
256,256},{514,0}},shrink={16898734792,{256,256},{257,0}},['circle-arrow-out-up-right']={16898617803,{256,256},{0,0}},meh
={16898675673,{256,256},{514,0}},['search-check']={16898734065,{256,256},{514,257}},crop={16898668482,{256,256},{257,257
}},['columns-2']={16898619182,{256,256},{257,0}},['mouse-pointer-square']={16898729337,{256,256},{257,514}},[
'indent-decrease']={16898673447,{256,256},{514,514}},['align-center-vertical']={16898613044,{256,256},{257,257}},[
'wand-2']={16898790791,{256,256},{257,0}},anvil={16898613699,{256,256},{0,0}},['align-start-vertical']={16898613509,{256
,256},{0,257}},['cloud-fog']={16898618763,{256,256},{257,257}},accessibility={16898612629,{256,256},{514,0}},layers={
16898674182,{256,256},{257,0}},['percent-diamond']={16898731539,{256,256},{257,0}},['package-check']={16898730417,{256,
256},{514,257}},['chevron-first']={16898617411,{256,256},{257,514}},pencil={16898731419,{256,256},{257,514}},[
'database-backup']={16898668755,{256,256},{514,0}},['list-x']={16898674684,{256,256},{0,0}},shapes={16898734421,{256,256
},{257,257}},['move-down']={16898729572,{256,256},{514,257}},['corner-up-right']={16898668288,{256,256},{514,514}},
computer={16898619347,{256,256},{0,0}},pin={16898731819,{256,256},{514,257}},['phone-off']={16898731683,{256,256},{0,0}}
,['clipboard-x']={16898618392,{256,256},{257,257}},fullscreen={16898672004,{256,256},{0,257}},[
'align-horizontal-distribute-start']={16898613353,{256,256},{257,0}},['redo-dot']={16898733036,{256,256},{0,514}},[
'cloud-moon']={16898618763,{256,256},{514,514}},['stretch-vertical']={16898736967,{256,256},{257,0}},[
'message-square-warning']={16898728402,{256,256},{257,257}},['file-plus']={16898670367,{256,256},{257,0}},[
'git-pull-request-arrow']={16898672450,{256,256},{257,0}},guitar={16898672700,{256,256},{514,257}},tangent={16898788248,
{256,256},{0,0}},['bell-dot']={16898615374,{256,256},{514,514}},['panel-bottom']={16898730821,{256,256},{0,514}},[
'flame-kindling']={16898670919,{256,256},{257,0}},['table-2']={16898787819,{256,256},{257,0}},[
'align-horizontal-space-around']={16898613353,{256,256},{0,514}},server={16898734421,{256,256},{257,0}},[
'briefcase-business']={16898616757,{256,256},{257,257}},diamond={16898669042,{256,256},{257,0}},blinds={16898615570,{256
,256},{257,514}},weight={16898790996,{256,256},{514,0}},candy={16898617146,{256,256},{514,257}},['volume-1']={
16898790615,{256,256},{0,0}},['table-properties']={16898787819,{256,256},{0,514}},['git-fork']={16898672316,{256,256},{
257,514}},recycle={16898733036,{256,256},{514,0}},['mountain-snow']={16898729337,{256,256},{0,257}},luggage={16898674825
,{256,256},{514,257}},['divide-square']={16898669271,{256,256},{514,257}},['folder-minus']={16898671263,{256,256},{0,514
}},['phone-outgoing']={16898731683,{256,256},{257,0}},['smartphone-charging']={16898735040,{256,256},{0,514}},banknote={
16898615143,{256,256},{0,0}},['train-track']={16898789012,{256,256},{0,0}},['folder-up']={16898671463,{256,256},{514,514
}},['circle-percent']={16898617944,{256,256},{514,257}},['bell-plus']={16898615428,{256,256},{514,0}},fan={16898669897,{
256,256},{514,0}},['disc-2']={16898669271,{256,256},{257,0}},['git-pull-request-draft']={16898672450,{256,256},{0,514}},
coins={16898619182,{256,256},{0,0}},['square-divide']={16898736072,{256,256},{0,0}},scroll={16898734065,{256,256},{0,514
}},['circle-arrow-right']={16898617803,{256,256},{257,0}},['candy-off']={16898617146,{256,256},{0,514}},['square-pi']={
16898736237,{256,256},{514,257}},['arrow-left-right']={16898614166,{256,256},{514,0}},['lightbulb-off']={16898674337,{
256,256},{257,514}},['panels-top-left']={16898731166,{256,256},{0,514}},['move-up-right']={16898729752,{256,256},{0,257}
},['message-square-share']={16898728402,{256,256},{0,257}},annoyed={16898613613,{256,256},{257,514}},['test-tube']={
16898788479,{256,256},{0,0}},['user-circle']={16898789644,{256,256},{514,514}},['cooking-pot']={16898619423,{256,256},{
257,0}},['case-lower']={16898617249,{256,256},{514,257}},['alarm-clock-minus']={16898612819,{256,256},{257,0}},[
'square-user']={16898736597,{256,256},{0,257}},square={16898736597,{256,256},{257,257}},['mail-open']={16898675156,{256,
256},{0,257}},['square-function']={16898736072,{256,256},{514,0}},['arrow-up-left-from-circle']={16898614410,{256,256},{
0,257}},variable={16898790259,{256,256},{257,514}},['arrow-up-right-square']={16898614410,{256,256},{257,514}},[
'badge-indian-rupee']={16898614945,{256,256},{257,257}}}}end)()end,function()local b,c,d=a(3)local e return(function(...
)return{PackageVersion='0.1.3',LucideVersion='0.363.0'}end)()end},{{1,2,{'Lucide'},{{2,2,{'Icons'}},{3,2,{'VersionInfo'}
}}}},'0.4.1','WaxRuntime',string,task,setmetatable,error,next,table,unpack,coroutine,script,type,require,pcall,tostring,
tonumber,_VERSION local v,w,x,y,z,A,B=k.insert,k.remove,k.freeze or function(v)return v end,m.wrap,f.sub,f.match,f.
gmatch if t and z(t,1,4)=='Lune'then local C,D=q(p,'@lune/task')if C and D then g=D end end local C=g and g.defer local
D,E,F,G,H,I,J,K,L=C or function(D,...)y(D)(...)end,{[1]='Folder',[2]='ModuleScript',[3]='Script',[4]='LocalScript',[5]=
'StringValue'},{},{},{},{},{},{},{}local M,N={GetFullName={{},function(M)local N,O=M.Name,M.Parent while O do N=O.Name..
'.'..N O=O.Parent end return N end},GetChildren={{},function(M)local N={}for O in j,L[M]do v(N,O)end return N end},
GetDescendants={{},function(M)local N={}for O in j,L[M]do v(N,O)for P,Q in j,O:GetDescendants()do v(N,Q)end end return N
end},FindFirstChild={{'string','boolean?'},function(M,N,O)local P=L[M]for Q in j,P do if Q.Name==N then return Q end end
if O then for R in j,P do return R:FindFirstChild(N,true)end end end},FindFirstAncestor={{'string'},function(M,N)local O
=M.Parent while O do if O.Name==N then return O end O=O.Parent end end},WaitForChild={{'string','number?'},function(M,N)
return M:FindFirstChild(N)end}},{}for O,P in j,M do local Q,R,S=P[1],P[2],{}for T,U in j,Q do local V,W=A(U,
'^([^%?]+)(%??)')S[T]={V,W}end N[O]=function(V,...)if not L[V]then i("Expected ':' not '.' calling member function "..O,
2)end local W={...}for X,Y in j,S do local Z=W[X]local _,aa,ab=o(Z),Y[1],Y[2]if Z==nil and not ab then i('Argument '..Z
..' missing or nil',3)end if aa~='any'and _~=aa and not(_=='nil'and ab)then i('Argument '..X..' expects type "'..aa..
'", got "'.._..'"',2)end end return R(V,...)end end local function aa(ab,Q,R)local S,T=(h({},{__mode='k'}))
local function U(V)i(V..' is not a valid (virtual) member of '..ab..' "'..Q..'"',3)end local function V(W)i(
'Unable to assign (virtual) property '..W..'. Property is read only',3)end local W,X={},{}X.__metatable=false X.__index=
function(Y,Z)if Z=='ClassName'then return ab elseif Z=='Name'then return Q elseif Z=='Parent'then return R elseif ab==
'StringValue'and Z=='Value'then return T else local _=N[Z]if _ then return _ end end for _ in j,S do if _.Name==Z then
return _ end end U(Z)end X.__newindex=function(Y,Z,_)if Z=='ClassName'then V(Z)elseif Z=='Name'then Q=_ elseif Z==
'Parent'then if _==W then return end if R~=nil then L[R][W]=nil end R=_ if _~=nil then L[_][W]=true end elseif ab==
'StringValue'and Z=='Value'then T=_ else U(Z)end end X.__tostring=function()return Q end h(W,X)L[W]=S if R~=nil then L[R
][W]=true end return W end local function ab(Q,R)local S,T,U,V=Q[1],Q[2],Q[3],Q[4]local W=E[T]local X=U and w(U,1)or W
local Y=aa(W,X,R)F[S]=Y if U then for Z,_ in j,U do Y[Z]=_ end end if V then for Z,_ in j,V do ab(_,Y)end end return Y
end local Q=aa('Folder','['..e..']')for R,S in j,c do ab(S,Q)end for T,U in j,b do local V=F[T]G[V]=U H[V]=T local W=V.
ClassName if W=='LocalScript'or W=='Script'then v(J,V)end end local function V(W)local X,Y=W.ClassName,I[W]if Y and X==
'ModuleScript'then return l(Y)end local Z=G[W]local function _(ac)ac=r(ac)local ad,ae,af=W:GetFullName(),A(ac,
'[^:]+:(%d+): (.+)')if not ae or not u then return ad..':*: '..(af or ac)end ae=s(ae)local ag=H[W]local ah=u[ag]local ai
=ae-ah+1 if ai<0 then ai='?'end return ad..':'..ai..': '..af end if X=='LocalScript'or X=='Script'then local ac,ad=q(Z)
if not ac then i(_(ad),0)end else local ac={q(Z)}local ad=w(ac,1)if not ad then local ae=w(ac,1)i(_(ae),0)end I[W]=ac
return l(ac)end end function a(ac)local ad=F[ac]local function ae(af,...)local ag={q(af,...)}local ah=w(ag,1)if not ah
then i(ag[1],3)end return l(ag)end local af=x(h({},{__index=K,__newindex=function(af,ag,ah)K[ag]=ah end,__len=function()
return#K end,__iter=function()return j,K end}))local ag,ah=x{version=d,envname=e,shared=af,script=n,require=p},ad
local function ai(W,...)local X,Y,Z=o(W),'Attempted to call require with a non-ModuleScript',
'Attempted to call require with self'if X=='table'and L[W]then if W.ClassName~='ModuleScript'then i(Y,2)elseif W==ad
then i(Z,2)end return V(W)elseif X=='string'and z(W,1,1)~='@'then if#W==0 then i(
'Attempted to call require with empty string',2)end local _=ad if z(W,1,1)=='/'then _=Q elseif z(W,1,2)=='./'then W=z(W,
3)end local aj for ak in B(W,'([^/]*)/?')do local al=ak if ak=='..'then al='Parent'end if al~=''then local am=_:
FindFirstChild(al)if not am then local an=_.Parent if an then am=an:FindFirstChild(al)end end if am then _=am elseif ak
~=aj and ak~='init'and ak~='init.server'and ak~='init.client'then i('Virtual script path "'..W..'" not found',2)end end
aj=ak end if _.ClassName~='ModuleScript'then i(Y,2)elseif _==ad then i(Z,2)end return V(_)end return ae(p,W,...)end
return ag,ah,ai end for ac,ad in j,J do D(V,ad)end return V(Q:GetChildren()[1])
end

-- MODULE: packages/spr
modules["packages/spr"] = function()--!strict
---------------------------------------------------------------------
-- spr - Spring-driven motion library
--
-- Copyright (c) 2023 Fractality. All rights reserved.
-- Released under the MIT license.
--
-- Docs & license can be found at https://github.com/Fraktality/spr
--
-- API Summary:
--
-- spr.target(
--    Instance obj,
--    number dampingRatio,
--    number undampedFrequency,
--    dict<string, Variant> targetProperties)
--
--    Animates the given properties towardes the target values,
--    given damping ratio and undamped frequency.
--
--
-- spr.stop(
--    Instance obj[,
--    string property])
--
--    Stops the specified property on an Instance from animating.
--    If no property is specified, all properties of the Instance
--    will stop animating.
--
-- Visualizer: https://www.desmos.com/calculator/rzvw27ljh9
---------------------------------------------------------------------

local STRICT_RUNTIME_TYPES = true -- assert on parameter and property type mismatch
local SLEEP_OFFSET_SQ_LIMIT = (1/3840)^2 -- square of the offset sleep limit
local SLEEP_VELOCITY_SQ_LIMIT = 1e-2^2 -- square of the velocity sleep limit
local SLEEP_ROTATION_OFFSET = math.rad(0.01) -- rad
local SLEEP_ROTATION_VELOCITY = math.rad(0.1) -- rad/s
local EPS = 1e-5 -- epsilon for stability checks around pathological frequency/damping values
local AXIS_MATRIX_EPS = 1e-6 -- epsilon for converting from axis-angle to matrix

local RunService = game:GetService("RunService")

local pi = math.pi
local exp = math.exp
local sin = math.sin
local cos = math.cos
local min = math.min
local sqrt = math.sqrt
local round = math.round

local function magnitudeSq(vec: {number})
	local out = 0
	for _, v in vec do
		out += v^2
	end
	return out
end

local function distanceSq(vec0: {number}, vec1: {number})
	local out = 0
	for i0, v0 in vec0 do
		out += (vec1[i0] - v0)^2
	end
	return out
end

type TypeMetadata<T> = {
	springType: (dampingRatio: number, frequency: number, pos: number, typedat: TypeMetadata<T>, rawTarget: T) -> LinearSpring<T>,
	toIntermediate: (T) -> {number},
	fromIntermediate: ({number}) -> T,
}

-- Spring for an array of linear values
local LinearSpring = {}

type LinearSpring<T> = typeof(setmetatable({} :: {
	d: number,
	f: number,
	g: {number},
	p: {number},
	v: {number},
	typedat: TypeMetadata<T>,
	rawTarget: T,
}, LinearSpring))

do
	LinearSpring.__index = LinearSpring

	function LinearSpring.new<T>(dampingRatio: number, frequency: number, pos: T, rawGoal: T, typedat)
		local linearPos = typedat.toIntermediate(pos)
		return setmetatable(
			{
				d = dampingRatio,
				f = frequency,
				g = linearPos,
				p = linearPos,
				v = table.create(#linearPos, 0),
				typedat = typedat,
				rawGoal = rawGoal
			},
			LinearSpring
		)
	end

	function LinearSpring.setGoal<T>(self, goal: T)
		self.rawGoal = goal
		self.g = self.typedat.toIntermediate(goal)
	end

	function LinearSpring.setDampingRatio<T>(self: LinearSpring<T>, dampingRatio: number)
		self.d = dampingRatio
	end

	function LinearSpring.setFrequency<T>(self: LinearSpring<T>, frequency: number)
		self.f = frequency
	end

	function LinearSpring.canSleep<T>(self)
		if magnitudeSq(self.v) > SLEEP_VELOCITY_SQ_LIMIT then
			return false
		end

		if distanceSq(self.p, self.g) > SLEEP_OFFSET_SQ_LIMIT then
			return false
		end

		return true
	end

	function LinearSpring.step<T>(self: LinearSpring<T>, dt: number)
		-- Advance the spring simulation by dt seconds.
		-- Take the damped harmonic oscillator ODE:
		--    f^2*(X[t] - g) + 2*d*f*X'[t] + X''[t] = 0
		-- Where X[t] is position at time t, g is target position,
		-- f is undamped angular frequency, and d is damping ratio.
		-- Apply constant initial conditions:
		--    X[0] = p0
		--    X'[0] = v0
		-- Solve the IVP to get analytic expressions for X[t] and X'[t].
		-- The solution takes one of three forms for 0<=d<1, d=1, and d>1

		local d = self.d
		local f = self.f*2*pi -- Hz -> Rad/s
		local g = self.g
		local p = self.p
		local v = self.v

		if d == 1 then -- critically damped
			local q = exp(-f*dt)
			local w = dt*q

			local c0 = q + w*f
			local c2 = q - w*f
			local c3 = w*f*f

			for idx = 1, #p do
				local o = p[idx] - g[idx]
				p[idx] = o*c0 + v[idx]*w + g[idx]
				v[idx] = v[idx]*c2 - o*c3
			end

		elseif d < 1 then -- underdamped
			local q = exp(-d*f*dt)
			local c = sqrt(1 - d*d)

			local i = cos(dt*f*c)
			local j = sin(dt*f*c)

			-- Damping ratios approaching 1 can cause division by very small numbers.
			-- To mitigate that, group terms around z=j/c and find an approximation for z.
			-- Start with the definition of z:
			--    z = sin(dt*f*c)/c
			-- Substitute a=dt*f:
			--    z = sin(a*c)/c
			-- Take the Maclaurin expansion of z with respect to c:
			--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
			--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120
			-- Rewrite in Horner form:
			--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

			local z
			if c > EPS then
				z = j/c
			else
				local a = dt*f
				z = a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6
			end

			-- Frequencies approaching 0 present a similar problem.
			-- We want an approximation for y as f approaches 0, where:
			--    y = sin(dt*f*c)/(f*c)
			-- Substitute b=dt*c:
			--    y = sin(b*c)/b
			-- Now reapply the process from z.

			local y
			if f*c > EPS then
				y = j/(f*c)
			else
				local b = f*c
				y = dt + ((dt*dt)*(b*b)*(b*b)/20 - b*b)*(dt*dt*dt)/6
			end

			for idx = 1, #p do
				local o = p[idx] - g[idx]
				p[idx] = (o*(i + z*d) + v[idx]*y)*q + g[idx]
				v[idx] = (v[idx]*(i - z*d) - o*(z*f))*q
			end

		else -- overdamped
			local c = sqrt(d*d - 1)

			local r1 = -f*(d - c)
			local r2 = -f*(d + c)

			local ec1 = exp(r1*dt)
			local ec2 = exp(r2*dt)

			for idx = 1, #p do
				local o = p[idx] - g[idx]
				local co2 = (v[idx] - o*r1)/(2*f*c)
				local co1 = ec1*(o - co2)

				p[idx] = co1 + co2*ec2 + g[idx]
				v[idx] = co1*r1 + co2*ec2*r2
			end
		end

		return self.typedat.fromIntermediate(self.p)
	end
end

local RotationSpring = {} 

type RotationSpring = typeof(setmetatable({} :: {
	d: number,
	f: number,
	g: CFrame,
	p: CFrame,
	v: Vector3,
}, RotationSpring))

do
	RotationSpring.__index = RotationSpring

	local function angleBetween(c0: CFrame, c1: CFrame)
		local _, angle = (c1:ToObjectSpace(c0)):ToAxisAngle()
		return math.abs(angle)
	end

	local function matrixToAxis(m: CFrame)
		local axis, angle = m:ToAxisAngle()
		return axis*angle
	end

	local function axisToMatrix(v: Vector3)
		local mag = v.Magnitude
		if mag > AXIS_MATRIX_EPS then
			return CFrame.fromAxisAngle(v.Unit, mag)
		end
		return CFrame.identity
	end

	function RotationSpring.new(d: number, f: number, p: CFrame, g: CFrame)
		return setmetatable(
			{
				d = d,
				f = f,
				g = g,
				p = p,
				v = Vector3.zero
			},
			RotationSpring
		)
	end

	function RotationSpring.setGoal(self: RotationSpring, value: CFrame)
		self.g = value
	end

	function RotationSpring.setDampingRatio(self: RotationSpring, dampingRatio: number)
		self.d = dampingRatio
	end

	function RotationSpring.setFrequency(self: RotationSpring, frequency: number)
		self.f = frequency
	end

	function RotationSpring.canSleep(self: RotationSpring)
		local sleepP = angleBetween(self.p, self.g) < SLEEP_ROTATION_OFFSET
		local sleepV = self.v.Magnitude < SLEEP_ROTATION_VELOCITY
		return sleepP and sleepV
	end

	function RotationSpring.step(self: RotationSpring, dt: number): CFrame
		local d = self.d
		local f = self.f*2*pi
		local g = self.g
		local p0 = self.p
		local v0 = self.v

		local offset = matrixToAxis(p0*g:Inverse())
		local decay = exp(-d*f*dt)

		local pt: CFrame
		local vt: Vector3

		if d == 1 then -- critically damped
			local w = dt*decay

			pt = axisToMatrix((offset*(1 + f*dt) + v0*dt)*decay)*g
			vt = (v0*(1 - dt*f) - offset*(dt*f*f))*decay

		elseif d < 1 then -- underdamped
			local c = sqrt(1 - d*d)

			local i = cos(dt*f*c)
			local j = sin(dt*f*c)

			local y = j/(f*c)
			local z = j/c

			pt = axisToMatrix((offset*(i + z*d) + v0*y)*decay)*g
			vt = (v0*(i - z*d) - offset*(z*f))*decay

		else -- overdamped
			local c = sqrt(d*d - 1)

			local r1 = -f*(d - c)
			local r2 = -f*(d + c)

			local co2 = (v0 - offset*r1)/(2*f*c)
			local co1 = offset - co2

			local e1 = co1*exp(r1*dt)
			local e2 = co2*exp(r2*dt)

			pt = axisToMatrix(e1 + e2)*g
			vt = e1*r1 + e2*r2
		end

		self.p = pt
		self.v = vt

		return pt
	end
end

-- Defined early to be used by CFrameSpring
local typeMetadata_Vector3 = {
	springType = LinearSpring.new,

	toIntermediate = function(value)
		return {value.X, value.Y, value.Z}
	end,

	fromIntermediate = function(value: {number})
		return Vector3.new(value[1], value[2], value[3])
	end,
}

-- Encapsulates a CFrame - Separates translation from rotation
local CFrameSpring = {}
do
	CFrameSpring.__index = CFrameSpring

	function CFrameSpring.new(
		dampingRatio: number,
		frequency: number,
		valueCurrent: CFrame,
		valueGoal: CFrame,
		_: any
	)
		return setmetatable(
			{
				rawGoal = valueGoal,
				_position = LinearSpring.new(dampingRatio, frequency, valueCurrent.Position, valueGoal.Position, typeMetadata_Vector3),
				_rotation = RotationSpring.new(dampingRatio, frequency, valueCurrent.Rotation, valueGoal.Rotation)
			},
			CFrameSpring
		)
	end

	function CFrameSpring:setGoal(value: CFrame)
		self.rawGoal = value
		self._position:setGoal(value.Position)
		self._rotation:setGoal(value.Rotation)
	end

	function CFrameSpring:setDampingRatio(value: number)
		self._position:setDampingRatio(value)
		self._rotation:setDampingRatio(value)
	end

	function CFrameSpring:setFrequency(value: number)
		self._position:setFrequency(value)
		self._rotation:setFrequency(value)
	end

	function CFrameSpring:canSleep()
		return self._position:canSleep() and self._rotation:canSleep()
	end

	function CFrameSpring:step(dt): CFrame
		local p: Vector3 = self._position:step(dt)
		local r: CFrame = self._rotation:step(dt)
		return r + p
	end
end

-- Color conversions
local rgbToLuv
local luvToRgb
do
	local function inverseGammaCorrectD65(c)
		return c < 0.0404482362771076 and c/12.92 or 0.87941546140213*(c + 0.055)^2.4
	end

	local function gammaCorrectD65(c)
		return c < 3.1306684425e-3 and 12.92*c or 1.055*c^(1/2.4) - 0.055
	end

	function rgbToLuv(value: Color3): {number}
		-- convert RGB to a variant of cieluv space
		local r, g, b = value.R, value.G, value.B

		-- D65 sRGB inverse gamma correction
		r = inverseGammaCorrectD65(r)
		g = inverseGammaCorrectD65(g)
		b = inverseGammaCorrectD65(b)

		-- sRGB -> xyz
		local x = 0.9257063972951867*r - 0.8333736323779866*g - 0.09209820666085898*b
		local y = 0.2125862307855956*r + 0.71517030370341085*g + 0.0722004986433362*b
		local z = 3.6590806972265883*r + 11.4426895800574232*g + 4.1149915024264843*b

		-- xyz -> scaled cieluv
		local l = y > 0.008856451679035631 and 116*y^(1/3) - 16 or 903.296296296296*y

		local u, v
		if z > 1e-14 then
			u = l*x/z
			v = l*(9*y/z - 0.46832)
		else
			u = -0.19783*l
			v = -0.46832*l
		end

		return {l, u, v}
	end

	function luvToRgb(value: {number}): Color3
		-- convert back from modified cieluv to rgb space
		local l = value[1]
		if l < 0.0197955 then
			return Color3.new(0, 0, 0)
		end
		local u = value[2]/l + 0.19783
		local v = value[3]/l + 0.46832

		-- cieluv -> xyz
		local y = (l + 16)/116
		y = y > 0.206896551724137931 and y*y*y or 0.12841854934601665*y - 0.01771290335807126
		local x = y*u/v
		local z = y*((3 - 0.75*u)/v - 5)

		-- xyz -> D65 sRGB
		local r =  7.2914074*x - 1.5372080*y - 0.4986286*z
		local g = -2.1800940*x + 1.8757561*y + 0.0415175*z
		local b =  0.1253477*x - 0.2040211*y + 1.0569959*z

		-- clamp minimum sRGB component
		if r < 0 and r < g and r < b then
			r, g, b = 0, g - r, b - r
		elseif g < 0 and g < b then
			r, g, b = r - g, 0, b - g
		elseif b < 0 then
			r, g, b = r - b, g - b, 0
		end

		-- gamma correction from D65
		-- clamp to avoid undesirable overflow wrapping behavior on certain properties (e.g. BasePart.Color)
		return Color3.new(
			min(gammaCorrectD65(r), 1),
			min(gammaCorrectD65(g), 1),
			min(gammaCorrectD65(b), 1)
		)
	end
end

-- Type definitions
-- Transforms Roblox types into intermediate types, converting
-- between spaces as necessary to preserve perceptual linearity
local typeMetadata = {
	boolean = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value and 1 or 0}
		end,

		fromIntermediate = function(value)
			return value[1] >= 0.5
		end,
	},

	number = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value}
		end,

		fromIntermediate = function(value)
			return value[1]
		end,
	},

	NumberRange = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value.Min, value.Max}
		end,

		fromIntermediate = function(value)
			return NumberRange.new(value[1], value[2])
		end,
	},

	UDim = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value.Scale, value.Offset}
		end,

		fromIntermediate = function(value: {number})
			return UDim.new(value[1], round(value[2]))
		end,
	},

	UDim2 = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			local x = value.X
			local y = value.Y
			return {x.Scale, x.Offset, y.Scale, y.Offset}
		end,

		fromIntermediate = function(value: {number})
			return UDim2.new(value[1], round(value[2]), value[3], round(value[4]))
		end,
	},

	Vector2 = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			return {value.X, value.Y}
		end,

		fromIntermediate = function(value: {number})
			return Vector2.new(value[1], value[2])
		end,
	},

	Vector3 = typeMetadata_Vector3,

	Color3 = {
		springType = LinearSpring.new,
		toIntermediate = rgbToLuv,
		fromIntermediate = luvToRgb,
	},

	-- Only interpolates start and end keypoints
	ColorSequence = {
		springType = LinearSpring.new,

		toIntermediate = function(value)
			local keypoints = value.Keypoints

			local luv0 = rgbToLuv(keypoints[1].Value)
			local luv1 = rgbToLuv(keypoints[#keypoints].Value)

			return {
				luv0[1], luv0[2], luv0[3],
				luv1[1], luv1[2], luv1[3],
			}
		end,

		fromIntermediate = function(value: {})
			return ColorSequence.new(
				luvToRgb{value[1], value[2], value[3]},
				luvToRgb{value[4], value[5], value[6]}
			)
		end,
	},

	CFrame = {
		springType = CFrameSpring.new,
		toIntermediate = error, -- custom (CFrameSpring)
		fromIntermediate = error, -- custom (CFrameSpring)
	}
}

type PropertyOverride = {
	[string]: {
		class: string,
		get: (any)->(),
		set: (any, any)->(),
	}
}

local PSEUDO_PROPERTIES: PropertyOverride = {
	Pivot = {
		class = "PVInstance",
		get = function(inst: PVInstance)
			return inst:GetPivot()
		end,
		set = function(inst: PVInstance, value: CFrame)
			inst:PivotTo(value)
		end
	},
	Scale = {
		class = "Model",
		get = function(inst: Model)
			return inst:GetScale()
		end,
		set = function(inst: Model, value: number)
			inst:ScaleTo(value)
		end
	}
}

-- Frame loop
local springStates: {[Instance]: {[string]: any}} = {} -- {[instance] = {[property] = spring}
local completedCallbacks: {[Instance]: {()->()}} = {}

RunService.Heartbeat:Connect(function(dt)
	for instance, state in springStates do
		for propName, spring in state do
			local override = PSEUDO_PROPERTIES[propName]
			
			if override and instance:IsA(override.class) then
				if spring:canSleep() then
					state[propName] = nil
					override.set(instance, spring.rawGoal)
				else
					override.set(instance, spring:step(dt))
				end
			else
				if spring:canSleep() then
					state[propName] = nil
					(instance :: any)[propName] = spring.rawGoal
				else
					(instance :: any)[propName] = spring:step(dt)
				end
			end
		end

		if not next(state) then
			springStates[instance] = nil

			-- trigger completed callbacks when all properties finish animating
			local callbackList = completedCallbacks[instance]
			if callbackList then
				-- flush callback list before we run any callbacks in case
				-- one of the callbacks recursively adds another callback
				completedCallbacks[instance] = nil

				for _, callback in callbackList do
					task.spawn(callback)
				end
			end
		end
	end
end)

-- API
local spr = {}
do
	local function assertType(argNum: number, fnName: string, expectedType: string, value: unknown)
		if not expectedType:find(typeof(value)) then
			error(`bad argument #{argNum} to {fnName} ({expectedType} expected, got {typeof(value)})`, 3)
		end
	end

	function spr.target(instance: Instance, dampingRatio: number, frequency: number, properties: {[string]: any})
		if STRICT_RUNTIME_TYPES then
			assertType(1, "spr.target", "Instance", instance)
			assertType(2, "spr.target", "number", dampingRatio)
			assertType(3, "spr.target", "number", frequency)
			assertType(4, "spr.target", "table", properties)
		end

		if dampingRatio ~= dampingRatio or dampingRatio < 0 then
			error(("expected damping ratio >= 0; got %.2f"):format(dampingRatio), 2)
		end

		if frequency ~= frequency or frequency < 0 then
			error(("expected undamped frequency >= 0; got %.2f"):format(frequency), 2)
		end

		local state = springStates[instance]
		if not state then
			state = {}
			springStates[instance] = state
		end

		for propName, propTarget in properties do
			local propValue
			local override = PSEUDO_PROPERTIES[propName]
			if override and instance:IsA(override.class) then
				propValue = override.get(instance)
			else
				propValue = (instance :: any)[propName]
			end

			if STRICT_RUNTIME_TYPES and typeof(propTarget) ~= typeof(propValue) then
				error(`bad property {propName} to spr.target ({typeof(propValue)} expected, got {typeof(propTarget)})`, 2)
			end

			-- Special case infinite frequency for an instantaneous change
			if frequency == math.huge then
				(instance :: any)[propName] = propTarget
				state[propName] = nil
				continue
			end

			local spring = state[propName]
			if not spring then
				local md = typeMetadata[typeof(propTarget)]
				if not md then
					error("unsupported type: " .. typeof(propTarget), 2)
				end

				spring = md.springType(dampingRatio, frequency, propValue, propTarget, md)
				state[propName] = spring
			end

			spring:setGoal(propTarget)
			spring:setDampingRatio(dampingRatio)
			spring:setFrequency(frequency)
		end

		if not next(state) then
			springStates[instance] = nil
		end
	end

	function spr.stop(instance: Instance, property: string?)
		if STRICT_RUNTIME_TYPES then
			assertType(1, "spr.stop", "Instance", instance)
			assertType(2, "spr.stop", "string|nil", property)
		end

		if property then
			local state = springStates[instance]
			if state then
				state[property] = nil
			end
		else
			springStates[instance] = nil
		end
	end

	function spr.completed(instance: Instance, callback: ()->())
		if STRICT_RUNTIME_TYPES then
			assertType(1, "spr.completed", "Instance", instance)
			assertType(2, "spr.completed", "function", callback)
		end

		local callbackList = completedCallbacks[instance]
		if callbackList then
			table.insert(callbackList, callback)
		else
			completedCallbacks[instance] = {callback}
		end
	end
end

return table.freeze(spr)
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
