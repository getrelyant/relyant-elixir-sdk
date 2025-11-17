# RelyantApi

Elixir SDK to communicate with the Relyant API. Install Elixir and Erlang to use this integration.
Take the versions in the .tool-versions file.

## Integration
In order to integrate the Elixir Relyant SDK, just install the package using:
```

```

And then make sure to set the following environment variables in your application:
- RELYANT_BASE_API_URL
- RELYANT_API_CLIENT_ID
- RELYANT_API_CLIENT_SECRET

## Run IEX Session

`iex -S mix`

## Test the SDK Integration

`mix test`

You can run tests on a specific file in Elixir using:

`mix test test/query_test.exs`

Or to run a specific test within that file, you can specify the line number:

`mix test test/query_test.exs:11`

You can also use pattern matching to run tests with specific names:

`mix test --only test:"llm_query/2 returns a response"`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `relyant_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:relyant_api, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/relyant_api>.
