defmodule RelyantApi.Documents do
  @moduledoc """
  A module for handling document-related operations in the Relyant API.
  """
  import RelyantApi.Requests

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
        "mimetype" => mime_type,
        "filename" => file_name
      }],
      "extract_elements" => false
    }

    case RelyantApi.Requests.execute_api_request(url, :post, headers, data) do
      {:ok, response} -> response
      _ -> nil
    end
  end

  @doc """
  Parses CVs using Relyant.
  """
  def parse_cvs(user_id, document_ids) do
    access_token = RelyantApi.Requests.get_relyant_access_token(@client_id, @client_secret)
    url = @base_api_url <> "/api/v1/cv-parser"
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"},
      {"X-User-ID", user_id}
    ]
    data = %{"document_ids" => document_ids}

    case RelyantApi.Requests.execute_api_request(url, :post, headers, data) do
      {:ok, response} -> response
      _ -> nil
    end
  end

end
