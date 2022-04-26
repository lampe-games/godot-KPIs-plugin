tool
extends Node

const PORT = 13377
const MAX_CONNECTIONS = 1


func _ready():
	if not Engine.is_editor_hint():
		return
	var network_peer = NetworkedMultiplayerENet.new()
	network_peer.create_server(PORT, MAX_CONNECTIONS)
	get_tree().network_peer = network_peer


func _exit_tree():
	get_tree().network_peer = null
