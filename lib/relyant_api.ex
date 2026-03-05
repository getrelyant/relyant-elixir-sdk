defmodule RelyantApi do

  @doc """
  Hello world.

  ## Examples

      iex> RelyantApi.hello()
      "Welcome to RelyantApi SDK!"

  """
  def hello do
    "Welcome to RelyantApi SDK!"
  end


  @doc """
  Creates a client user in Relyant.
  """
  def create_relyant_client_user(user_id, email \\ nil) do
    access_token = RelyantApi.Requests.get_relyant_access_token()
    url = RelyantApi.Requests.base_api_url() <> "/api/v1/users/client-users"
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]
    data = %{"entities" => [%{"user_id" => user_id, "email" => email}]}

    case RelyantApi.Requests.execute_api_request(url, :post, headers, data) do
      {:ok, %{"users" => [user | _]}} -> user
      _ -> nil
    end
  end

  @doc """
  Retrieves a client user from Relyant.
  """
  def get_relyant_client_user(user_id) do
    access_token = RelyantApi.Requests.get_relyant_access_token()
    url = RelyantApi.Requests.base_api_url() <> "/api/v1/users/client-users"
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"X-User-ID", user_id}
    ]

    case RelyantApi.Requests.execute_api_request(url, :get, headers) do
      {:ok, %{"user_info" => user_info}} -> user_info
      _ -> nil
    end
  end

end
