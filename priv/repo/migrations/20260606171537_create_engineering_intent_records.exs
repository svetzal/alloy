defmodule Alloy.Repo.Migrations.CreateEngineeringIntentRecords do
  use Ecto.Migration

  def change do
    create table(:engineering_intent_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :capability, :text
      add :threat, :text
      add :expectation, :text
      add :strategy, :text
      add :evidence_summary, :text
      add :tradeoff, :text
      add :status, :string, null: false, default: "proposed"
      add :confidence, :float, null: false, default: 1.0
      add :scope, :map, null: false, default: %{}
      add :version, :integer, null: false, default: 1

      add :supersedes_id,
          references(:engineering_intent_records, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:engineering_intent_records, [:status])
    create index(:engineering_intent_records, [:supersedes_id])
  end
end
