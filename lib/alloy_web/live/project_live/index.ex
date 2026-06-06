defmodule AlloyWeb.ProjectLive.Index do
  use AlloyWeb, :live_view

  alias Alloy.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Projects
        <:subtitle>
          The top-level containers that scope engineering intent.
        </:subtitle>
        <:actions>
          <.button variant="primary" navigate={~p"/projects/new"}>
            <.icon name="hero-plus" /> New Project
          </.button>
        </:actions>
      </.header>

      <.table
        id="projects"
        rows={@streams.projects}
        row_click={fn {_id, project} -> JS.navigate(~p"/projects/#{project}") end}
      >
        <:col :let={{_id, project}} label="Name">{project.name}</:col>
        <:col :let={{_id, project}} label="Key">
          <span class="font-mono text-sm">{project.key}</span>
        </:col>
        <:action :let={{_id, project}}>
          <.link navigate={~p"/projects/#{project}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, project}}>
          <.link
            phx-click={JS.push("delete", value: %{id: project.id}) |> hide("##{id}")}
            data-confirm="Delete this project and all of its intent records?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Projects")
     |> stream(:projects, Projects.list_projects())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, stream_delete(socket, :projects, project)}
  end
end
