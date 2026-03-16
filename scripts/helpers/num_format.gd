extends Node

func format_number(number: int) -> String:
	if number >= 100000000000:
		return str(snapped(number / 100000000000.0, 0.01)) + "Q"
	if number >= 10000000000:
		return str(snapped(number / 10000000000.0, 0.01)) + "T"
	elif number >= 1000000000:
		return str(snapped(number / 1000000000.0, 0.01)) + "B"
	elif number >= 1000000:
		return str(snapped(number / 1000000.0, 0.01)) + "M"
	elif number >= 1000:
		return str(snapped(number / 1000.0, 0.01)) + "K"
	else:
		return str(number)
