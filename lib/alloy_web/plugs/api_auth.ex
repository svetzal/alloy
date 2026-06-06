defmodule AlloyWeb.Plugs.ApiAuth do
  @moduledoc """
  Authenticates JSON API requests by per-project bearer token.

  Reads the `Authorization: Bearer <secret>` header, resolves the owning project
  via `Alloy.Projects.authenticate_token/1`, and assigns it as
  `conn.assigns.current_project`. A missing, malformed, or unknown token halts
  the pipeline with a `401` and the standard error envelope.
  """

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias Alloy.Projects
  alias AlloyWeb.Api.Envelope

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, secret} <- bearer_token(conn),
         %Projects.Project{} = project <- Projects.authenticate_token(secret) do
      assign(conn, :current_project, project)
    else
      _ -> unauthorized(conn)
    end
  end

  defp bearer_token(conn) do
    with [header] <- get_req_header(conn, "authorization"),
         [scheme, secret] <- String.split(header, " ", parts: 2),
         "bearer" <- String.downcase(scheme) do
      {:ok, secret}
    else
      _ -> :error
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(Envelope.error("Missing or invalid API token.", "unauthorized"))
    |> halt()
  end
end
