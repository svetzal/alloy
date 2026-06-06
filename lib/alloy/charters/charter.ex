defmodule Alloy.Charters.Charter do
  @moduledoc """
  A Project's product charter: five free-text fields that capture the product
  context grounding all downstream engineering intent.

  The fields mirror the sibling product's charter so the two stay conceptually
  aligned:

    * `mission` — why the product exists
    * `target_audience` — who it serves
    * `problem_space` — the problem it addresses
    * `differentiators` — what sets it apart
    * `out_of_scope` — what it deliberately does not do

  There is exactly one charter per project. Every field is optional — a charter
  is "present" once any field is filled in (see `Alloy.Charters.present?/1`).
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Alloy.Projects.Project

  @fields ~w(mission target_audience problem_space differentiators out_of_scope)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "charters" do
    field :mission, :string
    field :target_audience, :string
    field :problem_space, :string
    field :differentiators, :string
    field :out_of_scope, :string

    belongs_to :project, Project

    timestamps(type: :utc_datetime_usec)
  end

  @doc "The five charter field names, in canonical order."
  def fields, do: @fields

  @doc """
  Builds a changeset for a charter. All five fields are optional; blank strings
  are normalized to `nil` so an emptied field reads as absent.
  """
  def changeset(charter, attrs) do
    charter
    |> cast(attrs, @fields)
    |> trim_blanks()
  end

  defp trim_blanks(changeset) do
    Enum.reduce(@fields, changeset, fn field, acc ->
      case get_change(acc, field) do
        value when is_binary(value) -> put_change(acc, field, normalize(value))
        _ -> acc
      end
    end)
  end

  defp normalize(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end
end
