extends Sprite2D

func _on_area_2d_area_entered(area):
	$Label2.visible = true


func _on_area_2d_area_exited(area):
	$Label2.visible = false
