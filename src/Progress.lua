local Surface = require("./Surface")

--//Variables
local Progress = {}
Progress.__index = Progress
local Create = Surface.Create

--//Source
function Progress.new(Options)
	local self = setmetatable({ Config = Surface.Config(Options, "YHubStartup"), Connections = {}, Tweens = {}, Steps = {} }, Progress)
	local Success, Message = pcall(self.Build, self)
	if not Success then self:Destroy() error(Message, 0) end
	return self
end

function Progress:Connect(Signal, Callback)
	self.Connections[#self.Connections + 1] = Signal:Connect(Callback)
end

function Progress:Animate(Key, Object, Properties, Duration)
	if self.Tweens[Key] then self.Tweens[Key]:Cancel() end
	self.Tweens[Key] = Surface.Animate(Object, Properties, Duration)
end

function Progress:Build()
	local Theme = self.Config.Theme
	local Gui = Create("ScreenGui", {
		Name = self.Config.Name, ResetOnSpawn = false, DisplayOrder = 10001,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	})
	self.Gui = Gui
	Surface.Mount(Gui)
	self.Layout = Create("Frame", { Name = "Layout", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, Gui)
	local Panel = Create("CanvasGroup", {
		Name = "Panel", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -20),
		Size = UDim2.fromOffset(380, 206), BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
		GroupTransparency = 1,
	}, self.Layout)
	self.Panel = Panel
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Panel)
	Create("UIStroke", { Color = Theme.Border, Thickness = 1 }, Panel)
	self.Scroll = Create("ScrollingFrame", {
		Name = "Content", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 206), ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Pink, ScrollingDirection = Enum.ScrollingDirection.Y,
	}, Panel)
	local function Label(Name, Text, Position, Size, TextSize, Color, Font)
		return Create("TextLabel", {
			Name = Name, Text = Text, Position = Position, Size = Size, BackgroundTransparency = 1,
			TextColor3 = Color, Font = Font or Enum.Font.Gotham, TextSize = TextSize,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
		}, self.Scroll)
	end
	local Mark = Label("Mark", "<i>Y</i>", UDim2.fromOffset(18, 17), UDim2.fromOffset(30, 30), 22, Theme.Text, Enum.Font.GothamBold)
	Mark.RichText, Mark.BackgroundTransparency, Mark.BackgroundColor3, Mark.TextXAlignment = true, 0, Theme.Accent, Enum.TextXAlignment.Center
	Label("Brand", "Y HUB.", UDim2.fromOffset(59, 17), UDim2.new(1, -110, 0, 30), 17, Theme.Text, Enum.Font.GothamBold)
	local Close = Create("TextButton", {
		Name = "Close", Text = utf8.char(215), Position = UDim2.new(1, -50, 0, 8), Size = UDim2.fromOffset(44, 44),
		BackgroundTransparency = 1, TextColor3 = Theme.Muted, TextSize = 23, Font = Enum.Font.Gotham,
	}, self.Scroll)
	self.Title = Label("Title", "Checking compatibility", UDim2.fromOffset(18, 61), UDim2.new(1, -36, 0, 24), 15, Theme.Text, Enum.Font.GothamMedium)
	self.Message = Label("Message", "Preparing your session...", UDim2.fromOffset(18, 91), UDim2.new(1, -36, 0, 40), 12, Theme.Muted)
	self.Message.TextYAlignment = Enum.TextYAlignment.Top
	for Index, Name in ipairs({ "Environment", "Functions", "Hooks" }) do
		local Row = Create("Frame", {
			Name = Name, Position = UDim2.new((Index - 1) / 3, 18 - (Index - 1) * 12, 0, 150),
			Size = UDim2.new(1 / 3, -20, 0, 37), BackgroundTransparency = 1,
		}, self.Scroll)
		local Track = Create("Frame", { Name = "Track", Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = Theme.Border, BorderSizePixel = 0 }, Row)
		local Fill = Create("Frame", { Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Pink, BorderSizePixel = 0 }, Track)
		local Caption = Create("TextLabel", {
			Name = "Caption", Text = Name, Position = UDim2.fromOffset(0, 11), Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1, TextColor3 = Theme.Muted, TextSize = 11, Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, Row)
		self.Steps[Index] = { Fill = Fill, Caption = Caption }
	end
	self:Connect(Close.Activated, function() self:Destroy() end)
	self:Connect(self.Layout:GetPropertyChangedSignal("AbsoluteSize"), function() self:Resize() end)
	self:Connect(Gui.Destroying, function() self:Destroy() end)
	self:Resize()
	self:Animate("Entrance", Panel, { GroupTransparency = 0 }, 0.25)
end

function Progress:Resize()
	if self.Destroyed then return end
	local Size = self.Layout.AbsoluteSize
	if Size.X < 1 or Size.Y < 1 then return end
	self.Panel.Size = UDim2.fromOffset(math.min(380, math.max(1, Size.X - 24)), math.min(206, math.max(1, Size.Y - 32)))
end

function Progress:SetStage(Index, Message)
	if self.Destroyed then return end
	self.Message.Text = Message
	for StepIndex, Step in ipairs(self.Steps) do
		local Complete = StepIndex < Index
		Step.Caption.TextColor3 = StepIndex == Index and self.Config.Theme.Text or self.Config.Theme.Muted
		self:Animate(StepIndex, Step.Fill, { Size = UDim2.fromScale(Complete and 1 or StepIndex == Index and 0.3 or 0, 1) })
	end
end

function Progress:SetResult(Success, Message)
	if self.Destroyed then return end
	self.Title.Text = Success and "Ready to continue" or "Executor not supported"
	self.Title.TextColor3 = Success and self.Config.Theme.Success or self.Config.Theme.Error
	self.Message.Text = Message
	if Success then
		for Index, Step in ipairs(self.Steps) do
			Step.Fill.BackgroundColor3 = self.Config.Theme.Success
			self:Animate(Index, Step.Fill, { Size = UDim2.fromScale(1, 1) })
		end
	end
end

function Progress:Dismiss()
	if self.Destroyed then return false end
	self:Animate("Entrance", self.Panel, { GroupTransparency = 1 }, 0.18)
	task.wait(0.18)
	if self.Destroyed then return false end
	self:Destroy()
	return true
end

function Progress:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true
	for _, Connection in ipairs(self.Connections) do Connection:Disconnect() end
	for _, Tween in pairs(self.Tweens) do Tween:Cancel() end
	table.clear(self.Connections)
	table.clear(self.Tweens)
	if self.Gui then self.Gui:Destroy() end
end

return Progress
