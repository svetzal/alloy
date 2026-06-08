defmodule AlloyWeb.Api.Envelope do
  @moduledoc """
  The shared `{success, data, error}` response envelope for the JSON API.

  Every `/api/v1` response — success or failure — is wrapped here so the CLI can
  rely on one stable shape:

      %{"success" => true,  "data" => ...,  "error" => nil}
      %{"success" => false, "data" => nil,  "error" => %{"message" => ..., "code" => ...}}
  """

  @doc "Wraps a successful result. `data` is rendered as-is."
  def success(data), do: %{success: true, data: data, error: nil}

  @doc """
  Wraps a failure. `code` is a stable machine-readable string; `details` is an
  optional map (e.g. changeset errors keyed by field).
  """
  def error(message, code, details \\ nil) do
    error = %{message: message, code: code}
    error = if details, do: Map.put(error, :details, details), else: error
    %{success: false, data: nil, error: error}
  end
end
