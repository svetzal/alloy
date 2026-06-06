defmodule Alloy.IntentTest do
  use Alloy.DataCase, async: true

  alias Alloy.Intent
  alias Alloy.Intent.Record

  import Alloy.IntentFixtures
  import Alloy.ProjectsFixtures

  setup do
    {:ok, project: project_fixture()}
  end

  describe "list_records/1" do
    test "returns the project's records, newest first", %{project: project} do
      older = record_fixture(project: project, title: "Older")
      newer = record_fixture(project: project, title: "Newer")

      ids = project |> Intent.list_records() |> Enum.map(& &1.id)

      assert ids == [newer.id, older.id]
    end

    test "is scoped to the project", %{project: project} do
      other = project_fixture(key: "other", name: "Other")
      mine = record_fixture(project: project, title: "Mine")
      _theirs = record_fixture(project: other, title: "Theirs")

      assert project |> Intent.list_records() |> Enum.map(& &1.id) == [mine.id]
    end

    test "returns an empty list when the project has no records", %{project: project} do
      assert Intent.list_records(project) == []
    end
  end

  describe "get_record!/1" do
    test "returns the record with its project preloaded", %{project: project} do
      record = record_fixture(project: project)
      fetched = Intent.get_record!(record.id)
      assert fetched.id == record.id
      assert fetched.project.id == project.id
    end

    test "raises when the record does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Intent.get_record!(Ecto.UUID.generate())
      end
    end
  end

  describe "get_record_by_slug!/2" do
    test "returns the project's record with the given slug", %{project: project} do
      record = record_fixture(project: project, slug: "my_record")
      assert Intent.get_record_by_slug!(project, "my_record").id == record.id
    end

    test "raises when no record in the project has that slug", %{project: project} do
      assert_raise Ecto.NoResultsError, fn ->
        Intent.get_record_by_slug!(project, "missing")
      end
    end
  end

  describe "create_record/2" do
    test "with valid data creates a record under the project", %{project: project} do
      attrs = %{
        title: "Replaceable service providers",
        capability: "External providers can be swapped without rewriting domain logic.",
        threat: "Vendor SDK types spreading into domain modules.",
        expectation: "Payment providers are likely to change.",
        strategy: "Gateway abstractions behind behaviours.",
        evidence_summary: "Vendor SDK imports only appear in adapter modules.",
        tradeoff: "Gateways can become ceremony if volatility is low.",
        confidence: 0.9
      }

      assert {:ok, %Record{} = record} = Intent.create_record(project, attrs)
      assert record.project_id == project.id
      assert record.title == "Replaceable service providers"
      assert record.confidence == 0.9
    end

    test "derives the slug from the title when blank", %{project: project} do
      assert {:ok, %Record{} = record} =
               Intent.create_record(project, %{title: "Stable Failure Semantics"})

      assert record.slug == "stable_failure_semantics"
    end

    test "accepts an explicit slug", %{project: project} do
      assert {:ok, %Record{slug: "custom-slug"}} =
               Intent.create_record(project, %{title: "x", slug: "custom-slug"})
    end

    test "rejects an invalid slug format", %{project: project} do
      assert {:error, changeset} =
               Intent.create_record(project, %{title: "x", slug: "Not A Slug"})

      assert %{slug: [_]} = errors_on(changeset)
    end

    test "defaults status to :proposed, version to 1, confidence to 1.0", %{project: project} do
      assert {:ok, %Record{} = record} = Intent.create_record(project, %{title: "Defaults"})
      assert record.status == :proposed
      assert record.version == 1
      assert record.confidence == 1.0
    end

    test "requires a title", %{project: project} do
      assert {:error, changeset} = Intent.create_record(project, %{title: ""})
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "rejects an unknown status", %{project: project} do
      assert {:error, changeset} =
               Intent.create_record(project, %{title: "x", status: :nonsense})

      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "accepts every lifecycle status", %{project: project} do
      for status <- Record.statuses() do
        assert {:ok, %Record{status: ^status}} =
                 Intent.create_record(project, %{title: "s-#{status}", status: status})
      end
    end

    test "rejects confidence outside 0.0..1.0", %{project: project} do
      assert {:error, low} = Intent.create_record(project, %{title: "x", confidence: -0.1})
      assert %{confidence: [_]} = errors_on(low)

      assert {:error, high} = Intent.create_record(project, %{title: "y", confidence: 1.1})
      assert %{confidence: [_]} = errors_on(high)
    end

    test "rejects a version below 1", %{project: project} do
      assert {:error, changeset} = Intent.create_record(project, %{title: "x", version: 0})
      assert %{version: [_]} = errors_on(changeset)
    end

    test "enforces slug uniqueness within a project", %{project: project} do
      record_fixture(project: project, slug: "dup")

      assert {:error, changeset} =
               Intent.create_record(project, %{title: "x", slug: "dup"})

      assert %{slug: [_]} = errors_on(changeset)
    end

    test "allows the same slug in different projects", %{project: project} do
      other = project_fixture(key: "other", name: "Other")
      assert {:ok, _} = Intent.create_record(project, %{title: "x", slug: "shared"})
      assert {:ok, _} = Intent.create_record(other, %{title: "x", slug: "shared"})
    end
  end

  describe "update_record/2" do
    test "with valid data updates the record", %{project: project} do
      record = record_fixture(project: project)

      assert {:ok, %Record{} = updated} =
               Intent.update_record(record, %{status: :accepted, title: "Renamed"})

      assert updated.status == :accepted
      assert updated.title == "Renamed"
    end

    test "with invalid data returns an error changeset and leaves the record untouched", %{
      project: project
    } do
      record = record_fixture(project: project)
      assert {:error, %Ecto.Changeset{}} = Intent.update_record(record, %{title: ""})
      assert Intent.get_record!(record.id).title == record.title
    end

    test "ignores attempts to change the immutable slug", %{project: project} do
      record = record_fixture(project: project, slug: "fixed")
      assert {:ok, updated} = Intent.update_record(record, %{slug: "changed", title: "t"})
      assert updated.slug == "fixed"
    end
  end

  describe "delete_record/1" do
    test "deletes the record", %{project: project} do
      record = record_fixture(project: project)
      assert {:ok, %Record{}} = Intent.delete_record(record)
      assert_raise Ecto.NoResultsError, fn -> Intent.get_record!(record.id) end
    end
  end

  describe "change_record/2" do
    test "returns a create changeset for an unpersisted record (slug editable)" do
      changeset = Intent.change_record(%Record{})
      assert %Ecto.Changeset{} = changeset
      assert :slug in changeset.required
    end

    test "returns an update changeset for a persisted record (slug omitted)", %{project: project} do
      record = record_fixture(project: project)
      changeset = Intent.change_record(record, %{slug: "nope", title: "t"})
      refute Map.has_key?(changeset.changes, :slug)
    end
  end

  describe "supersedes_id" do
    test "a record may point at the record it supersedes", %{project: project} do
      original = record_fixture(project: project, title: "v1", slug: "v1")

      assert {:ok, replacement} =
               Intent.create_record(project, %{
                 title: "v2",
                 slug: "v2",
                 supersedes_id: original.id,
                 version: 2
               })

      assert replacement.supersedes_id == original.id
      assert replacement.version == 2
    end
  end

  describe "Record.full_key/1" do
    test "namespaces the slug by the project key", %{project: project} do
      record = record_fixture(project: project, slug: "my_record")
      assert Record.full_key(Intent.get_record!(record.id)) == "#{project.key}.intent.my_record"
    end
  end
end
