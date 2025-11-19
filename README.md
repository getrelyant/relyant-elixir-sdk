# RelyantApi Elixir SDK

Elixir SDK to communicate with the Relyant API. We are using this public repository to host the Relyant SDK based on the up to date documentation in api.relyant.ai/docs.

## Installation

Add `relyant_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:relyant_api, git: "https://github.com/getrelyant/relyant-elixir-sdk.git"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Configuration

Make sure to set the following environment variables in your application:
- `RELYANT_BASE_API_URL` - The base URL for the Relyant API
- `RELYANT_API_CLIENT_ID` - Your Relyant API client ID
- `RELYANT_API_CLIENT_SECRET` - Your Relyant API client secret

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

## Development

For local development, install Elixir and Erlang using the versions specified in the `.tool-versions` file.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc):

```bash
mix docs
```
