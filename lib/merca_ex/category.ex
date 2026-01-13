defmodule MercaEx.Category do
  @moduledoc """
  Represents a Mercadona product category.

  Categories can have subcategories (nested categories).
  """

  defstruct [:id, :name, :subcategories]

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          subcategories: [t()]
        }

  @doc """
  Parses a category from API response data.
  """
  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      subcategories: parse_subcategories(data["categories"])
    }
  end

  defp parse_subcategories(nil), do: []

  defp parse_subcategories(categories) when is_list(categories) do
    Enum.map(categories, &from_api/1)
  end
end
