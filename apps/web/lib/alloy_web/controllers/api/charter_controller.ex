defmodule AlloyWeb.Api.CharterController do
  @moduledoc """
  JSON API for the token-scoped project's product charter.

  The bearer token identifies exactly one project (assigned as
  `conn.assigns.current_project` by `AlloyWeb.Plugs.ApiAuth`), so there is no
  project id in the path — these actions always operate on that project's
  charter. A project that has never set a charter still reads as the five-field
  shape with `null` values.
  """

  use AlloyWeb, :controller

  alias Alloy.Charters
  alias AlloyWeb.Api.CharterJSON
  alias AlloyWeb.Api.Envelope

  action_fallback AlloyWeb.Api.FallbackController

  @doc "Shows the current project's charter."
  def show(conn, _params) do
    charter = Charters.get_or_new_charter(conn.assigns.current_project)
    json(conn, Envelope.success(CharterJSON.data(charter)))
  end

  @doc "Upserts the current project's charter from the supplied fields."
  def update(conn, params) do
    with {:ok, charter} <- Charters.upsert_charter(conn.assigns.current_project, params) do
      json(conn, Envelope.success(CharterJSON.data(charter)))
    end
  end
end
