defmodule RelyantApi.Agents do

  @doc """
  Creates an agent in Relyant with API call tools.

  ## Parameters
  - name: The name of the agent (required).
  - description: The description of the agent (required).
  - model: The model to use for the agent (required).
  - tools: List of api_call tool maps (required). Each tool must contain an "api_call" key with:
      - name: The name of the API call (required)
      - description: Description of what the API call does (required)
      - endpoint: The API endpoint URL (required)
      - method: HTTP method (required, e.g., "POST", "GET", "PUT", "DELETE")
      - body: Request body schema (optional)
      - params: Request parameters schema (optional)
      - headers: Request headers schema (optional)
      - response: Response schema (optional)
  - opts: Keyword list with the following optional options:
    - user_id: The user ID creating the agent (optional).
    - email: The email of the user creating the agent (optional).
    - params: Agent parameters with schema and value (optional).
    - user_prompt: User prompt template (optional).
    - icon_url: URL to the agent icon (optional).

  ## Returns
  - `{:ok, response}` on success with the created agent details
  - `{:error, reason}` on failure

  ## Examples

      # Create an agent with API call tools
      tools = [
        %{
          "api_call" => %{
            "name" => "get_employee_data",
            "description" => "Retrieve the employee data from the company's database",
            "endpoint" => "https://jsonplaceholder.typicode.com/users",
            "method" => "GET",
            "params" => %{},
            "headers" => %{}
          }
        },
        %{
          "api_call" => %{
            "name" => "get_posts",
            "description" => "Retrieve posts from the company's database",
            "endpoint" => "https://jsonplaceholder.typicode.com/posts",
            "method" => "GET",
            "params" => %{
              "type" => "object",
              "description" => "Query parameters for retrieving posts",
              "properties" => %{
                "userId" => %{
                  "type" => "string",
                  "description" => "The ID of the user to retrieve posts for"
                }
              }
            },
            "headers" => %{}
          }
        }
      ]
      RelyantApi.Agents.create_agent(
        "Employee Assistant",
        "An agent that retrieves employee and post information",
        "gpt-4o-mini",
        tools,
        user_id: "user123",
        email: "test@example.com",
        user_prompt: "Retrieve employee data and their posts"
      )
  """
  def create_agent(name, description, model, tools, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)
    params = Keyword.get(opts, :params)
    user_prompt = Keyword.get(opts, :user_prompt)
    icon_url = Keyword.get(opts, :icon_url)

    # Get and validate access token
    with token when is_binary(token) <- RelyantApi.Requests.get_relyant_access_token() do

      url = RelyantApi.Requests.base_api_url() <> "/api/v1/agents"
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"},
        {"X-User-ID", user_id},
        {"X-User-Email", email}
      ]

      # Format tools with type and api_call fields
      formatted_tools = Enum.map(tools, fn tool ->
        %{
          "type" => "api_call",
          "name" => tool["name"],
          "description" => tool["description"],
          "api_call" => tool["api_call"],
        }
      end)

      # Build request body with required and optional fields
      entity = %{
        "name" => name,
        "agent_type" => "custom",
        "description" => description,
        "tools" => formatted_tools,
      }
      |> add_optional_field("model", model)
      |> add_optional_field("params", params)
      |> add_optional_field("user_prompt", user_prompt)
      |> add_optional_field("icon_url", icon_url)

      data = %{
        "entities" => [entity]
      }

      case RelyantApi.Requests.execute_api_request(url, :post, headers, data) do
        {:ok, response} ->
          {:ok, response}

        other ->
          {:error, other}
      end
    else
      nil ->
        {:error, {:missing_credentials, "RELYANT_API_CLIENT_ID or RELYANT_API_CLIENT_SECRET environment variables are not set"}}

      other ->
        {:error, {:authentication_failed, other}}
    end
  end

  @doc """
  Retrieves agents for a specific user.

  ## Parameters
  - owner_id: The user ID to retrieve agents for (required).
  - opts: Keyword list with the following optional options:
    - user_id: The user ID making the request (optional, for authentication).
    - email: The email of the user making the request (optional, for authentication).

  ## Returns
  - `{:ok, agents}` on success with a list of agents
  - `{:error, reason}` on failure

  ## Examples

      # Get all agents for a user
      RelyantApi.Agents.get_agents("user123", user_id: "user123", email: "test@example.com")
  """
  def get_agents(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)

    # Get and validate access token
    with token when is_binary(token) <- RelyantApi.Requests.get_relyant_access_token() do

      url = RelyantApi.Requests.base_api_url() <> "/api/v1/agents"
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"},
        {"X-User-ID", user_id},
        {"X-User-Email", email}
      ]

      case RelyantApi.Requests.execute_api_request(url, :get, headers) do
        {:ok, response} ->
          {:ok, response}

        other ->
          {:error, other}
      end
    else
      nil ->
        {:error, {:missing_credentials, "RELYANT_API_CLIENT_ID or RELYANT_API_CLIENT_SECRET environment variables are not set"}}

      other ->
        {:error, {:authentication_failed, other}}
    end
  end

  @doc """
  Updates an existing agent in Relyant.

  ## Parameters
  - entity_id: The ID of the agent to update (required).
  - opts: Keyword list with fields to update (at least one field required):
    - user_id: The user ID updating the agent (optional, for authentication).
    - email: The email of the user updating the agent (optional, for authentication).
    - name: The name of the agent (optional).
    - description: The description of the agent (optional).
    - model: The model to use for the agent (optional).
    - tools: List of api_call tool maps (optional). Same format as create_agent.
    - params: Agent parameters with schema and value (optional).
    - user_prompt: User prompt template (optional).
    - icon_url: URL to the agent icon (optional).
    - is_active: Whether the agent is active (optional).

  ## Returns
  - `{:ok, response}` on success with the updated agent details
  - `{:error, reason}` on failure

  ## Examples

      # Update agent name and model
      RelyantApi.Agents.update_agent(
        "agent-uuid-123",
        user_id: "user123",
        name: "Updated Agent Name",
        model: "gpt-4"
      )

      # Update agent tools
      tools = [
        %{
          "api_call" => %{
            "name" => "get_data",
            "description" => "Retrieve data",
            "endpoint" => "https://api.example.com/data",
            "method" => "GET",
            "params" => %{},
            "headers" => %{}
          }
        }
      ]
      RelyantApi.Agents.update_agent(
        "agent-uuid-123",
        user_id: "user123",
        tools: tools,
        user_prompt: "New prompt"
      )
  """
  def update_agent(entity_id, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)
    name = Keyword.get(opts, :name)
    description = Keyword.get(opts, :description)
    model = Keyword.get(opts, :model)
    tools = Keyword.get(opts, :tools)
    params = Keyword.get(opts, :params)
    user_prompt = Keyword.get(opts, :user_prompt)
    icon_url = Keyword.get(opts, :icon_url)
    is_active = Keyword.get(opts, :is_active)

    # Get and validate access token
    with token when is_binary(token) <- RelyantApi.Requests.get_relyant_access_token() do

      url = RelyantApi.Requests.base_api_url() <> "/api/v1/agents"
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"},
        {"X-User-ID", user_id},
        {"X-User-Email", email}
      ]

      # Format tools if provided
      formatted_tools = if tools do
        Enum.map(tools, fn tool ->
          %{
            "type" => "api_call",
            "name" => tool["name"],
            "description" => tool["description"],
            "api_call" => tool["api_call"],
          }
        end)
      else
        nil
      end

      # Build fields_to_update object with only provided fields
      fields_to_update = %{}
      |> add_optional_field("name", name)
      |> add_optional_field("description", description)
      |> add_optional_field("model", model)
      |> add_optional_field("tools", formatted_tools)
      |> add_optional_field("params", params)
      |> add_optional_field("user_prompt", user_prompt)
      |> add_optional_field("icon_url", icon_url)
      |> add_optional_field("is_active", is_active)

      # Build request body
      data = %{
        "entity_id" => entity_id,
        "fields_to_update" => fields_to_update
      }

      case RelyantApi.Requests.execute_api_request(url, :put, headers, data) do
        {:ok, response} ->
          {:ok, response}

        other ->
          {:error, other}
      end
    else
      nil ->
        {:error, {:missing_credentials, "RELYANT_API_CLIENT_ID or RELYANT_API_CLIENT_SECRET environment variables are not set"}}

      other ->
        {:error, {:authentication_failed, other}}
    end
  end


  @doc """
  Deletes an existing agent in Relyant.

  ## Parameters
  - entity_id: The ID of the agent to delete (required).
  - opts: Keyword list with the following optional options:
    - user_id: The user ID deleting the agent (optional, for authentication).
    - email: The email of the user deleting the agent (optional, for authentication).

  ## Returns
  - `{:ok, response}` on success
  - `{:error, reason}` on failure

  ## Examples

      # Delete an agent
      RelyantApi.Agents.delete_agent("agent-uuid-123", user_id: "user123", email: "test@example.com")
  """
  def delete_agent(entity_id, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)

    # Get and validate access token
    with token when is_binary(token) <- RelyantApi.Requests.get_relyant_access_token() do

      url = RelyantApi.Requests.base_api_url() <> "/api/v1/agents"
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"},
        {"X-User-ID", user_id},
        {"X-User-Email", email}
      ]

      data = %{
        "entity_id" => entity_id
      }

      case RelyantApi.Requests.execute_api_request(url, :delete, headers, data) do
        {:ok, response} ->
          {:ok, response}

        other ->
          {:error, other}
      end
    else
      nil ->
        {:error, {:missing_credentials, "RELYANT_API_CLIENT_ID or RELYANT_API_CLIENT_SECRET environment variables are not set"}}

      other ->
        {:error, {:authentication_failed, other}}
    end
  end

  @doc """
  Calls an agent with a prompt and optional context.

  ## Parameters
  - agent: Map containing the agent configuration (required). Must include:
    - id: The agent ID (required)
    - type: The type of step, should be "agent" (required)
    - user_prompt: The prompt to send to the agent (optional)
    - Other agent configuration fields as needed
  - opts: Keyword list with the following optional options:
    - user_id: The user ID making the request (optional, for authentication).
    - email: The email of the user making the request (optional, for authentication).
    - flow_id: The flow ID to associate with this agent call (optional).
    - context: List of previous messages for context (optional).

  ## Returns
  - `{:ok, response}` on success with the agent's response
  - `{:error, reason}` on failure

  ## Examples

      # Call an agent with a simple prompt
      agent = %{
        "id" => "agent-uuid-123",
        "type" => "agent",
        "user_prompt" => "What is the weather today?"
      }
      RelyantApi.Agents.call_agent(agent, user_id: "user123", email: "test@example.com")

      # Call an agent with context from previous messages
      context = [
        %{"role" => "user", "content" => "Hello"},
        %{"role" => "assistant", "content" => "Hi there!"}
      ]
      RelyantApi.Agents.call_agent(agent,
        user_id: "user123",
        email: "test@example.com",
        context: context,
        flow_id: "flow-uuid-456"
      )
  """
  def call_agent(agent, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)
    flow_id = Keyword.get(opts, :flow_id)
    context = Keyword.get(opts, :context)

    # Get and validate access token
    with token when is_binary(token) <- RelyantApi.Requests.get_relyant_access_token() do

      url = RelyantApi.Requests.base_api_url() <> "/api/v1/flows/agent-call"
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"},
        {"X-User-ID", user_id},
        {"X-User-Email", email}
      ]

      # Build request body
      data = %{
        "agent" => agent
      }
      |> add_optional_field("flow_id", flow_id)
      |> add_optional_field("context", context)

      case RelyantApi.Requests.execute_api_request(url, :post, headers, data) do
        {:ok, response} ->
          {:ok, response}

        other ->
          {:error, other}
      end
    else
      nil ->
        {:error, {:missing_credentials, "RELYANT_API_CLIENT_ID or RELYANT_API_CLIENT_SECRET environment variables are not set"}}

      other ->
        {:error, {:authentication_failed, other}}
    end
  end



  @doc """
  Calls an agent with a prompt and optional context using Server-Sent Events (SSE) streaming.

  This function calls the streaming endpoint and returns the raw HTTP response stream.
  The caller is responsible for parsing the SSE stream, which delivers messages in the format:
  `data: <json_message>\n\n`

  Each message is a JSON object with fields like:
  - role: "assistant" or "user"
  - content: The message content

  ## Parameters
  - agent: Map containing the agent configuration (required). Must include:
    - id: The agent ID (required)
    - type: The type of step, should be "agent" (required)
    - user_prompt: The prompt to send to the agent (optional)
    - Other agent configuration fields as needed
  - opts: Keyword list with the following optional options:
    - user_id: The user ID making the request (optional, for authentication).
    - email: The email of the user making the request (optional, for authentication).
    - flow_id: The flow ID to associate with this agent call (optional).
    - context: List of previous messages for context (optional).

  ## Returns
  - `{:ok, response}` on success where response contains the streaming HTTP response
  - `{:error, reason}` on failure

  ## Handling the Stream

  The response will be a Server-Sent Events (SSE) stream with content-type "text/event-stream".
  Each event follows this format:
  ```
  data: {"role": "assistant", "content": "Hello"}

  data: {"role": "assistant", "content": " world"}

  ```

  To process the stream:
  1. Read lines from the response body
  2. Look for lines starting with "data: "
  3. Parse the JSON following "data: "
  4. Accumulate or process each message chunk

  ## Examples

      # Call an agent with streaming
      agent = %{
        "id" => "agent-uuid-123",
        "type" => "agent",
        "user_prompt" => "Tell me a story"
      }
      {:ok, response} = RelyantApi.Agents.call_agent_stream(agent, user_id: "user123", email: "test@example.com")

      # Process the stream (example using HTTPoison async)
      # The actual stream processing depends on your HTTP client
      # With HTTPoison.get(..., stream_to: self()), you'd receive chunks like:
      # %HTTPoison.AsyncChunk{chunk: "data: {\\"role\\": \\"assistant\\", \\"content\\": \\"Hello\\"}\n\n"}

      # Example stream processing pseudocode:
      # response.body
      # |> String.split("\n\n")
      # |> Enum.filter(&String.starts_with?(&1, "data: "))
      # |> Enum.map(fn "data: " <> json -> Jason.decode!(json) end)

      # Call with context
      context = [
        %{"role" => "user", "content" => "Hello"},
        %{"role" => "assistant", "content" => "Hi there!"}
      ]
      {:ok, response} = RelyantApi.Agents.call_agent_stream(agent,
        user_id: "user123",
        email: "test@example.com",
        context: context,
        flow_id: "flow-uuid-456"
      )
  """
  def call_agent_stream(agent, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)
    flow_id = Keyword.get(opts, :flow_id)
    context = Keyword.get(opts, :context)

    # Get and validate access token
    with token when is_binary(token) <- RelyantApi.Requests.get_relyant_access_token() do

      url = RelyantApi.Requests.base_api_url() <> "/api/v1/flows/agent-call/stream"
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json;charset=UTF-8"},
        # {"Accept", "text/event-stream"},
        {"X-User-ID", user_id},
        {"X-User-Email", email}
      ]

      # Build request body
      data = %{
        "agent" => agent
      }
      |> add_optional_field("flow_id", flow_id)
      |> add_optional_field("context", context)

      case RelyantApi.Requests.execute_api_request(url, :post, headers, data, true) do
        {:ok, response} ->
          {:ok, response}

        other ->
          {:error, other}
      end
    else
      nil ->
        {:error, {:missing_credentials, "RELYANT_API_CLIENT_ID or RELYANT_API_CLIENT_SECRET environment variables are not set"}}

      other ->
        {:error, {:authentication_failed, other}}
    end
  end

  @doc """
  Retrieves messages for a given agent or flow.

  ## Parameters
  - agent_id: The ID of the agent to retrieve messages for (required).
  - opts: Keyword list with the following optional options:
    - user_id: The user ID making the request (optional, for authentication).
    - email: The email of the user making the request (optional, for authentication).
    - flow_id: The flow ID to filter messages by (optional).
    - skip: Number of messages to skip (optional, defaults to 0).
    - limit: Maximum number of messages to retrieve (optional, defaults to 1000).

  ## Returns
  - `{:ok, %{"total" => total, "items" => messages}}` on success with message list
  - `{:error, reason}` on failure

  ## Examples

      # Get messages for a specific agent
      RelyantApi.Agents.get_messages("agent-uuid-123", user_id: "user123", email: "test@example.com")

      # Get messages for an agent in a specific flow
      RelyantApi.Agents.get_messages("agent-uuid-123",
        user_id: "user123",
        email: "test@example.com",
        flow_id: "flow-uuid-456"
      )

      # Get messages with pagination
      RelyantApi.Agents.get_messages("agent-uuid-123",
        user_id: "user123",
        skip: 10,
        limit: 50
      )
  """
  def get_messages(agent_id, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)
    flow_id = Keyword.get(opts, :flow_id)
    skip = Keyword.get(opts, :skip, 0)
    limit = Keyword.get(opts, :limit, 1000)

    # Get and validate access token
    with token when is_binary(token) <- RelyantApi.Requests.get_relyant_access_token() do

      # Build filters JSON
      filters = %{"agent_id" => agent_id}
      |> add_optional_field("flow_id", flow_id)
      |> Jason.encode!()

      # Build query parameters
      query_params = URI.encode_query(%{
        "skip" => skip,
        "limit" => limit,
        "filters" => filters
      })

      url = RelyantApi.Requests.base_api_url() <> "/api/v1/flows/messages?" <> query_params
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"},
        {"X-User-ID", user_id},
        {"X-User-Email", email}
      ]

      case RelyantApi.Requests.execute_api_request(url, :get, headers) do
        {:ok, response} ->
          {:ok, response}

        other ->
          {:error, other}
      end
    else
      nil ->
        {:error, {:missing_credentials, "RELYANT_API_CLIENT_ID or RELYANT_API_CLIENT_SECRET environment variables are not set"}}

      other ->
        {:error, {:authentication_failed, other}}
    end
  end


  @doc """
  Retrieves available tools for the client.

  ## Parameters
  - opts: Keyword list with the following optional options:
    - user_id: The user ID making the request (optional, for authentication).
    - email: The email of the user making the request (optional, for authentication).

  ## Returns
  - `{:ok, tools}` on success with the list of tools
  - `{:error, reason}` on failure
  """
  def get_tools(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)

    with token when is_binary(token) <- RelyantApi.Requests.get_relyant_access_token() do

      url = RelyantApi.Requests.base_api_url() <> "/api/v1/clients/tools"
      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"},
        {"X-User-ID", user_id},
        {"X-User-Email", email}
      ]

      case RelyantApi.Requests.execute_api_request(url, :get, headers) do
        {:ok, response} ->
          {:ok, response}

        other ->
          {:error, other}
      end
    else
      nil ->
        {:error, {:missing_credentials, "RELYANT_API_CLIENT_ID or RELYANT_API_CLIENT_SECRET environment variables are not set"}}

      other ->
        {:error, {:authentication_failed, other}}
    end
  end

  # Helper function to add optional fields to the map
  defp add_optional_field(map, _key, nil), do: map
  defp add_optional_field(map, key, value), do: Map.put(map, key, value)
end
