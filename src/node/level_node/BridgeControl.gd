extends Area2D

@export var bridgeLayer : TileMapLayer
@export var floorLayer : TileMapLayer

var player_on_bridge := false

func _ready() -> void:
	floorLayer.collision_enabled = true
	bridgeLayer.collision_enabled = false

func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player") and player_on_bridge == false and (local_shape_index == 0 or local_shape_index == 1) :
		player_on_bridge = true
		bridgeLayer.collision_enabled = true
		floorLayer.collision_enabled = false
		playerManager.player_instance.z_index = 1
#
#
func _on_body_shape_exited(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player") and player_on_bridge == true and local_shape_index == 2:
		player_on_bridge = false
		bridgeLayer.collision_enabled = false
		floorLayer.collision_enabled = true
		playerManager.player_instance.z_index = 0
