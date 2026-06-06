defmodule AlloyWeb.Api.ProjectJSON do
  @moduledoc "Serializes `Alloy.Projects.Project` for the JSON API."

  alias Alloy.Projects.Project

  @doc "The public JSON shape of a project."
  def data(%Project{} = project) do
    %{
      key: project.key,
      name: project.name,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at
    }
  end
end
