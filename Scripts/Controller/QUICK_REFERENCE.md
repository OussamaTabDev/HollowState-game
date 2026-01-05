# Quick Reference Guide

## State Transition Cheat Sheet

### From Any State
```gdscript
# Trigger transition
transition_to("StateName")

# Force from external system
state_machine.force_transition("StateName")
```

### Common Transition Checks

**Check for ground:**
```gdscript
if !player.is_on_floor():
    transition_to("Fall")
```

**Check for input:**
```gdscript
if player.inputDirection == Vector2.ZERO:
    transition_to("Idle")
elif player.inputDirection != Vector2.ZERO:
    transition_to("Walk")
```

**Check for jump:**
```gdscript
if Input.is_action_just_pressed("jump") and player.is_on_floor():
    transition_to("Jump")
```

**Check for crouch:**
```gdscript
if Input.is_action_just_pressed("crouch") and player.is_on_floor():
    game_data.isCrouching = !game_data.isCrouching
    transition_to("Crouch" if game_data.isCrouching else "Idle")
```

## State Templates

### Basic Movement State
```gdscript
extends State
class_name MyCustomState

func enter():
    if game_data:
        game_data.isCustomState = true

func update(delta: float):
    if !player:
        return
    
    # Set speed
    player.currentSpeed = lerp(player.currentSpeed, TARGET_SPEED, delta * LERP_RATE)
    
    # Check transitions
    if CONDITION:
        transition_to("NextState")
        return

func exit():
    if game_data:
        game_data.isCustomState = false
```

### State with Input Handling
```gdscript
extends State
class_name InteractiveState

func handle_input(event: InputEvent):
    if event.is_action_pressed("special_action"):
        # Handle special input
        transition_to("SpecialState")
```

## Common Patterns

### Speed Lerping
```gdscript
# Slow lerp (smoother)
player.currentSpeed = lerp(player.currentSpeed, targetSpeed, delta * 2.5)

# Fast lerp (more responsive)
player.currentSpeed = lerp(player.currentSpeed, targetSpeed, delta * 5.0)
```

### Sprint Mode Handling

**Mode 1 (Hold):**
```gdscript
if Input.is_action_pressed("sprint"):
    transition_to("Sprint")
```

**Mode 2 (Toggle):**
```gdscript
if Input.is_action_just_pressed("sprint"):
    player.sprintToggle = !player.sprintToggle

if player.sprintToggle:
    transition_to("Sprint")
```

### Collision Switching
```gdscript
# Enable crouch collider
player.standCollider.disabled = true
player.crouchCollider.disabled = false

# Enable stand collider
player.standCollider.disabled = false
player.crouchCollider.disabled = true
```

### Impulse Triggering
```gdscript
# Trigger camera impulse
player.jumpImpulse = 0.1   # Jump impact
player.landImpulse = 0.1   # Landing impact
player.crouchImpulse = 0.1 # Crouch down
player.standImpulse = 0.1  # Stand up
```

## GameData Flags Reference

### Movement States
```gdscript
game_data.isIdle      # Standing still
game_data.isMoving    # Any movement
game_data.isWalking   # Walking speed
game_data.isRunning   # Sprinting speed
game_data.isCrouching # Crouched (moving or not)
```

### Physics States
```gdscript
game_data.isGrounded  # On floor
game_data.isFalling   # Descending
game_data.isSwimming  # In water
game_data.isFlying    # Debug fly mode
```

### Impulse Flags (Camera Effects)
```gdscript
game_data.jump   # Jump camera bob
game_data.land   # Landing camera bob
game_data.crouch # Crouch camera bob
game_data.stand  # Stand camera bob
```

### Environment
```gdscript
game_data.surface      # "Grass", "Dirt", "Asphalt", etc.
game_data.isWater      # Standing in shallow water
game_data.isSubmerged  # Fully underwater
game_data.season       # 1=Normal, 2=Winter
```

### Player Condition
```gdscript
game_data.overweight   # Carrying too much
game_data.fracture     # Injured leg
game_data.bodyStamina  # Stamina value
```

