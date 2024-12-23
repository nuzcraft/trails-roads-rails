extends Node

const CLICK_1 = preload("res://assets/sounds/click1.ogg")
const CLICK_2 = preload("res://assets/sounds/click2.ogg")
const CLICK_3 = preload("res://assets/sounds/click3.ogg")
const CLICK_4 = preload("res://assets/sounds/click4.ogg")
const CLICK_5 = preload("res://assets/sounds/click5.ogg")
const MOUSECLICK_1 = preload("res://assets/sounds/mouseclick1.ogg")
const MOUSERELEASE_1 = preload("res://assets/sounds/mouserelease1.ogg")
const ROLLOVER_1 = preload("res://assets/sounds/rollover1.ogg")
const ROLLOVER_2 = preload("res://assets/sounds/rollover2.ogg")
const ROLLOVER_3 = preload("res://assets/sounds/rollover3.ogg")
const ROLLOVER_4 = preload("res://assets/sounds/rollover4.ogg")
const ROLLOVER_5 = preload("res://assets/sounds/rollover5.ogg")
const ROLLOVER_6 = preload("res://assets/sounds/rollover6.ogg")
const SWITCH_8 = preload("res://assets/sounds/switch8.ogg")
const JINGLES_PIZZI_04 = preload("res://assets/sounds/jingles_PIZZI04.ogg")
const JINGLES_PIZZI_16 = preload("res://assets/sounds/jingles_PIZZI16.ogg")
const BOOK_FLIP_3 = preload("res://assets/sounds/bookFlip3.ogg")

@onready var audio_players: Node = $AudioPlayers
@onready var music_players: Node = $MusicPlayers

func play_sound(sound, volume_percent: int = 100):
	print('playing sound')
	for audioStreamPlayer: AudioStreamPlayer in audio_players.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.volume_db = linear_to_db(volume_percent / 100.0)
			audioStreamPlayer.play()
			print('sound played')
			break
			
func play_music(sound):
	for audioStreamPlayer: AudioStreamPlayer in music_players.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.volume_db = 0
			audioStreamPlayer.play()
			break
			
func stop_music():
	for audioStreamPlayer: AudioStreamPlayer in music_players.get_children():
		if audioStreamPlayer.playing:
			audioStreamPlayer.stop()
			
func transition_music(sound):
	var playingStream: AudioStreamPlayer
	for audioStreamPlayer: AudioStreamPlayer in music_players.get_children():
		if audioStreamPlayer.playing:
			playingStream = audioStreamPlayer
			break
	var notPlayingStream: AudioStreamPlayer
	for audioStreamPlayer: AudioStreamPlayer in music_players.get_children():
		if not audioStreamPlayer == playingStream:
			notPlayingStream = audioStreamPlayer
			break
	notPlayingStream.volume_db = -80
	notPlayingStream.stream = sound
	if playingStream:
		if not notPlayingStream.stream == playingStream.stream:
			notPlayingStream.play(5.0)
			var tween = get_tree().create_tween()
			tween.tween_property(playingStream, "volume_db", -80, 1.5).set_ease(Tween.EASE_IN_OUT)
			tween.parallel().tween_property(notPlayingStream, "volume_db", 0, 1.5).set_ease(Tween.EASE_IN_OUT)
			tween.tween_callback(playingStream.stop)
	else:
		notPlayingStream.play()
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(notPlayingStream, "volume_db", 0, 1.5).set_ease(Tween.EASE_IN_OUT)
			
			
