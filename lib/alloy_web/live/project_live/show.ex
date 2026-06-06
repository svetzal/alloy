defmodule AlloyWeb.ProjectLive.Show do
  use AlloyWeb, :live_view

  alias Alloy.Projects
  alias Alloy.Projects.ApiToken

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} projects={@projects} current_project={@project}>
      <.header>
        {@project.name}
        <:subtitle>
          <span class="font-mono text-sm">{@project.key}</span>
        </:subtitle>
        <:actions>
          <.button navigate={~p"/projects"}>Back</.button>
          <.button variant="primary" navigate={~p"/projects/#{@project}/intents"}>
            <.icon name="hero-rectangle-stack" /> Intent Records
          </.button>
          <.button navigate={~p"/projects/#{@project}/edit"}>
            <.icon name="hero-pencil-square" /> Edit
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@project.name}</:item>
        <:item title="Key">{@project.key}</:item>
      </.list>

      <section class="mt-10">
        <.header>
          API Tokens
          <:subtitle>
            Per-project bearer tokens for the JSON API and the <code>alloy</code> CLI.
            A token's secret is shown only once, at creation — store it safely.
          </:subtitle>
        </.header>

        <div
          :if={@new_secret}
          class="alert alert-success mt-4 flex-col items-stretch gap-3"
          id="new-token-secret"
        >
          <p class="font-semibold">
            <.icon name="hero-check-circle" class="size-5" />
            Token created. Copy it now — it will not be shown again.
          </p>
          <pre class="bg-base-100 text-base-content rounded p-3 text-sm overflow-x-auto"><code>{"ALLOY_API_HOST=#{@api_host}\nALLOY_API_TOKEN=#{@new_secret}"}</code></pre>
          <p class="text-sm">
            Save these two lines as <code>.alloy_env</code> in your project root (it is gitignored).
          </p>
          <div>
            <.button phx-click="dismiss_secret">Dismiss</.button>
          </div>
        </div>

        <.form for={@token_form} id="token-form" phx-change="validate_token" phx-submit="mint_token">
          <div class="flex items-end gap-4">
            <div class="grow">
              <.input
                field={@token_form[:name]}
                type="text"
                label="Token name (e.g. “laptop” or “CI”)"
              />
            </div>
            <.button variant="primary" phx-disable-with="Generating...">
              <.icon name="hero-key" /> Generate token
            </.button>
          </div>
        </.form>

        <.table :if={@tokens != []} id="api-tokens" rows={@tokens} row_id={&"token-#{&1.id}"}>
          <:col :let={token} label="Name">{token.name}</:col>
          <:col :let={token} label="Last used">{format_used(token.last_used_at)}</:col>
          <:col :let={token} label="Created">{Calendar.strftime(token.inserted_at, "%Y-%m-%d")}</:col>
          <:action :let={token}>
            <.button
              phx-click="revoke_token"
              phx-value-id={token.id}
              data-confirm="Revoke this token? Any client using it will stop working."
            >
              Revoke
            </.button>
          </:action>
        </.table>

        <p :if={@tokens == []} class="text-base-content/60 mt-4 text-sm">
          No tokens yet. Generate one above to connect the CLI.
        </p>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"key" => key}, _session, socket) do
    project = Projects.get_project_by_key!(key)

    {:ok,
     socket
     |> assign(:page_title, project.name)
     |> assign(:project, project)
     |> assign(:projects, Projects.list_projects())
     |> assign(:api_host, AlloyWeb.Endpoint.url())
     |> assign(:new_secret, nil)
     |> assign_tokens()
     |> assign_token_form(Projects.change_api_token())}
  end

  @impl true
  def handle_event("validate_token", %{"token" => params}, socket) do
    changeset =
      %ApiToken{}
      |> Projects.change_api_token(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_token_form(socket, changeset)}
  end

  def handle_event("mint_token", %{"token" => params}, socket) do
    case Projects.create_api_token(socket.assigns.project, params) do
      {:ok, _token, secret} ->
        {:noreply,
         socket
         |> assign(:new_secret, secret)
         |> assign_tokens()
         |> assign_token_form(Projects.change_api_token())
         |> put_flash(:info, "Token created.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_token_form(socket, changeset)}
    end
  end

  def handle_event("revoke_token", %{"id" => id}, socket) do
    case Enum.find(socket.assigns.tokens, &(&1.id == id)) do
      nil ->
        {:noreply, socket}

      token ->
        {:ok, _} = Projects.delete_api_token(token)

        {:noreply,
         socket
         |> assign_tokens()
         |> put_flash(:info, "Token revoked.")}
    end
  end

  def handle_event("dismiss_secret", _params, socket) do
    {:noreply, assign(socket, :new_secret, nil)}
  end

  defp assign_tokens(socket) do
    assign(socket, :tokens, Projects.list_api_tokens(socket.assigns.project))
  end

  defp assign_token_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :token_form, to_form(changeset, as: "token"))
  end

  defp format_used(nil), do: "Never"
  defp format_used(%DateTime{} = at), do: Calendar.strftime(at, "%Y-%m-%d %H:%M UTC")
end
