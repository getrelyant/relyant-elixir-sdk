defmodule RelyantApi.AgentsTest do
  use ExUnit.Case
  doctest RelyantApi.Agents

  # Make sure this user ID exists in your Relyant setup for testing
  @user_id "test_user_id_elixir_agents"
  @email "test_elixir_integration_agents@example.com"
  @agent_name "Test Agent Elixir"
  @agent_description "A test agent for automated testing"
  @model "gpt-4o-mini"
  @oauth2_config %{
    "token_url" => "https://example.com/oauth2/token",
    "client_id" => "test_client_id",
    "client_secret" => "test_client_secret"
  }

  @tools [
    %{
      "name" => "get_employee_data",
      "description" => "Retrieve the employee data from the company's database",
      "api_call" => %{
        "endpoint" => "https://jsonplaceholder.typicode.com/users",
        "method" => "GET",
        "params" => %{},
        "headers" => %{}
      }
    },
    %{
      "name" => "get_posts",
      "description" => "Retrieve posts from the company's database",
      "api_call" => %{
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

  setup_all do
    :ok
  end

  setup do
    # Register cleanup function to run after each test
    on_exit(fn ->
      cleanup_test_agents()
    end)

    :ok
  end

  # Helper function to cleanup all test agents after tests complete
  defp cleanup_test_agents do
    case RelyantApi.Agents.get_agents(user_id: @user_id, email: @email) do
      {:ok, %{"items" => agents}} when is_list(agents) ->
        Enum.each(agents, fn agent ->
          agent_name = agent["name"] || ""
          if String.contains?(agent_name, [@agent_name, "Test Agent", "CRUD", "Update", "Delete"]) do
            RelyantApi.Agents.delete_agent(agent["id"], user_id: @user_id, email: @email)
          end
        end)
      _ -> :ok
    end
  end

  # Helper function to parse SSE (Server-Sent Events) stream
  defp parse_sse_stream(stream_body) do
    stream_body
    |> String.split("\n\n")
    |> Enum.filter(&String.starts_with?(&1, "data: "))
    |> Enum.map(fn "data: " <> json_str ->
      String.trim(json_str)
      |> Jason.decode!()
    end)
    |> Enum.filter(fn msg -> msg != %{} end)
  end

  describe "get_tools/1" do
    test "retrieves tools for the client" do
      {:ok, response} = RelyantApi.Agents.get_tools(user_id: @user_id, email: @email)

      # Basic assertions to accept either a list or a paginated map
      assert response != nil

      case response do
        list when is_list(list) ->
          assert is_list(list)
      end
    end
  end

  describe "create_agent/6" do
    test "creates an agent with required parameters" do
      {:ok, response} = RelyantApi.Agents.create_agent(
        @agent_name,
        @agent_description,
        @model,
        @tools,
        @oauth2_config,
        user_id: @user_id,
        email: @email
      )

      # Assert that the response is not nil
      assert response != nil
      assert is_list(response)
      response = List.first(response)

      # Assert that the response contains expected keys
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "description")
      assert Map.has_key?(response, "model")
      assert Map.has_key?(response, "tools")

      # Assert values match input
      assert response["name"] == @agent_name
      assert response["description"] == @agent_description
      assert response["model"] == @model
      assert is_list(response["tools"])
      assert length(response["tools"]) == 2
    end
  end

  describe "update_agent/2" do
    test "updates agent name and description" do
      # First create an agent
      {:ok, created_agent} = RelyantApi.Agents.create_agent(
        @agent_name <> " Update Test",
        @agent_description,
        @model,
        @tools,
        @oauth2_config,
        user_id: @user_id,
        email: @email
      )
      assert is_list(created_agent)
      created_agent = List.first(created_agent)

      # Update the agent
      new_name = "Updated Agent Name"
      new_description = "Updated agent description"

      {:ok, updated_agent} = RelyantApi.Agents.update_agent(
        created_agent["id"],
        user_id: @user_id,
        email: @email,
        name: new_name,
        description: new_description
      )

      assert updated_agent != nil
      assert updated_agent["name"] == new_name
      assert updated_agent["description"] == new_description
      assert updated_agent["id"] == created_agent["id"]
    end
  end

  describe "call_agent_stream/2" do
    test "calls an agent with streaming and receives a response" do
      # First create an agent
      {:ok, created_agent} = RelyantApi.Agents.create_agent(
        @agent_name <> " Call Test",
        @agent_description,
        @model,
        @tools,
        @oauth2_config,
        user_id: @user_id,
        email: @email,
        user_prompt: "Tell me a fun fact about space"
      )
      assert is_list(created_agent)
      created_agent = List.first(created_agent)

      {:ok, response} = RelyantApi.Agents.call_agent_stream(
        created_agent,
        user_id: @user_id,
        email: @email
      )

      # Assert response exists and is a string (SSE stream)
      assert is_binary(response)
      assert response != nil

      # Parse the SSE stream
      messages = parse_sse_stream(response)

      # Assert we got messages from the stream
      assert length(messages) > 0

      # Verify message structure
      Enum.each(messages, fn msg ->
        assert Map.has_key?(msg, "role")
        assert Map.has_key?(msg, "content")
        assert msg["role"] in ["user", "assistant"]
        assert is_binary(msg["content"])
      end)

      # Accumulate all assistant content
      full_content = messages
      |> Enum.filter(fn msg -> msg["role"] == "assistant" end)
      |> Enum.map(fn msg -> msg["content"] end)
      |> Enum.join("")

      # Assert we got some content from the assistant
      assert String.length(full_content) > 0
    end
  end

  describe "get_messages/2" do
    test "retrieves messages for a given agent" do
      # First create an agent
      {:ok, created_agent} = RelyantApi.Agents.create_agent(
        @agent_name <> " Messages Test",
        @agent_description,
        @model,
        @tools,
        @oauth2_config,
        user_id: @user_id,
        email: @email
      )
      assert is_list(created_agent)
      created_agent = List.first(created_agent)
      agent_id = created_agent["id"]

      # Get messages for the agent (before calling)
      {:ok, response_before} = RelyantApi.Agents.get_messages(
        agent_id,
        user_id: @user_id,
        email: @email
      )

      # Assert response structure
      assert is_map(response_before)
      assert Map.has_key?(response_before, "total")
      assert Map.has_key?(response_before, "items")
      assert is_integer(response_before["total"])
      assert is_list(response_before["items"])
      initial_count = response_before["total"]

      created_agent = Map.put(created_agent, "user_prompt", "What is the weather like today?")

      {:ok, _call_response} = RelyantApi.Agents.call_agent_stream(
        created_agent,
        user_id: @user_id,
        email: @email
      )

      # Get messages again after calling the agent
      {:ok, response_after} = RelyantApi.Agents.get_messages(
        agent_id,
        user_id: @user_id,
        email: @email
      )

      # Assert that messages were created
      assert response_after["total"] > initial_count
      assert length(response_after["items"]) > length(response_before["items"])
    end
  end

  describe "full CRUD workflow" do
    test "creates, reads, updates, and deletes an agent" do
      # Create
      {:ok, created_agent} = RelyantApi.Agents.create_agent(
        @agent_name <> " CRUD Test",
        @agent_description,
        @model,
        @tools,
        @oauth2_config,
        user_id: @user_id,
        email: @email,
        user_prompt: "Initial prompt"
      )
      assert is_list(created_agent)
      created_agent = List.first(created_agent)

      assert created_agent["name"] == @agent_name <> " CRUD Test"
      agent_id = created_agent["id"]

      # Read
      case RelyantApi.Agents.get_agents(user_id: @user_id, email: @email) do
      {:ok, %{"items" => agents}} when is_list(agents) ->
          found_agent = Enum.find(agents, fn agent -> agent["id"] == agent_id end)
          assert found_agent != nil
          assert found_agent["name"] == @agent_name <> " CRUD Test"
      end
      # Update
      {:ok, updated_agent} = RelyantApi.Agents.update_agent(
        agent_id,
        user_id: @user_id,
        email: @email,
        name: "Updated CRUD Agent",
        user_prompt: "Updated prompt"
      )

      assert updated_agent["name"] == "Updated CRUD Agent"
      assert updated_agent["user_prompt"] == "Updated prompt"

      # Delete
      {:ok, _delete_response} = RelyantApi.Agents.delete_agent(
        agent_id,
        user_id: @user_id,
        email: @email
      )

      # Verify deletion
      case RelyantApi.Agents.get_agents(user_id: @user_id, email: @email) do
      {:ok, %{"items" => agents}} when is_list(agents) ->
        agent_ids = Enum.map(agents, fn agent -> agent["id"] end)
        refute agent_id in agent_ids
      end
    end
  end
end
