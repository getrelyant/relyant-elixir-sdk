defmodule RelyantApi.Requests do
  @base_api_url "http://localhost:8000"
  # @base_api_url "https://dev.api.relyant.ai"

  @doc """
  Returns the base API URL.
  """
  def base_api_url do
    @base_api_url
  end

  defp client_id do
    System.get_env("COMPANY_A_API_CLIENT_ID")
  end

  defp client_secret do
    System.get_env("COMPANY_A_API_CLIENT_SECRET")
  end

  @doc """
  Executes an API request.

  ## Parameters
  - url: The API endpoint URL.
  - method: The HTTP method (:get, :post, :put).
  - headers: Optional headers for the request.
  - data: Optional data for POST/PUT requests.

  ## Returns
  - {:ok, response} on success
  - {:error, reason} on failure
  """
  def execute_api_request(url, method, headers \\ [], data \\ %{}) do
    headers = [{"Content-Type", "application/json"} | headers]

    options =
      case method do
        :get -> []
        # returns a keywords list as optional argument for the request
        :post -> Jason.encode!(data)
        :put -> Jason.encode!(data)
      end

    case HTTPoison.request(method, url, options, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, {code, Jason.decode!(body)}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Retrieves an access token from Relyant.
  """
  def get_relyant_access_token(client_id_param \\ nil, client_secret_param \\ nil) do
    url = "https://relyant.us.auth0.com/oauth/token"
    headers = [{"Content-Type", "application/json"}]
    data = %{
      "grant_type" => "client_credentials",
      "audience" => "https://relyant.ai/api/v1",
      "client_id" => client_id_param || client_id(),
      "client_secret" => client_secret_param || client_secret()
    }
    case execute_api_request(url, :post, headers, data) do
      {:ok, %{"access_token" => token}} -> token
      _ -> nil
    end
  end
end
