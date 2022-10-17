--experimental: strictEffects
  # Turn on the new refined effect tracking. It enables the new .effectsOf
  # annotation for effect polymorphic code ("this code raises if the callback does so").

--experimental: unicodeOperators
  # Allow the usage of Unicode operators.

--define: nimPreviewDotLikeOps
  # Dot-like operators (operators starting with `.`, but not with `..`)
  # now have the same precedence as `.`, so that `a.?b.c` is now parsed as `(a.?b).c`
  # instead of `a.?(b.c)`.

--define: nimPreviewFloatRoundtrip
  # Enable much faster "floating point to string" operations that also produce
  # easier to read floating point numbers.

--mm: orc
  # The one and only way to do memory management in modern Nim.

--define: nimStrictDelete
  # Make system.delete strict for index out of bounds accesses.

--experimental: overloadableEnums

--opt: speed
--define: lto
