defmodule Alloy.Projects do
  @moduledoc """
  The Projects context: the top-level containers that scope engineering intent.

  This context owns all persistence for `Alloy.Projects.Project`. The web layer
  delegates here; it never builds Ecto queries directly.
  """

  import Ecto.Query, warn: false

  alias Alloy.Projects.Project
  alias Alloy.Repo

  @doc """
  Returns all projects, alphabetically by name.
  """
  def list_projects do
    Repo.all(from p in Project, order_by: [asc: p.name, asc: p.id])
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the project does not exist.
  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Gets a single project by its key, or `nil` if none matches.
  """
  def get_project_by_key(key), do: Repo.get_by(Project, key: key)

  @doc """
  Gets a single project by its key.

  Raises `Ecto.NoResultsError` if no project has that key.
  """
  def get_project_by_key!(key), do: Repo.get_by!(Project, key: key)

  @doc """
  Creates a project.
  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project's mutable fields. The `key` is immutable.
  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.
  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns a changeset for tracking project changes (e.g. to drive a form).

  Picks the create or update changeset based on whether the project is already
  persisted, so the `key` field is editable only for new projects.
  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    if Ecto.get_meta(project, :state) == :loaded do
      Project.update_changeset(project, attrs)
    else
      Project.create_changeset(project, attrs)
    end
  end
end
