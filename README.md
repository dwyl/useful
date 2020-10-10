<div align="center">

# `useful`

A collection of useful functions for building `Elixir` Apps.

[![Build Status](https://img.shields.io/travis/com/dwyl/useful/master?color=bright-green&style=flat-square)](https://travis-ci.com/dwyl/useful)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/useful/master.svg?style=flat-square)](http://codecov.io/github/dwyl/useful?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/useful?color=brightgreen&style=flat-square)](https://hex.pm/packages/useful)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/useful/issues)

![swiss-army-knife](https://user-images.githubusercontent.com/194400/94815682-b646e300-03f2-11eb-8069-46b9e10fac7e.png)

</div>

# Why?

We found ourselves copy-pasting a few useful "helper" functions
across our Elixir projects ... <br />
it wasn't
["DRY"](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself),
so we created this library.

# What?

A library of useful functions that we need for building `Elixir` Apps.

# Who?

This library is for our use on our various `Elixir` / `Phoenix` apps.
As with everything we do it's Open Source, Tested and Documented
so that _anyone_ can benefit from it.

# How?

## Install

The package can be installed
by adding `useful` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:useful, "~> 0.3.0"}
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

# Docs

Detailed docs available at:
https://hexdocs.pm/useful/Useful.html
