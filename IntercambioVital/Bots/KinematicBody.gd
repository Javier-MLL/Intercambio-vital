extends KinematicBody

var comida : int = 0
var agua : int = 0
var combustible : int = 0
var metal : int = 0
var madera : int = 0
var cristal : int = 0
var puesto = comida 
var multi_precio_c = 1
var multi_precio_a = 1
var multi_precio_co = 1

func _ready() -> void:
	comida =+ 300
	print(comida)

	

func _process(delta):
	multipli_precio()
	

func multipli_precio():
	if comida < 300:
		multi_precio_c = 2
	elif comida >= 300:
		multi_precio_c = 1
	if agua < 300:
		multi_precio_a = 2
	elif agua >= 300:
		multi_precio_a = 2
	if combustible < 300:
		multi_precio_co = 2
	elif combustible >= 300:
		multi_precio_co = 2

onready var mi_panel = get_node('/root/Spatial/PanelIntercambio')



# Esta función se activa sola cuando alguien entra al área
func _on_Area_body_entered(body):
	if body.is_in_group("jugador"):
		mi_panel.show() # Muestra el panel automáticamente
		print("¡Jugador cerca! Panel abierto.")

# Si el jugador sale del área el panel se esconde
func _on_Area_body_exited(body):
	if body.is_in_group("jugador"):
		mi_panel.hide() # Oculta el panel automáticamente
		print("¡Jugador se ha ido! Panel cerrado.")

# Esta función se activa sola cuando haces clic en el botón de la pantalla
func _on_boton_cerrar_presionado():
	mi_panel.hide() # Esconde el panel de inmediato
	print("Botón presionar. Panel cerrado.")
