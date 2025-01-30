extends Node2D
class_name ObstacleSpawner

@export var pipe_obstacle_scene = load("res://entities/pipe_obstacle/pipe_obstacle.tscn")
@export var min_gapsize_pipes = 100
@export var max_gapsize_pipes = 640
@export var pair_holder: Node
@export var spawn_timeout_timer:Timer

var child_per_pair = 3

var per_position_limits = Vector2(min_gapsize_pipes / 2.0, max_gapsize_pipes / 2.0)

signal obstacle_pair_gen_completed


class ObstaclePair:
  var up_obstacle: Area2D
  var down_obstacle: Area2D
  var score_area: Area2D
  var move_speed: float = 100
  var move_dir: Vector2i = Vector2i(-1, 0)
  var gap_size : float
  var pair_generated = false
  var _created_score_rect = false
  func move(delta:float):
    up_obstacle.position += delta * move_dir * move_speed
    down_obstacle.position += delta * move_dir * move_speed
    score_area.position += delta * move_dir * move_speed


var obstaclePairs: Array[ObstaclePair]

func _ready():
  spawn_timeout_timer.stop()
  if not pair_holder:
    pair_holder = Node.new()
    add_child(pair_holder)
  spawn_timeout_timer.connect(&"timeout",_timer_timeout)

func _timer_timeout():
  spawn_timeout_timer.stop()

func _on_pair_obstacle_despawn(pair_id:int):
  if is_instance_id_valid(pair_id) and pair_id != -1:
    var first_pair = obstaclePairs.front()
    if first_pair:
      if first_pair.get_instance_id() == pair_id:
        var pair = obstaclePairs.pop_front()
        pair.score_area.queue_free()

func spawn_obstacle_pair():
  if spawn_timeout_timer.is_stopped():
    if not pair_holder:
      printerr("ERROR: pair_holder not created")
      return
    var new_pair = ObstaclePair.new()
    var pair_id = new_pair.get_instance_id()
    print(per_position_limits)

    new_pair.gap_size = randf_range(min_gapsize_pipes, max_gapsize_pipes)

    new_pair.up_obstacle = pipe_obstacle_scene.instantiate()
    pair_holder.add_child(new_pair.up_obstacle)
    new_pair.up_obstacle.pair_id = pair_id
    new_pair.up_obstacle.connect("obstacle_despawned",_on_pair_obstacle_despawn)
    new_pair.up_obstacle.position.y = randf_range(-per_position_limits[0], -per_position_limits[1])
    new_pair.up_obstacle.rotate(-PI)

    new_pair.down_obstacle = pipe_obstacle_scene.instantiate()
    pair_holder.add_child(new_pair.down_obstacle)
    new_pair.down_obstacle.pair_id = pair_id
    new_pair.down_obstacle.connect("obstacle_despawned",_on_pair_obstacle_despawn)
    new_pair.down_obstacle.position.y = new_pair.up_obstacle.position.y + new_pair.gap_size
    _create_score_rect_gap(new_pair)
    emit_signal("obstacle_pair_gen_completed")
    new_pair.pair_generated = true
    obstaclePairs.append(new_pair)
    spawn_timeout_timer.start()


func _physics_process(delta):
  for pair in obstaclePairs:
    pair.move(delta)

func _create_score_rect_gap(obst_pair: ObstaclePair):
  obst_pair.score_area = Area2D.new()
  obst_pair.score_area.name = &"score_area"
  pair_holder.add_child(obst_pair.score_area)
  var score_shape_size = Vector2(
        obst_pair.up_obstacle.col_height + abs(obst_pair.up_obstacle.position.y - obst_pair.down_obstacle.position.y),
        obst_pair.up_obstacle.col_width
  )
  print("_create_score_rect_gap: rect_shape_size = %s" % score_shape_size)
  if not obst_pair._created_score_rect:
    var col_shape := CollisionShape2D.new()
    var rect_shape := RectangleShape2D.new()
    rect_shape.size = score_shape_size
    col_shape.shape = rect_shape
    obst_pair.score_area.add_child(col_shape)
    obst_pair._created_score_rect = true
