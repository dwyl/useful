<div align="center">
# `useful`

A collection of useful functions for building `Elixir` Apps.

[![Build Status](https://img.shields.io/travis/com/dwyl/useful/master?color=bright-green&style=flat-square)](https://travis-ci.org/dwyl/useful)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/useful/master.svg?style=flat-square)](http://codecov.io/github/dwyl/useful?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/useful?color=brightgreen&style=flat-square)](https://hex.pm/packages/useful)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/useful/issues)

</div>

# Why?

We found ourselves copy-pasting a few useful "helper" functions
across our Elixir projects and it wasn't 
["DRY"](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).
So we put a stop to the copy-pasting and created this library.

# What?

A library of useful functions that we need for building apps in `Elixir`.


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
    {:useful, "~> 0.1.0"}
  ]
end
```

## Function Reference

### `atomize_map_keys/1`

Converts a `Map` that has strings as keys (or mixed keys)
to have only atoms.

```elixir
# map that has different types of keys:
my_map = %{"name" => "Alex", id: 1}
Useful.atomize_map_keys(my_map)
%{name: Alex, id: 1}
```

Works recursively for deeply nested maps:

```elixir
person = %{"name" => "Alex", id: 1, details: %{"age" => 17, height: 185}}
Useful.atomize_map_keys(my_map)
%{name: Alex, id: 1, details: %{age: 17, height: 185}}
```


# Docs

Detailed docs available at:
[https://hexdocs.pm/useful](https://hexdocs.pm/useful)