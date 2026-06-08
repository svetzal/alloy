defmodule AlloyWeb.ProjectLive.Form do
  use AlloyWeb, :live_view

  alias Alloy.Projects
  alias Alloy.Projects.Project

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>
          A project's key is a stable slug that namespaces the keys of the
          intent records it owns. It is set once and cannot change.
        </:subtitle>
      </.header>

      <.form for={@form} id="project-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:key]}
          type="text"
          label="Key — a stable slug (lowercase, numbers, _ or -)"
          disabled={@live_action == :edit}
        />

        <footer class="mt-4 flex items-center gap-4">
          <.button variant="primary" phx-disable-with="Saving...">Save Project</.button>
          <.button navigate={return_path(@project)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    project = %Project{}

    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, project)
    |> assign_form(Projects.change_project(project))
  end

  defp apply_action(socket, :edit, %{"key" => key}) do
    project = Projects.get_project_by_key!(key)

    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, project)
    |> assign_form(Projects.change_project(project))
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = Projects.change_project(socket.assigns.project, project_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.live_action, project_params)
  end

  defp save_project(socket, :new, project_params) do
    case Projects.create_project(project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
         |> push_navigate(to: return_path(project))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_project(socket, :edit, project_params) do
    case Projects.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_navigate(to: return_path(project))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "project"))
  end

  defp return_path(%Project{key: nil}), do: ~p"/projects"
  defp return_path(%Project{} = project), do: ~p"/projects/#{project}"
end
