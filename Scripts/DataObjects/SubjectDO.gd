extends Node
class_name SubjectDO

var subjectId : int
var subjectTitle : String

func _init(id, title):
	subjectId = id
	subjectTitle = title

func save():
	# Save data. DOType 0 means Subject, 1 would be Task
	var save_dict = {
		"DOType" : 0,
		"subjectId" : subjectId,
		"subjectTitle" : subjectTitle
	}
	return save_dict
