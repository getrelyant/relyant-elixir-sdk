defmodule RelyantApi.Requests do
  @base_api_url "http://localhost:8000"

  @doc """
  Returns the base API URL.
  """
  def base_api_url do
    System.get_env("RELYANT_BASE_API_URL") || @base_api_url
  end

  defp client_id do
    System.get_env("RELYANT_API_CLIENT_ID")
  end

  defp client_secret do
    System.get_env("RELYANT_API_CLIENT_SECRET")
  end

  @doc """
  Executes an API request.

  ## Parameters
  - url: The API endpoint URL.
  - method: The HTTP method (:get, :post, :put).
  - headers: Optional headers for the request.
  - data: Optional data for POST/PUT requests.
  - streaming: If true, returns raw body without JSON decoding (for SSE streams). Defaults to false.
  - opts: Optional keyword list with timeout settings:
    - recv_timeout: Timeout for receiving response (default: 5 minutes for AI operations)
    - timeout: Timeout for connection (default: 30 seconds)

  ## Returns
  - {:ok, response} on success (decoded JSON if streaming=false, raw body if streaming=true)
  - {:error, reason} on failure
  """
  def execute_api_request(url, method, headers \\ [], data \\ %{}, streaming \\ false, opts \\ []) do
    headers = [{"Content-Type", "application/json"} | headers]

    options =
      case method do
        :get -> []
        # returns a keywords list as optional argument for the request
        :post -> Jason.encode!(data)
        :put -> Jason.encode!(data)
        :delete -> Jason.encode!(data)
      end

    # Default timeouts suitable for AI/LLM operations with document processing
    # recv_timeout: 5 minutes (300 seconds) - time to receive data from AI processing
    # timeout: 30 seconds - time to establish connection
    recv_timeout = Keyword.get(opts, :recv_timeout, 300_000)
    timeout = Keyword.get(opts, :timeout, 30_000)

    case HTTPoison.request(method, url, options, headers, [recv_timeout: recv_timeout, timeout: timeout]) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        if streaming do
          {:ok, body}
        else
          {:ok, Jason.decode!(body)}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        if streaming do
          {:error, {code, body}}
        else
          {:error, {code, Jason.decode!(body)}}
        end

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
    response = execute_api_request(url, :post, headers, data)
    case response do
      {:ok, %{"access_token" => token}} -> token
      _ -> response
    end
  end
end
