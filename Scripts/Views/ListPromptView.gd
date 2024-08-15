extends Control
class_name PromptView

@onready var promptLabel := $PromptLabel
@onready var lineEdit : LineEdit = $LineEditNewTitle
@onready var animPlayer := $AnimationPlayer


var listManager : ListManager

func construct(lManager : ListManager, promptTitle:String, inputPlaceHolder:String):
	listManager = lManager
	promptLabel.text = promptTitle
	lineEdit.placeholder_text = inputPlaceHolder

func _on_button_confirm_pressed():
	var newTitle : String = lineEdit.text
	if newTitle.length() > 0:
		listManager.createNew(newTitle)
	else:
		animPlayer.play("promptInputBounce")


func _on_button_cancel_pressed():
	listManager.closePrompt()
