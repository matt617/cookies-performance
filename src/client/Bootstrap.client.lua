--!strict
-- Bootstrap.client.lua
-- Client entry point. Owns nothing but input, camera, and UI. All gameplay state
-- comes from the server over Remotes. UI modules get required from here as they
-- come online.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

Remotes.Event.ShowStateChanged.OnClientEvent:Connect(function(state)
	print("[Cookie] show state ->", state)
end)
