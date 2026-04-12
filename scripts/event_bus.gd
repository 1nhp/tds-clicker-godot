extends Node

signal notification
signal enemy_clicked

enum types {NORMAL, WARNING, ERROR, GOOD}

func show_notification(message = "not_enough_coins", type = types.ERROR):
	var notification_obj = object.create("notification", Vector2.ZERO, "/root/game/UI/Control/NotificationContainer")
	notification_obj.message = tr(message)
	notification_obj.type_var = type
	
	notification.emit()

func click_enemy():
	Globals.game.enemy.click()
	enemy_clicked.emit()
