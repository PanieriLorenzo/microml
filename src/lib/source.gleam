import lib/data/uint
import lib/source/range
import gleam/option
import gleam/result
import gleam/string
import gleam/list
import simplifile

pub opaque type Source {
  Source(path: option.Option(String), text: String, range: range.Range)
}

type Self =
  Source

pub fn from_file(path: String) {
  use text <- result.try(simplifile.read(path))
  Ok(Source(
    path: option.Some(path),
    text: text,
    range: range.Range(
      min: uint.from_int_unchecked(0),
      max: uint.from_int_unchecked(string.length(text)),
    ),
  ))
}

pub fn from_string(str: String) {
  Source(
    path: option.None,
    text: str,
    range: range.Range(
      min: uint.from_int_unchecked(0),
      max: uint.from_int_unchecked(string.length(str)),
    ),
  )
}

pub fn len(src: Source) {
  src.range
  |> range.len
}

// pub fn at(src: Source, idx: uint.UInt) {
//   src.text
//   |> string.to_graphemes
//   |> list.at(
//     idx
//     |> uint.to_int,
//   )
// }

/// Returns the anchor pointing to the beginning of the source string
pub fn begin_anchor(self) {
  Source(
    ..self,
    range: range.empty()
    |> range.offset(self.range.min),
  )
}

/// Returns the anchor pointing to the end of the source string
pub fn end_anchor(self) {
  Source(
    ..self,
    range: range.empty()
    |> range.offset(self.range.max),
  )
}

pub fn grow(self: Self) {
  let range = range.grow(self.range)
  use _ <- result.try(
    string.length(self.text)
    |> uint.from_int_unchecked
    |> uint.sub(range.max),
  )
  Ok(Source(..self, range: range))
}

pub fn grow_unchecked(self) {
  grow(self)
  |> result.lazy_unwrap(fn() {
    panic as "can't grow Source past original text size"
  })
}

pub fn shrink(self: Self) {
  use range <- result.try(range.shrink(self.range))
  Ok(Source(..self, range: range))
}

pub fn shrink_unchecked(self: Self) {
  use <- result.lazy_unwrap(shrink(self))
  panic as "can't shrink zero-sized Source"
}

pub fn to_string(self: Self) {
  string.slice(
    from: self.text,
    at_index: uint.to_int(self.range.min),
    length: range.len(self.range)
      |> uint.to_int,
  )
}

pub fn inspect(self: Self) {
  {
    self.path
    |> option.map(fn(path) { "@" <> path <> ": " })
    |> option.unwrap("")
  }
  <> "\""
  <> string.slice(
    from: self.text,
    at_index: 0,
    length: uint.to_int(self.range.min),
  )
  <> "["
  <> string.slice(
    from: self.text,
    at_index: uint.to_int(self.range.min),
    length: range.len(self.range)
      |> uint.to_int,
  )
  <> "]"
  <> string.slice(
    from: self.text,
    at_index: uint.to_int(self.range.max),
    length: string.length(self.text) - uint.to_int(self.range.max),
  )
  <> "\""
}
