--!strict
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Types)

type Screen3D = Types.Screen3D
type Component3D = Types.Component3D

local Component3D = {}
Component3D.__index = Component3D

local function pivot(original: CFrame, pivot: CFrame, angle: CFrame)
	return original:Inverse() * pivot * angle * pivot:Inverse() * original
end

--- Constructs projection state for one GuiObject.
--- @param component_2d GuiObject represented by this object
--- @param screen_3d Screen3D owner that provides root projection state
--- @return Component3D
function Component3D.new(component_2d: GuiObject, screen_3d: Screen3D): Component3D
	local self = setmetatable({
		Enabled = false,
		CompatibilityEnabled = false,

		Component2D = component_2d,
		SurfaceGui = nil,

		Parent3D = nil,
		Screen3D = screen_3d,

		Offset = CFrame.new(),
		ViewportSize = screen_3d:GetIntendedCanvasSize(),

		Conn = nil,
	}, Component3D) :: any

	self.ViewportSize = self:GetViewportSize()

	if component_2d.Parent and component_2d.Parent:IsA("GuiObject") then
		self.Parent2D = component_2d.Parent
	end

	return self
end

function Component3D:EnableCompatibility(): Component3D
	local this = self :: Component3D

	if not this.Parent2D then
		warn("Compatibility mode requires a GuiObject parent.")
		return this:Enable()
	end

	this.CompatibilityEnabled = true

	local container_0, container_1 = Instance.new("Frame"), Instance.new("Frame")

	container_0.Name = "3DCONTAINER"
	container_1.Name = "3DCONTAINER"

	container_0.Parent = this.Parent2D or this.Screen3D.RootGui
	container_1.Parent = container_0

	container_0.BackgroundTransparency = 1
	container_1.BackgroundTransparency = 1

	local container_3d_0, container_3d_1 =
		Component3D.new(container_0, this.Screen3D), Component3D.new(container_1, this.Screen3D)

	this.Screen3D.PartIndex[container_0], this.Screen3D.PartIndex[container_1] = container_3d_0, container_3d_1

	this.CompatibilityParent3D = this.Parent3D
	this.CompatibilityParent2D = this.Parent2D

	this.Parent2D = container_1
	this.Parent3D = container_3d_1

	return this:Enable()
end

function Component3D:Enable(): Component3D
	local this = self :: Component3D

	if this.Enabled or not this.Component2D then
		return this
	end

	this.Enabled = true

	local surface_gui = Instance.new("SurfaceGui")
	local surface_part = Instance.new("Part")

	surface_part.CanCollide = false
	surface_part.Anchored = true
	surface_part.Parent = surface_gui

	surface_gui.Parent = this.Parent2D or this.Screen3D.RootGui
	surface_gui.Face = Enum.NormalId.Back
	surface_gui.Adornee = surface_part
	surface_gui.AlwaysOnTop = true

	this.SurfaceGui = surface_gui

	this.Component2D.Parent = this.SurfaceGui

	this.Conn = game:GetService("HttpService"):GenerateGUID(false)
	RunService:BindToRenderStep(this.Conn, Enum.RenderPriority.Last.Value + 2, function()
		if this.Conn and not (this.SurfaceGui and surface_part) then
			RunService:UnbindFromRenderStep(this.Conn)
			return
		end

		local viewport_size = this:GetViewportSize()

		if
			this.CompatibilityEnabled
			and this.Parent2D
			and this.Parent3D
			and this.Parent3D.Parent2D
			and this.CompatibilityParent2D
		then
			local compatibility_parent = this.CompatibilityParent2D

			this.Parent3D.Parent2D.AnchorPoint = this.Component2D.AnchorPoint

			this.Parent3D.Parent2D.Position = this.Component2D.Position
			this.Parent2D.Position =
				UDim2.fromOffset(-this.Component2D.AbsolutePosition.X, -this.Component2D.AbsolutePosition.Y)

			this.Parent2D.Size =
				UDim2.fromOffset(compatibility_parent.AbsoluteSize.X, compatibility_parent.AbsoluteSize.Y)
			this.Parent3D.Parent2D.Size =
				UDim2.fromOffset(this.Component2D.AbsoluteSize.X, this.Component2D.AbsoluteSize.Y)
		end

		this.ViewportSize = viewport_size

		surface_gui.CanvasSize = viewport_size
		surface_part.Size = this:GetStudsScreenSize(viewport_size)
		surface_part.CFrame = this:ReadWorldCFrame()
	end)

	return this
end

function Component3D:Disable(): Component3D
	local this = self :: Component3D

	if not this.Enabled then
		return this
	end

	this.Enabled = false

	if this.Conn then
		RunService:UnbindFromRenderStep(this.Conn)
	end

	if this.Component2D then
		if this.CompatibilityEnabled then
			this.Component2D.Parent = this.CompatibilityParent2D or this.Screen3D.RootGui
		else
			this.Component2D.Parent = this.Parent2D or this.Screen3D.RootGui
		end
	end

	if this.SurfaceGui then
		this.SurfaceGui:Destroy()
	end

	return this
