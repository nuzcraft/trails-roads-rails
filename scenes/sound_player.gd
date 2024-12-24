extends Node

const CLICK_3 = preload("res://assets/sounds/click3.ogg")
const CLICK_4 = preload("res://assets/sounds/click4.ogg")
const CLICK_5 = preload("res://assets/sounds/click5.ogg")
const MOUSECLICK_1 = preload("res://assets/sounds/mouseclick1.ogg")
const MOUSERELEASE_1 = preload("res://assets/sounds/mouserelease1.ogg")
const ROLLOVER_2 = preload("res://assets/sounds/rollover2.ogg")
const ROLLOVER_3 = preload("res://assets/sounds/rollover3.ogg")
const ROLLOVER_4 = preload("res://assets/sounds/rollover4.ogg")
const SWITCH_8 = preload("res://assets/sounds/switch8.ogg")
const BOOK_FLIP_3 = preload("res://assets/sounds/bookFlip3.ogg")
const IMPACT_GLASS_LIGHT_000 = preload("res://assets/sounds/impactGlass_light_000.ogg")
const IMPACT_GLASS_MEDIUM_000 = preload("res://assets/sounds/impactGlass_medium_000.ogg")
const JINGLES_SAX_10 = preload("res://assets/sounds/jingles_SAX10.ogg")
const JINGLES_SAX_11 = preload("res://assets/sounds/jingles_SAX11.ogg")
const JD_SHERBERT___AMBIENCES_MUSIC_PACK___DESERT_SIROCCO = preload("res://assets/music/jdsherbert/JDSherbert - Ambiences Music Pack - Desert Sirocco.ogg")
const JINGLES_SAX_03 = preload("res://assets/sounds/jingles_SAX03.ogg")

@onready var audio_players: Node = $AudioPlayers
@onready var music_players: Node = $MusicPlayers

func play_sound(sound, volume_percent: int = 100):
	#print('playing sound')
	for audioStreamPlayer: AudioStreamPlayer in audio_players.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.volume_db = linear_to_db(volume_percent / 100.0)
			audioStreamPlayer.pitch_scale = 1.0 + randf_range(-0.1, 0.1)
			audioStreamPlayer.play()
			#print('sound played')
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
			
			
