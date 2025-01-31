extends Node2D
class_name ObstacleSpawner

@onready var level:Level  = self.owner
@export var pipe_obstacle_scene = load("res://entities/pipe_obstacle/pipe_obstacle.tscn")
@export var min_gapsize_pipes = 100
@export var max_gapsize_pipes = 200
# min/max gap_size_position limit is -,+
@export var gap_position_limit_vertical = 300
@export var obstacle_deleter : ObstacleDeleter
@export var pair_holder: Node
@export var spawn_timeout_timer:Timer

var child_per_pair = 3


signal obstacle_pair_gen_completed


class ObstaclePair:
  var up_obstacle: PipeObstacle
  var down_obstacle: PipeObstacle
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
  get_window().size_changed.connect(on_window_size_change)
  
func on_window_size_change():
  gap_position_limit_vertical = (level.window_size.y/2) - (level.window_size.y/2 * 0.3)

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

    new_pair.gap_size = randf_range(min_gapsize_pipes, max_gapsize_pipes)
    var gap_position_vert = randf_range(-gap_position_limit_vertical, gap_position_limit_vertical)
    # print("gap_position_vert : %f",gap_position_vert)
    # print("gap_size : %f",new_pair.gap_size)

    new_pair.up_obstacle = pipe_obstacle_scene.instantiate()

    pair_holder.add_child(new_pair.up_obstacle)
    var up_obstacle = new_pair.up_obstacle
    up_obstacle.position = position
    up_obstacle.pair_id = pair_id
    up_obstacle.connect("obstacle_despawned",_on_pair_obstacle_despawn)
    # can't be dynamicly selected because of position calculation depends lenght
    up_obstacle.pipe_length =  level.window_size.y - gap_position_limit_vertical/2
    up_obstacle.gen_body()
    up_obstacle.rotate(PI)
    up_obstacle.position.y = gap_position_vert - (up_obstacle.collisionShape.shape.size.y / 2)


    new_pair.down_obstacle = pipe_obstacle_scene.instantiate()
    pair_holder.add_child(new_pair.down_obstacle)
    var down_obstacle  = new_pair.down_obstacle
    down_obstacle.position = position
    down_obstacle.pair_id = pair_id
    down_obstacle.connect("obstacle_despawned",_on_pair_obstacle_despawn)
    # can't be dynamicly selected because of position calculation depends lenght
    down_obstacle.pipe_length =  level.window_size.y - gap_position_limit_vertical/2
    down_obstacle.gen_body()
    down_obstacle.position.y = gap_position_vert + new_pair.gap_size + (down_obstacle.collisionShape.shape.size.y / 2)

    _create_score_rect_gap(new_pair,gap_position_vert)
    emit_signal("obstacle_pair_gen_completed")
    new_pair.pair_generated = true
    obstaclePairs.append(new_pair)
    spawn_timeout_timer.start()


func _physics_process(delta):
  for pair in obstaclePairs:
    pair.move(delta)

func _create_score_rect_gap(obst_pair: ObstaclePair,gap_position_vert:float):
  obst_pair.score_area = Area2D.new()
  var score_area = obst_pair.score_area
  score_area.name = "score_area" + str(obst_pair.get_instance_id())
  pair_holder.add_child(obst_pair.score_area)
  var score_shape_size = Vector2(
        obst_pair.up_obstacle.col_width,
        obst_pair.gap_size
  )
  score_area.position = Vector2(
    position.x,
    gap_position_vert+obst_pair.gap_size/2
    )

  # print("_create_score_rect_gap: rect_shape_size = %s" % score_shape_size)
  if not obst_pair._created_score_rect:
    var col_shape := CollisionShape2D.new()
    var rect_shape := RectangleShape2D.new()
    rect_shape.size = score_shape_size
    col_shape.shape = rect_shape
    obst_pair.score_area.add_child(col_shape)
    obst_pair._created_score_rect = true
