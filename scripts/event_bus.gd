extends Node

signal notification

enum types {NORMAL, WARNING, ERROR, GOOD}

func show_notification(message = "not_enough_coins", type = types.ERROR):
	var notification_obj = object.create("notification", Vector2.ZERO, "/root/game/UI/Control/NotificationContainer")
	notification_obj.message = tr(message)
	notification_obj.type_var = type
	notification.emit()
