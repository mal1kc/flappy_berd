extends Node2D
class_name ObstacleSpawner

@export var pipe_obstacle_scene = load("res://entities/pipe_obstacle/pipe_obstacle.tscn")
@export var min_size_between_pipes = 50
@export var max_size_between_pipes = 120
@export var pair_holder: Node




signal obstacle_pair_gen_completed


class ObstaclePair:
  var up_obstacle: Area2D
  var down_obstacle: Area2D
  var score_area: Area2D
  var move_speed: float = 10
  var move_dir: Vector2i = Vector2i(-1, 0)
  var pair_generated = false
  var _created_score_rect = false
  func move(delta:float):
    up_obstacle.position = delta * move_dir * move_speed
    down_obstacle.position = delta * move_dir * move_speed
    score_area.position = delta * move_dir * move_speed

var obstaclePairs: Array[ObstaclePair]

func _ready():
  if not pair_holder:
    pair_holder = Node.new()
    add_child(pair_holder)

func spawn_obstacle_pair():
  if not pair_holder:
    printerr("ERROR: pair_holder not created")
    return
  var new_pair = ObstaclePair.new()
  var per_position_limits = Vector2(min_size_between_pipes / 2.0, max_size_between_pipes / 2.0)

  new_pair.up_obstacle = pipe_obstacle_scene.instantiate()
  pair_holder.add_child(new_pair.up_obstacle)
  new_pair.up_obstacle.position.y = randf_range(-per_position_limits[0], -per_position_limits[1])
  new_pair.up_obstacle.rotate(-180)

  new_pair.down_obstacle = pipe_obstacle_scene.instantiate()
  pair_holder.add_child(new_pair.down_obstacle)
  new_pair.down_obstacle.position.y = randf_range(per_position_limits[0], per_position_limits[1])
  _create_score_rect(new_pair)
  emit_signal("obstacle_pair_gen_completed")
  new_pair.pair_generated = true
  obstaclePairs.append(new_pair)

func _process(delta: float) -> void:
  for pair in obstaclePairs:
    pair.move(delta)

func _create_score_rect(obst_pair: ObstaclePair):
  obst_pair.score_area = Area2D.new()
  obst_pair.score_area.name = &"score_area"
  pair_holder.add_child(obst_pair.score_area)
  var score_shape_size = Vector2(
    abs(obst_pair.up_obstacle.position.y - obst_pair.down_obstacle.position.y),
    obst_pair.up_obstacle.col_width
  )

  print("_create_score_rect: rect_shape_size = %s" % score_shape_size)
  if not obst_pair._created_score_rect:
    var col_shape := CollisionShape2D.new()
    var rect_shape := RectangleShape2D.new()
    rect_shape.size = score_shape_size
    col_shape.shape = rect_shape
    obst_pair.score_area.add_child(col_shape)
    obst_pair._created_score_rect = true
