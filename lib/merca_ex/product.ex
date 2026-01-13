defmodule MercaEx.Product do
  @moduledoc """
  Represents a Mercadona product.

  Contains pricing, identification, and product details.
  """

  defstruct [
    :id,
    :name,
    :price,
    :reference_price,
    :reference_format,
    :ean,
    :photo_url,
    :description
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          price: float(),
          reference_price: float() | nil,
          reference_format: String.t() | nil,
          ean: String.t() | nil,
          photo_url: String.t() | nil,
          description: String.t() | nil
        }

  @doc """
  Parses a product from API response data.
  """
  @spec from_api(map()) :: t()
  def from_api(data) do
    price_instructions = data["price_instructions"] || %{}
    details = data["details"] || %{}

    %__MODULE__{
      id: to_string(data["id"]),
      name: data["display_name"] || data["name"],
      price: price_instructions["unit_price"],
      reference_price: price_instructions["reference_price"],
      reference_format: price_instructions["reference_format"],
      ean: data["ean"],
      photo_url: extract_photo_url(data["photos"]),
      description: details["description"]
    }
  end

  defp extract_photo_url(nil), do: nil
  defp extract_photo_url([]), do: nil
  defp extract_photo_url([photo | _]), do: photo["regular"]
end
