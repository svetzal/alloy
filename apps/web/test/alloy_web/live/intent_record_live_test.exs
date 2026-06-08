defmodule AlloyWeb.IntentRecordLiveTest do
  use AlloyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Alloy.IntentFixtures
  import Alloy.ProjectsFixtures

  @create_attrs %{
    title: "Stable failure semantics",
    capability: "Failure semantics remain stable for consumers.",
    threat: "Ad hoc string errors escaping into API responses.",
    expectation: "More consumers will integrate with this API.",
    strategy: "Typed domain errors mapped at the boundary.",
    evidence_summary: "Error responses are generated from typed domain errors.",
    tradeoff: "Typed errors require an additional mapping layer.",
    confidence: "0.9"
  }
  @update_attrs %{title: "Stable failure semantics (refined)", status: "accepted"}
  @invalid_attrs %{title: ""}

  setup do
    {:ok, project: project_fixture()}
  end

  describe "Index" do
    test "lists the project's records", %{conn: conn, project: project} do
      record = record_fixture(project: project)
      {:ok, _live, html} = live(conn, ~p"/projects/#{project}/intents")

      assert html =~ "Engineering Intent"
      assert html =~ project.name
      assert html =~ record.title
    end

    test "creates a new record", %{conn: conn, project: project} do
      {:ok, index_live, _html} = live(conn, ~p"/projects/#{project}/intents")

      assert {:ok, form_live, _html} =
               index_live
               |> element("a", "New Intent Record")
               |> render_click()
               |> follow_redirect(conn, ~p"/projects/#{project}/intents/new")

      assert render(form_live) =~ "New Intent Record"

      {:ok, _live, html} =
        form_live
        |> form("#intent-record-form", record: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/projects/#{project}/intents")

      assert html =~ "Intent record created successfully"
      assert html =~ "Stable failure semantics"
    end

    test "deletes a record", %{conn: conn, project: project} do
      record = record_fixture(project: project)
      {:ok, index_live, _html} = live(conn, ~p"/projects/#{project}/intents")

      assert index_live |> element("#records-#{record.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#records-#{record.id}")
    end
  end

  describe "Form validation" do
    test "renders errors for invalid data", %{conn: conn, project: project} do
      {:ok, form_live, _html} = live(conn, ~p"/projects/#{project}/intents/new")

      html =
        form_live
        |> form("#intent-record-form", record: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "Edit" do
    test "updates a record", %{conn: conn, project: project} do
      record = record_fixture(project: project)
      {:ok, form_live, _html} = live(conn, ~p"/projects/#{project}/intents/#{record}/edit")

      {:ok, _live, html} =
        form_live
        |> form("#intent-record-form", record: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/projects/#{project}/intents")

      assert html =~ "Intent record updated successfully"
      assert html =~ "Stable failure semantics (refined)"
    end
  end

  describe "Show" do
    test "displays a record", %{conn: conn, project: project} do
      record = record_fixture(project: project)
      {:ok, _live, html} = live(conn, ~p"/projects/#{project}/intents/#{record}")

      assert html =~ record.title
      assert html =~ record.capability
      assert html =~ "#{project.key}.intent.#{record.slug}"
    end
  end
end
