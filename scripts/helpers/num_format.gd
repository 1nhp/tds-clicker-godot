extends Node

func format_number(number: float) -> String:
	if number >= 10000000000000:
		return str(round(number / 10000000000000.0 * 100) / 100.0) + "S"
	elif number >= 1000000000000:
		return str(round(number / 1000000000000.0 * 100) / 100.0) + "Qt"
	elif number >= 100000000000:
		return str(round(number / 100000000000.0 * 100) / 100.0) + "Q"
	elif number >= 10000000000:
		return str(round(number / 10000000000.0 * 100) / 100.0) + "T"
	elif number >= 1000000000:
		return str(round(number / 1000000000.0 * 100) / 100.0) + "B"
	elif number >= 1000000:
		return str(round(number / 1000000.0 * 100) / 100.0) + "M"
	elif number >= 1000:
		return str(round(number / 1000.0 * 100) / 100.0) + "K"
	else:
		return str(int(number))
