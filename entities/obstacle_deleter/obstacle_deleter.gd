extends Area2D
class_name ObstacleDeleter


func _on_area_entered(area: Area2D) -> void:
  if area is PipeObstacle:
    area._remove_obstacle()
