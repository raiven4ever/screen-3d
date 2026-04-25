--!strict

--- Screen3D is the package entry object for world-space ScreenGui projection.
---
--- Responsibilities:
--- * Expose the Screen3D class from the package root
--- * Export public Screen3D and Component3D types
--- * Preserve the package require path used by consumers
local Screen3D = require(script.Screen3D)
local Types = require(script.Types)

export type Screen3D = Types.Screen3D
export type Component3D = Types.Component3D

print("SCREEN3D LOADED")
return Screen3D
