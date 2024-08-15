extends Control
class_name DraggableListItem

var timer : Timer
var activatingDrag : bool = false
var dragging : bool = false
const scrollArea : float = 60
var targetYPos : float = 0.0
var targetXPos : float = 0.0
var deltaY : float = 0.0
var prevIndex : int = 0

# Variables set from child
# listManager can be List2Subjects or -Tasks
var listManager : ListManager
var refDO : Variant
var bu : Button
var itemHeight : int
var minYPos : float
var maxYPos : float

func _init():
	createTimer()

func setVariablesFromChild(button:Button, lm:ListManager, dataObj:Variant, containerHeight:float, minY:float, maxY:float):
	bu = button
	listManager = lm
	refDO = dataObj
	itemHeight = containerHeight
	custom_minimum_size.y = itemHeight
	minYPos = minY
	maxYPos = maxY
	
func setDraggableButton(button:Button):
	bu = button

func setLManagerAndDO(lm:ListManager, rdo:Variant):
	listManager = lm
	refDO = rdo

func setHeightFromChild(h:int):
	itemHeight = h
	custom_minimum_size.y = itemHeight

func setButtonTitle(toTitle:String):
	# Will be overridden in child class
	pass

func createTimer():
	timer = Timer.new()
	add_child(timer)
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = .5
	timer.timeout.connect(_timeOut)

func _timeOut():
	if activatingDrag:
		print("Activate drag")
		# Filter stops click/touch at button -> stops scrolling
		bu.mouse_filter = Control.MOUSE_FILTER_STOP
		prevIndex = get_index()
		targetXPos = global_position.x + 30
		targetYPos = global_position.y
		dragging = true

# Start timer to activate drag
func startActivatingDrag():
	print("startActivatingDrag - Timeout start")
	activatingDrag = true
	if timer:
		timer.stop()
		timer.start()

func onMotion(event):
	if event is InputEventScreenDrag:
		if activatingDrag:
			if abs(event.velocity.x) + abs(event.velocity.y) > 50:
				activatingDrag = false
		elif dragging:			
			if targetYPos < minYPos-5 || targetYPos > maxYPos+5:
				targetYPos = clamp(targetYPos, minYPos-5, maxYPos+5)
			else:
				targetYPos += event.relative.y
				deltaY += event.relative.y

func onStopDrag():	
	#print("Button Up")
	activatingDrag = false
	if timer:
		timer.stop()
	if dragging:
		print("Stop drag")
		# Filter passes click/touch from button -> enables scrolling
		bu.mouse_filter = Control.MOUSE_FILTER_PASS
		dragging = false
		# Update index change to subjectDOs
		if prevIndex != get_index():
			listManager.MoveItemToIndex(refDO, get_index())
			prevIndex = get_index()
		else:
			listManager.updateList()

func _physics_process(delta):
	if dragging:
		global_position = lerp(global_position, Vector2(targetXPos, targetYPos) , 25*delta)
		# emulate scroll
		if targetYPos > maxYPos-scrollArea:
			var hasScrolled = listManager.emulateScroll("down")
			if hasScrolled:
				deltaY += 2
				print("Has Scrolled : Add delta ++")
		elif targetYPos < minYPos+scrollArea:
			var hasScrolled = listManager.emulateScroll("up")
			if hasScrolled:
				deltaY -= 2
				print("Has Scrolled : Add delta --")
		# change subject index
		if deltaY > itemHeight:
			var toIdx:int = get_index() + 1
			listManager.moveItemToIndex(self,toIdx)
			deltaY -= itemHeight
		elif deltaY < -itemHeight:
			var toIdx:int = get_index() - 1
			listManager.moveItemToIndex(self,toIdx)
			deltaY += itemHeight

