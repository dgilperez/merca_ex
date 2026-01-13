defmodule MercaEx.HTTPClient.Req do
  @moduledoc """
  HTTP client implementation using Req.
  """

  @behaviour MercaEx.HTTPClient

  @impl true
  def get(url, opts \\ []) do
    opts
    |> Keyword.put(:url, url)
    |> Keyword.put_new(:receive_timeout, 30_000)
    |> Req.new()
    |> Req.get()
    |> handle_response()
  end

  @impl true
  def post(url, body, opts \\ []) do
    opts
    |> Keyword.put(:url, url)
    |> Keyword.put(:body, body)
    |> Keyword.put_new(:receive_timeout, 30_000)
    |> Keyword.put_new(:headers, [{"content-type", "application/json"}])
    |> Req.new()
    |> Req.post()
    |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}}) do
    {:ok, %{status: status, body: body}}
  end

  defp handle_response({:error, exception}) do
    {:error, %{reason: exception}}
  end
end
