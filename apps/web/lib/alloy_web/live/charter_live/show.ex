defmodule AlloyWeb.CharterLive.Show do
  use AlloyWeb, :live_view

  alias Alloy.Charters
  alias Alloy.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} projects={@projects} current_project={@project}>
      <.header>
        Charter — {@project.name}
        <:subtitle>
          The product context that grounds every engineering intent in this project.
          Leave a field blank if it does not yet apply.
        </:subtitle>
        <:actions>
          <.button navigate={~p"/projects/#{@project}"}>Back to project</.button>
        </:actions>
      </.header>

      <.form for={@form} id="charter-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:mission]}
          type="textarea"
          label="Mission — why the product exists"
        />
        <.input
          field={@form[:target_audience]}
          type="textarea"
          label="Target audience — who it serves"
        />
        <.input
          field={@form[:problem_space]}
          type="textarea"
          label="Problem space — the problem it addresses"
        />
        <.input
          field={@form[:differentiators]}
          type="textarea"
          label="Differentiators — what sets it apart"
        />
        <.input
          field={@form[:out_of_scope]}
          type="textarea"
          label="Out of scope — what it deliberately does not do"
        />

        <footer class="mt-4 flex items-center gap-4">
          <.button variant="primary" phx-disable-with="Saving...">Save Charter</.button>
          <.button navigate={~p"/projects/#{@project}"}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"project_key" => project_key}, _session, socket) do
    project = Projects.get_project_by_key!(project_key)
    charter = Charters.get_or_new_charter(project)

    {:ok,
     socket
     |> assign(:page_title, "Charter — #{project.name}")
     |> assign(:project, project)
     |> assign(:projects, Projects.list_projects())
     |> assign(:charter, charter)
     |> assign_form(Charters.change_charter(charter))}
  end

  @impl true
  def handle_event("validate", %{"charter" => params}, socket) do
    changeset =
      socket.assigns.charter
      |> Charters.change_charter(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"charter" => params}, socket) do
    case Charters.upsert_charter(socket.assigns.project, params) do
      {:ok, charter} ->
        {:noreply,
         socket
         |> assign(:charter, charter)
         |> assign_form(Charters.change_charter(charter))
         |> put_flash(:info, "Charter saved")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "charter"))
  end
end
