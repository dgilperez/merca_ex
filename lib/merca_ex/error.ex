defmodule MercaEx.Error do
  @moduledoc """
  Exception raised when MercaEx API operations fail.
  """

  defexception [:message, :reason]

  @type t :: %__MODULE__{
          message: String.t(),
          reason: term()
        }

  @impl true
  def exception(opts) do
    reason = Keyword.get(opts, :reason)
    message = Keyword.get(opts, :message, format_message(reason))

    %__MODULE__{
      message: message,
      reason: reason
    }
  end

  defp format_message({:http_error, status, body}) do
    "HTTP error #{status}: #{inspect(body)}"
  end

  defp format_message(%{reason: reason}) do
    "Request failed: #{inspect(reason)}"
  end

  defp format_message(reason) do
    "Error: #{inspect(reason)}"
  end
end
