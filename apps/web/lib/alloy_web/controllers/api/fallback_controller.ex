defmodule AlloyWeb.Api.FallbackController do
  @moduledoc """
  Translates non-success action results into the JSON API error envelope.

  Controllers use `action_fallback/1` so their happy path can `with`-match the
  success case and let everything else — validation failures, missing records —
  land here in one consistent shape.
  """

  use AlloyWeb, :controller

  alias AlloyWeb.Api.Envelope

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(
      Envelope.error("Validation failed.", "unprocessable_entity", changeset_errors(changeset))
    )
  end

  def call(conn, error) when error in [nil, {:error, :not_found}] do
    conn
    |> put_status(:not_found)
    |> json(Envelope.error("Not found.", "not_found"))
  end

  # Flattens changeset errors into a map of field => [messages], with
  # interpolation applied (e.g. count/validation values substituted in).
  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
