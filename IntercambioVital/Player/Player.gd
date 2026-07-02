extends KinematicBody

var comida : int = 0
var agua : int = 0
var combustible : int = 0
var metal : int = 0
var madera : int = 0
var cristal : int = 0
var necesario : int = 0
var dias_sobrevividos : int = 0
export var tiempo_poner : int = 180
onready var tiempo_restante: int = 0
onready var tiempo = get_node("/root/Spatial/Player/Timer")

onready var comida_l = get_node('/root/Spatial/InterfazUsuario/CanvasLayer/MarginContainer/VBoxContainer/Label')
onready var agua_l = get_node('/root/Spatial/InterfazUsuario/CanvasLayer/MarginContainer/VBoxContainer/Label2')
onready var combustible_l = get_node('/root/Spatial/InterfazUsuario/CanvasLayer/MarginContainer/VBoxContainer/Label3')
onready var metal_l = get_node('/root/Spatial/InterfazUsuario/CanvasLayer/MarginContainer/VBoxContainer2/Label')
onready var madera_l = get_node('/root/Spatial/InterfazUsuario/CanvasLayer/MarginContainer/VBoxContainer2/Label2')
onready var cristal_l =  get_node('/root/Spatial/InterfazUsuario/CanvasLayer/MarginContainer/VBoxContainer2/Label3')
onready var tiempo_l = get_node('/root/Spatial/InterfazUsuario/CanvasLayer/Panel/Label')


#fisicas
var moveSpeed : float = 5.0
var jumpForce : float = 5.0
var gravity : float = 12.0

#camara
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var camaraSens : float  = 0.1 # Bajada un poco porque ahora responde al instante
onready var camera = get_node("CameraOrbit/Camera")

#vectores
var vel : Vector3 = Vector3()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	randomize()
	dias_sobrevividos = cargar_progreso()
	crear_puesto()
	iniciar_timer()
	tiempo.connect("timeout", self, "_on_Timer_dia_completado")

func _process(delta):
	if tiempo:
		tiempo_restante = int(tiempo.time_left)
	actualizar_label()

func _input(event: InputEvent) -> void:
	# REPARADO: El giro se calcula aquí al milisegundo exacto en que se mueve el ratón
	if event is InputEventMouseMotion:
		# Rotar la cámara arriba/abajo (eje X) de inmediato sin delta
		camera.rotation_degrees.x -= event.relative.y * camaraSens
		# Limitar la rotación vertical
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
		
		# Rotar el cuerpo del jugador izquierda/derecha (eje Y) de inmediato sin delta
		rotation_degrees.y -= event.relative.x * camaraSens
	
func _physics_process(delta: float) -> void:
	# Reiniciar x y z de Velocidad cada cuadro
	vel.x = 0
	vel.z = 0
	
	# Control de la gravedad acumulada
	if is_on_floor():
		vel.y = 0
		if Input.is_action_just_pressed("ui_accept"):
			vel.y = jumpForce
	else:
		vel.y -= gravity * delta
	
	var input = Vector2()
	
	# Input de movimiento
	if Input.is_action_pressed("ui_up"):
		input.y -= 1
	if Input.is_action_pressed("ui_down"):
		input.y += 1
	if Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_action_pressed("ui_right"):
		input.x += 1
	
	input = input.normalized()
	
	var adelante = global_transform.basis.z
	var derecha = global_transform.basis.x
	
	# Poner la velocidad basándose en la mirada
	vel.z = (adelante * input.y + derecha * input.x).z * moveSpeed
	vel.x = (adelante * input.y + derecha * input.x).x * moveSpeed
	
	vel = move_and_slide(vel, Vector3.UP)

func actualizar_label():
	comida_l.text = 'Comida: ' + str(comida) + '/' + str(necesario)
	agua_l.text = 'Agua: ' + str(agua) + '/' + str(necesario)
	combustible_l.text = 'Combustible: ' + str(combustible) + '/' + str(necesario)
	metal_l.text = 'Metal: ' + str(metal) + '/' + str(necesario)
	madera_l.text = 'Madera: ' + str(madera) + '/' + str(necesario)
	cristal_l.text = 'Cristal: ' + str(cristal) + '/' + str(necesario)
	tiempo_l.text = 'Día: ' + str(dias_sobrevividos) + ' | Tiempo: ' + str(tiempo_restante)

func crear_puesto():
	var numero = (randi() % 6) 
	print (str(numero))
	var puesto
	
	if numero == 0:
		puesto = comida
		comida += 150
	elif numero == 1:
		puesto = agua
		agua += 150
	elif numero == 2:
		puesto = combustible
		combustible += 150
	elif numero == 3:
		puesto = metal
		metal += 150
	elif numero == 4:
		puesto = madera
		madera += 150
	elif numero == 5:
		puesto = cristal
		cristal += 150
func iniciar_timer():
	tiempo.start(tiempo_poner)
	

func revisar_materias():
	if comida < necesario or agua < necesario or combustible < necesario:
		morir()
	else:
		if comida >= necesario or agua >= necesario or combustible >= necesario:
			iniciar_timer()
			

func morir():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Borra el archivo para dejar la ranura vacía en el menú
	var dir = Directory.new()
	var ruta = "user://partida_" + str(Global.slot_activo) + ".sav"
	if dir.file_exists(ruta):
		dir.remove(ruta)
		
	get_tree().change_scene("res://muerte/GameOver.tscn")

func _on_Timer_dia_completado():
	# 1. PASO ESENCIAL: Comprobamos si el jugador tiene suficiente para sobrevivir
	if comida < necesario or agua < necesario or combustible < necesario:
		morir()
		return # El return detiene el código aquí para que no ejecute lo de abajo si moriste
		
	# 2. Si sobrevivió, consume los recursos básicos del día
	comida -= necesario
	agua -= necesario
	combustible -= necesario
	
	# 3. Sumamos el día superado y guardamos de inmediato en su ranura
	dias_sobrevividos += 1
	guardar_progreso(dias_sobrevividos)
	print("¡Día completado con éxito! Iniciando día: ", dias_sobrevividos)
func guardar_progreso(dias):
	var archivo = File.new()
	var ruta = "user://partida_" + str(Global.slot_activo) + ".sav"
	if archivo.open(ruta, File.WRITE) == OK:
		archivo.store_var(dias)
		archivo.close()

func cargar_progreso() -> int:
	var archivo = File.new()
	var ruta = "user://partida_" + str(Global.slot_activo) + ".sav"
	if archivo.file_exists(ruta):
		archivo.open(ruta, File.READ)
		var dias = archivo.get_var()
		archivo.close()
		return dias
	return 0

