local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local Brain = {}

local States = require(ReplicatedStorage.Enums.States)

local function randomVector3InCircle(radius)
	local theta = math.random() * 2 * math.pi
	local r = math.sqrt(math.random()) * radius

	local x = r * math.cos(theta)
	local z = r * math.sin(theta)

	return Vector3.new(x, 0, z)
end

local function getClosestPlayer(part)
	local closestPlayer = nil
	local shortestDistance = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local hrp = character.HumanoidRootPart
			local distance = (hrp.Position - part.Position).Magnitude

			if distance < shortestDistance then
				shortestDistance = distance
				closestPlayer = player
			end
		end
	end

	return closestPlayer, shortestDistance
end

local function NewBrain(Npc)
	local Brain = {}

	Brain.state = States.Idle	
	Brain.FOV = 180
	Brain.MAX_DIST = 50
	Brain.Npc_Root = Npc.HumanoidRootPart
	Brain.Humanoid = Npc.Humanoid
	Brain.Humanoid.WalkSpeed = 20
	Brain.lastseentime = 0
	Brain.PatrolDuration = 30
	Brain.lastKnownPosition = nil
	Brain.searchStartTime = 0
	Brain.SearchDuration = 1
	Brain.LastPathTime = 0
	Brain.PathCooldown = 0.1


	function Brain:InVision()
		
		local target, _ = getClosestPlayer(Brain.Npc_Root)
		
		if not target then return false end

		local targetCharacter = target.Character or target.CharacterAdded:Wait()
		local targetRoot = targetCharacter:WaitForChild("HumanoidRootPart")

		local directionToTarget = (targetRoot.Position - Brain.Npc_Root.Position)
		local distance = directionToTarget.Magnitude
		
		if distance > Brain.MAX_DIST then
			return false
		end
		
		local forward = Brain.Npc_Root.CFrame.LookVector
		local directionUnit = directionToTarget.Unit
		
		local dot = forward:Dot(directionUnit)
		
		local angle = math.deg(math.acos(dot))
		
		return angle < (Brain.FOV / 2), targetRoot, targetCharacter
	end
	
	function Brain:ChaseTarget(target: Vector3)
		
		if tick() - Brain.LastPathTime > Brain.PathCooldown then
			Brain.LastPathTime = tick()
			local path = PathfindingService:CreatePath({
				AgentRadius = 2,
				AgentHeight = 5,
				AgentCanJump = true,
				AgentJumpHeight = 10,
				AgentMaxSlope = 45,
			})

			path:ComputeAsync(Brain.Npc_Root.Position, target)

			if path.Status == Enum.PathStatus.Success then
				local waypoints = path:GetWaypoints()

				for _, waypoint in ipairs(waypoints) do
					Brain.Humanoid:MoveTo(waypoint.Position)

					if waypoint.Action == Enum.PathWaypointAction.Jump then
						Brain.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			else
				warn("Pathfind Failed")
			end
		end
		
	end
	
	function Brain:Chase()
		local PlayerFounded, targetroot, TargetInstance = Brain:InVision()
		if PlayerFounded then
			Brain:ChaseTarget(targetroot.Position)
		end
	end
	
	function Brain:Patrol()
		local RandomVector = Brain.Npc_Root.Position + randomVector3InCircle(100)
		self:ChaseTarget(RandomVector)
	end
	
	function Brain:Search()
		if self.lastKnownPosition then
			self:ChaseTarget(self.lastKnownPosition)
		end
	end
	
	function Brain:Attack(targetCharacter)
		local humanoid = targetCharacter:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:TakeDamage(5)
		end
	end
	function Brain:LastStand(targetRoot)
		self:ChaseTarget(targetRoot.Position)
	end
	
	function Brain:Flee(fleeTargetPos: Vector3)
		self:ChaseTarget(fleeTargetPos)
	end
	
	function Brain:Idle() end
	
	function Brain:Update()
		Brain.Health = Brain.Humanoid.Health
		local seen, targetRoot, TargetCharacter = Brain:InVision()
		
		if not TargetCharacter or not targetRoot then return end
	
		local distance = (self.Npc_Root.Position - targetRoot.Position).Magnitude
		local directionToPlayer = (targetRoot.Position - self.Npc_Root.Position).Unit
		local npcLook = self.Npc_Root.CFrame.LookVector
		local directionOppositeToPlayer = (self.Npc_Root.Position - targetRoot.Position).Unit
		local humanoid = TargetCharacter:WaitForChild("Humanoid")
		local targetHealth = humanoid.Health
		
		local fleeDistance = 50
		
		local fleeTargetPos = self.Npc_Root.Position + directionOppositeToPlayer * fleeDistance

		local dot = npcLook:Dot(directionToPlayer)

		local Infront = dot > 0
		
		if seen then
			self.state = States.Chase
			self.lastseentime = tick()
			self.lastKnownPosition = targetRoot.Position
			if distance <= 6 and Infront then
				self.state = States.Attack
			end
		else
			local timeSinceSeen = tick() - self.lastseentime
			
			if timeSinceSeen <= self.SearchDuration then
				self.state = States.Search
			elseif timeSinceSeen <= self.PatrolDuration then
				self.state = States.Patrol
			else
				self.state = States.Idle
			end
		end
		if self.Health <= 40 and targetHealth > 20 and self.Health > 10 then
			Brain.Humanoid.WalkSpeed = 10
			self.state = States.Flee
		elseif self.Health <= 10 then
			self.state = States.LastStand
		end
		
		if self.state == States.Idle then
			self:Idle()
		elseif self.state == States.Chase then
			self:Chase()
		elseif self.state == States.Patrol then
			self:Patrol()
		elseif self.state == States.Search then
			self:Search()
		elseif self.state == States.Attack then
			self:Attack(TargetCharacter)
		elseif self.state == States.Flee then
			self:Flee(fleeTargetPos)
		elseif self.state == States.LastStand then
			self:LastStand(targetRoot)
		end
	end

	return Brain
end

return NewBrain
