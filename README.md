# Xod

Parsing and schema validation library for Elixir

## Introduction

Xod is a dynamic parsing and schema validation library for Elixir inspired by
the [Typescript library Zod](https://github.com/colinhacks/zod). A schema
refers broadly to a specification used to validate and transform any value, from
a simple number to a complex nested object.

Xod provides a functional API. The default schemas have no side effects and use
only immutable state.

Xod is also extensible. Apart from using the helper schemata provided, one can
implement the `Xod.Schema` protocol to create a fully custom schema.

## License

This software is licensed under
[the MIT license](https://github.com/ernestoittig/xod/blob/main/LICENSE).
