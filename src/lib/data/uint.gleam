import gleam/result

pub opaque type UInt {
  UInt(inner: Int)
}

type Self =
  UInt

/// Construct an UInt from an Int
///
/// Returns `option.None` if the given value is negative.
pub fn from_int(val: Int) {
  case val {
    _ if val < 0 -> Error(Nil)
    _ -> Ok(UInt(val))
  }
}

pub fn from_int_unchecked(val: Int) {
  from_int(val)
  |> result.lazy_unwrap(fn() { panic as "UInt can't be negative" })
}

pub fn to_int(self: Self) {
  self.inner
}

pub fn add(self: Self, other: Self) {
  from_int(self.inner + other.inner)
  |> result.lazy_unwrap(fn() { panic as "invariant violation" })
}

pub fn sub(self: Self, other: Self) {
  from_int(self.inner - other.inner)
}

pub fn sub_unchecked(self: Self, other: Self) {
  sub(self, other)
  |> result.lazy_unwrap(fn() { panic as "UInt can't be negative" })
}

pub fn mul(self: Self, other: Self) {
  from_int(self.inner * other.inner)
  |> result.lazy_unwrap(fn() { panic as "invariant violation" })
}

pub fn div(self: Self, other: Self) {
  from_int(self.inner / other.inner)
}

pub fn rem(self: Self, other: Self) {
  from_int(self.inner % other.inner)
}

pub fn one() {
  from_int_unchecked(1)
}
