extends Node3D

@onready var audio = $Audio

func PlayInstance(audioEvent):
    if audioEvent.audioClips.size() != 0:
        var randomIndex: int = randi_range(0, audioEvent.audioClips.size() - 1)
        audio.stream = audioEvent.audioClips[randomIndex]
        audio.volume_db = randf_range(audioEvent.minVolume, audioEvent.maxVolume)
        audio.pitch_scale = randf_range(audioEvent.minPitch, audioEvent.maxPitch)
        audio.play()

func _process(_delta) -> void :
    if !audio.is_playing():
        queue_free()
