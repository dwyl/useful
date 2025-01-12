<div align="center">

# `useful`

A collection of useful functions for building `Elixir` Apps.

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dwyl/useful/ci.yml?label=build&style=flat-square&branch=main)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/gogs/main.svg?style=flat-square)](http://codecov.io/github/dwyl/auth?branch=main)
[![Hex.pm](https://img.shields.io/hexpm/v/useful?color=brightgreen&style=flat-square)](https://hex.pm/packages/useful)
[![Libraries.io dependency status](https://img.shields.io/librariesio/release/hex/useful?logoColor=brightgreen&style=flat-square)](https://libraries.io/hex/useful)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/useful/issues)
[![HitCount](http://hits.dwyl.com/dwyl/useful.svg)](http://hits.dwyl.com/dwyl/useful)

![swiss-army-knife](https://user-images.githubusercontent.com/194400/94815682-b646e300-03f2-11eb-8069-46b9e10fac7e.png)

</div>

# Why? 🤷

We found ourselves copy-pasting a few useful "helper" functions
across our Elixir projects ... <br />
it wasn't
["DRY"](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself),
so we created this library.

# What? 💭

A library of useful functions
that we reach for
when building `Elixir` Apps.

# Who? 👤

This library is used in our various `Elixir` / `Phoenix` apps. <br />
As with everything we do it's Open Source, Tested and Documented
so that _anyone_ can benefit from it.

# How? 💻

## Install ⬇️

Install by adding `useful` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:useful, "~> 1.14.0"}
  ]
end
```

## Function Reference

### `atomize_map_keys/1`

Converts a `Map` that has strings as keys (or mixed keys)
to have only atom keys. e.g:

```elixir
# map that has different types of keys:
my_map = %{"name" => "Alex", id: 1}
Useful.atomize_map_keys(my_map)
%{name: Alex, id: 1}
```

Works recursively for deeply nested maps:

```elixir
person = %{"name" => "Alex", id: 1, details: %{"age" => 17, height: 185}}
Useful.atomize_map_keys(person)
%{name: Alex, id: 1, details: %{age: 17, height: 185}}
```

### `flatten_map/1`

Flatten a `Map` of any depth/nesting:

```elixir
iex> map = %{name: "alex", data: %{age: 17, height: 185}}
iex> Useful.flatten_map(map)
%{data__age: 17, data__height: 185, name: "alex"}
```

**Note**: `flatten_map/1` converts all Map keys to `Atom`
as it's easier to work with atoms as keys
e.g: `map.person__name` instead of `map["person__name"]`.
We use the `__` (_double underscore_)
as the delimiter for the keys of nested maps,
because if we attempt to use `.` (_period character_)
we get an error:

```elixir
iex(1)> :a.b
** (UndefinedFunctionError) function :a.b/0 is undefined (module :a is not available)
    :a.b()
```

### `get_in_default/1`

Get a deeply nested value from a map.
`get_in_default/3` Proxies `Kernel.get_in/2`
but allows setting a `default` value as the 3rd argument.

```elixir
iex> map = %{name: "alex", detail: %{age: 17, height: 185}}
iex> Useful.get_in_default(map, [:data, :age])
17
iex> Useful.get_in_default(map, [:data, :everything], "Awesome")
"Awesome"
iex> Useful.get_in_default(conn, [:assigns, :person, :id], 0)
0
```

We needed this for getting `conn.assigns.person.id`
in our [`App`](https://github.com/dwyl/mvp/)
without having to write a bunch of boilerplate!
e.g:

```elixir
person_id =
  case Map.has_key?(conn.assigns, :person) do
    false -> 0
    true -> Map.get(conn.assigns.person, :id)
  end
```

is just:

```elixir
person_id = Useful.get_in_default(conn, [:assigns, :person, :id], 0)
```

_Muuuuuuch cleaner/clearer_! 😍
If any of the keys in the list is not found
it doesn't _explode_ with errors,
simply returns the `default` value `0`
and continues!

> **Note**: Code inspired by:
> [stackoverflow.com/questions/48781427/optional-default-value-for-get-in](https://stackoverflow.com/questions/48781427/optional-default-value-for-get-in-access-behavior-elixir/48781493#48781493) <br />
> All credit to [**`@PatNowak`**](https://github.com/PatNowak) 🙌

The ideal syntax for this would be:

```elixir
person_id = conn.assigns.person.id || 0
```

But `Elixir` "_Me no likey_" ...
So this is what we have.

### `list_tuple_to_unique_keys/1`

Turns a list of tuples with the _same_ key
into a list of tuples with _unique_ keys.
Useful when dealing with "multipart" forms
that upload multiple files. e.g:

```elixir
parts = [
  {"files",[{"content-type", "image/png"},{"content-disposition","form-data; name=\"files\"; filename=\"first.png\""}],%Plug.Upload{path: "..", content_type: "image/png",filename: "first.png"}},
  {"files",[{"content-type", "image/webp"},{"content-disposition","form-data; name=\"files\"; filename=\"second.webp\""}],%Plug.Upload{path: "...",content_type: "image/webp",filename: "second.webp"}}
]


Useful.list_tuples_to_unique_keys(parts) =
[
  {"files-1",[{"content-type", "image/png"},{"content-disposition","form-data; name=\"files\"; filename=\"first.png\""}],%Plug.Upload{path: "..", content_type: "image/png",filename: "first.png"}},
  {"files-2",[{"content-type", "image/webp"},{"content-disposition","form-data; name=\"files\"; filename=\"second.webp\""}],%Plug.Upload{path: "...",content_type: "image/webp",filename: "second.webp"}}
]
```

### `remove_item_from_list/2`

Remove an `item` from a `list`.

With numbers:

```elixir
list = [1, 2, 3, 4]
Useful.remove_item_from_list(list, 3)
[1, 2, 4]
```

With a `List` of `Strings`:

```elixir
list = ["climate", "change", "is", "not", "real"]
Useful.remove_item_from_list(list, "not")
["climate", "change", "is", "real"]
```

The `list` is the first argument to the function
so it's easy to pipe:

```elixir
get_list_of_items(person_id)
|> Useful.remove_item_from_list("item_to_be_removed")
|> etc.
```

### `stringify_map/1`

Stringify a `Map` e.g. to store it in a DB or log it stdout.

```elixir
map = %{name: "alex", data: %{age: 17, height: 185}}
Useful.stringify_map(map)
"data__age: 17, data__height: 185, name: alex"
```

### `stringify_tuple/1`

Stringify a tuple of any length; useful in debugging.

```elixir
iex> tuple = {:ok, :example}
iex> Useful.stringify_tuple(tuple)
"ok: example"
```

### `truncate/3`

> **truncate**; To shorten (something) by, or as if by, cutting part of it off.
> [wiktionary.org/wiki/truncate](https://en.wiktionary.org/wiki/truncate)

Returns a truncated version of the `String` according to the desired `length`.
_Useful_ if your displaying an uncertain amount of text in an interface.
E.g. the "bio" field on GitHub can be up **`160 characters`**.
_Most_ `people` don't have a `bio` but some use every character.
If you're displaying profiles in an interface, you want a _predictable_ length.
Usage:

```elixir
iex> input = "You cannot lose what you never had."
iex> Useful.truncate(input, 18)
"You cannot lose ..."
```

The **_optional_ third argument** `terminator`
allows specify any `String` or an _empty_ `String` if you prefer
as the terminator for your truncated text:

```elixir
iex> input = "do or do not there is no try"
iex> Useful.truncate(input, 12, "") # no ellipsis
"do or do not"

iex> input = "It was the best of times, it was the worst of times"
iex> Useful.trucate(input, 25, "")
"It was the best of times"
```

### `typeof/1`

Returns the type of a variable, e.g: "function" or "integer"
Inspired by
[**`typeof`**](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof)
from `JavaScript` land.

```elixir
iex> myvar = 42
iex> Useful.typeof(myvar)
"integer"
```

### `empty_dir_contents/1`

Empties the directory
(_deletes all files and any nested directories_)
recursively, but does _not_ delete the actual directory.
This is useful when you want to reset a directory,
e.g. when testing.

```elixir
iex> dir = "tmp" # contains lots of sub directories and files
iex> Useful.empty_dir_contents(dir)
{:ok, dir}
```

<br />

# Docs 📜

Detailed docs available at:
https://hexdocs.pm/useful/Useful.html

<br />

# Help Us Help You! 🙏

If you need a specific helper function or utility
(e.g: something you found useful in a different programming language),
please
[open an issue](https://github.com/dwyl/useful/issues)
so that we can all benefit from useful functions.

Thanks!
