extends CanvasLayer
class_name MenuUi


var is_open = false
var in_fight_open = false

const STAT_MAP = {
		"HPstat":     ["Hp_dict",     "max"],
		"HPiv":       ["Hp_dict",     "ivs"],
		"ATKSPEstat": ["AtkSpe_dict", "current"],
		"ATKSPEiv":   ["AtkSpe_dict", "ivs"],
		"ATKstat":    ["Atk_dict",    "current"],
		"ATKiv":      ["Atk_dict",    "ivs"],
		"DEFSPEstat": ["DefSpe_dict", "current"],
		"DEFSPEiv":   ["DefSpe_dict", "ivs"],
		"DEFstat":    ["Def_dict",    "current"],
		"DEFiv":      ["Def_dict",    "ivs"],
		"SPEEDstat":  ["Speed_dict",  "current"],
		"SPEEDiv":    ["Speed_dict",  "ivs"],
}

@onready var fullMenu := $fullMenu
@onready var pokemonMenu := $PokemonMenu
@onready var pokemonmenuButton := $fullMenu/VBoxContainer/PokemonButton
@onready var pokemonStatmenuButton := $PokemonStatMenu
@onready var volumeSlider := $fullMenu/VBoxContainer/Panel2/HSlider
@onready var InventoryMenu := $InventoryMenu
	
func _ready() -> void:
	fullMenu.visible = false
	pokemonMenu.visible = false
	pokemonStatmenuButton.visible = false
	InventoryMenu.visible = false

func show_global_menu():
	volumeSlider.value = SoundManager.volume_value
	fullMenu.visible = true
	
func hide_global_menu():
	fullMenu.visible = false
	pokemonMenu.visible = false
	pokemonStatmenuButton.visible = false
	InventoryMenu.visible = false

func hide_player_inventory():
	InventoryMenu.visible = false
	fullMenu.visible = true
	
func hide_pokemon_menu():
	pokemonMenu.visible = false
	fullMenu.visible = true
	
func show_pokemon_menu(callable : Callable = show_pokemon_stat_menu):
	print("show_pokemon_menu callable : ", callable)
	print(callable.get_bound_arguments())
	fullMenu.visible = false
	pokemonStatmenuButton.visible = false
	InventoryMenu.visible = false
	var player_pokemon = playerManager.player_instance.pokemonTeam
	var i = 0
	var buttonlist = pokemonMenu.get_node("MarginContainer/VBoxContainer").get_children()
	buttonlist += pokemonMenu.get_node("MarginContainer2/VBoxContainer2").get_children()
	pokemonMenu.visible = true
	
	if not in_fight_open :
		setup_back_button(pokemonMenu, hide_pokemon_menu)
	
	for button in buttonlist :
		if button is Button :
			if i < player_pokemon.size():
				var pokemon = player_pokemon[i]
				button.icon = pokemon.data.sprite_frames.get_frame_texture("menu", 0)
				setup_pokemon_button(button, pokemon)
				Utils.disconnect_all_connections_pressed(button)
				button.connect("pressed", callable.bind(pokemon))
				if in_fight_open and pokemon.Stat_dict["Hp_dict"]["current"] <= 0 :
					button.disabled = true
				else :
					button.disabled = false
			else :
				button.text = "None"
			i += 1

func use_item_on_pokemon(pokemon : PokemonInstance, item_data : Item_data):
	var inventory = playerManager.player_instance.player_inventory
	pokemonMenu.visible = false
	if in_fight_open :
		Game.battleManager._on_item_selected(item_data, pokemon)
	else : 
		var is_used = pokemon.use_item(item_data) # penser a passer use_item dans player cela me semble plus logique 
		await DialogueManager.dialogue_ended
		if is_used :
			inventory.use_item(item_data) # mettre la logique de retrait dans use_item de player 
		display_ItemList(item_data.Categorie)
		InventoryMenu.visible = true

static func setup_pokemon_button(button : Button, pokemon : PokemonInstance):
	
	var hp_bar = button.get_node("hpBar")
	var lvlLabel = button.get_node("lvlLabel")
	hp_bar.value = float(pokemon.Stat_dict["Hp_dict"]["current"] * 100 / pokemon.Stat_dict["Hp_dict"]["max"])
	hp_bar.modulate = Utils.choose_hp_color(hp_bar.value)
	lvlLabel.text = "Niv. %d" % pokemon.level
	button.text = pokemon.pokemon_name
	
	
func setup_ct_button(pokemon : PokemonInstance):
	var ctBox = pokemonStatmenuButton.get_node("VBoxContainer")
	var i = 0
	
	for button in ctBox.get_children() :
		if button is Button and i < pokemon.moves.size():
			var pplabel = button.get_node("PPlabel")
			var typelabel = button.get_node("typelabel")
			var move = pokemon.moves[i]
			button.text = move["name"]
			var style = StyleBoxFlat.new()
			var color = Utils.get_type_color(move.type)
			style.bg_color = color
			button.add_theme_stylebox_override("normal", style)
			var current_pp_move = pokemon.movesPP[move.id]
			var max_pp_move = move["max_pp"]
			pplabel.text = str(current_pp_move) + "/" + str(max_pp_move)
			
			typelabel.text = Utils.type_to_string(move["type"])
		else :
			button.text = "NONE"
		i += 1

