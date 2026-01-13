defmodule MercaEx.HTTPClient do
  @moduledoc """
  Behaviour for HTTP client operations.

  This behaviour allows for easy mocking in tests while using
  the real HTTP client in production.
  """

  @type url :: String.t()
  @type body :: String.t()
  @type opts :: keyword()
  @type response :: %{status: integer(), body: term()}
  @type error :: %{reason: term()}

  @callback get(url(), opts()) :: {:ok, response()} | {:error, error()}
  @callback post(url(), body(), opts()) :: {:ok, response()} | {:error, error()}
end
