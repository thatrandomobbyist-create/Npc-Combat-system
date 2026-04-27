local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NewBrain = require(ReplicatedStorage:WaitForChild("ModuleScripts"):WaitForChild("Brain"))
local npc = script.Parent

local brain = NewBrain(npc)

while true do
	brain:Update()
	npc.Name = brain.state
	task.wait(0.1)
end
