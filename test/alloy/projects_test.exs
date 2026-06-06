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
end
