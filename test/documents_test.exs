defmodule RelyantApi.DocumentsTest do
  use ExUnit.Case
  doctest RelyantApi.Documents

  @user_id "test_user_id"
  @base64_document "dGVzdCBkb2N1bWVudA=="
  @mime_type "application/pdf"
  @file_name "test.pdf"

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
end
