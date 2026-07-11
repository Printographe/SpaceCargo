@tool

extends TextureRect
class_name  ExportableTextureRect 


@export var export_name : String = "image_x"
@export_tool_button("Export", "Callable") var exp_img = export_image


func export_image():
    if export_name != "":
        var image := texture.get_image()
        var res = image.save_jpg("res://"+export_name+".jpg", 0.9)
        if res == OK:
            print("Image Exported")
        else:
            print("There has been an export error")
    else:
        push_error("Give A Name")

