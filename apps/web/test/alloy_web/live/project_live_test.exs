defmodule AlloyWeb.ProjectLiveTest do
  use AlloyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Alloy.ProjectsFixtures

  @create_attrs %{key: "ledger", name: "Ledger"}
  @update_attrs %{name: "Ledger (renamed)"}
  @invalid_attrs %{key: "Not A Slug", name: ""}

  describe "Index" do
    test "lists projects", %{conn: conn} do
      project = project_fixture()
      {:ok, _live, html} = live(conn, ~p"/projects")

      assert html =~ "Projects"
      assert html =~ project.name
      assert html =~ project.key
    end

    test "creates a new project", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/projects")

      assert {:ok, form_live, _html} =
               index_live
               |> element("a", "New Project")
               |> render_click()
               |> follow_redirect(conn, ~p"/projects/new")

      assert render(form_live) =~ "New Project"

      {:ok, _live, html} =
        form_live
        |> form("#project-form", project: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/projects/ledger")

      assert html =~ "Project created successfully"
      assert html =~ "Ledger"
    end

    test "deletes a project", %{conn: conn} do
      project = project_fixture()
      {:ok, index_live, _html} = live(conn, ~p"/projects")

      assert index_live |> element("#projects-#{project.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#projects-#{project.id}")
    end
  end

  describe "Form validation" do
    test "renders errors for invalid data", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/projects/new")

      html =
        form_live
        |> form("#project-form", project: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "Edit" do
    test "updates a project's name", %{conn: conn} do
      project = project_fixture()
      {:ok, form_live, _html} = live(conn, ~p"/projects/#{project}/edit")

      {:ok, _live, html} =
        form_live
        |> form("#project-form", project: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/projects/#{project}")

      assert html =~ "Project updated successfully"
      assert html =~ "Ledger (renamed)"
    end
  end

  describe "Show" do
    test "displays a project", %{conn: conn} do
      project = project_fixture()
      {:ok, _live, html} = live(conn, ~p"/projects/#{project}")

      assert html =~ project.name
      assert html =~ project.key
    end
  end

  describe "Show — API tokens" do
    test "shows an empty state when there are no tokens", %{conn: conn} do
      project = project_fixture()
      {:ok, _live, html} = live(conn, ~p"/projects/#{project}")

      assert html =~ "API Tokens"
      assert html =~ "No tokens yet"
    end

    test "mints a token and reveals the secret once", %{conn: conn} do
      project = project_fixture()
      {:ok, live, _html} = live(conn, ~p"/projects/#{project}")

      html =
        live
        |> form("#token-form", token: %{name: "laptop"})
        |> render_submit()

      assert html =~ "will not be shown again"
      assert html =~ "ALLOY_API_TOKEN=alloy_"
      assert html =~ "laptop"
      assert has_element?(live, "#api-tokens")
    end

    test "shows a validation error for a blank name", %{conn: conn} do
      project = project_fixture()
      {:ok, live, _html} = live(conn, ~p"/projects/#{project}")

      html =
        live
        |> form("#token-form", token: %{name: ""})
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      refute html =~ "will not be shown again"
    end

    test "revokes a token", %{conn: conn} do
      project = project_fixture()
      {:ok, token, _secret} = Alloy.Projects.create_api_token(project, %{name: "doomed"})
      {:ok, live, _html} = live(conn, ~p"/projects/#{project}")

      assert has_element?(live, "#token-#{token.id}")

      live
      |> element("#token-#{token.id} button", "Revoke")
      |> render_click()

      refute has_element?(live, "#token-#{token.id}")
      assert Alloy.Projects.list_api_tokens(project) == []
    end
  end
end
