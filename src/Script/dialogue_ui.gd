extends CanvasLayer

signal choice_made(choice : bool)

@onready var dialogue_box = $DialogueBox
@onready var speaker_label = $DialogueBox/MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label = $DialogueBox/MarginContainer/VBoxContainer/textLabel
@onready var yes_noBox = $yes_noBox
@onready var yes_button = $yes_noBox/HBoxContainer/Button
@onready var no_button = $yes_noBox/HBoxContainer/Button2
@onready var show_box = $ShowBox

var full_text = ""
var current_char_index = 0
var text_speed = 0.03
var is_typing = false
var typing_timer := 0.0

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line_changed.connect(_on_dialogue_line_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	dialogue_box.visible = false
	yes_noBox.visible = false
	show_box.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if is_typing :
		typing_timer += delta
		if typing_timer >= text_speed :
			typing_timer = 0.0
			current_char_index += 1
			
			if current_char_index <= full_text.length():
				text_label.text = full_text.substr(0, current_char_index)
			else :
				finish_typing()
	if yes_noBox.visible:
		if Input.is_action_pressed("ui_left_dir"):
			yes_button.grab_focus()
		elif Input.is_action_pressed("ui_right_dir"):
			no_button.grab_focus()
		return
func _on_dialogue_started():
	dialogue_box.visible = true

func show_dialogue(text):
	playerManager.desacPlayer(true) 
	text_label.text = text
	dialogue_box.visible = true
	yes_noBox.visible = true
	yes_button.grab_focus()
	
func hide_dialogue():
	text_label.text = ""
	dialogue_box.visible = false
	yes_noBox.visible = false
	playerManager.activatePlayer()
	
func _on_dialogue_line_changed(speaker : String, text : String):
	speaker_label.text	 = speaker
	full_text = text
	current_char_index = 0
	text_label.text = ""
	is_typing = true
	typing_timer = 0.0

func show_img(img : Texture) : 
	show_box.visible = true
	var texture_rect = show_box.get_node("TextureRect")
	texture_rect.texture = img

func hide_img():
	show_box.visible = false
	var texture_rect = show_box.get_node("TextureRect")
	texture_rect.texture = null
	
func askCustomQuestion(text : String, img : Texture = null) :
	show_dialogue(text)
	if img : 
		show_img(img)	
	var result = await choice_made
	hide_img()
	hide_dialogue()
	return result
	
func finish_typing():
	is_typing = false
	text_label.text = full_text

func input_pressed():
	print("input pressed for dialogue next")
	if is_typing : 
		finish_typing()
	else:
		DialogueManager.next_line()
		
func _on_dialogue_ended():
	dialogue_box.visible = false
	is_typing = false

func _on_buttonyes_pressed() -> void:
	choice_made.emit(true)


func _on_buttonno_pressed() -> void:
	choice_made.emit(false)

func _unhandled_input(event):
	if not yes_noBox.visible:
		return
	if event.is_action_pressed("ui_left"):
		no_button.grab_focus()
	elif event.is_action_pressed("ui_right"):
		yes_button.grab_focus()
