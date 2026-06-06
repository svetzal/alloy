defmodule AlloyWeb.IntentRecordLive.Index do
  use AlloyWeb, :live_view

  alias Alloy.Intent
  alias Alloy.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} projects={@projects} current_project={@project}>
      <.header>
        Engineering Intent
        <:subtitle>
          {@project.name} — capabilities the codebase must retain, and the
          reasoning that protects them.
        </:subtitle>
        <:actions>
          <.button variant="primary" navigate={~p"/projects/#{@project}/intents/new"}>
            <.icon name="hero-plus" /> New Intent Record
          </.button>
        </:actions>
      </.header>

      <.table
        id="records"
        rows={@streams.records}
        row_click={fn {_id, record} -> JS.navigate(~p"/projects/#{@project}/intents/#{record}") end}
      >
        <:col :let={{_id, record}} label="Title">{record.title}</:col>
        <:col :let={{_id, record}} label="Capability">{record.capability}</:col>
        <:col :let={{_id, record}} label="Status">
          <span class="badge badge-soft">{record.status}</span>
        </:col>
        <:action :let={{_id, record}}>
          <.link navigate={~p"/projects/#{@project}/intents/#{record}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, record}}>
          <.link
            phx-click={JS.push("delete", value: %{id: record.id}) |> hide("##{id}")}
            data-confirm="Delete this intent record?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"project_key" => project_key}, _session, socket) do
    project = Projects.get_project_by_key!(project_key)

    {:ok,
     socket
     |> assign(:page_title, "#{project.name} — Engineering Intent")
     |> assign(:project, project)
     |> assign(:projects, Projects.list_projects())
     |> stream(:records, Intent.list_records(project))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    record = Intent.get_record!(id)
    {:ok, _} = Intent.delete_record(record)

    {:noreply, stream_delete(socket, :records, record)}
  end
end
