extends Node

signal dialogue_started
signal dialogue_line_changed(speaker, text)
signal dialogue_ended
signal input_pressed

var current_dialogue = []
var dialogue_line_index = 0 
var dialogueisActive = false
var dialogues = {
	"professeur Homes" : [
	{"speaker": "Prof", "text": "Salut {nom du joeur pas encore implementer}, C'est le grand jour pour toi"},
	{"speaker": "Prof", "text": "tu vas pouvoir choisir un des trois pokemon sur la table"},
	{"speaker": "Prof", "text": "fais bien attention a ton choix la vie au dela des mur du village est rude"},
	{"speaker": "Prof", "text": "Vipeliere est un choix horrible"}],
	"Gate Keeper" : [
	{"speaker": "Gate Keeper", "text": "Ou penses tu aller comme ca ?"},
	{"speaker": "Gate Keeper", "text": "Personne n'est autoriser a sortir du village sans Pokemon pour l'accompagner"},
	{"speaker": "Gate Keeper", "text": "Vas vite recupére un pokemon au labo du professeur Homes (PS : ne prend pas vipeliere)"},
	]
}

func _process(delta: float) -> void:
	if dialogueisActive == false : 
		return
	if Input.is_action_just_pressed("interact") :
		emit_signal("input_pressed")
		
func startDialogue(dialogue_id : String):
	if dialogueisActive == true :
		return 
		
	if not dialogues.has(dialogue_id):
		current_dialogue = [dialogue_id]
	else :
		current_dialogue = dialogues[dialogue_id] 
	
	
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
	
