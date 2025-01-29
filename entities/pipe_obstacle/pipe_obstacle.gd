extends Area2D

@onready var root_lvl: Level = self.owner
@onready var sprite: Sprite2D = $Sprite2D
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var col_width: float = collisionShape.shape.size.x * self.scale.x

signal obstacle_despawned


func _ready() -> void:
  pass

func _on_body_entered(body: Node) -> void:
  print("obstacle {} is have a collision with {}".format([name, body.name],"{}"))
  if body is Level:
    queue_free()
    emit_signal("obstacle_despawned")
