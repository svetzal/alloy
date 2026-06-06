defmodule AlloyWeb.IntentRecordLive.Show do
  use AlloyWeb, :live_view

  alias Alloy.Intent
  alias Alloy.Intent.Record
  alias Alloy.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} projects={@projects} current_project={@project}>
      <.header>
        {@record.title}
        <:subtitle>
          <span class="font-mono text-xs">{Record.full_key(@record)}</span>
          <span class="ml-2 badge badge-soft">{@record.status}</span>
          <span class="ml-2 text-base-content/70">
            confidence {@record.confidence} · version {@record.version}
          </span>
        </:subtitle>
        <:actions>
          <.button navigate={~p"/projects/#{@project}/intents"}>Back</.button>
          <.button
            variant="primary"
            navigate={~p"/projects/#{@project}/intents/#{@record}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Capability">{@record.capability}</:item>
        <:item title="Threat">{@record.threat}</:item>
        <:item title="Expectation">{@record.expectation}</:item>
        <:item title="Strategy">{@record.strategy}</:item>
        <:item title="Evidence">{@record.evidence_summary}</:item>
        <:item title="Tradeoff">{@record.tradeoff}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"project_key" => project_key, "slug" => slug}, _session, socket) do
    project = Projects.get_project_by_key!(project_key)
    record = Intent.get_record_by_slug!(project, slug)

    {:ok,
     socket
     |> assign(:page_title, record.title)
     |> assign(:project, project)
     |> assign(:projects, Projects.list_projects())
     |> assign(:record, record)}
  end
end
