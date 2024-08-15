extends ListManager
class_name ListSubjects

@onready var subjectResource := load("res://Scenes/Actors/ItemSubject.tscn")
@onready var promptResource := load("res://Scenes/Views/ListPromptView.tscn")

var main : Main
var promptView : PromptView

func construct(ma:Main):
	main = ma
	setScrollContainer($ScrollContainer)
	setItemsContainer($ScrollContainer/ItemsContainer)
	print("itemsContainer: " + str(itemsContainer))
	updateList()

	
func updateList():
	# overridden from parent
	for child in itemsContainer.get_children():
		itemsContainer.remove_child(child)
	for subj in main.subjectDOs:
		instantiateItem(subj)
	
func instantiateItem(subj:SubjectDO):
	var instance : ItemSubject = subjectResource.instantiate()
	itemsContainer.add_child(instance)
	instance.construct(self, subj)
	instance.initMore(subj)

func MoveItemToIndex(subjectDO:Variant, idx:int):
	main.moveSubjectoIndex(subjectDO,idx)
	updateList()

func createNew(title:String):
	main.createSubject(title)
	if promptView:
		remove_child(promptView)
	updateList()
	
func closePrompt():
	if promptView:
		remove_child(promptView)

# Create subject -> Opens prompt with input for title
func _on_button_create_subject_pressed():
	promptView = promptResource.instantiate()
	add_child(promptView)
	promptView.construct(self, "Luo uusi lista:", "Anna otsikko")
