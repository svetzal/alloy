defmodule Alloy.Intent do
  @moduledoc """
  The Intent context: capture and refinement of Engineering Intent Records.

  This context owns all persistence for `Alloy.Intent.Record`. The web layer
  delegates here; it never builds Ecto queries directly.
  """

  import Ecto.Query, warn: false

  alias Alloy.Intent.Record
  alias Alloy.Repo

  @doc """
  Returns all engineering intent records, most recently created first.
  """
  def list_records do
    Repo.all(from r in Record, order_by: [desc: r.inserted_at, desc: r.id])
  end

  @doc """
  Gets a single record.

  Raises `Ecto.NoResultsError` if the record does not exist.
  """
  def get_record!(id), do: Repo.get!(Record, id)

  @doc """
  Creates an engineering intent record.
  """
  def create_record(attrs \\ %{}) do
    %Record{}
    |> Record.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an engineering intent record.
  """
  def update_record(%Record{} = record, attrs) do
    record
    |> Record.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an engineering intent record.
  """
  def delete_record(%Record{} = record) do
    Repo.delete(record)
  end

  @doc """
  Returns a changeset for tracking record changes (e.g. to drive a form).
  """
  def change_record(%Record{} = record, attrs \\ %{}) do
    Record.changeset(record, attrs)
  end
end
