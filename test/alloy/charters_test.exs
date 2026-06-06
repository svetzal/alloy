defmodule Alloy.ChartersTest do
  use Alloy.DataCase, async: true

  alias Alloy.Charters
  alias Alloy.Charters.Charter

  import Alloy.ChartersFixtures
  import Alloy.ProjectsFixtures

  describe "get_charter/1" do
    test "returns nil when the project has no charter" do
      project = project_fixture()
      assert Charters.get_charter(project) == nil
    end

    test "returns the project's charter" do
      project = project_fixture()
      charter = charter_fixture(project: project, mission: "Ship intent")
      assert Charters.get_charter(project).id == charter.id
    end
  end

  describe "get_or_new_charter/1" do
    test "returns an unsaved charter scoped to the project when none exists" do
      project = project_fixture()
      charter = Charters.get_or_new_charter(project)

      assert %Charter{} = charter
      assert charter.id == nil
      assert charter.project_id == project.id
    end

    test "returns the existing charter when one exists" do
      project = project_fixture()
      existing = charter_fixture(project: project)
      assert Charters.get_or_new_charter(project).id == existing.id
    end
  end

  describe "upsert_charter/2" do
    test "creates a charter when the project has none" do
      project = project_fixture()

      assert {:ok, %Charter{} = charter} =
               Charters.upsert_charter(project, %{mission: "Preserve intent"})

      assert charter.mission == "Preserve intent"
      assert charter.project_id == project.id
    end

    test "updates the existing charter instead of inserting a second" do
      project = project_fixture()
      {:ok, first} = Charters.upsert_charter(project, %{mission: "First"})
      {:ok, second} = Charters.upsert_charter(project, %{mission: "Second"})

      assert first.id == second.id
      assert second.mission == "Second"
      assert Charters.get_charter(project).id == first.id
    end

    test "trims whitespace and normalizes blank fields to nil" do
      project = project_fixture()

      assert {:ok, charter} =
               Charters.upsert_charter(project, %{
                 mission: "  Trim me  ",
                 target_audience: "   "
               })

      assert charter.mission == "Trim me"
      assert charter.target_audience == nil
    end
  end

  describe "present?/1" do
    test "false for a project with no charter" do
      refute Charters.present?(project_fixture())
    end

    test "false for a charter with all blank fields" do
      project = project_fixture()
      {:ok, charter} = Charters.upsert_charter(project, %{mission: "   "})
      refute Charters.present?(charter)
      refute Charters.present?(project)
    end

    test "true once any field is filled in" do
      project = project_fixture()
      {:ok, charter} = Charters.upsert_charter(project, %{problem_space: "Drift"})
      assert Charters.present?(charter)
      assert Charters.present?(project)
    end
  end

  describe "change_charter/2" do
    test "returns a charter changeset" do
      assert %Ecto.Changeset{} = Charters.change_charter(%Charter{}, %{mission: "x"})
    end
  end
end
