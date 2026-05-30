--!strict
-- DanceMoves.lua
-- The dance move library. Source of truth for the radial wheel and the dancers.
-- All animation ids are Roblox-owned defaults that load on any R15 rig and animate in
-- place (no root travel), which is what works on the pinned cookie rigs. Moves that need
-- the whole body to move (jump, fall, sit, climb) were cut because they read as broken
-- on a stationary mannequin.

export type DanceMove = {
	id: string, -- stable internal key
	name: string, -- kid-facing display name
	animationId: string,
	speed: number, -- playback multiplier (Sugar Rush is a sped-up Twist)
	onWheel: boolean, -- shown on the 6-slot radial wheel by default
}

-- Order here is the library order. onWheel picks the default 6 for the wheel.
local DanceMoves: { DanceMove } = {
	{ id = "bop",        name = "The Bop",      animationId = "rbxassetid://507771019", speed = 1.0, onWheel = true },
	{ id = "twist",      name = "The Twist",    animationId = "rbxassetid://507776043", speed = 1.0, onWheel = true },
	{ id = "sway",       name = "Smooth Sway",  animationId = "rbxassetid://507777268", speed = 1.0, onWheel = true },
	{ id = "disco",      name = "Disco Point",  animationId = "rbxassetid://507770453", speed = 1.0, onWheel = true },
	{ id = "cheer",      name = "Big Cheer",    animationId = "rbxassetid://507770818", speed = 1.0, onWheel = true },
	{ id = "runningman", name = "Running Man",  animationId = "rbxassetid://913376220", speed = 1.0, onWheel = true },
	-- library extras (swap onto the wheel anytime by flipping onWheel)
	{ id = "wave",       name = "Crowd Wave",   animationId = "rbxassetid://507770239", speed = 1.0, onWheel = false },
	{ id = "sugarrush",  name = "Sugar Rush",   animationId = "rbxassetid://507776043", speed = 1.7, onWheel = false },
}

local M = {}
M.all = DanceMoves

function M.byId(id: string): DanceMove?
	for _, move in DanceMoves do
		if move.id == id then
			return move
		end
	end
	return nil
end

function M.wheel(): { DanceMove }
	local out = {}
	for _, move in DanceMoves do
		if move.onWheel then
			table.insert(out, move)
		end
	end
	return out
end

return M
