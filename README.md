# Absinthe Constraints

An absinthe library to add type constraints to your GraphQL schema using directives.

## Installation

Install from [Hex.pm](https://hex.pm/packages/absinthe_constraints)

```elixir
def deps do
  [
    {:absinthe_constraints, "~> 0.1.0"}
  ]
end
```

## Usage

#### 1. Add the `constraints` directive's prototype schema to your schema

```elixir
defmodule MyAppWeb.Schema do
  use Absinthe.Schema

  @prototype_schema AbsintheConstraints.Directive

  # Use `import_sdl`, etc...
end
```

#### 2. Add the document phase to your absinthe Pipeline

Example using `Absinthe.Plug`:

```elixir
# Somewhere in your router

def my_pipeline(config, opts) do
  config
  |> Absinthe.Plug.default_pipeline(opts)
  |> AbsintheConstraints.Phase.add_to_pipeline(opts)
end

forward("/", Absinthe.Plug, schema: MyAppWeb.Schema, pipeline: {__MODULE__, :my_pipeline})
```

#### 3. Add constraints to your schema

```elixir
# Somewhere in your schema

# Adding constraints to input object's fields
input_object :coordinates do
  field(:latitude, non_null(:float), directives: [constraints: [min: -90, max: 90]])
  field(:longitude, non_null(:float), directives: [constraints: [min: -180, max: 180]])
end

# Adding constraints to query field's arguments
object :my_queries do
  field :my_field, non_null(:string) do
    arg(:id, non_null(:string), directives: [constraints: [format: "uuid"]])
    resolve(&my_resolver/2)
  end
end
```

## Supported constraints

### String

#### min_length
```directives: [constraints: [min_length: 5]]```
Restrict to a minimum length

#### max_length
```directives: [constraints: [max_length: 5]]```
Restrict to a minimum length

#### max_length
```directives: [constraints: [format: :uuid]]```
Ensure value is in a particular format

Supported formats:
- `:uuid` - uses :elixir_uuid to validate the value
- `:email` - uses a regex to validate the value

### Number (integer/float)

#### min
```directives: [constraints: [min: 5]]```
Ensure value is greater than or equal to

#### max
```directives: [constraints: [max: 5]]```
Ensure value is less than or equal to
