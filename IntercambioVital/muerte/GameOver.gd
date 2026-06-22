extends Control

func _ready():
	# Forzamos a que el puntero del mouse sea visible para poder clickear
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Esta función se activa automáticamente gracias a la conexión del .tscn
func _on_BotonInicio_pressed():
	# Nos aseguramos de despausar el motor por si acaso
	get_tree().paused = false
	
	# Cargamos de vuelta el menú principal de las ranuras
	get_tree().change_scene("res://Inicio/MenuDeInicio.tscn")
