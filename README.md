# Screen3D

Screen3D projects Roblox `ScreenGui` interfaces into 3D space. It lets you keep building UI with normal 2D `GuiObject`s, then opt individual objects into world-space projection through `Component3D`.

This repository is a fork of [CatGuyMoment/Screen3D](https://github.com/CatGuyMoment/Screen3D), originally introduced in the Roblox Developer Forum post [Screen3D - A 3D UI framework that just works](https://devforum.roblox.com/t/screen3d-a-3d-ui-framework-that-just-works/3273671).

## What It Does

- Creates a `Screen3D` object from a `ScreenGui`
- Indexes every `GuiObject` descendant as a `Component3D`
- Converts selected 2D UI objects into `SurfaceGui`-backed 3D UI
- Supports rotating and moving projected UI through `CFrame` offsets
- Supports nested projected UI objects
- Lets 2D and 3D UI objects coexist in the same hierarchy

## Installation

This package includes a Wally manifest:

```toml
[dependencies]
screen3d = "raiven4ever/screen-3d@0.1.0"
```

Install dependencies with Wally, then require the package from your project's package location.

## Basic Usage

Create a `Screen3D` object from an existing `ScreenGui`:

```lua
local screen_gui: ScreenGui = path.to.your.ScreenGui
local Screen3D = require(path.to.Screen3D)

local screen_3d = Screen3D.new(screen_gui, 5)
```

The second argument is the display distance from the camera. Creating the `Screen3D` object indexes the `GuiObject` descendants, but it does not immediately convert them into 3D UI.

To project a specific `GuiObject`, get its matching `Component3D` and enable it:

```lua
local frame = screen_gui:WaitForChild("Frame") :: GuiObject
local component_3d = screen_3d:GetComponent3D(frame)

if component_3d then
	component_3d:Enable()
end
```

`Component3D:Enable()` moves the `GuiObject` into a `SurfaceGui` and starts updating its projected world-space transform. Use `Component3D:Disable()` to stop projection and restore the object to its 2D parent.

## Offsets

Each `Component3D` has an `Offset` property. The offset is applied around the UI object's anchor point and can rotate or move the projected object relative to its parent.

```lua
local frame = screen_gui:WaitForChild("Frame") :: GuiObject
local component_3d = screen_3d:GetComponent3D(frame)

if component_3d then
	component_3d:Enable()
	component_3d.Offset = CFrame.Angles(0, math.rad(10), 0)
end
```

Offsets can be changed continuously:

```lua
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
	if component_3d then
		component_3d.Offset = CFrame.Angles(0, math.sin(os.clock()) / 2, 0)
	end
end)
```

You can combine position and rotation to create an indented or angled panel:

```lua
if component_3d then
	component_3d.Offset = CFrame.new(0, 0, -0.1) * CFrame.Angles(0, math.rad(-6), 0)
end
```

## Nesting

Projected components can be nested. A child `Component3D` follows the transform of its projected parent while keeping its own `Offset`.

```lua
local frame = screen_gui:WaitForChild("Frame") :: GuiObject
local inner = frame:WaitForChild("Inner") :: GuiObject

local frame_3d = screen_3d:GetComponent3D(frame)
local inner_3d = screen_3d:GetComponent3D(inner)

if frame_3d and inner_3d then
	frame_3d:Enable()
	inner_3d:Enable()

	inner_3d.Offset = CFrame.Angles(0, math.rad(25), 0)
end
```

You do not need to enable an entire UI tree just to rotate one object. 2D UI can contain 3D components, and 3D components can contain more projected children.

## API

The package root returns the `Screen3D` class. Public Luau types are re-exported from `init.lua` and are defined in `Types.lua`.

```lua
local Screen3D = require(path.to.Screen3D)

type Screen3D = Screen3D.Screen3D
type Component3D = Screen3D.Component3D
```

### `Screen3D`

```lua
local screen_3d = Screen3D.new(screen_gui, display_distance)
```

- `Screen3D.new(screen_gui, display_distance)` creates projection state for a `ScreenGui`
- `screen_3d:GetComponent3D(gui_object)` returns the indexed `Component3D`, or `nil`
- `screen_3d:GetRealCanvasSize()` returns the camera viewport size
- `screen_3d:GetInset()` returns the GUI inset
- `screen_3d:GetInsetCanvasSize()` returns viewport size minus GUI inset
- `screen_3d:GetIntendedCanvasSize()` respects `ScreenGui.IgnoreGuiInset`

### `Component3D`

- `component_3d:Enable()` starts projection
- `component_3d:Disable()` stops projection
- `component_3d:EnableCompatibility()` enables wrapper-frame compatibility behavior for nested layouts
- `component_3d.Offset` controls local projected rotation and position
- `component_3d:GetViewportSize()` returns the active canvas size for the component
- `component_3d:ReadWorldCFrame()` computes the current world-space transform

## Notes

- Projection is opt-in for performance: creating `Screen3D` only indexes objects.
- `Offset` pivots around the original UI object's `AnchorPoint`.
- For angled corner panels, set the UI object's `AnchorPoint` to the pivot you want before enabling projection.
- True curved GUI is not provided by this module; the original forum thread discusses Roblox engine limitations around curvature.

## Differences From The Original Files

This fork is based on the original author's `Component3D.luau`, `Definitions.luau`, and `init.luau`. The runtime behavior is intentionally very close to the original.

Main differences:

- Files were renamed from `.luau` to `.lua`.
- The shared type definitions live in `Types.lua`, replacing the original `Definitions.luau`.
- Types were rewritten as plain exported object-shape types and documented there.
- Class/table names and public fields use PascalCase conventions.
- Formatting and comments were cleaned up.
- A duplicate `GetStudsScreenSize` call in `UDim2ToCFrame` was removed.
- Wally metadata, licensing, and this README were added for packaging.

## Credits

Original project: [CatGuyMoment/Screen3D](https://github.com/CatGuyMoment/Screen3D)

Original DevForum resource: [Screen3D - A 3D UI framework that just works](https://devforum.roblox.com/t/screen3d-a-3d-ui-framework-that-just-works/3273671)

This fork is maintained under `raiven4ever/screen-3d`.
