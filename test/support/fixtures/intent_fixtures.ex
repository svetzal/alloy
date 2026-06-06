defmodule Alloy.IntentFixtures do
  @moduledoc """
  Test fixtures for the `Alloy.Intent` context.
  """

  @defaults %{
    title: "Business rules testable without I/O",
    capability: "Business rules can be tested without UI, network, or database.",
    threat: "Business logic leaking into LiveView event handlers.",
    expectation: "UI flows will evolve faster than domain policy.",
    strategy: "Functional Core / Imperative Shell.",
    evidence_summary: "Domain tests run without a database.",
    tradeoff: "Functional core boundaries can be over-applied to simple CRUD.",
    status: :proposed,
    confidence: 0.8,
    scope: %{"paths" => []}
  }

  @doc """
  Returns the default "alloy" project, creating it if necessary. Lets intent
  fixtures attach to a project without each caller managing one.
  """
  def default_project do
    Alloy.Projects.get_project_by_key("alloy") || Alloy.ProjectsFixtures.project_fixture()
  end

  @doc """
  Generate an engineering intent record. Pass `:project` to attach it to a
  specific project; otherwise the default "alloy" project is used.
  """
  def record_fixture(attrs \\ %{}) do
    {project, attrs} =
      attrs
      |> Enum.into(%{})
      |> Map.pop_lazy(:project, &default_project/0)

    {:ok, record} = Alloy.Intent.create_record(project, Map.merge(@defaults, attrs))

    record
  end
end
