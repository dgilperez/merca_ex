defmodule MercaEx do
  @moduledoc """
  Elixir client for the Mercadona API.

  MercaEx provides a simple interface to interact with Mercadona's
  product catalog, including browsing categories, fetching products,
  and searching.

  ## Usage

      # List all categories
      {:ok, categories} = MercaEx.categories()

      # Get products in a category
      {:ok, products} = MercaEx.products(category_id)

      # Get a specific product
      {:ok, product} = MercaEx.product("1234")

      # Search for products
      {:ok, results} = MercaEx.search("leche")

  ## Configuration

  The HTTP client can be configured for testing:

      config :merca_ex, :http_client, MercaEx.HTTPClientMock

  """

  alias MercaEx.{Algolia, Category, Client, Product}

  @doc """
  Fetches all product categories.

  Returns a list of top-level categories, each containing
  their subcategories.

  ## Examples

      iex> {:ok, categories} = MercaEx.categories()
      iex> hd(categories).name
      "Aceite, especias y salsas"

  """
  @spec categories() :: {:ok, [Category.t()]} | {:error, term()}
  def categories do
    case Client.get("/categories/") do
      {:ok, %{"results" => results}} ->
        categories = Enum.map(results, &Category.from_api/1)
        {:ok, categories}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Fetches products for a specific category.

  ## Parameters

    - `category_id` - The category ID (integer or string)

  ## Examples

      iex> {:ok, products} = MercaEx.products(113)
      iex> hd(products).name
      "Aceite de oliva virgen extra"

  """
  @spec products(integer() | String.t()) :: {:ok, [Product.t()]} | {:error, term()}
  def products(category_id) do
    path = "/categories/#{category_id}/"

    case Client.get(path) do
      {:ok, %{"categories" => categories}} ->
        products =
          categories
          |> Enum.flat_map(fn cat -> cat["products"] || [] end)
          |> Enum.map(&Product.from_api/1)

        {:ok, products}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Fetches a single product by ID.

  ## Parameters

    - `product_id` - The product ID (string)

  ## Examples

      iex> {:ok, product} = MercaEx.product("1234")
      iex> product.name
      "Aceite de oliva virgen extra"

  """
  @spec product(String.t()) :: {:ok, Product.t()} | {:error, term()}
  def product(product_id) do
    path = "/products/#{product_id}/"

    case Client.get(path) do
      {:ok, data} ->
        {:ok, Product.from_api(data)}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Searches for products by query using Algolia.

  ## Parameters

    - `query` - Search term
    - `opts` - Optional parameters:
      - `:warehouse` - Warehouse code (default: "mad1"). See `MercaEx.Algolia.available_warehouses/0`
      - `:limit` - Maximum results to return (default: 20)

  ## Examples

      iex> {:ok, products} = MercaEx.search("leche")
      iex> length(products) > 0
      true

      iex> {:ok, products} = MercaEx.search("leche", warehouse: "bcn1", limit: 5)

  """
  @spec search(String.t(), keyword()) :: {:ok, [Product.t()]} | {:error, term()}
  def search(query, opts \\ []) do
    Algolia.search(query, opts)
  end
end