### Camera/Aiming
```gdscript
game_data.isAiming     # ADS active
game_data.isScoped     # Looking through scope
game_data.freeze       # Input disabled
```

## Player Variables Reference

### Speeds
```gdscript
player.currentSpeed   # Active speed (lerped)
player.walkSpeed      # 2.5
player.sprintSpeed    # 5.0
player.crouchSpeed    # 1.0
player.swimSpeed      # 2.0
```

### Physics
```gdscript
player.velocity          # CharacterBody3D velocity
player.movementDirection # Normalized direction vector
player.inputDirection    # Raw input Vector2
player.inertia           # Movement modifier (0.6-1.0)
```

### Jump
```gdscript
player.jumpVelocity    # 7.0 (vertical impulse)
player.hasJumped       # Currently in/from jump
player.hasLanded       # Just landed flag
```

### Fall
```gdscript
player.fallStartLevel  # Y position when falling started
player.fallThreshold   # 5.0 (units before damage)
```

### Node References
```gdscript
player.pelvis          # Body pivot
player.head            # Head pivot
player.camera          # Camera3D
player.standCollider   # Standing collision
player.crouchCollider  # Crouched collision
player.above           # Raycast above head
player.below           # Raycast to ground
```

## Audio Playback

### Footsteps
```gdscript
player.PlayFootstep()      # Regular step
player.PlayFootstepJump()  # Jump step
player.PlayFootstepLand()  # Landing step
```

### Swimming
```gdscript
player.PlaySwimSurface()    # Surface swimming
player.PlaySwimSubmerged()  # Underwater swimming
```

### Movement Foley
```gdscript
player.PlayMovementCloth()  # Always plays
player.PlayMovementGear()   # Only if heavy gear
```

## Debugging Tips

### Print Current State
```gdscript
func _physics_process(delta):
    print("Current State: ", state_machine.current_state.name)
```

### Log Transitions
```gdscript
func on_state_transition(old_state: State, new_state_name: String):
    print("Transition: ", old_state.name, " -> ", new_state_name)
    # ... rest of transition code
```

### Check State Variables
```gdscript
func update(delta: float):
    if Input.is_action_just_pressed("debug"):
        print("Speed: ", player.currentSpeed)
        print("Grounded: ", player.is_on_floor())
        print("Input: ", player.inputDirection)
```

### Visual State Debugger (Optional)
```gdscript
# Add to StateMachine.gd
func _process(_delta):
    if OS.is_debug_build():
        var label = get_node_or_null("../DebugLabel")
        if label:
            label.text = "State: " + current_state.name
```

## Performance Tips

1. **Use return after transitions** to avoid checking multiple conditions
2. **Check expensive conditions last** in your if chains
3. **Cache references** in _ready() instead of getting nodes each frame
4. **Use is_on_floor()** (native) over raycasts when possible
5. **Batch audio instances** when multiple sounds play simultaneously

## Common Mistakes

### ❌ Don't Do This
```gdscript
# Transition without return
if condition:
    transition_to("Walk")
# This code still runs! Bad!

# Setting state flags in multiple places
game_data.isWalking = true  # Fragile!
```

### ✅ Do This
```gdscript
# Always return after transition
if condition:
    transition_to("Walk")
    return

# Let states manage their own flags
func enter():
    game_data.isWalking = true
func exit():
    game_data.isWalking = false
```

## State Lifecycle

```
[State Created]
      ↓
  _ready() called
      ↓
  [Waiting...]
      ↓
  enter() called ← State becomes active
      ↓
  update(delta) called every frame
  handle_input(event) called on input
      ↓
  [State running...]
      ↓
  exit() called ← State becomes inactive
      ↓
  [Waiting...]
```

## Testing Checklist

- [ ] All states can be reached
- [ ] No state can get "stuck"
- [ ] Transitions feel responsive
- [ ] No jarring speed changes
- [ ] Audio plays correctly
- [ ] Colliders switch properly
- [ ] Fall damage triggers correctly
- [ ] Sprint modes work as expected
- [ ] Swimming enters/exits cleanly
- [ ] Crouch/uncrouch is smooth
