class_name Berd
extends RigidBody2D

@export var MAX_JUMP_STRENGHT := -1000
@export var MIN_JUMP_STRENGHT := -1500
@onready var _init_pos := global_position
@onready var MainLevel: Level = self.owner
var needs_respawn = false


func _ready() -> void:
  add_to_group(&"RESPAWNABLES", true)


# RESPAWNABLES -> group function
func respawn():
  needs_respawn = true


func _input(event: InputEvent) -> void:
  if not MainLevel.started:
    if event.is_action_pressed(&"berd_jump"):
      MainLevel.started = true
      gravity_scale = 1
    return
  if event.is_action_pressed(&"berd_jump"):
    var impulse_vec := Vector2(
      0, clampf(-1 * linear_velocity.y, MIN_JUMP_STRENGHT, MAX_JUMP_STRENGHT)
    )
    apply_central_impulse(impulse_vec)
  if event.is_action_pressed(&"restart"):
    respawn()


func _integrate_forces(state):
  if needs_respawn:
    state.transform.origin = _init_pos
    needs_respawn = false
    angular_velocity = 0
    gravity_scale = 0


func _on_body_entered(body: Node):
  print("berd is have a collision with %s" % body.name)
  if body is Level:
    MainLevel.emit_signal("game_over")
