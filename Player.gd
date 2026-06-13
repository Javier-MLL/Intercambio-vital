extends KinematicBody

#materias primas
export var comida : int = 0
export var agua : int = 0
export var combustible : int = 0
export var madera : int = 0
export var metales : int = 0

#dinero
export var dinero : int = 0
export var gemas : int = 0

var tipo : String = ''
var esta_vivo : bool = true

var tiempo_para_oleada : float = 120.0 # 2 minutos de juego


func _ready():
	randomize()
	
	var opcion_azar = int(randf() *5)
	
	if opcion_azar == 0:
		tipo = "Comida"
		comida = 150
		combustible = 10
		madera = 5
		metales = 0
	elif opcion_azar == 1:
		tipo = "Combustible"
		comida = 10
		combustible = 150
		madera = 0
		metales = 5
	elif opcion_azar == 2:
		tipo = "Madera"
		comida = 5
		combustible = 0
		madera = 150
		metales = 10
	elif opcion_azar == 3:
		tipo = "Metales"
		comida = 0
		combustible = 5
		madera = 10
		metales = 150
	elif opcion_azar == 4:
		tipo = 'Agua'
		comida = 10
		combustible = 5
		madera = 0
		metales = 5
		agua = 150
	print('Has sido creado. Tipo abundante: ', tipo)

func verificar_supervivencia_oleada(cuota_comida, cuota_combustible, cuota_agua):
	if comida < cuota_comida or combustible < cuota_combustible or agua < cuota_agua:
		esta_vivo = false
		perder_partida()
	else:
		# Si sobrevive, paga el costo de la oleada
		comida -= cuota_comida
		combustible -= cuota_combustible
		agua -= cuota_agua
		
func perder_partida():
	print(" NO CUMPLIÓ LA CUOTA. ¡Ha perdido!")
	queue_free()

func sumar_recurso(nombre_material, cantidad):
	if nombre_material == "Comida":
		comida += cantidad
	elif nombre_material == "Agua":
		agua += cantidad
	elif nombre_material == "Combustible":
		combustible += cantidad
	elif nombre_material == "Madera":
		madera += cantidad
	elif nombre_material == "Metales":
		metales += cantidad
	else:
		print("Error: El material ", nombre_material, " no existe.")

func restar_recurso(nombre_tumaterial, tu_cantidad) -> bool:
	if nombre_tumaterial == "Comida":
		if comida >= tu_cantidad:
			comida -= tu_cantidad
			return true # Operación exitosa
	elif nombre_tumaterial == "Agua":
		if agua >= tu_cantidad:
			agua -= tu_cantidad
			return true
	elif nombre_tumaterial == "Combustible":
		if combustible >= tu_cantidad:
			combustible -= tu_cantidad
			return true
	elif nombre_tumaterial == "Madera":
		if madera >= tu_cantidad:
			madera -= tu_cantidad
			return true
	elif nombre_tumaterial == "Metales":
		if metales >= tu_cantidad:
			metales -= tu_cantidad
			return true
			
	# Si llegó hasta aquí significa que el material no existía o que NO había suficiente cantidad
	print("Error o fondos insuficientes para restar: ", nombre_tumaterial)
	return false # Operación rechazada


func _on_Area_body_entered(body):
	if body.is_in_group('NPC') and body != self:
		print("¡Se detectó un socio comercial cerca! Nombre: ", body.name)

func _physics_process(delta):
   # El tiempo baja segundo a segundo
	tiempo_para_oleada -= delta

	# Si el tiempo llega a 0, se activa la revisión de la oleada
	if tiempo_para_oleada <= 0:
		tiempo_para_oleada = 120.0 # Reiniciamos el reloj para el siguiente día
		verificar_supervivencia_oleada(30, 30, 30) # Pide 30 de cada recurso
