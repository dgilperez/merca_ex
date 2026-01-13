# MercaEx

[![Hex.pm](https://img.shields.io/hexpm/v/merca_ex.svg)](https://hex.pm/packages/merca_ex)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/merca_ex)
[![CI](https://github.com/dgilperez/merca_ex/actions/workflows/ci.yml/badge.svg)](https://github.com/dgilperez/merca_ex/actions)

**Unofficial** Elixir client for Mercadona's internal API.

> **Note**: Mercadona does not provide an official public API. This library reverse-engineers
> the endpoints used by [tienda.mercadona.es](https://tienda.mercadona.es) for educational
> and personal use. The API may change without notice and break this library at any time.

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

## How It Works

This library interacts with two undocumented APIs:

### REST API (Categories & Products)

The main Mercadona web store exposes a REST API:

- Base URL: `https://tienda.mercadona.es/api`
- `GET /categories/` - List all categories
- `GET /categories/{id}/` - Products in a category
- `GET /products/{id}/` - Product details

### Search API (Algolia)

Mercadona uses [Algolia](https://www.algolia.com/) for product search. The credentials
are public (embedded in the web frontend JavaScript) and read-only:

```
App ID: 7UZJKL1DJ0
API Key: 9d8f2e39e90df472b4f2e559a116fe17 (read-only)
Index: products_prod_{warehouse}_es
```

#### Available Warehouses

Prices and product availability vary by warehouse/region:

| Code | Region | Notes |
|------|--------|-------|
| `mad1` | Madrid | Default, most complete catalog |
| `mad2` | Madrid | Alternative, sometimes different prices |
| `bcn1` | Barcelona | |
| `vlc1` | Valencia | |
| `vlc2` | Valencia | Limited catalog |
| `svq1` | Sevilla | |
| `alc1` | Alicante | |

**Note**: Not all regions have dedicated warehouse codes. Users in regions like Galicia
(A Coruña, Vigo, etc.) should use `mad1` as it has the most complete catalog.

## Prior Art

This library was inspired by and builds upon the reverse-engineering work of others:

- [mercapy](https://github.com/jtayped/mercapy) - Python client (MIT License)
- [mercadona-cli](https://github.com/alfonmga/mercadona-cli) - CLI tool with API documentation
- [Mercadona API Gist](https://gist.github.com/mdelapenya/7a7bf8e6f22d86d28ad3b5e3630b1343) - Algolia endpoint details

## Disclaimer

**This is an unofficial library.** Mercadona S.A. does not provide a public API.

- This library is **not affiliated with, endorsed by, or connected to Mercadona S.A.**
- The API endpoints were discovered by inspecting network traffic from [tienda.mercadona.es](https://tienda.mercadona.es)
- **The API may change or break at any time** without notice
- Use responsibly and respect Mercadona's servers (rate limiting, caching, etc.)
- Intended for personal/educational use

## License

MIT License. See [LICENSE](LICENSE) for details.
