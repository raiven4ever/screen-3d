--!strict
local GuiService = game:GetService("GuiService")

local Component3D = require(script.Parent.Component3D)
local Types = require(script.Parent.Types)

type Screen3D = Types.Screen3D
type Component3D = Types.Component3D

local Screen3D = {}
Screen3D.__index = Screen3D

--- Constructs projection state for a ScreenGui.
--- @param screen_gui ScreenGui projected into world space
--- @param display_distance number distance from the camera
--- @return Screen3D
function Screen3D.new(screen_gui: ScreenGui, display_distance: number): Screen3D
	local part_index: { [GuiObject]: Component3D } = {}

	local this = setmetatable({
		PartIndex = part_index,
		RootGui = screen_gui,
		DisplayDistance = display_distance,
		RootOffset = CFrame.new(),
	}, Screen3D) :: any

	for _, component_2d in screen_gui:GetDescendants() do
		if component_2d:IsA("GuiObject") then
			part_index[component_2d] = Component3D.new(component_2d, this)
		end
	end

	screen_gui.DescendantAdded:Connect(function(added_component: Instance)
		if added_component:IsA("GuiObject") then
			part_index[added_component] = Component3D.new(added_component, this)
		end
	end)

	return this
end

function Screen3D:GetRealCanvasSize(): Vector2
	return workspace.CurrentCamera.ViewportSize
end

function Screen3D:GetInset(): Vector2
	local inset = GuiService:GetGuiInset()
	return inset
end

function Screen3D:GetInsetCanvasSize(): Vector2
	local this = self :: Screen3D
	return this:GetRealCanvasSize() - this:GetInset()
end

function Screen3D:GetIntendedCanvasSize(): Vector2
	local this = self :: Screen3D

	if this.RootGui.IgnoreGuiInset then
		return this:GetRealCanvasSize()
	end

	return this:GetInsetCanvasSize()
end

function Screen3D:GetComponent3D(component_2d: GuiObject): Component3D?
	local this = self :: Screen3D
	return this.PartIndex[component_2d]
end

return Screen3D
