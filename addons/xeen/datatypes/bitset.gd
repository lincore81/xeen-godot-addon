extends Reference
class_name BitSet

var _value := 0

func has(bit: int) -> bool:
    return _value & bit == bit

func setbit(bit: int) -> void:
    if bit <= 0:
        push_error("setbit: bit must be positive")
        return
    _value |= bit

func clearbit(bit: int) -> void:
    if bit <= 0:
        push_error("clearbit: bit must be positive")
    _value -= _value & bit

func togglebit(bit: int) -> void:
    if bit <= 0:
        push_error("togglebit: bit must be positive")
        return
    elif has(bit):
        _value -= _value & bit
    else:
        _value |= bit

func toarray() -> Array:
    var result := []
    var n := 1
    while n <= _value:
        result.append(_value & n == n)
        n *= 2
    return result

func tostr() -> String:
    var n := 1
    var bits = toarray()
    var result = "[BitSet"
    for b in bits:
        if b:
            result += " %d" % (2 << n)
    return result + "]"