class_name BattleUI
extends CanvasLayer

enum actionType {FIGHT, POKEMON, BAG, RUN}

signal action_selected(Type : actionType)
signal move_selected(move_index: int)
signal moveReplacementSelected(moveArray: Array[int])
signal pokemon_selected(pokemon_index : int)
signal item_selected(item_id : int)
signal text_finished
signal animStep()
signal choice_made(choice : bool)

@onready var player_info := $PlayerInfo
@onready var enemy_info := $EnemyInfo
@onready var text_box := $textebox
@onready var main_menu := $MainMenu
@onready var move_menu := $movecontainer
@onready var lvlUpMoveContainer: GridContainer = $LvlUpMoveContainer
@onready var yesNoBox: Panel = $textebox/yes_noBox
@onready var TransitionAnim := $AnimationPlayer
@onready var PlayerpokemonContainer := $PlayerInfo/PlayerPokemon
@onready var EnemypokemonContainer := $EnemyInfo/EnemyPokemon


 
@onready var battleManager := get_tree().current_scene.get_node("Battlemanager")

var move_button_connections : Array = []
var current_text = ""
var text_speed := 0.03
var setup1 := false
var setup2 := false
var fight_ongoing := false
var is_displaying_text := false
var start_color_info_panel 

	
func _ready() -> void:
	print("info panel : ", player_info)
	move_menu.visible = false
	lvlUpMoveContainer.visible = false
	yesNoBox.visible = false
	
	start_color_info_panel = player_info.modulate
	main_menu.get_node("FightButton").pressed.connect(func() : action_selected.emit(actionType.FIGHT))
	main_menu.get_node("PokemonButton").pressed.connect(func() : action_selected.emit(actionType.POKEMON))
	main_menu.get_node("BagButton").pressed.connect(func() : action_selected.emit(actionType.BAG))
	main_menu.get_node("EscapeButton").pressed.connect(func() : action_selected.emit(actionType.RUN))

func setup(player_pkm : PokemonInstance, enemy_pkm : PokemonInstance):
	print("POURQUOI TU es APPELÉ deux fois ?")
	if player_pkm :	
		update_pokemon_info(true, player_pkm)
		player_pkm.connect("fainted", remove_pokemon_info.bind(player_info), CONNECT_ONE_SHOT)
		main_menu.visible = false
		setup1 = true
	if enemy_pkm :
		update_pokemon_info(false, enemy_pkm)
		enemy_pkm.connect("fainted", remove_pokemon_info.bind(enemy_info), CONNECT_ONE_SHOT)
		setup2 = true
	if not fight_ongoing and setup1 and setup2:
		TransitionAnim.play("enter_fight")
		fight_ongoing = true
	elif fight_ongoing and setup1 and setup2 :
		player_info.visible = true
		enemy_info.visible = true

func remove_pokemon_info(pokemonInfo : Control):
	if pokemonInfo == enemy_info :
		await EnemypokemonContainer.get_child(0).animation_finished
	else :
		await PlayerpokemonContainer.get_child(0).animation_finished
	print("EnemyPokemonContainer child --> ", EnemypokemonContainer.get_child(0))
	var start_color = pokemonInfo.modulate
	var end_color = start_color
	end_color.a = 0.0

	var tween = create_tween()
	tween.tween_property(pokemonInfo, "modulate", end_color, 1.0)
	await tween.finished
	pokemonInfo.visible = false
	pokemonInfo.modulate = start_color
	
func sendAnimStep():
	animStep.emit()
		
func update_pokemon_info(isally : bool, pokemon_info : PokemonInstance):
	var info_panel
	if isally == true :
		info_panel = player_info
		info_panel.get_node("XpBar").value = pokemon_info.current_xp
	else :
		info_panel = enemy_info
	print("info panel from update_pokemon_info : ", info_panel, " and ", pokemon_info)
	info_panel.get_node("NameLabel").text = pokemon_info.data.pokemon_name
	info_panel.get_node("lvlLabel").text = "Niv. %d" % pokemon_info.level
	var status_label = info_panel.get_node("RichTextLabel")
	if pokemon_info.status != null :
		status_label.text = pokemon_info.status
	else : 
		status_label.text = ""
	update_hp_bar(isally, pokemon_info)
	
