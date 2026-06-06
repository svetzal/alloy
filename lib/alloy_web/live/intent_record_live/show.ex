defmodule AlloyWeb.IntentRecordLive.Show do
  use AlloyWeb, :live_view

  alias Alloy.Intent

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@record.title}
        <:subtitle>
          <span class="badge badge-soft">{@record.status}</span>
          <span class="ml-2 text-base-content/70">
            confidence {@record.confidence} · version {@record.version}
          </span>
        </:subtitle>
        <:actions>
          <.button navigate={~p"/intents"}>Back</.button>
          <.button variant="primary" navigate={~p"/intents/#{@record}/edit?return_to=show"}>
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
  def mount(%{"id" => id}, _session, socket) do
    record = Intent.get_record!(id)

    {:ok,
     socket
     |> assign(:page_title, record.title)
     |> assign(:record, record)}
  end
end
