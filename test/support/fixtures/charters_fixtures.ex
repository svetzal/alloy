defmodule Alloy.ChartersFixtures do
  @moduledoc """
  Test fixtures for the `Alloy.Charters` context.
  """

  import Alloy.ProjectsFixtures

  @doc """
  Upserts a charter for a project, creating a default project when none is
  given. Returns the persisted charter.
  """
  def charter_fixture(attrs \\ %{}) do
    {project, attrs} = Map.pop_lazy(Enum.into(attrs, %{}), :project, &project_fixture/0)

    attrs =
      Enum.into(attrs, %{
        mission: "Capture and refine engineering intent.",
        target_audience: "Engineering teams building durable systems.",
        problem_space: "Intent erodes as code and people change.",
        differentiators: "Sits above the execution engine, versioned artifacts.",
        out_of_scope: "Executing the work itself."
      })

    {:ok, charter} = Alloy.Charters.upsert_charter(project, attrs)
    charter
  end
end
