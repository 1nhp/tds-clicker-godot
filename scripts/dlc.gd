extends Node
class_name DLC

signal DownloadSuccesful
signal RemoveSuccesful
signal DLCLoadSuccesful

var dlc = []

func load():
	# Load DLC if it exists
	dlc = [
		ProjectSettings.load_resource_pack("user://AdditionalMusic.pck"),
		]
	if dlc.has(true):
		print_debug("DLC loaded succesfully: " + str(dlc))
		DLCLoadSuccesful.emit()
	else:
		print_debug("Failed to load DLC!")


@onready var http_request: HTTPRequest
@onready var music_dlc_url: String = "https://drive.usercontent.google.com/download?id=135GkZjRHGZCR9g2y7cmxY6TKaRm5STv3&export=download&authuser=0"

func download():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	download_file(music_dlc_url, "user://AdditionalMusic.pck")

func download_file(url: String, save_path: String):
	http_request.download_file = save_path
	http_request.timeout = 10
	
	var err = http_request.request(url)
	if err != OK:
		push_error("Failed to start request: ", err)

func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("File downloaded successfully to: ", http_request.download_file)
		SoundManager.play_sound("Upgrade")
		self.load()
		emit_signal("DownloadSuccesful")
	else:
		push_error("Download failed with response code: ", response_code)


func remove():
	DirAccess.remove_absolute("user://AdditionalMusic.pck")
	self.load()
	emit_signal("RemoveSuccesful")
