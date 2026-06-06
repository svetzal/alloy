defmodule AlloyWeb.Api.IntentRecordController do
  @moduledoc """
  JSON API for engineering intent records, scoped to the token's project.

  Records are addressed by their project-local `slug`. Alongside CRUD, each
  lifecycle transition (accept/activate/deprecate/contradict/supersede) is a
  `POST` to a sub-path so the CLI can drive a record through its lifecycle.
  """

  use AlloyWeb, :controller

  alias Alloy.Intent
  alias Alloy.Intent.Record
  alias AlloyWeb.Api.Envelope
  alias AlloyWeb.Api.IntentRecordJSON

  action_fallback AlloyWeb.Api.FallbackController

  def index(conn, _params) do
    project = conn.assigns.current_project
    records = Intent.list_records(project)
    json(conn, Envelope.success(IntentRecordJSON.list(records, project)))
  end

  def create(conn, params) do
    project = conn.assigns.current_project

    with {:ok, record} <- Intent.create_record(project, params) do
      conn
      |> put_status(:created)
      |> render_record(record, project)
    end
  end

  def show(conn, %{"slug" => slug}) do
    project = conn.assigns.current_project

    with %Record{} = record <- Intent.get_record_by_slug(project, slug) do
      render_record(conn, record, project)
    end
  end

  def update(conn, %{"slug" => slug} = params) do
    project = conn.assigns.current_project

    with %Record{} = record <- Intent.get_record_by_slug(project, slug),
         {:ok, record} <- Intent.update_record(record, params) do
      render_record(conn, record, project)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    project = conn.assigns.current_project

    with %Record{} = record <- Intent.get_record_by_slug(project, slug),
         {:ok, _record} <- Intent.delete_record(record) do
      json(conn, Envelope.success(nil))
    end
  end

  def accept(conn, params), do: transition(conn, params, &Intent.accept_record/1)
  def activate(conn, params), do: transition(conn, params, &Intent.activate_record/1)
  def deprecate(conn, params), do: transition(conn, params, &Intent.deprecate_record/1)
  def contradict(conn, params), do: transition(conn, params, &Intent.contradict_record/1)

  @doc """
  Supersedes a record. With `{"by": "<slug>"}` in the body, the named record is
  linked as the replacement (its `supersedes_id` points back at this one);
  otherwise the record is simply marked superseded.
  """
  def supersede(conn, %{"slug" => slug} = params) do
    project = conn.assigns.current_project

    with %Record{} = record <- Intent.get_record_by_slug(project, slug),
         {:ok, superseding} <- resolve_superseding(project, params),
         {:ok, record} <- Intent.supersede_record(record, superseding) do
      render_record(conn, record, project)
    end
  end

  defp resolve_superseding(_project, %{"by" => by}) when by in [nil, ""], do: {:ok, nil}

  defp resolve_superseding(project, %{"by" => by}) when is_binary(by) do
    case Intent.get_record_by_slug(project, by) do
      %Record{} = superseding -> {:ok, superseding}
      nil -> {:error, :not_found}
    end
  end

  defp resolve_superseding(_project, _params), do: {:ok, nil}

  defp transition(conn, %{"slug" => slug}, fun) do
    project = conn.assigns.current_project

    with %Record{} = record <- Intent.get_record_by_slug(project, slug),
         {:ok, record} <- fun.(record) do
      render_record(conn, record, project)
    end
  end

  defp render_record(conn, record, project) do
    json(conn, Envelope.success(IntentRecordJSON.data(record, project)))
  end
end
