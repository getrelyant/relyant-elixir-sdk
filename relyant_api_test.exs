defmodule RelyantApiTest do
  use ExUnit.Case
  import Mock

  alias RelyantApi

  @client_id "test_client_id"
  @client_secret "test_client_secret"
  @user_id "test_user_id"
  @email "test_email@example.com"
  @base64_document "dGVzdCBkb2N1bWVudA=="
  @mime_type "application/pdf"
  @file_name "test.pdf"
  @document_ids ["doc1", "doc2"]

  test "get_relyant_access_token/2 returns access token" do
    with_mock RelyantApi, [execute_api_request: fn _, _, _, _ -> {:ok, %{"access_token" => "test_token"}} end] do
      assert RelyantApi.get_relyant_access_token(@client_id, @client_secret) == "test_token"
    end
  end

  test "create_relyant_company_user/2 creates a user" do
    with_mock RelyantApi, [execute_api_request: fn _, _, _, _ -> {:ok, %{"users" => [%{"id" => "user1"}]}} end] do
      assert RelyantApi.create_relyant_company_user(@user_id, @email) == %{"id" => "user1"}
    end
  end

  test "get_relyant_company_user/1 retrieves a user" do
    with_mock RelyantApi, [execute_api_request: fn _, _, _, _ -> {:ok, %{"user_info" => %{"id" => "user1"}}} end] do
      assert RelyantApi.get_relyant_company_user(@user_id) == %{"id" => "user1"}
    end
  end

  test "upload_document/4 uploads a document" do
    with_mock RelyantApi, [execute_api_request: fn _, _, _, _ -> {:ok, %{"status" => "success"}} end] do
      assert RelyantApi.upload_document(@user_id, @base64_document, @mime_type, @file_name) == %{"status" => "success"}
    end
  end

  test "parse_cvs/2 parses CVs" do
    with_mock RelyantApi, [execute_api_request: fn _, _, _, _ -> {:ok, %{"parsed" => true}} end] do
      assert RelyantApi.parse_cvs(@user_id, @document_ids) == %{"parsed" => true}
    end
  end
end
