extends UpgradeData

func get_display_text(game):
	return tr("autoclicker_amount") + " " + str(Globals.game.autoclickers)
