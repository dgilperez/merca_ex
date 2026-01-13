# MercaEx

[![Hex.pm](https://img.shields.io/hexpm/v/merca_ex.svg)](https://hex.pm/packages/merca_ex)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/merca_ex)
[![CI](https://github.com/dgilperez/merca_ex/actions/workflows/ci.yml/badge.svg)](https://github.com/dgilperez/merca_ex/actions)

Elixir client for the Mercadona API.

## Installation

Add `merca_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:merca_ex, "~> 0.1.0"}
  ]
end
```

## Usage

### List Categories

```elixir
{:ok, categories} = MercaEx.categories()

Enum.each(categories, fn cat ->
  IO.puts("#{cat.id}: #{cat.name}")
  Enum.each(cat.subcategories, fn sub ->
    IO.puts("  #{sub.id}: #{sub.name}")
  end)
end)
```

### Get Products by Category

```elixir
{:ok, products} = MercaEx.products(113)

Enum.each(products, fn product ->
  IO.puts("#{product.name} - #{product.price}€")
end)
```

### Get Product Details

```elixir
{:ok, product} = MercaEx.product("12345")

IO.puts("""
Name: #{product.name}
Price: #{product.price}€
EAN: #{product.ean}
Description: #{product.description}
""")
```

### Search Products

```elixir
{:ok, results} = MercaEx.search("leche")

# With options
{:ok, results} = MercaEx.search("leche", warehouse: "mad1", limit: 10)
```

## Data Types

### Category

```elixir
%MercaEx.Category{
  id: 112,
  name: "Aceite, especias y salsas",
  subcategories: [
    %MercaEx.Category{id: 113, name: "Aceite de oliva", subcategories: []}
  ]
}
```

### Product

```elixir
%MercaEx.Product{
  id: "12345",
  name: "Aceite de oliva virgen extra",
  price: 5.99,
  reference_price: 5.99,
  reference_format: "1 L",
  ean: "8480000123456",
  photo_url: "https://...",
  description: "Aceite de primera calidad"
}
```

## Configuration

For testing, you can configure a mock HTTP client:

```elixir
# config/test.exs
config :merca_ex, :http_client, MercaEx.HTTPClientMock
```

## API Reference

MercaEx wraps the undocumented Mercadona API:

- Base URL: `https://tienda.mercadona.es/api`
- Categories: `GET /categories/`
- Category products: `GET /categories/{id}/`
- Product details: `GET /products/{id}/`
- Search: Uses Algolia (see below)

### Search API (Algolia)

Mercadona uses [Algolia](https://www.algolia.com/) for product search. The Algolia credentials
are public (embedded in Mercadona's web frontend JavaScript) and read-only.

```
App ID: 7UZJKL1DJ0
API Key: 9d8f2e39e90df472b4f2e559a116fe17 (read-only)
Index: products_prod_{warehouse}_es
```

#### Available Warehouses

| Code | Region | Notes |
|------|--------|-------|
| `mad1` | Madrid | Default, recommended |
| `mad2` | Madrid | Alternative, sometimes different prices |
| `bcn1` | Barcelona | |
| `vlc1` | Valencia | |
| `vlc2` | Valencia | Limited catalog |
| `svq1` | Sevilla | |
| `alc1` | Alicante | |

**Note**: Not all regions have dedicated warehouse codes. Users in regions like Galicia
(A Coruña, Vigo, etc.) should use `mad1` as it has the most complete catalog.

#### References

This approach was documented by reverse-engineering Mercadona's web application:
- [mercapy](https://github.com/jtayped/mercapy) - Python client (MIT License)
- [Mercadona API Gist](https://gist.github.com/mdelapenya/7a7bf8e6f22d86d28ad3b5e3630b1343)

## Disclaimer

This library interacts with Mercadona's undocumented public API. It is not affiliated with,
endorsed by, or connected to Mercadona S.A. in any way. Use at your own risk. The API
may change without notice.

## License

MIT License. See [LICENSE](LICENSE) for details.
