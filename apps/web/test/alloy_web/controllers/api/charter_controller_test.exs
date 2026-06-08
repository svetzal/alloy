defmodule AlloyWeb.Api.CharterControllerTest do
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

  describe "GET /api/v1/charter" do
    test "returns the five-field shape with nulls when unset", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/charter")

      assert %{
               "success" => true,
               "error" => nil,
               "data" => %{
                 "mission" => nil,
                 "target_audience" => nil,
                 "problem_space" => nil,
                 "differentiators" => nil,
                 "out_of_scope" => nil
               }
             } = json_response(conn, 200)
    end

    test "401 without a token" do
      conn = build_conn() |> put_req_header("accept", "application/json")
      conn = get(conn, ~p"/api/v1/charter")
      assert json_response(conn, 401)["success"] == false
    end
  end

  describe "PATCH /api/v1/charter" do
    test "creates the charter on first write", %{conn: conn} do
      conn =
        patch(conn, ~p"/api/v1/charter", %{
          "mission" => "Preserve engineering intent",
          "out_of_scope" => "Executing the work"
        })

      data = json_response(conn, 200)["data"]
      assert data["mission"] == "Preserve engineering intent"
      assert data["out_of_scope"] == "Executing the work"
      assert data["problem_space"] == nil
    end

    test "updates an existing charter without creating a second", %{conn: conn, project: project} do
      patch(conn, ~p"/api/v1/charter", %{"mission" => "First"})
      conn = patch(conn, ~p"/api/v1/charter", %{"mission" => "Second"})

      assert json_response(conn, 200)["data"]["mission"] == "Second"
      assert Alloy.Charters.get_charter(project).mission == "Second"
    end

    test "blank fields are normalized to null", %{conn: conn} do
      conn =
        patch(conn, ~p"/api/v1/charter", %{"mission" => "  Trim  ", "problem_space" => "   "})

      data = json_response(conn, 200)["data"]
      assert data["mission"] == "Trim"
      assert data["problem_space"] == nil
    end

    test "ignores unknown fields", %{conn: conn} do
      conn = patch(conn, ~p"/api/v1/charter", %{"mission" => "Set", "bogus" => "nope"})
      assert json_response(conn, 200)["data"]["mission"] == "Set"
      refute Map.has_key?(json_response(conn, 200)["data"], "bogus")
    end
  end
end
