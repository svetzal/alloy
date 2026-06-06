defmodule AlloyWeb.Api.IntentRecordControllerTest do
  use AlloyWeb.ConnCase, async: true

  import Alloy.IntentFixtures
  import Alloy.ProjectsFixtures

  alias Alloy.Intent

  setup %{conn: conn} do
    project = project_fixture(key: "acme", name: "Acme")
    {_token, secret} = api_token_fixture(project: project)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{secret}")

    {:ok, conn: conn, project: project}
  end

  describe "GET /api/v1/intents" do
    test "lists the project's records, newest first", %{conn: conn, project: project} do
      record_fixture(project: project, title: "Older", slug: "older")
      record_fixture(project: project, title: "Newer", slug: "newer")

      data = conn |> get(~p"/api/v1/intents") |> json_response(200) |> Map.fetch!("data")

      assert Enum.map(data, & &1["slug"]) == ["newer", "older"]
      assert hd(data)["key"] == "acme.intent.newer"
    end

    test "does not leak another project's records", %{conn: conn, project: project} do
      other = project_fixture(key: "other", name: "Other")
      record_fixture(project: other, title: "Theirs", slug: "theirs")
      record_fixture(project: project, title: "Mine", slug: "mine")

      data = conn |> get(~p"/api/v1/intents") |> json_response(200) |> Map.fetch!("data")
      assert Enum.map(data, & &1["slug"]) == ["mine"]
    end
  end

  describe "POST /api/v1/intents" do
    test "creates a record and returns 201 with the full key", %{conn: conn} do
      params = %{"title" => "Stable Failure Semantics", "capability" => "Fails predictably."}

      body = conn |> post(~p"/api/v1/intents", params) |> json_response(201)

      assert body["success"] == true
      assert body["data"]["slug"] == "stable_failure_semantics"
      assert body["data"]["key"] == "acme.intent.stable_failure_semantics"
      assert body["data"]["status"] == "proposed"
    end

    test "422 on invalid data", %{conn: conn} do
      body = conn |> post(~p"/api/v1/intents", %{"title" => ""}) |> json_response(422)
      assert body["error"]["code"] == "unprocessable_entity"
      assert body["error"]["details"]["title"] == ["can't be blank"]
    end
  end

  describe "GET /api/v1/intents/:slug" do
    test "shows a record", %{conn: conn, project: project} do
      record_fixture(project: project, title: "Find me", slug: "find_me")

      body = conn |> get(~p"/api/v1/intents/find_me") |> json_response(200)
      assert body["data"]["title"] == "Find me"
    end

    test "404 for an unknown slug", %{conn: conn} do
      body = conn |> get(~p"/api/v1/intents/nope") |> json_response(404)
      assert body["error"]["code"] == "not_found"
    end
  end

  describe "PATCH /api/v1/intents/:slug" do
    test "updates mutable fields", %{conn: conn, project: project} do
      record_fixture(project: project, slug: "edit_me")

      body =
        conn
        |> patch(~p"/api/v1/intents/edit_me", %{"title" => "Renamed"})
        |> json_response(200)

      assert body["data"]["title"] == "Renamed"
    end

    test "leaves the slug immutable", %{conn: conn, project: project} do
      record_fixture(project: project, slug: "fixed")

      body =
        conn
        |> patch(~p"/api/v1/intents/fixed", %{"slug" => "changed", "title" => "t"})
        |> json_response(200)

      assert body["data"]["slug"] == "fixed"
    end
  end

  describe "DELETE /api/v1/intents/:slug" do
    test "deletes the record", %{conn: conn, project: project} do
      record_fixture(project: project, slug: "delete_me")

      assert conn |> delete(~p"/api/v1/intents/delete_me") |> json_response(200) ==
               %{"success" => true, "data" => nil, "error" => nil}

      assert Intent.get_record_by_slug(project, "delete_me") == nil
    end
  end

  describe "lifecycle transition endpoints" do
    test "POST /accept moves proposed -> accepted", %{conn: conn, project: project} do
      record_fixture(project: project, slug: "r", status: :proposed)

      body = conn |> post(~p"/api/v1/intents/r/accept") |> json_response(200)
      assert body["data"]["status"] == "accepted"
    end

    test "POST /activate moves accepted -> active", %{conn: conn, project: project} do
      record_fixture(project: project, slug: "r", status: :accepted)

      body = conn |> post(~p"/api/v1/intents/r/activate") |> json_response(200)
      assert body["data"]["status"] == "active"
    end

    test "an illegal transition returns 422", %{conn: conn, project: project} do
      record_fixture(project: project, slug: "r", status: :proposed)

      body = conn |> post(~p"/api/v1/intents/r/activate") |> json_response(422)
      assert body["error"]["code"] == "unprocessable_entity"
      assert body["error"]["details"]["status"]
    end

    test "POST /supersede with by= links the replacement", %{conn: conn, project: project} do
      record_fixture(project: project, slug: "v1", status: :active)
      replacement = record_fixture(project: project, slug: "v2")

      body =
        conn |> post(~p"/api/v1/intents/v1/supersede", %{"by" => "v2"}) |> json_response(200)

      assert body["data"]["status"] == "superseded"
      assert Intent.get_record!(replacement.id).supersedes_id
    end

    test "POST /supersede with unknown by= returns 404", %{conn: conn, project: project} do
      record_fixture(project: project, slug: "v1", status: :active)

      body =
        conn |> post(~p"/api/v1/intents/v1/supersede", %{"by" => "ghost"}) |> json_response(404)

      assert body["error"]["code"] == "not_found"
    end
  end
end
