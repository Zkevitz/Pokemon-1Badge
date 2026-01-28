extends CanvasLayer


var is_open = false
@onready var fullMenu := $fullMenu
@onready var pokemonMenu := $PokemonMenu
@onready var pokemonmenuButton := $fullMenu/VBoxContainer/PokemonButton
@onready var pokemonStatmenuButton := $PokemonStatMenu


func _ready() -> void:
	fullMenu.visible = false
	pokemonMenu.visible = false
	pokemonStatmenuButton.visible = false

func show_global_menu():
	fullMenu.visible = true
	
func hide_global_menu():
	fullMenu.visible = false
	pokemonMenu.visible = false

func hide_pokemon_menu():
	pokemonMenu.visible = false
	fullMenu.visible = true
	
func show_pokemon_menu():
	fullMenu.visible = false
	pokemonStatmenuButton.visible = false
	var player_pokemon = playerManager.player_instance.pokemonTeam
	var i = 0
	var buttonlist = pokemonMenu.get_node("MarginContainer/VBoxContainer").get_children()
	buttonlist += pokemonMenu.get_node("MarginContainer2/VBoxContainer2").get_children()
	pokemonMenu.visible = true
	for button in buttonlist :
		if button is Button :
			if i < player_pokemon.size():
				button.icon = player_pokemon[i].data.sprite_frames.get_frame_texture("menu", 0)
				setup_button(button, player_pokemon[i])
			else :
				button.text = "None"
			i += 1
			
func setup_button(button : Button, pokemon : PokemonInstance):
	print("show pokemon stat menu")
	if button.pressed.is_connected(show_pokemon_stat_menu):
		button.pressed.disconnect(show_pokemon_stat_menu)
		
	button.connect("pressed", show_pokemon_stat_menu.bind(pokemon))
	var hp_bar = button.get_node("hpBar")
	var lvlLabel = button.get_node("lvlLabel")
	hp_bar.value = float(pokemon.current_hp * 100 / pokemon.max_hp)
	choose_hp_color(hp_bar)
	print("hp_bar menu value : ", hp_bar.value)
	lvlLabel.text = "Niv. %d" % pokemon.level
	button.text = pokemon.pokemon_name
	
func setup_ct_button(button : Button, move : Dictionary):
	var pplabel = button.get_node("PPlabel")
	var typelabel = button.get_node("typelabel")
	
	button.text = move["name"]
	var current_pp_move = move["pp"]
	var max_pp_move = move["max_pp"]
	pplabel.text = str(current_pp_move) + "/" + str(max_pp_move)
	
	typelabel.text = type_to_string(move["type"])
	
func type_to_string(t: PokemonInstance.Type) -> String:
	if t < 0 or t >= PokemonInstance.Type.size():
		return "Inconnu"
	return PokemonInstance.Type.keys()[t].capitalize()
	
func show_pokemon_stat_menu(pokemon : PokemonInstance):
	print("show pokemon stat menu")
	pokemonStatmenuButton.visible = true
	pokemonMenu.visible = false
	var returnbtn = pokemonStatmenuButton.get_node("BackButton")
	
	if returnbtn.pressed.is_connected(show_pokemon_menu):
		returnbtn.pressed.disconnect(show_pokemon_menu)
		
	returnbtn.connect("pressed", show_pokemon_menu)
	
	# to handle CTinfoButton
	var ctBox = pokemonStatmenuButton.get_node("VBoxContainer")
	var i = 0
	
	for button in ctBox.get_children():
		if button is Button and i < pokemon.moves.size():
			setup_ct_button(button, pokemon.moves[i])
		else :
			button.text = "NONE"
		i += 1
			
	var pokemonSprite = pokemonStatmenuButton.get_node("pokemonSprite")
	pokemonSprite.texture = pokemon.data.sprite_frames.get_frame_texture("idle", 0)
	
	var gridinfo = pokemonStatmenuButton.get_node("GridContainer");
	gridinfo.get_node("pokemonName").text = "Name : %s" % pokemon.pokemon_name
	gridinfo.get_node("pokemonLevel").text = "Level : %d" % pokemon.level
	gridinfo.get_node("pokemonId").text = "ID : %d " % (pokemon.pokemon_id)
	gridinfo.get_node("pokemonTypes").text = "Type(s) : %s " % (type_to_string(pokemon.pokemon_type1) + "/" + type_to_string(pokemon.pokemon_type2) if pokemon.pokemon_type2 != pokemon.Type.AUCUN else type_to_string(pokemon.pokemon_type1))
	var statPanel = pokemonStatmenuButton.get_node("StatPanel")
	var allStats = statPanel.get_node("MarginContainer").get_node("GridContainer")
	for label in allStats.get_children():
		if label is Label :
			print("label name : ", label.name)
			if label.name.begins_with("HP"):
				if label.name.begins_with("HPstat"):
					update_stat_line(label, pokemon.max_hp)
			elif label.name.begins_with("ATKSPE"):
				if label.name.begins_with("ATKSPEstat"):
					update_stat_line(label, pokemon.current_atkSpe)
			elif label.name.begins_with("ATK"):
				if label.name.begins_with("ATKstat"):
					update_stat_line(label, pokemon.current_atk)
			elif label.name.begins_with("DEFSPE"):
				if label.name.begins_with("DEFSPEstat"):
					update_stat_line(label, pokemon.current_defSpe)
			elif label.name.begins_with("DEF"):
				if label.name.begins_with("DEFstat"):
					update_stat_line(label, pokemon.current_def)
			elif label.name.begins_with("SPEED"):
				if label.name.begins_with("SPEEDstat"):
					update_stat_line(label, pokemon.current_speed)
				
	
func choose_hp_color(hp_bar: ProgressBar):
	if hp_bar.value > 50:
		hp_bar.modulate = Color.GREEN
	elif hp_bar.value > 20:
		hp_bar.modulate = Color.ORANGE
	else:
		hp_bar.modulate = Color.RED
		

func update_stat_line(value_to_change : Label, value: int):
	print("value in line: ", value)
	value_to_change.text = str(value)
	
func _input(event: InputEvent) :
	if event.is_action_pressed("openMenu") and is_open == false: 
		show_global_menu()
		is_open = true
	elif event.is_action_pressed("openMenu") and is_open == true:
		hide_global_menu()
		is_open = false
