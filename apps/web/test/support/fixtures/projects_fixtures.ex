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

  @doc """
  Mints an API token for a project and returns `{token, secret}`, where `secret`
  is the one-time plaintext bearer string. Creates a default project when none
  is given.
  """
  def api_token_fixture(attrs \\ %{}) do
    {project, attrs} = Map.pop_lazy(Enum.into(attrs, %{}), :project, &project_fixture/0)
    attrs = Enum.into(attrs, %{name: "test token"})

    {:ok, token, secret} = Alloy.Projects.create_api_token(project, attrs)
    {token, secret}
  end
end
