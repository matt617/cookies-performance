--!strict
-- Backdrops.lua
-- The stage backdrop images. One always shows; during a show the BackdropController
-- rotates among them at random.

export type Backdrop = {
	name: string,
	imageId: string,
}

local Backdrops = {}

Backdrops.all = {
	{ name = "Cotton Candy Sky", imageId = "rbxassetid://124201122268704" },
	{ name = "Crumb Galaxy", imageId = "rbxassetid://131814135059304" },
	{ name = "Midnight Bakery", imageId = "rbxassetid://83645701764855" },
} :: { Backdrop }

-- shown in Hangout / between shows
Backdrops.default = "rbxassetid://124201122268704"

-- seconds between random swaps during a show
Backdrops.swapMin = 9
Backdrops.swapMax = 17

return Backdrops
