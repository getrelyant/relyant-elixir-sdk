defmodule RelyantApi do
  @moduledoc """
  Relyant API Integration
  This module provides functions to execute API requests to the Relyant API.
  It supports GET, POST, and PUT methods and handles JSON responses.
  """

  @base_api_url "http://localhost:8000"
  @client_id System.get_env("COMPANY_A_API_CLIENT_ID")
  @client_secret System.get_env("COMPANY_A_API_CLIENT_SECRET")








#   @doc """
#   Parses CVs using Relyant.
#   """
#   def parse_cvs(user_id, document_ids) do
#     access_token = get_relyant_access_token(@client_id, @client_secret)
#     url = @base_api_url <> "/api/v1/cv-parser"
#     headers = [
#       {"Authorization", "Bearer #{access_token}"},
#       {"Content-Type", "application/json"},
#       {"X-User-ID", user_id}
#     ]
#     data = %{"document_ids" => document_ids}

#     case execute_api_request(url, :post, headers, data) do
#       {:ok, response} -> response
#       _ -> nil
#     end
#   end
end