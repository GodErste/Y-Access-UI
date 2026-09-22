local Theme = require("./Theme")

--//Variables
local Surface = {}

--//Source
function Surface.Create(Class, Properties, Parent)
	local Object = Instance.new(Class)
	for Name, Value in pairs(Properties) do Object[Name] = Value end
	Object.Parent = Parent
	return Object
end

function Surface.Config(Options, Name)
	local Config = table.clone(Options or {})
	Config.Name = Config.Name or Name
	Config.Theme = setmetatable(table.clone(Config.Theme or {}), { __index = Theme })
	return Config
end

function Surface.Mount(Gui)
	local function Mount(Parent)
		if typeof(Parent) ~= "Instance" then return false end
		return pcall(function()
			local Previous = Parent:FindFirstChild(Gui.Name)
			if Previous then Previous:Destroy() end
			Gui.Parent = Parent
		end)
	end
	local Success, Hidden = pcall(function() return type(gethui) == "function" and gethui() end)
	if Success and Mount(Hidden) then return end
	if Mount(game:GetService("CoreGui")) then return end
	local Player = game:GetService("Players").LocalPlayer
	assert(Player and Mount(Player:WaitForChild("PlayerGui", 5)), "Y Hub UI is unavailable")
end

function Surface.Animate(Object, Properties, Duration)
	local Tween = game:GetService("TweenService"):Create(Object,
		TweenInfo.new(Duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Properties)
	Tween:Play()
	return Tween
end

return Surface
