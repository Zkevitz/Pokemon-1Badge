extends Node

signal dialogue_started
signal dialogue_line_changed(speaker, text)
signal dialogue_ended
signal input_pressed

var current_dialogue = []
var dialogue_line_index = 0
var dialogueisActive = false
var dialogues: Dictionary = {}

func _ready() -> void:
	dialogues = {
		"professeur Homes": {
			"default": [
				{"speaker": "Prof", "text": "Salut {nom du joeur pas encore implementer}, C'est le grand jour pour toi"},
				{"speaker": "Prof", "text": "tu vas pouvoir choisir un des trois pokemon sur la table"},
				{"speaker": "Prof", "text": "fais bien attention a ton choix la vie au dela des mur du village est rude"},
				{"speaker": "Prof", "text": "Vipeliere est un choix horrible"}
			],
			StoryManager.Flag.HAS_POKEMON: [
				{"speaker": "Prof", "text": "C'est bien mon coco mnt vas et perd"}
			]
		},
		"Gate Keeper": {
			"default": [
				{"speaker": "Gate Keeper", "text": "Ou penses tu aller comme ca ?"},
				{"speaker": "Gate Keeper", "text": "Personne n'est autoriser a sortir du village sans Pokemon pour l'accompagner"},
				{"speaker": "Gate Keeper", "text": "Vas vite recupére un pokemon au labo du professeur Homes (PS : ne prend pas vipeliere)"},
			],
			StoryManager.Flag.HAS_POKEMON: [
				{"speaker": "Gate Keeper", "text": "Ah, tu as enfin un Pokemon ! J'éspère que ce n'est pas vipélière."},
				{"speaker": "Gate Keeper", "text": "J'imagine que t'es déjà calé en Pokemon. Voici quelques items pour bien débuter."},
			]
		},
		"Rival": [
			{"speaker": "Rival", "text": "Wesh gros, tu crois vraiment que t'es pret ?"},
			{"speaker": "Rival", "text": "Moi je suis pret depuis longtemps, voyons voir qui de nous peut partir..."}
		],
		"RivalPost": [
			{"speaker": "Rival", "text": "... t'es pas mal. Mais la prochaine je vais te bz"},
			{"speaker": "Rival", "text": "Ciao."},
		]
	}

func _process(delta: float) -> void:
	if dialogueisActive == false : 
		return
	if Input.is_action_just_pressed("interact") :
		emit_signal("input_pressed")
		
func startDialogue(dialogue_id : String):
	print("dialogue id : ", dialogue_id)
	if dialogueisActive == true :
		return 
	var raw
	if not dialogues.has(dialogue_id):
		raw = dialogue_id
	else :
		raw = dialogues[dialogue_id] 
	
	if raw is Dictionary:
		current_dialogue = _resolve_variant(raw)
	elif raw is Array:
		current_dialogue = raw
	else:
		current_dialogue = [raw]
	
	dialogue_line_index = 0
	dialogueisActive = true
	playerManager.lock_player()
	emit_signal("dialogue_started")
	showCurrentLine()

func showCurrentLine():
	if dialogue_line_index >= current_dialogue.size():
		end_dialogue()
		return
	
	var line = current_dialogue[dialogue_line_index]
	var speaker
	var text 
	if line is Dictionary :
		speaker = line.get("speaker", "")
		text = line.get("text", "")
	else :
		speaker = ""
		text = line
	
	emit_signal("dialogue_line_changed", speaker, text)

func next_line():
	if not dialogueisActive :
		return
	
	dialogue_line_index += 1
	showCurrentLine()

func end_dialogue():
	dialogueisActive = false
	current_dialogue = []
	dialogue_line_index = 0
	playerManager.unlock_player()
	emit_signal("dialogue_ended")
	
func is_active() -> bool :
	return dialogueisActive
	

func _resolve_variant(variants: Dictionary) -> Array:
	for key in variants.keys():
		if key is String:
			continue
		if StoryManager.has_flag(key):
			return variants[key]
	return variants.get("default", [])
