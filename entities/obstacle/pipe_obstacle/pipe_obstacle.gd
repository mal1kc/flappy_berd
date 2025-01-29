class_name PipeObstacle
extends Obstacle

@export var sprite:Sprite2D
@export var collisionShape:CollisionShape2D
@export var head_width:float

func _ready() -> void:
  head_width = collisionShape.shape.x * self.scale.x
  super()
