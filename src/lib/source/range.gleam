import lib/data/uint
import gleam/result

pub type Range {
  Range(min: uint.UInt, max: uint.UInt)
}

type Self =
  Range

pub fn len(self: Self) {
  self.max
  |> uint.sub_unchecked(self.min)
}

pub fn empty() {
  Range(min: uint.from_int_unchecked(0), max: uint.from_int_unchecked(0))
}

pub fn grow(self) {
  Range(
    ..self,
    max: self.max
    |> uint.add(uint.one()),
  )
}

pub fn shrink(self: Self) {
  use max <- result.try(
    self.max
    |> uint.sub(uint.one()),
  )
  Ok(Range(..self, max: max))
}

pub fn offset(self: Self, offset: uint.UInt) {
  Range(min: uint.add(self.min, offset), max: uint.add(self.max, offset))
}
