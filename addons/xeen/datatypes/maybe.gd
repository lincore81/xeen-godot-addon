extends Object

class_name Maybe

var _value
var _is_empty: bool

func _init(v, empty: bool):
    _value = v
    _is_empty = empty

func is_some():
    return not _is_empty

func is_none():
    return _is_empty

func value(default := null):
    return _value if not _is_empty else default
