@tool
extends Level

func _ready():
  super()
  ObstaclePairTypes.append(
    preload("res://entities/obstacle/pipe_obstacle/pipe_obstacle_pair.gd")
    )

func spawn_obstaclepair()-> void:
  var livable_area = get_window().get_viewport().get_visible_rect()
  for obstacle_pair_type in ObstaclePairTypes:
    var obstacle_pair = obstacle_pair_type.new().generate_pair(
        livable_area
        )
    ObstaclePairHolder.add_child(obstacle_pair)
