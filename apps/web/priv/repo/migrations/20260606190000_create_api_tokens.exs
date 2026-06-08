defmodule Alloy.Repo.Migrations.CreateApiTokens do
  use Ecto.Migration

  @moduledoc """
  Per-project API tokens for the JSON API. Only a SHA-256 hash of each token is
  stored; the plaintext secret is shown once at creation and never persisted.
  """

  def change do
    create table(:api_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :token_hash, :string, null: false
      add :last_used_at, :utc_datetime_usec

      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:api_tokens, [:token_hash])
    create index(:api_tokens, [:project_id])
  end
end
