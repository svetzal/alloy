defmodule AlloyWeb.Api.IntentRecordJSON do
  @moduledoc "Serializes `Alloy.Intent.Record` for the JSON API."

  alias Alloy.Intent.Record
  alias Alloy.Projects.Project

  @doc """
  Serializes a list of records that all belong to `project`.

  The records' own ids supply the `supersedes_id` → `supersedes_slug`
  resolution, so no extra query is needed: a record's predecessor is always in
  the same project and therefore present in the list.
  """
  def list(records, %Project{} = project) do
    id_to_slug = Map.new(records, &{&1.id, &1.slug})
    Enum.map(records, &data(&1, project, id_to_slug))
  end

  @doc """
  The public JSON shape of a record.

  `project` supplies the namespace for the record's full `key`
  (`<project_key>.intent.<slug>`); all API records belong to the
  token-scoped project, so the caller passes it rather than relying on a
  preloaded association.

  `id_to_slug` resolves the `supersedes_id` link to a `supersedes_slug` (the
  project-local slug of the predecessor record); an empty map leaves it `nil`.
  """
  def data(%Record{} = record, %Project{} = project, id_to_slug \\ %{}) do
    %{
      key: "#{project.key}.intent.#{record.slug}",
      project_key: project.key,
      slug: record.slug,
      title: record.title,
      capability: record.capability,
      threat: record.threat,
      expectation: record.expectation,
      strategy: record.strategy,
      evidence_summary: record.evidence_summary,
      tradeoff: record.tradeoff,
      status: record.status,
      confidence: record.confidence,
      version: record.version,
      scope: record.scope,
      supersedes_id: record.supersedes_id,
      supersedes_slug: Map.get(id_to_slug, record.supersedes_id),
      inserted_at: record.inserted_at,
      updated_at: record.updated_at
    }
  end
end
