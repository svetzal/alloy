defmodule AlloyWeb.Api.ProjectControllerTest do
  use AlloyWeb.ConnCase, async: true

  import Alloy.ProjectsFixtures

  setup %{conn: conn} do
    project = project_fixture(key: "acme", name: "Acme")
    {_token, secret} = api_token_fixture(project: project)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{secret}")

    {:ok, conn: conn, project: project}
  end

  describe "GET /api/v1/project" do
    test "returns the token-scoped project in the envelope", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/project")

      assert %{
               "success" => true,
               "error" => nil,
               "data" => %{"key" => "acme", "name" => "Acme"}
             } = json_response(conn, 200)
    end

    test "401 without a token", %{project: _project} do
      conn = build_conn() |> put_req_header("accept", "application/json")
      conn = get(conn, ~p"/api/v1/project")
      assert json_response(conn, 401)["success"] == false
    end
  end

  describe "PATCH /api/v1/project" do
    test "updates the project name", %{conn: conn} do
      conn = patch(conn, ~p"/api/v1/project", %{"name" => "Acme Corp"})
      assert json_response(conn, 200)["data"]["name"] == "Acme Corp"
    end

    test "422 on invalid data", %{conn: conn} do
      conn = patch(conn, ~p"/api/v1/project", %{"name" => ""})
      body = json_response(conn, 422)
      assert body["success"] == false
      assert body["error"]["code"] == "unprocessable_entity"
      assert body["error"]["details"]["name"] == ["can't be blank"]
    end

    test "cannot change the immutable key", %{conn: conn} do
      conn = patch(conn, ~p"/api/v1/project", %{"key" => "renamed", "name" => "Acme"})
      assert json_response(conn, 200)["data"]["key"] == "acme"
    end
  end
end
