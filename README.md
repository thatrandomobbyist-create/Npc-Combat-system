# 🧠 NPC AI System (Roblox Luau)

A modular NPC AI system built in Luau featuring state-based behavior, vision detection, pathfinding, and dynamic combat decisions.

---

## 🚀 Overview

This system controls NPC behavior using a **finite state machine**, allowing characters to react dynamically to players based on:

* Line of sight and distance
* Memory of last known player position
* Health-based decision making
* Environmental navigation via pathfinding

The goal of this system is to create NPCs that feel **responsive, reactive, and believable** rather than scripted or predictable.

---

## 🧩 Features

### 🎯 Vision System

* Field-of-view (FOV) based detection using vector math
* Distance-limited perception
* Detects closest player within range

### 🧠 State Machine

NPC behavior is driven by the following states:

* `Idle` – Default inactive state
* `Patrol` – Moves randomly within an area
* `Search` – Investigates last known player position
* `Chase` – Actively follows detected player
* `Attack` – Damages player at close range
* `Flee` – Retreats when health is low
* `LastStand` – Aggressive behavior when critically low

---

### 🏃 Movement & Pathfinding

* Uses Roblox `PathfindingService`
* Recalculates paths frequently for responsiveness
* Non-blocking movement (NPC can adapt to moving targets)

---

### ❤️ Dynamic Behavior

NPC decisions adapt based on:

* Distance to player
* Whether player is in front of NPC
* NPC health vs player health
* Time since player was last seen

---

## ⚙️ How It Works

### 🔍 Vision Detection

The NPC checks:

* Distance to player
* Angle between NPC forward direction and target

If within FOV and range → player is “seen”

---

### 🔁 Update Loop

Every update cycle:

1. Detect player (if visible)
2. Update memory (`lastKnownPosition`)
3. Choose state based on:

   * Visibility
   * Time since last seen
   * Health conditions
4. Execute behavior for current state

---

### 🧠 Decision Flow (Simplified)

* If player is visible → **Chase**
* If close enough → **Attack**
* If player lost → **Search → Patrol → Idle**
* If low health → **Flee**
* If critical health → **LastStand**

---

## 📁 Structure

```

Workspace/
  └──NPC_rig/
      ├── Humanoid
      ├── HumanoidRootPart
      ├── ...
      └── GrantBrain

ReplicatedStorage/
└── Enums/
    └── EnumStatesModule
    ModuleScripts/
    └── BrainModule
```

---

## 🛠️ Usage

### 1. Require the module

```lua
local BrainModule = require(path.to.Brain)
```

### 2. Initialize for an NPC

```lua
local brain = BrainModule(NPC)
```

### 3. Run update loop

```lua
while true do
    brain:Update()
    task.wait()
end
```

---

## ⚠️ Notes

* Pathfinding is recalculated frequently to maintain responsiveness
* Movement is **non-blocking** (NPC does not wait for full path completion)
* Vision system does not currently include line-of-sight raycasting (can be added)

---

## 🧪 Limitations

* No attack cooldown (NPC may deal damage every update tick)
* No obstacle-based vision blocking
* Patrol behavior is random (not waypoint-based)
* Pathfinding may be expensive with many NPCs

---

## 🔧 Possible Improvements

* Add attack cooldown system
* Implement raycast-based line of sight
* Introduce patrol waypoints instead of random movement
* Add state priority system (e.g. Flee overrides Chase cleanly)
* Optimize vision checks for large numbers of NPCs
* Add animations tied to states

---

## 🎯 Design Goals

This system was built to explore:

* Real-time decision making in NPCs
* Balancing responsiveness vs stability
* Modular AI architecture in Roblox
* Combining multiple gameplay systems (movement, combat, perception)

---

## 📌 Summary

This NPC AI system demonstrates:

* Structured state-driven behavior
* Reactive decision-making
* Integration of pathfinding and perception systems

It serves as a foundation for more advanced AI such as:

* Squad behavior
* Stealth systems
* Boss AI patterns

---

## 🧑‍💻 Author Notes

This project represents a step toward building more advanced and reusable gameplay systems. The focus was on making NPCs feel **alive and reactive**, rather than strictly scripted.

---

Add gameplay screenshots or GIFs here to showcase behavior.

