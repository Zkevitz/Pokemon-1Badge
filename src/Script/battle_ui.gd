class_name BattleUI
extends CanvasLayer

enum actionType {FIGHT, POKEMON, BAG, RUN}

signal action_selected(Type : actionType)
signal move_selected(move_index: int)
signal moveReplacementSelected(moveArray: Array[int])
#signal pokemon_selected(pokemon_index : int)
#signal item_selected(item_id : int)
signal text_finished
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
@onready var EnemyMarker2d := $Marker2D2
@onready var AllyMarker2d := $Marker2D
@onready var BackgroundTexture := $TextureRect


var move_button_connections : Array = []
var current_text = ""
var text_speed := 0.04
var fight_ongoing := false
var is_displaying_text := false
var start_color_info_panel 
var battleManager : Battlemanager

	
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
	if player_pkm :	
		update_pokemon_info(true, player_pkm)
		player_pkm.connect("fainted", remove_pokemon_info.bind(player_info), CONNECT_ONE_SHOT)
		main_menu.visible = false
	if enemy_pkm :
		update_pokemon_info(false, enemy_pkm)
		enemy_pkm.connect("fainted", remove_pokemon_info.bind(enemy_info), CONNECT_ONE_SHOT)
	if not fight_ongoing :
		fight_ongoing = true
	if fight_ongoing :
		player_info.visible = true
		enemy_info.visible = true

func start_fight_entrance():
	TransitionAnim.play("enter_fight")
	await TransitionAnim.animation_finished
	
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
	
func entry_text_first_part():
	var enemy_pokemon_name = battleManager.enemy_pokemon.pokemon_name
	if battleManager.is_wild_battle :
		battleManager._queue_text("Un %s apparaît !" % enemy_pokemon_name)
	else :
		battleManager._queu_text("Le dresseur envoie %s !" % enemy_pokemon_name)
	await battleManager._process_text_queue()

func entry_text_second_part():
	var player_pokemon_name = battleManager.player_pokemon.pokemon_name
	battleManager._queue_text("Allez, %s !" % player_pokemon_name)
	await battleManager._process_text_queue()
	
func update_pokemon_info(isally : bool, pokemon_info : PokemonInstance):
	var info_panel
	if isally == true :
		info_panel = player_info
		info_panel.get_node("XpBar").value = float(pokemon_info.current_xp) / pokemon_info.xp_to_next_level * 100.0
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
	
	var target_value  = pokemon_info.Hp_dict["current"] * 100 / pokemon_info.Hp_dict["max"]
	hp_label.text = "%d/%d" % [pokemon_info.Hp_dict["current"], pokemon_info.Hp_dict["max"]]
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

func show_main_menu(Visible : bool = true):
	main_menu.visible = Visible
	
func show_move(Visible : bool = true):
	move_menu.visible = Visible
	
func show_text(Visible : bool = true):
	text_box.visible = Visible
					
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
			var color = Utils.get_type_color(move.type)
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

func showLevelUpMoveMenu(pokemon : PokemonInstance, newMoveID: CT_data):
	#hide_all_menu()
	text_box.visible = false
	move_menu.visible = false
	lvlUpMoveContainer.visible = true
	
	for i in range(5):
		var button = lvlUpMoveContainer.get_node("Move%dButton" % (i + 1))
		var move: CT_data
		var callable
		if i < pokemon.moves.size():
			move = pokemon.moves[i]
			callable = func(): moveReplacementSelected.emit([i, move.id])
			button.text = "%s\nPP: %d/%d" % [move.name, pokemon.movesPP[move.id], move.max_pp]
		else:
			move = newMoveID
			callable = func(): moveReplacementSelected.emit([i, move.id])
			button.text = "%s\nPP: %d/%d" % [move.name, move.max_pp, move.max_pp]
		var style = StyleBoxFlat.new()
		var color = Utils.get_type_color(move.type)
		style.bg_color = color
		button.add_theme_stylebox_override("normal", style)
		
		button.pressed.connect(callable)
		move_button_connections.append({"button": button, "callable": callable})

func askCustomQuestionForLvlUp(text : String, pokemon: PokemonInstance, moveID: CT_data) -> Array:
	#var res : Array = []
	yesNoBox.visible = true
	display_text(text)
	var choice = await choice_made
	var oldMove : CT_data
	
	yesNoBox.visible = false
	if choice:
		showLevelUpMoveMenu(pokemon, moveID)
		var moveArray = await moveReplacementSelected
		var moveIndex = moveArray[0]
		if moveArray[0] == 4 :
			disconnect_move_button()
			lvlUpMoveContainer.visible = false
			return [false, moveID]
		oldMove = pokemon.moves[moveIndex]
		pokemon.learnMove(moveID.id, moveIndex)
		lvlUpMoveContainer.visible = false
		return [true, oldMove]
	return [true, null]
		
	
func Play_attack_anim(attacker : PokemonNode, defender : PokemonNode, _move_used : CT_data, attackAnim : Node2D):
	var tween = create_tween()
	var attack_dir = -20 if attacker.is_opponent else 20
	tween.tween_property(attacker, "position:x", attacker.position.x + attack_dir, 0.1)
	tween.tween_property(attacker, "position:x", attacker.position.x, 0.1)
	await tween.finished
	
	if attackAnim :
		attackAnim.setup_anim()
		print("defender global pos : ", defender.global_position)
		await attackAnim.play_attack(attacker, defender, self)
		attackAnim.queue_free() 
	defender.flash_color(Color.WHITE, 0.3)

func _on_move_button_pressed(move_index : int ):
	move_selected.emit(move_index)
	
func showPokemonMenu():
	var MenuUi = Game.GlobalUI.get_node("MenuUi")
	
#same for bag 

func _on_button_pressed() -> void:
	choice_made.emit(true)


func _on_button_2_pressed() -> void:
	choice_made.emit(false)
