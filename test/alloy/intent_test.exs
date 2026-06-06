defmodule Alloy.IntentTest do
  use Alloy.DataCase, async: true

  alias Alloy.Intent
  alias Alloy.Intent.Record

  import Alloy.IntentFixtures

  describe "list_records/0" do
    test "returns all records, newest first" do
      older = record_fixture(title: "Older")
      newer = record_fixture(title: "Newer")

      ids = Intent.list_records() |> Enum.map(& &1.id)

      assert ids == [newer.id, older.id]
    end

    test "returns an empty list when there are no records" do
      assert Intent.list_records() == []
    end
  end

  describe "get_record!/1" do
    test "returns the record with the given id" do
      record = record_fixture()
      assert Intent.get_record!(record.id).id == record.id
    end

    test "raises when the record does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Intent.get_record!(Ecto.UUID.generate())
      end
    end
  end

  describe "create_record/1" do
    test "with valid data creates a record" do
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

      assert {:ok, %Record{} = record} = Intent.create_record(attrs)
      assert record.title == "Replaceable service providers"
      assert record.strategy == "Gateway abstractions behind behaviours."
      assert record.confidence == 0.9
    end

    test "defaults status to :proposed, version to 1, confidence to 1.0" do
      assert {:ok, %Record{} = record} = Intent.create_record(%{title: "Defaults"})
      assert record.status == :proposed
      assert record.version == 1
      assert record.confidence == 1.0
    end

    test "requires a title" do
      assert {:error, changeset} = Intent.create_record(%{title: ""})
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "rejects an unknown status" do
      assert {:error, changeset} = Intent.create_record(%{title: "x", status: :nonsense})
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "accepts every lifecycle status" do
      for status <- [
            :hypothesized,
            :proposed,
            :accepted,
            :active,
            :deprecated,
            :contradicted,
            :superseded
          ] do
        assert {:ok, %Record{status: ^status}} =
                 Intent.create_record(%{title: "s", status: status})
      end
    end

    test "rejects confidence outside 0.0..1.0" do
      assert {:error, low} = Intent.create_record(%{title: "x", confidence: -0.1})
      assert %{confidence: [_]} = errors_on(low)

      assert {:error, high} = Intent.create_record(%{title: "x", confidence: 1.1})
      assert %{confidence: [_]} = errors_on(high)
    end

    test "rejects a version below 1" do
      assert {:error, changeset} = Intent.create_record(%{title: "x", version: 0})
      assert %{version: [_]} = errors_on(changeset)
    end
  end

  describe "update_record/2" do
    test "with valid data updates the record" do
      record = record_fixture()

      assert {:ok, %Record{} = updated} =
               Intent.update_record(record, %{status: :accepted, title: "Renamed"})

      assert updated.status == :accepted
      assert updated.title == "Renamed"
    end

    test "with invalid data returns an error changeset and leaves the record untouched" do
      record = record_fixture()
      assert {:error, %Ecto.Changeset{}} = Intent.update_record(record, %{title: ""})
      assert Intent.get_record!(record.id).title == record.title
    end
  end

  describe "delete_record/1" do
    test "deletes the record" do
      record = record_fixture()
      assert {:ok, %Record{}} = Intent.delete_record(record)
      assert_raise Ecto.NoResultsError, fn -> Intent.get_record!(record.id) end
    end
  end

  describe "change_record/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = Intent.change_record(record_fixture())
    end
  end

  describe "supersedes_id" do
    test "a record may point at the record it supersedes" do
      original = record_fixture(title: "v1")

      assert {:ok, replacement} =
               Intent.create_record(%{title: "v2", supersedes_id: original.id, version: 2})

      assert replacement.supersedes_id == original.id
      assert replacement.version == 2
    end
  end
end
