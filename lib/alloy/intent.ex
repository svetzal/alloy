defmodule Alloy.Intent do
  @moduledoc """
  The Intent context: capture and refinement of Engineering Intent Records.

  This context owns all persistence for `Alloy.Intent.Record`. Records are
  scoped to a `Alloy.Projects.Project`. The web layer delegates here; it never
  builds Ecto queries directly.
  """

  import Ecto.Query, warn: false

  alias Alloy.Intent.Record
  alias Alloy.Projects.Project
  alias Alloy.Repo

  @doc """
  Returns a project's engineering intent records, most recently created first.
  """
  def list_records(%Project{} = project) do
    Repo.all(
      from r in Record,
        where: r.project_id == ^project.id,
        order_by: [desc: r.inserted_at, desc: r.id]
    )
  end

  @doc """
  Gets a single record by id, with its project preloaded.

  Raises `Ecto.NoResultsError` if the record does not exist.
  """
  def get_record!(id), do: Record |> Repo.get!(id) |> Repo.preload(:project)

  @doc """
  Gets a single record by its project-local slug, with its project preloaded.

  Raises `Ecto.NoResultsError` if no such record exists in the project.
  """
  def get_record_by_slug!(%Project{} = project, slug) do
    Record
    |> Repo.get_by!(project_id: project.id, slug: slug)
    |> Repo.preload(:project)
  end

  @doc """
  Gets a single record by its project-local slug, with its project preloaded, or
  `nil` if no such record exists in the project.
  """
  def get_record_by_slug(%Project{} = project, slug) do
    case Repo.get_by(Record, project_id: project.id, slug: slug) do
      nil -> nil
      record -> Repo.preload(record, :project)
    end
  end

  @doc """
  Creates an engineering intent record under a project.
  """
  def create_record(%Project{} = project, attrs \\ %{}) do
    project
    |> Ecto.build_assoc(:records)
    |> Record.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an engineering intent record. The slug and owning project are immutable.
  """
  def update_record(%Record{} = record, attrs) do
    record
    |> Record.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an engineering intent record.
  """
  def delete_record(%Record{} = record) do
    Repo.delete(record)
  end

  @doc """
  Accepts a record (`hypothesized`/`proposed` → `accepted`).
  """
  def accept_record(%Record{} = record), do: apply_transition(record, :accept)

  @doc """
  Activates a record (`accepted` → `active`).
  """
  def activate_record(%Record{} = record), do: apply_transition(record, :activate)

  @doc """
  Deprecates a record (`accepted`/`active` → `deprecated`).
  """
  def deprecate_record(%Record{} = record), do: apply_transition(record, :deprecate)

  @doc """
  Contradicts a record (any non-terminal state → `contradicted`).
  """
  def contradict_record(%Record{} = record), do: apply_transition(record, :contradict)

  @doc """
  Supersedes a record (any non-terminal state → `superseded`).

  With a `superseding` record, the two are linked (the superseding record's
  `supersedes_id` is pointed at the old one) and both writes happen atomically:
  if the old record cannot be superseded, the link is rolled back.
  """
  def supersede_record(record, superseding \\ nil)

  def supersede_record(%Record{} = record, nil), do: apply_transition(record, :supersede)

  def supersede_record(%Record{} = record, %Record{} = superseding) do
    Repo.transaction(fn ->
      {:ok, _} =
        superseding
        |> Ecto.Changeset.change(supersedes_id: record.id)
        |> Repo.update()

      case apply_transition(record, :supersede) do
        {:ok, superseded} -> superseded
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  defp apply_transition(%Record{} = record, event) do
    record
    |> Record.transition_changeset(event)
    |> Repo.update()
  end

  @doc """
  Returns a changeset for tracking record changes (e.g. to drive a form).

  Picks the create or update changeset based on whether the record is already
  persisted, so the slug is editable only for new records.
  """
  def change_record(%Record{} = record, attrs \\ %{}) do
    if Ecto.get_meta(record, :state) == :loaded do
      Record.update_changeset(record, attrs)
    else
      Record.create_changeset(record, attrs)
    end
  end
end
