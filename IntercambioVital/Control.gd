extends Panel

# --- REFERENCIAS A LA UI ---
onready var panel_pagos = $PanelOpcionesPago
onready var lista_botones_pago = $PanelOpcionesPago/ContenedorBotonesPago

# --- TABLA DE VALORES (EQUIVALENCIAS) ---
# Define el valor interno de cada recurso para calcular los cambios de forma justa
var valores_recursos = {
	"comida": 15,
	"agua": 10,
	"combustible": 30,
	"madera": 5,
	"cristal": 20,
	"metal": 25
}

# --- INVENTARIO REAL DEL JUGADOR ---
# El script del jugador debería modificar este diccionario
var inventario_jugador = {
	"comida": 5,
	"agua": 12,
	"combustible": 2,
	"madera": 40,
	"cristal": 1,
	"metal": 10
}

# Variable para recordar qué quiere comprar el jugador en este instante
var recurso_a_comprar = ""

func _ready():
	# Conectar los botones de la lista de compras del panel anterior
	$SeccionPedir/PedirComida.connect("pressed", self, "_on_recurso_click", ["comida"])
	$SeccionPedir/PedirAgua.connect("pressed", self, "_on_recurso_click", ["agua"])
	$SeccionPedir/PedirCombustible.connect("pressed", self, "_on_recurso_click", ["combustible"])
	$SeccionPedir/PedirMadera.connect("pressed", self, "_on_recurso_click", ["madera"])
	$SeccionPedir/PedirCristal.connect("pressed", self, "_on_recurso_click", ["cristal"])
	$SeccionPedir/PedirMetal.connect("pressed", self, "_on_recurso_click", ["metal"])
	
	# Conexión para el botón de cerrar del sub-panel de pagos
	if $PanelOpcionesPago.has_node("BotonCerrarPago"):
		$PanelOpcionesPago/BotonCerrarPago.connect("pressed", panel_pagos, "hide")

func _process(delta):
	# Muestra el ratón cuando se abre el panel
	if visible == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Se activa al elegir qué quieres obtener
func _on_recurso_click(recurso_deseado):
	recurso_a_comprar = recurso_deseado
	var valor_deseado = valores_recursos[recurso_deseado]
	
	# Limpiar las opciones de pago generadas anteriormente
	for boton in lista_botones_pago.get_children():
		boton.queue_free()
		
	print("Buscando formas de pagar por: ", recurso_deseado)
	
	# Revisar todos los recursos del juego para ofrecerlos como posible "moneda"
	for recurso_pago in valores_recursos.keys():
		# Regla obvia: No puedes pagar comida usando comida
		if recurso_pago == recurso_deseado:
			continue
			
		var valor_pago = valores_recursos[recurso_pago]
		
		# Cálculo matemático: Cuántas unidades de este recurso equivalen al deseado
		# stepify redondea a un decimal para evitar fracciones extrañas
		var cantidad_a_pagar = stepify(float(valor_deseado) / float(valor_pago), 0.1)
		
		# Crear el botón dinámicamente en pantalla
		var nuevo_boton = Button.new()
		nuevo_boton.text = "Pagar con " + str(cantidad_a_pagar) + " de " + str(recurso_pago).to_upper()
		nuevo_boton.text += " (Tienes: " + str(inventario_jugador[recurso_pago]) + ")"
		
		# Validar si el jugador tiene suficiente cantidad de este recurso en su inventario
		if inventario_jugador[recurso_pago] < cantidad_a_pagar:
			nuevo_boton.disabled = true
			nuevo_boton.text += " - Insuficiente"
			
		# Añadir el botón al menú visual de pagos
		lista_botones_pago.add_child(nuevo_boton)
		
		# Conectar el botón al evento de confirmación final
		nuevo_boton.connect("pressed", self, "_on_confirmar_trueque", [recurso_pago, cantidad_a_pagar])
		
	# Desplegar la ventana flotante de opciones de pago
	panel_pagos.show()

# Se ejecuta cuando el jugador selecciona con qué recurso pagar
func _on_confirmar_trueque(recurso_usado, costo):
	# 1. Cobrar el costo del trueque al jugador
	inventario_jugador[recurso_usado] -= costo
	
	# 2. Entregarle el recurso que quería comprar
	inventario_jugador[recurso_a_comprar] += 1
	
	print("--- TRUEQUE REALIZADO CON ÉXITO ---")
	print("Entregaste: ", costo, " de ", recurso_usado)
	print("Recibiste: 1 de ", recurso_a_comprar)
	print("Tu inventario actual: ", inventario_jugador)
	
	# Cerrar la ventana de opciones de pago
	panel_pagos.hide()
