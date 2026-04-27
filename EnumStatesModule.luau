local State = table.freeze({
	Idle = "Idle",
	Patrol = "Patrol",
	Chase = "Chase",
	Attack = "Attack",
	Search = "Search",
	Flee = "Flee",
	LastStand = "LastStand"
})

return State
