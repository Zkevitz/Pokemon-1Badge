class_name Utils



static func get_type_color(type : int):
	var modulate_level :float = 0.75
	match type :
				1 : #NORMAL 
					return Color(Color.GRAY, modulate_level)
				2 : #FEU 
					return Color(Color.RED, modulate_level)
				3 : #EAU
					return Color(Color.BLUE, modulate_level)
				4 : #PLANTE
					return Color(Color.WEB_GREEN, modulate_level)
				5 : #ELECTRIQUE
					return Color(Color.YELLOW, 1.0)
				6 : #GLACE
					return Color(Color.DEEP_SKY_BLUE, modulate_level)
				7 : #COMBAT
					return Color(Color.CORAL, modulate_level)
				8 : #POISON
					return Color(Color.REBECCA_PURPLE, modulate_level) 
				9 : #SOL
					return Color(Color("#E2B86B"), modulate_level)
				10 : #VOL
					return Color(Color.SKY_BLUE, 0.8)
				11 : #PSY
					return Color(Color.PALE_VIOLET_RED, modulate_level)
				12 : #INSECTE
					return Color(Color.GREEN_YELLOW, modulate_level)
				13 : #ROCHE
					return Color(Color.SADDLE_BROWN, modulate_level)
				14 : #SPECTRE
					return Color(Color.MEDIUM_PURPLE, modulate_level)
				15: #DRAGON
					return Color(Color.DARK_SLATE_BLUE, modulate_level)
				16: #TENEBRES
					return Color(Color("2B1E2E"), modulate_level)
				17: #ACIER
					return Color(Color("9FA8B2"), modulate_level)
				18: #FEE
					return Color(Color.PINK, modulate_level)

static func choose_hp_color(value : int):
	if value > 50:
		return Color.GREEN
	elif value > 20:
		return Color.ORANGE
	else:
		return Color.RED

static func disconnect_all_connections_pressed(object : Object ,signal_name : String = "pressed") -> void:
	if object == null:
		return
	print("Object with signal analyze : ", object)
	var connections = object.get_signal_connection_list(signal_name)
	print("connection on signal : ", signal_name)
	for connection in connections:
		print("connection in signal : ", connection)
		object.disconnect(signal_name, connection.callable)
