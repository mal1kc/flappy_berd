@tool

class_name Level
extends StaticBody2D

@export var Player : Berd
@export var MAX_OBSTACLEPAIR_LIMIT := 5
@export var ObstaclePairHolder = Node2D.new()
# @export var boundry_padding = 0.40
@export var boundry_padding = 0.70
@export var started := false
var window_size :Vector2

@export var generate_pair: bool:
    set(value):
        _on_my_button_pressed()

var ObstaclePairTypes: Array[Resource]

signal game_over

func restart():
  started = false
  get_tree().call_group(&"RESPAWNABLES", &"respawn")

func _ready():
  add_child(ObstaclePairHolder)
  get_window().size_changed.connect(setup_level_boundries)
  game_over.connect(on_game_over)
  restart()
  setup_level_boundries()

func on_game_over():
  print("game_over")
  restart()


func setup_level_boundries():
  window_size = get_window().get_viewport().size
  var childos = get_children()
  for n in childos:
    if n.is_in_group(&"level_boundries"):
      remove_child(n)
      n.queue_free()
  var bound_rules = [
      #[Vector2(1, 0), 0], # right
      #[Vector2(-1, 0), -w_size.x + boundry_padding], # left
      [Vector2(0, 1), -window_size.y + (boundry_padding * window_size.y)],
      [Vector2(0, -1), -window_size.y + (boundry_padding * window_size.y)],
    ]
  for bound_indx in bound_rules.size() :
    var shape := WorldBoundaryShape2D.new()
    shape.normal = bound_rules[bound_indx][0]
    shape.distance = bound_rules[bound_indx][1]
    var collision_shape := CollisionShape2D.new()
    collision_shape.debug_color= Color("#f6007a6b")
    collision_shape.name = "bound_%s" % str(bound_indx)
    collision_shape.shape = shape
    add_child(collision_shape)
    collision_shape.add_to_group(&"level_boundries")

func spawn_obstaclepair()-> void:
  pass

func _on_my_button_pressed()->void:
  spawn_obstaclepair()
