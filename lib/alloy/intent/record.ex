defmodule Alloy.Intent.Record do
  @moduledoc """
  An Engineering Intent Record: a future-facing engineering judgement decomposed
  into six fields — capability, threat, expectation, strategy, evidence, and
  tradeoff:

  > We need to preserve this *capability* because this *threat* matters under
  > this *expectation*, so we prefer this *strategy*, require this *evidence*,
  > and accept this *tradeoff*.

  Records move through a lifecycle (`t:status/0`) because extracted intent is
  often a hypothesis, not a fact. See `docs/intent-model/` for the conceptual
  treatment.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Alloy.Projects.Project
  alias Alloy.Slug

  @typedoc "The lifecycle state of a record."
  @type status ::
          :hypothesized
          | :proposed
          | :accepted
          | :active
          | :deprecated
          | :contradicted
          | :superseded

  @statuses [
    :hypothesized,
    :proposed,
    :accepted,
    :active,
    :deprecated,
    :contradicted,
    :superseded
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :slug}

  schema "engineering_intent_records" do
    field :title, :string
    field :slug, :string
    field :capability, :string
    field :threat, :string
    field :expectation, :string
    field :strategy, :string
    field :evidence_summary, :string
    field :tradeoff, :string
    field :status, Ecto.Enum, values: @statuses, default: :proposed
    field :confidence, :float, default: 1.0
    field :scope, :map, default: %{}
    field :version, :integer, default: 1

    field :supersedes_id, :binary_id

    belongs_to :project, Project

    timestamps(type: :utc_datetime_usec)
  end

  # Editable on create. `project_id` is set via the association, not cast.
  # `slug` is set here once and is immutable thereafter.
  @creatable [
    :title,
    :slug,
    :capability,
    :threat,
    :expectation,
    :strategy,
    :evidence_summary,
    :tradeoff,
    :status,
    :confidence,
    :scope,
    :version,
    :supersedes_id
  ]

  # `slug` and `project_id` are dropped: both are immutable after creation.
  @updatable @creatable -- [:slug]

  @doc """
  Builds a changeset for creating an intent record under a project.

  The owning project is expected on the struct (e.g. via `Ecto.build_assoc/3`);
  it is not castable. The `slug` is derived from the title when blank, validated
  as a slug, and must be unique within the project.
  """
  def create_changeset(record, attrs) do
    record
    |> cast(attrs, @creatable)
    |> derive_slug_from_title()
    |> validate_required([:title, :slug, :project_id])
    |> validate_format(:slug, Slug.format(),
      message: "must be lowercase letters, numbers, underscores, or hyphens"
    )
    |> common_validations()
    |> assoc_constraint(:project)
    |> unique_constraint(:slug,
      name: :engineering_intent_records_project_id_slug_index,
      message: "is already taken within this project"
    )
  end

  @doc """
  Builds a changeset for updating an intent record.

  The `slug` and owning `project` are immutable, so neither may change.
  """
  def update_changeset(record, attrs) do
    record
    |> cast(attrs, @updatable)
    |> validate_required([:title])
    |> common_validations()
  end

  defp common_validations(changeset) do
    changeset
    |> validate_number(:confidence,
      greater_than_or_equal_to: 0.0,
      less_than_or_equal_to: 1.0
    )
    |> validate_number(:version, greater_than_or_equal_to: 1)
  end

  defp derive_slug_from_title(changeset) do
    case {get_field(changeset, :slug), get_field(changeset, :title)} do
      {slug, title} when slug in [nil, ""] and is_binary(title) ->
        put_change(changeset, :slug, Slug.slugify(title))

      _ ->
        changeset
    end
  end

  @doc """
  The full, project-namespaced key for a record: `<project_key>.intent.<slug>`.

  Requires the `:project` association to be loaded.
  """
  def full_key(%__MODULE__{project: %Project{key: project_key}, slug: slug})
      when is_binary(project_key) and is_binary(slug) do
    "#{project_key}.intent.#{slug}"
  end

  @doc "The full set of valid lifecycle statuses."
  def statuses, do: @statuses
end
