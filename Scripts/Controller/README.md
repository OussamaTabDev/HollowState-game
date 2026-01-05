# Player Controller State Machine Architecture

## Overview
This is a refactored character controller that uses a finite state machine (FSM) pattern to manage player movement states. The architecture separates concerns between the player controller and individual movement states.

## File Structure

```
Player.gd                 # Main player controller
StateMachine.gd           # State machine manager
State.gd                  # Base state class
States/
  ├── IdleState.gd       # Standing still
  ├── WalkState.gd       # Walking movement
  ├── SprintState.gd     # Running/sprinting
  ├── CrouchState.gd     # Crouched movement
  ├── JumpState.gd       # Jumping (ascending)
  ├── FallState.gd       # Falling (descending)
  ├── LandState.gd       # Landing impact
  ├── SwimState.gd       # Swimming movement
  └── FlyState.gd        # Debug/admin fly mode
```

## Scene Tree Setup

Your scene should be structured like this:

```
Player (CharacterBody3D) - Player.gd
├── StateMachine (Node) - StateMachine.gd
│   ├── Idle (Node) - IdleState.gd
│   ├── Walk (Node) - WalkState.gd
│   ├── Sprint (Node) - SprintState.gd
│   ├── Crouch (Node) - CrouchState.gd
│   ├── Jump (Node) - JumpState.gd
│   ├── Fall (Node) - FallState.gd
│   ├── Land (Node) - LandState.gd
│   ├── Swim (Node) - SwimState.gd
│   └── Fly (Node) - FlyState.gd
├── Pelvis (Node3D)
│   └── Riser (Node3D)
│       └── Head (Node3D)
│           └── Bob (Node3D)
│               └── Impulse (Node3D)
│                   └── Damage (Node3D)
│                       └── Noise (Node3D)
│                           └── Camera (Camera3D)
├── Character (Node)
├── Stand (CollisionShape3D)
├── Crouch (CollisionShape3D)
└── Raycasts (Node3D)
    ├── Above (RayCast3D)
    ├── Below (RayCast3D)
    ├── Left (RayCast3D)
    └── Right (RayCast3D)
```

## Architecture Components

### 1. Player.gd (Main Controller)
**Responsibilities:**
- Physics processing (gravity, movement, collisions)
- Input handling (mouse look, WASD input)
- Core systems (headbob, surface detection, audio)
- Provides data to states through public variables

**Does NOT handle:**
- State-specific logic
- State transitions
- State management

### 2. StateMachine.gd (State Manager)
**Responsibilities:**
- Maintains dictionary of all states
- Tracks current active state
- Handles state transitions via signals
- Forwards `_physics_process` and `_input` to current state

**Key Methods:**
- `on_state_transition(old_state, new_state_name)` - Handles state changes
- `force_transition(new_state_name)` - External state change (e.g., swimming)

### 3. State.gd (Base Class)
**Responsibilities:**
- Provides common interface for all states
- Emits `state_transition` signal
- Stores references to player and game data

**Virtual Methods:**
- `enter()` - Called when entering this state
- `exit()` - Called when leaving this state
- `update(delta)` - Called every physics frame
- `handle_input(event)` - Called for input events

### 4. Individual States
Each state is responsible for:
- Setting appropriate gameData flags on enter
- Updating player speed/movement during update
- Checking transition conditions
- Cleaning up on exit

## State Transition Diagram

```
          ┌─────────┐
          │  Idle   │
          └────┬────┘
               │
        Input detected
               │
               ↓
     ┌─────────────────┐
     │   Walk/Sprint   │←──────┐
     └────┬─────┬──────┘       │
          │     │               │
  Crouch  │     │ Jump         │
   input  │     │               │
          ↓     ↓               │
     ┌────────┐ ┌───────┐      │
     │ Crouch │ │ Jump  │      │
     └────────┘ └───┬───┘      │
                    │           │
              Velocity ≤ 0      │
                    │           │
                    ↓           │
               ┌────────┐       │
               │  Fall  │       │
               └────┬───┘       │
                    │           │
              On floor          │
                    │           │
                    ↓           │
               ┌────────┐       │
               │  Land  │───────┘
               └────────┘
                    
     ┌──────────────────────────┐
     │  Special: Swim / Fly     │
     │  (separate from main FSM)│
     └──────────────────────────┘
```

## State Descriptions

### IdleState
- **Enter:** Player is stationary
- **Transitions to:**
  - Walk: Input detected
  - Crouch: Crouch button pressed
  - Jump: Jump button pressed
  - Fall: Loses ground contact
  - Swim: Enters water

### WalkState
- **Enter:** Player moving at walk speed
- **Transitions to:**
  - Idle: Input stops
  - Sprint: Sprint button (based on sprint mode)
  - Crouch: Crouch button
  - Jump: Jump button
  - Fall: Loses ground contact
  - Swim: Enters water

