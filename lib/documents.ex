defmodule RelyantApi.Documents do

  @doc """
  Uploads a document to Relyant.
  """
  def upload_document(user_id, base64_document, mime_type, file_name) do
    access_token = RelyantApi.Requests.get_relyant_access_token()

    url = RelyantApi.Requests.base_api_url() <> "/api/v1/documents"
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"},
      {"X-User-ID", user_id}
    ]
    data = %{
      "documents" => [%{
        "base64_document" => base64_document,
        "content_type" => mime_type,
        "filename" => file_name
      }]
    }

    case RelyantApi.Requests.execute_api_request(url, :post, headers, data) do
      {:ok, response} -> response
      _ -> nil
    end
  end

end
