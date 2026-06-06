defmodule AlloyWeb.Api.IntentRecordJSON do
  @moduledoc "Serializes `Alloy.Intent.Record` for the JSON API."

  alias Alloy.Intent.Record
  alias Alloy.Projects.Project

  @doc "Serializes a list of records that all belong to `project`."
  def list(records, %Project{} = project), do: Enum.map(records, &data(&1, project))

  @doc """
  The public JSON shape of a record.

  `project` supplies the namespace for the record's full `key`
  (`<project_key>.intent.<slug>`); all API records belong to the
  token-scoped project, so the caller passes it rather than relying on a
  preloaded association.
  """
  def data(%Record{} = record, %Project{} = project) do
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
      inserted_at: record.inserted_at,
      updated_at: record.updated_at
    }
  end
end
