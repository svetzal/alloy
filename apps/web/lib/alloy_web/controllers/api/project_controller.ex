defmodule AlloyWeb.Api.ProjectController do
  @moduledoc """
  JSON API for the token-scoped project.

  The bearer token identifies exactly one project (assigned as
  `conn.assigns.current_project` by `AlloyWeb.Plugs.ApiAuth`), so there is no
  project id in the path — these actions always operate on that project.
  Project creation and deletion are web-UI concerns, not API ones.
  """

  use AlloyWeb, :controller

  alias Alloy.Projects
  alias AlloyWeb.Api.Envelope
  alias AlloyWeb.Api.ProjectJSON

  action_fallback AlloyWeb.Api.FallbackController

  @doc "Shows the current project."
  def show(conn, _params) do
    json(conn, Envelope.success(ProjectJSON.data(conn.assigns.current_project)))
  end

  @doc "Updates the current project's mutable fields (its `name`)."
  def update(conn, params) do
    with {:ok, project} <- Projects.update_project(conn.assigns.current_project, params) do
      json(conn, Envelope.success(ProjectJSON.data(project)))
    end
  end
end
