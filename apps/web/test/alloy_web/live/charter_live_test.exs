defmodule AlloyWeb.CharterLiveTest do
  use AlloyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Alloy.ChartersFixtures
  import Alloy.ProjectsFixtures

  describe "Show" do
    test "renders blank fields when the project has no charter", %{conn: conn} do
      project = project_fixture()
      {:ok, _live, html} = live(conn, ~p"/projects/#{project}/charter")

      assert html =~ "Charter — #{project.name}"
      assert html =~ "Mission"
      assert html =~ "Out of scope"
    end

    test "prefills the form with an existing charter", %{conn: conn} do
      project = project_fixture()
      charter_fixture(project: project, mission: "Preserve intent")

      {:ok, _live, html} = live(conn, ~p"/projects/#{project}/charter")
      assert html =~ "Preserve intent"
    end

    test "saves the charter", %{conn: conn} do
      project = project_fixture()
      {:ok, live, _html} = live(conn, ~p"/projects/#{project}/charter")

      html =
        live
        |> form("#charter-form",
          charter: %{mission: "Ship engineering intent", out_of_scope: "Execution"}
        )
        |> render_submit()

      assert html =~ "Charter saved"
      assert Alloy.Charters.get_charter(project).mission == "Ship engineering intent"
    end
  end

  describe "project Show charter section" do
    test "shows a prompt to set a charter when none exists", %{conn: conn} do
      project = project_fixture()
      {:ok, _live, html} = live(conn, ~p"/projects/#{project}")

      assert html =~ "No charter yet"
      assert html =~ "Set charter"
    end

    test "summarizes the charter when present", %{conn: conn} do
      project = project_fixture()
      charter_fixture(project: project, mission: "Preserve intent")

      {:ok, _live, html} = live(conn, ~p"/projects/#{project}")
      assert html =~ "Preserve intent"
      assert html =~ "Edit charter"
    end
  end
end
