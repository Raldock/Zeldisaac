extends Object
class_name Maths


static func clampi(value: int, min_v: int, max_v: int) -> int:
	return int(clamp(float(value), float(min_v), float(max_v)))
