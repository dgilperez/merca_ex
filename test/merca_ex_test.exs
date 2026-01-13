defmodule MercaExTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  @categories_response %{
    "results" => [
      %{
        "id" => 112,
        "name" => "Aceite, especias y salsas",
        "categories" => [
          %{"id" => 113, "name" => "Aceite de oliva"},
          %{"id" => 114, "name" => "Aceite de girasol"}
        ]
      },
      %{
        "id" => 115,
        "name" => "Lácteos y huevos",
        "categories" => [
          %{"id" => 116, "name" => "Leche"}
        ]
      }
    ]
  }

  @products_response %{
    "categories" => [
      %{
        "id" => 113,
        "name" => "Aceite de oliva",
        "products" => [
          %{
            "id" => "1234",
            "display_name" => "Aceite de oliva virgen extra",
            "price_instructions" => %{
              "unit_price" => 5.99,
              "reference_price" => 5.99,
              "reference_format" => "1 L"
            },
            "photos" => [%{"regular" => "https://example.com/photo.jpg"}],
            "ean" => "8480000123456"
          }
        ]
      }
    ]
  }

  @product_response %{
    "id" => "1234",
    "display_name" => "Aceite de oliva virgen extra",
    "price_instructions" => %{
      "unit_price" => 5.99,
      "reference_price" => 5.99,
      "reference_format" => "1 L"
    },
    "photos" => [%{"regular" => "https://example.com/photo.jpg"}],
    "ean" => "8480000123456",
    "details" => %{
      "description" => "Aceite de primera calidad"
    }
  }

  describe "categories/0" do
    test "returns list of categories" do
      expect(MercaEx.HTTPClientMock, :get, fn url, _opts ->
        assert url =~ "/categories/"
        {:ok, %{status: 200, body: @categories_response}}
      end)

      assert {:ok, categories} = MercaEx.categories()
      assert length(categories) == 2
      assert hd(categories).id == 112
      assert hd(categories).name == "Aceite, especias y salsas"
      assert length(hd(categories).subcategories) == 2
    end

    test "returns error on API failure" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, _opts ->
        {:error, %{reason: :timeout}}
      end)

      assert {:error, _} = MercaEx.categories()
    end
  end

  describe "products/1" do
    test "returns products for a category" do
      expect(MercaEx.HTTPClientMock, :get, fn url, _opts ->
        assert url =~ "/categories/113/"
        {:ok, %{status: 200, body: @products_response}}
      end)

      assert {:ok, products} = MercaEx.products(113)
      assert length(products) == 1

      product = hd(products)
      assert product.id == "1234"
      assert product.name == "Aceite de oliva virgen extra"
      assert product.price == 5.99
      assert product.ean == "8480000123456"
    end

    test "accepts category_id as string" do
      expect(MercaEx.HTTPClientMock, :get, fn url, _opts ->
        assert url =~ "/categories/113/"
        {:ok, %{status: 200, body: @products_response}}
      end)

      assert {:ok, _products} = MercaEx.products("113")
    end
  end

  describe "product/1" do
    test "returns single product details" do
      expect(MercaEx.HTTPClientMock, :get, fn url, _opts ->
        assert url =~ "/products/1234/"
        {:ok, %{status: 200, body: @product_response}}
      end)

      assert {:ok, product} = MercaEx.product("1234")
      assert product.id == "1234"
      assert product.name == "Aceite de oliva virgen extra"
      assert product.description == "Aceite de primera calidad"
    end

    test "returns error for non-existent product" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, _opts ->
        {:ok, %{status: 404, body: %{"error" => "Not found"}}}
      end)

      assert {:error, {:http_error, 404, _}} = MercaEx.product("invalid")
    end
  end

  describe "search/2" do
    test "searches products by query" do
      expect(MercaEx.HTTPClientMock, :get, fn url, opts ->
        assert url =~ "/products/"
        assert opts[:params][:query] == "leche"
        {:ok, %{status: 200, body: %{"results" => [@product_response]}}}
      end)

      assert {:ok, products} = MercaEx.search("leche")
      assert length(products) == 1
    end

    test "accepts warehouse option" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, opts ->
        assert opts[:params][:wh] == "mad1"
        {:ok, %{status: 200, body: %{"results" => []}}}
      end)

      MercaEx.search("leche", warehouse: "mad1")
    end

    test "accepts limit option" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, opts ->
        assert opts[:params][:limit] == 10
        {:ok, %{status: 200, body: %{"results" => []}}}
      end)

      MercaEx.search("leche", limit: 10)
    end

    test "returns empty list when no results" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, _opts ->
        {:ok, %{status: 200, body: %{"results" => []}}}
      end)

      assert {:ok, []} = MercaEx.search("producto_inexistente_xyz")
    end
  end
end