func update_xp_bar(pokemon : PokemonInstance , xp_gain : int):
	var xp_bar: ProgressBar = player_info.get_node("XpBar")
	var level_label : Label = player_info.get_node("lvlLabel")
	var remaining_xp = xp_gain
	
	while remaining_xp > 0:
		var xp_needed = pokemon.xp_to_next_level - pokemon.current_xp
		var gained = min(remaining_xp, xp_needed)
		
		var start_value = float(pokemon.current_xp) / pokemon.xp_to_next_level * 100.0
		var target_value = float(pokemon.current_xp + gained) / pokemon.xp_to_next_level * 100.0
		
		xp_bar.value = start_value
		
		await animate_xp_bar(xp_bar, target_value)
		pokemon.current_xp += gained
		remaining_xp -= gained
		if pokemon.current_xp >= pokemon.xp_to_next_level:
			pokemon.lvl_up()
			level_label.text = "Niv. %d" % pokemon.level
			xp_bar.value = 0

func animate_xp_bar(xp_bar : ProgressBar, target_value : int ):
	var tween = create_tween()
	tween.tween_property(xp_bar, "value", target_value, 0.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	
func update_hp_bar(isally : bool, pokemon_info : PokemonInstance):
	var info_panel
	if isally == true : 
		info_panel = player_info
	else : 
		info_panel = enemy_info
	var hp_bar = info_panel.get_node("HpBar")
	var hp_label = info_panel.get_node("hpLabel")
	
	var target_value  = pokemon_info.current_hp * 100 / pokemon_info.max_hp
	hp_label.text = "%d/%d" % [pokemon_info.current_hp, pokemon_info.max_hp]
	var tween = create_tween()
	tween.tween_property(
		hp_bar,
		"value",
		target_value,
		0.5 # durée en secondes peut etre cool d'ajouter une variation + de degats + de temps 
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_callback(func():
		update_hp_color(hp_bar))
	await tween.finished	
func update_hp_color(hp_bar: ProgressBar):
	if hp_bar.value > 50:
		hp_bar.modulate = Color.GREEN
	elif hp_bar.value > 20:
		hp_bar.modulate = Color.ORANGE
	else:
		hp_bar.modulate = Color.RED
		
func display_text(text : String):
	if is_displaying_text == true :
		await text_finished
	is_displaying_text = true
	text_box.get_node("textLabel").text = ""
	current_text = text
	animate_text()

func disable_button():
	for child in main_menu.get_children():
		if child is Button :
			child.visible = false

func enable_button():
	for child in main_menu.get_children():
		if child is Button :
			child.visible = true
func animate_text():
	var label = text_box.get_node("textLabel")
	print(current_text)
	for i in range(current_text.length()):
		label.text += current_text[i]
		await get_tree().create_timer(text_speed).timeout
	
	is_displaying_text = false
	await get_tree().create_timer(1.0).timeout
	text_finished.emit()

func show_main_menu():
	main_menu.visible = true
	
func hide_move():
	move_menu.visible = false
	 
func show_text():
	text_box.visible = true

func get_type_color(type : int):
	var modulate_level :float = 0.6
	match type :
				1 :
					return Color(Color.GRAY, modulate_level)
				2 :
					return Color(Color.RED, modulate_level)
				3 :
					return Color(Color.BLUE, modulate_level)
				4 :
					return Color(Color.WEB_GREEN, modulate_level)
				5 :
					return Color(Color.YELLOW, modulate_level)
				6 :
					return Color(Color.DEEP_SKY_BLUE, modulate_level)
				7 :
					return Color(Color.CORAL, modulate_level)
				8 :
					return Color(Color.REBECCA_PURPLE, modulate_level) 
				9 :
					return Color(Color("#E2B86B"), modulate_level)
				10 :
					return Color(Color.SKY_BLUE, modulate_level)
				11 :
					return Color(Color.PALE_VIOLET_RED, modulate_level)
				12 :
					return Color(Color.GREEN_YELLOW, modulate_level)
				13 :	
					return Color(Color.SADDLE_BROWN, modulate_level)
				14 :
					return Color(Color.MEDIUM_PURPLE, modulate_level)
				15:
					return Color(Color.DARK_SLATE_BLUE, modulate_level)
				16:
					return Color(Color("2B1E2E"), modulate_level)
				17:
					return Color(Color("9FA8B2"), modulate_level)
				18: 
					return Color(Color.PINK, modulate_level)
					
func disconnect_move_button():
	for connection in move_button_connections:
		if connection.button.pressed.is_connected(connection.callable):
			connection.button.pressed.disconnect(connection.callable)
	move_button_connections.clear()
						
func show_move_menu(pokemon : PokemonInstance):
	#hide_all_menu()
	text_box.visible = false
	move_menu.visible = true

	disconnect_move_button()
	for i in range(4):
		var button = move_menu.get_node("Move%dButton" % (i + 1))
		if i < pokemon.moves.size():
			var move = pokemon.moves[i]
			print("new move : ", move)
			button.text = "%s\nPP: %d/%d" % [move.name, pokemon.movesPP[move.id], move.max_pp]
			var style = StyleBoxFlat.new()
			var color = get_type_color(move.type)
			style.bg_color = color
			button.add_theme_stylebox_override("normal", style)
			button.disabled = pokemon.movesPP[move.id] <= 0
			
			var callable = func(): _on_move_button_pressed(i)
			button.pressed.connect(callable)
			move_button_connections.append({"button": button, "callable": callable})
			#button.pressed.connect(func(): move_selected.emit(i), CONNECT_ONE_SHOT)
		else:
			button.text = "---"
			button.disabled = true

func showLevelUpMoveMenu(pokemon : PokemonInstance, newMoveID: int):
	#hide_all_menu()
	text_box.visible = false
	move_menu.visible = false
	lvlUpMoveContainer.visible = true
	
	#disconnect_move_button()
	#print("move size 0 ?? :", pokemon.moves.size())
	for i in range(5):
		var button = lvlUpMoveContainer.get_node("Move%dButton" % (i + 1))
		var move: CT_data
		if i < pokemon.moves.size():
			move = pokemon.moves[i]
			print("new move : ", move)
			button.text = "%s\nPP: %d/%d" % [move.name, pokemon.movesPP[move.id], move.max_pp]
		else:
			move = Game.get_move_data(newMoveID)
			button.text = "%s\nPP: %d" % [move.name, move.max_pp]
		#button.pressed.connect(func(): move_selected.emit(i), CONNECT_ONE_SHOT)
		var style = StyleBoxFlat.new()
		var color = get_type_color(move.type)
		style.bg_color = color
		button.add_theme_stylebox_override("normal", style)
		
		var callable
		if i < pokemon.moves.size():
			callable = func(): moveReplacementSelected.emit([i, 0])
		else:
			callable = func(): moveReplacementSelected.emit([i, 1])
		button.pressed.connect(callable)
		move_button_connections.append({"button": button, "callable": callable})

func askCustomQuestionForLvlUp(text : String, pokemon: PokemonInstance, moveID: int) -> Array:
	var res : Array = []
	yesNoBox.visible = true
	display_text(text)
	var choice = await choice_made
	var oldMove : CT_data
	
	yesNoBox.visible = false
	if choice:
		showLevelUpMoveMenu(pokemon, moveID)
		var moveArray = await moveReplacementSelected
		var moveIndex = moveArray[0]
		var goBack = moveArray[1]
		if goBack == 1:
			disconnect_move_button()
			lvlUpMoveContainer.visible = false
			return [false, oldMove]
		oldMove = pokemon.moves[moveIndex]
		pokemon.learnMove(moveID, moveIndex)
		lvlUpMoveContainer.visible = false
		return [true, oldMove]
	return [true, null]
		
	
func Play_attack_anim(attacker : PokemonNode, defender : PokemonNode, move_used : CT_data):
	var tween = create_tween()
	tween.tween_property(attacker, "position:x", attacker.position.x + 20, 0.1)
	tween.tween_property(attacker, "position:x", attacker.position.x, 0.1)
	defender.flash_white()

func _on_move_button_pressed(move_index : int ):
	move_selected.emit(move_index)
	
#func showPokemonMenu(): A REALISER
#same for bag 


func _process(_delta: float) -> void:
	pass

func hide_all_menu():
	main_menu.visible = false
	move_menu.visible = false


func _on_button_pressed() -> void:
	choice_made.emit(true)


func _on_button_2_pressed() -> void:
	choice_made.emit(false)
