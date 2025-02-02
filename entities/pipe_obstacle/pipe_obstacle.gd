@tool
extends Area2D
class_name PipeObstacle

@onready var root_lvl: Level = self.owner
@onready var sprite_head: Sprite2D = $HeadSprite
@onready var sprite_body: Node2D = $BodySprites
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var col_width: float:
  get():
    return sprite_head.texture.get_width() * sprite_scale.x

@onready var col_height: float:
  get():
    return pipe_length

var pair_id: int = -1

@export var sprite_texture: Texture
@export var pipe_length: float = 100.0
@export var sprite_scale := Vector2(2.4, 2.4)
@export var texture_segment_count: int = 8

@export var sprite_gen: bool:
  set(value):
    _on_gen_sprite_button_pressed()

@export var remove_sprite_gen: bool:
  set(value):
    _on_remove_gen_sprite_button_pressed()


func _on_remove_gen_sprite_button_pressed():
  for child in sprite_body.get_children():
    child.queue_free()
  sprite_head.texture = null


func _on_gen_sprite_button_pressed():
  gen_body()


func gen_body():
  # Clear existing children
  for child in sprite_body.get_children():
    child.queue_free()

    # Calculate the number of segments

    # print("texture_segment_length : %d" % texture_segment_length)
    # print("segment_length : %d" % segment_length)
    # print("num_segments : %d" % num_segments)

    # Create segments

    # reconfigure postions for balance object center
  var texture_segment_length = sprite_texture.get_height() / texture_segment_count
  var segment_length = texture_segment_length * sprite_scale.y
  var num_segments = int(pipe_length / segment_length)
  # print("texture_segment_length : %d" % texture_segment_length)
  # print("segment_length : %d" % segment_length)
  # print("num_segments : %d" % num_segments)

  # Create segments
  for i in range(num_segments):
    var segment = Sprite2D.new()
    segment.texture = sprite_texture
    segment.vframes = texture_segment_count
    segment.frame = 1
    segment.scale = sprite_scale
    segment.position = Vector2(0, i * segment_length)  # Position each segment
    sprite_body.add_child(segment)

    # reconfigure postions for balance object center
  sprite_head.texture = sprite_texture
  sprite_head.vframes = texture_segment_count
  sprite_head.frame = 0
  sprite_head.scale = sprite_scale

  sprite_head.position = Vector2(0, -1 * segment_length * num_segments)

  sprite_body.position = Vector2(0, -1 * segment_length * (num_segments - 1))

  var col_shape_shape = collisionShape.shape as RectangleShape2D
  col_shape_shape.size = Vector2(col_width, segment_length * (num_segments + 1))
  collisionShape.position = Vector2(0, sprite_head.position.y / 2)

  # reconfigure postions for balance object center
  sprite_head.position -= collisionShape.position
  sprite_body.position -= collisionShape.position
  collisionShape.position -= collisionShape.position


## connectd callables must handle [b][color=white]pair_id = -1[/color][/b] to invalid
## @experimental
signal obstacle_despawned(pair_id: int)


func _exit_tree() -> void:
  obstacle_despawned.emit(pair_id)


# called by obstacle_remove_body
## queue_free call with diffrent name
func _remove_obstacle():
  queue_free()


# func _on_obstacle_despawned(_pair_id:int)->void:
#   print("obstacle_pair with {} is despawned".format([pair_id],"{}"))


func _ready() -> void:
  gen_body()
  # connect("obstacle_despawned",_on_obstacle_despawned)


func _on_body_entered(body: Node2D):
  if body.name == &"Berd":
    if root_lvl:
      root_lvl.emit_signal("player_entered_obstacle_area")
