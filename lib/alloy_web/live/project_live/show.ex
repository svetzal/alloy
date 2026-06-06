defmodule AlloyWeb.ProjectLive.Show do
  use AlloyWeb, :live_view

  alias Alloy.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@project.name}
        <:subtitle>
          <span class="font-mono text-sm">{@project.key}</span>
        </:subtitle>
        <:actions>
          <.button navigate={~p"/projects"}>Back</.button>
          <.button variant="primary" navigate={~p"/projects/#{@project}/edit"}>
            <.icon name="hero-pencil-square" /> Edit
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@project.name}</:item>
        <:item title="Key">{@project.key}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"key" => key}, _session, socket) do
    project = Projects.get_project_by_key!(key)

    {:ok,
     socket
     |> assign(:page_title, project.name)
     |> assign(:project, project)}
  end
end
