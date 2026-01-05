extends Node

@onready var audio_player = $Audio
@onready var color_rect = $Color
var spectrum: AudioEffectSpectrumAnalyzerInstance
var audio_texture: ImageTexture
var image: Image
var sample_count: int = 256

func _ready():

    var bus_idx = AudioServer.get_bus_index("Master")


    spectrum = AudioServer.get_bus_effect_instance(bus_idx, 2)
    if spectrum == null:
        push_error("Failed to get spectrum analyzer instance")
        return


    image = Image.create(sample_count, 1, false, Image.FORMAT_RF)
    audio_texture = ImageTexture.create_from_image(image)


    color_rect.material.set_shader_parameter("audio_texture", audio_texture)


    audio_player.play()

func _process(delta):
    if spectrum == null:
        return


    var magnitude = spectrum.get_magnitude_for_frequency_range(20.0, 20000.0)
    var energy = clamp(magnitude.length() * 10.0, 0.0, 1.0)


    var data = []
    for i in range(sample_count):
        var t = float(i) / sample_count
        var sample = sin(t * 10.0 + Time.get_ticks_msec() * 0.001) * energy
        data.append(sample)


    for i in range(sample_count):
        var value = (data[i] + 1.0) / 2.0
        image.set_pixel(i, 0, Color(value, value, value, 1.0))


    audio_texture.update(image)
