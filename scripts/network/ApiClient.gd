extends Node

const BASE_URL = "http://localhost:3000/api"
var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)

func login(username: String, password: String, callback: Callable):
	var body = JSON.stringify({"username": username, "password": password})
	_post("/login", body, callback)

func register(username: String, password: String, callback: Callable):
	var body = JSON.stringify({"username": username, "password": password})
	_post("/register", body, callback)

func save_game(user_id: String, save_name: String, data: Dictionary, callback: Callable):
	var body = JSON.stringify({"user_id": user_id, "name": save_name, "data": data})
	_post("/saves", body, callback)

func load_saves(user_id: String, callback: Callable):
	_get("/saves?user_id=" + user_id, callback)

func delete_save(save_id: String, callback: Callable):
	_delete("/saves/" + save_id, callback)

func get_leaderboard(callback: Callable):
	_get("/leaderboard", callback)

func _post(endpoint: String, body: String, callback: Callable):
	var url = BASE_URL + endpoint
	http_request.request_completed.connect(_on_response.bind(callback), CONNECT_ONE_SHOT)
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _get(endpoint: String, callback: Callable):
	var url = BASE_URL + endpoint
	http_request.request_completed.connect(_on_response.bind(callback), CONNECT_ONE_SHOT)
	http_request.request(url)

func _delete(endpoint: String, callback: Callable):
	var url = BASE_URL + endpoint
	http_request.request_completed.connect(_on_response.bind(callback), CONNECT_ONE_SHOT)
	http_request.request(url, [], HTTPClient.METHOD_DELETE)

func _on_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callback: Callable):
	if response_code >= 200 and response_code < 300:
		var text = body.get_string_from_utf8()
		var json = JSON.parse_string(text)
		callback.call(true, json)
	else:
		callback.call(false, {"error": "HTTP %d" % response_code})
