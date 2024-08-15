extends Node
class_name TaskDO

var taskId : int
var taskTitle : String
var completed : bool
var subjectId : int

func _init(id:int=0, title:String="TaskTitle", subjId:int=0, completedState:bool=false):
	taskId = id
	taskTitle = title
	subjectId = subjId
	completed = completedState

func save():
	# Save data. DOType 1 means Task, 0 would be Subject
	var saveDict = {
		"DOType" : 1,
		"taskId" : taskId,
		"taskTitle" : taskTitle,
		"subjectId" : subjectId,
		"completed" : completed
	}
	return saveDict
