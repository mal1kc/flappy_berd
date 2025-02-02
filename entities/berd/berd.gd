class_name Berd
extends RigidBody2D

# @export var MAX_JUMP_STRENGHT := -800
# @export var MIN_JUMP_STRENGHT := -500
@export var jump_force = 400
@onready var _init_pos := global_position
@onready var MainLevel: Level = self.owner
var needs_respawn = false
var first_press = false


func _ready() -> void:
  add_to_group(&"RESPAWNABLES", true)


# RESPAWNABLES -> group function
func respawn():
  needs_respawn = true
  first_press = false


func _input(event: InputEvent) -> void:
  if not MainLevel.started:
    if event.is_action_pressed(&"berd_jump"):
      MainLevel.game_start.emit()
      first_press = true
  if event.is_action_pressed(&"berd_jump"):
    var grav_pull = linear_velocity.y
    var impulse_vec := Vector2(0, -1 * (jump_force + grav_pull))
    apply_central_impulse(impulse_vec)
  if event.is_action_pressed(&"restart"):
    respawn()


func _integrate_forces(state):
  if needs_respawn:
    state.transform.origin = _init_pos
    needs_respawn = false
    angular_velocity = 0
    gravity_scale = 0
    sleeping = true
  if first_press:
    gravity_scale = 1
    sleeping = false


func _on_body_entered(body: Node):
  # print("berd is have a collision with %s" % body.name)
  if body is Level:
    MainLevel.emit_signal("game_over")
