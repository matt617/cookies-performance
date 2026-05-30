--!strict
-- Bootstrap.server.lua
-- Server entry point. Requiring Remotes here is what creates the RemoteEvents
-- folder so clients have something to wait for. Real systems (GameLoop, Queue,
-- Persistence, WorldBuilder) get required from here as they come online.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)

-- Touch the remotes so the folder is built before any client joins.
local _ = Remotes.Event.ShowStateChanged

print(string.format("[Cookie] server up. host=%d", Config.HOST_USER_ID))
