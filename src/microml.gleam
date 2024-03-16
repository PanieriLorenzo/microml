import gleam/io
import lib/source
import lib/lexer
import gleam/result
import gleam/iterator

pub fn main() {
  use item <- iterator.each(
    source.from_string("\"lmao\"")
    |> lexer.lex()
    |> iterator.take(20),
  )
  io.println(item.0)
}
