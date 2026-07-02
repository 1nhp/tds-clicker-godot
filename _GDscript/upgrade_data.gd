extends StoreItemData
class_name UpgradeData

@export var base_price : int
@export var price_multiplier: float
@export var level: int
@export var max_level: int
@export var upgrade_name_key: String
@export var description_key: String
@export var text_color: Color

func get_display_text(_game):
	return ""
