defmodule Alloy.Projects.Project do
  @moduledoc """
  A Project: the top-level container that scopes engineering intent.

  Every project carries a stable, human-readable `key` (a slug matching
  `Alloy.Slug.format/0`) that namespaces the keys of the records it owns
  (`<project_key>.intent.<slug>`). The key is assigned once and is immutable
  thereafter; only the display `name` may change.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Alloy.Slug

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :key}

  schema "projects" do
    field :key, :string
    field :name, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Builds a changeset for creating a project.

  Both `key` and `name` are required, and `key` must be a unique, valid slug.
  When `key` is omitted or blank it is derived from `name`.
  """
  def create_changeset(project, attrs) do
    project
    |> cast(attrs, [:key, :name])
    |> derive_key_from_name()
    |> validate_required([:key, :name])
    |> validate_format(:key, Slug.format(),
      message: "must be lowercase letters, numbers, underscores, or hyphens"
    )
    |> unique_constraint(:key)
  end

  @doc """
  Builds a changeset for updating a project.

  The `key` is immutable, so only `name` may change.
  """
  def update_changeset(project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  defp derive_key_from_name(changeset) do
    case {get_field(changeset, :key), get_field(changeset, :name)} do
      {key, name} when key in [nil, ""] and is_binary(name) ->
        put_change(changeset, :key, Slug.slugify(name))

      _ ->
        changeset
    end
  end
end
