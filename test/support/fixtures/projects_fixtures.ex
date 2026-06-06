defmodule Alloy.ProjectsFixtures do
  @moduledoc """
  Test fixtures for the `Alloy.Projects` context.
  """

  @doc """
  Generate a project. Pass a distinct `:key` when creating more than one in a
  single test, since project keys are unique.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        key: "alloy",
        name: "Alloy"
      })
      |> Alloy.Projects.create_project()

    project
  end
end
