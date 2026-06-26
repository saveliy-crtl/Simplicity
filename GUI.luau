local __DARKLUA_BUNDLE_MODULES={cache={}::any}do do local function __modImpl()
local Theme={Background=Color3.fromHex('FFFFFF'),SecondaryBackground=Color3.
fromHex('F5F5F7'),Button=Color3.fromHex('0071E3'),ButtonHover=Color3.fromHex(
'0077ED'),ButtonPressed=Color3.fromHex('006EDB'),TextPrimary=Color3.fromHex(
'1D1D1F'),TextSecondary=Color3.fromHex('6E6E73'),Border=Color3.fromHex('D2D2D7')
,ToggleOn=Color3.fromHex('34C759'),ToggleOff=Color3.fromHex('E5E5EA'),
ToggleHover=Color3.fromHex('D1D1D6'),SliderTrack=Color3.fromHex('E5E5EA'),
SliderFill=Color3.fromHex('0071E3'),Divider=Color3.fromHex('D2D2D7'),CloseButton
=Color3.fromHex('FF3B30'),CloseButtonHover=Color3.fromHex('FF453A'),
CloseButtonPressed=Color3.fromHex('FF2D20')}return Theme end function
__DARKLUA_BUNDLE_MODULES.a():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES
.cache.a if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.a=v end
return v.c end end do local function __modImpl()local Environment={}function
Environment.isExecutor()return type(getgenv)=='function'end function Environment
.isStudio()return not Environment.isExecutor()end function Environment.
getGuiParent()if Environment.isExecutor()then if type(gethui)=='function'then
return gethui()end local coreGui=game:GetService('CoreGui')if coreGui then
return coreGui end end local players=game:GetService('Players')local localPlayer
=players.LocalPlayer or players:WaitForChild('Players').LocalPlayer return
localPlayer:WaitForChild('PlayerGui')end function Environment.getCustomAsset(
name)if type(getcustomasset)=='function'then local success,asset=pcall(
getcustomasset,name)if success and asset then return asset end end return nil
end return Environment end function __DARKLUA_BUNDLE_MODULES.b():typeof(
__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.b if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.b=v end return v.c end end do local 
function __modImpl()local Environment=__DARKLUA_BUNDLE_MODULES.b()local Fonts={}
local interFont=nil function Fonts.getInter()if interFont then return interFont
end local asset=Environment.getCustomAsset('Inter')if asset then interFont=Font.
new(asset)else interFont=Font.new('rbxasset://fonts/families/GothamSSm.json')end
return interFont end return Fonts end function __DARKLUA_BUNDLE_MODULES.c():
typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.c if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.c=v end return v.c end end do local 
function __modImpl()local Utils={}function Utils.create(className,props,children
)local instance=Instance.new(className)if props then for key,value in pairs(
props)do if key~='Parent'then instance[key]=value end end end if children then
for _,child in ipairs(children)do child.Parent=instance end end if props and
props.Parent then instance.Parent=props.Parent end return instance end function
Utils.tween(instance,props,duration,callback)local tweenInfo=TweenInfo.new(
duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)local tween=game:
GetService('TweenService'):Create(instance,tweenInfo,props)if callback then
tween.Completed:Once(callback)end tween:Play()return tween end function Utils.
round(value,decimals)local multiplier=10^(decimals or 0)return math.floor(value*
multiplier+0.5)/multiplier end return Utils end function
__DARKLUA_BUNDLE_MODULES.d():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES
.cache.d if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.d=v end
return v.c end end do local function __modImpl()local Theme=
__DARKLUA_BUNDLE_MODULES.a()local Fonts=__DARKLUA_BUNDLE_MODULES.c()local Utils=
__DARKLUA_BUNDLE_MODULES.d()local Button={}function Button.new(parent,config)
local text=config.Text or'Button'local textSize=config.TextSize or 15 local
callback=config.Callback or function()end local wrapper=Utils.create('Frame',{
Name='ButtonWrapper',BackgroundTransparency=1,Size=UDim2.new(1,0,0,36),
LayoutOrder=config.LayoutOrder or 0,Parent=parent},{Utils.create('UIPadding',{
PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16)})})local button=Utils.
create('TextButton',{Name='Button',BackgroundColor3=Theme.Button,
BackgroundTransparency=0,Size=UDim2.new(1,0,0,36),FontFace=Fonts.getInter(),Text
=text,TextSize=textSize,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,
TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.
Center,Parent=wrapper},{Utils.create('UICorner',{CornerRadius=UDim.new(0.5,0)})}
)button.MouseEnter:Connect(function()Utils.tween(button,{BackgroundColor3=Theme.
ButtonHover},0.15)end)button.MouseLeave:Connect(function()Utils.tween(button,{
BackgroundColor3=Theme.Button},0.15)end)button.InputBegan:Connect(function(input
)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType
==Enum.UserInputType.Touch then Utils.tween(button,{BackgroundColor3=Theme.
ButtonPressed},0.1)end end)button.InputEnded:Connect(function(input)if input.
UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.
UserInputType.Touch then Utils.tween(button,{BackgroundColor3=Theme.ButtonHover}
,0.1)end end)button.Activated:Connect(function()callback()end)local module={}
function module:SetText(newText)button.Text=newText end function module:GetText(
)return button.Text end function module:SetCallback(newCallback)callback=
newCallback end function module:Destroy()wrapper:Destroy()end return module end
return Button end function __DARKLUA_BUNDLE_MODULES.e():typeof(__modImpl())local
v=__DARKLUA_BUNDLE_MODULES.cache.e if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.e=v end return v.c end end do local function 
__modImpl()local Theme=__DARKLUA_BUNDLE_MODULES.a()local Fonts=
__DARKLUA_BUNDLE_MODULES.c()local Utils=__DARKLUA_BUNDLE_MODULES.d()local Toggle
={}function Toggle.new(parent,config)local text=config.Text or'Toggle'local
textSize=config.TextSize or 15 local default=config.Default or false local
callback=config.Callback or function()end local state=default local container=
Utils.create('Frame',{Name='Toggle',BackgroundTransparency=1,Size=UDim2.new(1,0,
0,36),LayoutOrder=config.LayoutOrder or 0,Parent=parent},{Utils.create(
'UIPadding',{PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16)})})local
label=Utils.create('TextLabel',{Name='Label',BackgroundTransparency=1,Size=UDim2
.new(1,-56,1,0),FontFace=Fonts.getInter(),Text=text,TextSize=textSize,TextColor3
=Theme.TextPrimary,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.
TextYAlignment.Center,Parent=container})local toggleBg=Utils.create('TextButton'
,{Name='ToggleBackground',BackgroundColor3=state and Theme.ToggleOn or Theme.
ToggleOff,Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-44,0.5,-12),Text='',
AutoButtonColor=false,Parent=container},{Utils.create('UICorner',{CornerRadius=
UDim.new(0.5,0)})})local knob=Utils.create('Frame',{Name='Knob',BackgroundColor3
=Color3.new(1,1,1),Size=UDim2.new(0,20,0,20),Position=state and UDim2.new(1,-22,
0.5,-10)or UDim2.new(0,2,0.5,-10),Parent=toggleBg},{Utils.create('UICorner',{
CornerRadius=UDim.new(0.5,0)})})local function updateToggle(animate)local
targetColor=state and Theme.ToggleOn or Theme.ToggleOff local targetPos=state
and UDim2.new(1,-22,0.5,-10)or UDim2.new(0,2,0.5,-10)if animate then Utils.
tween(toggleBg,{BackgroundColor3=targetColor},0.2)Utils.tween(knob,{Position=
targetPos},0.2)else toggleBg.BackgroundColor3=targetColor knob.Position=
targetPos end callback(state)end toggleBg.MouseEnter:Connect(function()if not
state then Utils.tween(toggleBg,{BackgroundColor3=Theme.ToggleHover},0.15)end
end)toggleBg.MouseLeave:Connect(function()if not state then Utils.tween(toggleBg
,{BackgroundColor3=Theme.ToggleOff},0.15)end end)toggleBg.Activated:Connect(
function()state=not state updateToggle(true)end)local module={}function module:
SetState(newState,animate)state=newState updateToggle(animate~=false)end
function module:GetState()return state end function module:SetText(newText)label
.Text=newText end function module:SetCallback(newCallback)callback=newCallback
end function module:Destroy()container:Destroy()end return module end return
Toggle end function __DARKLUA_BUNDLE_MODULES.f():typeof(__modImpl())local v=
__DARKLUA_BUNDLE_MODULES.cache.f if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.f=v end return v.c end end do local function 
__modImpl()local Theme=__DARKLUA_BUNDLE_MODULES.a()local Fonts=
__DARKLUA_BUNDLE_MODULES.c()local Utils=__DARKLUA_BUNDLE_MODULES.d()local Slider
={}function Slider.new(parent,config)local text=config.Text or'Slider'local
textSize=config.TextSize or 15 local min=config.Min or 0 local max=config.Max or
100 local default=config.Default or min local suffix=config.Suffix or''local
callback=config.Callback or function()end local value=math.clamp(default,min,max
)local dragging=false local container=Utils.create('Frame',{Name='Slider',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,48),LayoutOrder=config.LayoutOrder
or 0,Parent=parent},{Utils.create('UIPadding',{PaddingLeft=UDim.new(0,16),
PaddingRight=UDim.new(0,16)})})local label=Utils.create('TextLabel',{Name=
'Label',BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),FontFace=Fonts.
getInter(),Text=text,TextSize=textSize,TextColor3=Theme.TextPrimary,
TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.
Center,Parent=container})local valueLabel=Utils.create('TextLabel',{Name=
'ValueLabel',BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),FontFace=Fonts.
getInter(),Text=tostring(Utils.round(value))..suffix,TextSize=textSize,
TextColor3=Theme.TextSecondary,TextXAlignment=Enum.TextXAlignment.Right,
TextYAlignment=Enum.TextYAlignment.Center,Parent=container})local track=Utils.
create('TextButton',{Name='Track',BackgroundColor3=Theme.SliderTrack,Size=UDim2.
new(1,0,0,4),Position=UDim2.new(0,0,1,-8),Text='',AutoButtonColor=false,Parent=
container},{Utils.create('UICorner',{CornerRadius=UDim.new(0.5,0)})})local fill=
Utils.create('Frame',{Name='Fill',BackgroundColor3=Theme.SliderFill,Size=UDim2.
new((value-min)/(max-min),0,1,0),BackgroundTransparency=0,BorderSizePixel=0,
Parent=track},{Utils.create('UICorner',{CornerRadius=UDim.new(0.5,0)})})local
knob=Utils.create('Frame',{Name='Knob',BackgroundColor3=Color3.new(1,1,1),Size=
UDim2.new(0,16,0,16),Position=UDim2.new((value-min)/(max-min),-8,0.5,-8),
BorderSizePixel=0,Parent=track},{Utils.create('UICorner',{CornerRadius=UDim.new(
0.5,0)}),Utils.create('UIStroke',{Color=Theme.Border,Thickness=1,Transparency=0}
)})local function updateValue(newValue)value=math.clamp(Utils.round(newValue),
min,max)local percent=(value-min)/(max-min)fill.Size=UDim2.new(percent,0,1,0)
knob.Position=UDim2.new(percent,-8,0.5,-8)valueLabel.Text=tostring(value)..
suffix callback(value)end local function getValueFromInput(input)local relativeX
=input.Position.X-track.AbsolutePosition.X local percent=math.clamp(relativeX/
track.AbsoluteSize.X,0,1)return min+(max-min)*percent end track.InputBegan:
Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1
or input.UserInputType==Enum.UserInputType.Touch then dragging=true updateValue(
getValueFromInput(input))end end)local userInput=game:GetService(
'UserInputService')userInput.InputChanged:Connect(function(input)if dragging and
(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==
Enum.UserInputType.Touch)then updateValue(getValueFromInput(input))end end)
userInput.InputEnded:Connect(function(input)if input.UserInputType==Enum.
UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=false end end)local module={}function module:SetValue(newValue)
updateValue(newValue)end function module:GetValue()return value end function
module:SetText(newText)label.Text=newText end function module:SetCallback(
newCallback)callback=newCallback end function module:Destroy()container:Destroy(
)end return module end return Slider end function __DARKLUA_BUNDLE_MODULES.g():
typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.g if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.g=v end return v.c end end do local 
function __modImpl()local Theme=__DARKLUA_BUNDLE_MODULES.a()local Fonts=
__DARKLUA_BUNDLE_MODULES.c()local Utils=__DARKLUA_BUNDLE_MODULES.d()local Label=
{}function Label.new(parent,config)local text=config.Text or''local textSize=
config.TextSize or 15 local textColor=config.TextColor or Theme.TextSecondary
local alignment=config.Alignment or Enum.TextXAlignment.Left local label=Utils.
create('TextLabel',{Name='Label',BackgroundTransparency=1,Size=UDim2.new(1,0,0,
textSize+10),FontFace=Fonts.getInter(),Text=text,TextSize=textSize,TextColor3=
textColor,TextXAlignment=alignment,TextYAlignment=Enum.TextYAlignment.Center,
LayoutOrder=config.LayoutOrder or 0,Parent=parent},{Utils.create('UIPadding',{
PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16),PaddingTop=UDim.new(0,4),
PaddingBottom=UDim.new(0,4)})})local module={}function module:SetText(newText)
label.Text=newText end function module:GetText()return label.Text end function
module:Destroy()label:Destroy()end return module end return Label end function
__DARKLUA_BUNDLE_MODULES.h():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES
.cache.h if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.h=v end
return v.c end end do local function __modImpl()local Theme=
__DARKLUA_BUNDLE_MODULES.a()local Utils=__DARKLUA_BUNDLE_MODULES.d()local
Divider={}function Divider.new(parent,layoutOrder)local divider=Utils.create(
'Frame',{Name='Divider',BackgroundColor3=Theme.Divider,BackgroundTransparency=0,
Size=UDim2.new(1,0,0,1),BorderSizePixel=0,LayoutOrder=layoutOrder or 0,Parent=
parent},{Utils.create('UIPadding',{PaddingLeft=UDim.new(0,16),PaddingRight=UDim.
new(0,16)})})local module={}function module:Destroy()divider:Destroy()end return
module end return Divider end function __DARKLUA_BUNDLE_MODULES.i():typeof(
__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.i if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.i=v end return v.c end end do local 
function __modImpl()local Theme=__DARKLUA_BUNDLE_MODULES.a()local Fonts=
__DARKLUA_BUNDLE_MODULES.c()local Utils=__DARKLUA_BUNDLE_MODULES.d()local Input=
{}function Input.new(parent,config)local text=config.Text or'Input'local
textSize=config.TextSize or 15 local placeholder=config.Placeholder or''local
default=config.Default or''local callback=config.Callback or function()end local
container=Utils.create('Frame',{Name='Input',BackgroundTransparency=1,Size=UDim2
.new(1,0,0,36),LayoutOrder=config.LayoutOrder or 0,Parent=parent},{Utils.create(
'UIPadding',{PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16)})})local
label=Utils.create('TextLabel',{Name='Label',BackgroundTransparency=1,Size=UDim2
.new(0,80,1,0),FontFace=Fonts.getInter(),Text=text,TextSize=textSize,TextColor3=
Theme.TextPrimary,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.
TextYAlignment.Center,Parent=container})local inputFrame=Utils.create('Frame',{
Name='InputFrame',BackgroundColor3=Theme.SecondaryBackground,Size=UDim2.new(1,-
88,1,0),Position=UDim2.new(0,88,0,0),BorderSizePixel=0,Parent=container},{Utils.
create('UICorner',{CornerRadius=UDim.new(0,8)}),Utils.create('UIPadding',{
PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})})local textBox=Utils.
create('TextBox',{Name='TextBox',BackgroundTransparency=1,Size=UDim2.new(1,0,1,0
),FontFace=Fonts.getInter(),Text=default,PlaceholderText=placeholder,TextSize=
textSize,TextColor3=Theme.TextPrimary,PlaceholderColor3=Theme.TextSecondary,
TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.
Center,ClearTextOnFocus=false,Parent=inputFrame})textBox.Focused:Connect(
function()Utils.tween(inputFrame,{BackgroundColor3=Color3.fromHex('E8E8ED')},
0.15)end)textBox.FocusLost:Connect(function(enterPressed)Utils.tween(inputFrame,
{BackgroundColor3=Theme.SecondaryBackground},0.15)callback(textBox.Text,
enterPressed)end)local module={}function module:GetValue()return textBox.Text
end function module:SetValue(value)textBox.Text=value end function module:
SetText(newText)label.Text=newText end function module:SetCallback(newCallback)
callback=newCallback end function module:Destroy()container:Destroy()end return
module end return Input end function __DARKLUA_BUNDLE_MODULES.j():typeof(
__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.j if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.j=v end return v.c end end do local 
function __modImpl()local Theme=__DARKLUA_BUNDLE_MODULES.a()local Fonts=
__DARKLUA_BUNDLE_MODULES.c()local Utils=__DARKLUA_BUNDLE_MODULES.d()local
Environment=__DARKLUA_BUNDLE_MODULES.b()local Dropdown={}function Dropdown.new(
parent,config)local text=config.Text or'Dropdown'local textSize=config.TextSize
or 15 local options=config.Options or{}local default=config.Default or(options[1
]or'')local callback=config.Callback or function()end local selected=default
local popup=nil local container=Utils.create('Frame',{Name='Dropdown',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,36),LayoutOrder=config.LayoutOrder
or 0,Parent=parent},{Utils.create('UIPadding',{PaddingLeft=UDim.new(0,16),
PaddingRight=UDim.new(0,16)})})local label=Utils.create('TextLabel',{Name=
'Label',BackgroundTransparency=1,Size=UDim2.new(0,80,0,36),FontFace=Fonts.
getInter(),Text=text,TextSize=textSize,TextColor3=Theme.TextPrimary,
TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.
Center,Parent=container})local dropdownButton=Utils.create('TextButton',{Name=
'DropdownButton',BackgroundColor3=Theme.SecondaryBackground,Size=UDim2.new(1,-88
,0,36),Position=UDim2.new(0,88,0,0),FontFace=Fonts.getInter(),Text=selected,
TextSize=textSize,TextColor3=Theme.TextPrimary,TextXAlignment=Enum.
TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,AutoButtonColor=
false,Parent=container},{Utils.create('UICorner',{CornerRadius=UDim.new(0,8)}),
Utils.create('UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)
})})local arrow=Utils.create('TextLabel',{Name='Arrow',BackgroundTransparency=1,
Size=UDim2.new(0,20,0,36),Position=UDim2.new(1,-20,0,0),FontFace=Fonts.getInter(
),Text='',TextSize=textSize,TextColor3=Theme.TextSecondary,Parent=dropdownButton
})local function destroyPopup()if popup then popup:Destroy()popup=nil end end
local function buildPopup()destroyPopup()local guiParent=Environment.
getGuiParent()local btnPos=dropdownButton.AbsolutePosition local btnSize=
dropdownButton.AbsoluteSize popup=Utils.create('ScreenGui',{Name='DropdownPopup'
,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=guiParent}
)local popupWidth=btnSize.X local popupHeight=math.min(220,44+#options*32)local
popupX=btnPos.X local popupY=btnPos.Y+btnSize.Y+4 local popupFrame=Utils.create(
'Frame',{Name='PopupFrame',BackgroundColor3=Theme.Background,
BackgroundTransparency=0,Size=UDim2.new(0,popupWidth,0,popupHeight),Position=
UDim2.new(0,popupX,0,popupY),BorderSizePixel=0,Parent=popup},{Utils.create(
'UICorner',{CornerRadius=UDim.new(0,12)}),Utils.create('UIStroke',{Color=Theme.
Border,Thickness=1,Transparency=0}),Utils.create('UIShadow',{Color=Color3.new(0,
0,0),Transparency=0.8,BlurRadius=UDim.new(0,12),Offset=UDim2.new(0,0,0,4),Spread
=UDim2.new(0,0,0,0)})})local searchFrame=Utils.create('Frame',{Name=
'SearchFrame',BackgroundColor3=Theme.SecondaryBackground,Size=UDim2.new(1,-16,0,
36),Position=UDim2.new(0,8,0,8),BorderSizePixel=0,Parent=popupFrame},{Utils.
create('UICorner',{CornerRadius=UDim.new(0,8)}),Utils.create('UIPadding',{
PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,4),
PaddingBottom=UDim.new(0,4)})})local searchBox=Utils.create('TextBox',{Name=
'SearchBox',BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),FontFace=Fonts.
getInter(),Text='',PlaceholderText='Search...',TextSize=13,TextColor3=Theme.
TextPrimary,PlaceholderColor3=Theme.TextSecondary,TextXAlignment=Enum.
TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,ClearTextOnFocus=
false,Parent=searchFrame})local scrollFrame=Utils.create('ScrollingFrame',{Name=
'OptionsScroll',BackgroundTransparency=1,Size=UDim2.new(1,-16,1,-52),Position=
UDim2.new(0,8,0,48),ScrollBarThickness=4,ScrollBarImageColor3=Theme.Border,
CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
BorderSizePixel=0,Parent=popupFrame},{Utils.create('UIListLayout',{Padding=UDim.
new(0,2),SortOrder=Enum.SortOrder.LayoutOrder}),Utils.create('UIPadding',{
PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)})})local optionButtons={}
local function rebuildFilteredOptions(filter)for _,btn in ipairs(optionButtons)
do btn:Destroy()end optionButtons={}local order=0 for _,option in ipairs(options
)do local match=true if filter and filter~=''then match=string.find(string.
lower(option),string.lower(filter),1,true)~=nil end if match then order+=1 local
optionBtn=Utils.create('TextButton',{Name='Option',BackgroundColor3=option==
selected and Theme.SecondaryBackground or Theme.Background,
BackgroundTransparency=0,Size=UDim2.new(1,0,0,30),FontFace=Fonts.getInter(),Text
=option,TextSize=textSize,TextColor3=option==selected and Theme.Button or Theme.
TextPrimary,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.
TextYAlignment.Center,AutoButtonColor=false,LayoutOrder=order,Parent=scrollFrame
},{Utils.create('UICorner',{CornerRadius=UDim.new(0,6)}),Utils.create(
'UIPadding',{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})})optionBtn
.MouseEnter:Connect(function()if option~=selected then Utils.tween(optionBtn,{
BackgroundColor3=Theme.SecondaryBackground},0.1)end end)optionBtn.MouseLeave:
Connect(function()if option~=selected then Utils.tween(optionBtn,{
BackgroundColor3=Theme.Background},0.1)end end)optionBtn.Activated:Connect(
function()selected=option dropdownButton.Text=selected callback(selected)
destroyPopup()end)table.insert(optionButtons,optionBtn)end end end
rebuildFilteredOptions('')searchBox:GetPropertyChangedSignal('Text'):Connect(
function()rebuildFilteredOptions(searchBox.Text)end)local userInput=game:
GetService('UserInputService')local inputConn inputConn=userInput.InputBegan:
Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1
then local mousePos=input.Position local framePos=popupFrame.AbsolutePosition
local frameSize=popupFrame.AbsoluteSize if mousePos.X<framePos.X or mousePos.X>
framePos.X+frameSize.X or mousePos.Y<framePos.Y or mousePos.Y>framePos.Y+
frameSize.Y then destroyPopup()inputConn:Disconnect()end end end)popup.
AncestryChanged:Connect(function()if not popup.Parent then if inputConn then
inputConn:Disconnect()end end end)end dropdownButton.MouseEnter:Connect(function
()Utils.tween(dropdownButton,{BackgroundColor3=Color3.fromHex('E8E8ED')},0.15)
end)dropdownButton.MouseLeave:Connect(function()Utils.tween(dropdownButton,{
BackgroundColor3=Theme.SecondaryBackground},0.15)end)dropdownButton.Activated:
Connect(function()buildPopup()end)local module={}function module:GetValue()
return selected end function module:SetValue(value)for _,option in ipairs(
options)do if option==value then selected=value dropdownButton.Text=selected
return end end end function module:SetOptions(newOptions)options=newOptions
selected=options[1]or''dropdownButton.Text=selected end function module:SetText(
newText)label.Text=newText end function module:SetCallback(newCallback)callback=
newCallback end function module:Destroy()destroyPopup()container:Destroy()end
return module end return Dropdown end function __DARKLUA_BUNDLE_MODULES.k():
typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.k if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.k=v end return v.c end end do local 
function __modImpl()local Theme=__DARKLUA_BUNDLE_MODULES.a()local Fonts=
__DARKLUA_BUNDLE_MODULES.c()local Utils=__DARKLUA_BUNDLE_MODULES.d()local Button
=__DARKLUA_BUNDLE_MODULES.e()local Toggle=__DARKLUA_BUNDLE_MODULES.f()local
Slider=__DARKLUA_BUNDLE_MODULES.g()local Label=__DARKLUA_BUNDLE_MODULES.h()local
Divider=__DARKLUA_BUNDLE_MODULES.i()local Input=__DARKLUA_BUNDLE_MODULES.j()
local Dropdown=__DARKLUA_BUNDLE_MODULES.k()local Container={}function Container.
new(parent,config)local title=config.Title or''local layoutOrder=config.
LayoutOrder or 0 local container=Utils.create('Frame',{Name='Container',
BackgroundColor3=Theme.Background,BackgroundTransparency=0,Size=UDim2.new(1,0,0,
0),AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0,LayoutOrder=layoutOrder,
Parent=parent},{Utils.create('UICorner',{CornerRadius=UDim.new(0,12)}),Utils.
create('UIStroke',{Color=Theme.Border,Thickness=1,Transparency=0})})local
content=Utils.create('Frame',{Name='Content',BackgroundTransparency=1,Size=UDim2
.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=container},{Utils.
create('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.
LayoutOrder}),Utils.create('UIPadding',{PaddingTop=UDim.new(0,10),PaddingBottom=
UDim.new(0,10)})})if title~=''then Utils.create('TextLabel',{Name='Title',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),FontFace=Fonts.getInter(),Text
=title,TextSize=13,TextColor3=Theme.TextSecondary,TextXAlignment=Enum.
TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,LayoutOrder=0,
Parent=content},{Utils.create('UIPadding',{PaddingLeft=UDim.new(0,16),
PaddingRight=UDim.new(0,16)})})end local layoutOrderCounter=1 local hasElements=
false local function autoDivider()if hasElements then Divider.new(content,
layoutOrderCounter)layoutOrderCounter+=1 end end local module={}function module:
AddButton(buttonConfig)autoDivider()buttonConfig.LayoutOrder=layoutOrderCounter
layoutOrderCounter+=1 hasElements=true return Button.new(content,buttonConfig)
end function module:AddToggle(toggleConfig)autoDivider()toggleConfig.LayoutOrder
=layoutOrderCounter layoutOrderCounter+=1 hasElements=true return Toggle.new(
content,toggleConfig)end function module:AddSlider(sliderConfig)autoDivider()
sliderConfig.LayoutOrder=layoutOrderCounter layoutOrderCounter+=1 hasElements=
true return Slider.new(content,sliderConfig)end function module:AddLabel(
labelConfig)autoDivider()labelConfig.LayoutOrder=layoutOrderCounter
layoutOrderCounter+=1 hasElements=true return Label.new(content,labelConfig)end
function module:AddDivider()autoDivider()local divider=Divider.new(content,
layoutOrderCounter)layoutOrderCounter+=1 hasElements=true return divider end
function module:AddInput(inputConfig)autoDivider()inputConfig.LayoutOrder=
layoutOrderCounter layoutOrderCounter+=1 hasElements=true return Input.new(
content,inputConfig)end function module:AddDropdown(dropdownConfig)autoDivider()
dropdownConfig.LayoutOrder=layoutOrderCounter layoutOrderCounter+=1 hasElements=
true return Dropdown.new(content,dropdownConfig)end function module:GetContainer
()return container end function module:Destroy()container:Destroy()end return
module end return Container end function __DARKLUA_BUNDLE_MODULES.l():typeof(
__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.l if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.l=v end return v.c end end do local 
function __modImpl()local Environment={}function Environment.isExecutor()return
type(getgenv)=='function'end function Environment.isStudio()return not
Environment.isExecutor()end function Environment.getGuiParent()if Environment.
isExecutor()then if type(gethui)=='function'then return gethui()end local
coreGui=game:GetService('CoreGui')if coreGui then return coreGui end end local
players=game:GetService('Players')local localPlayer=players.LocalPlayer or
players:WaitForChild('Players').LocalPlayer return localPlayer:WaitForChild(
'PlayerGui')end function Environment.getCustomAsset(name)if type(getcustomasset)
=='function'then local success,asset=pcall(getcustomasset,name)if success and
asset then return asset end end return nil end return Environment end function
__DARKLUA_BUNDLE_MODULES.m():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES
.cache.m if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.m=v end
return v.c end end do local function __modImpl()local Environment=
__DARKLUA_BUNDLE_MODULES.m()local Config={}Config.__index=Config local
DEFAULT_KEY='r0bXu1_c0nf1g_3ncryp710n_k3y'local CHAR_MAP={}local BASE64_CHARS=
[[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/]]for i=1,#
BASE64_CHARS do CHAR_MAP[string.sub(BASE64_CHARS,i,i)]=i-1 end local function 
xorEncrypt(text,key)local result={}for i=1,#text do local textByte=string.byte(
text,i)local keyByte=string.byte(key,(i-1)%#key+1)result[i]=string.char(bit32.
bxor(textByte,keyByte))end return table.concat(result)end local function 
base64Encode(data)local bytes={}for i=1,#data do bytes[i]=string.byte(data,i)end
local result={}local i=1 while i<=#bytes do local b1=bytes[i]local b2=bytes[i+1]
or 0 local b3=bytes[i+2]or 0 local c1=bit32.rshift(b1,2)local c2=bit32.bor(bit32
.lshift(bit32.band(b1,3),4),bit32.rshift(b2,4))local c3=bit32.bor(bit32.lshift(
bit32.band(b2,15),2),bit32.rshift(b3,6))local c4=bit32.band(b3,63)result[#result
+1]=string.sub(BASE64_CHARS,c1+1,c1+1)result[#result+1]=string.sub(BASE64_CHARS,
c2+1,c2+1)if i+1<=#bytes then result[#result+1]=string.sub(BASE64_CHARS,c3+1,c3+
1)else result[#result+1]='='end if i+2<=#bytes then result[#result+1]=string.
sub(BASE64_CHARS,c4+1,c4+1)else result[#result+1]='='end i=i+3 end return table.
concat(result)end local function base64Decode(data)local bytes={}local i=1 while
i<=#data do local c1=CHAR_MAP[string.sub(data,i,i)]local c2=CHAR_MAP[string.sub(
data,i+1,i+1)]local c3=CHAR_MAP[string.sub(data,i+2,i+2)]local c4=CHAR_MAP[
string.sub(data,i+3,i+3)]if c1 and c2 then local b1=bit32.bor(bit32.lshift(c1,2)
,bit32.rshift(c2,4))bytes[#bytes+1]=b1 if c3 then local b2=bit32.bor(bit32.
lshift(bit32.band(c2,15),4),bit32.rshift(c3,2))bytes[#bytes+1]=b2 if c4 then
local b3=bit32.bor(bit32.lshift(bit32.band(c3,3),6),c4)bytes[#bytes+1]=b3 end
end end i=i+4 end local result={}for j=1,#bytes do result[j]=string.char(bytes[j
])end return table.concat(result)end local function encrypt(data,key)key=key or
DEFAULT_KEY local encrypted=xorEncrypt(data,key)return base64Encode(encrypted)
end local function decrypt(data,key)key=key or DEFAULT_KEY local decoded=
base64Decode(data)return xorEncrypt(decoded,key)end local function getWritePath(
fileName)if Environment.isExecutor()then if type(writefile)=='function'then
return fileName end end return nil end local function getReadPath(fileName)if
Environment.isExecutor()then if type(readfile)=='function'then return fileName
end end return nil end function Config.new(fileName,encryptionKey)local self=
setmetatable({},Config)self.fileName=fileName or'robxui_config.cfg'self.
encryptionKey=encryptionKey or DEFAULT_KEY self.data={}self.defaults={}self.
loaded=false return self end function Config:SetDefaults(defaults)self.defaults=
defaults for key,value in pairs(defaults)do if self.data[key]==nil then self.
data[key]=value end end return self end function Config:Load()local path=
getReadPath(self.fileName)if not path then self:MergeDefaults()self.loaded=true
return self end local success,content=pcall(readfile,path)if success and content
then local decryptSuccess,decrypted=pcall(decrypt,content,self.encryptionKey)if
decryptSuccess and decrypted then local HttpService=game:GetService(
'HttpService')local parseSuccess,parsed=pcall(HttpService.JSONDecode,HttpService
,decrypted)if parseSuccess and type(parsed)=='table'then self.data=parsed end
end end self:MergeDefaults()self.loaded=true return self end function Config:
Save()local path=getWritePath(self.fileName)if not path then return false end
local HttpService=game:GetService('HttpService')local success,encoded=pcall(
HttpService.JSONEncode,HttpService,self.data)if not success then return false
end local encrypted=encrypt(encoded,self.encryptionKey)local writeSuccess=pcall(
writefile,path,encrypted)return writeSuccess end function Config:Get(key)return
self.data[key]end function Config:Set(key,value)self.data[key]=value return self
end function Config:GetAll()return self.data end function Config:SetAll(data)
self.data=data return self end function Config:Reset()self.data={}self:
MergeDefaults()return self end function Config:Delete()local path=getWritePath(
self.fileName)if not path then return false end if type(delfile)=='function'then
local success=pcall(delfile,path)return success end return false end function
Config:MergeDefaults()for key,value in pairs(self.defaults)do if self.data[key]
==nil then self.data[key]=value end end end return Config end function
__DARKLUA_BUNDLE_MODULES.n():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES
.cache.n if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.n=v end
return v.c end end do local function __modImpl()local Theme=
__DARKLUA_BUNDLE_MODULES.a()local Fonts=__DARKLUA_BUNDLE_MODULES.c()local Utils=
__DARKLUA_BUNDLE_MODULES.d()local Environment=__DARKLUA_BUNDLE_MODULES.b()local
Container=__DARKLUA_BUNDLE_MODULES.l()local Config=__DARKLUA_BUNDLE_MODULES.n()
local Window={}function Window.new(config)local title=config.Title or'Window'
local size=config.Size or UDim2.fromOffset(600,400)local guiParent=Environment.
getGuiParent()local screenGui=Utils.create('ScreenGui',{Name='RobloxUI',
ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=guiParent})
local canvasGroup=Utils.create('CanvasGroup',{Name='Window',BackgroundColor3=
Theme.Background,BackgroundTransparency=0,Size=size,Position=UDim2.new(0.5,-size
.X.Offset/2,0.5,-size.Y.Offset/2),BorderSizePixel=0,GroupColor3=Color3.new(1,1,1
),GroupTransparency=0,ClipsDescendants=true,Parent=screenGui},{Utils.create(
'UICorner',{CornerRadius=UDim.new(0,16)}),Utils.create('UIShadow',{Color=Color3.
new(0,0,0),Transparency=0.8,BlurRadius=UDim.new(0,16),Offset=UDim2.new(0,0,0,4),
Spread=UDim2.new(0,0,0,0)})})local titleBar=Utils.create('Frame',{Name=
'TitleBar',BackgroundColor3=Theme.Background,BackgroundTransparency=0,Size=UDim2
.new(1,0,0,44),BorderSizePixel=0,Parent=canvasGroup},{Utils.create('UIPadding',{
PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16)})})Utils.create('Frame',{
Name='TitleBarBorder',BackgroundColor3=Theme.Border,Size=UDim2.new(1,0,0,1),
Position=UDim2.new(0,0,1,-1),BorderSizePixel=0,Parent=titleBar})local titleLabel
=Utils.create('TextLabel',{Name='Title',BackgroundTransparency=1,Size=UDim2.new(
1,-76,1,0),FontFace=Fonts.getInter(),Text=title,TextSize=17,TextColor3=Theme.
TextPrimary,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.
TextYAlignment.Center,Parent=titleBar})local closeIcon=config.CloseIcon local
closeButton if closeIcon then closeButton=Utils.create('ImageButton',{Name=
'Close',BackgroundColor3=Theme.CloseButton,BackgroundTransparency=0,Size=UDim2.
new(0,28,0,28),Position=UDim2.new(1,-28,0.5,-14),Image=closeIcon,ImageColor3=
Color3.new(1,1,1),ImageTransparency=0,AutoButtonColor=false,Parent=titleBar},{
Utils.create('UICorner',{CornerRadius=UDim.new(0.5,0)}),Utils.create('UIPadding'
,{PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7),PaddingLeft=UDim.new(0,7)
,PaddingRight=UDim.new(0,7)})})else closeButton=Utils.create('TextButton',{Name=
'Close',BackgroundColor3=Theme.CloseButton,BackgroundTransparency=0,Size=UDim2.
new(0,60,0,28),Position=UDim2.new(1,-60,0.5,-14),FontFace=Fonts.getInter(),Text=
'Close',TextSize=13,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,Parent=
titleBar},{Utils.create('UICorner',{CornerRadius=UDim.new(0.5,0)})})end
closeButton.MouseEnter:Connect(function()Utils.tween(closeButton,{
BackgroundColor3=Theme.CloseButtonHover},0.15)end)closeButton.MouseLeave:
Connect(function()Utils.tween(closeButton,{BackgroundColor3=Theme.CloseButton},
0.15)end)closeButton.InputBegan:Connect(function(input)if input.UserInputType==
Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch
then Utils.tween(closeButton,{BackgroundColor3=Theme.CloseButtonPressed},0.1)end
end)closeButton.InputEnded:Connect(function(input)if input.UserInputType==Enum.
UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
Utils.tween(closeButton,{BackgroundColor3=Theme.CloseButtonHover},0.1)end end)
closeButton.Activated:Connect(function()screenGui:Destroy()end)local tabBar=
Utils.create('Frame',{Name='TabBar',BackgroundTransparency=1,Size=UDim2.new(1,0,
0,36),Position=UDim2.new(0,0,0,44),BorderSizePixel=0,Parent=canvasGroup},{Utils.
create('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.
new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.
VerticalAlignment.Center}),Utils.create('UIPadding',{PaddingLeft=UDim.new(0,16),
PaddingRight=UDim.new(0,16)})})Utils.create('Frame',{Name='TabBarBorder',
BackgroundColor3=Theme.Border,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,
80),BorderSizePixel=0,Parent=canvasGroup})local pagesContainer=Utils.create(
'Frame',{Name='Pages',BackgroundTransparency=1,Size=UDim2.new(1,0,1,-80),
Position=UDim2.new(0,0,0,80),BorderSizePixel=0,ClipsDescendants=true,Parent=
canvasGroup})local tabs={}local activeTab=nil local tabLayoutOrder=0 local 
function selectTab(tab)for _,t in ipairs(tabs)do t.page.Visible=false t.button.
TextColor3=Theme.TextSecondary end tab.page.Visible=true tab.button.TextColor3=
Theme.Button activeTab=tab end local function createTab(name)local tab={}tab.
button=Utils.create('TextButton',{Name='Tab_'..name,BackgroundTransparency=1,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,0,36),FontFace=Fonts.
getInter(),Text=name,TextSize=14,TextColor3=Theme.TextSecondary,TextXAlignment=
Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,
AutoButtonColor=false,LayoutOrder=tabLayoutOrder,Parent=tabBar},{Utils.create(
'UIPadding',{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})})tab.page=
Utils.create('ScrollingFrame',{Name='Page_'..name,BackgroundTransparency=1,Size=
UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),ScrollBarThickness=4,
ScrollBarImageColor3=Theme.Border,CanvasSize=UDim2.new(0,0,0,0),
AutomaticCanvasSize=Enum.AutomaticSize.Y,BorderSizePixel=0,Visible=false,Parent=
pagesContainer},{Utils.create('UIListLayout',{Padding=UDim.new(0,12),SortOrder=
Enum.SortOrder.LayoutOrder}),Utils.create('UIPadding',{PaddingLeft=UDim.new(0,16
),PaddingRight=UDim.new(0,16),PaddingTop=UDim.new(0,16),PaddingBottom=UDim.new(0
,16)})})tab.button.MouseEnter:Connect(function()if activeTab~=tab then Utils.
tween(tab.button,{TextColor3=Theme.TextPrimary},0.15)end end)tab.button.
MouseLeave:Connect(function()if activeTab~=tab then Utils.tween(tab.button,{
TextColor3=Theme.TextSecondary},0.15)end end)tab.button.Activated:Connect(
function()selectTab(tab)end)tab.layoutOrderCounter=0 function tab:AddSection(
sectionConfig)sectionConfig.LayoutOrder=self.layoutOrderCounter self.
layoutOrderCounter+=1 return Container.new(self.page,sectionConfig)end function
tab:AddContainer(containerConfig)return self:AddSection(containerConfig)end
table.insert(tabs,tab)tabLayoutOrder+=1 if#tabs==1 then selectTab(tab)end return
tab end local dragging=false local dragStart=nil local startPos=nil titleBar.
InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.
MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true
dragStart=input.Position startPos=canvasGroup.Position end end)local userInput=
game:GetService('UserInputService')userInput.InputChanged:Connect(function(input
)if dragging and(input.UserInputType==Enum.UserInputType.MouseMovement or input.
UserInputType==Enum.UserInputType.Touch)then local delta=input.Position-
dragStart canvasGroup.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+
delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)end end)userInput.InputEnded:
Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1
or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
local layoutOrderCounter=0 local configInstance=Config.new(config.ConfigFile or
'robxui_config.cfg',config.ConfigKey)configInstance:Load()local settingsTab=
createTab('Settings')local configSection=settingsTab:AddSection({Title=
'Configuration'})local statusLabel=configSection:AddLabel({Text='Config: '..(
configInstance.loaded and'Loaded'or'Not loaded'),TextSize=13})configSection:
AddLabel({Text='File: '..(configInstance.fileName or'N/A'),TextSize=12,TextColor
=Theme.TextSecondary})configSection:AddButton({Text='Save Config',Callback=
function()local success=configInstance:Save()statusLabel:SetText('Config: '..(
success and'Saved'or'Save failed'))end})configSection:AddButton({Text=
'Load Config',Callback=function()configInstance:Load()statusLabel:SetText(
'Config: '..(configInstance.loaded and'Loaded'or'Load failed'))end})
configSection:AddButton({Text='Reset Config',Callback=function()configInstance:
Reset()statusLabel:SetText('Config: Reset to defaults')end})local module={}
function module:GetConfig()return configInstance end function module:AddTab(name
)return createTab(name)end function module:AddSection(sectionConfig)if#tabs==0
then createTab('Main')end return tabs[#tabs]:AddSection(sectionConfig)end
function module:AddContainer(containerConfig)return module:AddSection(
containerConfig)end function module:SetTitle(newTitle)titleLabel.Text=newTitle
end function module:GetTitle()return titleLabel.Text end function module:GetGui(
)return screenGui end function module:Destroy()screenGui:Destroy()end return
module end return Window end function __DARKLUA_BUNDLE_MODULES.o():typeof(
__modImpl())local v=__DARKLUA_BUNDLE_MODULES.cache.o if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.o=v end return v.c end end do local 
function __modImpl()local Environment=__DARKLUA_BUNDLE_MODULES.m()local Icons={}
Icons.__index=Icons local LUCIDE_BASE=
[[https://raw.githubusercontent.com/lucide-icons/lucide/main/icons]]local
DEFAULT_CONVERT_ENDPOINT='https://api.clawstudiouo.com/svg-to-png'local
ICONS_DIR='RobloxUI/Icons'local BASE64_CHARS=
[[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/]]local 
function base64Encode(data)local result={}local i=1 while i<=#data do local b1=
string.byte(data,i)local b2=string.byte(data,i+1)or 0 local b3=string.byte(data,
i+2)or 0 local c1=bit32.rshift(b1,2)local c2=bit32.bor(bit32.lshift(bit32.band(
b1,3),4),bit32.rshift(b2,4))local c3=bit32.bor(bit32.lshift(bit32.band(b2,15),2)
,bit32.rshift(b3,6))local c4=bit32.band(b3,63)result[#result+1]=string.sub(
BASE64_CHARS,c1+1,c1+1)result[#result+1]=string.sub(BASE64_CHARS,c2+1,c2+1)if i+
1<=#data then result[#result+1]=string.sub(BASE64_CHARS,c3+1,c3+1)else result[#
result+1]='='end if i+2<=#data then result[#result+1]=string.sub(BASE64_CHARS,c4
+1,c4+1)else result[#result+1]='='end i=i+3 end return table.concat(result)end
local function buildMultipart(fields)local boundary=
'----FormBoundary7MA4YWxkTrZu0gW'local body={}for _,field in ipairs(fields)do
table.insert(body,'--'..boundary..'\r\n')local header=
'Content-Disposition: form-data; name="'..field.name..'"'if field.filename then
header=header..'; filename="'..field.filename..'"'end if field.contentType then
header=header..'\r\nContent-Type: '..field.contentType end table.insert(body,
header..'\r\n\r\n')table.insert(body,field.content..'\r\n')end table.insert(body
,'--'..boundary..'--\r\n')return table.concat(body),
'multipart/form-data; boundary='..boundary end local function httpRequest(url,
method,headers,body)if type(request)=='function'then local opts={Url=url,Method=
method,Headers=headers or{}}if body then opts.Body=body end local success,
response=pcall(request,opts)if success then return response end elseif type(
http_request)=='function'then local opts={Url=url,Method=method,Headers=headers
or{}}if body then opts.Body=body end local success,response=pcall(http_request,
opts)if success then return response end end return nil end function Icons.new(
config)local self=setmetatable({},Icons)config=config or{}self.convertEndpoint=
config.convertEndpoint or DEFAULT_CONVERT_ENDPOINT self.iconsDir=config.iconsDir
or ICONS_DIR self.defaultSize=config.defaultSize or 24 self.cache={}return self
end function Icons:fetchSVG(iconName)if not Environment.isExecutor()then return
nil,'Icons only available in executor environment'end local url=LUCIDE_BASE..'/'
..iconName..'.svg'local response=httpRequest(url,'GET',{})if response and
response.StatusCode==200 then return response.Body end return nil,
'Failed to fetch SVG for: '..iconName end function Icons:convertToPNG(svgContent
,size)if not Environment.isExecutor()then return nil,
'Icons only available in executor environment'end size=size or self.defaultSize
local body,contentType=buildMultipart({{name='file',filename='icon.svg',
contentType='image/svg+xml',content=svgContent},{name='width',content=tostring(
size)}})local response=httpRequest(self.convertEndpoint,'POST',{['Content-Type']
=contentType},body)if response and response.StatusCode==200 then local
HttpService=game:GetService('HttpService')local isJson=false if response.Headers
then for k,v in pairs(response.Headers)do if string.lower(k)=='content-type'and
string.find(string.lower(v),'json')then isJson=true break end end end if isJson
then local success,data=pcall(HttpService.JSONDecode,HttpService,response.Body)
if success and data then if data.url then local pngResponse=httpRequest(data.url
,'GET',{})if pngResponse and pngResponse.StatusCode==200 then return pngResponse
.Body end elseif data.data and data.data.url then local pngResponse=httpRequest(
data.data.url,'GET',{})if pngResponse and pngResponse.StatusCode==200 then
return pngResponse.Body end end end else return response.Body end end return nil
,'SVG to PNG conversion failed'end function Icons:download(iconName,size)if not
Environment.isExecutor()then return nil,
'Icons only available in executor environment'end if type(writefile)~='function'
then return nil,'writefile not available'end size=size or self.defaultSize local
cacheKey=iconName..'_'..tostring(size)if self.cache[cacheKey]then return self.
cache[cacheKey]end local svg,err=self:fetchSVG(iconName)if not svg then return
nil,err end local png,convertErr=self:convertToPNG(svg,size)if not png then
return nil,convertErr end local filePath=self.iconsDir..'/'..iconName..'.png'
writefile(filePath,png)if type(getcustomasset)=='function'then local assetPath=
getcustomasset(filePath)if assetPath then self.cache[cacheKey]=assetPath return
assetPath end end return nil,'getcustomasset failed'end function Icons:
ensureDownloaded(iconName,size)if not Environment.isExecutor()then return nil
end size=size or self.defaultSize local cacheKey=iconName..'_'..tostring(size)if
self.cache[cacheKey]then return self.cache[cacheKey]end local filePath=self.
iconsDir..'/'..iconName..'.png'if type(isfile)=='function'and isfile(filePath)
then if type(getcustomasset)=='function'then local assetPath=getcustomasset(
filePath)if assetPath then self.cache[cacheKey]=assetPath return assetPath end
end end return self:download(iconName,size)end function Icons:get(iconName)local
cacheKey=iconName..'_'..tostring(self.defaultSize)return self.cache[cacheKey]end
function Icons:isAvailable()return Environment.isExecutor()and type(request)==
'function'and type(writefile)=='function'end return Icons end function
__DARKLUA_BUNDLE_MODULES.p():typeof(__modImpl())local v=__DARKLUA_BUNDLE_MODULES
.cache.p if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.p=v end
return v.c end end end local Theme=__DARKLUA_BUNDLE_MODULES.a()local Fonts=
__DARKLUA_BUNDLE_MODULES.c()local Utils=__DARKLUA_BUNDLE_MODULES.d()local
Environment=__DARKLUA_BUNDLE_MODULES.b()local Window=__DARKLUA_BUNDLE_MODULES.o(
)local Config=__DARKLUA_BUNDLE_MODULES.n()local Icons=__DARKLUA_BUNDLE_MODULES.
p()local Library={}function Library:CreateWindow(config)return Window.new(config
)end function Library:CreateConfig(fileName,encryptionKey)return Config.new(
fileName,encryptionKey)end function Library:CreateIcons(iconsConfig)return Icons
.new(iconsConfig)end function Library:GetTheme()return Theme end function
Library:SetTheme(customTheme)for key,value in pairs(customTheme)do Theme[key]=
value end end function Library:GetFont()return Fonts.getInter()end function
Library:GetEnvironment()return Environment end return Library
