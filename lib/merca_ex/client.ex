defmodule MercaEx.Client do
  @moduledoc """
  Low-level HTTP client for the Mercadona API.

  Handles URL construction, request execution, and error handling.
  """

  @base_url "https://tienda.mercadona.es/api"

  @doc """
  Makes a GET request to the Mercadona API.

  ## Examples

      iex> MercaEx.Client.get("/categories/")
      {:ok, %{"results" => [...]}}

      iex> MercaEx.Client.get("/products/", params: %{query: "leche"})
      {:ok, %{"results" => [...]}}

  """
  @spec get(String.t(), keyword()) :: {:ok, term()} | {:error, term()}
  def get(path, opts \\ []) do
    url = @base_url <> path

    case http_client().get(url, opts) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Makes a GET request and raises on error.

  ## Examples

      iex> MercaEx.Client.get!("/categories/")
      %{"results" => [...]}

  """
  @spec get!(String.t(), keyword()) :: term()
  def get!(path, opts \\ []) do
    case get(path, opts) do
      {:ok, body} ->
        body

      {:error, reason} ->
        raise MercaEx.Error, reason: reason
    end
  end

  defp http_client do
    Application.get_env(:merca_ex, :http_client, MercaEx.HTTPClient.Req)
  end
end
