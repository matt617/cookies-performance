--!strict
-- BackdropController.server.lua
-- Keeps one stage backdrop always showing, and rotates the backdrop at random while a
-- show is running. Driven by the ReplicatedStorage "ShowActive" attribute, which the
-- game loop flips true/false. Decoupled on purpose: the moment the show system sets that
-- flag, the backdrop starts cycling, and it settles back to the default between shows.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Backdrops = require(ReplicatedStorage.Shared.Backdrops)

-- Find the backdrop frame, and build the SurfaceGui + ImageLabel if they are not there
-- yet, so this works whether the venue was hand-built or rebuilt by WorldBuilder.
local function ensureImage(): ImageLabel?
	local venue = Workspace:FindFirstChild("Venue")
	local stage = venue and venue:FindFirstChild("Stage")
	local frame = stage and stage:FindFirstChild("BackdropFrame")
	if not (frame and frame:IsA("BasePart")) then
		return nil
	end

	local display = frame:FindFirstChild("BackdropDisplay")
	if not display then
		local sg = Instance.new("SurfaceGui")
		sg.Name = "BackdropDisplay"
		sg.Face = Enum.NormalId.Back -- the face pointing at the stage and crowd
		sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		sg.PixelsPerStud = 20
		sg.Parent = frame
		display = sg
	end

	local img = display:FindFirstChild("BackdropImage")
	if not img then
		local label = Instance.new("ImageLabel")
		label.Name = "BackdropImage"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.ScaleType = Enum.ScaleType.Stretch
		label.Parent = display
		img = label
	end

	return (img:IsA("ImageLabel") and img) or nil
end

local img = ensureImage()
if not img then
	warn("[Backdrop] BackdropFrame not found; backdrop rotation disabled")
	return
end

-- one always showing
if img.Image == "" then
	img.Image = Backdrops.default
end

-- generation bumps every time the show state changes, so a stale rotation loop stops
local generation = 0

local function pickDifferent(current: string): string
	local choices = {}
	for _, b in Backdrops.all do
		if b.imageId ~= current then
			table.insert(choices, b.imageId)
		end
	end
	if #choices == 0 then
		return current
	end
	return choices[math.random(1, #choices)]
end

-- recursive task.delay (not a while loop) so the sandbox and resume stay happy
local function rotate(myGen: number)
	local function tick()
		if myGen ~= generation then
			return
		end
		img.Image = pickDifferent(img.Image)
		task.delay(math.random(Backdrops.swapMin, Backdrops.swapMax), tick)
	end
	task.delay(math.random(Backdrops.swapMin, Backdrops.swapMax), tick)
end

local function onShowStateChanged()
	generation += 1
	local active = ReplicatedStorage:GetAttribute("ShowActive") == true
	if active then
		-- kick off with an immediate swap so the change reads instantly, then random cadence
		img.Image = pickDifferent(img.Image)
		rotate(generation)
	else
		img.Image = Backdrops.default
	end
end

ReplicatedStorage:GetAttributeChangedSignal("ShowActive"):Connect(onShowStateChanged)
onShowStateChanged()
