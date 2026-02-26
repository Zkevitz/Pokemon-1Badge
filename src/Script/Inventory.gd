extends Node
class_name Inventory


var items : Dictionary
const InventoryMaxSlots = 100

func add_item(item : Item_data):
	if items.has(item.Item_name) and item.max_stack > items[item.Item_name].quantity:
		items[item.Item_name].quantity += 1
	elif items.size() < InventoryMaxSlots:
		items[item.Item_name] = {"data" : item, "quantity" : 1}


func use_item(item : Item_data):
	if items.has(item.Item_name):
		items[item.Item_name].quantity -= 1
	else :
		push_error("try to use item not in inventory")

func get_item_quantity(item : Item_data) -> int:
	if items.has(item.Item_name):
		return items[item.Item_name].quantity
	return 0
