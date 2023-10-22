import pkg/raylib
import geometry, levels

converter vec2ToRaylibVec*(v: Vec2): Vector2 = Vector2(x: v.x.cfloat, y: v.y.cfloat)
converter colorTupToRaylibColor*(c: levels.Color): raylib.Color =
  raylib.Color(r: c.r.uint8, g: c.g.uint8, b: c.b.uint8, a: 255'u8)
converter intToInt32*(n: int): int32 = n.int32
