defmodule MercaEx.AlgoliaTest do
  use ExUnit.Case, async: true

  import Mox

  alias MercaEx.Algolia

  setup :verify_on_exit!

  @algolia_response %{
    "hits" => [
      %{
        "id" => "10381",
        "display_name" => "Leche semidesnatada Hacendado",
        "brand" => "Hacendado",
        "thumbnail" => "https://prod-mercadona.imgix.net/images/leche.jpg",
        "price_instructions" => %{
          "unit_price" => 5.28,
          "reference_price" => 0.88,
          "reference_format" => "L",
          "is_pack" => true,
          "pack_size" => 1.0,
          "unit_size" => 6.0
        }
      },
      %{
        "id" => "10379",
        "display_name" => "Leche entera Hacendado",
        "brand" => "Hacendado",
        "thumbnail" => "https://prod-mercadona.imgix.net/images/leche2.jpg",
        "price_instructions" => %{
          "unit_price" => 5.28,
          "reference_price" => 0.88,
          "reference_format" => "L"
        }
      }
    ],
    "nbHits" => 45,
    "page" => 0,
    "nbPages" => 1,
    "hitsPerPage" => 20
  }

  describe "search/2" do
    test "searches products with default warehouse" do
      expect(MercaEx.HTTPClientMock, :post, fn url, body, _opts ->
        assert url =~ "algolia.net"
        assert url =~ "products_prod_mad1_es"
        assert url =~ "x-algolia-application-id=7UZJKL1DJ0"
        assert body =~ "query=leche"
        {:ok, %{status: 200, body: @algolia_response}}
      end)

      assert {:ok, results} = Algolia.search("leche")
      assert length(results) == 2
      assert hd(results).id == "10381"
      assert hd(results).name == "Leche semidesnatada Hacendado"
    end

    test "searches with custom warehouse" do
      expect(MercaEx.HTTPClientMock, :post, fn url, _body, _opts ->
        assert url =~ "products_prod_bcn1_es"
        {:ok, %{status: 200, body: @algolia_response}}
      end)

      assert {:ok, _} = Algolia.search("leche", warehouse: "bcn1")
    end

    test "respects limit option (hitsPerPage)" do
      expect(MercaEx.HTTPClientMock, :post, fn _url, body, _opts ->
        assert body =~ "hitsPerPage=5"
        {:ok, %{status: 200, body: @algolia_response}}
      end)

      Algolia.search("leche", limit: 5)
    end

    test "returns empty list when no hits" do
      expect(MercaEx.HTTPClientMock, :post, fn _url, _body, _opts ->
        {:ok, %{status: 200, body: %{"hits" => [], "nbHits" => 0}}}
      end)

      assert {:ok, []} = Algolia.search("producto_inexistente_xyz")
    end

    test "returns error on HTTP failure" do
      expect(MercaEx.HTTPClientMock, :post, fn _url, _body, _opts ->
        {:error, %{reason: :timeout}}
      end)

      assert {:error, _} = Algolia.search("leche")
    end

    test "returns error on non-200 status" do
      expect(MercaEx.HTTPClientMock, :post, fn _url, _body, _opts ->
        {:ok, %{status: 403, body: %{"message" => "Invalid API key"}}}
      end)

      assert {:error, {:http_error, 403, _}} = Algolia.search("leche")
    end

    test "parses product with all fields" do
      expect(MercaEx.HTTPClientMock, :post, fn _url, _body, _opts ->
        {:ok, %{status: 200, body: @algolia_response}}
      end)

      {:ok, [product | _]} = Algolia.search("leche")

      assert product.id == "10381"
      assert product.name == "Leche semidesnatada Hacendado"
      assert product.price == 5.28
      assert product.reference_price == 0.88
      assert product.reference_format == "L"
      assert product.photo_url == "https://prod-mercadona.imgix.net/images/leche.jpg"
    end
  end

  describe "available_warehouses/0" do
    test "returns list of known warehouse codes" do
      warehouses = Algolia.available_warehouses()

      assert "mad1" in warehouses
      assert "bcn1" in warehouses
      assert "vlc1" in warehouses
      assert "svq1" in warehouses
      assert "alc1" in warehouses
    end
  end
end
