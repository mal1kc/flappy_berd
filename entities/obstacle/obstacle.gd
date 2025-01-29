extends StaticBody2D
class_name Obstacle

@export var despawn_limits:Rect2

signal obstacle_despawned

func _ready() -> void:
  pass

func _process(delta):
  if not despawn_limits.has_point(position):
    queue_free()
    emit_signal("obstacle_despawned")