end

function Component3D:GetViewportSize(): Vector2
	local this = self :: Component3D

	if this.Parent3D and this.Parent3D.Component2D then
		return this.Parent3D.Component2D.AbsoluteSize
	end

	return this.Screen3D:GetIntendedCanvasSize()
end

function Component3D:UDim2ToCFrame(position_2d: UDim2): CFrame
	local this = self :: Component3D

	if not this.Component2D then
		return CFrame.new()
	end

	local scale_x, scale_y = position_2d.X.Scale, position_2d.Y.Scale
	local offset_x, offset_y = position_2d.X.Offset, position_2d.Y.Offset

	local view_size = this:GetViewportSize()

	local true_scale_x, true_scale_y = scale_x + offset_x / view_size.X, scale_y + offset_y / view_size.Y
	local part_size = this:GetStudsScreenSize(view_size)

	return CFrame.new(part_size.X * (true_scale_x - 0.5), -part_size.Y * (true_scale_y - 0.5), 0)
end

function Component3D:GetStudsScreenSize(viewport_size: Vector2): Vector3
	local this = self :: Component3D
	local true_size = this.Screen3D:GetRealCanvasSize()

	local current_camera = workspace.CurrentCamera
	local fov = current_camera.FieldOfView

	return Vector3.new(
		(true_size.X / true_size.Y) * math.tan(math.rad(fov) / 2) * (viewport_size.X / true_size.X),
		math.tan(math.rad(fov) / 2) * (viewport_size.Y / true_size.Y),
		0
	) * this.Screen3D.DisplayDistance
end

function Component3D:RecomputeParent(): Component3D
	local this = self :: Component3D

	if this.Parent2D and this.Parent2D:IsA("GuiObject") then
		this.Parent3D = this.Screen3D:GetComponent3D(this.Parent2D)
	end

	if this.SurfaceGui then
		local parent = this.Parent3D
		local z_index = 0

		while parent do
			z_index += 1
			parent = parent.Parent3D
		end

		this.SurfaceGui.ZOffset = z_index
	end

	return this
end

function Component3D:GetCompatibilityPosition(): UDim2
	local this = self :: Component3D

	if not this.Enabled and this.Component2D and this.Parent3D and this.Parent3D.Component2D then
		local offset = this.Component2D.AbsolutePosition - this.Parent3D.Component2D.AbsolutePosition
		return UDim2.fromOffset(offset.X, offset.Y)
	end
	return UDim2.new(0, 0, 0, 0)
end

function Component3D:ReadWorldCFrame(): CFrame
	local this = self :: Component3D

	if not this.Component2D then
		return CFrame.new()
	end

	this:RecomputeParent()

	local original_cframe, udim_pos, added_position

	local udim_max = this:UDim2ToCFrame(UDim2.fromScale(1, 1))

	if this.Parent3D then
		if not this.Parent3D.Component2D or not this.Parent2D then
			return CFrame.new()
		end

		local anchor_point = this.Parent3D.Component2D.AnchorPoint

		original_cframe = this.Parent3D:ReadWorldCFrame()

		udim_pos = this.Parent3D.Component2D.Position

		local anchor_frame = this:UDim2ToCFrame(UDim2.fromScale(-anchor_point.X + 0.5, -anchor_point.Y + 0.5))

		if not this.Parent3D.Enabled and this.Parent3D.Parent3D and this.Parent3D.Parent3D.Component2D then
			udim_pos = this.Parent3D:GetCompatibilityPosition()

			anchor_frame = CFrame.new()
		end

		added_position = this.Parent3D:UDim2ToCFrame(udim_pos)
			* udim_max
			* anchor_frame
			* CFrame.Angles(0, 0, -math.rad(this.Parent2D.Rotation))
	else
		local viewport_diff = this.Screen3D:GetRealCanvasSize() - this.Screen3D:GetIntendedCanvasSize()

		original_cframe = workspace.CurrentCamera.CFrame
			* CFrame.new(0, 0, -this.Screen3D.DisplayDistance / 2)
			* this.Screen3D.RootOffset

		udim_pos = UDim2.new(0, viewport_diff.X / 2, 0, viewport_diff.Y / 2)

		added_position = this:UDim2ToCFrame(udim_pos) * this:UDim2ToCFrame(UDim2.fromScale(1, 1))
	end

	local final_cframe = original_cframe * added_position

	local component_position = this.Component2D.Position

	if not this.Enabled and this.Parent3D and this.Parent3D.Component2D and not this.Parent3D.Enabled then
		component_position = this:GetCompatibilityPosition()
	end

	local final_pivot = final_cframe * udim_max:Inverse() * this:UDim2ToCFrame(component_position) * udim_max

	return final_cframe * pivot(final_cframe, final_pivot, this.Offset)
end

return Component3D
