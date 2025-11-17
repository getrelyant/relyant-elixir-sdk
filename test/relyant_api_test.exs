defmodule RelyantApiTest do
  use ExUnit.Case
  # import Mock
  doctest RelyantApi

  @user_id "test_user_id"
  @email "test_elixir_integration@example.com"
  @base64_document "dGVzdCBkb2N1bWVudA=="
  @mime_type "application/pdf"
  @file_name "test.pdf"
  @document_ids ["doc1", "doc2"]

  test "greets from Relyant API" do
    assert RelyantApi.hello() == "Welcome to RelyantApi SDK!"
  end

  test "get_relyant_access_token returns access token" do
    assert RelyantApi.Requests.get_relyant_access_token() != nil
  end

  test "create_relyant_client_user/2 creates a user" do
    # with_mock RelyantApi, [execute_api_request: fn _, _, _, _ -> {:ok, %{"users" => [%{"id" => "user1"}]}} end] do
    assert Map.take(RelyantApi.create_relyant_company_user(@user_id, @email), ["company_user_id"]) == %{"company_user_id" => @user_id}
    # end
  end

  test "get_relyant_client_user/1 retrieves a user" do
    assert Map.take(RelyantApi.get_relyant_company_user(@user_id), ["company_user_id", "email", "first_name"]) == %{"company_user_id" => @user_id, "email" => @email, "first_name" => nil}
  end

  test "upload_document/4 uploads a document" do
    response = RelyantApi.Documents.upload_document(@user_id, @base64_document, @mime_type, @file_name)

    # assert that the response is a non empty list
    assert is_list(response)
    assert length(response) > 0
    response = List.first(response)

    # Assert that the response contains the expected keys and values
    assert Map.has_key?(response, "url")
    assert Map.has_key?(response, "filename")
    assert Map.has_key?(response, "s3_key")
    assert response["filename"] == @file_name
    assert response["content_type"] == @mime_type
    assert response["size"] == 13
  end

  # test "parse_cvs/2 parses CVs" do
  #   assert RelyantApi.parse_cvs(@user_id, @document_ids) == %{"parsed" => true}
  # end
end
