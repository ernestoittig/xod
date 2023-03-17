# Xod

Parsing and schema validation library for Elixir

## Introduction

Xod is a dynamic parsing and schema validation library for Elixir inspired by
the [Typescript library Zod](https://github.com/colinhacks/zod). A schema
refers broadly to a specification used to validate and transform any value, from
a simple number to a complex nested object.

Xod provides a functional API. The default schemata have no side effects and use
only immutable state.

Xod is also extensible. Apart from using the helper schemata provided, one can
implement the `Xod.Schema` protocol to create a fully custom schema.

### Example

```elixir
iex> alias Xod, as: X
iex> my_config = X.map(%{
...>   data: X.map(%{
...>     age: X.number(int: true, ge: 0, lt: 150)
...>   }),
...>   names: X.list(X.string() |> X.max(10))
...> }, key_coerce: true)
iex> X.parse(my_config, %{
...>   "data" => %{
...>     age: -10,
...>   },
...>   names: ["John", "Peter", "Chandragupta"]
...> })
{:error,
 %Xod.XodError{issues: [
  [type: :too_small,
   path: [:data, :age],
   message: "Number must be greater than or equal to 0",
   data: [min: 0]
  ],
  [type: :too_big,
   path: [:names, 2],
   message: "String must contain at most 10 character(s)",
   data: [max: 10]
  ]
]}}
```

## Alternatives

### NimbleOptions

<https://github.com/dashbitco/nimble_options>

Very popular library. Validates options defined as keyword lists.

### Optimal

<https://github.com/albert-io/optimal>

Similar to NimbleOptions. Only useful on opts defined as keyword lists.

### Parameter

<https://github.com/phcurado/parameter>

Schema creation, validation with serialization and deserialization.
Works with maps by defining parameters on modules using macros.

### Xema

<https://github.com/hrzndhrn/xema>

Schema validator. Very similar to this project but inspired by JSON schema.

## License

This software is licensed under
[the MIT license](https://github.com/ernestoittig/xod/blob/main/LICENSE).
