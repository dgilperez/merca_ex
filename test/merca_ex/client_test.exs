defmodule MercaEx.ClientTest do
  use ExUnit.Case, async: true

  import Mox

  alias MercaEx.Client

  @base_url "https://tienda.mercadona.es/api"

  setup :verify_on_exit!

  describe "get/2" do
    test "makes GET request to the correct URL" do
      expect(MercaEx.HTTPClientMock, :get, fn url, _opts ->
        assert url == "#{@base_url}/categories/"
        {:ok, %{status: 200, body: %{"results" => []}}}
      end)

      assert {:ok, %{"results" => []}} = Client.get("/categories/")
    end

    test "passes options through to HTTP client" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, opts ->
        assert opts[:params] == %{lang: "es"}
        {:ok, %{status: 200, body: %{}}}
      end)

      Client.get("/categories/", params: %{lang: "es"})
    end

    test "returns error tuple on HTTP error" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, _opts ->
        {:error, %{reason: :timeout}}
      end)

      assert {:error, %{reason: :timeout}} = Client.get("/categories/")
    end

    test "returns error tuple on non-2xx status" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, _opts ->
        {:ok, %{status: 404, body: %{"error" => "Not found"}}}
      end)

      assert {:error, {:http_error, 404, %{"error" => "Not found"}}} = Client.get("/categories/")
    end

    test "returns error tuple on 5xx status" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, _opts ->
        {:ok, %{status: 500, body: nil}}
      end)

      assert {:error, {:http_error, 500, nil}} = Client.get("/categories/")
    end
  end

  describe "get!/2" do
    test "returns body directly on success" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, _opts ->
        {:ok, %{status: 200, body: %{"data" => "value"}}}
      end)

      assert %{"data" => "value"} = Client.get!("/test/")
    end

    test "raises on error" do
      expect(MercaEx.HTTPClientMock, :get, fn _url, _opts ->
        {:error, %{reason: :timeout}}
      end)

      assert_raise MercaEx.Error, fn ->
        Client.get!("/test/")
      end
    end
  end
end