func setup_back_button(fromControl : Control, callable : Callable):
	var returnButton = fromControl.get_node("BackButton")
	
	Utils.disconnect_all_connections_pressed(returnButton)
	if callable.is_valid() :
		returnButton.connect("pressed", callable)

func setup_pokemon_stat(pokemon : PokemonInstance) :
	var pokemonSprite = pokemonStatmenuButton.get_node("pokemonSprite")
	pokemonSprite.texture = pokemon.data.sprite_frames.get_frame_texture("idle", 0)
	
	var type_text := Utils.type_to_string(pokemon.pokemon_type1)
	if pokemon.pokemon_type2 != pokemon.Type.AUCUN:
		type_text += "/" + Utils.type_to_string(pokemon.pokemon_type2)
		
	var gridinfo = pokemonStatmenuButton.get_node("GridContainer");
	gridinfo.get_node("pokemonName").text = "Name : %s" % pokemon.pokemon_name
	gridinfo.get_node("pokemonLevel").text = "Level : %d" % pokemon.level
	gridinfo.get_node("pokemonId").text = "ID : %d " % (pokemon.pokemon_id)
	gridinfo.get_node("pokemonTypes").text = "Type(s) : %s " % type_text
	
	var allStatGrid = pokemonStatmenuButton.get_node("StatPanel/MarginContainer/GridContainer")
	
	for label in allStatGrid.get_children():
		if not label is Label : 
			continue
		for prefix in STAT_MAP :
			if label.name.begins_with(prefix):
				var keys = STAT_MAP[prefix]
				label.text = str(pokemon.Stat_dict[keys[0]][keys[1]])
				break
	
func show_pokemon_stat_menu(pokemon : PokemonInstance):
	pokemonStatmenuButton.visible = true
	pokemonMenu.visible = false
	
	setup_back_button(pokemonStatmenuButton, show_pokemon_menu)
	setup_ct_button(pokemon)
	# to handle CTinfoButto
	setup_pokemon_stat(pokemon)
	

func _input(event: InputEvent) :
	if in_fight_open == true : 
		return
	if event.is_action_pressed("openMenu") and is_open == false: 
		show_global_menu()
		is_open = true
	elif event.is_action_pressed("openMenu") and is_open == true:
		hide_global_menu()
		is_open = false


func _on_h_slider_value_changed(value: float) -> void:
	SoundManager.set_master_vulume(value)

func display_ItemList(category : int):
	
	var ItemListNode = InventoryMenu.get_node("ItemList")
	var Player_inventory = playerManager.player_instance.player_inventory
	
	ItemListNode.clear()
	for item_name in Player_inventory.items:
		var item = Player_inventory.items[item_name]
		var item_data = item["data"]
		var quantity = item["quantity"]
		if item_data.Categorie == category :
			var text = "{0}  x{1}".format([item_data.Item_name, str(quantity)])
			var idx = ItemListNode.add_item(text, item_data.icon)
			ItemListNode.set_item_custom_fg_color(idx, Color.WHEAT)
			ItemListNode.set_item_metadata(idx, item_data)
		
func _on_bag_button_pressed(callable : Callable = hide_player_inventory) -> void:
	reset_item_left_part()
	fullMenu.visible = false
	InventoryMenu.visible = true
	var tabBar = InventoryMenu.get_node("TabBar")
	setup_back_button(InventoryMenu, callable)
	Utils.disconnect_all_connections_pressed(tabBar, "tab_changed")
	tabBar.connect("tab_changed", display_ItemList)
	display_ItemList(Item_data.ItemCat.POTION)

func reset_item_left_part() -> void : 
	var IconHolder = InventoryMenu.get_node("TextureRect")
	var DescriptionHolder = InventoryMenu.get_node("Label")
	var ItemName = InventoryMenu.get_node("HBoxContainer/ItemName")
	var ItemQuantity = InventoryMenu.get_node("HBoxContainer/ItemQuantity")
	
	IconHolder.texture = null
	DescriptionHolder.text = ""
	ItemName.text = ""
	ItemQuantity.text = ""
	
func Show_item_left_part(index: int) -> void:
	var IconHolder = InventoryMenu.get_node("TextureRect")
	var DescriptionHolder = InventoryMenu.get_node("Label")
	var ItemName = InventoryMenu.get_node("HBoxContainer/ItemName")
	var ItemQuantity = InventoryMenu.get_node("HBoxContainer/ItemQuantity")
	var UseButton = InventoryMenu.get_node("HBoxContainer/UseButton")
	var ItemListNode = InventoryMenu.get_node("ItemList")
	
	var item_data = ItemListNode.get_item_metadata(index)
	var callable = use_item_on_pokemon.bind(item_data)
	Utils.disconnect_all_connections_pressed(UseButton)
	if not in_fight_open and item_data.Categorie == Item_data.ItemCat.BALL:
		UseButton.disabled = true
	elif in_fight_open and item_data.Categorie == Item_data.ItemCat.BALL :
		UseButton.connect("pressed", Game.battleManager._on_item_selected.bind(item_data))
	else :
		UseButton.disabled = false
		UseButton.connect("pressed", show_pokemon_menu.bind(callable))
	IconHolder.texture = item_data.icon
	DescriptionHolder.text = item_data.Description
	ItemName.text = item_data.Item_name
	ItemQuantity.text = str(playerManager.player_instance.player_inventory.get_item_quantity(item_data)) + " Qty"
