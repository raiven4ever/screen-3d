--!strict

--- Screen3D represents a ScreenGui projected into world space.
---
--- Responsibilities:
--- * Own the root ScreenGui projection state
--- * Create Component3D objects for GuiObject descendants
--- * Provide canvas and inset measurements for projected components
export type Screen3D = {
	--- Maps source GuiObjects to their projected Component3D objects.
	PartIndex: { [GuiObject]: Component3D },
	--- ScreenGui that owns the 2D hierarchy being projected.
	RootGui: ScreenGui,
	--- Distance from the camera used for world-space projection.
	DisplayDistance: number,
	--- Additional world-space transform applied to the root projection.
	RootOffset: CFrame,

	--- Returns the projected object for a GuiObject.
	--- @param component_2d GuiObject used as the lookup key
	--- @return Component3D? nil if the GuiObject has not been indexed
	GetComponent3D: (self: Screen3D, component_2d: GuiObject) -> Component3D?,
	--- Returns the full camera viewport size.
	--- @return Vector2 camera viewport size in pixels
	GetRealCanvasSize: (self: Screen3D) -> Vector2,
	--- Returns the camera viewport size minus the GUI inset.
	--- @return Vector2 inset-adjusted canvas size in pixels
	GetInsetCanvasSize: (self: Screen3D) -> Vector2,
	--- Returns the canvas size used for projection.
	--- @return Vector2 full viewport when IgnoreGuiInset is true, otherwise inset-adjusted size
	GetIntendedCanvasSize: (self: Screen3D) -> Vector2,
	--- Returns the top-left GUI inset.
	--- @return Vector2 inset in pixels
	GetInset: (self: Screen3D) -> Vector2,
}

--- Component3D represents one GuiObject projected into world space.
---
--- Responsibilities:
--- * Own the projected SurfaceGui and backing Part
--- * Track parent-child projection relationships
--- * Convert 2D GUI layout into world-space CFrames
export type Component3D = {
	--- Whether this object is actively projected into world space.
	Enabled: boolean,
	--- Whether wrapper-frame compatibility behavior is active.
	CompatibilityEnabled: boolean,

	--- GuiObject represented by this projected object.
	Component2D: GuiObject?,
	--- SurfaceGui currently hosting the GuiObject while enabled.
	SurfaceGui: SurfaceGui?,

	--- Original 2D GuiObject parent, when the object is nested.
	Parent2D: GuiObject?,
	--- Screen3D owner that provides root projection state.
	Screen3D: Screen3D,
	--- Projected parent object, when the GuiObject is nested.
	Parent3D: Component3D?,

	--- Original 2D parent restored after compatibility mode is disabled.
	CompatibilityParent2D: GuiObject?,
	--- Original projected parent restored after compatibility mode is disabled.
	CompatibilityParent3D: Component3D?,

	--- Local transform applied around this object's projected pivot.
	Offset: CFrame,
	--- Current canvas size used by this object's SurfaceGui.
	ViewportSize: Vector2,

	--- Render-step binding name used while this object is enabled.
	Conn: string?,

	--- Starts projection by moving the GuiObject into a SurfaceGui.
	--- @return Component3D this object
	Enable: (self: Component3D) -> Component3D,
	--- Enables projection with wrapper frames that preserve nested layout behavior.
	--- @return Component3D this object
	EnableCompatibility: (self: Component3D) -> Component3D,
	--- Stops projection and restores the GuiObject to its 2D parent.
	--- @return Component3D this object
	Disable: (self: Component3D) -> Component3D,
	--- Recomputes this object's projected parent and z offset.
	--- @return Component3D this object
	RecomputeParent: (self: Component3D) -> Component3D,
	--- Returns the world-space size of a viewport at the display distance.
	--- @param viewport_size Vector2 viewport size in pixels
	--- @return Vector3 size in studs
	GetStudsScreenSize: (self: Component3D, viewport_size: Vector2) -> Vector3,
	--- Computes the world-space CFrame for this object.
	--- @return CFrame identity when required 2D state is missing
	ReadWorldCFrame: (self: Component3D) -> CFrame,
	--- Converts a 2D GUI position into a local projected CFrame.
	--- @param position_2d UDim2 position within this object's viewport
	--- @return CFrame identity when the component has no GuiObject
	UDim2ToCFrame: (self: Component3D, position_2d: UDim2) -> CFrame,
	--- Returns a parent-relative position for disabled nested compatibility objects.
	--- @return UDim2 zero when no compatibility position is needed
	GetCompatibilityPosition: (self: Component3D) -> UDim2,
	--- Returns the viewport used by this object.
	--- @return Vector2 parent size when nested, otherwise the Screen3D canvas size
	GetViewportSize: (self: Component3D) -> Vector2,
}

return nil
