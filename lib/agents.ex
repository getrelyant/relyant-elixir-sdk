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
          "api_call" => tool["api_call"]
        }
      end)

      # Build request body with required and optional fields
      entity = %{
        "name" => name,
        "agent_type" => "custom",
        "description" => description,
        "model" => model,
        "tools" => formatted_tools,
      }
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
            "api_call" => tool["api_call"]
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

  # Helper function to add optional fields to the map
  defp add_optional_field(map, _key, nil), do: map
  defp add_optional_field(map, key, value), do: Map.put(map, key, value)
end
