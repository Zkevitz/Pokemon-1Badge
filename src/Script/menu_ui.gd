extends CanvasLayer
class_name MenuUi


var is_open = false

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
	fullMenu.visible = false
	pokemonStatmenuButton.visible = false
	InventoryMenu.visible = false
	var player_pokemon = playerManager.player_instance.pokemonTeam
	var i = 0
	var buttonlist = pokemonMenu.get_node("MarginContainer/VBoxContainer").get_children()
	buttonlist += pokemonMenu.get_node("MarginContainer2/VBoxContainer2").get_children()
	pokemonMenu.visible = true
	for button in buttonlist :
		if button is Button :
			if i < player_pokemon.size():
				var pokemon = player_pokemon[i]
				button.icon = pokemon.data.sprite_frames.get_frame_texture("menu", 0)
				setup_pokemon_button(button, pokemon)
				for connection in button.pressed.get_connections():
					button.pressed.disconnect(connection.callable)
				if callable :
					button.connect("pressed", callable.bind(pokemon))
			else :
				button.text = "None"
			i += 1

func use_item_on_pokemon(pokemon : PokemonInstance, item_data : Item_data):
	var inventory = playerManager.player_instance.player_inventory
	pokemonMenu.visible = false
	var is_used = pokemon.use_item(item_data) # penser a passer use_item dans player cela me semble plus logique 
	await DialogueManager.dialogue_ended
	if is_used :
		inventory.use_item(item_data) # mettre la logique de retrait dans use_item de player 
	InventoryMenu.visible = true

static func setup_pokemon_button(button : Button, pokemon : PokemonInstance):
	
	var hp_bar = button.get_node("hpBar")
	var lvlLabel = button.get_node("lvlLabel")
	hp_bar.value = float(pokemon.Hp_dict["current"] * 100 / pokemon.Hp_dict["max"])
	hp_bar.modulate = Utils.choose_hp_color(hp_bar.value)
	print("hp_bar menu value : ", hp_bar.value)
	lvlLabel.text = "Niv. %d" % pokemon.level
	button.text = pokemon.pokemon_name
	
func setup_ct_button(button : Button, move : CT_data, current_pp : int):
	var pplabel = button.get_node("PPlabel")
	var typelabel = button.get_node("typelabel")
	
	button.text = move["name"]
	var style = StyleBoxFlat.new()
	var color = Utils.get_type_color(move.type)
	style.bg_color = color
	button.add_theme_stylebox_override("normal", style)
	print("Move ", move)
	var current_pp_move = current_pp
	var max_pp_move = move["max_pp"]
	pplabel.text = str(current_pp_move) + "/" + str(max_pp_move)
	
	typelabel.text = type_to_string(move["type"])
	
func type_to_string(t: PokemonInstance.Type) -> String:
	if t < 0 or t >= PokemonInstance.Type.size():
		return "Inconnu"
	return PokemonInstance.Type.keys()[t].capitalize()
	
func show_pokemon_stat_menu(pokemon : PokemonInstance):
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
		print("DEBUG: Move size: ", pokemon.moves.size())
		if button is Button and i < pokemon.moves.size():
			setup_ct_button(button, pokemon.moves[i], pokemon.movesPP[pokemon.moves[i].id])
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
					update_stat_line(label, pokemon.Hp_dict["max"])
				elif label.name.begins_with("HPiv") :
					update_stat_line(label, pokemon.Hp_dict["ivs"])
			elif label.name.begins_with("ATKSPE"):
				if label.name.begins_with("ATKSPEstat"):
					update_stat_line(label, pokemon.AtkSpe_dict["current"])
				elif label.name.begins_with("ATKSPEiv") :
					update_stat_line(label, pokemon.AtkSpe_dict["ivs"])
			elif label.name.begins_with("ATK"):
				if label.name.begins_with("ATKstat"):
					update_stat_line(label, pokemon.Atk_dict["current"])
				elif label.name.begins_with("ATKiv") :
					update_stat_line(label, pokemon.Atk_dict["ivs"])
			elif label.name.begins_with("DEFSPE"):
				if label.name.begins_with("DEFSPEstat"):
					update_stat_line(label, pokemon.DefSpe_dict["current"])
				elif label.name.begins_with("DEFSPEiv") :
					update_stat_line(label, pokemon.DefSpe_dict["ivs"])
			elif label.name.begins_with("DEF"):
				if label.name.begins_with("DEFstat"):
					update_stat_line(label, pokemon.Def_dict["current"])
				elif label.name.begins_with("DEFiv") :
					update_stat_line(label, pokemon.Def_dict["ivs"])
			elif label.name.begins_with("SPEED"):
				if label.name.begins_with("SPEEDstat"):
					update_stat_line(label, pokemon.Speed_dict["current"])
				elif label.name.begins_with("SPEEDiv") :
					update_stat_line(label, pokemon.Speed_dict["ivs"])
				
	
		

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
		
func _on_bag_button_pressed() -> void:
	reset_item_left_part()
	fullMenu.visible = false
	InventoryMenu.visible = true
	var tabBar = InventoryMenu.get_node("TabBar")
	var backButton = InventoryMenu.get_node("Button")
	backButton.connect("pressed", hide_player_inventory)
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
	UseButton.connect("pressed", show_pokemon_menu.bind(callable))
	IconHolder.texture = item_data.icon
	DescriptionHolder.text = item_data.Description
	ItemName.text = item_data.Item_name
	ItemQuantity.text = str(playerManager.player_instance.player_inventory.get_item_quantity(item_data)) + " Qty"
