extends DraggableListItem
class_name ItemTask

@onready var button := $Button
@onready var buttonRemove := $ButtonRemove
@onready var crossOver := $CrossOver
const itemH : int = 80
# Dragged items can't go past these global Y limits 
const minY : float = 180
const maxY : float = 680

func construct(lManager:ListManager, dataObject:Variant):
	setVariablesFromChild(button, lManager, dataObject, itemH, minY, maxY)
	
	#setLManagerAndDO(lManager,dataObject)
	#setDraggableButton(button)
	setButtonTitle(dataObject.taskTitle)
	#setHeightFromChild(80)
	updateCompletedVisual()


func setButtonTitle(toTitle:String):
	button.text = toTitle

func updateCompletedVisual():
	var completed = refDO.completed
	crossOver.set_visible(completed)


# Open tasks
func _on_button_pressed():	
	activatingDrag = false
	if not dragging:
		# Toggle completed-state
		refDO.completed = !refDO.completed
		updateCompletedVisual()


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
	listManager.main.removeTask(refDO)
	listManager.updateList()
