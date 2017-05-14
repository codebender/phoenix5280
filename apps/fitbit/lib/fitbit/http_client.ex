defmodule Fitbit.HttpClient do
  @moduledoc """
  An HTTP client for Fitbit
  """
  use HTTPoison.Base

  @doc """
  Creates the URL for our endpoint.
  Args:
    * endpoint - part of the API we're hitting
  Returns string
  """
  def process_url(endpoint), do: "https://api.fitbit.com/" <> endpoint <> ".json"

  def process_request_body(body), do: Poison.encode! body

  def process_response_body(body), do: Poison.decode! body

  @doc """
  Set our request headers for every request.
  """
  def request_headers(token) do
    headers = Map.new

    headers
    |> Map.put("Authorization", "Bearer #{token}")
    |> Map.put("User-Agent",    "Fitbit/v1 fitbit-elixir/0.0.1")
    |> Map.put("Content-Type",  "application/x-www-form-urlencoded")
    |> Map.put("Accept-Language",  "en_US")
    |> Map.to_list
  end

  def user_request(endpoint) do
    endpoint = "1/user/-/" <> endpoint

    api_request(:get, endpoint, token())
  end

  @doc """
  Boilerplate code to make requests.
  Args:
    * method - atom HTTP method
    * endpoint - string requested API endpoint
    * token - string user token
  Returns dict
  """
  def api_request(method, endpoint, token \\ "", body \\ "") do
    headers = request_headers(token)

    case request(method, endpoint, body, headers) do
      {:ok, response} ->
        (case response.body do
          %{"errors" => errors} ->
            error = List.first(errors)
            {:error, %{error: error["errorType"], message: error["message"]}}
          _ ->
            {:ok, response.body}
        end)
      {:error, reason} ->
        {:error, %{error: "bad_request", message: reason}}
    end
  end

  @doc """
  Gets the API key from :fitbit, :client_id application env or ENV
  Returns binary
  """
  def client_id do
    Application.get_env(:web5280, :fitbit)[:fitbit_client_id] ||
      System.get_env("FITBIT_CLIENT_ID")
  end

  @doc """
  Gets the API key from :fitbit, :client_secret application env or ENV
  Returns binary
  """
  def client_secret do
    Application.get_env(:web5280, :fitbit)[:client_secret] ||
      System.get_env("FITBIT_CLIENT_SECRET")
  end

  @doc """
  Gets the API key from :fitbit, :token application env or ENV
  Returns binary
  """
  def token do
    Application.get_env(:web5280, :fitbit)[:token] ||
      System.get_env("FITBIT_TOKEN")
  end
end
