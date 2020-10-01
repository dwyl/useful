# `useful`

A collection of useful functions for working in `Elixir`.


# Why?

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

## Use in Your Code

```elixir
# map that has different types of keys:
my_map = %{"name" => "Alex", id: 1}
Useful.atomize_map_keys(my_map)
%{name: Alex, id: 1}
```


# Docs

Detailed docs available at:
[https://hexdocs.pm/useful](https://hexdocs.pm/useful)