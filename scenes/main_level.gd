@tool
extends Level


func _ready():
  super()


func spawn_obstaclepair() -> void:
  if not Engine.is_editor_hint():
    obstacle_spawner.spawn_obstacle_pair()


func _process(_delta: float) -> void:
  if not Engine.is_editor_hint():
    if get_obstacle_pair_count() < MAX_OBSTACLEPAIR_LIMIT:
      obstacle_spawner.spawn_obstacle_pair()
