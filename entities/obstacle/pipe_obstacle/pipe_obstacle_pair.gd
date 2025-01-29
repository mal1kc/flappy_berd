extends ObstaclePair
class_name PipeObstaclePair

@export var pipe_obstacle_scene = preload("res://entities/obstacle/pipe_obstacle/pipe_obstacle.tscn")

@export var min_size_between_pipes = 50
@export var max_size_between_pipes = 120

# var obstacles : Array[PipeObstacle]

func generate_pair(obstacle_despawn_limits:Rect2) -> PipeObstaclePair:
  var per_position_limits = Vector2(min_size_between_pipes/2.0,max_size_between_pipes/2.0)
  var up_obstacle = pipe_obstacle_scene.instantiate()
  up_obstacle.position.y = randf_range(-per_position_limits[0],-per_position_limits[1])
  var down_obstacle = pipe_obstacle_scene.instantiate()
  down_obstacle.position.y = randf_range(per_position_limits[0],per_position_limits[1])

  print(down_obstacle)
  print(down_obstacle.head_width)
  var score_shape_size = Vector2(abs(up_obstacle.position.y - down_obstacle.position.y),down_obstacle.head_width)
  obstacles.append(up_obstacle)
  obstacles.append(down_obstacle)
  create_score_rect(score_shape_size)
  super(obstacle_despawn_limits)
  return self
