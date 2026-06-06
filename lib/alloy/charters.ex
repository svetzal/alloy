defmodule Alloy.Charters do
  @moduledoc """
  The Charters context: each project's single product charter.

  A charter holds the five free-text fields (`mission`, `target_audience`,
  `problem_space`, `differentiators`, `out_of_scope`) that ground a project's
  engineering intent. There is at most one charter per project; this context
  owns all persistence for `Alloy.Charters.Charter`. The web layer delegates
  here; it never builds Ecto queries directly.
  """

  import Ecto.Query, warn: false

  alias Alloy.Charters.Charter
  alias Alloy.Projects.Project
  alias Alloy.Repo

  @doc """
  Gets a project's charter, or `nil` if it has none yet.
  """
  def get_charter(%Project{} = project) do
    Repo.get_by(Charter, project_id: project.id)
  end

  @doc """
  Returns a project's charter, building an unsaved empty one when none exists.

  Useful for rendering: callers get a `%Charter{}` to display or drive a form
  whether or not the project has saved any fields yet.
  """
  def get_or_new_charter(%Project{} = project) do
    get_charter(project) || %Charter{project_id: project.id}
  end

  @doc """
  Upserts a project's charter from `attrs`.

  Creates the charter if the project has none, otherwise updates the existing
  one. Returns `{:ok, charter}` or `{:error, changeset}`.
  """
  def upsert_charter(%Project{} = project, attrs) do
    case get_charter(project) do
      nil ->
        %Charter{project_id: project.id}
        |> Charter.changeset(attrs)
        |> Repo.insert()

      %Charter{} = charter ->
        charter
        |> Charter.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Returns true if the charter has at least one field filled in.

  Accepts either a `%Charter{}` or a `%Project{}` (for which it loads the
  charter). A project with no charter row, or a charter whose fields are all
  blank, is considered absent.
  """
  def present?(%Project{} = project) do
    case get_charter(project) do
      nil -> false
      %Charter{} = charter -> present?(charter)
    end
  end

  def present?(%Charter{} = charter) do
    Enum.any?(Charter.fields(), fn field ->
      case Map.get(charter, field) do
        value when is_binary(value) -> String.trim(value) != ""
        _ -> false
      end
    end)
  end

  @doc """
  Returns a changeset for tracking charter changes (e.g. to drive a form).
  """
  def change_charter(%Charter{} = charter, attrs \\ %{}) do
    Charter.changeset(charter, attrs)
  end
end
