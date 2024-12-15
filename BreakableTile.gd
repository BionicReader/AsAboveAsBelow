extends StaticBody2D
class_name BreakableTile

@export var tilemap: TileMap  # Change @export to a regular var declaration

func break_tile():
	if tilemap:
		var tile_coords = tilemap.local_to_map(global_position)
		
		tilemap.erase_cell(0, tile_coords)
		
		queue_free()
