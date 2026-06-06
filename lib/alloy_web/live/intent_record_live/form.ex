defmodule AlloyWeb.IntentRecordLive.Form do
  use AlloyWeb, :live_view

  alias Alloy.Intent
  alias Alloy.Intent.Record

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>
          We need to preserve this capability because this threat matters under this
          expectation, so we prefer this strategy, require this evidence, and accept
          this tradeoff.
        </:subtitle>
      </.header>

      <.form for={@form} id="intent-record-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />

        <.input
          field={@form[:capability]}
          type="textarea"
          label="Capability — the ability to retain"
        />
        <.input
          field={@form[:threat]}
          type="textarea"
          label="Threat — the force that erodes it"
        />
        <.input
          field={@form[:expectation]}
          type="textarea"
          label="Expectation — the change that makes it matter"
        />
        <.input
          field={@form[:strategy]}
          type="textarea"
          label="Strategy — the approach that protects it"
        />
        <.input
          field={@form[:evidence_summary]}
          type="textarea"
          label="Evidence — observable proof it is working"
        />
        <.input
          field={@form[:tradeoff]}
          type="textarea"
          label="Tradeoff — the cost the strategy introduces"
        />

        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={status_options()}
        />
        <.input
          field={@form[:confidence]}
          type="number"
          label="Confidence (0.0–1.0)"
          step="0.05"
          min="0"
          max="1"
        />

        <footer class="mt-4 flex items-center gap-4">
          <.button variant="primary" phx-disable-with="Saving...">Save Intent Record</.button>
          <.button navigate={return_path(@return_to, @record)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :new, _params) do
    record = %Record{}

    socket
    |> assign(:page_title, "New Intent Record")
    |> assign(:record, record)
    |> assign_form(Intent.change_record(record))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    record = Intent.get_record!(id)

    socket
    |> assign(:page_title, "Edit Intent Record")
    |> assign(:record, record)
    |> assign_form(Intent.change_record(record))
  end

  @impl true
  def handle_event("validate", %{"record" => record_params}, socket) do
    changeset = Intent.change_record(socket.assigns.record, record_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"record" => record_params}, socket) do
    save_record(socket, socket.assigns.live_action, record_params)
  end

  defp save_record(socket, :new, record_params) do
    case Intent.create_record(record_params) do
      {:ok, record} ->
        {:noreply,
         socket
         |> put_flash(:info, "Intent record created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, record))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_record(socket, :edit, record_params) do
    case Intent.update_record(socket.assigns.record, record_params) do
      {:ok, record} ->
        {:noreply,
         socket
         |> put_flash(:info, "Intent record updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, record))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "record"))
  end

  defp status_options do
    Enum.map(Record.statuses(), fn status ->
      {status |> Atom.to_string() |> String.capitalize(), status}
    end)
  end

  defp return_path("index", _record), do: ~p"/intents"
  defp return_path("show", record), do: ~p"/intents/#{record}"
end