### SprintState
- **Enter:** Player moving at sprint speed
- **Transitions to:**
  - Idle: Input stops
  - Walk: Sprint released (hold mode) or toggled off
  - Crouch: Crouch button
  - Jump: Jump button
  - Fall: Loses ground contact
  - Swim: Enters water

### CrouchState
- **Enter:** Player crouching (can be moving or stationary)
- **Transitions to:**
  - Idle/Walk: Un-crouch (if space above is clear)
  - Fall: Loses ground contact
  - Swim: Enters water
- **Note:** Cannot jump while crouched

### JumpState
- **Enter:** Player initiates jump, applies upward velocity
- **Transitions to:**
  - Fall: Velocity becomes negative (reached peak)
  - Swim: Enters water mid-jump

### FallState
- **Enter:** Player is descending
- **Transitions to:**
  - Land: Touches ground
  - Swim: Enters water while falling

### LandState
- **Enter:** Player just hit the ground
- **Does:** Plays landing sound, checks fall damage
- **Transitions to:** Immediately transitions to appropriate state:
  - Crouch: If still crouched
  - Walk/Sprint: If moving with input
  - Idle: If stationary

### SwimState
- **Enter:** Player submerged in water
- **Custom Movement:** Uses camera direction for movement
- **Transitions to:**
  - Idle: Surfaces above water threshold
- **Note:** Handles both jump and fall entry with splash effects

### FlyState
- **Enter:** Debug/admin mode activated
- **Custom Movement:** 3D directional flight
- **Transitions to:**
  - Fall: When fly mode disabled

## Sprint Modes

The system supports two sprint modes (configured via `gameData.sprintMode`):

### Mode 1: Hold to Sprint
- Press and hold sprint button to run
- Release to return to walk

### Mode 2: Toggle Sprint
- Press sprint button to toggle sprint on/off
- Remains active until pressed again or crouch

## Key Design Patterns

### 1. Separation of Concerns
- **Player.gd:** Physics, input processing, utilities
- **States:** Logic for specific movement behaviors
- **StateMachine:** Orchestration and transitions

### 2. Signal-Based Communication
```gdscript
# State requests transition
transition_to("Walk")

# Emits signal that StateMachine catches
signal state_transition(old_state: State, new_state_name: String)
```

### 3. Data Access Pattern
States access player data through:
```gdscript
player.currentSpeed    # Direct access to player variables
game_data.isWalking    # Shared game state
player.PlayFootstep()  # Call player methods
```

### 4. Force Transitions
For external systems (like water detection):
```gdscript
state_machine.force_transition("Swim")
```

## Integration Checklist

When integrating this system:

1. **Scene Setup:**
   - [ ] Create StateMachine node as child of Player
   - [ ] Add all state nodes as children of StateMachine
   - [ ] Attach correct scripts to each node

2. **Player Script:**
   - [ ] Add `@onready var state_machine = $StateMachine`
   - [ ] Remove old state management code
   - [ ] Keep physics systems (gravity, movement, headbob)

3. **State Scripts:**
   - [ ] Verify each state has correct class_name
   - [ ] Check state transitions match your game logic
   - [ ] Adjust speeds and values as needed

4. **Testing:**
   - [ ] Test all state transitions
   - [ ] Verify sprint modes work correctly
   - [ ] Check crouch collision switching
   - [ ] Test swimming entry/exit
   - [ ] Verify fall damage triggers

## Customization

### Adding New States
1. Create new script extending State
2. Add it as child node of StateMachine
3. Implement enter/exit/update methods
4. Add transitions to/from other states

### Modifying Transitions
Edit the `update()` method in relevant states:
```gdscript
func update(delta: float):
    # Your state logic...
    
    # Check for transition
    if some_condition:
        transition_to("NewState")
        return
```

### Adjusting Values
Player.gd contains all tunable values:
- Speeds: `walkSpeed`, `sprintSpeed`, `crouchSpeed`
- Jump: `jumpVelocity`, `jumpControl`
- Headbob: Various intensity/speed constants

## Benefits of This Architecture

1. **Maintainability:** Each state is isolated and easy to modify
2. **Debuggability:** Clear state names, easy to log transitions
3. **Extensibility:** Add new states without touching existing code
4. **Testability:** States can be tested independently
5. **Clarity:** State machine makes behavior explicit

## Common Issues & Solutions

### States not transitioning
- Check state names match (case-insensitive)
- Verify states are children of StateMachine
- Check transition conditions in update()

### Player reference is null
- Ensure StateMachine is child of Player
- States get player reference in _ready()

### Multiple states active
- Should never happen with proper enter/exit
- Check for missing return statements after transitions

### Physics feels different
- Core physics still in Player.gd
- States only control currentSpeed and flags
- Check Movement() and Gravity() functions

## Performance Notes

- State machine adds minimal overhead (~1 extra function call per frame)
- Each state only processes when active
- No polling of inactive states
- Signal-based transitions are efficient

## Future Enhancements

Potential additions to consider:
- State stack for complex behaviors (e.g., shoot while walking)
- State history for debugging
- Visual state debugger tool
- Animation state machine integration
- Networked state synchronization
