defmodule Alloy.Repo.Migrations.RelateIntentRecordsToProjects do
  use Ecto.Migration

  @moduledoc """
  Relates `engineering_intent_records` to `projects` and gives each record a
  project-local `slug`, migrating off the loose `scope->>'project'` string.

  Existing rows are attached to a project derived from their `scope.project`
  value (defaulting to "alloy") and are assigned their id as a placeholder
  slug; new rows derive a human-readable slug from the title in the changeset.
  """

  def up do
    alter table(:engineering_intent_records) do
      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all)
      add :slug, :string
    end

    # Ensure a project exists for each distinct scope project (default "alloy").
    execute("""
    INSERT INTO projects (id, key, name, inserted_at, updated_at)
    SELECT gen_random_uuid(),
           proj,
           initcap(replace(replace(proj, '_', ' '), '-', ' ')),
           now(),
           now()
    FROM (
      SELECT DISTINCT COALESCE(NULLIF(scope->>'project', ''), 'alloy') AS proj
      FROM engineering_intent_records
    ) s
    ON CONFLICT (key) DO NOTHING;
    """)

    # Attach each record to its project.
    execute("""
    UPDATE engineering_intent_records r
    SET project_id = p.id
    FROM projects p
    WHERE p.key = COALESCE(NULLIF(r.scope->>'project', ''), 'alloy')
      AND r.project_id IS NULL;
    """)

    # Assign legacy records a unique, valid slug (the row id is a valid slug).
    execute("""
    UPDATE engineering_intent_records
    SET slug = id::text
    WHERE slug IS NULL;
    """)

    execute("ALTER TABLE engineering_intent_records ALTER COLUMN project_id SET NOT NULL")
    execute("ALTER TABLE engineering_intent_records ALTER COLUMN slug SET NOT NULL")

    create unique_index(:engineering_intent_records, [:project_id, :slug])
  end

  def down do
    drop unique_index(:engineering_intent_records, [:project_id, :slug])

    alter table(:engineering_intent_records) do
      remove :slug
      remove :project_id
    end
  end
end
