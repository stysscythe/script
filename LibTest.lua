-- quick note, ronaldo is the goat.
local Lib = {}

local tweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

function Lib:Drag(frame,parent)
	local UIS = game:GetService('UserInputService')
	parent = parent or frame
	local dragToggle = nil
	local dragSpeed = 0.25
	local dragStart = nil
	local startPos = nil

	local function updateInput(input)
		local delta = input.Position - dragStart
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		game:GetService('TweenService'):Create(parent, TweenInfo.new(dragSpeed), {Position = position}):Play()
	end

	frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true
			dragStart = input.Position
			startPos = parent.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				updateInput(input)
			end
		end
	end)
end

function Lib.Window(Title)
	Title = Title or "Ui Library"

	local UiLib = Instance.new("ScreenGui")
	local Main = Instance.new("Frame")
	local MainCorner = Instance.new("UICorner")
	local TabFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local TabNavigator = Instance.new("ScrollingFrame")
	local UIPadding = Instance.new("UIPadding")
	local UIListLayout = Instance.new("UIListLayout")
	local TopBar = Instance.new("Frame")
	local TopCorner = Instance.new("UICorner")
	local LibraryTitle = Instance.new("TextLabel")
	local Extension = Instance.new("Frame")
	local ExtensionCorner = Instance.new("UICorner")
	local ContentHolder = Instance.new("Folder")
	local TabContent = Instance.new("ScrollingFrame")
	local ContentPadding = Instance.new("UIPadding")
	local ContentLayout = Instance.new("UIListLayout")

	--Properties:

	UiLib.Name = "UiLib"
	UiLib.Parent = game.CoreGui
	UiLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Main.Name = "Main"
	Main.Parent = UiLib
	Main.BackgroundColor3 = Color3.fromRGB(31, 25, 44)
	Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.303370774, 0, 0.291770577, 0)
	Main.Size = UDim2.new(0, 454, 0, 333)
	Main.ZIndex = 2

	MainCorner.CornerRadius = UDim.new(0, 15)
	MainCorner.Name = "MainCorner"
	MainCorner.Parent = Main

	TabFrame.Name = "TabFrame"
	TabFrame.Parent = Main
	TabFrame.BackgroundColor3 = Color3.fromRGB(18, 15, 24)
	TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabFrame.BorderSizePixel = 0
	TabFrame.Position = UDim2.new(0.0198237877, 0, 0.153153151, 0)
	TabFrame.Size = UDim2.new(0, 134, 0, 275)
	TabFrame.ZIndex = 4

	UICorner.CornerRadius = UDim.new(0, 7)
	UICorner.Parent = TabFrame

	TabNavigator.Name = "TabNavigator"
	TabNavigator.Parent = TabFrame
	TabNavigator.Active = true
	TabNavigator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabNavigator.BackgroundTransparency = 1.000
	TabNavigator.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabNavigator.BorderSizePixel = 0
	TabNavigator.Position = UDim2.new(0.00733371312, 0, 0, 0)
	TabNavigator.Size = UDim2.new(0, 132, 0, 275)
	TabNavigator.ZIndex = 4
	TabNavigator.CanvasSize = UDim2.new(0, 0, 0, 0)

	UIPadding.Parent = TabNavigator
	UIPadding.PaddingTop = UDim.new(0, 12)

	UIListLayout.Parent = TabNavigator
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 19)
	
	Lib:Drag(TopBar,Main)
	
	TopBar.Name = "TopBar"
	TopBar.Parent = Main
	TopBar.BackgroundColor3 = Color3.fromRGB(18, 15, 24)
	TopBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TopBar.BorderSizePixel = 0
	TopBar.Size = UDim2.new(0, 454, 0, 45)
	TopBar.ZIndex = 5

	TopCorner.CornerRadius = UDim.new(0, 15)
	TopCorner.Name = "TopCorner"
	TopCorner.Parent = TopBar

	LibraryTitle.Name = "LibraryTitle"
	LibraryTitle.Parent = TopBar
	LibraryTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LibraryTitle.BackgroundTransparency = 1.000
	LibraryTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LibraryTitle.BorderSizePixel = 0
	LibraryTitle.Position = UDim2.new(0.0194763951, 2, 0.169778883, -4)
	LibraryTitle.Size = UDim2.new(0, 300, 0, 39)
	LibraryTitle.ZIndex = 5
	LibraryTitle.FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal);
	LibraryTitle.Text = "UI Lib"
	LibraryTitle.TextColor3 = Color3.fromRGB(227, 227, 227)
	LibraryTitle.TextScaled = true
	LibraryTitle.TextSize = 37.000
	LibraryTitle.TextWrapped = true
	LibraryTitle.TextXAlignment = Enum.TextXAlignment.Left

	Extension.Name = "Extension"
	Extension.Parent = TopBar
	Extension.BackgroundColor3 = Color3.fromRGB(18, 15, 24)
	Extension.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Extension.BorderSizePixel = 0
	Extension.Position = UDim2.new(0.00652175443, -3, 0.994062245, 0)
	Extension.Size = UDim2.new(0, 454, 0, -23)
	Extension.ZIndex = 4

	ExtensionCorner.CornerRadius = UDim.new(0, 7)
	ExtensionCorner.Name = "ExtensionCorner"
	ExtensionCorner.Parent = Extension

	ContentHolder.Name = "ContentHolder"
	ContentHolder.Parent = Main
	
	local TabSys = {}

	local first = true

	function TabSys.CreateTab(TabTitle)
		TabTitle = TabTitle or "Home"

		local TabContent = Instance.new("ScrollingFrame")
		local TabSwitcher = Instance.new("TextButton")
		local TabCorner = Instance.new("UICorner")
		local ContentPadding = Instance.new("UIPadding")
		local ContentLayout = Instance.new("UIListLayout")

		TabSwitcher.Name = "TabSwitcher"
		TabSwitcher.Parent = TabNavigator
		TabSwitcher.BackgroundColor3 = Color3.fromRGB(53, 50, 74)
		TabSwitcher.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabSwitcher.BorderSizePixel = 0
		TabSwitcher.Position = UDim2.new(0, 0, 0.101818189, 0)
		TabSwitcher.Size = UDim2.new(0, 114, 0, 25)
		TabSwitcher.ZIndex = 4
		TabSwitcher.FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		TabSwitcher.Text = TabTitle
		TabSwitcher.TextColor3 = Color3.fromRGB(227, 227, 227)
		TabSwitcher.TextSize = 24.000
		TabSwitcher.TextWrapped = true

		TabCorner.Name = "TabCorner"
		TabCorner.Parent = TabSwitcher

		TabContent.Name = "TabContent"
		TabContent.Parent = ContentHolder
		TabContent.Active = true
		TabContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabContent.BackgroundTransparency = 1.000
		TabContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabContent.BorderSizePixel = 0
		TabContent.Position = UDim2.new(0.331549704, 0, 0.153153151, 0)
		TabContent.Size = UDim2.new(0, 295, 0, 275)
		TabContent.ZIndex = 4
		TabContent.ClipsDescendants = true

		ContentPadding.Name = "ContentPadding"
		ContentPadding.Parent = TabContent
		ContentPadding.PaddingTop = UDim.new(0, 12)

		ContentLayout.Name = "ContentLayout"
		ContentLayout.Parent = TabContent
		ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ContentLayout.Padding = UDim.new(0,12)

		if first then
			first = false
			TabContent.Visible = true
			TabSwitcher.BackgroundTransparency = 0.7
			TabSwitcher.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			TabContent.Visible = false
			TabSwitcher.BackgroundTransparency = 0.89
			TabSwitcher.TextColor3 = Color3.fromRGB(199, 199, 199)
		end

		TabSwitcher.MouseButton1Click:Connect(function()
			for i,v in next, ContentHolder:GetChildren() do
				v.Visible = false
			end
			TabContent.Visible = true

			for i,v in next, TabNavigator:GetChildren() do
				if v:IsA("TextButton") then
					game.TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						BackgroundTransparency = 0.89
					}):Play()
					game.TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						TextColor3 = Color3.fromRGB(199, 199, 199)
					}):Play()
				end
			end
			game.TweenService:Create(TabSwitcher, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				BackgroundTransparency = 0.7
			}):Play()
			game.TweenService:Create(TabSwitcher, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				TextColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
			
		end)
		local Content = {}

		function Content.CreateButton(BtnTitle, callback)
			BtnTitle = BtnTitle or "Print"
			callback = callback or function() end

			local ButtonFrame = Instance.new("Frame")	
			local ButtonTrigger = Instance.new("TextButton")
			local ButtonCorner = Instance.new("UICorner")
			local TextLabel = Instance.new("TextLabel")
			local TouchImage = Instance.new("ImageLabel")
			local Circle = Instance.new("ImageLabel")

			ButtonFrame.Name = "ButtonFrame"
			ButtonFrame.Parent = TabContent
			ButtonFrame.Active = true
			ButtonFrame.BackgroundColor3 = Color3.fromRGB(53, 50, 74)
			ButtonFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ButtonFrame.BorderSizePixel = 0
			ButtonFrame.ClipsDescendants = true
			ButtonFrame.Position = UDim2.new(0.0983050838, 0, 0.043636363, 0)
			ButtonFrame.Selectable = true
			ButtonFrame.Size = UDim2.new(0, 237, 0, 32)
			ButtonFrame.ZIndex = 4

			ButtonCorner.Name = "ButtonCorner"
			ButtonCorner.Parent = ButtonFrame

			ButtonTrigger.Name = "ButtonTrigger"
			ButtonTrigger.Parent = ButtonFrame
			ButtonTrigger.BackgroundColor3 = Color3.fromRGB(53, 50, 74)
			ButtonTrigger.BackgroundTransparency = 1.000
			ButtonTrigger.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ButtonTrigger.BorderSizePixel = 0
			ButtonTrigger.ClipsDescendants = true
			ButtonTrigger.Size = UDim2.new(0, 237, 0, 32)
			ButtonTrigger.ZIndex = 5
			ButtonTrigger.Text = ""
			ButtonTrigger.TextTransparency = 1.000

			TextLabel.Parent = ButtonFrame
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.151898727, 0, 0, 0)
			TextLabel.Size = UDim2.new(0, 193, 0, 32)
			TextLabel.ZIndex = 5
			TextLabel.FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
			TextLabel.Text = BtnTitle
			TextLabel.TextColor3 = Color3.fromRGB(227, 227, 227)
			TextLabel.TextSize = 26.000
			TextLabel.TextWrapped = true
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			TouchImage.Name = "TouchImage"
			TouchImage.Parent = ButtonFrame
			TouchImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TouchImage.BackgroundTransparency = 1.000
			TouchImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TouchImage.BorderSizePixel = 0
			TouchImage.Position = UDim2.new(0.0590717308, -5, 0.1875, -2)
			TouchImage.Size = UDim2.new(0, 22, 0, 22)
			TouchImage.ZIndex = 5
			TouchImage.Image = "rbxassetid://3926305904"
			TouchImage.ImageColor3 = Color3.fromRGB(228, 197, 255)
			TouchImage.ImageRectOffset = Vector2.new(84, 204)
			TouchImage.ImageRectSize = Vector2.new(36, 36)

			Circle.Name = "Circle"
			Circle.Parent = ButtonFrame
			Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Circle.BackgroundTransparency = 1.000
			Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Circle.BorderSizePixel = 0
			Circle.Position = UDim2.new(0.472573817, -5, 0.21875, 9)
			Circle.ZIndex = 5
			Circle.Image = "rbxassetid://4560909609"
			Circle.ImageColor3 = Color3.fromRGB(228, 197, 255)

			local sample = Circle
			local ms = game.Players.LocalPlayer:GetMouse()

			ButtonTrigger.MouseButton1Click:Connect(function()
				local ClickSound = 	Instance.new("Sound")

				ClickSound.Parent = ButtonTrigger
				ClickSound.SoundId = "rbxassetid://552900451"
				ClickSound.Volume = 2 
				ClickSound.Pitch = 0.5

				ClickSound:Play()

				callback()

				local c = sample:Clone()
				c.Parent = ButtonFrame
				local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
				c.Position = UDim2.new(0, x, 0, y)
				local len, size = 0.35, nil
				if ButtonFrame.AbsoluteSize.X >= ButtonFrame.AbsoluteSize.Y then
					size = (ButtonFrame.AbsoluteSize.X * 1.5)
				else
					size = (ButtonFrame.AbsoluteSize.Y * 1.5)
				end
				c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, (-size / 2), 0.5, (-size / 2)), 'Out', 'Quad', len, true, nil)
				for i = 1, 10 do
					c.ImageTransparency = c.ImageTransparency + 0.05
					wait(len / 12)
				end

				c:Destroy()
			end)
		end

		function Content.CreateSlider(SliderTitle, minvalue, maxvalue, callback)
			SliderTitle = SliderTitle or "Walkspeed"
			minvalue = minvalue or 16
			maxvalue = maxvalue or 100
			callback = callback or function() end

			local SliderFrame = Instance.new("Frame")
			local SliderCorner = Instance.new("UICorner")
			local SliderLabel = Instance.new("TextLabel")
			local GraphImage = Instance.new("ImageLabel")
			local SliderTrigger = Instance.new("TextButton")
			local SliderBack = Instance.new("Frame")
			local SliderFill = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UICorner_3 = Instance.new("UICorner")
			local ValueLabel = Instance.new("TextLabel")

			SliderFrame.Name = "SliderFrame"
			SliderFrame.Parent = TabContent
			SliderFrame.Active = true
			SliderFrame.BackgroundColor3 = Color3.fromRGB(53, 50, 74)
			SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SliderFrame.BorderSizePixel = 0
			SliderFrame.ClipsDescendants = true
			SliderFrame.Position = UDim2.new(0.0983050838, 0, 0.203636363, 0)
			SliderFrame.Selectable = true
			SliderFrame.Size = UDim2.new(0, 237, 0, 48)
			SliderFrame.ZIndex = 4

			SliderCorner.Name = "SliderCorner"
			SliderCorner.Parent = SliderFrame

			SliderLabel.Name = "SliderLabel"
			SliderLabel.Parent = SliderFrame
			SliderLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderLabel.BackgroundTransparency = 1.000
			SliderLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SliderLabel.BorderSizePixel = 0
			SliderLabel.Position = UDim2.new(0.185654014, 0, 0, 0)
			SliderLabel.Size = UDim2.new(0, 193, 0, 32)
			SliderLabel.ZIndex = 5
			SliderLabel.FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
			SliderLabel.Text = SliderTitle
			SliderLabel.TextColor3 = Color3.fromRGB(227, 227, 227)
			SliderLabel.TextSize = 26.000
			SliderLabel.TextWrapped = true
			SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

			GraphImage.Name = "GraphImage"
			GraphImage.Parent = SliderFrame
			GraphImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			GraphImage.BackgroundTransparency = 1.000
			GraphImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
			GraphImage.BorderSizePixel = 0
			GraphImage.Position = UDim2.new(0.0801687762, -5, 0.1875, -2)
			GraphImage.Size = UDim2.new(0, 22, 0, 22)
			GraphImage.ZIndex = 5
			GraphImage.Image = "rbxassetid://3926307971"
			GraphImage.ImageColor3 = Color3.fromRGB(228, 197, 255)
			GraphImage.ImageRectOffset = Vector2.new(404, 164)
			GraphImage.ImageRectSize = Vector2.new(36, 36)

			SliderTrigger.Name = "SliderTrigger"
			SliderTrigger.Parent = SliderFrame
			SliderTrigger.BackgroundColor3 = Color3.fromRGB(53, 50, 74)
			SliderTrigger.BackgroundTransparency = 1.000
			SliderTrigger.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SliderTrigger.BorderSizePixel = 0
			SliderTrigger.ClipsDescendants = true
			SliderTrigger.Position = UDim2.new(0.0680000037, 0, 0.708000004, 0)
			SliderTrigger.Size = UDim2.new(0, 207, 0, 7)
			SliderTrigger.ZIndex = 5
			SliderTrigger.Text = ""
			SliderTrigger.TextTransparency = 1.000

			SliderBack.Name = "SliderBack"
			SliderBack.Parent = SliderTrigger
			SliderBack.BackgroundColor3 = Color3.fromRGB(53, 40, 65)
			SliderBack.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SliderBack.BorderSizePixel = 0
			SliderBack.Size = UDim2.new(0, 207, 0, 7)
			SliderBack.ZIndex = 5
			SliderBack.ClipsDescendants = true
			
			SliderFill.Name = "SliderFill"
			SliderFill.Parent = SliderBack
			SliderFill.BackgroundColor3 = Color3.fromRGB(228, 197, 255)
			SliderFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SliderFill.BorderSizePixel = 0
			SliderFill.Size = UDim2.new(0, 0, 0, 7)
			SliderFill.ZIndex = 5

			UICorner_2.Parent = SliderFill

			UICorner_3.Parent = SliderBack

			ValueLabel.Name = "ValueLabel"
			ValueLabel.Parent = SliderFrame
			ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ValueLabel.BackgroundTransparency = 1.000
			ValueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ValueLabel.BorderSizePixel = 0
			ValueLabel.Position = UDim2.new(0.628692031, 0, 0.0416666679, -1)
			ValueLabel.Size = UDim2.new(0, 88, 0, 32)
			ValueLabel.ZIndex = 5
			ValueLabel.FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
			ValueLabel.Text = minvalue
			ValueLabel.TextColor3 = Color3.fromRGB(227, 227, 227)
			ValueLabel.TextSize = 26.000
			ValueLabel.TextWrapped = true
			ValueLabel.TextTransparency = 1.000

			local mouse = game.Players.LocalPlayer:GetMouse()
			local uis = game:GetService("UserInputService")
			local Value;

			SliderTrigger.MouseButton1Down:Connect(function()
					game.TweenService:Create(ValueLabel, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						TextTransparency = 0
					}):Play()
				Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 206) * SliderFill.AbsoluteSize.X) + tonumber(minvalue)) or 0
					pcall(function()
						callback(Value)
					end)
				SliderFill:TweenSize(UDim2.new(0, math.clamp(mouse.X - SliderFill.AbsolutePosition.X, 0, 206), 0, 7), "InOut", "Linear", 0.15, true)
					moveconnection = mouse.Move:Connect(function()
						ValueLabel.Text = Value
					Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 206) * SliderFill.AbsoluteSize.X) + tonumber(minvalue))
						pcall(function()
							callback(Value)
						end)
					SliderFill:TweenSize(UDim2.new(0, math.clamp(mouse.X - SliderFill.AbsolutePosition.X, 0, 206), 0, 7), "InOut", "Linear", 0.15, true)
					end)
					releaseconnection = uis.InputEnded:Connect(function(Mouse)
						if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
						Value = math.floor((((tonumber(maxvalue) - tonumber(minvalue)) / 206) * SliderFill.AbsoluteSize.X) + tonumber(minvalue))
							pcall(function()
								callback(Value)
							end)
						ValueLabel.Text = Value
						game.TweenService:Create(ValueLabel, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
								TextTransparency = 1
							}):Play()
						SliderFill:TweenSize(UDim2.new(0, math.clamp(mouse.X - SliderFill.AbsolutePosition.X, 0, 206), 0, 7), "InOut", "Linear", 0.15, true)
							moveconnection:Disconnect()
							releaseconnection:Disconnect()
						end
				  end)
			end)
		end
		
		function Content.CreateToggle(TogTXT, callback)
			TogTXT = TogTXT or "Inf Jump"
			callback = callback or function() end
			local toggled = false
			
			local ToggleFrame = Instance.new("Frame")
			local ButtonCorner = Instance.new("UICorner")
			local ToggleLabel = Instance.new("TextLabel")
			local ToggleDisabled = Instance.new("ImageLabel")
			local Circle = Instance.new("ImageLabel")
			local ToggleTrigger = Instance.new("TextButton")
			local ToggleEnabled = Instance.new("ImageLabel")

			ToggleFrame.Name = "ToggleFrame"
			ToggleFrame.Parent = TabContent
			ToggleFrame.Active = true
			ToggleFrame.BackgroundColor3 = Color3.fromRGB(53, 50, 74)
			ToggleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleFrame.BorderSizePixel = 0
			ToggleFrame.ClipsDescendants = true
			ToggleFrame.Position = UDim2.new(0.0983050838, 0, 0.043636363, 0)
			ToggleFrame.Selectable = true
			ToggleFrame.Size = UDim2.new(0, 237, 0, 32)
			ToggleFrame.ZIndex = 4

			ButtonCorner.Name = "ButtonCorner"
			ButtonCorner.Parent = ToggleFrame

			ToggleLabel.Name = "ToggleLabel"
			ToggleLabel.Parent = ToggleFrame
			ToggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleLabel.BackgroundTransparency = 1.000
			ToggleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleLabel.BorderSizePixel = 0
			ToggleLabel.Position = UDim2.new(0.151898727, 0, 0, 0)
			ToggleLabel.Size = UDim2.new(0, 193, 0, 32)
			ToggleLabel.ZIndex = 5
			ToggleLabel.FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
			ToggleLabel.Text = TogTXT
			ToggleLabel.TextColor3 = Color3.fromRGB(227, 227, 227)
			ToggleLabel.TextSize = 26.000
			ToggleLabel.TextWrapped = true
			ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

			ToggleDisabled.Name = "ToggleDisabled"
			ToggleDisabled.Parent = ToggleFrame
			ToggleDisabled.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleDisabled.BackgroundTransparency = 1.000
			ToggleDisabled.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleDisabled.BorderSizePixel = 0
			ToggleDisabled.Position = UDim2.new(0.0590717308, -5, 0.1875, -1)
			ToggleDisabled.Size = UDim2.new(0, 22, 0, 22)
			ToggleDisabled.ZIndex = 5
			ToggleDisabled.Image = "rbxassetid://3926309567"
			ToggleDisabled.ImageColor3 = Color3.fromRGB(228, 197, 255)
			ToggleDisabled.ImageRectOffset = Vector2.new(628, 420)
			ToggleDisabled.ImageRectSize = Vector2.new(48, 48)

			Circle.Name = "Circle"
			Circle.Parent = ToggleFrame
			Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Circle.BackgroundTransparency = 1.000
			Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Circle.BorderSizePixel = 0
			Circle.Position = UDim2.new(0.472573817, -5, 0.21875, 9)
			Circle.ZIndex = 5
			Circle.Image = "rbxassetid://4560909609"
			Circle.ImageColor3 = Color3.fromRGB(228, 197, 255)

			ToggleTrigger.Name = "ToggleTrigger"
			ToggleTrigger.Parent = ToggleFrame
			ToggleTrigger.BackgroundColor3 = Color3.fromRGB(53, 50, 74)
			ToggleTrigger.BackgroundTransparency = 1.000
			ToggleTrigger.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleTrigger.BorderSizePixel = 0
			ToggleTrigger.ClipsDescendants = true
			ToggleTrigger.Size = UDim2.new(0, 237, 0, 32)
			ToggleTrigger.ZIndex = 5
			ToggleTrigger.Text = ""
			ToggleTrigger.TextTransparency = 1.000

			ToggleEnabled.Name = "ToggleEnabled"
			ToggleEnabled.Parent = ToggleFrame
			ToggleEnabled.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleEnabled.BackgroundTransparency = 1.000
			ToggleEnabled.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleEnabled.BorderSizePixel = 0
			ToggleEnabled.Position = UDim2.new(0.0590717308, -5, 0.1875, -1)
			ToggleEnabled.Size = UDim2.new(0, 22, 0, 22)
			ToggleEnabled.ZIndex = 5
			ToggleEnabled.Image = "rbxassetid://3926309567"
			ToggleEnabled.ImageColor3 = Color3.fromRGB(228, 197, 255)
			ToggleEnabled.ImageRectOffset = Vector2.new(784, 420)
			ToggleEnabled.ImageRectSize = Vector2.new(48, 48)
			ToggleEnabled.ImageTransparency = 1.000
			
			local img = ToggleEnabled
			local sample = Circle
			local ms = game.Players.LocalPlayer:GetMouse()
			
			ToggleTrigger.MouseButton1Click:Connect(function()
				if toggled == false then
					game.TweenService:Create(img, TweenInfo.new(0.5, Enum.EasingStyle.Linear,Enum.EasingDirection.In), {
						ImageTransparency = 0
					}):Play()
					
					local ClickSound = 	Instance.new("Sound")

					ClickSound.Parent = ToggleFrame
					ClickSound.SoundId = "rbxassetid://552900451"
					ClickSound.Volume = 2 
					ClickSound.Pitch = 1

					local c = sample:Clone()
					c.Parent = ToggleFrame
					local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
					c.Position = UDim2.new(0, x, 0, y)
					local len, size = 0.35, nil
					if ToggleFrame.AbsoluteSize.X >= ToggleFrame.AbsoluteSize.Y then
						size = (ToggleFrame.AbsoluteSize.X * 1.5)
					else
						size = (ToggleFrame.AbsoluteSize.Y * 1.5)
					end
					c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, (-size / 2), 0.5, (-size / 2)), 'Out', 'Quad', len, true, nil)
					for i = 1, 10 do
						c.ImageTransparency = c.ImageTransparency + 0.05
						wait(len / 12)
					end
					ClickSound:Play()

				
					c:Destroy()
					wait(0.25)
					toggled = true
				elseif toggled == true then
					game.TweenService:Create(img, TweenInfo.new(0.5, Enum.EasingStyle.Linear,Enum.EasingDirection.In), {
						ImageTransparency = 1
					}):Play()

					local ClickSound = 	Instance.new("Sound")

					ClickSound.Parent = ToggleFrame
					ClickSound.SoundId = "rbxassetid://552900451"
					ClickSound.Volume = 2 
					ClickSound.Pitch = 1.2
								
					
					local c = sample:Clone()
					c.Parent = ToggleFrame
					local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
					c.Position = UDim2.new(0, x, 0, y)
					local len, size = 0.35, nil
					if ToggleFrame.AbsoluteSize.X >= ToggleFrame.AbsoluteSize.Y then
						size = (ToggleFrame.AbsoluteSize.X * 1.5)
					else
						size = (ToggleFrame.AbsoluteSize.Y * 1.5)
					end
					c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, (-size / 2), 0.5, (-size / 2)), 'Out', 'Quad', len, true, nil)
					for i = 1, 10 do
						c.ImageTransparency = c.ImageTransparency + 0.05
						wait(len / 12)
					end
					ClickSound:Play()
					c:Destroy()
					wait(0.25)
					toggled = false
				end
			pcall(callback, toggled)
		  end)
		end
		
		return Content
	end
	return TabSys
end
return Lib;
