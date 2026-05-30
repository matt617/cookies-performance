--!strict
-- Remotes.lua
-- Every RemoteEvent and RemoteFunction is declared once, here. Server and client
-- both require this module so the names can never drift apart. The server is the
-- only side allowed to trust a payload; validate everything that crosses.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FOLDER_NAME = "RemoteEvents"

-- Declare names here. Add to these lists as systems come online.
local EVENTS = {
	"StartShow", -- client asks to start a show (host only, validated server-side)
	"JoinQueue", -- tap the Next Up sign
	"PlayDanceMove", -- Cookie triggers a live move during the show
	"SaveRoutine", -- choreo studio commits a recorded routine
	"SaveCueSheet", -- lights / fx station commits a timeline
	"ThrowEmoji", -- audience reaction
	"ApplauseUpdate", -- server pushes the current meter to all clients
	"ShowStateChanged", -- server broadcasts prep / show / curtain transitions
}

local FUNCTIONS = {
	"GetProfile", -- client pulls its saved routines, sheets, wardrobe
}

local function ensureFolder(): Folder
	local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if existing then
		return existing :: Folder
	end
	-- Only the server creates the instances. Clients wait for them to replicate.
	if RunService:IsServer() then
		local folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
		return folder
	end
	return ReplicatedStorage:WaitForChild(FOLDER_NAME, 10) :: Folder
end

local function ensureChild(folder: Folder, className: string, name: string): Instance
	local existing = folder:FindFirstChild(name)
	if existing then
		return existing
	end
	if RunService:IsServer() then
		local inst = Instance.new(className)
		inst.Name = name
		inst.Parent = folder
		return inst
	end
	return folder:WaitForChild(name, 10)
end

local Remotes = {}
Remotes.Event = {} :: { [string]: RemoteEvent }
Remotes.Function = {} :: { [string]: RemoteFunction }

local folder = ensureFolder()
for _, name in EVENTS do
	Remotes.Event[name] = ensureChild(folder, "RemoteEvent", name) :: RemoteEvent
end
for _, name in FUNCTIONS do
	Remotes.Function[name] = ensureChild(folder, "RemoteFunction", name) :: RemoteFunction
end

return Remotes
