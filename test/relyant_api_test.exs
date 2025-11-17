defmodule RelyantApiTest do
  use ExUnit.Case
  # import Mock
  doctest RelyantApi

  @user_id "test_user_id"
  @email "test_elixir_integration@example.com"

  test "greets from Relyant API" do
    assert RelyantApi.hello() == "Welcome to RelyantApi SDK!"
  end

  test "get_relyant_access_token returns access token" do
    assert RelyantApi.Requests.get_relyant_access_token() != nil
  end

  test "create_relyant_client_user/2 creates a user" do
    # with_mock RelyantApi, [execute_api_request: fn _, _, _, _ -> {:ok, %{"users" => [%{"id" => "user1"}]}} end] do
    assert Map.take(RelyantApi.create_relyant_client_user(@user_id, @email), ["client_user_id"]) == %{"client_user_id" => @user_id}
    # end
  end

  test "get_relyant_client_user/1 retrieves a user" do
    assert Map.take(RelyantApi.get_relyant_client_user(@user_id), ["client_user_id", "email", "first_name"]) == %{"client_user_id" => @user_id, "email" => @email, "first_name" => nil}
  end
end
