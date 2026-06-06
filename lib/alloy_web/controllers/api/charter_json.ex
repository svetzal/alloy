defmodule AlloyWeb.Api.CharterJSON do
  @moduledoc "Serializes a project's charter for the JSON API."

  alias Alloy.Charters.Charter

  @doc """
  The public JSON shape of a charter. Accepts an unsaved `%Charter{}` (with nil
  fields) so a project without a charter still serializes to the five-field
  shape rather than a special-case null.
  """
  def data(%Charter{} = charter) do
    %{
      mission: charter.mission,
      target_audience: charter.target_audience,
      problem_space: charter.problem_space,
      differentiators: charter.differentiators,
      out_of_scope: charter.out_of_scope
    }
  end
end
