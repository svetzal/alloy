defmodule Alloy.Repo.Migrations.CreateCharters do
  use Ecto.Migration

  @moduledoc """
  A per-project product charter: the five free-text fields (mission, target
  audience, problem space, differentiators, out of scope) that ground all
  downstream engineering intent. One charter per project.
  """

  def change do
    create table(:charters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :mission, :text
      add :target_audience, :text
      add :problem_space, :text
      add :differentiators, :text
      add :out_of_scope, :text

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:charters, [:project_id])
  end
end
