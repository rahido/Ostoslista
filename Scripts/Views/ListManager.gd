extends Node2D
class_name ListManager

var scrollContainer : ScrollContainer
var itemsContainer : VBoxContainer

func setItemsContainer(iContainer: VBoxContainer):
	itemsContainer = iContainer
func setScrollContainer(sContainer: ScrollContainer):
	scrollContainer = sContainer

func updateList():
	# will be overridden in child class
	pass
func MoveItemToIndex(dataObject:Variant, idx:int):
	# will be overridden in child class
	pass
func createNew(title:String):
	# Create new Subject or Task
	# will be overridden in child class
	pass
func closePrompt():
	# will be overridden in child class
	pass
func moveItemToIndex(item : DraggableListItem, toIdx):
	itemsContainer.move_child(item, toIdx)

func emulateScroll(direction:String) -> bool:
	var hasScrolled : bool = false
	#print("Scroll to : " + direction)
	# Maximum Y Position of scroll Container (accounting unscrolled part)
	var maxVerticalPos = scrollContainer.get_v_scroll_bar().get_max()
	# Maximum Scroll Y value (Total container Y size - visible container Y size)
	var maxScrollY = maxVerticalPos - scrollContainer.size.y
	# If not enought items in list to create a need for scroll
	if maxScrollY <= 0:
		return hasScrolled
	# Current vertical scroll value
	var nextVal = scrollContainer.scroll_vertical
	print("maxVerticalPos: " + str(maxVerticalPos) + " ... maxScrollY : " + str(maxScrollY) + " ... Current val: " + str(nextVal))
	if direction == "up":
		if nextVal > 2:
			nextVal -= 2
			hasScrolled = true
	elif direction == "down":
		if nextVal < maxScrollY-2:
			nextVal += 2
			hasScrolled = true
			print("Scroll -down- because nextVal: " + str(nextVal) + " < maxVertical:" + str(maxScrollY))
	scrollContainer.scroll_vertical = nextVal
	return hasScrolled

