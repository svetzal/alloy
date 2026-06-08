defmodule Alloy.ProjectsTest do
  use Alloy.DataCase, async: true

  alias Alloy.Projects
  alias Alloy.Projects.Project

  import Alloy.ProjectsFixtures

  describe "list_projects/0" do
    test "returns all projects, alphabetically by name" do
      b = project_fixture(key: "beta", name: "Beta")
      a = project_fixture(key: "alpha", name: "Alpha")

      assert Projects.list_projects() |> Enum.map(& &1.id) == [a.id, b.id]
    end

    test "returns an empty list when there are no projects" do
      assert Projects.list_projects() == []
    end
  end

  describe "get_project!/1" do
    test "returns the project with the given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id).id == project.id
    end

    test "raises when the project does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project!(Ecto.UUID.generate())
      end
    end
  end

  describe "get_project_by_key/1" do
    test "returns the project with the given key" do
      project = project_fixture(key: "widget", name: "Widget")
      assert Projects.get_project_by_key("widget").id == project.id
    end

    test "returns nil when no project has that key" do
      assert Projects.get_project_by_key("missing") == nil
    end
  end

  describe "get_project_by_key!/1" do
    test "raises when no project has that key" do
      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project_by_key!("missing")
      end
    end
  end

  describe "create_project/1" do
    test "with valid data creates a project" do
      assert {:ok, %Project{} = project} =
               Projects.create_project(%{key: "ledger", name: "Ledger"})

      assert project.key == "ledger"
      assert project.name == "Ledger"
    end

    test "derives the key from the name when key is blank" do
      assert {:ok, %Project{} = project} =
               Projects.create_project(%{name: "Epilogue Tracker"})

      assert project.key == "epilogue_tracker"
    end

    test "requires a name" do
      assert {:error, changeset} = Projects.create_project(%{key: "x"})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "rejects an invalid key format" do
      assert {:error, changeset} =
               Projects.create_project(%{key: "Not A Slug", name: "X"})

      assert %{key: [_]} = errors_on(changeset)
    end

    test "enforces key uniqueness" do
      project_fixture(key: "dup", name: "First")

      assert {:error, changeset} = Projects.create_project(%{key: "dup", name: "Second"})
      assert %{key: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "update_project/2" do
    test "updates the name" do
      project = project_fixture()
      assert {:ok, updated} = Projects.update_project(project, %{name: "Renamed"})
      assert updated.name == "Renamed"
    end

    test "ignores attempts to change the immutable key" do
      project = project_fixture(key: "fixed", name: "Fixed")

      assert {:ok, updated} =
               Projects.update_project(project, %{key: "changed", name: "Fixed"})

      assert updated.key == "fixed"
    end

    test "requires a name" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, %{name: ""})
    end
  end

  describe "delete_project/1" do
    test "deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end
  end

  describe "change_project/2" do
    test "returns a create changeset for an unpersisted project (key editable)" do
      changeset = Projects.change_project(%Project{})
      assert %Ecto.Changeset{} = changeset
      assert :key in changeset.required
    end

    test "returns an update changeset for a persisted project (key omitted)" do
      project = project_fixture()
      changeset = Projects.change_project(project, %{key: "nope", name: "Still"})
      refute Map.has_key?(changeset.changes, :key)
    end
  end

  describe "create_api_token/2" do
    test "mints a token and returns the one-time plaintext secret" do
      project = project_fixture()

      assert {:ok, token, secret} = Projects.create_api_token(project, %{name: "ci"})
      assert token.project_id == project.id
      assert token.name == "ci"
      assert String.starts_with?(secret, "alloy_")
    end

    test "stores only the hash, never the plaintext" do
      project = project_fixture()
      {:ok, token, secret} = Projects.create_api_token(project, %{name: "ci"})

      refute token.token_hash == secret
      assert token.token_hash == Alloy.Projects.ApiToken.hash(secret)
    end

    test "issues a distinct secret each time" do
      project = project_fixture()
      {:ok, _, a} = Projects.create_api_token(project, %{name: "one"})
      {:ok, _, b} = Projects.create_api_token(project, %{name: "two"})
      refute a == b
    end

    test "requires a name" do
      project = project_fixture()
      assert {:error, changeset} = Projects.create_api_token(project, %{name: ""})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "list_api_tokens/1" do
    test "returns the project's tokens, newest first" do
      project = project_fixture()
      {:ok, older, _} = Projects.create_api_token(project, %{name: "older"})
      {:ok, newer, _} = Projects.create_api_token(project, %{name: "newer"})

      assert project |> Projects.list_api_tokens() |> Enum.map(& &1.id) == [newer.id, older.id]
    end

    test "is scoped to the project" do
      mine = project_fixture(key: "mine", name: "Mine")
      theirs = project_fixture(key: "theirs", name: "Theirs")
      {:ok, token, _} = Projects.create_api_token(mine, %{name: "mine"})
      {:ok, _, _} = Projects.create_api_token(theirs, %{name: "theirs"})

      assert mine |> Projects.list_api_tokens() |> Enum.map(& &1.id) == [token.id]
    end
  end

  describe "authenticate_token/1" do
    test "returns the owning project for a valid secret" do
      project = project_fixture()
      {:ok, _token, secret} = Projects.create_api_token(project, %{name: "ci"})

      assert %Project{id: id} = Projects.authenticate_token(secret)
      assert id == project.id
    end

    test "touches last_used_at on a successful authentication" do
      project = project_fixture()
      {:ok, token, secret} = Projects.create_api_token(project, %{name: "ci"})
      assert token.last_used_at == nil

      Projects.authenticate_token(secret)

      assert [%{last_used_at: used}] = Projects.list_api_tokens(project)
      assert used != nil
    end

    test "returns nil for an unknown secret" do
      assert Projects.authenticate_token("alloy_nope") == nil
    end

    test "returns nil for a non-binary secret" do
      assert Projects.authenticate_token(nil) == nil
    end
  end

  describe "delete_api_token/1" do
    test "revokes the token so it no longer authenticates" do
      project = project_fixture()
      {:ok, token, secret} = Projects.create_api_token(project, %{name: "ci"})

      assert {:ok, _} = Projects.delete_api_token(token)
      assert Projects.authenticate_token(secret) == nil
      assert Projects.list_api_tokens(project) == []
    end
  end
end
