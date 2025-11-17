defmodule RelyantApi.QueryTest do
  use ExUnit.Case
  doctest RelyantApi.Query

  # Make sure this user ID exists in your Relyant setup for testing
  @user_id "test_user_id_elixir_emails"
  @email "test_elixir_integration@example.com"
  @base64_document "dGVzdCBkb2N1bWVudA=="
  @mime_type "text/plain"
  @file_name "test_elixir_integration.txt"

  # test "llm_query/2 returns a response for a simple query without documents" do
  #   query = "What is the result of 2 + 2? Answer with just the number."
  #   response = RelyantApi.Query.llm_query(query, user_id: @user_id, email: @email)

  #   # Assert that the response is not nil
  #   assert response != nil

  #   # Assert that the response contains expected keys
  #   assert Map.has_key?(response, "id") || Map.has_key?(response, "result")
  # end

  # test "llm_query/3 returns a response for a query with empty documents list" do
  #   query = "What is the capital of France?"
  #   response = RelyantApi.Query.llm_query(query, user_id: @user_id, documents: [])

  #   # Assert that the response is not nil
  #   assert response != nil
  # end

  test "llm_query/3 returns a response for a query with documents" do
    # First, upload a document to get valid document data
    uploaded_docs = RelyantApi.Documents.upload_document(@user_id, @base64_document, @mime_type, @file_name)
    assert is_list(uploaded_docs)
    assert length(uploaded_docs) > 0

    document = List.first(uploaded_docs)
    documents = [
      %{
        "id" => document["id"],
        "uuid" => document["uuid"],
        "s3_key" => document["s3_key"],
        "filename" => document["filename"],
        "content_type" => document["content_type"]
      }
    ]
    IO.inspect(documents, label: "Documents for LLM Query")

    query = "Please summarize the document"
    response = RelyantApi.Query.llm_query(query, user_id: @user_id, documents: documents)

    # Assert that the response is not nil
    assert response != nil

    IO.inspect(response, label: "LLM Query Response")

    # Assert that the response contains query_id
    assert Map.has_key?(response, "query_id") || Map.has_key?(response, "answer")
  end

  # test "llm_query/3 handles document with URL" do
  #   documents = [
  #     %{
  #       "url" => "https://www.example.com"
  #     }
  #   ]

  #   query = "What is this about?"
  #   response = RelyantApi.Query.llm_query(query, user_id: @user_id, documents: documents)

  #   # Assert that the response is not nil (API should handle URL fetching)
  #   assert response != nil
  # end

  # test "llm_query/3 handles multiple documents" do
  #   # Upload two documents
  #   doc1 = RelyantApi.Documents.upload_document(@user_id, @base64_document, @mime_type, "doc1.pdf")
  #   doc2 = RelyantApi.Documents.upload_document(@user_id, @base64_document, @mime_type, "doc2.pdf")

  #   assert is_list(doc1) && length(doc1) > 0
  #   assert is_list(doc2) && length(doc2) > 0

  #   documents = [
  #     %{
  #       "id" => List.first(doc1)["id"],
  #       "uuid" => List.first(doc1)["uuid"],
  #       "s3_key" => List.first(doc1)["s3_key"],
  #       "filename" => List.first(doc1)["filename"]
  #     },
  #     %{
  #       "id" => List.first(doc2)["id"],
  #       "uuid" => List.first(doc2)["uuid"],
  #       "s3_key" => List.first(doc2)["s3_key"],
  #       "filename" => List.first(doc2)["filename"]
  #     }
  #   ]

  #   query = "Compare these documents"
  #   response = RelyantApi.Query.llm_query(query, user_id: @user_id, documents: documents)

  #   # Assert that the response is not nil
  #   assert response != nil
  #   assert Map.has_key?(response, "id") || Map.has_key?(response, "result")
  # end
end
