import gleam/iterator
import gleam/regex
import gleam/result
import gleam/function
import gleam/string
import gleam/io
import lib/source

// pub fn lex(source: source.Source, rules: List(Rule(t))) -> iterator.Iterator(t) {
//   todo
// }

pub type Token =
  #(String, source.Source)

fn try_grow(cursor: source.Source, lexer: fn(source.Source) -> Token) {
  case source.grow(cursor) {
    Ok(cursor) -> lexer(cursor)
    Error(_) -> #("EOF", cursor)
  }
}

fn try_grow_or(
  cursor: source.Source,
  or: Token,
  lexer: fn(source.Source) -> Token,
) {
  case source.grow(cursor) {
    Ok(cursor) -> lexer(cursor)
    Error(_) -> or
  }
}

/// Grow while condition on last char is true
fn try_grow_while(
  cursor: source.Source,
  while: fn(String) -> Bool,
  lexer: fn(source.Source) -> Token,
) {
  case
    source.grow(cursor)
    |> result.map(fn(cursor) {
      #(
        source.to_string(cursor)
          |> string.last
          |> result.lazy_unwrap(fn() { panic as "infallible" })
          |> while,
        cursor,
      )
    })
  {
    Ok(#(True, cursor)) -> try_grow_while(cursor, while, lexer)
    Ok(#(False, _)) -> lexer(cursor)
    Error(_) -> #("EOF", cursor)
  }
}

pub fn lex(source: source.Source) -> iterator.Iterator(Token) {
  use previous <- iterator.iterate(#("SOF", source.begin_anchor(source)))
  lexer_entry(source.end_anchor(previous.1))
}

fn lexer_entry(cursor: source.Source) {
  use cursor <- try_grow(cursor)
  case source.to_string(cursor) {
    // match all fixed tokens
    "," -> #("comma", cursor)
    ":" -> #("colon", cursor)
    ";" -> #("semicolon", cursor)
    "(" -> #("l-paren", cursor)
    ")" -> #("r-paren", cursor)
    "-" -> {
      use cursor <- try_grow(cursor)
      case source.to_string(cursor) {
        "->" -> #("arrow", cursor)
        // we went one char too far, so backtrack by one
        _ -> #("unknown", source.shrink_unchecked(cursor))
      }
    }
    "*" -> {
      use cursor <- try_grow_or(cursor, #("star", cursor))
      case source.to_string(cursor) {
        "**" -> #("double-star", cursor)
        _ -> #("star", source.shrink_unchecked(cursor))
      }
    }

    // discard whitespace ✨recursively✨
    " " | "\r" | "\t" | "\n" ->
      source.end_anchor(cursor)
      |> lexer_entry

    // match variabe length tokens
    "\"" -> {
      use cursor <- try_grow_while(cursor, fn(last) {
        last != "\n" && last != "\""
      })
      use cursor <- try_grow(cursor)
      case
        source.to_string(cursor)
        |> string.last()
        |> result.lazy_unwrap(fn() { panic as "infallible" })
      {
        "\"" -> #("literal-string", cursor)
        _ -> #("unknown", cursor)
      }
    }
    _ -> #("unknown", cursor)
  }
}
