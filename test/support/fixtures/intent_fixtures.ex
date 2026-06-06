defmodule Alloy.IntentFixtures do
  @moduledoc """
  Test fixtures for the `Alloy.Intent` context.
  """

  @doc """
  Generate an engineering intent record.
  """
  def record_fixture(attrs \\ %{}) do
    {:ok, record} =
      attrs
      |> Enum.into(%{
        title: "Business rules testable without I/O",
        capability: "Business rules can be tested without UI, network, or database.",
        threat: "Business logic leaking into LiveView event handlers.",
        expectation: "UI flows will evolve faster than domain policy.",
        strategy: "Functional Core / Imperative Shell.",
        evidence_summary: "Domain tests run without a database.",
        tradeoff: "Functional core boundaries can be over-applied to simple CRUD.",
        status: :proposed,
        confidence: 0.8,
        scope: %{"project" => "alloy", "paths" => []}
      })
      |> Alloy.Intent.create_record()

    record
  end
end
