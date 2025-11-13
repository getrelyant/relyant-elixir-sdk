defmodule RelyantApi.Query do
  @moduledoc """
  A module for handling LLM query operations in the Relyant API.
  """
  import RelyantApi.Requests

  @doc """
  Queries documents using LLM.

  ## Parameters
  - user_id: The user ID making the query.
  - query: The question or query text.
  - documents: Optional list of document maps. Each document can contain:
    - id: Document ID
    - uuid: Document UUID
    - s3_key: S3 storage key
    - filename: Document filename
    - url: Document URL (content will be fetched from URL)
    - content: Direct document content

  ## Returns
  - The query response on success
  - nil on failure

  ## Examples

      # Query without documents (general knowledge)
      RelyantApi.Query.llm_query("user123", "What is the capital of France?")

      # Query with documents
      documents = [
        %{
          "id" => "doc1",
          "uuid" => "abc-123",
          "s3_key" => "documents/file.pdf",
          "filename" => "file.pdf"
        }
      ]
      RelyantApi.Query.llm_query("user123", "Summarize this document", documents)

      # Query with document URLs
      documents = [%{"url" => "https://example.com/document.pdf"}]
      RelyantApi.Query.llm_query("user123", "What is this document about?", documents)
  """
  def llm_query(user_id \\ nil, query, documents \\ []) do
    access_token = RelyantApi.Requests.get_relyant_access_token()

    url = RelyantApi.Requests.base_api_url() <> "/api/v1/query"
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"},
      {"X-User-ID", user_id}
    ]
    data = %{
      "documents" => documents,
      "query" => query
    }

    case RelyantApi.Requests.execute_api_request(url, :post, headers, data) do
      {:ok, response} -> response
      _ -> nil
    end
  end
end
