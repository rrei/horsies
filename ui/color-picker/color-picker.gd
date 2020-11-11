extends GridContainer

func _ready():
    for child in self.get_children():
        var swatch := child as ColorRect
        # swatch.connect("gui_input", self, "_on_swatch_input", [swatch])


func _on_swatch_input(event: InputEvent, swatch: ColorRect):
    print(event.as_text())
    if event is InputEventMouseMotion:
        swatch.grab_focus()
    if event.is_action_pressed("ui_accept"):
        swatch.grab_focus()
        self.selected_color = swatch.color
        print("Color selected:", self.selected_color)
