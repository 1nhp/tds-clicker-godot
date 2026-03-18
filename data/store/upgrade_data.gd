extends StoreItemData
class_name UpgradeData

@export var base_price : int
@export var price_multiplier: float
@export var level: int
@export var max_level: int
@export var description: String
@export var text_color: Color

func get_display_text(game):
	return ""
