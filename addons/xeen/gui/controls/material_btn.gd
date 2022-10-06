extends TextureButton
class_name MaterialButton

func can_drop_data(position, data):
    return true

func drop_data(position, data):
    print("position: ", position, ", data: ", data)