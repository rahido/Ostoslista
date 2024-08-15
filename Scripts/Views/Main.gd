extends Node2D
class_name Main

@onready var listSubjectsResource := load("res://Scenes/Views/ListSubjects.tscn")
@onready var listTasksResource := load("res://Scenes/Views/ListTasks.tscn")
var listSubjects : ListSubjects
var listTasks : ListTasks

var subjectDOs : Array # Dataobjects
var taskDOs : Array # Dataobjects

var isMobile : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Auto accept quit disabled. Closing handled in func _notification() below
	get_tree().set_auto_accept_quit(true)
	get_tree().set_quit_on_go_back(true)
	loadData()
	checkPlatformType()
	openSubjectsList()
	
	cleanUp()


func cleanUp():
	# During development, a few Tasks with a missing Subject were left in the save file
	# These wouldn't show anywhere in UI. This func cleans those out.
	print("Run Ostoslista saved data -clean up")
	var f := true
	var cleaned = false
	for t in taskDOs:
		for s in subjectDOs:
			if t.subjectId == s.subjectId:
				f = false
				break
		if f:
			print("Found one task containing a removed subject ref")
			cleaned = true
			taskDOs = taskDOs.filter(func (tt): tt.subjectId != t.subjectId)
		f = true
	if cleaned:
		saveData()


func checkPlatformType():
	var modelName = OS.get_model_name()
	isMobile = false if modelName == "GenericDevice" else true
	print("modelName: " + modelName + ".. isMobile: " + str(isMobile))

# SUBJECTS
func openSubjectsList():
	if listSubjects:
		listSubjects.set_visible(true)
	else:
		listSubjects = listSubjectsResource.instantiate()
		add_child(listSubjects)
		listSubjects.construct(self)

func closeSubjectsList():
	if listSubjects:
		listSubjects.set_visible(false)

func createSubject(title:String="Title", id:int=-1):
	print("Main -> create Subject")
	# ID: Loaded (existing) DOs has an id, not -1. New DOs use -1 and gets a ID here.
	# idx: Loaded DOs with id != -1 are inserted to the end of array. New DOs with id -1 are inserted at the beginning.
	var newId = id
	if newId == -1:
		newId = 0
		for subj  in subjectDOs:
			if subj.subjectId >= newId:
				newId = subj.subjectId + 1
	var newSubj = SubjectDO.new(newId, title)
	var idx = 0 if id == -1 else subjectDOs.size()
	subjectDOs.insert(idx,newSubj)
	# Save data after creating a fully new subject
	if id == -1:
		saveData()

func removeSubject(subj:SubjectDO):
	print("Main -> remove subject")
	taskDOs = taskDOs.filter(func (t): return t.subjectId != subj.subjectId)
	subjectDOs = subjectDOs.filter(func (s): return s != subj)
	saveData()

func moveSubjectoIndex(subj:SubjectDO, toIdx:int):
	var prevIdx : int = subjectDOs.find(subj)
	if prevIdx != -1:
		subjectDOs.insert(toIdx, subjectDOs.pop_at(prevIdx))
	saveData()

# TASKS
func openTasksList(subjDO:SubjectDO):
	closeSubjectsList()
	listTasks = listTasksResource.instantiate()
	add_child(listTasks)
	listTasks.construct(self)
	listTasks.initMore(subjDO)

func closeTasksList():
	if listTasks:
		remove_child(listTasks)
	openSubjectsList()

func createTask(subjectId:int=0, title:String="Task Title", id:int=-1, completed:bool=false):
	# ID: Loaded DOs has a non -1 id. New DOs will get a new id.
	var newId = id
	if newId == -1:
		newId = 0
		for t in taskDOs:
			if t.taskId >= newId:
				newId = t.taskId + 1	
	var newTask = TaskDO.new(newId,title,subjectId,completed)
	var idx = 0 if id == -1 else taskDOs.size()
	taskDOs.insert(idx,newTask)
	# Save data after creating a fully new subject
	if id == -1:
		saveData()

func removeTask(task:TaskDO):
	print("Main -> remove task")
	taskDOs = taskDOs.filter(func (t): return t != task)
	saveData()

func moveTasktoIndex(task:Variant, toIdx:int):
	var prevIdx : int = taskDOs.find(task)
	if prevIdx != -1:
		taskDOs.insert(toIdx, taskDOs.pop_at(prevIdx))
	saveData()

# DATA
func saveData():
	print("Main -> save data")	
	var saveFile = FileAccess.open("user://ostoslista.save", FileAccess.WRITE)
	for subj in subjectDOs:
		if !subj.has_method("save"):
			print("SubjectDO is missing save -function, skipping")
			continue
		var subjectData = subj.call("save")
		print("Save - " + str(subjectData))
		var jsonStr = JSON.stringify(subjectData)
		saveFile.store_line(jsonStr)
	for t in taskDOs:
		if !t.has_method("save"):
			print("TaskDO is missing save -function, skipping")
			continue
		var taskAsDict = t.call("save")
		print("Save - " + str(taskAsDict))
		var jsonStr = JSON.stringify(taskAsDict)
		saveFile.store_line(jsonStr)
	saveFile.close()

func loadData():
	print("Main -> load data")
	if not FileAccess.file_exists("user://ostoslista.save"):
		print("Save file (user://ostoslista.save) not found -> no data to load")
		return
	var saveFile = FileAccess.open("user://ostoslista.save", FileAccess.READ)
	while saveFile.get_position() < saveFile.get_length():
		# Read save file, line by line
		var jsonStr = saveFile.get_line()
		var json = JSON.new()
		var parsed = json.parse(jsonStr)
		if not parsed == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", jsonStr, " at line ", json.get_error_line())
			continue
		# data as dictionary
		var jsonData = json.get_data()
		print("Load - " + str(jsonData))
		if jsonData.has("DOType"):
			# Subject-type
			if jsonData["DOType"] == 0:
				var id = int(jsonData["subjectId"])
				var title = jsonData["subjectTitle"]
				createSubject(title, id)
			# Task-type
			elif jsonData["DOType"] == 1:
				var id = int(jsonData["taskId"])
				var title = jsonData["taskTitle"]
				var subjId = int(jsonData["subjectId"])
				var completed = bool(jsonData["completed"])
				createTask(subjId, title, id, completed)
	saveFile.close()
