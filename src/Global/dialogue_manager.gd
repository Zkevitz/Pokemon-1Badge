extends Node

signal dialogue_started
signal dialogue_line_changed(speaker, text)
signal dialogue_ended

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
func startDialogue(dialogue_id : String):
	if dialogueisActive == true :
		print("out")
		return 
		
	if not dialogues.has(dialogue_id):
		push_error("error dialogue not found :", dialogue_id)
		return
	
	current_dialogue = dialogues[dialogue_id]
	print("current_dialogue : ", current_dialogue)
	dialogue_line_index = 0
	dialogueisActive = true
	
	print("dialogue signal Started")
	emit_signal("dialogue_started")
	showCurrentLine()

func showCurrentLine():
	if dialogue_line_index >= current_dialogue.size():
		end_dialogue()
		return
	
	var line = current_dialogue[dialogue_line_index]
	var speaker = line.get("speaker", "")
	var text = line.get("text", "")
	
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
	emit_signal("dialogue_ended")
	
func is_active() -> bool :
	return dialogueisActive
	
