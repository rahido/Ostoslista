extends DraggableListItem
class_name ItemSubject

@onready var button = $Button
var subjectDO : SubjectDO
const itemH : int = 100
# Dragged items can't go past these global Y limits 
const minY : float = 110
const maxY : float = 650

func construct(lManager:ListManager, dataObject:Variant):
	setVariablesFromChild(button, lManager, dataObject, itemH, minY, maxY)
	#setLManagerAndDO(lManager,dataObject)
	#setDraggableButton(button)
	setButtonTitle(dataObject.subjectTitle)
	#setHeightFromChild(100)

func initMore(subjDO:SubjectDO):
	subjectDO = subjDO

func setButtonTitle(toTitle:String):
	button.text = toTitle

# Open tasks
func _on_button_pressed():	
	activatingDrag = false
	if not dragging:
		listManager.main.openTasksList(subjectDO)

# Start activating drag
func _on_button_button_down():
	startActivatingDrag()

# Stop drag
func _on_button_button_up():
	onStopDrag()

# Drag Motion
func _on_button_gui_input(event):
	if activatingDrag or dragging:
		onMotion(event)


func _on_button_remove_pressed():
	listManager.main.removeSubject(refDO)
	listManager.updateList()
