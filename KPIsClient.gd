tool
extends Node

const IP = "127.0.0.1"
const PORT = 13377  # TODO: move to config

var _connected = false


func _ready():
	if Engine.is_editor_hint():
		return
	var network_peer = NetworkedMultiplayerENet.new()
	network_peer.create_client(IP, PORT)
	get_tree().network_peer = network_peer
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")


func _process(_delta):
	if not _connected:
		return
	var data = {
		"kpis":
		{
			"time_fps": Performance.get_monitor(Performance.TIME_FPS),
			"time_process": Performance.get_monitor(Performance.TIME_PROCESS),
			"time_physics_process": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
		},
		"user_kpis": {}
	}
	if get_node("/root").has_meta("user_kpis"):
		data["user_kpis"] = get_node("/root").get_meta("user_kpis")
	rpc("_feed_data", data)


remote func _feed_data(data):
	var kpis_displays = get_tree().get_nodes_in_group("kpis_plugin_displays")
	if kpis_displays.empty():
		return
	var kpis_display = kpis_displays[0]
	var user_kpis = ""
	for user_kpi in data["user_kpis"]:  # TODO: sort
		user_kpis += "\n" + user_kpi + ": " + str(data["user_kpis"][user_kpi])
	kpis_display.bbcode_text = "[u]FPS: {0}[/u]\nProcess: {1}\nPhy Process: {2}\n{3}".format(
		[
			"%0.1f" % data["kpis"]["time_fps"],
			"%0.1f" % (data["kpis"]["time_process"] * 1000.0),
			"%0.1f" % (data["kpis"]["time_physics_process"] * 1000.0),
			user_kpis,
		]
	)


func _on_connected_to_server():
	_connected = true


func _on_server_disconnected():
	_connected = false
