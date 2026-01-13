defmodule MercaEx.Algolia do
  @moduledoc """
  Algolia search client for Mercadona products.

  Mercadona uses Algolia for product search. The credentials are public
  (embedded in their web frontend JavaScript) and read-only.

  ## Warehouses

  Different warehouse codes return different product catalogs and prices:

  - `mad1` - Madrid (default, most complete)
  - `mad2` - Madrid (alternative)
  - `bcn1` - Barcelona
  - `vlc1` - Valencia
  - `vlc2` - Valencia (limited catalog)
  - `svq1` - Sevilla
  - `alc1` - Alicante

  ## Usage

      {:ok, products} = MercaEx.Algolia.search("leche")
      {:ok, products} = MercaEx.Algolia.search("leche", warehouse: "bcn1", limit: 10)

  """

  alias MercaEx.Product

  @app_id "7UZJKL1DJ0"
  @api_key "9d8f2e39e90df472b4f2e559a116fe17"
  @default_warehouse "mad1"
  @default_hits_per_page 20

  @warehouses ~w(mad1 mad2 bcn1 vlc1 vlc2 svq1 alc1)

  @doc """
  Returns a list of known warehouse codes.
  """
  @spec available_warehouses() :: [String.t()]
  def available_warehouses, do: @warehouses

  @doc """
  Searches for products using Algolia.

  ## Options

    - `:warehouse` - Warehouse code (default: "mad1")
    - `:limit` - Maximum results to return (default: 20)

  ## Examples

      iex> MercaEx.Algolia.search("leche")
      {:ok, [%MercaEx.Product{...}, ...]}

      iex> MercaEx.Algolia.search("cerveza", warehouse: "bcn1", limit: 5)
      {:ok, [%MercaEx.Product{...}, ...]}

  """
  @spec search(String.t(), keyword()) :: {:ok, [Product.t()]} | {:error, term()}
  def search(query, opts \\ []) do
    warehouse = Keyword.get(opts, :warehouse, @default_warehouse)
    limit = Keyword.get(opts, :limit, @default_hits_per_page)

    url = build_url(warehouse)
    body = build_body(query, limit)

    case http_client().post(url, body, []) do
      {:ok, %{status: 200, body: %{"hits" => hits}}} ->
        products = Enum.map(hits, &parse_hit/1)
        {:ok, products}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, _} = error ->
        error
    end
  end

  defp build_url(warehouse) do
    index = "products_prod_#{warehouse}_es"

    "https://#{@app_id}-dsn.algolia.net/1/indexes/#{index}/query" <>
      "?x-algolia-application-id=#{@app_id}" <>
      "&x-algolia-api-key=#{@api_key}"
  end

  defp build_body(query, limit) do
    params = URI.encode_query(query: query, hitsPerPage: limit)
    Jason.encode!(%{params: params})
  end

  defp parse_hit(hit) do
    price_instructions = hit["price_instructions"] || %{}

    %Product{
      id: to_string(hit["id"]),
      name: hit["display_name"],
      price: price_instructions["unit_price"],
      reference_price: price_instructions["reference_price"],
      reference_format: price_instructions["reference_format"],
      ean: hit["ean"],
      photo_url: hit["thumbnail"],
      description: nil
    }
  end

  defp http_client do
    Application.get_env(:merca_ex, :http_client, MercaEx.HTTPClient.Req)
  end
end
