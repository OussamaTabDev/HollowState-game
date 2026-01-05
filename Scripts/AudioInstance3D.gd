extends Node3D

@onready var audio = $Audio

func PlayInstance(audioEvent, unitSize: float, maxDistance: float):
    var randomIndex: int = randi_range(0, audioEvent.audioClips.size() - 1)
    audio.stream = audioEvent.audioClips[randomIndex]
    audio.unit_size = unitSize
    audio.max_distance = maxDistance
    audio.volume_db = randf_range(audioEvent.minVolume, audioEvent.maxVolume)
    audio.pitch_scale = randf_range(audioEvent.minPitch, audioEvent.maxPitch)
    audio.play()

func _process(_delta) -> void :
    if !audio.is_playing():
        queue_free()
