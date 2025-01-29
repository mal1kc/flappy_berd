extends Node2D
class_name ObstaclePair

var score_body : StaticBody2D
var obstacles:Array[Obstacle]
var obstacle_delete_counter = 0

var _created_score_rect = false

var move_speed:float = 0
var move_dir:Vector2i = Vector2i(-1,0)

signal obstacle_pair_gen_completed

func obstacle_deleted():
  # TODO: this is bug hungry code for more score
  obstacle_delete_counter = obstacle_delete_counter + 1
  if obstacle_delete_counter >= obstacles.size():
    queue_free()

func _ready():
  if not score_body:
    score_body = StaticBody2D.new()
    score_body.name = &"score_body"
  add_child(score_body)

func create_score_rect(rect_shape_size:Vector2):
  if not _created_score_rect:
    var col_shape = CollisionShape2D.new()
    var rect_shape = RectangleShape2D.new()
    rect_shape.size = rect_shape_size
    col_shape.shape = rect_shape
    score_body.add_child(col_shape)
    _created_score_rect = true

func generate_pair(obstacle_despawn_limits:Rect2) -> ObstaclePair:
  emit_signal("obstacle_pair_gen_completed")
  for obst in obstacles:
    obst.despawn_limits = obstacle_despawn_limits
  return self
