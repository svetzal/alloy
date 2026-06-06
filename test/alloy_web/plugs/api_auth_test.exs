defmodule AlloyWeb.Plugs.ApiAuthTest do
  use AlloyWeb.ConnCase, async: true

  import Alloy.ProjectsFixtures

  alias AlloyWeb.Plugs.ApiAuth

  defp call(conn), do: ApiAuth.call(conn, ApiAuth.init([]))

  describe "with a valid bearer token" do
    test "assigns the owning project and does not halt", %{conn: conn} do
      project = project_fixture()
      {_token, secret} = api_token_fixture(project: project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{secret}")
        |> call()

      assert conn.assigns.current_project.id == project.id
      refute conn.halted
    end

    test "accepts a case-insensitive scheme", %{conn: conn} do
      {_token, secret} = api_token_fixture()

      conn =
        conn
        |> put_req_header("authorization", "bearer #{secret}")
        |> call()

      assert conn.assigns.current_project
      refute conn.halted
    end
  end

  describe "with a missing or bad token" do
    test "halts with 401 and the error envelope when the header is absent", %{conn: conn} do
      conn = call(conn)

      assert conn.halted
      assert conn.status == 401

      assert %{"success" => false, "error" => %{"code" => "unauthorized"}} =
               json_response(conn, 401)
    end

    test "halts with 401 for an unknown token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer alloy_nope")
        |> call()

      assert conn.halted
      assert conn.status == 401
    end

    test "halts with 401 for a non-bearer scheme", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic abc123")
        |> call()

      assert conn.halted
      assert conn.status == 401
    end
  end
end
