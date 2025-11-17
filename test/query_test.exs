defmodule RelyantApi.QueryTest do
  use ExUnit.Case
  doctest RelyantApi.Query

  # Make sure this user ID exists in your Relyant setup for testing
  @user_id "test_user_id_elixir_query"
  @email "test_elixir_integration_query@example.com"
  @base64_document "JVBERi0xLjQKJZOMi54gUmVwb3J0TGFiIEdlbmVyYXRlZCBQREYgZG9jdW1lbnQxCjEgMCBvYmoKPDwgL1R5cGUgL0NhdGFsb2cgL1BhZ2VzIDIgMCBSID4+CmVuZG9iagoKMiAwIG9iago8PCAvVHlwZSAvUGFnZXMgL0tpZHMgWyAzIDAgUiBdIC9Db3VudCAxID4+CmVuZG9iagoKMyAwIG9iago8PCAvVHlwZSAvUGFnZSAvUGFyZW50IDIgMCBSIC9NZWRpYUJveCBbIDAgMCA2MTIgNzkyIF0gL0NvbnRlbnRzIDQgMCBSID4+CmVuZG9iagoKNCAwIG9iago8PCAvTGVuZ3RoIDUgMCBSID4+CnN0cmVhbQpCVAovRm9udCA8PCAvRjAgNiAwIFIgPj4KL0ZGMCA3IDAgUgovRVQgOAowIDAgMAovVGYgCjEgMCBSQ2wKL0VUKCBBdXRob3I6IE9wZW5BSVxOJykKL0VUKCBEYXRlOiAyMDI1MTEyNjA5MzA1M1opCj4+CmVuZHN0cmVhbQplbmRvYmoKCjUgMCBvYmoKMjM4CmVuZG9iagoKNiAwIG9iago8PCAvVHlwZSAvRm9udCAvU3VidHlwZSAvVHlwZTEgL0Jhc2VGb250IC9IZWx2ZXRpY2EgPj4KZW5kb2JqCgo3IDAgb2JqCjw8IC9UeXBlIC9Gb250RGVzY3JpcHRvciAvRm9udE5hbWUgL0YwIC9GbGFncyA0IC9Gb250QkJveCBbIDAgLTIwMCA2MTIgMTAwMCBdIC9JdGFsaWNBbmdsZSAwIC9Bc2NlbnQgODk4IC9DYXBIZWlnaHQgMTAwMCA+PgplbmRvYmoKCjggMCBvYmoKPDwgL1R5cGUgL1hPYmplY3QgL1N1YnR5cGUgL0ltYWdlIC9XaWR0aCAxIC9IZWlnaHQgMSAvQ29sb3JTcGFjZSAvRGV2aWNlUkdCIC9CaXRzUGVyQ29tcG9uZW50IDggL0xlbmd0aCA5IDAgUiA+PgpzdHJlYW0KAAplbmRzdHJlYW0KZW5kb2JqCgo5IDAgb2JqCjEyCmVuZG9iagoKeHJlZgowIDExCjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDA5MCAwMDAwMCBuIAowMDAwMDAwMDg3IDAwMDAwIG4gCjAwMDAwMDAxNzAgMDAwMDAgbiAKMDAwMDAwMDI1NyAwMDAwMCBuIAowMDAwMDAwMzcxIDAwMDAwIG4gCjAwMDAwMDA0NTQgMDAwMDAgbiAKMDAwMDAwMDU1NSAwMDAwMCBuIAowMDAwMDAwNjU2IDAwMDAwIG4gCjAwMDAwMDA3NzUgMDAwMDAgbiAKMDAwMDAwMDg4NCAwMDAwMCBuIAp0cmFpbGVyCjw8IC9TaXplIDExIC9Sb290IDEgMCBSID4+CnN0YXJ0eHJlZgowODk3CiUlRU9GCg=="
  @mime_type "application/pdf"
  @file_name "test_elixir_integration.pdf"

  test "llm_query/2 returns a response for a simple query without documents" do
    query = "What is the result of 2 + 2? Answer with just the number."
    response = RelyantApi.Query.llm_query(query, user_id: @user_id, email: @email)

    # Assert that the response is not nil
    assert response != nil

    # Assert that the response contains expected keys
    assert Map.has_key?(response, "id") || Map.has_key?(response, "result")
  end

  test "llm_query/3 returns a response for a query with empty documents list" do
    query = "What is the capital of France?"
    response = RelyantApi.Query.llm_query(query, user_id: @user_id, documents: [])
    assert response != nil
  end

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
    query = "Please summarize the document"
    response = RelyantApi.Query.llm_query(query, user_id: @user_id, documents: documents)

    # Assert that the response is not nil
    assert response != nil
    assert response["id"] != nil
    assert response["result"] != nil
    assert response["query"] == query
  end
end
