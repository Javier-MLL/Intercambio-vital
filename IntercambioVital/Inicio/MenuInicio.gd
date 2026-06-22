extends Control

onready var boton_slot1 = $ContenedorSlots/BotonSlot1
onready var boton_slot2 = $ContenedorSlots/BotonSlot2
onready var boton_slot3 = $ContenedorSlots/BotonSlot3
onready var titulo_pantalla = $ZonaCentral/TituloJuego

func _ready():
	# Habilitamos el puntero del mouse para navegar por las ranuras
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Leemos los archivos del disco duro para cambiar el texto de los botones
	actualizar_texto_slots()

func _process(delta):
	# Detalle dinámico: El título pulsa sutilmente de tamaño para dar vida al menú
	if titulo_pantalla:
		var escala_pulso = 1.0 + (sin(OS.get_ticks_msec() * 0.005) * 0.04)
		titulo_pantalla.rect_scale = Vector2(escala_pulso, escala_pulso)

func actualizar_texto_slots():
	boton_slot1.text = verificar_archivo_partida(1)
	boton_slot2.text = verificar_archivo_partida(2)
	boton_slot3.text = verificar_archivo_partida(3)

# Comprueba si la ranura está vacía o tiene un progreso guardado
func verificar_archivo_partida(numero_slot: int) -> String:
	var archivo = File.new()
	var ruta = "user://partida_" + str(numero_slot) + ".sav"
	
	if archivo.file_exists(ruta):
		archivo.open(ruta, File.READ)
		var dias = archivo.get_var()
		archivo.close()
		return "Partida " + str(numero_slot) + " - Días: " + str(dias)
	else:
		return "Partida " + str(numero_slot) + " [ Nueva Partida ]"

# Enlaces de eventos para presionar los botones
func _on_BotonSlot1_pressed(): entrar_al_juego(1)
func _on_BotonSlot2_pressed(): entrar_al_juego(2)
func _on_BotonSlot3_pressed(): entrar_al_juego(3)

func entrar_al_juego(slot_elegido: int):
	# Guardamos el número de ranura en el Autoload global
	Global.slot_activo = slot_elegido
	
	# Lanzamos la escena principal del juego en 3D
	get_tree().change_scene("res://Mundo/Mundo.tscn")
