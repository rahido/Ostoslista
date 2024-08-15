extends ListManager
class_name ListTasks

@onready var taskResource := load("res://Scenes/Actors/ItemTask.tscn")
@onready var promptResource := load("res://Scenes/Views/ListPromptView.tscn")
@onready var labelSubjectTitle := $PanelTitle/LabelSubjectTitle

var main : Main
var subjectDO : SubjectDO
var promptView : PromptView

func construct(ma:Main):
	main = ma
	setScrollContainer($ScrollContainer)
	setItemsContainer($ScrollContainer/ItemsContainer)
	print("itemsContainer: " + str(itemsContainer))

func initMore(subjDO:SubjectDO):
	subjectDO = subjDO
	labelSubjectTitle.text = "[center]%s[/center]" % subjectDO.subjectTitle
	updateList()

func updateList():
	# overridden from parent
	for child in itemsContainer.get_children():
		itemsContainer.remove_child(child)
	for task in main.taskDOs:
		if task.subjectId == subjectDO.subjectId:
			instantiateItem(task)
	
func instantiateItem(task:TaskDO):
	var instance : ItemTask = taskResource.instantiate()
	itemsContainer.add_child(instance)
	instance.construct(self, task)

func MoveItemToIndex(taskDO:Variant, idx:int):
	main.moveTasktoIndex(taskDO,idx)
	updateList()
	

func createNew(title:String):
	main.createTask(subjectDO.subjectId, title)
	if promptView:
		remove_child(promptView)
	updateList()
	
func closePrompt():
	if promptView:
		remove_child(promptView)

func _on_button_back_pressed():
	main.closeTasksList()


func _on_button_create_task_pressed():
	promptView = promptResource.instantiate()
	add_child(promptView)
	promptView.construct(self, "Lisää asia listalle:", "Asian nimi")
