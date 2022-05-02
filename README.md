<div align="center">

# `useful`

A collection of useful functions for building `Elixir` Apps.

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/dwyl/gogs/Elixir%20CI?label=build&style=flat-square)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/gogs/master.svg?style=flat-square)](http://codecov.io/github/dwyl/auth?branch=main)
[![Hex.pm](https://img.shields.io/hexpm/v/useful?color=brightgreen&style=flat-square)](https://hex.pm/packages/useful)
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

A library of useful functions that we need for building `Elixir` Apps.

# Who? 👤

This library is for our use on our various `Elixir` / `Phoenix` apps.
As with everything we do it's Open Source, Tested and Documented
so that _anyone_ can benefit from it.

# How? 💻

## Install ⬇️

Install by adding `useful` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:useful, "~> 1.0.0"}
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

### `stringify_tuple/1`

Stringify a tuple of any length; useful in debugging.

```elixir
iex> tuple = {:ok, :example}
iex> Useful.stringify_tuple(tuple)
"ok: example"
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
