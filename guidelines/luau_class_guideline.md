# Luau Class & Module Guideline (Roblox Lua)

## 0. Scope

This guideline applies to all **ModuleScripts (`*.lua`)** that define
Luau classes.

Rule: - Treat every module as defining a **class or object
abstraction** - Do **not** classify modules as services or components

------------------------------------------------------------------------

## 1. Core Philosophy

Classes represent **objects with state and behavior**.

A class should answer: \> "What object does this represent, and what can
it do?"

Avoid framing in terms of: - services - components - singleton systems -
tagged-instance behavior

------------------------------------------------------------------------

## 2. What a Class Owns

A class may own:

-   internal state
-   references to instances (Model, BasePart, Player, etc.)
-   domain data (e.g. recipe, progress, state flags)
-   created objects and cleanup logic
-   behavior and methods acting on that state
-   lifecycle (construction, start, cleanup)

------------------------------------------------------------------------

## 3. Examples (Class Framing)

-   Pizza → represents a cookable pizza object\
-   Oven → represents an oven that can hold and cook a pizza\
-   Dragger → manages drag state for one player\
-   Draggable → adds drag capability to an object\
-   Hoverable → applies hover feedback to an object

------------------------------------------------------------------------

## 4. File-Level Structure

Order:

    --!strict

    -- imports

    -- types

    -- private utilities

    -- class definition

Import grouping: 1. Services (Roblox services) 2. Packages 3. Internal
modules

------------------------------------------------------------------------

## 5. Module-Level Documentation

    --- ClassName does X.
    ---
    --- Responsibilities:
    --- • responsibility 1
    --- • responsibility 2

### Optional Sections

#### Public API

    --- • Method() - description

#### Lifecycle

    --- • new() / Construct() - create state
    --- • Start()             - begin behavior
    --- • Stop() / Destroy()  - cleanup

#### Signals

    --- • EventName(payload) - description

#### Dependencies

    --- • ModuleName - purpose

------------------------------------------------------------------------

## 6. Class Definition

    local Class = {}
    Class.__index = Class

    function Class.new(...)
        local self = setmetatable({}, Class)
        return self
    end

------------------------------------------------------------------------

## 7. State Declaration

    export type Class = {
        --- Instance represented by this object.
        Instance: Instance,
        --- Current lifecycle state.
        State: string,
        --- Starts behavior for this object.
        --- @return ()
        Start: (self: Class) -> (),
        --- Cleans up resources owned by this object.
        --- @return ()
        Destroy: (self: Class) -> (),
    }

Rules:

-   Use Luau types whenever possible
-   Be explicit about fields
-   Declare class instance types as plain object-shape types
-   Do **not** use `typeof(setmetatable(...))` to define class types
-   Include public methods in the object-shape type when callers use them
-   Document every object property inside the exported type block
-   Document every object function inside the exported type block, next to
    the function type declaration
-   Keep object property and object function documentation in the exported
    type as the primary API documentation
-   Do not rely on implementation-site comments as the only documentation
    for object properties or object functions

------------------------------------------------------------------------

## 8. Instance Method Typing

Instance methods must cast `self` into a local `this` variable before
accessing object state or calling other instance methods.

    function Class:Start()
        local this = self :: Class

        this.State = "Started"
        this:DoWork()
    end

Rules:

-   Declare `local this = self :: Class` at the top of every instance
    method
-   Use `this` for all object field access and instance method calls
-   Do not use `self` in the method body after the `this` declaration
-   Exception: if an instance method does not read or write object state
    and does not call other instance methods, it does not need to declare
    `local this = self :: Class`
-   Keep constructor object creation separate from instance method
    typing; constructors may use `self` for the newly created table
-   Avoid `typeof(setmetatable(...))`; this rule is the required
    replacement pattern for typed class methods

------------------------------------------------------------------------

## 9. Lifecycle

    --- Constructs internal state.
    function Class.new()

    --- Starts behavior.
    function Class:Start()

    --- Cleans up resources.
    function Class:Destroy()

------------------------------------------------------------------------

## 10. Function Documentation

    --- Description
    --- @param name Type description
    --- @return Type description

Rules: - describe behavior, not implementation - keep concise

------------------------------------------------------------------------

## 11. Behavior & Return Contracts

Always clarify:

-   what `nil` means\
-   what booleans mean\
-   failure conditions

Example:

    --- @return BasePart? -- nil if none found

------------------------------------------------------------------------

## 12. Events / Signals

    --- Fired when X happens.
    --- Payload: param1, param2

------------------------------------------------------------------------

## 13. Naming & Terminology

Exported members: - PascalCase

File names: - PascalCase

Internal members: - snake_case

Constants: - SCREAMING_SNAKE_CASE

------------------------------------------------------------------------

## 14. API Organization (Optional)

    -- Lifecycle
    -- State
    -- Actions
    -- Utilities

------------------------------------------------------------------------

## 15. Public vs Internal Code

-   Public API → fully documented\
-   Internal code → only if complex

------------------------------------------------------------------------

## 16. Avoid Redundant Comments

Do not explain obvious code.

Document: - intent - side effects - constraints

------------------------------------------------------------------------

## 17. Tone & Style

-   present tense\
-   neutral tone\
-   no conversational phrasing

------------------------------------------------------------------------

## 18. Class Design Guidelines

Prefer designing a class when:

-   it represents a clear object or concept\
-   it owns its own state\
-   behavior logically belongs to that object\
-   multiple instances may exist

Avoid putting into a class:

-   global registries\
-   unrelated cross-object coordination\
-   engine-wide setup logic\
-   networking boundaries (unless scoped to the object)

------------------------------------------------------------------------

## 19. Cross-Module Interaction

Always document:

-   dependencies between classes\
-   how objects interact\
-   expected ownership boundaries

------------------------------------------------------------------------

## 20. Rules Summary

-   everything is a **class or object abstraction**
-   no service/component terminology
-   class types are plain object-shape types
-   never use `typeof(setmetatable(...))` for class types
-   instance methods use `local this = self :: Class`, then use `this`
-   focus on **ownership, state, and behavior**
-   documentation describes **what the object is**, not its architecture
    role
