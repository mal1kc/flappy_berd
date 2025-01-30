extends Area2D

@onready var root_lvl: Level = self.owner
@onready var sprite: Sprite2D = $Sprite2D
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var col_width: float = collisionShape.shape.size.x / 2 * scale.x
@onready var col_height: float = collisionShape.shape.size.y / 2 * scale.x

var pair_id: int = -1

signal obstacle_despawned(pair_id: int)


func _ready() -> void:
  pass


func _on_body_entered(body: Node) -> void:
  print("obstacle {} is have a collision with {}".format([name, body.name], "{}"))
  if body is Level:
    queue_free()
    emit_signal("obstacle_despawned", pair_id)
