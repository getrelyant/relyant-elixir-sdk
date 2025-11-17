defmodule RelyantApi.Query do

  @doc """
  Queries documents using LLM.

  ## Parameters
  - query: The question or query text (required).
  - opts: Keyword list with the following options:
    - user_id: The user ID making the query (optional).
    - email: The email of the user making the query (optional).
    - documents: List of document maps (optional, defaults to []). Each document can contain:
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
      RelyantApi.Query.llm_query("What is the capital of France?", user_id: "user123")

      # Query with documents
      documents = [
        %{
          "id" => "doc1",
          "uuid" => "abc-123",
          "s3_key" => "documents/file.pdf",
          "filename" => "file.pdf"
        }
      ]
      RelyantApi.Query.llm_query("Summarize this document", user_id: "user123", documents: documents)

      # Query with document URLs
      documents = [%{"url" => "https://example.com/document.pdf"}]
      RelyantApi.Query.llm_query("What is this document about?", user_id: "user123", email: "test@example.com", documents: documents)
  """
  def llm_query(query, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    email = Keyword.get(opts, :email)
    documents = Keyword.get(opts, :documents, [])

    access_token = RelyantApi.Requests.get_relyant_access_token()

    url = RelyantApi.Requests.base_api_url() <> "/api/v1/query"
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"},
      {"X-User-ID", user_id},
      {"X-User-Email", email}
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
