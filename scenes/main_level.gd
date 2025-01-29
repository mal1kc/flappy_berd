@tool
extends Level


func _ready():
  super()


func spawn_obstaclepair() -> void:
  obstacle_spawner.spawn_obstacle_pair()


func _process(delta: float) -> void:
  if not Engine.is_editor_hint():
    if obstacle_spawner.pair_holder.get_child_count() / 3 < MAX_OBSTACLEPAIR_LIMIT:
      obstacle_spawner.spawn_obstacle_pair()
