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

  schema "engineering_intent_records" do
    field :title, :string
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

    timestamps(type: :utc_datetime_usec)
  end

  @castable [
    :title,
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

  @doc """
  Builds a changeset for creating or updating an intent record.
  """
  def changeset(record, attrs) do
    record
    |> cast(attrs, @castable)
    |> validate_required([:title])
    |> validate_number(:confidence,
      greater_than_or_equal_to: 0.0,
      less_than_or_equal_to: 1.0
    )
    |> validate_number(:version, greater_than_or_equal_to: 1)
  end

  @doc "The full set of valid lifecycle statuses."
  def statuses, do: @statuses
end
